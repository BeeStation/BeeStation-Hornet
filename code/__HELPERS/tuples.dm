/**
 * Tuple types are basic types that hold data.
 * It is a shorthand for creating basic types.
 * This can be simplified with pointers.
 */

#define NAMED_TUPLE_1(NAME, TYPE_1, NAME_1) /datum/##NAME {\
	##TYPE_1/##NAME_1;\
}\
/datum/##NAME/New(...) {\
	src.##NAME_1 = args[1];\
}

#define NAMED_TUPLE_2(NAME, TYPE_1, NAME_1, TYPE_2, NAME_2) /datum/##NAME {\
	##TYPE_1/##NAME_1;\
	##TYPE_2/##NAME_2;\
}\
/datum/##NAME/New(...) {\
	src.##NAME_1 = args[1];\
	src.##NAME_2 = args[2];\
}
