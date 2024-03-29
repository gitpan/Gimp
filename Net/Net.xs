#include "config.h"

#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#include "gppport.h"
#include <locale.h>

#if !defined(PERLIO_IS_STDIO) && defined(HASATTRIBUTE)
# undef printf
# define printf PerlIO_stdoutf
#endif

#include "../perl-intl.h"

#define is_dynamic(sv)				\
	(strEQ ((sv), "Gimp::Tile")		\
         || strEQ ((sv), "Gimp::PixelRgn")	\
         || strEQ ((sv), "Gimp::GimpDrawable"))

static HV *object_cache;
static int object_id = 100;

#define init_object_cache	if (!object_cache) object_cache = newHV()

static void destroy_object (SV *sv)
{
  if (!(object_cache && sv_isobject (sv)))
    croak (__("Internal error: Gimp::Net #100, please report!"));
  char *name = HvNAME(SvSTASH(SvRV(sv)));
  if (!is_dynamic (name))
    croak (__("Internal error: Gimp::Net #101, please report!"));
  int id = SvIV(SvRV(sv));
  (void)hv_delete (object_cache, (char *)&id, sizeof(id), G_DISCARD);
}

/* allocate this much as initial length */
#define INITIAL_PV	256
/* and increment in these steps */
#define PV_INC		512

/* types
 *
 * u			undef
 * a num sv*		array
 * p len cont		pv
 * i int		iv
 * n double		nv
 * b stash sv		blessed reference
 * r			simple reference
 * h len (key sv)*	hash (not yet supported!)
 * P pv			passed as a string which has been PDL::IO::Dumper-ed
 *
 */

static void sv2net (int deobjectify, SV *s, SV *sv)
{
  if (SvLEN(s)-SvCUR(s) < 96)
    SvGROW (s, SvLEN(s) + PV_INC);

  if (SvROK(sv))
    {
      SV *rv = SvRV(sv);
      if (SvOBJECT (rv))
        {
          char *name = HvNAME (SvSTASH (rv));

	  if (strEQ (name, "PDL"))
	    {
	      char *str;
	      STRLEN len;
	      require_pv ("PDL/IO/Dumper.pm");
	      dSP;
	      ENTER;
	      SAVETMPS;
	      PUSHMARK(SP);
	      XPUSHs(sv);
	      PUTBACK;
	      if (perl_call_pv ("PDL::IO::Dumper::sdump", G_SCALAR) != 1)
		croak (__("Failed to sdump PDL object"));
	      SPAGAIN;
	      sv = POPs;
	      str = SvPV(sv,len);
	      sv_catpvf (s, "P%x:", (int)len);
	      sv_catpvn (s, str, len);
	      PUTBACK;
	      FREETMPS;
	      LEAVE;
              return;
	    }

          sv_catpvf (s, "b%x:%s", (unsigned int)strlen (name), name);

          if (deobjectify && is_dynamic (name))
            {
              object_id++;
              SvREFCNT_inc(sv);
              (void)hv_store (object_cache, (char *)&object_id, sizeof(object_id), sv, 0);
              sv_catpvf (s, "i%d:", object_id);
              return;
            }
        }
      else
	{
	  sv_catpvn (s, "r", 1);
	}

      if (SvTYPE(rv) == SVt_PVAV)
        {
          AV *av = (AV*)rv;
          int i;

          sv_catpvf (s, "a%x:", (I32)av_len(av));
          for (i = 0; i <= av_len(av); i++)
            sv2net (deobjectify, s, *av_fetch(av,i,0));
        }
      else if (SvTYPE(rv) == SVt_PVMG)
        sv2net (deobjectify, s, rv);
      else
        croak ("Internal error: unable to convert reference in sv2net, please report!");
    }
  else if (SvOK(sv))
    {
      if (SvIOK(sv))
	{
	  sv_catpvf (s,"i%ld:", (long)SvIV(sv));
	}
      else if (SvNOK(sv))
        {
	  sv_catpvf (s,"n%.20lf:", (double)SvNV(sv));
	}
      else
        {
          char *str;
          STRLEN len;

          /* slower than necessary, just make it an pv */
          str = SvPV(sv,len);
          sv_catpvf (s, "p%x:", (int)len);
          sv_catpvn (s, str, len);
        }
    }
  else
    {
      sv_catpvn (s, "u", 1);
    }
}

