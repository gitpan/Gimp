#ifdef __cplusplus
extern "C" {
#endif
#include "EXTERN.h"
#include "perl.h"
#include "XSUB.h"
#ifdef __cplusplus
}
#endif

/* dirty is used in gimp.h.  */
#include <assert.h>
#include <stdio.h>

#undef dirty
#include <libgimp/gimp.h>

#include "extradefs.h"

#define TRACE_NONE	0x00
#define TRACE_CALL	0x01
#define TRACE_TYPE	0x11
#define TRACE_NAME	0x21
#define TRACE_DESC	0x41
#define TRACE_ALL	0xff

#define GIMP_PKG	"Gimp::"	/* the package name */

#define PKG_COLOR	GIMP_PKG "Color"
#define PKG_REGION	GIMP_PKG "Region"
#define PKG_DISPLAY	GIMP_PKG "Display"
#define PKG_IMAGE	GIMP_PKG "Image"
#define PKG_LAYER	GIMP_PKG "Layer"
#define PKG_CHANNEL	GIMP_PKG "Channel"
#define PKG_DRAWABLE	GIMP_PKG "Drawable"
#define PKG_SELECTION	GIMP_PKG "Selection"

static int trace = TRACE_NONE;

typedef guint32 IMAGE;
typedef guint32 LAYER;
typedef guint32 CHANNEL;
typedef guint32 DRAWABLE;
typedef guint32 SELECTION;
typedef guint32 DISPLAY;
typedef guint32 REGION;
typedef guint32 COLOR;

static int
not_here(s)
char *s;
{
    croak("%s not implemented on this architecture", s);
    return -1;
}

