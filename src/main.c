#include <exec/types.h>
#include <exec/libraries.h>
#include <exec/memory.h>
#include <exec/tasks.h>
#include <dos/dos.h>
#include <dos/dosextens.h>
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


#define APP_TITLE "MASWaver v1.0"
#define VERSION_TEXT "MASWaver v1.0 by Marcel Jaehne (c)2026"

#define WIN_W 520
#define WIN_H 232
#define WIN_MAX_W 640
#define WIN_MAX_H 480
#define WIN_INNER_MARGIN 8
#define STATUS_BLOCK_H 74
#define BUTTON_TOP_PAD 6
#define BUTTON_AREA_H 24
#define LIST_FRAME_TOP_OFFSET 28
#define LIST_TITLE_Y_OFFSET 36
#define LIST_ROWS_TOP_OFFSET 56
#define LIST_STATUS_GAP 4
#define MAX_RESULTS 64
#define TITLE_LEN 64
#define URL_LEN 384
#define GENRE_LEN 48
#define STATUS_LEN 160
#define ICY_TEXT_LEN 96
#define ICY_GENRE_LEN 96
#define ICY_META_BUF 256
#define STREAMS_FILE "streams.txt"
#define WINDOWS_FILE "MASWaver.win"
#define STREAMS_LINE_LEN 320
#define PLS_MAX_FILES 16
#define PLS_PATH_LEN 108
#define HTTP_BUF_SIZE 2048
#define STREAM_NET_CHUNK 512
#define PREBUFFER_BYTES 131072UL
#define LOCAL_START_BYTES 32768UL
#define PUMP_INTERVAL_US 20000UL
#define MAX_PUMP_READS 16
#define STATUS_UPDATE_TICKS 25
#define PLAY_TICKS_PER_SEC (1000000UL / PUMP_INTERVAL_US)
#define STREAM_EOF_DRAIN_BYTES 4096UL
#define STREAM_EMPTY_DRAIN_BYTES 256UL

#define DEFER_STREAM_NONE 0
#define DEFER_STREAM_NEXT_FILE 1
#define DEFER_STREAM_EOF_STOP 2
#define DEFER_STREAM_UNDERRUN_STOP 3

#define GID_SEARCH 1
#define GID_SEARCH_BUTTON 2
#define GID_PLAY 3
#define GID_STOP 4
#define GID_PREV 5
#define GID_NEXT 6
#define GID_QUIT 7
#define GID_DEL 8
#define GID_SAVE_NAME 20
#define GID_SAVE_OK 21
#define GID_SAVE_CANCEL 22
#define GID_SOUND_BASS 30
#define GID_SOUND_TREBLE 31
#define GID_SOUND_VOLUME 32

#define MENU_OPEN 0
#define MENU_SOUND 1
#define MENU_HELP 2
#define ITEM_PLAYLIST 0
#define ITEM_FILE_ADD 1
#define ITEM_DIR_ADD 2
#define ITEM_SOUND_OPEN 0
#define ITEM_INFO 0
#define SUB_PLAYLIST_OPEN 0
#define SUB_PLAYLIST_SAVE 1

#define WINSTATE_MAIN 0
#define WINSTATE_INFO 1
#define WINSTATE_PLAYLIST 2
#define WINSTATE_FILE_ADD 3
#define WINSTATE_DIR_ADD 4
#define WINSTATE_SAVE_M3U 5
#define WINSTATE_SOUND 6
#define WINSTATE_COUNT 7

#define RAWKEY_BACKSPACE 0x41
#define RAWKEY_DELETE 0x46
#define RAWKEY_UP 0x4C
#define RAWKEY_DOWN 0x4D

LONG __stack = 524288;

struct IntuitionBase *IntuitionBase;
struct GfxBase *GfxBase;
struct Library *SocketBase;
static BPTR g_net_log_fh;
static UBYTE g_net_log_started;
static char g_net_log_line[128];

struct StreamEntry {
    char title[TITLE_LEN];
    char artist[TITLE_LEN];
    char album[TITLE_LEN];
    char url[URL_LEN];
    char genre[GENRE_LEN];
    LONG bitrate;
    LONG track_no;
    LONG duration_secs;
    UBYTE is_file;
    ULONG file_audio_offset;
};

struct StreamState {
    int fd;
    int active;
    int started;
    BPTR file_fh;
};

static struct Window *g_win;
static struct StreamEntry g_results[MAX_RESULTS];
static LONG g_result_count;
static LONG g_selected;
static LONG g_list_top;
static char g_status[STATUS_LEN] = "Ready";
static char g_transport_error[STATUS_LEN];
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
static ULONG g_play_elapsed_ticks;
static LONG g_play_duration_secs;
static LONG g_play_draw_secs = -1;
static struct DateStamp g_play_start_stamp;
static UBYTE g_play_clock_valid;
static UBYTE g_header_read_buf[HTTP_BUF_SIZE];
static LONG g_pending_pos;
static LONG g_pending_len;
static char g_http_headers[2048];
static char g_http_path[384];
static char g_http_location[URL_LEN];
static char g_http_redirect[URL_LEN];
static char g_http_current[URL_LEN];
static char g_status_scratch[STATUS_LEN];
static ULONG g_total_stream_bytes;
static UWORD g_status_tick;
static int g_stack_missing;
static char g_stream_error[STATUS_LEN];
static UBYTE g_file_list_mode;
static UBYTE g_file_eof;
static UBYTE g_deferred_stream_action;
static LONG g_icy_metaint;
static LONG g_icy_audio_left;
static LONG g_icy_meta_remaining;
static LONG g_icy_meta_pos;
static UBYTE g_icy_need_len;
static UBYTE g_icy_dirty;
static char g_icy_name[ICY_TEXT_LEN];
static char g_icy_bitrate[16];
static char g_icy_genre[ICY_GENRE_LEN];
static char g_icy_title[ICY_TEXT_LEN];
static char g_icy_meta_buf[ICY_META_BUF];
static LONG g_sound_bass;
static LONG g_sound_treble;
static LONG g_sound_volume = 10;

struct WindowState {
    WORD left;
    WORD top;
    WORD width;
    WORD height;
    UBYTE valid;
};

static struct WindowState g_window_states[WINSTATE_COUNT];


static struct IntuiText g_txt_search_btn = {1,0,JAM1,8,3,0,(UBYTE *)"Reload",0};
static struct IntuiText g_txt_play = {1,0,JAM1,14,3,0,(UBYTE *)"Play",0};
static struct IntuiText g_txt_stop = {1,0,JAM1,14,3,0,(UBYTE *)"Stop",0};
static struct IntuiText g_txt_prev = {1,0,JAM1,10,3,0,(UBYTE *)"Prev",0};
static struct IntuiText g_txt_next = {1,0,JAM1,10,3,0,(UBYTE *)"Next",0};
static struct IntuiText g_txt_quit = {1,0,JAM1,10,3,0,(UBYTE *)"Quit",0};
static struct IntuiText g_txt_del = {1,0,JAM1,14,3,0,(UBYTE *)"Del",0};
static struct IntuiText g_menu_playlist_text = {0,1,JAM1,0,1,0,(UBYTE *)"Playlist",0};
static struct IntuiText g_menu_playlist_open_text = {0,1,JAM1,0,1,0,(UBYTE *)"Open",0};
static struct IntuiText g_menu_playlist_save_text = {0,1,JAM1,0,1,0,(UBYTE *)"Save",0};
static struct IntuiText g_menu_file_add_text = {0,1,JAM1,0,1,0,(UBYTE *)"File add",0};
static struct IntuiText g_menu_dir_add_text = {0,1,JAM1,0,1,0,(UBYTE *)"Dir add",0};
static struct IntuiText g_menu_sound_text = {0,1,JAM1,0,1,0,(UBYTE *)"Sound",0};
static struct IntuiText g_menu_info_text = {0,1,JAM1,0,1,0,(UBYTE *)"Info",0};

static struct MenuItem g_menu_playlist_save_sub = {0,78,10,56,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_playlist_save_text,0,0,0,0};
static struct MenuItem g_menu_playlist_open_sub = {&g_menu_playlist_save_sub,78,0,56,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_playlist_open_text,0,0,0,0};
static struct MenuItem g_menu_dir_add_item = {0,0,20,82,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_dir_add_text,0,0,0,0};
static struct MenuItem g_menu_file_add_item = {&g_menu_dir_add_item,0,10,82,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_file_add_text,0,0,0,0};
static struct MenuItem g_menu_playlist_item = {&g_menu_file_add_item,0,0,82,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_playlist_text,0,0,&g_menu_playlist_open_sub,0};
static struct MenuItem g_menu_sound_item = {0,0,0,70,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_sound_text,0,0,0,0};
static struct MenuItem g_menu_info_item = {0,0,0,60,10,ITEMTEXT|ITEMENABLED|HIGHBOX,0,(APTR)&g_menu_info_text,0,0,0,0};
static struct Menu g_menu_help = {0,104,0,16,10,MENUENABLED,(UBYTE *)"?",&g_menu_info_item,0,0,0,0};
static struct Menu g_menu_sound = {&g_menu_help,48,0,52,10,MENUENABLED,(UBYTE *)"Sound",&g_menu_sound_item,0,0,0,0};
static struct Menu g_menu_open = {&g_menu_sound,0,0,44,10,MENUENABLED,(UBYTE *)"Open",&g_menu_playlist_item,0,0,0,0};

static struct Gadget g_quit_gad;
static struct Gadget g_del_gad;
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

static LONG parse_long_field(const char **pp)
{
    const char *p = *pp;
    LONG sign = 1;
    LONG v = 0;

    while (*p == ' ' || *p == '\t' || *p == '=' || *p == ',') ++p;
    if (*p == '-') { sign = -1; ++p; }
    while (*p >= '0' && *p <= '9') {
        v = v * 10 + (*p - '0');
        ++p;
    }
    *pp = p;
    return v * sign;
}

static int parse_window_line(const char *line, const char *key, struct WindowState *ws)
{
    const char *p;
    LONG key_len = cstrlen(key);

    if (!line || !key || !ws) return 0;
    if (strncmp(line, key, key_len) != 0 || line[key_len] != '=') return 0;
    p = line + key_len + 1;
    ws->left = (WORD)parse_long_field(&p);
    ws->top = (WORD)parse_long_field(&p);
    ws->width = (WORD)parse_long_field(&p);
    ws->height = (WORD)parse_long_field(&p);
    if (ws->width <= 0 || ws->height <= 0) return 0;
    ws->valid = 1;
    return 1;
}

static void load_window_states(void)
{
    BPTR fh;
    char buf[768];
    LONG n, i, start;

    fh = Open((STRPTR)WINDOWS_FILE, MODE_OLDFILE);
    if (!fh) return;
    n = Read(fh, buf, sizeof(buf) - 1);
    Close(fh);
    if (n <= 0) return;
    buf[n] = 0;

    start = 0;
    for (i = 0; i <= n; ++i) {
        if (buf[i] == '\n' || buf[i] == '\r' || buf[i] == 0) {
            char old = buf[i];
            buf[i] = 0;
            parse_window_line(buf + start, "main", &g_window_states[WINSTATE_MAIN]);
            parse_window_line(buf + start, "info", &g_window_states[WINSTATE_INFO]);
            parse_window_line(buf + start, "playlist", &g_window_states[WINSTATE_PLAYLIST]);
            parse_window_line(buf + start, "fileadd", &g_window_states[WINSTATE_FILE_ADD]);
            parse_window_line(buf + start, "diradd", &g_window_states[WINSTATE_DIR_ADD]);
            parse_window_line(buf + start, "savem3u", &g_window_states[WINSTATE_SAVE_M3U]);
            if (old == '\r' && buf[i + 1] == '\n') ++i;
            start = i + 1;
        }
    }
}

static void write_window_state_line(BPTR fh, const char *key, struct WindowState *ws)
{
    char line[80];
    if (!fh || !key || !ws || !ws->valid) return;
    sprintf(line, "%s=%ld,%ld,%ld,%ld\n", key, (LONG)ws->left, (LONG)ws->top, (LONG)ws->width, (LONG)ws->height);
    Write(fh, (APTR)line, cstrlen(line));
}

static void save_window_states(void)
{
    BPTR fh = Open((STRPTR)WINDOWS_FILE, MODE_NEWFILE);
    if (!fh) return;
    write_window_state_line(fh, "main", &g_window_states[WINSTATE_MAIN]);
    write_window_state_line(fh, "info", &g_window_states[WINSTATE_INFO]);
    write_window_state_line(fh, "playlist", &g_window_states[WINSTATE_PLAYLIST]);
    write_window_state_line(fh, "fileadd", &g_window_states[WINSTATE_FILE_ADD]);
    write_window_state_line(fh, "diradd", &g_window_states[WINSTATE_DIR_ADD]);
    write_window_state_line(fh, "savem3u", &g_window_states[WINSTATE_SAVE_M3U]);
    Close(fh);
}

static void remember_window_state(LONG id, struct Window *w)
{
    if (!w || id < 0 || id >= WINSTATE_COUNT) return;
    g_window_states[id].left = w->LeftEdge;
    g_window_states[id].top = w->TopEdge;
    g_window_states[id].width = w->Width;
    g_window_states[id].height = w->Height;
    g_window_states[id].valid = 1;
}

static void apply_window_state(struct NewWindow *nw, LONG id, WORD def_left, WORD def_top, WORD def_width, WORD def_height)
{
    struct WindowState *ws;

    if (!nw) return;
    nw->LeftEdge = def_left;
    nw->TopEdge = def_top;
    nw->Width = def_width;
    nw->Height = def_height;
    if (id < 0 || id >= WINSTATE_COUNT) return;
    ws = &g_window_states[id];
    if (!ws->valid) return;
    nw->LeftEdge = ws->left;
    nw->TopEdge = ws->top;
    nw->Width = ws->width;
    nw->Height = ws->height;
}

static void clamp_new_window_size(struct NewWindow *nw, WORD min_w, WORD min_h, WORD max_w, WORD max_h)
{
    if (!nw) return;
    if (nw->Width < min_w) nw->Width = min_w;
    if (nw->Height < min_h) nw->Height = min_h;
    if (max_w > 0 && nw->Width > max_w) nw->Width = max_w;
    if (max_h > 0 && nw->Height > max_h) nw->Height = max_h;
}

static struct Window *open_window_with_position_fallback(struct NewWindow *nw)
{
    struct Window *w;

    if (!nw) return 0;
    w = OpenWindow(nw);
    if (w) return w;

    nw->LeftEdge = 0;
    nw->TopEdge = 0;
    return OpenWindow(nw);
}

static void net_log_open(void)
{
    if (!g_net_log_started) {
        g_net_log_fh = Open((STRPTR)"RAM:MASWaverNet.log", MODE_NEWFILE);
        if (g_net_log_fh) {
            Close(g_net_log_fh);
            g_net_log_fh = 0;
            g_net_log_started = 1;
        }
    }
}

static void net_log(const char *s)
{
    BPTR fh;

    if (!s) return;
    net_log_open();
    fh = Open((STRPTR)"RAM:MASWaverNet.log", MODE_OLDFILE);
    if (fh) {
        Seek(fh, 0, OFFSET_END);
        Write(fh, (APTR)s, cstrlen(s));
        Write(fh, (APTR)"\n", 1);
        Close(fh);
    }
}

