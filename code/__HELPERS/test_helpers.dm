#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Builds (and returns) a list of atoms that we shouldn't initialize in generic testing, like Create and Destroy.
/// It is appreciated to add the reason why the atom shouldn't be initialized if you add it to this list.
/datum/unit_test/proc/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	return list()

#define CREATION_TEST_IGNORE_SELF(path)/datum/unit_test/build_list_of_uncreatables() {\
	. = ..();\
	. += path;\
}

#define CREATION_TEST_IGNORE_SUBTYPES(path)/datum/unit_test/build_list_of_uncreatables() {\
	. = ..();\
	. += typesof(path);\
}

// Annoyingly, dview is defined inside of _DEFINES, so we are doing it here
CREATION_TEST_IGNORE_SELF(/mob/dview)

#else

#define CREATION_TEST_IGNORE_SELF(path)

#define CREATION_TEST_IGNORE_SUBTYPES(path)

#endif