static double
constant(name, arg)
char *name;
int arg;
{
    errno = 0;
    switch (*name) {
    case 'A':
	if (strEQ(name, "ADDITION_MODE"))
	    return ADDITION_MODE;
	if (strEQ(name, "ALPHA_MASK"))
	    return ALPHA_MASK;
	if (strEQ(name, "APPLY"))
	    return APPLY;
	break;
    case 'B':
	if (strEQ(name, "BEHIND_MODE"))
	    return BEHIND_MODE;
	if (strEQ(name, "BG_BUCKET_FILL"))
	    return BG_BUCKET_FILL;
	if (strEQ(name, "BG_IMAGE_FILL"))
	    return BG_IMAGE_FILL;
	if (strEQ(name, "BILINEAR"))
	    return BILINEAR;
	if (strEQ(name, "BLACK_MASK"))
	    return BLACK_MASK;
	if (strEQ(name, "BLUE_CHANNEL"))
	    return BLUE_CHANNEL;
	if (strEQ(name, "BLUR"))
	    return BLUR;
	break;
    case 'C':
	if (strEQ(name, "CLIP_TO_BOTTOM_LAYER"))
	    return CLIP_TO_BOTTOM_LAYER;
	if (strEQ(name, "CLIP_TO_IMAGE"))
	    return CLIP_TO_IMAGE;
	if (strEQ(name, "COLOR_MODE"))
	    return COLOR_MODE;
	if (strEQ(name, "CONICAL_ASYMMETRIC"))
	    return CONICAL_ASYMMETRIC;
	if (strEQ(name, "CONICAL_SYMMETRIC"))
	    return CONICAL_SYMMETRIC;
	if (strEQ(name, "CUSTOM"))
	    return CUSTOM;
	break;
    case 'D':
	if (strEQ(name, "DARKEN_ONLY_MODE"))
	    return DARKEN_ONLY_MODE;
	if (strEQ(name, "DIFFERENCE_MODE"))
	    return DIFFERENCE_MODE;
	if (strEQ(name, "DISCARD"))
	    return DISCARD;
	if (strEQ(name, "DISSOLVE_MODE"))
	    return DISSOLVE_MODE;
	break;
    case 'E':
	if (strEQ(name, "EXPAND_AS_NECESSARY"))
	    return EXPAND_AS_NECESSARY;
	break;
    case 'F':
	if (strEQ(name, "FG_BG_HSV"))
	    return FG_BG_HSV;
	if (strEQ(name, "FG_BG_RGB"))
	    return FG_BG_RGB;
	if (strEQ(name, "FG_BUCKET_FILL"))
	    return FG_BUCKET_FILL;
	if (strEQ(name, "FG_TRANS"))
	    return FG_TRANS;
	break;
    case 'G':
	if (strEQ(name, "GRAY"))
	    return GRAY;
	if (strEQ(name, "GRAYA_IMAGE"))
	    return GRAYA_IMAGE;
	if (strEQ(name, "GRAY_CHANNEL"))
	    return GRAY_CHANNEL;
	if (strEQ(name, "GRAY_IMAGE"))
	    return GRAY_IMAGE;
	if (strEQ(name, "GREEN_CHANNEL"))
	    return GREEN_CHANNEL;
	break;
    case 'H':
	if (strEQ(name, "HUE_MODE"))
	    return HUE_MODE;
	break;
    case 'I':
	if (strEQ(name, "IMAGE_CLONE"))
	    return IMAGE_CLONE;
	if (strEQ(name, "INDEXED"))
	    return INDEXED;
	if (strEQ(name, "INDEXEDA_IMAGE"))
	    return INDEXEDA_IMAGE;
	if (strEQ(name, "INDEXED_CHANNEL"))
	    return INDEXED_CHANNEL;
	if (strEQ(name, "INDEXED_IMAGE"))
	    return INDEXED_IMAGE;
	break;
    case 'L':
	if (strEQ(name, "LIGHTEN_ONLY_MODE"))
	    return LIGHTEN_ONLY_MODE;
	if (strEQ(name, "LINEAR"))
	    return LINEAR;
	break;
    case 'M':
	if (strEQ(name, "MULTIPLY_MODE"))
	    return MULTIPLY_MODE;
	break;
    case 'N':
	if (strEQ(name, "NORMAL_MODE"))
	    return NORMAL_MODE;
	if (strEQ(name, "NO_IMAGE_FILL"))
	    return NO_IMAGE_FILL;
	break;
    case 'O':
	if (strEQ(name, "OVERLAY_MODE"))
	    return OVERLAY_MODE;
	break;
    case 'P':
	if (strEQ(name, "PARAM_BOUNDARY"))
	    return PARAM_BOUNDARY;
	if (strEQ(name, "PARAM_CHANNEL"))
	    return PARAM_CHANNEL;
	if (strEQ(name, "PARAM_COLOR"))
	    return PARAM_COLOR;
	if (strEQ(name, "PARAM_DISPLAY"))
	    return PARAM_DISPLAY;
	if (strEQ(name, "PARAM_DRAWABLE"))
	    return PARAM_DRAWABLE;
	if (strEQ(name, "PARAM_END"))
	    return PARAM_END;
	if (strEQ(name, "PARAM_FLOAT"))
	    return PARAM_FLOAT;
	if (strEQ(name, "PARAM_FLOATARRAY"))
	    return PARAM_FLOATARRAY;
	if (strEQ(name, "PARAM_IMAGE"))
	    return PARAM_IMAGE;
	if (strEQ(name, "PARAM_INT16"))
	    return PARAM_INT16;
	if (strEQ(name, "PARAM_INT16ARRAY"))
	    return PARAM_INT16ARRAY;
	if (strEQ(name, "PARAM_INT32"))
	    return PARAM_INT32;
	if (strEQ(name, "PARAM_INT32ARRAY"))
	    return PARAM_INT32ARRAY;
	if (strEQ(name, "PARAM_INT8"))
	    return PARAM_INT8;
	if (strEQ(name, "PARAM_INT8ARRAY"))
	    return PARAM_INT8ARRAY;
	if (strEQ(name, "PARAM_LAYER"))
	    return PARAM_LAYER;
	if (strEQ(name, "PARAM_PATH"))
	    return PARAM_PATH;
	if (strEQ(name, "PARAM_REGION"))
	    return PARAM_REGION;
	if (strEQ(name, "PARAM_SELECTION"))
	    return PARAM_SELECTION;
	if (strEQ(name, "PARAM_STATUS"))
	    return PARAM_STATUS;
	if (strEQ(name, "PARAM_STRING"))
	    return PARAM_STRING;
	if (strEQ(name, "PARAM_STRINGARRAY"))
	    return PARAM_STRINGARRAY;
	if (strEQ(name, "PATTERN_BUCKET_FILL"))
	    return PATTERN_BUCKET_FILL;
	if (strEQ(name, "PATTERN_CLONE"))
	    return PATTERN_CLONE;
	if (strEQ(name, "PIXELS"))
	    return PIXELS;
	if (strEQ(name, "POINTS"))
	    return POINTS;
	if (strEQ(name, "PROC_EXTENSION"))
	    return PROC_EXTENSION;
	if (strEQ(name, "PROC_PLUG_IN"))
	    return PROC_PLUG_IN;
	if (strEQ(name, "PROC_TEMPORARY"))
	    return PROC_TEMPORARY;
	break;
    case 'R':
	if (strEQ(name, "RADIAL"))
	    return RADIAL;
	if (strEQ(name, "RED_CHANNEL"))
	    return RED_CHANNEL;
	if (strEQ(name, "REPEAT_NONE"))
	    return REPEAT_NONE;
	if (strEQ(name, "REPEAT_SAWTOOTH"))
	    return REPEAT_SAWTOOTH;
	if (strEQ(name, "REPEAT_TRIANGULAR"))
	    return REPEAT_TRIANGULAR;
	if (strEQ(name, "RGB"))
	    return RGB;
	if (strEQ(name, "RGBA_IMAGE"))
	    return RGBA_IMAGE;
	if (strEQ(name, "RGB_IMAGE"))
	    return RGB_IMAGE;
	if (strEQ(name, "RUN_INTERACTIVE"))
	    return RUN_INTERACTIVE;
	if (strEQ(name, "RUN_NONINTERACTIVE"))
	    return RUN_NONINTERACTIVE;
	if (strEQ(name, "RUN_WITH_LAST_VALS"))
	    return RUN_WITH_LAST_VALS;
	break;
    case 'S':
	if (strEQ(name, "SATURATION_MODE"))
	    return SATURATION_MODE;
	if (strEQ(name, "SCREEN_MODE"))
	    return SCREEN_MODE;
	if (strEQ(name, "SELECTION_ADD"))
	    return SELECTION_ADD;
	if (strEQ(name, "SELECTION_INTERSECT"))
	    return SELECTION_INTERSECT;
	if (strEQ(name, "SELECTION_REPLACE"))
	    return SELECTION_REPLACE;
	if (strEQ(name, "SELECTION_SUB"))
	    return SELECTION_SUB;
	if (strEQ(name, "SHAPEBURST_ANGULAR"))
	    return SHAPEBURST_ANGULAR;
	if (strEQ(name, "SHAPEBURST_DIMPLED"))
	    return SHAPEBURST_DIMPLED;
	if (strEQ(name, "SHAPEBURST_SPHERICAL"))
	    return SHAPEBURST_SPHERICAL;
	if (strEQ(name, "SHARPEN"))
	    return SHARPEN;
	if (strEQ(name, "SQUARE"))
	    return SQUARE;
	if (strEQ(name, "STATUS_CALLING_ERROR"))
	    return STATUS_CALLING_ERROR;
	if (strEQ(name, "STATUS_EXECUTION_ERROR"))
	    return STATUS_EXECUTION_ERROR;
	if (strEQ(name, "STATUS_PASS_THROUGH"))
	    return STATUS_PASS_THROUGH;
	if (strEQ(name, "STATUS_SUCCESS"))
	    return STATUS_SUCCESS;
	if (strEQ(name, "SUBTRACT_MODE"))
	    return SUBTRACT_MODE;
	break;
    case 'T':
	if (strEQ(name, "TRANS_IMAGE_FILL"))
	    return TRANS_IMAGE_FILL;
	if (strEQ(name, "TRACE_NONE")) return TRACE_NONE;
	if (strEQ(name, "TRACE_CALL")) return TRACE_CALL;
	if (strEQ(name, "TRACE_TYPE")) return TRACE_TYPE;
	if (strEQ(name, "TRACE_NAME")) return TRACE_NAME;
	if (strEQ(name, "TRACE_DESC")) return TRACE_DESC;
	if (strEQ(name, "TRACE_ALL"))  return TRACE_ALL;
	break;
    case 'V':
	if (strEQ(name, "VALUE_MODE"))
	    return VALUE_MODE;
	break;
    case 'W':
	if (strEQ(name, "WHITE_IMAGE_FILL"))
	    return WHITE_IMAGE_FILL;
	if (strEQ(name, "WHITE_MASK"))
	    return WHITE_MASK;
	break;
    }
    errno = EINVAL;
    return 0;

not_there:
    errno = ENOENT;
    return 0;
}

