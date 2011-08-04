
/******************************************************************************
* MODULE     : vars.hpp
* DESCRIPTION: environment variables for typesetting
* COPYRIGHT  : (C) 1999  Joris van der Hoeven
*******************************************************************************
* This software falls under the GNU general public license version 3 or later.
* It comes WITHOUT ANY WARRANTY WHATSOEVER. For details, see the file LICENSE
* in the root directory or <http://www.gnu.org/licenses/gpl-3.0.html>.
******************************************************************************/

#ifndef VARS_H
#define VARS_H
#include "string.hpp"

/******************************************************************************
* System environment variables
******************************************************************************/

extern string DPI;
extern string SFACTOR;
extern string PREAMBLE;
extern string SAVE_AUX;
extern string MODE;
extern string INFO_FLAG;
extern string WINDOW_BARS;
extern string SCROLL_BARS;
extern string IDENTITY;
extern string TABULAR;
extern string THE_LABEL;
extern string THE_TAGS;
extern string THE_MODULES;

extern string FONT;
extern string FONT_FAMILY;
extern string FONT_SERIES;
extern string FONT_SHAPE;
extern string FONT_SIZE;
extern string FONT_BASE_SIZE;
extern string MAGNIFICATION;
extern string COLOR;
extern string BG_COLOR;
extern string LOCUS_COLOR;
extern string VISITED_COLOR;
extern string LANGUAGE;
extern string ATOM_DECORATIONS;
extern string LINE_DECORATIONS;
extern string PAGE_DECORATIONS;
extern string XOFF_DECORATIONS;
extern string YOFF_DECORATIONS;

extern string MATH_LANGUAGE;
extern string MATH_FONT;
extern string MATH_FONT_FAMILY;
extern string MATH_FONT_SERIES;
extern string MATH_FONT_SHAPE;
extern string MATH_LEVEL;
extern string MATH_DISPLAY;
extern string MATH_CONDENSED;
extern string MATH_VPOS;
extern string MATH_NESTING_MODE;
extern string MATH_NESTING_LEVEL;

extern string PROG_LANGUAGE;
extern string PROG_SCRIPTS;
extern string PROG_FONT;
extern string PROG_FONT_FAMILY;
extern string PROG_FONT_SERIES;
extern string PROG_FONT_SHAPE;
extern string PROG_SESSION;

extern string PAR_MODE;
extern string PAR_FLEXIBILITY;
extern string PAR_HYPHEN;
extern string PAR_WIDTH;
extern string PAR_LEFT;
extern string PAR_RIGHT;
extern string PAR_FIRST;
extern string PAR_NO_FIRST;
extern string PAR_SEP;
extern string PAR_HOR_SEP;
extern string PAR_VER_SEP;
extern string PAR_LINE_SEP;
extern string PAR_PAR_SEP;
extern string PAR_FNOTE_SEP;
extern string PAR_COLUMNS;
extern string PAR_COLUMNS_SEP;

extern string PAGE_MEDIUM;
extern string PAGE_PRINTED;
extern string PAGE_TYPE;
extern string PAGE_ORIENTATION;
extern string PAGE_WIDTH_MARGIN;
extern string PAGE_HEIGHT_MARGIN;
extern string PAGE_SCREEN_MARGIN;
extern string PAGE_BREAKING;
extern string PAGE_FLEXIBILITY;
extern string PAGE_NR;
extern string PAGE_THE_PAGE;
extern string PAGE_WIDTH;
extern string PAGE_HEIGHT;
extern string PAGE_ODD;
extern string PAGE_EVEN;
extern string PAGE_RIGHT;
extern string PAGE_ODD_SHIFT;
extern string PAGE_EVEN_SHIFT;
extern string PAGE_TOP;
extern string PAGE_BOT;
extern string PAGE_USER_HEIGHT;
extern string PAGE_SHRINK;
extern string PAGE_EXTEND;
extern string PAGE_HEAD_SEP;
extern string PAGE_FOOT_SEP;
extern string PAGE_ODD_HEADER;
extern string PAGE_ODD_FOOTER;
extern string PAGE_EVEN_HEADER;
extern string PAGE_EVEN_FOOTER;
extern string PAGE_THIS_HEADER;
extern string PAGE_THIS_FOOTER;
extern string PAGE_SCREEN_WIDTH;
extern string PAGE_SCREEN_HEIGHT;
extern string PAGE_SCREEN_LEFT;
extern string PAGE_SCREEN_RIGHT;
extern string PAGE_SCREEN_TOP;
extern string PAGE_SCREEN_BOT;
extern string PAGE_SHOW_HF;
extern string PAGE_FNOTE_SEP;
extern string PAGE_FNOTE_BARLEN;
extern string PAGE_FLOAT_SEP;
extern string PAGE_MNOTE_SEP;
extern string PAGE_MNOTE_WIDTH;

