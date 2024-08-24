#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

#define CREATION_TEST_IGNORE_SELF(path)/datum/unit_test/build_list_of_uncreatables() {\
	. = ..();\
	. += path;\
}

#define CREATION_TEST_IGNORE_SUBTYPES(path)/datum/unit_test/build_list_of_uncreatables() {\
	. = ..();\
	. += typesof(path);\
}

#else

#define CREATION_TEST_IGNORE_SELF(path)

#define CREATION_TEST_IGNORE_SUBTYPES(path)

#endif