static void
dump_params (int nparams, GParam *args, GParamDef *params)
{
  static char *ptype[22] = {
    "INT32"      , "INT16"      , "INT8"      , "FLOAT"      , "STRING"     ,
    "INT32ARRAY" , "INT16ARRAY" , "INT8ARRAY" , "FLOATARRAY" , "STRINGARRAY",
    "COLOR"      , "REGION"     , "DISPLAY"   , "IMAGE"      , "LAYER"      ,
    "CHANNEL"    , "DRAWABLE"   , "SELECTION" , "BOUNDARY"   , "PATH"       ,
    "STATUS"     , "END"
  };
  int i;
  
  fprintf (stderr, "(");
  
  if ((trace & TRACE_DESC) == TRACE_DESC)
    fprintf (stderr, "\n\t");
  
  for (i = 0; i < nparams; i++)
    {
      if ((trace & TRACE_TYPE) == TRACE_TYPE)
        if (params[i].type >= 0 && params[i].type < 22)
          fprintf (stderr, "%s ", ptype[params[i].type]);
        else
          fprintf (stderr, "T%d ", params[i].type);
      
      if ((trace & TRACE_NAME) == TRACE_NAME)
        fprintf (stderr, "%s=", params[i].name);
      
      switch (args[i].type)
        {
          case PARAM_INT32:	fprintf (stderr, "%d", args[i].data.d_int32); break;
          case PARAM_INT16:	fprintf (stderr, "%d", args[i].data.d_int16); break;
          case PARAM_INT8:	fprintf (stderr, "%d", args[i].data.d_int8); break;
          case PARAM_FLOAT:	fprintf (stderr, "%d", args[i].data.d_float); break;
          case PARAM_STRING:	fprintf (stderr, "\"%s\"", args[i].data.d_string); break;
          case PARAM_DISPLAY:	fprintf (stderr, "%d", args[i].data.d_display); break;
          case PARAM_IMAGE:	fprintf (stderr, "%d", args[i].data.d_image); break;
          case PARAM_LAYER:	fprintf (stderr, "%d", args[i].data.d_layer); break;
          case PARAM_CHANNEL:	fprintf (stderr, "%d", args[i].data.d_channel); break;
          case PARAM_DRAWABLE:	fprintf (stderr, "%d", args[i].data.d_drawable); break;
          case PARAM_SELECTION:	fprintf (stderr, "%d", args[i].data.d_selection); break;
          case PARAM_BOUNDARY:	fprintf (stderr, "%d", args[i].data.d_boundary); break;
          case PARAM_PATH:	fprintf (stderr, "%d", args[i].data.d_path); break;
          case PARAM_STATUS:	fprintf (stderr, "%d", args[i].data.d_status); break;
          
          case PARAM_COLOR:
            fprintf (stderr, "[%d,%d,%d]",
                     args[i].data.d_color.red, args[i].data.d_color.green, args[i].data.d_color.blue);
            break;
            
          default:
            fprintf (stderr, "(?)");
        }
      
      if ((trace & TRACE_DESC) == TRACE_DESC)
        fprintf (stderr, "\t\"%s\"\n\t", params[i].description);
      else if (i < nparams - 1)
        fprintf (stderr, ", ");
      
    }
  
  fprintf (stderr, ")");
}

static void
convert_sv2paramdef (GParamDef *par, SV *sv)
{
  SV *type = 0;
  SV *name = 0;
  SV *help = 0;
  
  if (SvROK (sv) && SvTYPE (SvRV (sv)) == SVt_PVAV)
    {
      AV *av = (AV *)SvRV(sv);
      SV **x;
      
      if ((x = av_fetch (av, 0, 0))) type = *x;
      if ((x = av_fetch (av, 1, 0))) name = *x;
      if ((x = av_fetch (av, 2, 0))) help = *x;
    }
  else if (SvIOK(sv))
    type = sv;

  if (type)
    {
      par->type = SvIV (type);
      par->name = name ? SvPV (name, na) : 0;
      par->description = help ? SvPV (help, na) : 0;
    }
  else
    croak ("malformed paramdef, expected [PARAM_TYPE,\"NAME\",\"DESCRIPTION\"] or PARAM_TYPE");
}

/* automatically bless SV into PARAM_type.  */
/* for what it's worth, we cache the stashes.  */
static SV *
autobless (SV *sv, int type)
{
  static HV *bless_hv[22]; /* initialized to zero */
   static char *bless[22] = { 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
                             PKG_COLOR,
                             PKG_REGION,
                             PKG_DISPLAY,
                             PKG_IMAGE,
                             PKG_LAYER,
                             PKG_CHANNEL,
                             PKG_DRAWABLE,
                             PKG_SELECTION,
                             0, 0, 0, 0 };
  
  if (bless [type])
    {
      if (!bless_hv [type])
        bless_hv [type] = gv_stashpv (bless [type], 1);
      
      sv = sv_bless (newRV_noinc (sv), bless_hv [type]);
    }
  
  return sv;
}

/* return gint32 from object, wether iv or rv.  */
static gint32
unbless (SV *sv)
{
  if (SvROK (sv))
    {
      if (SvTYPE (SvRV (sv)) == SVt_PVMG)
        return SvIV (SvRV (sv));
      else
        croak ("only blessed scalars accepted here");
    }
  else
    return SvIV (sv);
}