extern string TABLE_WIDTH;
extern string TABLE_HEIGHT;
extern string TABLE_HMODE;
extern string TABLE_VMODE;
extern string TABLE_HALIGN;
extern string TABLE_VALIGN;
extern string TABLE_ROW_ORIGIN;
extern string TABLE_COL_ORIGIN;
extern string TABLE_LSEP;
extern string TABLE_RSEP;
extern string TABLE_BSEP;
extern string TABLE_TSEP;
extern string TABLE_LBORDER;
extern string TABLE_RBORDER;
extern string TABLE_BBORDER;
extern string TABLE_TBORDER;
extern string TABLE_HYPHEN;
extern string TABLE_MIN_ROWS;
extern string TABLE_MIN_COLS;
extern string TABLE_MAX_ROWS;
extern string TABLE_MAX_COLS;

extern string CELL_FORMAT;
extern string CELL_DECORATION;
extern string CELL_BACKGROUND;
extern string CELL_ORIENTATION;
extern string CELL_WIDTH;
extern string CELL_HEIGHT;
extern string CELL_HPART;
extern string CELL_VPART;
extern string CELL_HMODE;
extern string CELL_VMODE;
extern string CELL_HALIGN;
extern string CELL_VALIGN;
extern string CELL_LSEP;
extern string CELL_RSEP;
extern string CELL_BSEP;
extern string CELL_TSEP;
extern string CELL_LBORDER;
extern string CELL_RBORDER;
extern string CELL_BBORDER;
extern string CELL_TBORDER;
extern string CELL_ROW_SPAN;
extern string CELL_COL_SPAN;
extern string CELL_VCORRECT;
extern string CELL_HYPHEN;
extern string CELL_BLOCK;
extern string CELL_ROW_NR;
extern string CELL_COL_NR;

extern string POINT_STYLE;
extern string LINE_WIDTH;
extern string DASH_STYLE;
extern string DASH_STYLE_UNIT;
extern string LINE_ARROWS;
extern string LINE_CAPS;
extern string FILL_COLOR;
extern string FILL_STYLE;
extern string TEXTAT_HALIGN;
extern string TEXTAT_VALIGN;

extern string GR_GEOMETRY;
extern string GR_FRAME;
extern string GR_MODE;
extern string GR_COLOR;
extern string GR_POINT_STYLE;
extern string GR_LINE_WIDTH;
extern string GR_DASH_STYLE;
extern string GR_DASH_STYLE_UNIT;
extern string GR_LINE_ARROWS;
extern string GR_FILL_COLOR;
extern string GR_TEXTAT_HALIGN;
extern string GR_TEXTAT_VALIGN;
extern string GR_GRID;
extern string GR_GRID_ASPECT;
extern string GR_EDIT_GRID;
extern string GR_EDIT_GRID_ASPECT;

extern string SRC_STYLE;
extern string SRC_SPECIAL;
extern string SRC_COMPACT;
extern string SRC_CLOSE;

extern string CANVAS_TYPE;
extern string CANVAS_COLOR;
extern string CANVAS_HPADDING;
extern string CANVAS_VPADDING;
extern string CANVAS_BAR_WIDTH;
extern string CANVAS_BAR_PADDING;
extern string CANVAS_BAR_COLOR;
extern string ORNAMENT_SHAPE;
extern string ORNAMENT_BORDER;
extern string ORNAMENT_HPADDING;
extern string ORNAMENT_VPADDING;
extern string ORNAMENT_COLOR;
extern string ORNAMENT_SUNNY_COLOR;
extern string ORNAMENT_SHADOW_COLOR;

#endif // defined VARS_H
