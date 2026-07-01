#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <dos/dos.h>
#include <devices/timer.h>
#include <exec/io.h>
#include <exec/ports.h>
#include <intuition/intuition.h>
#include <graphics/gfxbase.h>
#include <graphics/rastport.h>

#include <proto/exec.h>
#include <proto/dos.h>
#include <proto/intuition.h>
#include <proto/graphics.h>
#include <proto/alib.h>
#include <proto/socket.h>

#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/filio.h>
#include <netdb.h>
#include <netinet/in.h>

#include <string.h>
#include <stdio.h>

#include "mas_direct.h"


#define APP_TITLE "MASRadio v0.1"
#define VERSION_TEXT "MASRadio v0.1 by Marcel Jaehne (c)2026"

#define WIN_W 520
#define WIN_H 190
#define MAX_RESULTS 8
#define TITLE_LEN 64
#define URL_LEN 192
#define GENRE_LEN 48
#define STATUS_LEN 96
#define PLAYLIST_FILE "playlist.txt"
#define PLAYLIST_LINE_LEN 320
#define HTTP_BUF_SIZE 2048
#define STREAM_NET_CHUNK 512
#define PREBUFFER_BYTES 131072UL
#define PUMP_INTERVAL_US 20000UL
#define MAX_PUMP_READS 16
#define STATUS_UPDATE_TICKS 25

#define AMITLS13F_INSECURE 0x00000001UL
#define AMITLS13_OK 0L

#define GID_SEARCH 1
#define GID_SEARCH_BUTTON 2
#define GID_PLAY 3
#define GID_STOP 4
#define GID_PREV 5
#define GID_NEXT 6
#define GID_QUIT 7

LONG __stack = 524288;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *SocketBase;
struct Library *AmiTLS13Base;
struct AmiTLS13Context;

LONG AmiTLS13_Init(void);
void AmiTLS13_Exit(void);
struct AmiTLS13Context *AmiTLS13_Connect(const char *host, UWORD port, ULONG flags);
LONG AmiTLS13_StartTLS(struct AmiTLS13Context *ctx, const char *host);
LONG AmiTLS13_Write(struct AmiTLS13Context *ctx, const UBYTE *buf, ULONG len);
LONG AmiTLS13_Read(struct AmiTLS13Context *ctx, UBYTE *buf, ULONG maxlen);
void AmiTLS13_Close(struct AmiTLS13Context *ctx);

struct StreamEntry {
    char title[TITLE_LEN];
    char url[URL_LEN];
    char genre[GENRE_LEN];
    LONG bitrate;
};

struct StreamState {
    int fd;
    int active;
    int started;
    int is_tls;
    struct AmiTLS13Context *tls_ctx;
};

static struct Window *g_win;
static struct StreamEntry g_results[MAX_RESULTS];
static LONG g_result_count;
static LONG g_selected;
static char g_status[STATUS_LEN] = "Ready";
static struct StreamState g_stream;

struct TimerState {
    struct MsgPort *port;
    struct timerequest *req;
    ULONG sigmask;
    UBYTE opened;
    UBYTE pending;
};

static struct TimerState g_timer;
static UBYTE g_net_buf[STREAM_NET_CHUNK];
static UBYTE g_pending_buf[HTTP_BUF_SIZE];
static UBYTE g_header_read_buf[HTTP_BUF_SIZE];
static LONG g_pending_pos;
static LONG g_pending_len;
static char g_http_headers[2048];
static char g_http_path[256];
static char g_http_location[URL_LEN];
static char g_http_redirect[URL_LEN];
static char g_http_current[URL_LEN];
static char g_status_scratch[STATUS_LEN];
static ULONG g_total_stream_bytes;
static UWORD g_status_tick;
static int g_stack_missing;
static char g_stream_error[STATUS_LEN];


static struct IntuiText g_txt_search_btn = {1,0,JAM1,8,3,0,(UBYTE *)"Reload",0};
static struct IntuiText g_txt_play = {1,0,JAM1,14,3,0,(UBYTE *)"Play",0};
static struct IntuiText g_txt_stop = {1,0,JAM1,14,3,0,(UBYTE *)"Stop",0};
static struct IntuiText g_txt_prev = {1,0,JAM1,10,3,0,(UBYTE *)"Prev",0};
static struct IntuiText g_txt_next = {1,0,JAM1,10,3,0,(UBYTE *)"Next",0};
static struct IntuiText g_txt_quit = {1,0,JAM1,10,3,0,(UBYTE *)"Quit",0};

static struct Gadget g_quit_gad;
static struct Gadget g_next_gad;
static struct Gadget g_prev_gad;
static struct Gadget g_stop_gad;
static struct Gadget g_play_gad;
static struct Gadget g_search_btn_gad;

