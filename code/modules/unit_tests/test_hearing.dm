
/*
 * Test hearing
 *
 * Will create 2 dummy listener mobs, 1 in darkness and 1 in light.
 * Will run get_hear and get_hearers_in_view and validate that the mobs
 * can hear the speaker
 */

#if defined(UNIT_TESTS)

GLOBAL_VAR_INIT(hearer_light_test_passed, FALSE)
GLOBAL_VAR_INIT(hearer_dark_test_passed, FALSE)

/datum/unit_test/test_hearing/Run()
	//Clear out a random area near the base of the world
	for(var/turf/T in block(locate(3, 3, 1), locate(9, 9, 1)))
		T.ChangeTurf(/turf/open/floor/plating, flags = CHANGETURF_INHERIT_AIR)
		//Set the turfs to unlit
		T.luminosity = 0

	//Create the dark listener
	new /obj/listener/dark(locate(3, 6, 1))

	//Create the light listener
	var/turf/light_turf = locate(9, 6, 1)
	light_turf.luminosity = 1
	new /obj/listener/light(light_turf)

	//Have something speak
	var/turf/speaking_turf = locate(6, 6, 1)
	speaking_turf.say("test")

	//Reset the area
	for(var/turf/T in block(locate(3, 3, 1), locate(9, 9, 1)))
		T.ChangeTurf(/turf/open/space/basic, flags = CHANGETURF_INHERIT_AIR)
	//Reset the light turf
	light_turf.luminosity = 0

	//Sleep slightly to be safe
	sleep(5)

	//Assert tests
	if(!GLOB.hearer_light_test_passed)
		Fail("Hearing test failed, listener failed to hear any messages!")
	if(!GLOB.hearer_dark_test_passed)
		Fail("Hearing test failed, listener failed to hear any messages while in the dark!")

/obj/listener/dark/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(message == "test")
		GLOB.hearer_dark_test_passed = TRUE

/obj/listener/light/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	if(message == "test")
		GLOB.hearer_light_test_passed = TRUE

#endif
