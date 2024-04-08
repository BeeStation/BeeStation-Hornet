//Colored pipes, use these for mapping

#define HELPER_PARTIAL(Fulltype, Type, Iconbase, Color) \
	##Fulltype {						\
		pipe_color = Color;				\
		color = Color;					\
	}									\
	##Fulltype/visible {				\
		hide = FALSE; 					\
		layer = GAS_PIPE_VISIBLE_LAYER;	\
		FASTDMM_PROP(pipe_group = "atmos-[piping_layer]-"+Type+"-visible");\
	}									\
	##Fulltype/visible/layer2 {			\
		piping_layer = 2;				\
		icon_state = Iconbase + "-2";	\
	}									\
	##Fulltype/visible/layer4 {			\
		piping_layer = 4;				\
		icon_state = Iconbase + "-4";	\
	}									\
	##Fulltype/hidden {					\
		hide = TRUE;					\
	}									\
	##Fulltype/hidden/layer2 {			\
		piping_layer = 2;				\
		icon_state = Iconbase + "-2";	\
	}									\
	##Fulltype/hidden/layer4 {			\
		piping_layer = 4;				\
		icon_state = Iconbase + "-4";	\
	}

#define HELPER_PARTIAL_NAMED(Fulltype, Type, Iconbase, Color, Name) \
	HELPER_PARTIAL(Fulltype, Type, Iconbase, Color)	\
	##Fulltype {								\
		name = Name;							\
	}

#define HELPER(Type, Color) \
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/simple/##Type, #Type, "pipe11", Color) 		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold/##Type, #Type, "manifold", Color)		\
	HELPER_PARTIAL(/obj/machinery/atmospherics/pipe/manifold4w/##Type, #Type, "manifold4w", Color)

#define HELPER_NAMED(Type, Name, Color) \
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/simple/##Type, #Type, "pipe11", Color, Name) 		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold/##Type, #Type, "manifold", Color, Name)		\
	HELPER_PARTIAL_NAMED(/obj/machinery/atmospherics/pipe/manifold4w/##Type, #Type, "manifold4w", Color, Name)

HELPER(general, null)
HELPER(yellow, rgb(255, 198, 0))
HELPER(cyan, rgb(0, 255, 249))
HELPER(green, rgb(30, 255, 0))
HELPER(orange, rgb(255, 129, 25))
HELPER(purple, rgb(128, 0, 182))
HELPER(dark, rgb(69, 69, 69))
HELPER(brown, rgb(178, 100, 56))
HELPER(violet, rgb(64, 0, 128))
HELPER(amethyst, rgb(130, 43, 255))

HELPER_NAMED(scrubbers, "scrubbers pipe", rgb(255, 0, 0))
HELPER_NAMED(supply, "air supply pipe", rgb(0, 0, 255))

#undef HELPER_NAMED
#undef HELPER
#undef HELPER_PARTIAL_NAMED
#undef HELPER_PARTIAL