static LONG cstrlen(const char *s)
{
    LONG n = 0;
    while (s && s[n]) ++n;
    return n;
}

static int starts_with(const char *s, const char *p)
{
    while (*p) {
        if (*s++ != *p++) return 0;
    }
    return 1;
}

static char lower_char(char c)
{
    if (c >= 'A' && c <= 'Z') return c + 32;
    return c;
}

static void copy_trim(char *dst, LONG dst_size, const char *src, LONG len)
{
    LONG i, out = 0;
    if (dst_size <= 0) return;
    while (len > 0 && (*src == ' ' || *src == '\n' || *src == '\r' || *src == '\t')) {
        ++src; --len;
    }
    while (len > 0 && (src[len - 1] == ' ' || src[len - 1] == '\n' || src[len - 1] == '\r' || src[len - 1] == '\t')) --len;
    for (i = 0; i < len && out < dst_size - 1; ++i) {
        char c = src[i];
        if (c == '&') {
            if (i + 4 < len && src[i+1] == 'a' && src[i+2] == 'm' && src[i+3] == 'p' && src[i+4] == ';') { c = '&'; i += 4; }
            else if (i + 3 < len && src[i+1] == 'l' && src[i+2] == 't' && src[i+3] == ';') { c = '<'; i += 3; }
            else if (i + 3 < len && src[i+1] == 'g' && src[i+2] == 't' && src[i+3] == ';') { c = '>'; i += 3; }
        }
        if ((UBYTE)c < 32) c = ' ';
        dst[out++] = c;
    }
    dst[out] = 0;
}

static int parse_url(const char *url, char *host, LONG host_size, char *path, LONG path_size, UWORD *port)
{
    const char *p;
    const char *slash;
    const char *colon;
    LONG host_len;
    if (starts_with(url, "http://")) {
        p = url + 7;
        *port = 80;
    }
    else if (starts_with(url, "https://")) {
        p = url + 8;
        *port = 443;
    }
    else return 0;
    slash = strchr(p, '/');
    if (!slash) slash = p + cstrlen(p);
    colon = p;
    while (colon < slash && *colon != ':') ++colon;
    host_len = (LONG)((colon < slash) ? (colon - p) : (slash - p));
    if (host_len <= 0 || host_len >= host_size) return 0;
    memcpy(host, p, host_len);
    host[host_len] = 0;
    if (colon < slash && *colon == ':') {
        LONG v = 0;
        ++colon;
        while (colon < slash && *colon >= '0' && *colon <= '9') {
            v = v * 10 + (*colon - '0');
            ++colon;
        }
        if (v > 0 && v < 65536) *port = (UWORD)v;
    }
    if (*slash) strncpy(path, slash, path_size - 1);
    else strncpy(path, "/", path_size - 1);
    path[path_size - 1] = 0;
    return 1;
}

static int open_socket_lib(void)
{
    if (!SocketBase) SocketBase = OpenLibrary((STRPTR)"bsdsocket.library", 4);
    if (!SocketBase) {
        g_stack_missing = 1;
        return 0;
    }
    return 1;
}

static int connect_http(const char *url, char *path, LONG path_size)
{
    char host[96];
    UWORD port;
    struct hostent *he;
    struct sockaddr_in sa;
    int fd;
    if (!open_socket_lib()) return -1;
    if (!parse_url(url, host, sizeof(host), path, path_size, &port)) return -1;
    he = gethostbyname((STRPTR)host);
    if (!he || !he->h_addr) return -1;
    fd = socket(AF_INET, SOCK_STREAM, 0);
    if (fd < 0) return -1;
    memset(&sa, 0, sizeof(sa));
    sa.sin_family = AF_INET;
    sa.sin_port = htons(port);
    memcpy(&sa.sin_addr, he->h_addr, 4);
    if (connect(fd, (struct sockaddr *)&sa, sizeof(sa)) < 0) {
        CloseSocket(fd);
        return -1;
    }
    return fd;
}

static int ensure_tls_lib(void)
{
    if (AmiTLS13Base) return 1;
    AmiTLS13Base = OpenLibrary((STRPTR)"amitls13.library", 2);
    if (!AmiTLS13Base) return 0;
    if (AmiTLS13_Init() != AMITLS13_OK) {
        CloseLibrary(AmiTLS13Base);
        AmiTLS13Base = 0;
        g_stack_missing = 1;
        return 0;
    }
    return 1;
}

static void close_tls_lib(void)
{
    if (AmiTLS13Base) {
        AmiTLS13_Exit();
        CloseLibrary(AmiTLS13Base);
        AmiTLS13Base = 0;
    }
}

static int tls_library_installed(void)
{
    struct Library *lib = OpenLibrary((STRPTR)"amitls13.library", 2);
    if (!lib) return 0;
    CloseLibrary(lib);
    return 1;
}