static void net_log_close(void)
{
    if (g_net_log_fh) {
        Close(g_net_log_fh);
        g_net_log_fh = 0;
    }
}

static void set_stream_error(const char *s);
static void play_selected(void);

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

static void clipped_window_text(struct Window *w, WORD x, WORD y, const char *s);
static void draw_status(void);
static void draw_play_time(void);
static void show_sound_window(void);
static void draw_ui(void);
static void stop_stream(void);
static void service_stream_timer_signal(void);
static void process_stream_deferred(void);
static void format_duration(char *out, LONG out_size, LONG secs);
static void format_clock_time(char *out, LONG out_size, LONG secs);
static void join_path(char *out, LONG out_size, const char *dir, const char *name);
static void parent_path(char *path);
static int path_is_root(const char *dir);
static LONG scan_volumes(char names[][PLS_PATH_LEN], UBYTE is_dir[]);

static WORD win_left(void)
{
    return g_win ? (WORD)(g_win->BorderLeft + WIN_INNER_MARGIN) : WIN_INNER_MARGIN;
}

static WORD win_right(void)
{
    WORD r;
    if (!g_win) return (WORD)(WIN_W - WIN_INNER_MARGIN);
    r = (WORD)(g_win->Width - g_win->BorderRight - WIN_INNER_MARGIN);
    if (r < win_left()) r = win_left();
    return r;
}

static WORD win_top(void)
{
    return g_win ? (WORD)(g_win->BorderTop + WIN_INNER_MARGIN) : WIN_INNER_MARGIN;
}

static WORD win_bottom(void)
{
    WORD b;
    if (!g_win) return (WORD)(WIN_H - WIN_INNER_MARGIN);
    b = (WORD)(g_win->Height - g_win->BorderBottom - WIN_INNER_MARGIN);
    if (b < win_top()) b = win_top();
    return b;
}

static WORD status_top(void)
{
    WORD b = win_bottom();
    WORD t = (WORD)(b - STATUS_BLOCK_H);
    WORD min_t = (WORD)(g_win ? (g_win->BorderTop + LIST_ROWS_TOP_OFFSET) : (win_top() + 52));
    if (t < min_t) t = min_t;
    return t;
}

static WORD button_area_bottom(void)
{
    return g_win ? (WORD)(g_win->BorderTop + BUTTON_AREA_H) : BUTTON_AREA_H;
}

static WORD list_frame_top(void)
{
    return g_win ? (WORD)(g_win->BorderTop + LIST_FRAME_TOP_OFFSET) : LIST_FRAME_TOP_OFFSET;
}

static WORD list_title_y(void)
{
    return g_win ? (WORD)(g_win->BorderTop + LIST_TITLE_Y_OFFSET) : LIST_TITLE_Y_OFFSET;
}

static WORD list_rows_top(void)
{
    return g_win ? (WORD)(g_win->BorderTop + LIST_ROWS_TOP_OFFSET) : LIST_ROWS_TOP_OFFSET;
}

static WORD list_bottom(void)
{
    WORD b = (WORD)(status_top() - LIST_STATUS_GAP);
    WORD top = list_rows_top();
    if (b < top) b = top;
    return b;
}

static void layout_gadgets(void)
{
    WORD y;
    if (!g_win) return;
    y = (WORD)(g_win->BorderTop + BUTTON_TOP_PAD);
    g_search_btn_gad.GadgetText = &g_txt_search_btn;
    g_play_gad.GadgetText = &g_txt_play;
    g_stop_gad.GadgetText = &g_txt_stop;
    g_prev_gad.GadgetText = &g_txt_prev;
    g_next_gad.GadgetText = &g_txt_next;
    g_del_gad.GadgetText = &g_txt_del;
    g_quit_gad.GadgetText = &g_txt_quit;
    g_search_btn_gad.LeftEdge = win_left();
    g_search_btn_gad.TopEdge = y;
    g_play_gad.LeftEdge = (WORD)(g_search_btn_gad.LeftEdge + 72);
    g_play_gad.TopEdge = y;
    g_stop_gad.LeftEdge = (WORD)(g_play_gad.LeftEdge + 60);
    g_stop_gad.TopEdge = y;
    g_prev_gad.LeftEdge = (WORD)(g_stop_gad.LeftEdge + 60);
    g_prev_gad.TopEdge = y;
    g_next_gad.LeftEdge = (WORD)(g_prev_gad.LeftEdge + 60);
    g_next_gad.TopEdge = y;
    g_del_gad.LeftEdge = (WORD)(g_next_gad.LeftEdge + 60);
    g_del_gad.TopEdge = y;
    g_quit_gad.LeftEdge = (WORD)(g_del_gad.LeftEdge + 52);
    g_quit_gad.TopEdge = y;
    g_search_btn_gad.Width = 64;
    g_play_gad.Width = 52;
    g_stop_gad.Width = 52;
    g_prev_gad.Width = 52;
    g_next_gad.Width = 52;
    g_del_gad.Width = 44;
    g_quit_gad.Width = 44;
    g_search_btn_gad.Height = g_play_gad.Height = g_stop_gad.Height = g_prev_gad.Height = g_next_gad.Height = g_del_gad.Height = g_quit_gad.Height = 14;
}

static void refresh_button_row(void)
{
    WORD left, right, top, bottom;
    if (!g_win) return;
    layout_gadgets();
    left = win_left();
    right = win_right();
    top = (WORD)(g_win->BorderTop + 1);
    bottom = button_area_bottom();
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, g_win->BorderLeft, top, (WORD)(g_win->Width - g_win->BorderRight - 1), bottom);
    RefreshGList(&g_search_btn_gad, g_win, 0, 7);
    Move(g_win->RPort, left, bottom);
    SetAPen(g_win->RPort, 1);
    Draw(g_win->RPort, right, bottom);
}

static void set_status(const char *s)
{
    strncpy(g_status, s, STATUS_LEN - 1);
    g_status[STATUS_LEN - 1] = 0;
}

static void draw_frame(WORD left, WORD top, WORD right, WORD bottom)
{
    if (!g_win) return;
    if (right <= left || bottom <= top) return;
    SetAPen(g_win->RPort, 1);
    SetDrMd(g_win->RPort, JAM1);
    Move(g_win->RPort, left, top);
    Draw(g_win->RPort, right, top);
    Draw(g_win->RPort, right, bottom);
    Draw(g_win->RPort, left, bottom);
    Draw(g_win->RPort, left, top);
}

static void draw_status_line(WORD x, WORD y, WORD r, const char *line)
{
    LONG len;
    LONG max_chars;

    if (!g_win || !line) return;
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, x, (WORD)(y - 8), r, (WORD)(y + 2));
    SetAPen(g_win->RPort, 1);
    SetBPen(g_win->RPort, 0);
    SetDrMd(g_win->RPort, JAM1);
    len = cstrlen(line);
    max_chars = (LONG)((r - x) / 8);
    if (max_chars < 0) max_chars = 0;
    if (len > max_chars) len = max_chars;
    Move(g_win->RPort, x, y);
    if (len > 0) Text(g_win->RPort, (STRPTR)line, len);
}

static void draw_status_title_wrapped(WORD x, WORD y, WORD r)
{
    char line[180];
    const char *title;
    LONG max_chars;
    LONG label_len;
    LONG title_len;
    LONG first_take;

    title = g_icy_title[0] ? g_icy_title : "-";
    max_chars = (LONG)((r - x) / 8);
    if (max_chars < 0) max_chars = 0;
    label_len = cstrlen("StreamTitle: ");
    title_len = cstrlen(title);
    first_take = max_chars - label_len;
    if (first_take < 0) first_take = 0;
    if (first_take > title_len) first_take = title_len;

    line[0] = 0;
    strncat(line, "StreamTitle: ", sizeof(line) - strlen(line) - 1);
    if (first_take > 0) strncat(line, title, first_take);
    draw_status_line(x, y, r, line);

    if (title_len > first_take) {
        draw_status_line(x, (WORD)(y + 11), r, title + first_take);
    } else {
        draw_status_line(x, (WORD)(y + 11), r, "");
    }
}

static LONG visible_list_rows(void)
{
    LONG rows;
    if (!g_win) return 0;
    rows = ((LONG)(list_bottom() - list_rows_top()) / 11L) + 1L;
    if (rows < 1) rows = 1;
    return rows;
}

static void ensure_selected_visible(void)
{
    LONG rows = visible_list_rows();
    if (g_result_count <= 0) { g_selected = 0; g_list_top = 0; return; }
    if (g_selected < 0) g_selected = 0;
    if (g_selected >= g_result_count) g_selected = g_result_count - 1;
    if (g_list_top < 0) g_list_top = 0;
    if (g_selected < g_list_top) g_list_top = g_selected;
    if (g_selected >= g_list_top + rows) g_list_top = g_selected - rows + 1;
    if (g_list_top < 0) g_list_top = 0;
    if (g_result_count > rows && g_list_top > g_result_count - rows) g_list_top = g_result_count - rows;
}

static void select_relative(LONG delta)
{
    if (g_result_count <= 0) return;
    g_selected += delta;
    ensure_selected_visible();
    draw_ui();
}

static void remove_selected_file(void)
{
    LONG i;
    if (!g_file_list_mode) { set_status("Del works in file list only"); draw_status(); return; }
    if (g_result_count <= 0 || g_selected < 0 || g_selected >= g_result_count) { set_status("No file selected"); draw_status(); return; }
    if (!g_results[g_selected].is_file) { set_status("No file selected"); draw_status(); return; }
    if (g_stream.active && g_results[g_selected].is_file) stop_stream();
    for (i = g_selected; i + 1 < g_result_count; ++i) g_results[i] = g_results[i + 1];
    --g_result_count;
    if (g_result_count <= 0) {
        g_result_count = 0;
        g_selected = 0;
        g_list_top = 0;
        set_status("File list empty");
    } else {
        ensure_selected_visible();
        set_status("File removed");
    }
    draw_ui();
}

static int has_m3u_filename_suffix(const char *name)
{
    LONG len = cstrlen(name);
    if (len < 4) return 0;
    return lower_char(name[len - 4]) == '.' && lower_char(name[len - 3]) == 'm' && lower_char(name[len - 2]) == '3' && lower_char(name[len - 1]) == 'u';
}

static void make_m3u_filename(char *out, LONG out_size, const char *name)
{
    if (!out || out_size <= 0) return;
    out[0] = 0;
    copy_trim(out, out_size, name, cstrlen(name));
    if (!out[0]) copy_trim(out, out_size, "MASWaverFiles.m3u", 17);
    if (!has_m3u_filename_suffix(out)) strncat(out, ".m3u", out_size - strlen(out) - 1);
}

static void save_filelist_m3u_as(const char *filename)
{
    BPTR f;
    LONG i, saved = 0;
    char path[PLS_PATH_LEN];
    if (!g_file_list_mode || g_result_count <= 0) {
        set_status("No file list to save");
        draw_status();
        return;
    }
    make_m3u_filename(path, sizeof(path), filename);
    if (!path[0]) {
        set_status("No filename");
        draw_status();
        return;
    }
    f = Open((STRPTR)path, MODE_NEWFILE);
    if (!f) {
        set_status("Save playlist failed");
        draw_status();
        return;
    }
    Write(f, (APTR)"#EXTM3U\n", 8);
    for (i = 0; i < g_result_count; ++i) {
        char line[URL_LEN + TITLE_LEN + 32];
        if (!g_results[i].is_file) continue;
        line[0] = 0;
        if (g_results[i].duration_secs > 0) sprintf(line, "#EXTINF:%ld,", g_results[i].duration_secs);
        else strncat(line, "#EXTINF:-1,", sizeof(line) - strlen(line) - 1);
        if (g_results[i].artist[0]) {
            strncat(line, g_results[i].artist, sizeof(line) - strlen(line) - 1);
            strncat(line, " - ", sizeof(line) - strlen(line) - 1);
        }
        strncat(line, g_results[i].title, sizeof(line) - strlen(line) - 1);
        strncat(line, "\n", sizeof(line) - strlen(line) - 1);
        Write(f, (APTR)line, cstrlen(line));
        Write(f, (APTR)g_results[i].url, cstrlen(g_results[i].url));
        Write(f, (APTR)"\n", 1);
        ++saved;
    }
    Close(f);
    if (saved > 0) {
        strcpy(g_status_scratch, "Saved ");
        strncat(g_status_scratch, path, sizeof(g_status_scratch) - strlen(g_status_scratch) - 1);
        set_status(g_status_scratch);
    }
    else set_status("No files in list");
    draw_status();
}

static void draw_save_m3u_window(struct Window *w)
{
    struct RastPort *rp;
    if (!w) return;
    rp = w->RPort;
    SetAPen(rp, 0);
    RectFill(rp, w->BorderLeft + 4, w->BorderTop + 4, w->Width - w->BorderRight - 6, w->Height - w->BorderBottom - 6);
    SetAPen(rp, 1);
    SetBPen(rp, 0);
    SetDrMd(rp, JAM1);
    clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 16), "Save file list as:");
}

static void save_filelist_m3u(void)
{
    struct NewWindow nw;
    struct Window *w;
    struct StringInfo si;
    struct Gadget name_gad, ok_gad, cancel_gad;
    struct IntuiText ok_txt = {1,0,JAM1,15,3,0,(UBYTE *)"OK",0};
    struct IntuiText cancel_txt = {1,0,JAM1,8,3,0,(UBYTE *)"Cancel",0};
    char filename[PLS_PATH_LEN];
    char undo[PLS_PATH_LEN];
    int done = 0;

    if (!g_file_list_mode || g_result_count <= 0) {
        set_status("No file list to save");
        draw_status();
        return;
    }

    strcpy(filename, "MASWaverFiles.m3u");
    undo[0] = 0;
    memset(&si, 0, sizeof(si));
    si.Buffer = (STRPTR)filename;
    si.UndoBuffer = (STRPTR)undo;
    si.MaxChars = sizeof(filename);
    si.NumChars = cstrlen(filename);

    memset(&name_gad, 0, sizeof(name_gad));
    memset(&ok_gad, 0, sizeof(ok_gad));
    memset(&cancel_gad, 0, sizeof(cancel_gad));

    name_gad.NextGadget = &ok_gad;
    name_gad.LeftEdge = 14;
    name_gad.TopEdge = 40;
    name_gad.Width = 260;
    name_gad.Height = 14;
    name_gad.Flags = GFLG_GADGHCOMP;
    name_gad.Activation = GACT_RELVERIFY;
    name_gad.GadgetType = GTYP_STRGADGET;
    name_gad.SpecialInfo = (APTR)&si;
    name_gad.GadgetID = GID_SAVE_NAME;

    ok_gad.NextGadget = &cancel_gad;
    ok_gad.LeftEdge = 70;
    ok_gad.TopEdge = 68;
    ok_gad.Width = 48;
    ok_gad.Height = 14;
    ok_gad.Flags = GFLG_GADGHCOMP;
    ok_gad.Activation = GACT_RELVERIFY;
    ok_gad.GadgetType = BOOLGADGET;
    ok_gad.GadgetText = &ok_txt;
    ok_gad.GadgetID = GID_SAVE_OK;

    cancel_gad.LeftEdge = 130;
    cancel_gad.TopEdge = 68;
    cancel_gad.Width = 72;
    cancel_gad.Height = 14;
    cancel_gad.Flags = GFLG_GADGHCOMP;
    cancel_gad.Activation = GACT_RELVERIFY;
    cancel_gad.GadgetType = BOOLGADGET;
    cancel_gad.GadgetText = &cancel_txt;
    cancel_gad.GadgetID = GID_SAVE_CANCEL;

    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, WINSTATE_SAVE_M3U, g_win ? (WORD)(g_win->LeftEdge + 35) : 45, g_win ? (WORD)(g_win->TopEdge + 35) : 40, 296, 112);
    clamp_new_window_size(&nw, 296, 112, 640, 480);
    nw.DetailPen = 0;
    nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_GADGETUP;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH;
    nw.FirstGadget = &name_gad;
    nw.Title = (UBYTE *)"Save Playlist";
    nw.Type = WBENCHSCREEN;

    w = open_window_with_position_fallback(&nw);
    if (!w) return;
    ActivateGadget(&name_gad, w, 0);
    draw_save_m3u_window(w);
    RefreshGList(&name_gad, w, 0, 3);

    while (!done) {
        ULONG sigmask = (1UL << w->UserPort->mp_SigBit) | g_timer.sigmask;
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (1) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(w->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) {
                BeginRefresh(w);
                EndRefresh(w, TRUE);
                draw_save_m3u_window(w);
                RefreshGList(&name_gad, w, 0, 3);
            }
            else if (msg->Class == IDCMP_GADGETUP) {
                struct Gadget *gad = (struct Gadget *)msg->IAddress;
                if (gad && gad->GadgetID == GID_SAVE_OK) {
                    save_filelist_m3u_as(filename);
                    done = 1;
                }
                else if (gad && gad->GadgetID == GID_SAVE_CANCEL) done = 1;
            }
            ReplyMsg((struct Message *)msg);
        }
    }
    remember_window_state(WINSTATE_SAVE_M3U, w);
    CloseWindow(w);
}