static SV *
convert_gimp2sv (GParam *arg)
{
  SV *sv;
  AV *av;
  
  switch (arg->type)
    {
      case PARAM_INT32:		sv = newSViv(arg->data.d_int32	); break;
      case PARAM_INT16:		sv = newSViv(arg->data.d_int16	); break;
      case PARAM_INT8:		sv = newSViv(arg->data.d_int8	); break;
      case PARAM_FLOAT:		sv = newSVnv(arg->data.d_float	); break;
      case PARAM_STRING:	sv = newSVpv(arg->data.d_string, strlen(arg->data.d_string)); break;
      case PARAM_DISPLAY:	sv = newSViv(arg->data.d_display); break;
      case PARAM_IMAGE:		sv = newSViv(arg->data.d_image	); break;
      case PARAM_LAYER:		sv = newSViv(arg->data.d_layer	); break;
      case PARAM_CHANNEL:	sv = newSViv(arg->data.d_channel); break;
      case PARAM_DRAWABLE:	sv = newSViv(arg->data.d_drawable); break;
      case PARAM_SELECTION:	sv = newSViv(arg->data.d_selection); break;
      case PARAM_BOUNDARY:	sv = newSViv(arg->data.d_boundary); break;
      case PARAM_PATH:		sv = newSViv(arg->data.d_path	); break;
      case PARAM_STATUS:	sv = newSViv(arg->data.d_status	); break;
      case PARAM_COLOR:
        /* difficult */
        av = newAV ();
        av_push (av, newSViv (arg->data.d_color.red));
        av_push (av, newSViv (arg->data.d_color.green));
        av_push (av, newSViv (arg->data.d_color.blue));
        sv = newRV_inc ((SV *)av);
        break;
        
      default:
        fatal ("dunno how to return param type %d", arg->type);
/*        sv = sv_newmortal ();*/
        abort ();
    }
  
  return autobless (sv, arg->type);
}

static void
convert_sv2gimp (char *err, GParam *arg, SV *sv)
{
  switch (arg->type)
    {
      case PARAM_INT32:		arg->data.d_int32	= SvIV(sv); break;
      case PARAM_INT16:		arg->data.d_int16	= SvIV(sv); break;
      case PARAM_INT8:		arg->data.d_int8	= SvIV(sv); break;
      case PARAM_FLOAT:		arg->data.d_float	= SvNV(sv); break;
      case PARAM_STRING:	arg->data.d_string	= SvPV(sv, na); break;
      case PARAM_DISPLAY:	arg->data.d_display	= unbless(sv); break;
      case PARAM_IMAGE:		arg->data.d_image	= unbless(sv); break;
      case PARAM_LAYER:		arg->data.d_layer	= unbless(sv); break;
      case PARAM_CHANNEL:	arg->data.d_channel	= unbless(sv); break;
      case PARAM_DRAWABLE:	arg->data.d_drawable	= unbless(sv); break;
      case PARAM_SELECTION:	arg->data.d_selection	= unbless(sv); break;
      case PARAM_BOUNDARY:	arg->data.d_boundary	= SvIV(sv); break;
      case PARAM_PATH:		arg->data.d_path	= SvIV(sv); break;
      case PARAM_STATUS:	arg->data.d_status	= SvIV(sv); break;
      case PARAM_COLOR:
        /* difficult */
        if (SvROK(sv))
          {
            if (SvTYPE(SvRV(sv)) == SVt_PVAV)
              {
                AV *av = (AV *)SvRV(sv);
                if (av_len(av) == 2)
                  {
                    arg->data.d_color.red   = SvIV(*av_fetch(av, 0, 0));
                    arg->data.d_color.green = SvIV(*av_fetch(av, 1, 0));
                    arg->data.d_color.blue  = SvIV(*av_fetch(av, 2, 0));
                  }
                else
                  sprintf (err, "a color must have three components (array elements)");
              }
            else
              sprintf (err, "a color must be specified as either an array-ref or a string");
          }
        else
          {
            int r,g,b;
            STRLEN len;
            if (sscanf (SvPV (sv, len), "#%02x%02x%02x", &r, &g, &b) == 3
                && len == 7)
              {
                arg->data.d_color.red   = r;
                arg->data.d_color.green = g;
                arg->data.d_color.blue  = b;
              }
            else
              sprintf (err, "a color string must be of form #rrggbb");
          }
        break;
        
      default:
        sprintf (err, "dunno how to pass arg type %d", arg->type);
    }
}

static void pii_init(void)
{
  dSP; PUSHMARK(sp); perl_call_pv ("init", G_DISCARD | G_NOARGS);
}

static void pii_query(void)
{
  dSP; PUSHMARK(sp); perl_call_pv ("query", G_DISCARD | G_NOARGS);
}

static void pii_quit(void)
{
  dSP; PUSHMARK(sp); perl_call_pv ("quit", G_DISCARD | G_NOARGS);
}

static void pii_run(char *name, int nparams, GParam *param, int *nreturn_vals, GParam **return_vals)
{
  dSP;
  int i, count;
  
  ENTER;
  SAVETMPS;
  
  PUSHMARK(sp);
  
  if (nparams)
    {
      EXTEND (sp, nparams);
      for (i = 0; i < nparams; i++)
        PUSHs(convert_gimp2sv(&param[i]));
      
      PUTBACK;
    }
  
  count = perl_call_pv (name, nparams ? 0 : G_NOARGS
                        | *nreturn_vals == 0 ? G_VOID|G_DISCARD : *nreturn_vals == 1 ? G_SCALAR : G_ARRAY);
  
  SPAGAIN;
  
  FREETMPS;
  LEAVE;
  
/*  printf ("call_pv returned with %d results\n", count);*//*D*/
/*  printf ("nreturn = %d\n", *nreturn_vals);*//*D*/
  
  *nreturn_vals = 0;
}

GPlugInInfo PLUG_IN_INFO = { pii_init, pii_quit, pii_query, pii_run };

MODULE = Gimp		PACKAGE = Gimp

PROTOTYPES: ENABLE

void
set_trace (mask)
	int	mask
	CODE:
	trace = mask;

double
constant(name, arg)
	char *		name
	int		arg