static int timer_init(void)
{
    memset(&g_timer, 0, sizeof(g_timer));
    g_timer.port = CreatePort(0, 0);
    if (!g_timer.port) return 0;
    g_timer.req = (struct timerequest *)AllocMem(sizeof(struct timerequest), MEMF_PUBLIC | MEMF_CLEAR);
    if (!g_timer.req) { DeletePort(g_timer.port); g_timer.port = 0; return 0; }
    g_timer.req->tr_node.io_Message.mn_ReplyPort = g_timer.port;
    if (OpenDevice((STRPTR)TIMERNAME, UNIT_MICROHZ, (struct IORequest *)g_timer.req, 0) != 0) {
        FreeMem(g_timer.req, sizeof(struct timerequest));
        DeletePort(g_timer.port);
        memset(&g_timer, 0, sizeof(g_timer));
        return 0;
    }
    g_timer.opened = 1;
    g_timer.sigmask = 1UL << g_timer.port->mp_SigBit;
    return 1;
}

static void timer_start(void)
{
    if (!g_timer.opened || g_timer.pending) return;
    g_timer.req->tr_node.io_Command = TR_ADDREQUEST;
    g_timer.req->tr_time.tv_secs = 0;
    g_timer.req->tr_time.tv_micro = PUMP_INTERVAL_US;
    SendIO((struct IORequest *)g_timer.req);
    g_timer.pending = 1;
}

static void timer_stop(void)
{
    if (!g_timer.opened || !g_timer.pending) return;
    if (!CheckIO((struct IORequest *)g_timer.req)) AbortIO((struct IORequest *)g_timer.req);
    WaitIO((struct IORequest *)g_timer.req);
    g_timer.pending = 0;
}

static int timer_drain(void)
{
    struct Message *msg;
    int got = 0;
    if (!g_timer.opened) return 0;
    while ((msg = GetMsg(g_timer.port))) { (void)msg; got = 1; }
    if (got) g_timer.pending = 0;
    return got;
}

static void timer_cleanup(void)
{
    timer_stop();
    if (g_timer.opened) CloseDevice((struct IORequest *)g_timer.req);
    if (g_timer.req) FreeMem(g_timer.req, sizeof(struct timerequest));
    if (g_timer.port) DeletePort(g_timer.port);
    memset(&g_timer, 0, sizeof(g_timer));
}

static void draw_status(void);

static void set_status(const char *s)
{
    strncpy(g_status, s, STATUS_LEN - 1);
    g_status[STATUS_LEN - 1] = 0;
}

static void draw_status(void)
{
    if (!g_win) return;
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, 8, g_win->Height - 30, g_win->Width - 12, g_win->Height - 12);
    SetAPen(g_win->RPort, 1);
    SetBPen(g_win->RPort, 0);
    SetDrMd(g_win->RPort, JAM1);
    Move(g_win->RPort, 12, g_win->Height - 18);
    Text(g_win->RPort, (STRPTR)g_status, cstrlen(g_status));
}


static void draw_ui(void)
{
    LONG i;
    char line[160];
    if (!g_win) return;
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, 8, 38, g_win->Width - 12, g_win->Height - 12);
    SetAPen(g_win->RPort, 1);
    SetBPen(g_win->RPort, 0);
    SetDrMd(g_win->RPort, JAM1);
    Move(g_win->RPort, 12, 52);
    Text(g_win->RPort, (STRPTR)"Streams from playlist.txt", 25);
    for (i = 0; i < MAX_RESULTS; ++i) {
        LONG idx = i;
        Move(g_win->RPort, 16, 72 + i * 11);
        if (idx < g_result_count) {
            if (idx == g_selected) SetAPen(g_win->RPort, 3); else SetAPen(g_win->RPort, 1);
            line[0] = 0;
            strncat(line, g_results[idx].title, 56);
            strncat(line, "  ", sizeof(line)-strlen(line)-1);
            if (g_results[idx].bitrate > 0) {
                char b[16];
                sprintf(b, "%ldk", g_results[idx].bitrate);
                strncat(line, b, sizeof(line)-strlen(line)-1);
            }
            Text(g_win->RPort, (STRPTR)line, cstrlen(line));
        }
    }
    draw_status();
}

static void clear_playlist(void)
{
    LONG i;
    for (i = 0; i < MAX_RESULTS; ++i) {
        g_results[i].title[0] = 0;
        g_results[i].url[0] = 0;
        g_results[i].genre[0] = 0;
        g_results[i].bitrate = 0;
    }
    g_result_count = 0;
    g_selected = 0;
}