static void start_play_clock(void)
{
    DateStamp(&g_play_start_stamp);
    g_play_clock_valid = 1;
    g_play_draw_secs = -1;
}

static LONG current_play_elapsed_secs(void)
{
    struct DateStamp now;
    LONG days;
    LONG mins;
    LONG ticks;
    LONG total_ticks;

    if (!g_stream.active || !g_stream.started || !g_stream.file_fh) return 0;
    if (!g_play_clock_valid) return 0;
    DateStamp(&now);
    days = now.ds_Days - g_play_start_stamp.ds_Days;
    mins = now.ds_Minute - g_play_start_stamp.ds_Minute;
    ticks = now.ds_Tick - g_play_start_stamp.ds_Tick;
    total_ticks = days * 24L * 60L * 50L + mins * 60L * 50L + ticks;
    if (total_ticks < 0) total_ticks = 0;
    return total_ticks / 50L;
}

static void draw_status(void)
{
    char line[180];
    char elapsed[16];
    char total[16];
    LONG secs;
    WORD x, r, y;

    if (!g_win) return;
    x = (WORD)(win_left() + 4);
    r = (WORD)(win_right() - 4);
    if (r < x) r = x;
    y = status_top();
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, win_left(), y, win_right(), win_bottom());
    draw_frame(win_left(), y, win_right(), win_bottom());
    draw_status_line(x, (WORD)(y + 10), r, g_status);

    line[0] = 0;
    strncat(line, "Name: ", sizeof(line) - strlen(line) - 1);
    strncat(line, g_icy_name[0] ? g_icy_name : "-", sizeof(line) - strlen(line) - 1);
    draw_status_line(x, (WORD)(y + 21), r, line);

    line[0] = 0;
    strncat(line, "Bitrate: ", sizeof(line) - strlen(line) - 1);
    strncat(line, g_icy_bitrate[0] ? g_icy_bitrate : "-", sizeof(line) - strlen(line) - 1);
    if (g_stream.active && g_stream.started && g_stream.file_fh) {
        secs = current_play_elapsed_secs();
        if (g_play_duration_secs > 0 && secs > g_play_duration_secs) secs = g_play_duration_secs;
        format_clock_time(elapsed, sizeof(elapsed), secs);
        strncat(line, "  Time: ", sizeof(line) - strlen(line) - 1);
        strncat(line, elapsed, sizeof(line) - strlen(line) - 1);
        if (g_play_duration_secs > 0) {
            format_clock_time(total, sizeof(total), g_play_duration_secs);
            strncat(line, "/", sizeof(line) - strlen(line) - 1);
            strncat(line, total, sizeof(line) - strlen(line) - 1);
        }
    }
    draw_status_line(x, (WORD)(y + 32), r, line);

    line[0] = 0;
    strncat(line, "Genre: ", sizeof(line) - strlen(line) - 1);
    strncat(line, g_icy_genre[0] ? g_icy_genre : "-", sizeof(line) - strlen(line) - 1);
    draw_status_line(x, (WORD)(y + 43), r, line);

    draw_status_title_wrapped(x, (WORD)(y + 54), r);
}

static void draw_play_time(void)
{
    char prefix[64];
    char value[32];
    char elapsed[16];
    char total[16];
    LONG secs;
    WORD x, r, y, tx;

    if (!g_win || !g_stream.active || !g_stream.started || !g_stream.file_fh) return;

    x = (WORD)(win_left() + 4);
    r = (WORD)(win_right() - 4);
    if (r < x) return;
    y = (WORD)(status_top() + 32);

    prefix[0] = 0;
    strncat(prefix, "Bitrate: ", sizeof(prefix) - strlen(prefix) - 1);
    strncat(prefix, g_icy_bitrate[0] ? g_icy_bitrate : "-", sizeof(prefix) - strlen(prefix) - 1);
    strncat(prefix, "  Time: ", sizeof(prefix) - strlen(prefix) - 1);
    tx = (WORD)(x + cstrlen(prefix) * 8);
    if (tx >= r) return;

    secs = current_play_elapsed_secs();
    if (g_play_duration_secs > 0 && secs > g_play_duration_secs) secs = g_play_duration_secs;
    g_play_draw_secs = secs;
    format_clock_time(elapsed, sizeof(elapsed), secs);

    value[0] = 0;
    strncat(value, elapsed, sizeof(value) - strlen(value) - 1);
    if (g_play_duration_secs > 0) {
        format_clock_time(total, sizeof(total), g_play_duration_secs);
        strncat(value, "/", sizeof(value) - strlen(value) - 1);
        strncat(value, total, sizeof(value) - strlen(value) - 1);
    }

    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, tx, (WORD)(y - 8), r, (WORD)(y + 2));
    SetAPen(g_win->RPort, 1);
    SetBPen(g_win->RPort, 0);
    SetDrMd(g_win->RPort, JAM1);
    Move(g_win->RPort, tx, y);
    Text(g_win->RPort, (STRPTR)value, cstrlen(value));
}


static void draw_ui(void)
{
    LONG i;
    char line[160];
    WORD x, y0, rows_top, rows_bottom;
    WORD frame_top;
    if (!g_win) return;
    layout_gadgets();
    x = (WORD)(win_left() + 4);
    y0 = list_title_y();
    rows_top = list_rows_top();
    rows_bottom = list_bottom();
    frame_top = list_frame_top();
    SetAPen(g_win->RPort, 0);
    RectFill(g_win->RPort, win_left(), button_area_bottom(), win_right(), rows_bottom);
    draw_frame(win_left(), frame_top, win_right(), rows_bottom);
    SetAPen(g_win->RPort, 1);
    SetBPen(g_win->RPort, 0);
    SetDrMd(g_win->RPort, JAM1);
    Move(g_win->RPort, x, y0);
    if (g_file_list_mode) Text(g_win->RPort, (STRPTR)"Selected Filelist", cstrlen("Selected Filelist"));
    else Text(g_win->RPort, (STRPTR)"Available Streams", cstrlen("Available Streams"));
    ensure_selected_visible();
    for (i = 0; i < MAX_RESULTS; ++i) {
        LONG idx = g_list_top + i;
        WORD row_y = (WORD)(rows_top + i * 11);
        if (row_y > rows_bottom) break;
        Move(g_win->RPort, (WORD)(x + 4), row_y);
        if (idx < g_result_count) {
            if (idx == g_selected) SetAPen(g_win->RPort, 3); else SetAPen(g_win->RPort, 1);
            line[0] = 0;
            if (g_results[idx].is_file) {
                if (g_results[idx].track_no > 0) {
                    char t[12];
                    if (g_results[idx].track_no < 100) sprintf(t, "%02ld  ", g_results[idx].track_no); else sprintf(t, "%ld ", g_results[idx].track_no);
                    strncat(line, t, sizeof(line)-strlen(line)-1);
                }
                else strncat(line, "    ", sizeof(line)-strlen(line)-1);
                if (g_results[idx].artist[0]) {
                    strncat(line, g_results[idx].artist, sizeof(line)-strlen(line)-1);
                    strncat(line, " - ", sizeof(line)-strlen(line)-1);
                }
                strncat(line, g_results[idx].title, sizeof(line)-strlen(line)-1);
                if (g_results[idx].duration_secs > 0) {
                    char dur[16];
                    strncat(line, "  ", sizeof(line)-strlen(line)-1);
                    format_duration(dur, sizeof(dur), g_results[idx].duration_secs);
                    strncat(line, dur, sizeof(line)-strlen(line)-1);
                }
            }
            else {
                strncat(line, g_results[idx].title, 56);
                strncat(line, "  ", sizeof(line)-strlen(line)-1);
                if (g_results[idx].bitrate > 0) {
                    char b[16];
                    sprintf(b, "%ldk", g_results[idx].bitrate);
                    strncat(line, b, sizeof(line)-strlen(line)-1);
                }
            }
            Text(g_win->RPort, (STRPTR)line, cstrlen(line));
        }
    }
    draw_status();
}

static void info_text(struct RastPort *rp, WORD x, WORD y, const char *s)
{
    Move(rp, x, y);
    Text(rp, (STRPTR)s, cstrlen(s));
}

static void clipped_window_text(struct Window *w, WORD x, WORD y, const char *s)
{
    LONG len;
    LONG max_chars;
    WORD right;

    if (!w || !s) return;
    right = (WORD)(w->Width - w->BorderRight - 8);
    if (x >= right) return;
    max_chars = (LONG)((right - x) / 8);
    if (max_chars <= 0) return;
    len = cstrlen(s);
    if (len > max_chars) len = max_chars;
    Move(w->RPort, x, y);
    Text(w->RPort, (STRPTR)s, len);
}

static void draw_info_window(struct Window *w)
{
    struct RastPort *rp;
    if (!w) return;
    rp = w->RPort;
    SetAPen(rp, 0);
    RectFill(rp, w->BorderLeft + 4, w->BorderTop + 4, w->Width - w->BorderRight - 6, w->Height - w->BorderBottom - 6);
    SetAPen(rp, 1);
    SetBPen(rp, 0);
    SetDrMd(rp, JAM1);
    {
        WORD x = (WORD)(w->BorderLeft + 12);
        WORD y = (WORD)(w->BorderTop + 14);
        info_text(rp, x, y, "MASWaver for Kickstart 1.3");
        info_text(rp, x, (WORD)(y + 14), "Version: v1.0");
        info_text(rp, x, (WORD)(y + 28), "by Marcel Jaehne (c)2026");
        info_text(rp, x, (WORD)(y + 44), "MP3 internet streams for MAS Player Pro");
        info_text(rp, x, (WORD)(y + 62), "If you want to buy me a coffee,");
        info_text(rp, x, (WORD)(y + 76), "send me a buck to paypal.me/mytubefree");
    }
}

static LONG sound_value_to_x(LONG value, LONG min, LONG max, WORD x1, WORD x2)
{
    LONG range = max - min;
    if (value < min) value = min;
    if (value > max) value = max;
    if (range <= 0) return x1;
    return x1 + ((value - min) * (x2 - x1) + (range / 2)) / range;
}

static LONG sound_x_to_value(WORD mx, LONG min, LONG max, WORD x1, WORD x2)
{
    LONG range = max - min;
    LONG v;
    if (x2 <= x1 || range <= 0) return min;
    if (mx < x1) mx = x1;
    if (mx > x2) mx = x2;
    v = min + (((LONG)(mx - x1) * range + ((x2 - x1) / 2)) / (x2 - x1));
    if (v < min) v = min;
    if (v > max) v = max;
    return v;
}

static void sound_apply(void)
{
    mas_direct_set_bass_step(g_sound_bass);
    mas_direct_set_treble_step(g_sound_treble);
    mas_direct_set_volume_step(g_sound_volume);
}

static void sound_defaults(void)
{
    g_sound_bass = 0;
    g_sound_treble = 0;
    g_sound_volume = 10;
    g_play_draw_secs = -1;
}

static void draw_sound_value(struct Window *w, WORD x, WORD y, LONG value)
{
    char buf[16];
    if (!w) return;
    sprintf(buf, "%ld", value);
    SetAPen(w->RPort, 0);
    RectFill(w->RPort, x, (WORD)(y - 9), (WORD)(x + 44), (WORD)(y + 3));
    SetAPen(w->RPort, 1);
    SetBPen(w->RPort, 0);
    SetDrMd(w->RPort, JAM1);
    Move(w->RPort, x, y);
    Text(w->RPort, (STRPTR)buf, cstrlen(buf));
}

static void draw_sound_slider(struct Window *w, WORD y, LONG value, LONG min, LONG max)
{
    WORD x1, x2, kx;
    if (!w) return;
    x1 = (WORD)(w->BorderLeft + 78);
    x2 = (WORD)(w->BorderLeft + 232);
    kx = (WORD)sound_value_to_x(value, min, max, x1, x2);

    SetAPen(w->RPort, 0);
    RectFill(w->RPort, x1, (WORD)(y - 8), x2, (WORD)(y + 8));
    SetAPen(w->RPort, 1);
    SetDrMd(w->RPort, JAM1);
    Move(w->RPort, x1, y);
    Draw(w->RPort, x2, y);
    Move(w->RPort, x1, (WORD)(y - 4));
    Draw(w->RPort, x1, (WORD)(y + 4));
    Move(w->RPort, x2, (WORD)(y - 4));
    Draw(w->RPort, x2, (WORD)(y + 4));
    if (min < 0 && max > 0) {
        WORD zx = (WORD)sound_value_to_x(0, min, max, x1, x2);
        Move(w->RPort, zx, (WORD)(y - 5));
        Draw(w->RPort, zx, (WORD)(y + 5));
    }
    RectFill(w->RPort, (WORD)(kx - 3), (WORD)(y - 6), (WORD)(kx + 3), (WORD)(y + 6));
}

static void draw_sound_window(struct Window *w)
{
    WORD yb, yt, yv;
    if (!w) return;
    yb = (WORD)(w->BorderTop + 22);
    yt = (WORD)(w->BorderTop + 56);
    yv = (WORD)(w->BorderTop + 90);
    SetAPen(w->RPort, 0);
    RectFill(w->RPort, (WORD)(w->BorderLeft + 4), (WORD)(w->BorderTop + 4), (WORD)(w->Width - w->BorderRight - 6), (WORD)(w->Height - w->BorderBottom - 6));
    SetAPen(w->RPort, 1);
    SetBPen(w->RPort, 0);
    SetDrMd(w->RPort, JAM1);
    clipped_window_text(w, (WORD)(w->BorderLeft + 12), (WORD)(yb + 3), "Bass");
    clipped_window_text(w, (WORD)(w->BorderLeft + 12), (WORD)(yt + 3), "Treble");
    clipped_window_text(w, (WORD)(w->BorderLeft + 12), (WORD)(yv + 3), "Volume");
    clipped_window_text(w, (WORD)(w->BorderLeft + 78), (WORD)(yb + 18), "-5        0        +5");
    clipped_window_text(w, (WORD)(w->BorderLeft + 78), (WORD)(yt + 18), "-5        0        +5");
    clipped_window_text(w, (WORD)(w->BorderLeft + 78), (WORD)(yv + 18), "0                  10");
    draw_sound_slider(w, yb, g_sound_bass, -5, 5);
    draw_sound_slider(w, yt, g_sound_treble, -5, 5);
    draw_sound_slider(w, yv, g_sound_volume, 0, 10);
    draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yb + 3), g_sound_bass);
    draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yt + 3), g_sound_treble);
    draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yv + 3), g_sound_volume);
}

