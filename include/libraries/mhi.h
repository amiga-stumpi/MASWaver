/* MHI 1.2 public interface constants; MHI by Thomas Wenzel and Paul Qureshi. */
#ifndef LIBRARIES_MHI_H
#define LIBRARIES_MHI_H

#include <exec/libraries.h>

#define MHIF_PLAYING 0
#define MHIF_STOPPED 1
#define MHIF_OUT_OF_DATA 2
#define MHIF_PAUSED 3

#define MHIF_UNSUPPORTED 0
#define MHIF_SUPPORTED 1
#define MHIQ_DECODER_NAME 1000
#define MHIQ_DECODER_VERSION 1001
#define MHIQ_AUTHOR 1002
#define MHIQ_CAPABILITIES 0
#define MHIQ_BASS_CONTROL 30
#define MHIQ_TREBLE_CONTROL 31
#define MHIQ_VOLUME_CONTROL 40

#define MHIP_VOLUME 0
#define MHIP_BASS 3
#define MHIP_TREBLE 5

#endif
