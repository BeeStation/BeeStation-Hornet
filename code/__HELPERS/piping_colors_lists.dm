///All colors available to pipes and atmos components
GLOBAL_LIST_INIT(pipe_paint_colors, list(
		"amethyst" = COLOR_AMETHYST, //supplymain
		"blue" = COLOR_BLUE,
		"brown" = COLOR_PIPE_BROWN,
		"cyan" = COLOR_CYAN,
		"dark" = COLOR_DARK,
		"green" = COLOR_LIME,
		"grey" = COLOR_GREY,
		"orange" = COLOR_MOSTLY_PURE_ORANGE,
		"purple" = COLOR_MAGENTA,
		"red" = COLOR_MOSTLY_PURE_RED,
		"violet" = COLOR_VIOLET,
		"yellow" = COLOR_LIGHT_ORANGE
))

///Names shown in the examine for every colored atmos component
GLOBAL_LIST_INIT(pipe_color_name, sort_list(list(
	COLOR_GREY = "grey",
	COLOR_BLUE = "blue",
	COLOR_MOSTLY_PURE_RED = "red",
	COLOR_LIME = "green",
	COLOR_MOSTLY_PURE_ORANGE = "orange",
	COLOR_CYAN = "cyan",
	COLOR_DARK = "dark",
	COLOR_LIGHT_ORANGE = "yellow",
	COLOR_PIPE_BROWN = "brown",
	COLOR_LIGHT_PINK = "pink",
	COLOR_MAGENTA = "purple",
	COLOR_VIOLET = "violet"
)))
