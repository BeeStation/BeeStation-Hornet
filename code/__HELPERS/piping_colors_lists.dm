///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, list(
	"green" = COLOR_VIBRANT_LIME,
	"blue" = COLOR_BLUE,
	"red" = COLOR_RED,
	"orange" = COLOR_TAN_ORANGE,
	"cyan" = COLOR_CYAN,
	"dark" = COLOR_DARK,
	"yellow" = COLOR_YELLOW,
	"brown" = COLOR_DARK_BROWN,
	"pink" = COLOR_LIGHT_PINK,
	"purple" = COLOR_PURPLE,
	"violet" = COLOR_STRONG_VIOLET,
	"gray" = COLOR_VERY_LIGHT_GRAY
))

///Names shown in the examine for every colored atmos component
GLOBAL_LIST_INIT(pipe_color_name, sort_list(list(
	COLOR_VERY_LIGHT_GRAY = "gray",
	COLOR_BLUE = "blue",
	COLOR_RED = "red",
	COLOR_VIBRANT_LIME = "green",
	COLOR_TAN_ORANGE = "orange",
	COLOR_CYAN = "cyan",
	COLOR_DARK = "dark",
	COLOR_YELLOW = "yellow",
	COLOR_DARK_BROWN = "brown",
	COLOR_LIGHT_PINK = "pink",
	COLOR_PURPLE = "purple",
	COLOR_STRONG_VIOLET = "violet"
)))