static void derive_title_from_url(const char *url, char *title, LONG title_size, LONG index)
{
    const char *p = url;
    const char *slash;
    LONG len;
    char tmp[24];

    if (starts_with(p, "http://")) p += 7;
    else if (starts_with(p, "https://")) p += 8;
    slash = strchr(p, '/');
    if (!slash) slash = p + cstrlen(p);
    len = (LONG)(slash - p);
    if (len <= 0) {
        strcpy(title, "Stream ");
        sprintf(tmp, "%ld", index + 1);
        strncat(title, tmp, title_size - strlen(title) - 1);
        return;
    }
    copy_trim(title, title_size, p, len);
}

static int parse_playlist_line(char *line, struct StreamEntry *out, LONG index)
{
    char *p = line;
    char *sep = 0;
    char *url;
    LONG len;

    while (*p == ' ' || *p == '\t') ++p;
    if (!*p || *p == '#' || *p == ';') return 0;

    len = cstrlen(p);
    while (len > 0 && (p[len - 1] == '\n' || p[len - 1] == '\r' || p[len - 1] == ' ' || p[len - 1] == '\t')) {
        p[--len] = 0;
    }
    if (!len) return 0;

    sep = strchr(p, '|');
    if (!sep) sep = strchr(p, '=');

    if (sep) {
        *sep++ = 0;
        while (*sep == ' ' || *sep == '\t') ++sep;
        url = sep;
        copy_trim(out->title, TITLE_LEN, p, cstrlen(p));
        if (!out->title[0]) derive_title_from_url(url, out->title, TITLE_LEN, index);
    }
    else {
        url = p;
        derive_title_from_url(url, out->title, TITLE_LEN, index);
    }

    if (!starts_with(url, "http://") && !starts_with(url, "https://")) return 0;
    copy_trim(out->url, URL_LEN, url, cstrlen(url));
    out->genre[0] = 0;
    out->bitrate = 0;
    return out->url[0] != 0;
}

static void load_playlist(void)
{
    BPTR f;
    char line[PLAYLIST_LINE_LEN];
    LONG pos = 0;
    char c;
    LONG got;

    clear_playlist();
    f = Open((STRPTR)PLAYLIST_FILE, MODE_OLDFILE);
    if (!f) {
        set_status("playlist.txt not found");
        draw_ui();
        return;
    }

    while (g_result_count < MAX_RESULTS && (got = Read(f, &c, 1)) > 0) {
        if (c == '\n' || pos >= PLAYLIST_LINE_LEN - 1) {
            line[pos] = 0;
            if (parse_playlist_line(line, &g_results[g_result_count], g_result_count)) ++g_result_count;
            pos = 0;
        }
        else {
            line[pos++] = c;
        }
    }
    if (pos > 0 && g_result_count < MAX_RESULTS) {
        line[pos] = 0;
        if (parse_playlist_line(line, &g_results[g_result_count], g_result_count)) ++g_result_count;
    }
    Close(f);

    if (g_result_count <= 0) set_status("No streams in playlist.txt");
    else set_status("Playlist loaded");
    draw_ui();
}

static LONG stream_read_transport(UBYTE *buf, LONG maxlen)
{
    if (g_pending_len > g_pending_pos) {
        LONG avail = g_pending_len - g_pending_pos;
        if (avail > maxlen) avail = maxlen;
        memcpy(buf, g_pending_buf + g_pending_pos, avail);
        g_pending_pos += avail;
        if (g_pending_pos >= g_pending_len) {
            g_pending_pos = 0;
            g_pending_len = 0;
        }
        return avail;
    }
    if (g_stream.is_tls) {
        LONG tls_n;
        if (!g_stream.tls_ctx) return -1;
        tls_n = AmiTLS13_Read(g_stream.tls_ctx, buf, (ULONG)maxlen);
        return tls_n;
    }
    return recv(g_stream.fd, buf, maxlen, 0);
}

static int stream_write_all_transport(const char *buf, LONG len)
{
    LONG done = 0;
    while (done < len) {
        LONG n;
        if (g_stream.is_tls) n = AmiTLS13_Write(g_stream.tls_ctx, (const UBYTE *)buf + done, (ULONG)(len - done));
        else n = send(g_stream.fd, (char *)buf + done, len - done, 0);
        if (n <= 0) return 0;
        done += n;
    }
    return 1;
}

static void stream_close_transport(void)
{
    g_pending_pos = 0;
    g_pending_len = 0;
    if (g_stream.tls_ctx) {
        AmiTLS13_Close(g_stream.tls_ctx);
        g_stream.tls_ctx = 0;
    }
    if (g_stream.fd >= 0) {
        CloseSocket(g_stream.fd);
        g_stream.fd = -1;
    }
    g_stream.is_tls = 0;
}

