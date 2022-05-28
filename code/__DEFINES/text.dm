/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

#define WXH_TO_WIDTH(x) text2num(copytext(x, 1, findtextEx(x, "x") + 1))

#define CENTER(text) {"<center>[##text]</center>"}

#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

/// Index of normal sized character size in runechat lists
#define NORMAL_FONT_INDEX 1

/// Index of small sized character size in runechat lists
#define SMALL_FONT_INDEX 2

/// Index of big sized character size in runechat lists
#define BIG_FONT_INDEX 3

/// Index of maximum possible calculated values
#define MAX_CHAR_WIDTH "max_width"

/// Initializes empty list of cache characters for runechat. Space is special case since measuring it returns 0.
#define EMPTY_CHARACTERS_LIST list(\
		"." = null,\
		"," = null,\
		"?" = null,\
		"!" = null,\
		"\"" = null,\
		"/" = null,\
		"$" = null,\
		"(" = null,\
		")" = null,\
		"@" = null,\
		"=" = null,\
		":" = null,\
		"'" = null,\
		";" = null,\
		"+" = null,\
		"-" = null,\
		"\\" = null,\
		"<" = null,\
		">" = null,\
		"&" = null,\
		"*" = null,\
		"%" = null,\
		"#" = null,\
		"^" = null,\
		"{" = null,\
		"}" = null,\
		"|" = null,\
		"~" = null,\
		"`" = null,\
		"[" = null,\
		"]" = null,\
		"A" = null,\
		"B" = null,\
		"C" = null,\
		"D" = null,\
		"E" = null,\
		"F" = null,\
		"G" = null,\
		"H" = null,\
		"I" = null,\
		"J" = null,\
		"K" = null,\
		"L" = null,\
		"M" = null,\
		"N" = null,\
		"O" = null,\
		"P" = null,\
		"Q" = null,\
		"R" = null,\
		"S" = null,\
		"T" = null,\
		"U" = null,\
		"V" = null,\
		"W" = null,\
		"X" = null,\
		"Y" = null,\
		"Z" = null,\
		"a" = null,\
		"b" = null,\
		"c" = null,\
		"d" = null,\
		"e" = null,\
		"f" = null,\
		"g" = null,\
		"h" = null,\
		"i" = null,\
		"j" = null,\
		"k" = null,\
		"l" = null,\
		"m" = null,\
		"n" = null,\
		"o" = null,\
		"p" = null,\
		"q" = null,\
		"r" = null,\
		"s" = null,\
		"t" = null,\
		"u" = null,\
		"v" = null,\
		"w" = null,\
		"x" = null,\
		"y" = null,\
		"z" = null,\
		"0" = null,\
		"1" = null,\
		"2" = null,\
		"3" = null,\
		"4" = null,\
		"5" = null,\
		"6" = null,\
		"7" = null,\
		"8" = null,\
		"9" = null,\
		MAX_CHAR_WIDTH = list(0, 0, 0)\
	)