static int handle_sound_click(struct Window *w, WORD mx, WORD my)
{
    WORD x1, x2;
    WORD yb, yt, yv;
    LONG new_value;
    if (!w) return 0;
    x1 = (WORD)(w->BorderLeft + 70);
    x2 = (WORD)(w->BorderLeft + 240);
    if (mx < x1 || mx > x2) return 0;
    yb = (WORD)(w->BorderTop + 22);
    yt = (WORD)(w->BorderTop + 56);
    yv = (WORD)(w->BorderTop + 90);

    if (my >= yb - 8 && my <= yb + 8) {
        new_value = sound_x_to_value(mx, -5, 5, (WORD)(w->BorderLeft + 78), (WORD)(w->BorderLeft + 232));
        if (new_value != g_sound_bass) {
            g_sound_bass = new_value;
            mas_direct_set_bass_step(g_sound_bass);
            draw_sound_slider(w, yb, g_sound_bass, -5, 5);
            draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yb + 3), g_sound_bass);
        }
        return 1;
    }
    if (my >= yt - 8 && my <= yt + 8) {
        new_value = sound_x_to_value(mx, -5, 5, (WORD)(w->BorderLeft + 78), (WORD)(w->BorderLeft + 232));
        if (new_value != g_sound_treble) {
            g_sound_treble = new_value;
            mas_direct_set_treble_step(g_sound_treble);
            draw_sound_slider(w, yt, g_sound_treble, -5, 5);
            draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yt + 3), g_sound_treble);
        }
        return 1;
    }
    if (my >= yv - 8 && my <= yv + 8) {
        new_value = sound_x_to_value(mx, 0, 10, (WORD)(w->BorderLeft + 78), (WORD)(w->BorderLeft + 232));
        if (new_value != g_sound_volume) {
            g_sound_volume = new_value;
            mas_direct_set_volume_step(g_sound_volume);
            draw_sound_slider(w, yv, g_sound_volume, 0, 10);
            draw_sound_value(w, (WORD)(w->BorderLeft + 246), (WORD)(yv + 3), g_sound_volume);
        }
        return 1;
    }
    return 0;
}

static void show_sound_window(void)
{
    struct NewWindow nw;
    struct Window *w;
    int done = 0;

    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, WINSTATE_SOUND, g_win ? (WORD)(g_win->LeftEdge + 45) : 60, g_win ? (WORD)(g_win->TopEdge + 45) : 50, 304, 140);
    clamp_new_window_size(&nw, 304, 140, 640, 480);
    nw.DetailPen = 0;
    nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH;
    nw.FirstGadget = 0;
    nw.Title = (UBYTE *)"Sound";
    nw.Type = WBENCHSCREEN;

    w = open_window_with_position_fallback(&nw);
    if (!w) return;
    draw_sound_window(w);

    while (!done) {
        ULONG sigmask = (1UL << w->UserPort->mp_SigBit) | g_timer.sigmask;
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (1) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(w->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) {
                BeginRefresh(w);
                EndRefresh(w, TRUE);
                draw_sound_window(w);
            }
            else if (msg->Class == IDCMP_MOUSEBUTTONS && msg->Code == SELECTDOWN) {
                handle_sound_click(w, msg->MouseX, msg->MouseY);
            }
            ReplyMsg((struct Message *)msg);
        }
    }
    remember_window_state(WINSTATE_SOUND, w);
    CloseWindow(w);
}

static void show_info_window(void)
{
    struct NewWindow nw;
    struct Window *w;
    int done = 0;

    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, WINSTATE_INFO, g_win ? (WORD)(g_win->LeftEdge + 30) : 40, g_win ? (WORD)(g_win->TopEdge + 25) : 30, 348, 132);
    clamp_new_window_size(&nw, 348, 132, 640, 480);
    nw.DetailPen = 0;
    nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH;
    nw.Title = (UBYTE *)"Info";
    nw.Type = WBENCHSCREEN;

    w = open_window_with_position_fallback(&nw);
    if (!w) return;
    draw_info_window(w);
    while (!done) {
        ULONG sigmask = (1UL << w->UserPort->mp_SigBit) | g_timer.sigmask;
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (1) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(w->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) {
                BeginRefresh(w);
                EndRefresh(w, TRUE);
                draw_info_window(w);
            }
            else if (msg->Class == IDCMP_MOUSEBUTTONS && msg->Code == SELECTDOWN) done = 1;
            ReplyMsg((struct Message *)msg);
        }
    }
    remember_window_state(WINSTATE_INFO, w);
    CloseWindow(w);
}

static void clear_playlist(void)
{
    LONG i;
    for (i = 0; i < MAX_RESULTS; ++i) {
        g_results[i].title[0] = 0;
        g_results[i].artist[0] = 0;
        g_results[i].album[0] = 0;
        g_results[i].url[0] = 0;
        g_results[i].genre[0] = 0;
        g_results[i].bitrate = 0;
        g_results[i].track_no = 0;
        g_results[i].duration_secs = 0;
        g_results[i].is_file = 0;
        g_results[i].file_audio_offset = 0;
    }
    g_file_list_mode = 0;
    g_result_count = 0;
    g_selected = 0;
    g_list_top = 0;
}

static void derive_title_from_url(const char *url, char *title, LONG title_size, LONG index)
{
    const char *p = url;
    const char *slash;
    LONG len;
    char tmp[24];

    if (starts_with(p, "http://")) p += 7;
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

    if (!starts_with(url, "http://")) return 0;
    copy_trim(out->url, URL_LEN, url, cstrlen(url));
    out->artist[0] = 0;
    out->genre[0] = 0;
    out->bitrate = 0;
    out->track_no = 0;
    out->duration_secs = 0;
    out->is_file = 0;
    out->file_audio_offset = 0;
    return out->url[0] != 0;
}

static void load_playlist(void)
{
    BPTR f;
    char line[STREAMS_LINE_LEN];
    LONG pos = 0;
    char c;
    LONG got;

    clear_playlist();
    f = Open((STRPTR)STREAMS_FILE, MODE_OLDFILE);
    if (!f) {
        set_status("streams.txt not found");
        draw_ui();
        return;
    }

    while (g_result_count < MAX_RESULTS && (got = Read(f, &c, 1)) > 0) {
        if (c == '\n' || pos >= STREAMS_LINE_LEN - 1) {
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

    if (g_result_count <= 0) set_status("No streams in streams.txt");
    else set_status("Playlist loaded");
    draw_ui();
}


static int line_key_equals(const char *line, const char *key)
{
    while (*key) {
        if (lower_char(*line++) != lower_char(*key++)) return 0;
    }
    return *line == 0;
}

static LONG parse_positive_long(const char *s)
{
    LONG v = 0;
    while (*s == ' ' || *s == '\t') ++s;
    while (*s >= '0' && *s <= '9') {
        v = v * 10 + (*s - '0');
        ++s;
    }
    return v;
}

static void pls_store_entry(LONG slot, char urls[][URL_LEN], char titles[][TITLE_LEN], LONG *max_slot, const char *key, const char *value)
{
    LONG n;

    if (slot < 1 || slot > MAX_RESULTS) return;
    n = slot - 1;
    if (line_key_equals(key, "file")) {
        if (starts_with(value, "http://")) {
            copy_trim(urls[n], URL_LEN, value, cstrlen(value));
            if (slot > *max_slot) *max_slot = slot;
        }
    }
    else if (line_key_equals(key, "title")) {
        copy_trim(titles[n], TITLE_LEN, value, cstrlen(value));
        if (slot > *max_slot) *max_slot = slot;
    }
}

static int parse_pls_line(char *line, char urls[][URL_LEN], char titles[][TITLE_LEN], LONG *max_slot)
{
    char *p = line;
    char *eq;
    char key[16];
    LONG key_len;
    LONG slot;

    while (*p == ' ' || *p == '\t') ++p;
    if (!*p || *p == ';' || *p == '#' || *p == '[') return 0;
    eq = strchr(p, '=');
    if (!eq) return 0;
    key_len = (LONG)(eq - p);
    while (key_len > 0 && (p[key_len - 1] >= '0' && p[key_len - 1] <= '9')) --key_len;
    if (key_len <= 0 || key_len >= (LONG)sizeof(key)) return 0;
    memcpy(key, p, key_len);
    key[key_len] = 0;
    slot = parse_positive_long(p + key_len);
    pls_store_entry(slot, urls, titles, max_slot, key, eq + 1);
    return 1;
}

static int load_pls_file(const char *path)
{
    BPTR f;
    char line[STREAMS_LINE_LEN];
    char urls[MAX_RESULTS][URL_LEN];
    char titles[MAX_RESULTS][TITLE_LEN];
    LONG i, max_slot = 0, pos = 0, got;
    char c;

    for (i = 0; i < MAX_RESULTS; ++i) {
        urls[i][0] = 0;
        titles[i][0] = 0;
    }

    f = Open((STRPTR)path, MODE_OLDFILE);
    if (!f) {
        set_status("Playlist file not found");
        draw_ui();
        return 0;
    }

    while ((got = Read(f, &c, 1)) > 0) {
        if (c == '\n' || pos >= STREAMS_LINE_LEN - 1) {
            line[pos] = 0;
            parse_pls_line(line, urls, titles, &max_slot);
            pos = 0;
        } else {
            line[pos++] = c;
        }
    }
    if (pos > 0) {
        line[pos] = 0;
        parse_pls_line(line, urls, titles, &max_slot);
    }
    Close(f);

    clear_playlist();
    for (i = 0; i < max_slot && g_result_count < MAX_RESULTS; ++i) {
        if (!urls[i][0]) continue;
        copy_trim(g_results[g_result_count].url, URL_LEN, urls[i], cstrlen(urls[i]));
        if (titles[i][0]) copy_trim(g_results[g_result_count].title, TITLE_LEN, titles[i], cstrlen(titles[i]));
        else derive_title_from_url(g_results[g_result_count].url, g_results[g_result_count].title, TITLE_LEN, g_result_count);
        g_results[g_result_count].artist[0] = 0;
        g_results[g_result_count].album[0] = 0;
        g_results[g_result_count].genre[0] = 0;
        g_results[g_result_count].bitrate = 0;
        g_results[g_result_count].track_no = 0;
        g_results[g_result_count].duration_secs = 0;
        g_results[g_result_count].is_file = 0;
        g_results[g_result_count].file_audio_offset = 0;
        ++g_result_count;
    }

    if (g_result_count <= 0) set_status("No streams in PLS file");
    else set_status("PLS playlist loaded");
    draw_ui();
    return g_result_count > 0;
}

static int m3u_line_url(char *line, char *out, LONG out_size)
{
    char *p = line;
    LONG len;

    while (*p == ' ' || *p == '\t') ++p;
    len = cstrlen(p);
    while (len > 0 && (p[len - 1] == '\r' || p[len - 1] == '\n' || p[len - 1] == ' ' || p[len - 1] == '\t')) p[--len] = 0;
    if (!starts_with(p, "http://")) return 0;
    copy_trim(out, out_size, p, cstrlen(p));
    return out[0] != 0;
}

static void m3u_parse_extinf(char *line, char *title, LONG title_size)
{
    char *comma;
    char *p = line;

    while (*p == ' ' || *p == '\t') ++p;
    if (!starts_with(p, "#EXTINF:")) return;
    comma = strchr(p, ',');
    if (!comma) return;
    ++comma;
    while (*comma == ' ' || *comma == '\t') ++comma;
    copy_trim(title, title_size, comma, cstrlen(comma));
}

static int has_m3u_suffix(const char *name);

static int load_m3u_file(const char *path)
{
    BPTR f;
    char line[STREAMS_LINE_LEN];
    char pending_title[TITLE_LEN];
    char url[URL_LEN];
    LONG pos = 0, got;
    char c;

    f = Open((STRPTR)path, MODE_OLDFILE);
    if (!f) {
        set_status("Playlist file not found");
        draw_ui();
        return 0;
    }

    clear_playlist();
    pending_title[0] = 0;
    while (g_result_count < MAX_RESULTS && (got = Read(f, &c, 1)) > 0) {
        if (c == '\n' || pos >= STREAMS_LINE_LEN - 1) {
            line[pos] = 0;
            m3u_parse_extinf(line, pending_title, sizeof(pending_title));
            if (m3u_line_url(line, url, sizeof(url))) {
                copy_trim(g_results[g_result_count].url, URL_LEN, url, cstrlen(url));
                if (pending_title[0]) copy_trim(g_results[g_result_count].title, TITLE_LEN, pending_title, cstrlen(pending_title));
                else derive_title_from_url(url, g_results[g_result_count].title, TITLE_LEN, g_result_count);
                g_results[g_result_count].artist[0] = 0;
                g_results[g_result_count].album[0] = 0;
                g_results[g_result_count].genre[0] = 0;
                g_results[g_result_count].bitrate = 0;
                g_results[g_result_count].track_no = 0;
                g_results[g_result_count].duration_secs = 0;
                g_results[g_result_count].is_file = 0;
                g_results[g_result_count].file_audio_offset = 0;
                ++g_result_count;
                pending_title[0] = 0;
            }
            pos = 0;
        } else {
            line[pos++] = c;
        }
    }
    if (pos > 0 && g_result_count < MAX_RESULTS) {
        line[pos] = 0;
        m3u_parse_extinf(line, pending_title, sizeof(pending_title));
        if (m3u_line_url(line, url, sizeof(url))) {
            copy_trim(g_results[g_result_count].url, URL_LEN, url, cstrlen(url));
            if (pending_title[0]) copy_trim(g_results[g_result_count].title, TITLE_LEN, pending_title, cstrlen(pending_title));
            else derive_title_from_url(url, g_results[g_result_count].title, TITLE_LEN, g_result_count);
            g_results[g_result_count].artist[0] = 0;
            g_results[g_result_count].genre[0] = 0;
            g_results[g_result_count].bitrate = 0;
            g_results[g_result_count].track_no = 0;
            g_results[g_result_count].duration_secs = 0;
            g_results[g_result_count].is_file = 0;
            g_results[g_result_count].file_audio_offset = 0;
            ++g_result_count;
        }
    }
    Close(f);

    if (g_result_count <= 0) set_status("No streams in M3U file");
    else set_status("M3U playlist loaded");
    draw_ui();
    return g_result_count > 0;
}

static int load_playlist_file(const char *path)
{
    if (has_m3u_suffix(path)) return load_m3u_file(path);
    return load_pls_file(path);
}

static int has_suffix3(const char *name, char a, char b, char c)
{
    LONG len = cstrlen(name);
    if (len < 4) return 0;
    return lower_char(name[len - 4]) == '.' && lower_char(name[len - 3]) == a && lower_char(name[len - 2]) == b && lower_char(name[len - 1]) == c;
}

static int has_pls_suffix(const char *name)
{
    return has_suffix3(name, 'p', 'l', 's');
}

static int has_m3u_suffix(const char *name)
{
    return has_suffix3(name, 'm', '3', 'u');
}

static int has_playlist_suffix(const char *name)
{
    return has_pls_suffix(name) || has_m3u_suffix(name);
}

static LONG scan_playlist_dir(const char *dir, char names[][PLS_PATH_LEN], UBYTE is_dir[])
{
    struct FileInfoBlock *fib;
    BPTR lock;
    LONG count = 0;

    if (path_is_root(dir)) return scan_volumes(names, is_dir);

    fib = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock), MEMF_PUBLIC | MEMF_CLEAR);
    if (!fib) return 0;
    lock = Lock((STRPTR)dir, ACCESS_READ);
    if (lock) {
        if (Examine(lock, fib)) {
            if (count < PLS_MAX_FILES) {
                strcpy(names[count], "..");
                is_dir[count] = 2;
                ++count;
            }
            while (count < PLS_MAX_FILES && ExNext(lock, fib)) {
                if (fib->fib_DirEntryType >= 0) {
                    copy_trim(names[count], PLS_PATH_LEN, (const char *)fib->fib_FileName, cstrlen((const char *)fib->fib_FileName));
                    is_dir[count] = 1;
                    ++count;
                }
                else if (has_playlist_suffix((const char *)fib->fib_FileName)) {
                    copy_trim(names[count], PLS_PATH_LEN, (const char *)fib->fib_FileName, cstrlen((const char *)fib->fib_FileName));
                    is_dir[count] = 0;
                    ++count;
                }
            }
        }
        UnLock(lock);
    }
    FreeMem(fib, sizeof(struct FileInfoBlock));
    return count;
}