int
gimp_main(...)
	PREINIT:
	CODE:
		if (items == 0)
		  {
		  }
		else
		  croak ("arguments to main not yet supported!");
		
		RETVAL = gimp_main (origargc-1, origargv+1);
	OUTPUT:
	RETVAL

# checks wether a gimp procedure exists
int
_gimp_procedure_available(proc_name)
	char * proc_name
	CODE:
	{
		char *proc_blurb;	
		char *proc_help;
		char *proc_author;
		char *proc_copyright;
		char *proc_date;
		int proc_type;
		int nparams;
		int nreturn_vals;
		int nvalues;
		GParamDef *params;
		GParamDef *return_vals;
		
		if (gimp_query_procedure (proc_name, &proc_blurb, &proc_help, &proc_author,
		    &proc_copyright, &proc_date, &proc_type, &nparams, &nreturn_vals,
		    &params, &return_vals) == TRUE)
		  {
		    g_free (proc_blurb);
		    g_free (proc_help);
		    g_free (proc_author);
		    g_free (proc_copyright);
		    g_free (proc_date);
		    g_free (params);
		    g_free (return_vals);
		    RETVAL = TRUE;
		  }
		else
		  RETVAL = FALSE;
		    
	}
	OUTPUT:
	RETVAL

void
gimp_call_procedure (proc_name, ...)
	char *	proc_name
	PPCODE:
	{
		char croak_str[300] = "";
		char *arg_name;
		char *proc_blurb;	
		char *proc_help;
		char *proc_author;
		char *proc_copyright;
		char *proc_date;
		int proc_type;
		int nparams;
		int nreturn_vals;
		int i;
		GParam *args;
		GParam *values;
		int nvalues;
		GParamDef *params;
		GParamDef *return_vals;
		
		if (trace & TRACE_CALL)
		  fprintf (stderr, "%s", proc_name);
		
		if (gimp_query_procedure (proc_name, &proc_blurb, &proc_help, &proc_author,
		    &proc_copyright, &proc_date, &proc_type, &nparams, &nreturn_vals,
		    &params, &return_vals) == TRUE)
		  {
		    g_free (proc_blurb);
		    g_free (proc_help);
		    g_free (proc_author);
		    g_free (proc_copyright);
		    g_free (proc_date);
		    if (items-1 != nparams)
		      sprintf (croak_str, "'%s' expects %d arguments, not %d",
		               proc_name, nparams, items-1);
		    else
		      {
		        if (nparams)
		          args = (GParam *) g_new (GParam, nparams);
    		        
    		        for (i = 0; i < nparams; i++)
		          {
		            args[i].type = params[i].type;
		            convert_sv2gimp (croak_str, &args[i], ST(i+1));
		          }
		        
		        if (trace & TRACE_CALL)
		          {
		            dump_params (nparams, args, params);
		            fprintf (stderr, " = ");
		          }
    		    
                        values = gimp_run_procedure2 (proc_name, &nvalues, nparams, args);
                        
    		        if (nparams)
    		          g_free (args);
    		    
			if (trace & TRACE_CALL)
			  {
			    dump_params (nvalues-1, values+1, return_vals);
			    fprintf (stderr, "\n");
			  }
			
                        if (values && values[0].type == PARAM_STATUS)
                          {
                            if (values[0].data.d_status == STATUS_EXECUTION_ERROR)
                              sprintf (croak_str, "%s: procedural database execution failed", proc_name);
                            else if (values[0].data.d_status == STATUS_CALLING_ERROR)
                              sprintf (croak_str, "%s: procedural database execution failed on invalid input arguments", proc_name);
                            else if (values[0].data.d_status == STATUS_SUCCESS)
                              {
                                EXTEND(sp, nvalues-1);
                                for (i = 0; i < nvalues-1; i++)
                                  PUSHs(sv_2mortal (convert_gimp2sv (&values[i+1])));
                              }
                            else
                              sprintf (croak_str, "unsupported status code: %d\n", values[0].data.d_status);
                          }
                        else
                          sprintf (croak_str, "gimp returned, well.. dunno how to interpret that...");
		        
		        if (values)
		          g_free (values);
		      
                      }
		    
		    g_free (return_vals);
		    g_free (params);
		    
		    if (croak_str[0])
		      croak (croak_str);
		  }
		else
		  croak ("gimp procedure '%s' not found", proc_name);
	}

void
gimp_install_procedure(name, blurb, help, author, copyright, date, menu_path, image_types, type, params, return_vals)
	char *	name
	char *	blurb
	char *	help
	char *	author
	char *	copyright
	char *	date
	char *	menu_path
	char *	image_types
	int	type
	SV *	params
	SV *	return_vals
	CODE:
	{
		if (SvROK(params) && SvTYPE(SvRV(params)) == SVt_PVAV
		    && SvROK(return_vals) && SvTYPE(SvRV(return_vals)) == SVt_PVAV)
		  {
		    AV *args = (AV *)SvRV(params);
		    AV *ret = (AV *)SvRV(return_vals);
		    int nparams = av_len(args)+1;
		    int nreturn_vals = av_len(ret)+1;
		    GParamDef *apd = alloca(nparams * sizeof (GParamDef));
		    GParamDef *rpd = alloca(nreturn_vals * sizeof (GParamDef));
		    int i;
		    
		    for (i = 0; i < nparams; i++)
		      convert_sv2paramdef (&apd[i], *av_fetch(args, i, 0));
		    for (i = 0; i < nreturn_vals; i++)
		      convert_sv2paramdef (&rpd[i], *av_fetch(ret, i, 0));
		    
		    gimp_install_procedure(name,blurb,help,author,copyright,date,menu_path,image_types,
		                           type,nparams,nreturn_vals,apd,rpd);
		  }
		else
		  croak ("params and return_vals must be array refs (even if empty)!");
	}

#void
#gimp_install_temp_proc(name, blurb, help, author, copyright, date, menu_path, image_types, type, nparams, nreturn_vals, params, return_vals, run_proc)
#	char *	name
#	char *	blurb
#	char *	help
#	char *	author
#	char *	copyright
#	char *	date
#	char *	menu_path
#	char *	image_types
#	int	type
#	int	nparams
#	int	nreturn_vals
#	GParamDef *	params
#	GParamDef *	return_vals
#	GRunProc	run_proc

