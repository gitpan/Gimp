#include "config.h"

#include <libgimp/gimp.h>
#include <libgimp/gimpexport.h>

#include <locale.h>

/* FIXME */
/* sys/param.h is redefining these! */
#undef MIN
#undef MAX

/* dunno where this comes from */
#undef VOIDUSED

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#define NEED_newCONSTSUB
#include "gppport.h"

#include "perl-intl.h"

/* FIXME */
/* dirty is used in gimp.h.  */
#ifdef dirty
# undef dirty
#endif

#ifndef HAVE_EXIT
/* expect iso-c here.  */
# include <signal.h>
#endif

#include "extra.h"

MODULE = Gimp	PACKAGE = Gimp

PROTOTYPES: ENABLE

void
_exit()
	CODE:
#ifdef HAVE__EXIT
	_exit(0);
#elif defined(SIGKILL)
	raise(SIGKILL);
#else
	raise(9)
#endif
	abort();


BOOT:
#ifdef ENABLE_NLS
	setlocale (LC_MESSAGES, ""); /* calling twice doesn't hurt, no? */
        bindtextdomain (GETTEXT_PACKAGE "-perl", datadir "/locale");
        textdomain (GETTEXT_PACKAGE "-perl");
#endif

char *
bindtextdomain(d,dir)
	char * d
	char * dir

char *
textdomain(d)
	char *	d

utf8_str
gettext(s)
	utf8_str s
        PROTOTYPE: $

utf8_str
dgettext(d,s)
	char *	d
	utf8_str s

utf8_str
__(s)
	utf8_str s
        PROTOTYPE: $

void
xs_exit(status)
	int	status
	CODE:
	exit (status);

BOOT:
{
   HV *stash = gv_stashpvn ("Gimp", 4, TRUE);
   
   newCONSTSUB (stash, "PARASITE_PERSISTENT", newSViv (GIMP_PARASITE_PERSISTENT));
   newCONSTSUB (stash, "PARASITE_UNDOABLE", newSViv (GIMP_PARASITE_UNDOABLE));

   newCONSTSUB (stash, "PARASITE_ATTACH_PARENT", newSViv (GIMP_PARASITE_ATTACH_PARENT));
   newCONSTSUB (stash, "PARASITE_PARENT_PERSISTENT", newSViv (GIMP_PARASITE_PARENT_PERSISTENT));
   newCONSTSUB (stash, "PARASITE_PARENT_UNDOABLE", newSViv (GIMP_PARASITE_PARENT_UNDOABLE));
   
   newCONSTSUB (stash, "PARASITE_ATTACH_GRANDPARENT", newSViv (GIMP_PARASITE_ATTACH_GRANDPARENT));
   newCONSTSUB (stash, "PARASITE_GRANDPARENT_PERSISTENT", newSViv (GIMP_PARASITE_GRANDPARENT_PERSISTENT));
   newCONSTSUB (stash, "PARASITE_GRANDPARENT_UNDOABLE", newSViv (GIMP_PARASITE_GRANDPARENT_UNDOABLE));
   
   newCONSTSUB (stash, "TRACE_NONE", newSViv (TRACE_NONE));
   newCONSTSUB (stash, "TRACE_CALL", newSViv (TRACE_CALL));
   newCONSTSUB (stash, "TRACE_TYPE", newSViv (TRACE_TYPE));
   newCONSTSUB (stash, "TRACE_NAME", newSViv (TRACE_NAME));
   newCONSTSUB (stash, "TRACE_DESC", newSViv (TRACE_DESC));
   newCONSTSUB (stash, "TRACE_ALL" , newSViv (TRACE_ALL ));

   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_RGB", newSViv (GIMP_EXPORT_CAN_HANDLE_RGB));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_GRAY", newSViv (GIMP_EXPORT_CAN_HANDLE_GRAY));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_INDEXED", newSViv (GIMP_EXPORT_CAN_HANDLE_INDEXED));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_ALPHA", newSViv (GIMP_EXPORT_CAN_HANDLE_ALPHA ));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_BITMAP", newSViv (GIMP_EXPORT_CAN_HANDLE_BITMAP));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_LAYERS", newSViv (GIMP_EXPORT_CAN_HANDLE_LAYERS));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_LAYERS_AS_ANIMATION", newSViv (GIMP_EXPORT_CAN_HANDLE_LAYERS_AS_ANIMATION));
   newCONSTSUB (stash, "EXPORT_CAN_HANDLE_LAYER_MASKS", newSViv (GIMP_EXPORT_CAN_HANDLE_LAYER_MASKS));
   newCONSTSUB (stash, "EXPORT_NEEDS_ALPHA", newSViv (GIMP_EXPORT_NEEDS_ALPHA));

   newCONSTSUB (stash, "EXPORT_CANCEL", newSViv (GIMP_EXPORT_CANCEL));
   newCONSTSUB (stash, "EXPORT_IGNORE", newSViv (GIMP_EXPORT_CANCEL));
   newCONSTSUB (stash, "EXPORT_EXPORT", newSViv (GIMP_EXPORT_EXPORT));
}