static void draw_playlist_window(struct Window *w, const char *dir, char names[][PLS_PATH_LEN], UBYTE is_dir[], LONG count)
{
    LONG i;
    struct RastPort *rp;
    char line[128];
    WORD left, right, bottom;

    if (!w) return;
    rp = w->RPort;
    left = (WORD)(w->BorderLeft + 4);
    right = (WORD)(w->Width - w->BorderRight - 6);
    bottom = (WORD)(w->Height - w->BorderBottom - 6);
    if (right < left) right = left;
    if (bottom < (WORD)(w->BorderTop + 4)) bottom = (WORD)(w->BorderTop + 4);
    SetAPen(rp, 0);
    RectFill(rp, left, (WORD)(w->BorderTop + 4), right, bottom);
    SetBPen(rp, 0);
    SetDrMd(rp, JAM1);
    SetAPen(rp, 1);
    line[0] = 0;
    strncat(line, "Dir: ", sizeof(line) - strlen(line) - 1);
    strncat(line, (dir && dir[0]) ? dir : "Volumes", sizeof(line) - strlen(line) - 1);
    clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 14), line);
    clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 28), "Select .pls/.m3u playlist");
    if (count <= 0) {
        clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 46), path_is_root(dir) ? "No volumes found" : "No .pls/.m3u files found");
        return;
    }
    for (i = 0; i < count; ++i) {
        WORD y = (WORD)(w->BorderTop + 46 + i * 12);
        if (y > bottom) break;
        line[0] = 0;
        if (is_dir[i] == 1) {
            strncat(line, "[", sizeof(line) - strlen(line) - 1);
            strncat(line, names[i], sizeof(line) - strlen(line) - 1);
            strncat(line, "]", sizeof(line) - strlen(line) - 1);
        } else if (is_dir[i] == 2) {
            strncat(line, "[..]", sizeof(line) - strlen(line) - 1);
        } else {
            strncat(line, names[i], sizeof(line) - strlen(line) - 1);
        }
        clipped_window_text(w, (WORD)(w->BorderLeft + 14), y, line);
    }
}

static void show_playlist_file_window(void)
{
    struct NewWindow nw;
    struct Window *w;
    char names[PLS_MAX_FILES][PLS_PATH_LEN];
    UBYTE is_dir[PLS_MAX_FILES];
    char current_dir[PLS_PATH_LEN];
    char path[URL_LEN];
    LONG count;
    int done = 0;

    current_dir[0] = 0;
    count = scan_playlist_dir(current_dir, names, is_dir);
    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, WINSTATE_PLAYLIST, g_win ? (WORD)(g_win->LeftEdge + 24) : 35, g_win ? (WORD)(g_win->TopEdge + 24) : 30, 330, (WORD)(92 + (count > 0 ? (WORD)(count * 12) : 12)));
    if (!g_window_states[WINSTATE_PLAYLIST].valid && nw.Height > 250) nw.Height = 250;
    clamp_new_window_size(&nw, 240, 104, 640, 480);
    nw.DetailPen = 0;
    nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS | IDCMP_NEWSIZE;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH;
    nw.MinWidth = 240;
    nw.MinHeight = 104;
    nw.MaxWidth = 640;
    nw.MaxHeight = 480;
    nw.Title = (UBYTE *)"Open Playlist";
    nw.Type = WBENCHSCREEN;

    w = open_window_with_position_fallback(&nw);
    if (!w) return;
    draw_playlist_window(w, current_dir, names, is_dir, count);
    while (!done) {
        ULONG sigmask = (1UL << w->UserPort->mp_SigBit) | g_timer.sigmask;
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (1) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(w->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) {
                BeginRefresh(w);
                EndRefresh(w, TRUE);
                draw_playlist_window(w, current_dir, names, is_dir, count);
            }
            else if (msg->Class == IDCMP_NEWSIZE) {
                draw_playlist_window(w, current_dir, names, is_dir, count);
            }
            else if (msg->Class == IDCMP_MOUSEBUTTONS && msg->Code == SELECTDOWN) {
                LONG row = (msg->MouseY - (w->BorderTop + 38)) / 12;
                if (row >= 0 && row < count) {
                    if (is_dir[row] == 2) {
                        parent_path(current_dir);
                        count = scan_playlist_dir(current_dir, names, is_dir);
                        draw_playlist_window(w, current_dir, names, is_dir, count);
                    }
                    else if (is_dir[row] == 1) {
                        if (path_is_root(current_dir)) copy_trim(path, sizeof(path), names[row], cstrlen(names[row]));
                        else join_path(path, sizeof(path), current_dir, names[row]);
                        copy_trim(current_dir, sizeof(current_dir), path, cstrlen(path));
                        count = scan_playlist_dir(current_dir, names, is_dir);
                        draw_playlist_window(w, current_dir, names, is_dir, count);
                    }
                    else {
                        join_path(path, sizeof(path), current_dir, names[row]);
                        load_playlist_file(path);
                        done = 1;
                    }
                }
            }
            ReplyMsg((struct Message *)msg);
        }
    }
    remember_window_state(WINSTATE_PLAYLIST, w);
    CloseWindow(w);
}


static int has_mp3_suffix(const char *name)
{
    return has_suffix3(name, 'm', 'p', '3');
}

static int has_audio_file_suffix(const char *name)
{
    return has_mp3_suffix(name);
}

static void join_path(char *out, LONG out_size, const char *dir, const char *name)
{
    LONG len;

    if (!out || out_size <= 0) return;
    out[0] = 0;
    if (dir && dir[0]) {
        strncat(out, dir, out_size - 1);
        len = cstrlen(out);
        if (len > 0 && out[len - 1] != '/' && out[len - 1] != ':') {
            strncat(out, "/", out_size - strlen(out) - 1);
        }
    }
    strncat(out, name, out_size - strlen(out) - 1);
}

static void parent_path(char *path)
{
    LONG len;

    if (!path || !path[0]) return;
    len = cstrlen(path);
    while (len > 0 && path[len - 1] == '/') path[--len] = 0;
    while (len > 0 && path[len - 1] != '/' && path[len - 1] != ':') --len;
    if (len <= 0) {
        path[0] = 0;
        return;
    }
    if (path[len - 1] == ':') path[len] = 0;
    else path[len - 1] = 0;
}

static int path_is_root(const char *dir)
{
    return !dir || !dir[0];
}

static void copy_bstr_volume_name(char *out, LONG out_size, BSTR bstr)
{
    UBYTE *src;
    LONG len;

    if (!out || out_size <= 0) return;
    out[0] = 0;
    if (!bstr) return;

    src = (UBYTE *)BADDR(bstr);
    len = src[0];
    if (len <= 0) return;
    if (len > out_size - 2) len = out_size - 2;
    memcpy(out, src + 1, len);
    out[len] = 0;
    if (out[len - 1] != ':') {
        out[len++] = ':';
        out[len] = 0;
    }
}

static LONG scan_volumes(char names[][PLS_PATH_LEN], UBYTE is_dir[])
{
    struct DosLibrary *dos;
    struct RootNode *root;
    struct DosInfo *info;
    BPTR node;
    LONG count = 0;

    dos = (struct DosLibrary *)DOSBase;
    if (!dos || !dos->dl_Root) return 0;

    Forbid();
    root = dos->dl_Root;
    info = root ? (struct DosInfo *)BADDR(root->rn_Info) : 0;
    node = info ? info->di_DevInfo : 0;
    while (node && count < PLS_MAX_FILES) {
        struct DeviceList *dl = (struct DeviceList *)BADDR(node);
        if (dl && dl->dl_Type == DLT_VOLUME && dl->dl_Name) {
            copy_bstr_volume_name(names[count], PLS_PATH_LEN, dl->dl_Name);
            if (names[count][0]) {
                is_dir[count] = 1;
                ++count;
            }
        }
        node = dl ? dl->dl_Next : 0;
    }
    Permit();

    return count;
}

static LONG scan_file_dir(const char *dir, char names[][PLS_PATH_LEN], UBYTE is_dir[])
{
    struct FileInfoBlock *fib;
    BPTR lock;
    LONG count = 0;

    if (path_is_root(dir)) return scan_volumes(names, is_dir);

    fib = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock), MEMF_PUBLIC | MEMF_CLEAR);
    if (!fib) return 0;
    lock = Lock((STRPTR)dir, ACCESS_READ);
    if (lock) {
        if (Examine(lock, fib)) {
            if (count < PLS_MAX_FILES) {
                strcpy(names[count], "..");
                is_dir[count] = 2;
                ++count;
            }
            while (count < PLS_MAX_FILES && ExNext(lock, fib)) {
                if (fib->fib_DirEntryType >= 0) {
                    copy_trim(names[count], PLS_PATH_LEN, (const char *)fib->fib_FileName, cstrlen((const char *)fib->fib_FileName));
                    is_dir[count] = 1;
                    ++count;
                }
                else if (has_audio_file_suffix((const char *)fib->fib_FileName)) {
                    copy_trim(names[count], PLS_PATH_LEN, (const char *)fib->fib_FileName, cstrlen((const char *)fib->fib_FileName));
                    is_dir[count] = 0;
                    ++count;
                }
            }
        }
        UnLock(lock);
    }
    FreeMem(fib, sizeof(struct FileInfoBlock));
    return count;
}

static void draw_file_window(struct Window *w, const char *dir, char names[][PLS_PATH_LEN], UBYTE is_dir[], UBYTE selected[], LONG count)
{
    LONG i;
    struct RastPort *rp;
    char line[128];
    WORD bx1, by1, bx2, by2;
    WORD left, right, bottom, list_bottom;

    if (!w) return;
    rp = w->RPort;
    left = (WORD)(w->BorderLeft + 4);
    right = (WORD)(w->Width - w->BorderRight - 6);
    bottom = (WORD)(w->Height - w->BorderBottom - 6);
    if (right < left) right = left;
    if (bottom < (WORD)(w->BorderTop + 4)) bottom = (WORD)(w->BorderTop + 4);

    SetAPen(rp, 0);
    RectFill(rp, left, (WORD)(w->BorderTop + 4), right, bottom);
    SetBPen(rp, 0);
    SetDrMd(rp, JAM1);
    SetAPen(rp, 1);
    line[0] = 0;
    strncat(line, "Dir: ", sizeof(line) - strlen(line) - 1);
    strncat(line, (dir && dir[0]) ? dir : "Volumes", sizeof(line) - strlen(line) - 1);
    clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 14), line);

    bx1 = (WORD)(w->BorderLeft + 10);
    by1 = (WORD)(w->Height - w->BorderBottom - 22);
    bx2 = (WORD)(bx1 + 52);
    by2 = (WORD)(by1 + 14);
    list_bottom = (WORD)(by1 - 4);
    if (list_bottom > bottom) list_bottom = bottom;

    if (count <= 0) {
        clipped_window_text(w, (WORD)(w->BorderLeft + 10), (WORD)(w->BorderTop + 34), path_is_root(dir) ? "No volumes found" : "No folders or .mp3 files");
    }
    for (i = 0; i < count; ++i) {
        WORD y = (WORD)(w->BorderTop + 34 + i * 12);
        if (y > list_bottom) break;
        line[0] = 0;
        if (is_dir[i] == 1) {
            strncat(line, "[", sizeof(line) - strlen(line) - 1);
            strncat(line, names[i], sizeof(line) - strlen(line) - 1);
            strncat(line, "]", sizeof(line) - strlen(line) - 1);
        } else if (is_dir[i] == 2) {
            strncat(line, "[..]", sizeof(line) - strlen(line) - 1);
        } else {
            strncat(line, selected[i] ? "* " : "  ", sizeof(line) - strlen(line) - 1);
            strncat(line, names[i], sizeof(line) - strlen(line) - 1);
        }
        if (selected[i] && is_dir[i] == 0) SetAPen(rp, 3); else SetAPen(rp, 1);
        clipped_window_text(w, (WORD)(w->BorderLeft + 14), y, line);
    }

    if (by2 <= bottom && bx2 <= right) {
        SetAPen(rp, 1);
        Move(rp, bx1, by1); Draw(rp, bx2, by1); Draw(rp, bx2, by2); Draw(rp, bx1, by2); Draw(rp, bx1, by1);
        clipped_window_text(w, (WORD)(bx1 + 14), (WORD)(by1 + 10), "Add");
    }
}

static ULONG id3_syncsafe(const UBYTE *p)
{
    return (((ULONG)(p[0] & 0x7f)) << 21) | (((ULONG)(p[1] & 0x7f)) << 14) | (((ULONG)(p[2] & 0x7f)) << 7) | ((ULONG)(p[3] & 0x7f));
}

static ULONG id3_u32(const UBYTE *p)
{
    return (((ULONG)p[0]) << 24) | (((ULONG)p[1]) << 16) | (((ULONG)p[2]) << 8) | ((ULONG)p[3]);
}

