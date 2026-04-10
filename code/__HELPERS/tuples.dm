/**
 * Tuple types are basic types that hold data.
 * It is a shorthand for creating basic types.
 */

#define NAMED_TUPLE_1(NAME, TYPEA, NAMEA) /datum/##NAME {\
	##TYPEA/##NAMEA;\
}\
/datum/##NAME/New(...) {\
	src.##NAMEA = args[1];\
}

#define NAMED_TUPLE_2(NAME, TYPEA, NAMEA, TYPEB, NAMEB) /datum/##NAME {\
	##TYPEA/##NAMEA;\
	##TYPEB/##NAMEB;\
}\
/datum/##NAME/New(...) {\
	src.##NAMEA = args[1];\
	src.##NAMEB = args[2];\
}