void
gimp_uninstall_temp_proc(name)
	char *	name

void
gimp_quit()

#void
#gimp_set_data(id, data, length)
#	gchar *	id
#	gpointer	data
#	guint32	length

#void
#gimp_get_data(id, data)
#	gchar *	id
#	gpointer	data

void
gimp_progress_init(message)
	char *	message

void
gimp_progress_update(percentage)
	gdouble	percentage

void
gimp_query_database(name_regexp, blurb_regexp, help_regexp, author_regexp, copyright_regexp, date_regexp, proc_type_regexp)
	char *	name_regexp
	char *	blurb_regexp
	char *	help_regexp
	char *	author_regexp
	char *	copyright_regexp
	char *	date_regexp
	char *	proc_type_regexp
	PPCODE:
	{
		int *nprocs;
		char ***proc_names;
		abort ();
	}

#gint
#gimp_query_procedure(proc_name, proc_blurb, proc_help, proc_author, proc_copyright, proc_date, proc_type, nparams, nreturn_vals, params, return_vals)
#	char *	proc_name
#	char **	proc_blurb
#	char **	proc_help
#	char **	proc_author
#	char **	proc_copyright
#	char **	proc_date
#	int *	proc_type
#	int *	nparams
#	int *	nreturn_vals
#	GParamDef **	params
#	GParamDef **	return_vals

#gint32 *
#gimp_query_images(nimages)
#	int *	nimages

void
gimp_register_magic_load_handler(name, extensions, prefixes, magics)
	char *	name
	char *	extensions
	char *	prefixes
	char *	magics

void
gimp_register_load_handler(name, extensions, prefixes)
	char *	name
	char *	extensions
	char *	prefixes

void
gimp_register_save_handler(name, extensions, prefixes)
	char *	name
	char *	extensions
	char *	prefixes

#GParam *
#gimp_run_procedure(name, nreturn_vals, ...)
#	char *	name
#	int *	nreturn_vals

#GParam *
#gimp_run_procedure2(name, nreturn_vals, nparams, params)
#	char *	name
#	int *	nreturn_vals
#	int	nparams
#	GParam *	params

#void
#gimp_destroy_params(params, nparams)
#	GParam *	params
#	int	nparams

gdouble
gimp_gamma()

gint
gimp_install_cmap()

gint
gimp_use_xshm()

guchar *
gimp_color_cube()

gchar *
gimp_gtkrc()

IMAGE
gimp_image_new(width, height, type)
	guint	width
	guint	height
	GImageType	type

void
gimp_image_delete(image_ID)
	IMAGE	image_ID

guint
gimp_image_width(image_ID)
	IMAGE	image_ID

guint
gimp_image_height(image_ID)
	IMAGE	image_ID

GImageType
gimp_image_base_type(image_ID)
	IMAGE	image_ID

LAYER
gimp_image_floating_selection(image_ID)
	IMAGE	image_ID

void
gimp_image_add_channel(image_ID, channel_ID, position)
	IMAGE	image_ID
	CHANNEL	channel_ID
	gint	position

void
gimp_image_add_layer(image_ID, layer_ID, position)
	IMAGE	image_ID
	LAYER	layer_ID
	gint	position

void
gimp_image_add_layer_mask(image_ID, layer_ID, mask_ID)
	IMAGE	image_ID
	LAYER	layer_ID
	LAYER	mask_ID

void
gimp_image_clean_all(image_ID)
	IMAGE	image_ID

void
gimp_image_disable_undo(image_ID)
	IMAGE	image_ID

void
gimp_image_enable_undo(image_ID)
	IMAGE	image_ID

void
gimp_image_flatten(image_ID)
	IMAGE	image_ID

void
gimp_image_lower_channel(image_ID, channel_ID)
	IMAGE	image_ID
	CHANNEL	channel_ID

void
gimp_image_lower_layer(image_ID, layer_ID)
	IMAGE	image_ID
	CHANNEL	layer_ID

LAYER
gimp_image_merge_visible_layers(image_ID, merge_type)
	IMAGE	image_ID
	gint	merge_type

LAYER
gimp_image_pick_correlate_layer(image_ID, x, y)
	IMAGE	image_ID
	gint	x
	gint	y

void
gimp_image_raise_channel(image_ID, channel_ID)
	IMAGE	image_ID
	CHANNEL	channel_ID

void
gimp_image_raise_layer(image_ID, layer_ID)
	IMAGE	image_ID
	LAYER	layer_ID

void
gimp_image_remove_channel(image_ID, channel_ID)
	IMAGE	image_ID
	CHANNEL	channel_ID

void
gimp_image_remove_layer(image_ID, layer_ID)
	IMAGE	image_ID
	LAYER	layer_ID

void
gimp_image_remove_layer_mask(image_ID, layer_ID, mode)
	IMAGE	image_ID
	LAYER	layer_ID
	gint	mode

void
gimp_image_resize(image_ID, new_width, new_height, offset_x, offset_y)
	IMAGE	image_ID
	guint	new_width
	guint	new_height
	gint	offset_x
	gint	offset_y

CHANNEL
gimp_image_get_active_channel(image_ID)
	IMAGE	image_ID

LAYER
gimp_image_get_active_layer(image_ID)
	IMAGE	image_ID

gint32 *
gimp_image_get_channels(image_ID, nchannels)
	IMAGE	image_ID
	gint *	nchannels

guchar *
gimp_image_get_cmap(image_ID, ncolors)
	IMAGE	image_ID
	gint *	ncolors

gint
gimp_image_get_component_active(image_ID, component)
	IMAGE	image_ID
	gint	component

#
# this is not implemented in my version of libgimp!
#
#gint
#gimp_image_get_component_visible(image_ID, component)
#	gint32	image_ID
#	gint	component


char *
gimp_image_get_filename(image_ID)
	IMAGE	image_ID

gint32 *
gimp_image_get_layers(image_ID, nlayers)
	IMAGE	image_ID
	gint *	nlayers