static void copy_id3_text(char *dst, LONG dst_size, const UBYTE *src, LONG len)
{
    LONG i, out = 0;
    UBYTE enc;

    if (!dst || dst_size <= 0) return;
    dst[0] = 0;
    if (!src || len <= 0) return;
    enc = src[0];
    src++;
    len--;

    if (enc == 1 || enc == 2) {
        LONG step = 2;
        LONG start = 0;
        if (len >= 2 && ((src[0] == 0xff && src[1] == 0xfe) || (src[0] == 0xfe && src[1] == 0xff))) start = 2;
        for (i = start; i + 1 < len && out < dst_size - 1; i += step) {
            UBYTE c = src[i];
            UBYTE d = src[i + 1];
            if (c == 0 && d == 0) break;
            if (c == 0) c = d;
            if (c >= 32 && c < 127) dst[out++] = (char)c;
            else if (c == 9) dst[out++] = ' ';
        }
    } else {
        for (i = 0; i < len && out < dst_size - 1; ++i) {
            UBYTE c = src[i];
            if (c == 0) break;
            if (c >= 32) dst[out++] = (char)c;
            else if (c == 9) dst[out++] = ' ';
        }
    }
    dst[out] = 0;
    {
        char tmp[128];
        copy_trim(tmp, sizeof(tmp), dst, cstrlen(dst));
        copy_trim(dst, dst_size, tmp, cstrlen(tmp));
    }
}

static void derive_title_from_file(const char *path, char *title, LONG title_size)
{
    const char *p = path;
    const char *last = path;
    const char *dot;
    LONG len;

    while (p && *p) {
        if (*p == '/' || *p == ':') last = p + 1;
        ++p;
    }
    dot = strrchr(last, '.');
    len = dot && dot > last ? (LONG)(dot - last) : cstrlen(last);
    if (len <= 0) copy_trim(title, title_size, path, cstrlen(path));
    else copy_trim(title, title_size, last, len);
}

static LONG mpeg_bitrate_from_header(ULONG h)
{
    static const WORD v1_l1[16] = {0,32,64,96,128,160,192,224,256,288,320,352,384,416,448,0};
    static const WORD v1_l2[16] = {0,32,48,56,64,80,96,112,128,160,192,224,256,320,384,0};
    static const WORD v1_l3[16] = {0,32,40,48,56,64,80,96,112,128,160,192,224,256,320,0};
    static const WORD v2_l1[16] = {0,32,48,56,64,80,96,112,128,144,160,176,192,224,256,0};
    static const WORD v2_l23[16] = {0,8,16,24,32,40,48,56,64,80,96,112,128,144,160,0};
    LONG version = (h >> 19) & 3;
    LONG layer = (h >> 17) & 3;
    LONG idx = (h >> 12) & 15;

    if ((h & 0xffe00000UL) != 0xffe00000UL) return 0;
    if (version == 1 || layer == 0 || idx == 0 || idx == 15) return 0;
    if (version == 3) {
        if (layer == 3) return v1_l1[idx];
        if (layer == 2) return v1_l2[idx];
        return v1_l3[idx];
    }
    if (layer == 3) return v2_l1[idx];
    return v2_l23[idx];
}

static LONG scan_mpeg_bitrate(BPTR fh, ULONG offset)
{
    UBYTE buf[1024];
    ULONG base = offset;
    LONG pass;

    Seek(fh, (LONG)offset, OFFSET_BEGINNING);
    for (pass = 0; pass < 16; ++pass) {
        LONG n = Read(fh, buf, sizeof(buf));
        LONG i;
        if (n <= 4) break;
        for (i = 0; i + 3 < n; ++i) {
            ULONG h = (((ULONG)buf[i]) << 24) | (((ULONG)buf[i + 1]) << 16) | (((ULONG)buf[i + 2]) << 8) | (ULONG)buf[i + 3];
            LONG br = mpeg_bitrate_from_header(h);
            if (br > 0) return br;
        }
        base += (ULONG)n;
        Seek(fh, (LONG)base, OFFSET_BEGINNING);
    }
    return 0;
}

static LONG file_size_bytes(BPTR fh)
{
    LONG old;
    LONG size;
    if (!fh) return 0;
    old = Seek(fh, 0, OFFSET_CURRENT);
    if (old < 0) return 0;
    if (Seek(fh, 0, OFFSET_END) < 0) { Seek(fh, old, OFFSET_BEGINNING); return 0; }
    size = Seek(fh, 0, OFFSET_CURRENT);
    Seek(fh, old, OFFSET_BEGINNING);
    return size > 0 ? size : 0;
}

static LONG mp3_duration_from_size(LONG size, ULONG audio_offset, LONG bitrate)
{
    LONG audio_bytes;
    LONG denom;
    if (size <= 0 || bitrate <= 0) return 0;
    if ((ULONG)size <= audio_offset) return 0;
    audio_bytes = size - (LONG)audio_offset;
    if (audio_bytes > 128 && audio_offset == 0) audio_bytes -= 128;
    denom = bitrate * 125;
    if (denom <= 0) return 0;
    return audio_bytes / denom;
}

static void format_clock_time(char *out, LONG out_size, LONG secs)
{
    LONG m;
    LONG s;
    if (!out || out_size <= 0) return;
    if (secs < 0) secs = 0;
    m = secs / 60;
    s = secs % 60;
    if (m < 100) sprintf(out, "%ld:%02ld", m, s);
    else sprintf(out, "%ldm", m);
}

static void format_duration(char *out, LONG out_size, LONG secs)
{
    if (!out || out_size <= 0) return;
    out[0] = 0;
    if (secs <= 0) return;
    format_clock_time(out, out_size, secs);
}

static LONG parse_track_number(const char *s)
{
    LONG v = 0;
    if (!s) return 0;
    while (*s == ' ' || *s == '\t') ++s;
    while (*s >= '0' && *s <= '9') {
        v = v * 10 + (*s - '0');
        ++s;
    }
    return v;
}

static int same_album_name(const char *a, const char *b)
{
    if (!a) a = "";
    if (!b) b = "";
    while (*a || *b) {
        char ca = lower_char(*a++);
        char cb = lower_char(*b++);
        if (ca != cb) return 0;
    }
    return 1;
}

static int album_less(const char *a, const char *b)
{
    if (!a) a = "";
    if (!b) b = "";
    while (*a || *b) {
        char ca = lower_char(*a++);
        char cb = lower_char(*b++);
        if (ca < cb) return 1;
        if (ca > cb) return 0;
    }
    return 0;
}

static int file_entry_less(const struct StreamEntry *a, const struct StreamEntry *b)
{
    if (!a || !b) return 0;
    if (!a->is_file || !b->is_file) return 0;
    if (!same_album_name(a->album, b->album)) return album_less(a->album, b->album);
    if (a->track_no > 0 && b->track_no > 0 && a->track_no != b->track_no) return a->track_no < b->track_no;
    if (a->track_no > 0 && b->track_no <= 0) return 1;
    if (a->track_no <= 0 && b->track_no > 0) return 0;
    return album_less(a->title, b->title);
}

static void sort_file_list(void)
{
    LONG i, j;
    char selected_url[URL_LEN];

    if (!g_file_list_mode || g_result_count <= 1) return;
    selected_url[0] = 0;
    if (g_selected >= 0 && g_selected < g_result_count) copy_trim(selected_url, sizeof(selected_url), g_results[g_selected].url, cstrlen(g_results[g_selected].url));
    for (i = 1; i < g_result_count; ++i) {
        struct StreamEntry cur = g_results[i];
        j = i;
        while (j > 0 && file_entry_less(&cur, &g_results[j - 1])) {
            g_results[j] = g_results[j - 1];
            --j;
        }
        g_results[j] = cur;
    }
    if (selected_url[0]) {
        for (i = 0; i < g_result_count; ++i) {
            if (strcmp(g_results[i].url, selected_url) == 0) { g_selected = i; break; }
        }
    }
    if (g_selected >= g_result_count) g_selected = g_result_count - 1;
    if (g_selected < 0) g_selected = 0;
    ensure_selected_visible();
}

static void parse_id3v2_frames(UBYTE *tag, ULONG tag_len, UBYTE version, char *title, LONG title_size, char *artist, LONG artist_size, char *album, LONG album_size, char *genre, LONG genre_size, LONG *track_no)
{
    ULONG pos = 0;

    while (pos + 10 <= tag_len) {
        char id[5];
        ULONG size;
        UBYTE *frame;

        if (tag[pos] == 0) break;
        memcpy(id, tag + pos, 4);
        id[4] = 0;
        size = (version == 4) ? id3_syncsafe(tag + pos + 4) : id3_u32(tag + pos + 4);
        pos += 10;
        if (size == 0 || pos + size > tag_len) break;
        frame = tag + pos;
        if (!title[0] && strcmp(id, "TIT2") == 0) copy_id3_text(title, title_size, frame, (LONG)size);
        else if (!artist[0] && strcmp(id, "TPE1") == 0) copy_id3_text(artist, artist_size, frame, (LONG)size);
        else if (!album[0] && strcmp(id, "TALB") == 0) copy_id3_text(album, album_size, frame, (LONG)size);
        else if (!genre[0] && strcmp(id, "TCON") == 0) copy_id3_text(genre, genre_size, frame, (LONG)size);
        else if (track_no && *track_no <= 0 && strcmp(id, "TRCK") == 0) {
            char track_buf[16];
            copy_id3_text(track_buf, sizeof(track_buf), frame, (LONG)size);
            *track_no = parse_track_number(track_buf);
        }
        pos += size;
    }
}

static void read_id3v1(BPTR fh, char *title, LONG title_size, char *artist, LONG artist_size, char *genre, LONG genre_size, LONG *track_no)
{
    UBYTE buf[128];
    LONG old;
    static const char *genres[] = {
        "Blues","Classic Rock","Country","Dance","Disco","Funk","Grunge","Hip-Hop",
        "Jazz","Metal","New Age","Oldies","Other","Pop","R&B","Rap","Reggae","Rock",
        "Techno","Industrial","Alternative","Ska","Death Metal","Pranks","Soundtrack",
        "Euro-Techno","Ambient","Trip-Hop","Vocal","Jazz+Funk","Fusion","Trance",
        "Classical","Instrumental","Acid","House","Game","Sound Clip","Gospel","Noise",
        "AlternRock","Bass","Soul","Punk","Space","Meditative","Instrumental Pop",
        "Instrumental Rock","Ethnic","Gothic","Darkwave","Techno-Industrial","Electronic"
    };

    old = Seek(fh, 0, OFFSET_CURRENT);
    if (Seek(fh, -128, OFFSET_END) < 0) { Seek(fh, old, OFFSET_BEGINNING); return; }
    if (Read(fh, buf, sizeof(buf)) == sizeof(buf) && memcmp(buf, "TAG", 3) == 0) {
        if (!title[0]) copy_trim(title, title_size, (const char *)buf + 3, 30);
        if (!artist[0]) copy_trim(artist, artist_size, (const char *)buf + 33, 30);
        if (track_no && *track_no <= 0 && buf[125] == 0 && buf[126] > 0) *track_no = (LONG)buf[126];
        if (!genre[0] && buf[127] < (UBYTE)(sizeof(genres) / sizeof(genres[0]))) {
            copy_trim(genre, genre_size, genres[buf[127]], cstrlen(genres[buf[127]]));
        }
    }
    Seek(fh, old, OFFSET_BEGINNING);
}

static void read_mp3_file_info(const char *path, struct StreamEntry *entry)
{
    BPTR fh;
    UBYTE head[10];
    ULONG audio_offset = 0;
    LONG size = 0;
    char title[TITLE_LEN];
    char artist[TITLE_LEN];
    char album[TITLE_LEN];
    char genre[GENRE_LEN];
    LONG track_no = 0;

    if (!entry) return;
    title[0] = 0;
    artist[0] = 0;
    album[0] = 0;
    genre[0] = 0;
    entry->file_audio_offset = 0;
    entry->bitrate = 0;
    entry->track_no = 0;
    entry->duration_secs = 0;

    fh = Open((STRPTR)path, MODE_OLDFILE);
    if (!fh) return;
    if (Read(fh, head, sizeof(head)) == sizeof(head) && memcmp(head, "ID3", 3) == 0) {
        ULONG tag_size = id3_syncsafe(head + 6);
        ULONG total = 10 + tag_size;
        ULONG read_size = tag_size;
        UBYTE *tag;
        if (head[5] & 0x10) total += 10;
        audio_offset = total;
        if (read_size > 32768UL) read_size = 32768UL;
        tag = (UBYTE *)AllocMem(read_size ? read_size : 1, MEMF_PUBLIC | MEMF_CLEAR);
        if (tag) {
            Seek(fh, 10, OFFSET_BEGINNING);
            if (read_size > 0 && Read(fh, tag, read_size) > 0) parse_id3v2_frames(tag, read_size, head[3], title, sizeof(title), artist, sizeof(artist), album, sizeof(album), genre, sizeof(genre), &track_no);
            FreeMem(tag, read_size ? read_size : 1);
        }
    }
    read_id3v1(fh, title, sizeof(title), artist, sizeof(artist), genre, sizeof(genre), &track_no);
    entry->file_audio_offset = audio_offset;
    entry->bitrate = scan_mpeg_bitrate(fh, audio_offset);
    size = file_size_bytes(fh);
    entry->duration_secs = mp3_duration_from_size(size, audio_offset, entry->bitrate);
    Close(fh);

    if (title[0]) copy_trim(entry->title, TITLE_LEN, title, cstrlen(title));
    if (artist[0]) copy_trim(entry->artist, TITLE_LEN, artist, cstrlen(artist));
    if (album[0]) copy_trim(entry->album, TITLE_LEN, album, cstrlen(album));
    if (genre[0]) copy_trim(entry->genre, GENRE_LEN, genre, cstrlen(genre));
    entry->track_no = track_no;
}

static void add_file_entry(const char *path)
{
    LONG slot;

    if (!g_file_list_mode) {
        clear_playlist();
        g_file_list_mode = 1;
    }
    if (g_result_count >= MAX_RESULTS) {
        set_status("File list full");
        draw_ui();
        return;
    }
    slot = g_result_count;
    copy_trim(g_results[slot].url, URL_LEN, path, cstrlen(path));
    derive_title_from_file(path, g_results[slot].title, TITLE_LEN);
    g_results[slot].artist[0] = 0;
    g_results[slot].album[0] = 0;
    g_results[slot].genre[0] = 0;
    g_results[slot].bitrate = 0;
    g_results[slot].track_no = 0;
    g_results[slot].duration_secs = 0;
    g_results[slot].is_file = 1;
    g_results[slot].file_audio_offset = 0;
    read_mp3_file_info(path, &g_results[slot]);
    g_result_count++;
    g_selected = slot;
    ensure_selected_visible();
}

static LONG add_selected_files(const char *dir, char names[][PLS_PATH_LEN], UBYTE is_dir[], UBYTE selected[], LONG count)
{
    LONG i, added = 0;
    char path[URL_LEN];

    for (i = 0; i < count; ++i) {
        if (is_dir[i] == 0 && selected[i]) {
            join_path(path, sizeof(path), dir, names[i]);
            add_file_entry(path);
            ++added;
            if (g_result_count >= MAX_RESULTS) break;
        }
    }
    if (added > 0) {
        sort_file_list();
        sprintf(g_status_scratch, "%ld MP3 file(s) added", added);
        set_status(g_status_scratch);
        draw_ui();
    }
    return added;
}

