///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, list(
	"green" = COLOR_LIME,
	"blue" = COLOR_BLUE,
	"red" = COLOR_RED,
	"orange" = COLOR_ORANGE,
	"cyan" = COLOR_CYAN,
	"dark" = COLOR_BLACK,
	"yellow" = COLOR_YELLOW,
	"brown" = COLOR_DARK_BROWN,
	"pink" = COLOR_PINK,
	"purple" = COLOR_PURPLE,
	"violet" = COLOR_MAGENTA,
	"gray" = COLOR_SILVER
))

///Names shown in the examine for every colored atmos component
GLOBAL_LIST_INIT(pipe_color_name, sort_list(list(
	COLOR_SILVER = "gray",
	COLOR_BLUE = "blue",
	COLOR_RED = "red",
	COLOR_LIME = "green",
	COLOR_ORANGE = "orange",
	COLOR_CYAN = "cyan",
	COLOR_BLACK = "dark",
	COLOR_YELLOW = "yellow",
	COLOR_DARK_BROWN = "brown",
	COLOR_PINK = "pink",
	COLOR_PURPLE = "purple",
	COLOR_MAGENTA = "violet"
)))
