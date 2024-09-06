#define HELPER_TRINARY_INVERTABLE(Fulltype, Iconbase, Node1, Node2) \
	##Fulltype {						\
		node1_concentration = Node1; 	\
		node2_concentration = Node2; 	\
		icon_state = Iconbase + "-0";	\
	}									\
	##Fulltype/inverse {				\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}									\
	##Fulltype/flipped {				\
		icon_state = Iconbase + "-0_f";	\
		flipped = TRUE;					\
	}									\
	##Fulltype/flipped/inverse {		\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}									\
	##Fulltype/layer4 {					\
		piping_layer = 4;				\
		icon_state = Iconbase + "-5";	\
	}									\
	##Fulltype/layer4/inverse {			\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}									\
	##Fulltype/layer4/flipped {			\
		icon_state = Iconbase + "-5_f";	\
		flipped = TRUE;					\
	}									\
	##Fulltype/layer4/flipped/inverse {	\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}									\
	##Fulltype/layer2 {					\
		piping_layer = 2;				\
		icon_state = Iconbase + "-1";	\
	}									\
	##Fulltype/layer2/inverse {			\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}									\
	##Fulltype/layer2/flipped {			\
		icon_state = Iconbase + "-1_f";	\
		flipped = TRUE;					\
	}									\
	##Fulltype/layer2/flipped/inverse {	\
		node1_concentration = Node2; 	\
		node2_concentration = Node1; 	\
	}

HELPER_TRINARY_INVERTABLE(/obj/machinery/atmospherics/components/trinary/mixer/airmix, "mixer_on", N2STANDARD, O2STANDARD)

#undef HELPER_TRINARY_INVERTABLE
