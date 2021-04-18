/mob/living/carbon/human/verb/Give()
	var/mob/living/carbon/C = src
	C.give()

/mob/living/carbon/human/CtrlShiftClickOn()
    ..()
    Give()