static int stream_send_request(const char *url)
{
    char path[256], host[96], req[512];
    UWORD port;
    if (!parse_url(url, host, sizeof(host), path, sizeof(path), &port)) return 0;
    strcpy(req, "GET ");
    strncat(req, path, sizeof(req)-strlen(req)-1);
    strncat(req, " HTTP/1.1\r\nHost: ", sizeof(req)-strlen(req)-1);
    strncat(req, host, sizeof(req)-strlen(req)-1);
    strncat(req, "\r\nUser-Agent: MASRadio/0.1\r\nAccept: */*\r\nConnection: close\r\n\r\n", sizeof(req)-strlen(req)-1);
    return stream_write_all_transport(req, cstrlen(req));
}

static int header_line_starts(const char *line, const char *prefix)
{
    while (*prefix) {
        if (lower_char(*line++) != lower_char(*prefix++)) return 0;
    }
    return 1;
}

static LONG find_header_end(const char *headers, LONG used)
{
    LONG i;
    for (i = 0; i + 3 < used; ++i) {
        if (headers[i] == '\r' && headers[i + 1] == '\n' &&
            headers[i + 2] == '\r' && headers[i + 3] == '\n') {
            return i + 4;
        }
    }
    for (i = 0; i + 1 < used; ++i) {
        if (headers[i] == '\n' && headers[i + 1] == '\n') return i + 2;
    }
    return -1;
}

static int stream_read_headers(char *headers, LONG headers_size)
{
    UBYTE *read_buf = g_header_read_buf;
    LONG used = 0;
    int ok = 0;

    if (!headers || headers_size <= 1) return 0;

    headers[0] = 0;
    g_pending_pos = 0;
    g_pending_len = 0;
    while (used < headers_size - 1) {
        LONG room = headers_size - 1 - used;
        LONG n;
        LONG end;
        if (room > STREAM_NET_CHUNK) room = STREAM_NET_CHUNK;
        room &= ~1L;
        if (room <= 0) break;
        n = stream_read_transport(read_buf, room);
        if (n <= 0) break;
        memcpy(headers + used, read_buf, n);
        used += n;
        headers[used] = 0;
        end = find_header_end(headers, used);
        if (end >= 0) {
            LONG extra = used - end;
            if (extra > 0) {
                if (extra > HTTP_BUF_SIZE) extra = HTTP_BUF_SIZE;
                memcpy(g_pending_buf, headers + end, extra);
                g_pending_pos = 0;
                g_pending_len = extra;
            }
            headers[end] = 0;
            ok = 1;
            break;
        }
    }
    return ok;
}

static int stream_status_code(const char *headers)
{
    const char *p = headers;
    int code = 0;
    if (!starts_with(headers, "HTTP/")) return 200;
    while (*p && *p != ' ') ++p;
    while (*p == ' ') ++p;
    while (*p >= '0' && *p <= '9') {
        code = code * 10 + (*p - '0');
        ++p;
    }
    return code;
}

static LONG stream_content_length(const char *headers)
{
    const char *p = headers;
    while (*p) {
        const char *line = p;
        while (*p && *p != '\n') ++p;
        if (*p == '\n') ++p;
        if (header_line_starts(line, "Content-Length:")) {
            LONG v = 0;
            line += 15;
            while (*line == ' ' || *line == '\t') ++line;
            while (*line >= '0' && *line <= '9') {
                v = (v * 10) + (*line - '0');
                ++line;
            }
            return v;
        }
    }
    return -1;
}

static void stream_drain_response_body(const char *headers)
{
    LONG len = stream_content_length(headers);
    UBYTE tmp[128];
    if (len <= 0) {
        g_pending_pos = 0;
        g_pending_len = 0;
        return;
    }
    while (len > 0 && g_pending_len > g_pending_pos) {
        LONG avail = g_pending_len - g_pending_pos;
        if (avail > len) avail = len;
        g_pending_pos += avail;
        len -= avail;
        if (g_pending_pos >= g_pending_len) {
            g_pending_pos = 0;
            g_pending_len = 0;
        }
    }
    while (len > 0) {
        LONG want = len > (LONG)sizeof(tmp) ? (LONG)sizeof(tmp) : len;
        LONG n = stream_read_transport(tmp, want);
        if (n <= 0) break;
        len -= n;
    }
    g_pending_pos = 0;
    g_pending_len = 0;
}

static int stream_find_location(const char *headers, char *out, LONG out_size)
{
    const char *p = headers;
    while (*p) {
        const char *line = p;
        const char *end;
        while (*p && *p != '\n') ++p;
        end = p;
        if (*p == '\n') ++p;
        if (header_line_starts(line, "Location:")) {
            line += 9;
            while (line < end && (*line == ' ' || *line == '\t')) ++line;
            while (end > line && (end[-1] == '\r' || end[-1] == '\n' || end[-1] == ' ' || end[-1] == '\t')) --end;
            copy_trim(out, out_size, line, (LONG)(end - line));
            return out[0] != 0;
        }
    }
    if (out_size) out[0] = 0;
    return 0;
}