static LONG add_directory_files(const char *dir)
{
    struct FileInfoBlock *fib;
    BPTR lock;
    LONG added = 0;
    char path[URL_LEN];

    if (path_is_root(dir)) {
        set_status("Select a directory first");
        draw_status();
        return 0;
    }
    fib = (struct FileInfoBlock *)AllocMem(sizeof(struct FileInfoBlock), MEMF_PUBLIC | MEMF_CLEAR);
    if (!fib) return 0;
    lock = Lock((STRPTR)dir, ACCESS_READ);
    if (lock) {
        if (Examine(lock, fib)) {
            while (g_result_count < MAX_RESULTS && ExNext(lock, fib)) {
                if (fib->fib_DirEntryType < 0 && has_audio_file_suffix((const char *)fib->fib_FileName)) {
                    join_path(path, sizeof(path), dir, (const char *)fib->fib_FileName);
                    add_file_entry(path);
                    ++added;
                }
            }
        }
        UnLock(lock);
    }
    FreeMem(fib, sizeof(struct FileInfoBlock));
    if (added > 0) {
        sort_file_list();
        g_selected = 0;
        g_list_top = 0;
        ensure_selected_visible();
        sprintf(g_status_scratch, "%ld MP3 file(s) added", added);
        set_status(g_status_scratch);
        draw_ui();
    } else {
        set_status("No MP3 files in directory");
        draw_status();
    }
    return added;
}

static void clear_file_selection(UBYTE selected[])
{
    LONG i;
    for (i = 0; i < PLS_MAX_FILES; ++i) selected[i] = 0;
}

static void show_file_add_window_mode(int dir_mode)
{
    struct NewWindow nw;
    struct Window *w;
    char names[PLS_MAX_FILES][PLS_PATH_LEN];
    UBYTE is_dir[PLS_MAX_FILES];
    UBYTE selected[PLS_MAX_FILES];
    char current_dir[PLS_PATH_LEN];
    char path[URL_LEN];
    LONG count;
    int done = 0;

    current_dir[0] = 0;
    clear_file_selection(selected);
    count = scan_file_dir(current_dir, names, is_dir);
    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, dir_mode ? WINSTATE_DIR_ADD : WINSTATE_FILE_ADD, g_win ? (WORD)(g_win->LeftEdge + 30) : 40, g_win ? (WORD)(g_win->TopEdge + 30) : 35, 330, (WORD)(92 + (count > 0 ? (WORD)(count * 12) : 12)));
    if (!g_window_states[dir_mode ? WINSTATE_DIR_ADD : WINSTATE_FILE_ADD].valid && nw.Height > 250) nw.Height = 250;
    clamp_new_window_size(&nw, 240, 104, 640, 480);
    nw.DetailPen = 0;
    nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS | IDCMP_NEWSIZE;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SMART_REFRESH;
    nw.MinWidth = 240;
    nw.MinHeight = 104;
    nw.MaxWidth = 640;
    nw.MaxHeight = 480;
    nw.Title = dir_mode ? (UBYTE *)"Add MP3 Dir" : (UBYTE *)"Add MP3 File";
    nw.Type = WBENCHSCREEN;

    w = open_window_with_position_fallback(&nw);
    if (!w) return;
    draw_file_window(w, current_dir, names, is_dir, selected, count);
    while (!done) {
        ULONG sigmask = (1UL << w->UserPort->mp_SigBit) | g_timer.sigmask;
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (1) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(w->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) {
                BeginRefresh(w);
                EndRefresh(w, TRUE);
                draw_file_window(w, current_dir, names, is_dir, selected, count);
            }
            else if (msg->Class == IDCMP_NEWSIZE) {
                draw_file_window(w, current_dir, names, is_dir, selected, count);
            }
            else if (msg->Class == IDCMP_MOUSEBUTTONS && msg->Code == SELECTDOWN) {
                WORD add_x1 = (WORD)(w->BorderLeft + 10);
                WORD add_y1 = (WORD)(w->Height - w->BorderBottom - 22);
                WORD add_x2 = (WORD)(add_x1 + 52);
                WORD add_y2 = (WORD)(add_y1 + 14);
                if (msg->MouseX >= add_x1 && msg->MouseX <= add_x2 && msg->MouseY >= add_y1 && msg->MouseY <= add_y2) {
                    if (dir_mode) {
                        if (add_directory_files(current_dir) > 0) done = 1;
                    }
                    else {
                        if (add_selected_files(current_dir, names, is_dir, selected, count) > 0) done = 1;
                        else { set_status("No MP3 files selected"); draw_ui(); }
                    }
                }
                else {
                    LONG row = (msg->MouseY - (w->BorderTop + 26)) / 12;
                    if (row >= 0 && row < count) {
                        if (is_dir[row] == 2) {
                            parent_path(current_dir);
                            clear_file_selection(selected);
                            count = scan_file_dir(current_dir, names, is_dir);
                            draw_file_window(w, current_dir, names, is_dir, selected, count);
                        }
                        else if (is_dir[row] == 1) {
                            if (path_is_root(current_dir)) copy_trim(path, sizeof(path), names[row], cstrlen(names[row]));
                            else join_path(path, sizeof(path), current_dir, names[row]);
                            copy_trim(current_dir, sizeof(current_dir), path, cstrlen(path));
                            clear_file_selection(selected);
                            count = scan_file_dir(current_dir, names, is_dir);
                            draw_file_window(w, current_dir, names, is_dir, selected, count);
                        }
                        else if (!dir_mode) {
                            selected[row] = selected[row] ? 0 : 1;
                            draw_file_window(w, current_dir, names, is_dir, selected, count);
                        }
                    }
                }
            }
            ReplyMsg((struct Message *)msg);
        }
    }
    remember_window_state(dir_mode ? WINSTATE_DIR_ADD : WINSTATE_FILE_ADD, w);
    CloseWindow(w);
}

static void show_file_add_window(void)
{
    show_file_add_window_mode(0);
}

static void show_dir_add_window(void)
{
    show_file_add_window_mode(1);
}

static LONG stream_read_transport(UBYTE *buf, LONG maxlen)
{
    if (g_stream.file_fh) { LONG n = Read(g_stream.file_fh, buf, maxlen); if (n <= 0) g_file_eof = 1; return n; }
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
    return recv(g_stream.fd, buf, maxlen, 0);
}

static int stream_write_all_transport(const char *buf, LONG len)
{
    LONG done = 0;
    g_transport_error[0] = 0;
    while (done < len) {
        LONG n;
        n = send(g_stream.fd, (char *)buf + done, len - done, 0);
        if (n <= 0) {
            sprintf(g_transport_error, "HTTP write failed r=%ld", n);
            return 0;
        }
        done += n;
    }
    return 1;
}

static void stream_close_transport(void)
{
    g_pending_pos = 0;
    g_pending_len = 0;
    g_file_eof = 0;
    if (g_stream.file_fh) {
        Close(g_stream.file_fh);
        g_stream.file_fh = 0;
    }
    if (g_stream.fd >= 0) {
        CloseSocket(g_stream.fd);
        g_stream.fd = -1;
    }
}

