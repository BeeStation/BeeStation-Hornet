#if defined(UNIT_TESTS) || defined(SPACEMAN_DMM)

/// Builds (and returns) a list of atoms that we shouldn't initialize in generic testing, like Create and Destroy.
/// It is appreciated to add the reason why the atom shouldn't be initialized if you add it to this list.
/datum/unit_test/proc/build_list_of_uncreatables()
	RETURN_TYPE(/list)
	var/list/output = list()
	for (var/type in subtypesof(/datum/ignore_type))
		var/datum/ignore_type/temp = new type()
		temp.add_ignores(output)
	return output

// Extension procs crash byond with enough of them due to stack overflows, this allows us to do it
// without traversing the stack
/datum/ignore_type/proc/add_ignores(list/target)
	return

#define CREATION_TEST_IGNORE_SELF(path) /datum/ignore_type##path/add_ignores(list/target) {\
	target += path;\
}

#define CREATION_TEST_IGNORE_SUBTYPES(path) /datum/ignore_type##path/add_ignores(list/target) {\
	target += typesof(path);\
}

// Annoyingly, dview is defined inside of _DEFINES, so we are doing it here
CREATION_TEST_IGNORE_SELF(/mob/dview)

#else

#define CREATION_TEST_IGNORE_SELF(path) ;

#define CREATION_TEST_IGNORE_SUBTYPES(path) ;

#endif
