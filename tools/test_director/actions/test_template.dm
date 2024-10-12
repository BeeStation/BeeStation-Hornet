
/datum/unit_test/TEST_NAME/Run()
	var/mob/living/carbon/human/player = allocate(/mob/living/carbon/human/consistent)
	TEST_ITERATORS
	try
		TEST_CODE
	catch (exception/e)
		TEST_FAIL("Test TEST_NAME threw an exception during exception and failed. [E.name] ([E.file]:[E.line])\n[E.desc]")