static SV *net2sv (int objectify, char **_s)
{
  char *s = *_s;
  SV *sv;
  AV *av;
  unsigned int ui, n;
  int i, j;
  long l;
  double d;
  char str[64];

  switch (*s++)
    {
      case 'u':
        sv = newSVsv (&PL_sv_undef);
        break;

      case 'n':
        sscanf (s, "%lf:%n", &d, &n); s += n;
        sv = newSVnv ((NV)d);
        break;

      case 'i':
        sscanf (s, "%ld:%n", &l, &n); s += n;
        sv = newSViv ((IV)l);
        break;

      case 'p':
        sscanf (s, "%x:%n", &ui, &n); s += n;
        sv = newSVpvn (s, (STRLEN)ui);
        s += ui;
        break;

      case 'P':
	{
	  char *tmp;
	  sscanf (s, "%x:%n", &ui, &n); s += n;
	  tmp = strndup (s, ui);
	  s += ui;
	  require_pv ("PDL.pm");
	  require_pv ("PDL/IO/Dumper.pm");
	  ENTER;
	  SAVETMPS;
	  (void)eval_pv ("import PDL;", TRUE);
	  sv = eval_pv (tmp, TRUE);
	  SvREFCNT_inc (sv);
	  free (tmp);
	  FREETMPS;
	  LEAVE;
	  break;
	}

      case 'r':
        sv = newRV_noinc (net2sv (objectify, &s));
        break;

      case 'b':
        sscanf (s, "%x:%n", &ui, &n); s += n;
        if (ui >= sizeof str)
          croak ("Internal error: stashname too long, please report!");

        memcpy (str, s, ui); s += ui;
        str[ui] = 0;

        if (objectify && is_dynamic (str))
          {
            SV **cv;
            int id;

            sscanf (s, "i%ld:%n", &l, &n); s += n;

            cv = hv_fetch (object_cache, (char *)(id=l,&id), sizeof(id), 0);
            if (!cv)
              croak ("Internal error: asked to deobjectify an object not in the cache, please report!");

            sv = *cv;
            SvREFCNT_inc (sv);
          }
        else
          sv = sv_bless (newRV_noinc (net2sv (objectify, &s)), gv_stashpv (str, 1));

        break;

      case 'a':
        sscanf (s, "%x:%n", &i, &n); s += n;
        av = newAV ();
        av_extend (av, (I32)i);
        for (j = 0; j <= i; j++)
          av_store (av, (I32)j, net2sv (objectify, &s));

        sv = (SV*)av;
        break;

      default:
        croak ("Internal error: unable to handle argtype '%c' in net2sv, please report!", s[-1]);
    }

  *_s = s;
  return sv;
}

MODULE = Gimp::Net	PACKAGE = Gimp::Net

PROTOTYPES: ENABLE

BOOT:
#ifdef ENABLE_NLS
        setlocale (LC_ALL, "");
#endif

SV *
args2net(deobjectify,...)
int deobjectify
CODE:
  int index;
  char* previous_locale = setlocale(LC_NUMERIC, "C");
  if (deobjectify) init_object_cache;
  RETVAL = newSVpv ("", 0);
  (void) SvUPGRADE (RETVAL, SVt_PV);
  SvGROW (RETVAL, INITIAL_PV);
  for (index = 1; index < items; index++)
    sv2net (deobjectify, RETVAL, ST(index));
  setlocale(LC_NUMERIC, previous_locale);
OUTPUT:
  RETVAL

void
net2args(objectify,s)
int	objectify
char *	s
PPCODE:
  if (objectify) init_object_cache;
  /* this depends on a trailing zero! */
  char* previous_locale = setlocale(LC_NUMERIC, "C");
  while (*s)
    {
      SV *sv;
      PUTBACK; // this is necessary due to eval_pv in net2sv
      sv = net2sv (objectify, &s);
      SPAGAIN; // works without, but recommended by perl expert - leaving in
      XPUSHs (sv_2mortal (sv));
    }
  setlocale(LC_NUMERIC, previous_locale);

void
destroy_objects(...)
CODE:
  int index;
  for (index = 0; index < items; index++)
    destroy_object (ST(index));