static void append_port(char *out, LONG out_size, UWORD port)
{
    char tmp[8];
    char b[8];
    UWORD i = 0;
    UWORD p = 0;
    UWORD v = port;

    if (!out || out_size <= 0) return;
    b[p++] = ':';
    do {
        tmp[i++] = (char)('0' + (v % 10));
        v = (UWORD)(v / 10);
    } while (v && i < sizeof(tmp));
    while (i > 0 && (ULONG)(p + 1) < sizeof(b)) b[p++] = tmp[--i];
    b[p] = 0;
    strncat(out, b, out_size - strlen(out) - 1);
}

static int stream_make_redirect_url(const char *base_url, const char *location, char *out, LONG out_size)
{
    char host[96];
    char path[256];
    UWORD port;

    if (!location || !out || out_size <= 0) return 0;
    out[0] = 0;
    if (starts_with(location, "http://") || starts_with(location, "https://")) {
        strncpy(out, location, out_size - 1);
        out[out_size - 1] = 0;
        return 1;
    }
    if (!parse_url(base_url, host, sizeof(host), path, sizeof(path), &port)) return 0;

    if (starts_with(base_url, "https://")) strcpy(out, "https://");
    else strcpy(out, "http://");
    strncat(out, host, out_size - strlen(out) - 1);
    if ((starts_with(base_url, "https://") && port != 443) ||
        (starts_with(base_url, "http://") && port != 80)) {
        append_port(out, out_size, port);
    }
    if (location[0] == '/') {
        strncat(out, location, out_size - strlen(out) - 1);
    }
    else {
        strncat(out, "/", out_size - strlen(out) - 1);
        strncat(out, location, out_size - strlen(out) - 1);
    }
    return out[0] != 0;
}

static void set_stream_error(const char *s)
{
    strncpy(g_stream_error, s, STATUS_LEN - 1);
    g_stream_error[STATUS_LEN - 1] = 0;
}

static void set_http_status_error(const char *headers, int is_tls)
{
    const char *p = headers;
    char line[72];
    LONG i = 0;

    while (*p && *p != '\r' && *p != '\n' && i < (LONG)sizeof(line) - 1) {
        line[i++] = *p++;
    }
    line[i] = 0;
    if (!line[0]) {
        set_stream_error("HTTP status not OK");
        return;
    }
    if (is_tls) {
        strcpy(g_stream_error, "HTTPS ");
        strncat(g_stream_error, line, sizeof(g_stream_error) - strlen(g_stream_error) - 1);
    }
    else {
        strncpy(g_stream_error, line, sizeof(g_stream_error) - 1);
        g_stream_error[sizeof(g_stream_error) - 1] = 0;
    }
}

static int stream_open_direct(const char *url)
{
    int redirect;
    set_stream_error("Stream connect/header failed");
    strncpy(g_http_current, url, sizeof(g_http_current) - 1);
    g_http_current[sizeof(g_http_current) - 1] = 0;
    for (redirect = 0; redirect < 3; ++redirect) {
        int code;
        char host[96];
        UWORD port;
        stream_close_transport();
        if (!parse_url(g_http_current, host, sizeof(host), g_http_path, sizeof(g_http_path), &port)) { set_stream_error("Unsupported stream URL"); return -1; }
        if (starts_with(g_http_current, "https://")) {
            set_status("Opening HTTPS..."); draw_status();
            if (!ensure_tls_lib()) {
                set_stream_error("Please install AmiTLS13 Library for https:// support");
                return -1;
            }
            g_stream.is_tls = 1;
            set_status("Connecting HTTPS..."); draw_status();
            g_stream.tls_ctx = AmiTLS13_Connect(host, port, AMITLS13F_INSECURE);
            if (!g_stream.tls_ctx) {
                set_stream_error("HTTPS TCP connect failed");
                return -1;
            }
            set_status("Starting TLS..."); draw_status();
            if (AmiTLS13_StartTLS(g_stream.tls_ctx, host) != AMITLS13_OK) {
                stream_close_transport();
                set_stream_error("HTTPS TLS start failed");
                return -1;
            }
        }
        else {
            g_stream.is_tls = 0;
            g_stream.fd = connect_http(g_http_current, g_http_path, sizeof(g_http_path));
            if (g_stream.fd < 0) { set_stream_error("HTTP socket connect failed"); return -1; }
        }
        set_status("Requesting stream..."); draw_status();
        if (!stream_send_request(g_http_current)) {
            stream_close_transport();
            set_stream_error("HTTP request send failed");
            return -1;
        }
        set_status("Reading stream header..."); draw_status();
        if (!stream_read_headers(g_http_headers, sizeof(g_http_headers))) {
            stream_close_transport();
            set_stream_error("HTTP header read failed");
            return -1;
        }
        code = stream_status_code(g_http_headers);
        
        if ((code == 301 || code == 302 || code == 303 || code == 307 || code == 308) &&
            stream_find_location(g_http_headers, g_http_location, sizeof(g_http_location)) &&
            stream_make_redirect_url(g_http_current, g_http_location, g_http_redirect, sizeof(g_http_redirect))) {
            
            stream_drain_response_body(g_http_headers);
            
            stream_close_transport();
            set_status("Following redirect..."); draw_status();
            strncpy(g_http_current, g_http_redirect, sizeof(g_http_current) - 1);
            g_http_current[sizeof(g_http_current) - 1] = 0;
            continue;
        }
        if (code >= 200 && code < 300) return 0;
        stream_close_transport();
        set_http_status_error(g_http_headers, starts_with(g_http_current, "https://"));
        return -1;
    }
    set_stream_error("Stream redirect failed");
    return -1;
}