MODULE = Gimp	PACKAGE = Gimp::RAW

# some raw byte/bit-manipulation (e.g. for avi and miff), use PDL instead
# mostly undocumented as well...

void
reverse_v_inplace (datasv, bpl)
	SV *	datasv
        IV	bpl
        CODE:
        char *line, *data, *end;
        STRLEN h;

        data = SvPV (datasv, h); h /= bpl;
        end = data + (h-1) * bpl;

        New (0, line, bpl, char);

        while (data < end)
          {
            Move (data, line, bpl, char);
            Move (end, data, bpl, char);
            Move (line, end, bpl, char);

            data += bpl;
            end -= bpl;
          }

        Safefree (line);

	OUTPUT:
        datasv

void
convert_32_24_inplace (datasv)
	SV *	datasv
        CODE:
        STRLEN dc;
        char *data, *src, *dst, *end;

        data = SvPV (datasv, dc); end = data + dc;

        for (src = dst = data; src < end; )
          {
            *dst++ = *src++;
            *dst++ = *src++;
            *dst++ = *src++;
                     *src++;
          }

        SvCUR_set (datasv, dst - data);
	OUTPUT:
        datasv

void
convert_24_15_inplace (datasv)
	SV *	datasv
        CODE:
        STRLEN dc;
        char *data, *src, *dst, *end;

        U16 m31d255[256];

        for (dc = 256; dc--; )
          m31d255[dc] = (dc*31+127)/255;

        data = SvPV (datasv, dc); end = data + dc;

        for (src = dst = data; src < end; )
          {
            unsigned int r = *(U8 *)src++;
            unsigned int g = *(U8 *)src++;
            unsigned int b = *(U8 *)src++;

            U16 rgb = m31d255[r]<<10 | m31d255[g]<<5 | m31d255[b];
            *dst++ = rgb & 0xff;
            *dst++ = rgb >> 8;
          }

        SvCUR_set (datasv, dst - data);
	OUTPUT:
        datasv

void
convert_15_24_inplace (datasv)
	SV *	datasv
        CODE:
        STRLEN dc, de;
        char *data, *src, *dst;

        U8 m255d31[32];

        for (dc = 32; dc--; )
          m255d31[dc] = (dc*255+15)/31;

        data = SvPV (datasv, dc); dc &= ~1;
        de = dc + (dc >> 1);
        SvGROW (datasv, de);
        SvCUR_set (datasv, de);
        data = SvPV (datasv, de); src = data + dc;

        dst = data + de;

        while (src != dst)
          {
            U16 rgb = *(U8 *)--src << 8 | *(U8 *)--src;

            *(U8 *)--dst = m255d31[ rgb & 0x001f       ];
            *(U8 *)--dst = m255d31[(rgb & 0x03e0) >>  5];
            *(U8 *)--dst = m255d31[(rgb & 0x7c00) >> 10];
          }

	OUTPUT:
        datasv

void
convert_bgr_rgb_inplace (datasv)
	SV *	datasv
        CODE:
        char *data, *end;

        data = SvPV_nolen (datasv);
        end = SvEND (datasv);

        while (data < end)
          {
            char x = data[0];

            data[0] = data[2];
            data[2] = x;

            data += 3;
          }

	OUTPUT:
        datasv