gint32
gimp_image_get_selection(image_ID)
	IMAGE	image_ID

void
gimp_image_set_active_channel(image_ID, channel_ID)
	IMAGE	image_ID
	IMAGE	channel_ID

void
gimp_image_set_active_layer(image_ID, layer_ID)
	IMAGE	image_ID
	LAYER	layer_ID

void
gimp_image_set_cmap(image_ID, cmap, ncolors)
	IMAGE	image_ID
	guchar *cmap
	gint	ncolors

void
gimp_image_set_component_active(image_ID, component, active)
	IMAGE	image_ID
	gint	component
	gint	active

void
gimp_image_set_component_visible(image_ID, component, visible)
	IMAGE	image_ID
	gint	component
	gint	visible

void
gimp_image_set_filename(image_ID, name)
	gint32	image_ID
	char *	name

DISPLAY
gimp_display_new(image_ID)
	IMAGE	image_ID

void
gimp_display_delete(display_ID)
	DISPLAY	display_ID

void
gimp_displays_flush()

# different calling convention (who the heck does so dumb things?)
#gint32
#gimp_layer_new(image_ID, name, width, height, type, opacity, mode)
#	gint32	image_ID
#	char *	name
#	guint	width
#	guint	height
#	GDrawableType	type
#	gdouble	opacity
#	GLayerMode	mode

#gint32
#gimp_layer_copy(layer_ID)
#	gint32	layer_ID

void
gimp_layer_delete(layer_ID)
	LAYER	layer_ID

guint
gimp_layer_width(layer_ID)
	LAYER	layer_ID

guint
gimp_layer_height(layer_ID)
	LAYER	layer_ID

guint
gimp_layer_bpp(layer_ID)
	LAYER	layer_ID

GDrawableType
gimp_layer_type(layer_ID)
	LAYER	layer_ID

void
gimp_layer_add_alpha(layer_ID)
	LAYER	layer_ID

gint32
gimp_layer_create_mask(layer_ID, mask_type)
	LAYER	layer_ID
	gint	mask_type

void
gimp_layer_resize(layer_ID, new_width, new_height, offset_x, offset_y)
	LAYER	layer_ID
	guint	new_width
	guint	new_height
	gint	offset_x
	gint	offset_y

void
gimp_layer_scale(layer_ID, new_width, new_height, local_origin)
	LAYER	layer_ID
	guint	new_width
	guint	new_height
	gint	local_origin

void
gimp_layer_translate(layer_ID, offset_x, offset_y)
	LAYER	layer_ID
	gint	offset_x
	gint	offset_y

gint
gimp_layer_is_floating_selection(layer_ID)
	LAYER	layer_ID

IMAGE
gimp_layer_get_image_id(layer_ID)
	LAYER	layer_ID

LAYER
gimp_layer_get_mask_id(layer_ID)
	LAYER	layer_ID

gint
gimp_layer_get_apply_mask(layer_ID)
	LAYER	layer_ID

gint
gimp_layer_get_edit_mask(layer_ID)
	gint32	layer_ID

GLayerMode
gimp_layer_get_mode(layer_ID)
	LAYER	layer_ID

char *
gimp_layer_get_name(layer_ID)
	LAYER	layer_ID

gdouble
gimp_layer_get_opacity(layer_ID)
	LAYER	layer_ID

gint
gimp_layer_get_preserve_transparency(layer_ID)
	LAYER	layer_ID

gint
gimp_layer_get_show_mask(layer_ID)
	LAYER	layer_ID

gint
gimp_layer_get_visible(layer_ID)
	gint32	layer_ID

void
gimp_layer_set_apply_mask(layer_ID, apply_mask)
	LAYER	layer_ID
	gint	apply_mask

void
gimp_layer_set_edit_mask(layer_ID, edit_mask)
	LAYER	layer_ID
	gint	edit_mask

void
gimp_layer_set_mode(layer_ID, mode)
	LAYER	layer_ID
	GLayerMode	mode

void
gimp_layer_set_name(layer_ID, name)
	LAYER	layer_ID
	char *	name

void
gimp_layer_set_offsets(layer_ID, offset_x, offset_y)
	LAYER	layer_ID
	gint	offset_x
	gint	offset_y

void
gimp_layer_set_opacity(layer_ID, opacity)
	LAYER	layer_ID
	gdouble	opacity

void
gimp_layer_set_preserve_transparency(layer_ID, preserve_transparency)
	LAYER	layer_ID
	gint	preserve_transparency

void
gimp_layer_set_show_mask(layer_ID, show_mask)
	LAYER	layer_ID
	gint	show_mask

void
gimp_layer_set_visible(layer_ID, visible)
	LAYER	layer_ID
	gint	visible

CHANNEL
gimp_channel_new(image_ID, name, width, height, opacity, color)
	IMAGE	image_ID
	char *	name
	guint	width
	guint	height
	gdouble	opacity
	guchar *	color

CHANNEL
gimp_channel_copy(channel_ID)
	CHANNEL	channel_ID

void
gimp_channel_delete(channel_ID)
	CHANNEL	channel_ID

guint
gimp_channel_width(channel_ID)
	CHANNEL	channel_ID

guint
gimp_channel_height(channel_ID)
	CHANNEL	channel_ID

IMAGE
gimp_channel_get_image_id(channel_ID)
	CHANNEL	channel_ID

LAYER
gimp_channel_get_layer_id(channel_ID)
	CHANNEL	channel_ID

void
gimp_channel_get_color(channel_ID, red, green, blue)
	CHANNEL	channel_ID
	guchar *	red
	guchar *	green
	guchar *	blue

char *
gimp_channel_get_name(channel_ID)
	CHANNEL	channel_ID

gdouble
gimp_channel_get_opacity(channel_ID)
	CHANNEL	channel_ID

#
# not implemented in libgimp!
#
#gint
#gimp_channel_get_show_masked(channel_ID)
#	gint32	channel_ID

gint
gimp_channel_get_visible(channel_ID)
	CHANNEL	channel_ID

#
# more orthogonality: use pdb version instead,
# which uses a d_color argument.
#
#void
#gimp_channel_set_color(channel_ID, red, green, blue)
#	gint32	channel_ID
#	guchar	red
#	guchar	green
#	guchar	blue