static int stream_send_request(const char *url)
{
    char path[384], host[96], req[640];
    UWORD port;
    if (!parse_url(url, host, sizeof(host), path, sizeof(path), &port)) return 0;
    strcpy(req, "GET ");
    strncat(req, path, sizeof(req)-strlen(req)-1);
    strncat(req, " HTTP/1.1\r\nHost: ", sizeof(req)-strlen(req)-1);
    strncat(req, host, sizeof(req)-strlen(req)-1);
    strncat(req, "\r\nUser-Agent: MASWaver/1.0\r\nAccept: */*\r\nIcy-MetaData: 1\r\nConnection: close\r\n\r\n", sizeof(req)-strlen(req)-1);
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

static void icy_clear(void)
{
    g_icy_metaint = 0;
    g_icy_audio_left = 0;
    g_icy_meta_remaining = 0;
    g_icy_meta_pos = 0;
    g_icy_need_len = 1;
    g_icy_dirty = 1;
    g_icy_name[0] = 0;
    g_icy_bitrate[0] = 0;
    g_icy_genre[0] = 0;
    g_icy_title[0] = 0;
    memset(g_icy_meta_buf, 0, sizeof(g_icy_meta_buf));
}

static int header_get_value(const char *headers, const char *prefix, char *out, LONG out_size)
{
    const char *p = headers;
    if (out_size > 0) out[0] = 0;
    while (*p) {
        const char *line = p;
        const char *end;
        while (*p && *p != '\n') ++p;
        end = p;
        if (*p == '\n') ++p;
        if (header_line_starts(line, prefix)) {
            line += cstrlen(prefix);
            while (line < end && (*line == ' ' || *line == '\t')) ++line;
            while (end > line && (end[-1] == '\r' || end[-1] == '\n' || end[-1] == ' ' || end[-1] == '\t')) --end;
            copy_trim(out, out_size, line, (LONG)(end - line));
            return out[0] != 0;
        }
    }
    return 0;
}

static LONG header_get_long(const char *headers, const char *prefix)
{
    char tmp[24];
    char *p;
    LONG v = 0;
    if (!header_get_value(headers, prefix, tmp, sizeof(tmp))) return 0;
    p = tmp;
    while (*p >= '0' && *p <= '9') {
        v = (v * 10) + (*p - '0');
        ++p;
    }
    return v;
}

static void icy_parse_headers(const char *headers)
{
    LONG metaint;

    g_icy_name[0] = 0;
    g_icy_bitrate[0] = 0;
    g_icy_genre[0] = 0;
    g_icy_title[0] = 0;
    header_get_value(headers, "icy-name:", g_icy_name, sizeof(g_icy_name));
    header_get_value(headers, "icy-br:", g_icy_bitrate, sizeof(g_icy_bitrate));
    header_get_value(headers, "icy-genre:", g_icy_genre, sizeof(g_icy_genre));
    metaint = header_get_long(headers, "icy-metaint:");
    if (metaint > 0 && metaint < 262144L) {
        g_icy_metaint = metaint;
        g_icy_audio_left = metaint;
    } else {
        g_icy_metaint = 0;
        g_icy_audio_left = 0;
    }
    g_icy_meta_remaining = 0;
    g_icy_meta_pos = 0;
    g_icy_need_len = 1;
    g_icy_dirty = 1;
}

static void icy_update_title_from_block(void)
{
    const char *key = "StreamTitle='";
    char *p;
    char *end;
    char title[ICY_TEXT_LEN];

    g_icy_meta_buf[sizeof(g_icy_meta_buf) - 1] = 0;
    p = strstr(g_icy_meta_buf, key);
    if (!p) return;
    p += cstrlen(key);
    end = strchr(p, '\'');
    if (!end || end <= p) return;
    copy_trim(title, sizeof(title), p, (LONG)(end - p));
    if (title[0] && strcmp(title, g_icy_title) != 0) {
        strncpy(g_icy_title, title, sizeof(g_icy_title) - 1);
        g_icy_title[sizeof(g_icy_title) - 1] = 0;
        g_icy_dirty = 1;
    }
}

static int icy_consume_metadata(void)
{
    UBYTE tmp[64];

    while (1) {
        if (g_icy_need_len) {
            UBYTE len_byte;
            LONG n = stream_read_transport(&len_byte, 1);
            if (n <= 0) return 0;
            g_icy_meta_remaining = ((LONG)len_byte) * 16L;
            g_icy_meta_pos = 0;
            memset(g_icy_meta_buf, 0, sizeof(g_icy_meta_buf));
            g_icy_need_len = 0;
            if (g_icy_meta_remaining <= 0) {
                g_icy_need_len = 1;
                g_icy_audio_left = g_icy_metaint;
                return 1;
            }
        }

        while (g_icy_meta_remaining > 0) {
            LONG want = g_icy_meta_remaining;
            LONG n;
            if (want > (LONG)sizeof(tmp)) want = sizeof(tmp);
            n = stream_read_transport(tmp, want);
            if (n <= 0) return 0;
            if (g_icy_meta_pos < (LONG)sizeof(g_icy_meta_buf) - 1) {
                LONG copy = n;
                if (copy > ((LONG)sizeof(g_icy_meta_buf) - 1 - g_icy_meta_pos)) {
                    copy = (LONG)sizeof(g_icy_meta_buf) - 1 - g_icy_meta_pos;
                }
                memcpy(g_icy_meta_buf + g_icy_meta_pos, tmp, copy);
                g_icy_meta_pos += copy;
                g_icy_meta_buf[g_icy_meta_pos] = 0;
            }
            g_icy_meta_remaining -= n;
        }

        icy_update_title_from_block();
        g_icy_need_len = 1;
        g_icy_audio_left = g_icy_metaint;
        return 1;
    }
}

static LONG stream_read_audio(UBYTE *buf, LONG maxlen)
{
    while (g_icy_metaint > 0) {
        LONG want;
        LONG n;
        if (g_icy_audio_left <= 0) {
            if (!icy_consume_metadata()) return 0;
            continue;
        }
        want = maxlen;
        if (want > g_icy_audio_left) want = g_icy_audio_left;
        n = stream_read_transport(buf, want);
        if (n <= 0) return n;
        g_icy_audio_left -= n;
        return n;
    }
    return stream_read_transport(buf, maxlen);
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
    char path[384];
    UWORD port;

    if (!location || !out || out_size <= 0) return 0;
    out[0] = 0;
    if (starts_with(location, "http://")) {
        strncpy(out, location, out_size - 1);
        out[out_size - 1] = 0;
        return 1;
    }
    if (!parse_url(base_url, host, sizeof(host), path, sizeof(path), &port)) return 0;

    strcpy(out, "http://");
    strncat(out, host, out_size - strlen(out) - 1);
    if (port != 80) {
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

static void set_http_status_error(const char *headers)
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
    strncpy(g_stream_error, line, sizeof(g_stream_error) - 1);
    g_stream_error[sizeof(g_stream_error) - 1] = 0;
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
        icy_clear();
        if (!parse_url(g_http_current, host, sizeof(host), g_http_path, sizeof(g_http_path), &port)) { set_stream_error("Unsupported stream URL"); return -1; }
        g_stream.fd = connect_http(g_http_current, g_http_path, sizeof(g_http_path));
        if (g_stream.fd < 0) { set_stream_error("HTTP socket connect failed"); return -1; }
        set_status("Requesting stream..."); draw_status();
        net_log("request send call");
        if (!stream_send_request(g_http_current)) {
            stream_close_transport();
            set_stream_error(g_transport_error[0] ? g_transport_error : "HTTP request send failed");
            return -1;
        }
        set_status("Reading stream header..."); draw_status();
        net_log("header read call");
        if (!stream_read_headers(g_http_headers, sizeof(g_http_headers))) {
            stream_close_transport();
            set_stream_error("HTTP header read failed");
            return -1;
        }
        net_log("header read ok");
        code = stream_status_code(g_http_headers);
        sprintf(g_net_log_line, "status code=%ld", (LONG)code);
        net_log(g_net_log_line);
        icy_parse_headers(g_http_headers);
        draw_status();
        
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
        set_http_status_error(g_http_headers);
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
    icy_clear();
    g_stream.active = 0;
    g_stream.started = 0;
    g_play_elapsed_ticks = 0;
    g_play_duration_secs = 0;
    g_play_draw_secs = -1;
    g_play_clock_valid = 0;
    g_status_tick = 0;
    set_status("Stopped");
    draw_ui();
}

static int stream_pump_socket(void)
{
    LONG reads = 0;
    int got_data = 0;

    if (!g_stream.active || (!g_stream.file_fh && g_stream.fd < 0)) return 0;
    while (reads < MAX_PUMP_READS && mas_direct_buffer_free() >= STREAM_NET_CHUNK) {
        LONG n = stream_read_audio(g_net_buf, STREAM_NET_CHUNK);
        if (n <= 0) break;
        if (mas_direct_write(g_net_buf, (ULONG)n) != (ULONG)n) break;
        g_total_stream_bytes += (ULONG)n;
        if (g_icy_dirty) {
            g_icy_dirty = 0;
            draw_status();
        }
        got_data = 1;
        ++reads;
    }
    return got_data;
}

static void queue_stream_end_action(UBYTE action)
{
    if (!g_deferred_stream_action) g_deferred_stream_action = action;
    g_stream.started = 0;
}

static void service_stream_timer_signal(void)
{
    if (!timer_drain()) return;
    if (g_stream.active && g_stream.started) {
        int got_data;
        ULONG used;
        if (g_stream.file_fh) ++g_play_elapsed_ticks;
        got_data = stream_pump_socket();
        used = mas_direct_buffer_used();
        if (g_stream.file_fh) {
            LONG secs = current_play_elapsed_secs();
            if (g_play_duration_secs > 0 && secs > g_play_duration_secs) secs = g_play_duration_secs;
            if (secs != g_play_draw_secs) {
                g_play_draw_secs = secs;
                draw_play_time();
            }
        }
        if (mas_direct_had_underrun()) {
            if (g_file_eof && g_selected + 1 < g_result_count && g_results[g_selected + 1].is_file) queue_stream_end_action(DEFER_STREAM_NEXT_FILE);
            else if (g_file_eof) queue_stream_end_action(DEFER_STREAM_EOF_STOP);
            else queue_stream_end_action(DEFER_STREAM_UNDERRUN_STOP);
        }
        else if (g_file_eof && used <= STREAM_EOF_DRAIN_BYTES) {
            if (g_selected + 1 < g_result_count && g_results[g_selected + 1].is_file) queue_stream_end_action(DEFER_STREAM_NEXT_FILE);
            else queue_stream_end_action(DEFER_STREAM_EOF_STOP);
        }
        else if (!g_stream.file_fh && !got_data && used <= STREAM_EMPTY_DRAIN_BYTES) {
            queue_stream_end_action(DEFER_STREAM_UNDERRUN_STOP);
        }
        else {
            timer_start();
        }
    }
}

static void process_stream_deferred(void)
{
    UBYTE action = g_deferred_stream_action;
    if (!action) return;
    g_deferred_stream_action = DEFER_STREAM_NONE;

    mas_direct_stop();
    if (action == DEFER_STREAM_NEXT_FILE) {
        stream_close_transport();
        g_stream.active = 0;
        g_stream.started = 0;
        ++g_selected;
        play_selected();
        return;
    }

    stream_close_transport();
    g_stream.active = 0;
    g_stream.started = 0;
    if (action == DEFER_STREAM_EOF_STOP) set_status("Playback finished");
    else set_status("Buffer underrun - stream stopped");
    draw_status();
}

static int stream_prebuffer(void)
{
    g_total_stream_bytes = 0;
    while (mas_direct_buffer_used() < PREBUFFER_BYTES) {
        LONG n = stream_read_audio(g_net_buf, STREAM_NET_CHUNK);
        if (n <= 0) break;
        if (mas_direct_write(g_net_buf, (ULONG)n) != (ULONG)n) return 0;
        g_total_stream_bytes += (ULONG)n;
        if (g_icy_dirty) {
            g_icy_dirty = 0;
            draw_status();
        }
        if ((g_total_stream_bytes & 0x7fffUL) == 0) {
            sprintf(g_status_scratch, "Prebuffering %ld/%ld KB...", (LONG)(mas_direct_buffer_used() / 1024UL), (LONG)(PREBUFFER_BYTES / 1024UL));
            set_status(g_status_scratch);
            draw_status();
        }
    }
    return mas_direct_buffer_used() >= MAS_DIRECT_NEED_PREBUFFER;
}

static int local_start_fill(void)
{
    g_total_stream_bytes = 0;
    while (mas_direct_buffer_used() < LOCAL_START_BYTES) {
        LONG n = stream_read_audio(g_net_buf, STREAM_NET_CHUNK);
        if (n <= 0) break;
        if (mas_direct_write(g_net_buf, (ULONG)n) != (ULONG)n) return 0;
        g_total_stream_bytes += (ULONG)n;
    }
    return mas_direct_buffer_used() > 0;
}

static void play_selected(void)
{
    if (g_selected < 0 || g_selected >= g_result_count) { set_status("No stream selected"); draw_ui(); return; }

    stop_stream();
    g_stack_missing = 0;
    g_stream.fd = -1;
    g_stream.file_fh = 0;
    g_file_eof = 0;
    g_play_elapsed_ticks = 0;
    g_play_duration_secs = 0;
    g_play_draw_secs = -1;
    g_play_clock_valid = 0;

    if (g_results[g_selected].is_file) {
        set_status("Opening MP3 file...");
        draw_status();
        g_stream.file_fh = Open((STRPTR)g_results[g_selected].url, MODE_OLDFILE);
        if (!g_stream.file_fh) {
            set_status("MP3 file open failed");
            draw_ui();
            return;
        }
        icy_clear();
        g_play_duration_secs = g_results[g_selected].duration_secs;
        if (g_results[g_selected].file_audio_offset > 0) {
            Seek(g_stream.file_fh, (LONG)g_results[g_selected].file_audio_offset, OFFSET_BEGINNING);
        }
        if (g_results[g_selected].artist[0]) {
            g_icy_name[0] = 0;
            strncat(g_icy_name, g_results[g_selected].artist, sizeof(g_icy_name)-strlen(g_icy_name)-1);
            strncat(g_icy_name, " - ", sizeof(g_icy_name)-strlen(g_icy_name)-1);
            strncat(g_icy_name, g_results[g_selected].title, sizeof(g_icy_name)-strlen(g_icy_name)-1);
        } else {
            copy_trim(g_icy_name, sizeof(g_icy_name), g_results[g_selected].title, cstrlen(g_results[g_selected].title));
        }
        copy_trim(g_icy_title, sizeof(g_icy_title), g_results[g_selected].title, cstrlen(g_results[g_selected].title));
        copy_trim(g_icy_genre, sizeof(g_icy_genre), g_results[g_selected].genre, cstrlen(g_results[g_selected].genre));
        if (g_results[g_selected].bitrate > 0) sprintf(g_icy_bitrate, "%ldk", g_results[g_selected].bitrate);
        g_icy_dirty = 1;
    }
    else {
        if (!starts_with(g_results[g_selected].url, "http://")) {
            set_status("Unsupported stream URL");
            draw_ui();
            return;
        }
        set_status("Connecting stream...");
        draw_status();
        if (stream_open_direct(g_results[g_selected].url) < 0) {
            if (g_stack_missing) {
                set_status("Network stack is not running");
            } else {
                set_status(g_stream_error[0] ? g_stream_error : "Stream connect/header failed");
            }
            draw_ui();
            return;
        }
    }

    if (!mas_direct_prepare()) {
        set_status("MAS buffer init failed");
        draw_ui();
        stream_close_transport();
        return;
    }

    g_stream.active = 1;
    g_stream.started = 0;
    if (g_stream.file_fh) {
        set_status("Starting file...");
        draw_status();
        if (!local_start_fill()) {
            stream_close_transport();
            g_stream.active = 0;
            set_status("MP3 file read failed");
            draw_ui();
            return;
        }
    }
    else {
        set_status("Prebuffering stream...");
        draw_status();
        if (!stream_prebuffer()) {
            stream_close_transport();
            g_stream.active = 0;
            set_status("Stream prebuffer failed");
            draw_ui();
            return;
        }
    }

    if (!g_stream.file_fh && g_stream.fd >= 0) {
        LONG nonblock = 1;
        IoctlSocket(g_stream.fd, FIONBIO, &nonblock);
    }
    mas_direct_reset();
    sound_apply();
    mas_direct_start();
    g_stream.started = 1;
    if (g_stream.file_fh) start_play_clock();
    g_status_tick = 0;
    set_status("Playing");
    draw_status();
    if (g_stream.file_fh) draw_play_time();
    timer_start();
}

static void setup_gadgets(void)
{
#define INIT_BUTTON(g,next,x,y,w,label,id) do { memset(&(g),0,sizeof(g)); (g).NextGadget=(next); (g).LeftEdge=(x); (g).TopEdge=(y); (g).Width=(w); (g).Height=14; (g).Flags=GFLG_GADGHCOMP; (g).Activation=GACT_RELVERIFY; (g).GadgetType=BOOLGADGET; (g).GadgetText=(label); (g).GadgetID=(id); } while(0)
    INIT_BUTTON(g_search_btn_gad, &g_play_gad, 12, 16, 64, &g_txt_search_btn, GID_SEARCH_BUTTON);
    INIT_BUTTON(g_play_gad, &g_stop_gad, 84, 16, 52, &g_txt_play, GID_PLAY);
    INIT_BUTTON(g_stop_gad, &g_prev_gad, 144, 16, 52, &g_txt_stop, GID_STOP);
    INIT_BUTTON(g_prev_gad, &g_next_gad, 204, 16, 52, &g_txt_prev, GID_PREV);
    INIT_BUTTON(g_next_gad, &g_del_gad, 264, 16, 52, &g_txt_next, GID_NEXT);
    INIT_BUTTON(g_del_gad, &g_quit_gad, 324, 16, 44, &g_txt_del, GID_DEL);
    INIT_BUTTON(g_quit_gad, 0, 376, 16, 44, &g_txt_quit, GID_QUIT);
#undef INIT_BUTTON
}

static int open_gui(void)
{
    struct NewWindow nw;
    setup_gadgets();
    memset(&nw, 0, sizeof(nw));
    apply_window_state(&nw, WINSTATE_MAIN, 20, 20, WIN_W, WIN_H);
    clamp_new_window_size(&nw, WIN_W, WIN_H, WIN_MAX_W, WIN_MAX_H);
    nw.DetailPen = 0; nw.BlockPen = 1;
    nw.IDCMPFlags = IDCMP_CLOSEWINDOW | IDCMP_GADGETUP | IDCMP_REFRESHWINDOW | IDCMP_MOUSEBUTTONS | IDCMP_MENUPICK | IDCMP_NEWSIZE | IDCMP_RAWKEY;
    nw.Flags = WFLG_CLOSEGADGET | WFLG_DRAGBAR | WFLG_DEPTHGADGET | WFLG_SIZEGADGET | WFLG_ACTIVATE | WFLG_SIMPLE_REFRESH;
    nw.FirstGadget = &g_search_btn_gad;
    nw.Title = (UBYTE *)APP_TITLE;
    nw.Type = WBENCHSCREEN;
    nw.MinWidth = WIN_W;
    nw.MinHeight = WIN_H;
    nw.MaxWidth = WIN_MAX_W;
    nw.MaxHeight = WIN_MAX_H;
    g_win = open_window_with_position_fallback(&nw);
    if (!g_win) return 0;
    SetMenuStrip(g_win, &g_menu_open);
    draw_ui();
    refresh_button_row();
    return 1;
}

int main(void)
{
    ULONG sigmask;
    int done = 0;
    g_stream.fd = -1;
    g_stream.file_fh = 0;
    IntuitionBase = (struct IntuitionBase *)OpenLibrary((STRPTR)"intuition.library", 0);
    GfxBase = (struct GfxBase *)OpenLibrary((STRPTR)"graphics.library", 0);
    if (!IntuitionBase || !GfxBase) goto out;
    sound_defaults();
    load_window_states();
    timer_init();
    if (!open_gui()) goto out;
    sigmask = (1UL << g_win->UserPort->mp_SigBit) | g_timer.sigmask;
    load_playlist();
    while (!done) {
        ULONG got_sig = Wait(sigmask);
        if (got_sig & g_timer.sigmask) { service_stream_timer_signal(); process_stream_deferred(); }
        while (g_win && g_win->UserPort) {
            struct IntuiMessage *msg = (struct IntuiMessage *)GetMsg(g_win->UserPort);
            if (!msg) break;
            if (msg->Class == IDCMP_CLOSEWINDOW) done = 1;
            else if (msg->Class == IDCMP_REFRESHWINDOW) { BeginRefresh(g_win); EndRefresh(g_win, TRUE); draw_ui(); refresh_button_row(); }
            else if (msg->Class == IDCMP_NEWSIZE) { draw_ui(); refresh_button_row(); }
            else if (msg->Class == IDCMP_MOUSEBUTTONS) {
                if (msg->Code == SELECTDOWN && msg->MouseX >= win_left() && msg->MouseY >= list_rows_top() && msg->MouseY <= list_bottom()) {
                    LONG row = (msg->MouseY - list_rows_top()) / 11;
                    LONG idx = g_list_top + row;
                    if (row >= 0 && idx >= 0 && idx < g_result_count) {
                        g_selected = idx;
                        ensure_selected_visible();
                        draw_ui();
                    }
                }
            }
            else if (msg->Class == IDCMP_MENUPICK) {
                UWORD code = msg->Code;
                while (code != MENUNULL) {
                    struct MenuItem *item = ItemAddress(&g_menu_open, code);
                    if (MENUNUM(code) == MENU_OPEN && ITEMNUM(code) == ITEM_PLAYLIST && SUBNUM(code) == SUB_PLAYLIST_OPEN) show_playlist_file_window();
                    else if (MENUNUM(code) == MENU_OPEN && ITEMNUM(code) == ITEM_PLAYLIST && SUBNUM(code) == SUB_PLAYLIST_SAVE) save_filelist_m3u();
                    else if (MENUNUM(code) == MENU_OPEN && ITEMNUM(code) == ITEM_FILE_ADD) show_file_add_window();
                    else if (MENUNUM(code) == MENU_OPEN && ITEMNUM(code) == ITEM_DIR_ADD) show_dir_add_window();
                    else if (MENUNUM(code) == MENU_SOUND && ITEMNUM(code) == ITEM_SOUND_OPEN) show_sound_window();
                    else if (MENUNUM(code) == MENU_HELP && ITEMNUM(code) == ITEM_INFO) show_info_window();
                    code = item ? item->NextSelect : MENUNULL;
                }
            }
            else if (msg->Class == IDCMP_RAWKEY) {
                UWORD raw = msg->Code & 0x7f;
                if (raw == RAWKEY_UP) select_relative(-1);
                else if (raw == RAWKEY_DOWN) select_relative(1);
                else if (raw == RAWKEY_DELETE || raw == RAWKEY_BACKSPACE) remove_selected_file();
            }
            else if (msg->Class == IDCMP_GADGETUP) {
                struct Gadget *gad = (struct Gadget *)msg->IAddress;
                switch (gad->GadgetID) {
                    case GID_SEARCH_BUTTON: load_playlist(); break;
                    case GID_PLAY: play_selected(); break;
                    case GID_STOP: stop_stream(); break;
                    case GID_PREV: select_relative(-1); break;
                    case GID_NEXT: select_relative(1); break;
                    case GID_DEL: remove_selected_file(); break;
                    case GID_QUIT: done = 1; break;
                }
            }
            ReplyMsg((struct Message *)msg);
        }
    }
out:
    stop_stream();
    mas_direct_shutdown();
    if (g_win) { remember_window_state(WINSTATE_MAIN, g_win); ClearMenuStrip(g_win); CloseWindow(g_win); g_win = 0; }
    save_window_states();
    timer_cleanup();
    net_log_close();
    if (SocketBase) CloseLibrary(SocketBase);
    if (GfxBase) CloseLibrary((struct Library *)GfxBase);
    if (IntuitionBase) CloseLibrary((struct Library *)IntuitionBase);
    return 0;
}