static void stop_stream(void)
{
    timer_stop();
    mas_direct_stop();
    if (g_stream.active) stream_close_transport();
    g_stream.active = 0;
    g_stream.started = 0;
    g_status_tick = 0;
    set_status("Stopped");
    draw_ui();
}

static int stream_pump_socket(void)
{
    LONG reads = 0;
    int got_data = 0;

    if (!g_stream.active || (!g_stream.is_tls && g_stream.fd < 0) || (g_stream.is_tls && !g_stream.tls_ctx)) return 0;
    while (reads < MAX_PUMP_READS && mas_direct_buffer_free() >= STREAM_NET_CHUNK) {
        LONG n = stream_read_transport(g_net_buf, STREAM_NET_CHUNK);
        if (n <= 0) break;
        if (mas_direct_write(g_net_buf, (ULONG)n) != (ULONG)n) break;
        g_total_stream_bytes += (ULONG)n;
        got_data = 1;
        ++reads;
    }
    return got_data;
}

static int stream_prebuffer(void)
{
    g_total_stream_bytes = 0;
    while (mas_direct_buffer_used() < PREBUFFER_BYTES) {
        LONG n = stream_read_transport(g_net_buf, STREAM_NET_CHUNK);
        if (n <= 0) break;
        if (mas_direct_write(g_net_buf, (ULONG)n) != (ULONG)n) return 0;
        g_total_stream_bytes += (ULONG)n;
        if ((g_total_stream_bytes & 0x7fffUL) == 0) {
            sprintf(g_status_scratch, "Prebuffering %ld/%ld KB...", (LONG)(mas_direct_buffer_used() / 1024UL), (LONG)(PREBUFFER_BYTES / 1024UL));
            set_status(g_status_scratch);
            draw_status();
        }
    }
    return mas_direct_buffer_used() >= MAS_DIRECT_NEED_PREBUFFER;
}

static void play_selected(void)
{
    if (g_selected < 0 || g_selected >= g_result_count) { set_status("No stream selected"); draw_ui(); return; }
    if (!starts_with(g_results[g_selected].url, "http://") && !starts_with(g_results[g_selected].url, "https://")) { set_status("Unsupported stream URL"); draw_ui(); return; }

    stop_stream();
    set_status("Connecting stream...");
    draw_status();
    g_stack_missing = 0;
    g_stream.fd = -1;
    g_stream.tls_ctx = 0;
    g_stream.is_tls = 0;
    if (stream_open_direct(g_results[g_selected].url) < 0) {
        if (g_stack_missing) {
            set_status("Network stack is not running");
        } else if (starts_with(g_results[g_selected].url, "https://") && !AmiTLS13Base) {
            set_status("Please install AmiTLS13 Library for https:// support");
        } else {
            set_status(g_stream_error[0] ? g_stream_error : "Stream connect/header failed");
        }
        draw_ui();
        return;
    }

    if (!mas_direct_prepare()) {
        set_status("MAS buffer init failed");
        draw_ui();
        stream_close_transport();
        return;
    }

    g_stream.active = 1;
    g_stream.started = 0;
    set_status("Prebuffering stream...");
    draw_status();

    if (!stream_prebuffer()) {
        stream_close_transport();
        g_stream.active = 0;
        set_status("Stream prebuffer failed");
        draw_ui();
        return;
    }

    if (!g_stream.is_tls && g_stream.fd >= 0) {
        LONG nonblock = 1;
        IoctlSocket(g_stream.fd, FIONBIO, &nonblock);
    }
    mas_direct_reset();
    mas_direct_start();
    g_stream.started = 1;
    g_status_tick = 0;
    set_status("Playing");
    draw_status();
    timer_start();
}