void
gimp_channel_set_name(channel_ID, name)
	CHANNEL	channel_ID
	char *	name

void
gimp_channel_set_opacity(channel_ID, opacity)
	CHANNEL	channel_ID
	gdouble	opacity

#
# not implemented in libgimp!
#
#void
#gimp_channel_set_show_masked(channel_ID, show_masked)
#	gint32	channel_ID
#	gint	show_masked

void
gimp_channel_set_visible(channel_ID, visible)
	CHANNEL	channel_ID
	gint	visible

GDrawable *
gimp_drawable_get(drawable_ID)
	DRAWABLE	drawable_ID

void
gimp_drawable_detach(drawable)
	GDrawable *	drawable

void
gimp_drawable_flush(drawable)
	GDrawable *	drawable

void
gimp_drawable_delete(drawable)
	GDrawable *	drawable

void
gimp_drawable_update(drawable_ID, x, y, width, height)
	DRAWABLE	drawable_ID
	gint	x
	gint	y
	guint	width
	guint	height

void
gimp_drawable_merge_shadow(drawable_ID, undoable)
	DRAWABLE	drawable_ID
	gint	undoable

IMAGE
gimp_drawable_image_id(drawable_ID)
	DRAWABLE	drawable_ID

char *
gimp_drawable_name(drawable_ID)
	DRAWABLE	drawable_ID

guint
gimp_drawable_width(drawable_ID)
	DRAWABLE	drawable_ID

guint
gimp_drawable_height(drawable_ID)
	DRAWABLE	drawable_ID

guint
gimp_drawable_bpp(drawable_ID)
	DRAWABLE	drawable_ID

GDrawableType
gimp_drawable_type(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_visible(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_channel(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_color(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_gray(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_has_alpha(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_indexed(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_layer(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_layer_mask(drawable_ID)
	DRAWABLE	drawable_ID

gint
gimp_drawable_mask_bounds(drawable_ID, x1, y1, x2, y2)
	DRAWABLE	drawable_ID
	gint *	x1
	gint *	y1
	gint *	x2
	gint *	y2

void
gimp_drawable_offsets(drawable_ID, offset_x, offset_y)
	DRAWABLE	drawable_ID
	gint *	offset_x
	gint *	offset_y

void
gimp_drawable_fill(drawable_ID, fill_type)
	DRAWABLE	drawable_ID
	gint	fill_type

void
gimp_drawable_set_name(drawable_ID, name)
	DRAWABLE	drawable_ID
	char *	name

void
gimp_drawable_set_visible(drawable_ID, visible)
	DRAWABLE	drawable_ID
	gint	visible

#GTile *
#gimp_drawable_get_tile(drawable, shadow, row, col)
#	GDrawable *	drawable
#	gint	shadow
#	gint	row
#	gint	col

#GTile *
#gimp_drawable_get_tile2(drawable, shadow, x, y)
#	GDrawable *	drawable
#	gint	shadow
#	gint	x
#	gint	y

#void
#gimp_tile_ref(tile)
#	GTile *	tile

#void
#gimp_tile_ref_zero(tile)
#	GTile *	tile

#void
#gimp_tile_unref(tile, dirty)
#	GTile *	tile
#	int	dirty

#void
#gimp_tile_flush(tile)
#	GTile *	tile

void
gimp_tile_cache_size(kilobytes)
	gulong	kilobytes

void
gimp_tile_cache_ntiles(ntiles)
	gulong	ntiles

guint
gimp_tile_width()

guint
gimp_tile_height()

#void
#gimp_pixel_rgn_init(pr, drawable, x, y, width, height, dirty, shadow)
#	GPixelRgn *	pr
#	GDrawable *	drawable
#	int	x
#	int	y
#	int	width
#	int	height
#	int	dirty
#	int	shadow

#void
#gimp_pixel_rgn_resize(pr, x, y, width, height)
#	GPixelRgn *	pr
#	int	x
#	int	y
#	int	width
#	int	height

#void
#gimp_pixel_rgn_get_pixel(pr, buf, x, y)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y

#void
#gimp_pixel_rgn_get_row(pr, buf, x, y, width)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	width

#void
#gimp_pixel_rgn_get_col(pr, buf, x, y, height)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	height

#void
#gimp_pixel_rgn_get_rect(pr, buf, x, y, width, height)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	width
#	int	height

#void
#gimp_pixel_rgn_set_pixel(pr, buf, x, y)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y

#void
#gimp_pixel_rgn_set_row(pr, buf, x, y, width)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	width

#void
#gimp_pixel_rgn_set_col(pr, buf, x, y, height)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	height

#void
#gimp_pixel_rgn_set_rect(pr, buf, x, y, width, height)
#	GPixelRgn *	pr
#	guchar *	buf
#	int	x
#	int	y
#	int	width
#	int	height

#gpointer
#gimp_pixel_rgns_register(nrgns, ...)
#	int	nrgns

#gpointer
#gimp_pixel_rgns_process(pri_ptr)
#	gpointer	pri_ptr

# use pdb equivalent
#void
#gimp_palette_get_background(red, green, blue)
#	guchar *	red
#	guchar *	green
#	guchar *	blue

# use pdb equivalent
#void
#gimp_palette_get_foreground(red, green, blue)
#	guchar *	red
#	guchar *	green
#	guchar *	blue

# use pdb equivalent
#void
#gimp_palette_set_background(red, green, blue)
#	guchar	red
#	guchar	green
#	guchar	blue

# use pdb equivalent
#void
#gimp_palette_set_foreground(red, green, blue)
#	guchar	red
#	guchar	green
#	guchar	blue

#char **
#gimp_gradients_get_list(num_gradients)
#	gint *	num_gradients

char *
gimp_gradients_get_active()

void
gimp_gradients_set_active(name)
	char *	name

#gdouble *
#gimp_gradients_sample_uniform(num_samples)
#	gint	num_samples

#gdouble *
#gimp_gradients_sample_custom(num_samples, positions)
#	gint	num_samples
#	gdouble *	positions