static void setup_gadgets(void)
{
#define INIT_BUTTON(g,next,x,y,w,label,id) do { memset(&(g),0,sizeof(g)); (g).NextGadget=(next); (g).LeftEdge=(x); (g).TopEdge=(y); (g).Width=(w); (g).Height=14; (g).Flags=GFLG_GADGHCOMP; (g).Activation=GACT_RELVERIFY; (g).GadgetType=BOOLGADGET; (g).GadgetText=(label); (g).GadgetID=(id); } while(0)
    INIT_BUTTON(g_search_btn_gad, &g_play_gad, 12, 10, 64, &g_txt_search_btn, GID_SEARCH_BUTTON);
    INIT_BUTTON(g_play_gad, &g_stop_gad, 84, 10, 52, &g_txt_play, GID_PLAY);
    INIT_BUTTON(g_stop_gad, &g_prev_gad, 144, 10, 52, &g_txt_stop, GID_STOP);
    INIT_BUTTON(g_prev_gad, &g_next_gad, 204, 10, 52, &g_txt_prev, GID_PREV);
    INIT_BUTTON(g_next_gad, &g_quit_gad, 264, 10, 52, &g_txt_next, GID_NEXT);
    INIT_BUTTON(g_quit_gad, 0, 460, 10, 44, &g_txt_quit, GID_QUIT);
#undef INIT_BUTTON
}

static int open_gui(void)
{
    struct NewWindow nw;
    setup_gadgets();
    memset(&nw, 0, sizeof(nw));
    nw.LeftEdge = 20; nw.TopEdge = 20; nw.Width = WIN_W; nw.Height = WIN_H;
    nw.DetailPen = 0; nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_GADGETUP | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_ACTIVATE | WFLG_SIMPLE_REFRESH;
    nw.FirstGadget = &g_search_btn_gad;
    nw.Title = (UBYTE *)APP_TITLE;
    nw.Type = WBENCHSCREEN;
    g_win = OpenWindow(&nw);
    if (!g_win) return 0;
    draw_ui();
    return 1;
}

int main(void)
{
    ULONG sigmask;
    int done = 0;
    g_stream.fd = -1;
    g_stream.tls_ctx = 0;
    IntuitionBase = (struct IntuitionBase *)OpenLibrary((STRPTR)"intuition.library", 0);
    GfxBase = (struct GfxBase *)OpenLibrary((STRPTR)"graphics.library", 0);
    if (!IntuitionBase || !GfxBase) goto out;
    timer_init();
    if (!open_gui()) goto out;
    sigmask = (1UL << g_win->UserPort->mp_SigBit) | g_timer.sigmask;
    load_playlist();
    if (!tls_library_installed()) {
        set_status("Fuer HTTPS:// Streams bitte AmiTLS13 >= 2.0 installieren...");
        draw_status();
    }
    while (!done) {
        ULONG got_sig = Wait(sigmask);
        if ((got_sig & g_timer.sigmask) && timer_drain()) {
            if (g_stream.active && g_stream.started) {
                stream_pump_socket();
                if (mas_direct_had_underrun()) {
                    mas_direct_stop();
                    stream_close_transport();
                    g_stream.active = 0;
                    g_stream.started = 0;
                    set_status("Buffer underrun - stream stopped");
                    draw_status();
                } else {
                    timer_start();
                }
            }
        }
        while (g_win && g_win->UserPort) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(g_win->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) { BeginRefresh(g_win); EndRefresh(g_win, TRUE); draw_ui(); }
            else if (msg->Class == IDCMP_MOUSEBUTTONS) {
                if (msg->Code == SELECTDOWN && msg->MouseX >= 12 && msg->MouseY >= 66 && msg->MouseY < 72 + MAX_RESULTS * 11) {
                    LONG row = (msg->MouseY - 72) / 11;
                    if (row >= 0 && row < g_result_count) {
                        g_selected = row;
                        draw_ui();
                    }
                }
            }
            else if (msg->Class == IDCMP_GADGETUP) {
                struct Gadget *gad = (struct Gadget *)msg->IAddress;
                switch (gad->GadgetID) {
                    case GID_SEARCH_BUTTON: load_playlist(); break;
                    case GID_PLAY: play_selected(); break;
                    case GID_STOP: stop_stream(); break;
                    case GID_PREV: if (g_selected > 0) --g_selected; draw_ui(); break;
                    case GID_NEXT: if (g_selected + 1 < g_result_count) ++g_selected; draw_ui(); break;
                    case GID_QUIT: done = 1; break;
                }
            }
            ReplyMsg((struct Message *)msg);
        }
    }
out:
    stop_stream();
    mas_direct_shutdown();
    if (g_win) CloseWindow(g_win);
    timer_cleanup();
    close_tls_lib();
    if (SocketBase) CloseLibrary(SocketBase);
    if (GfxBase) CloseLibrary((struct Library *)GfxBase);
    if (IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
    return 0;
}
