
/mob/living/carbon/human/Stun(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Knockdown(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	return ..()

/mob/living/carbon/human/Paralyze(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Immobilize(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src, amount)
	return ..()

/mob/living/carbon/human/Unconscious(amount, ignore_canstun = FALSE)
	amount = dna.species.spec_stun(src,amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/Sleeping(amount)
	if(HAS_TRAIT(src, TRAIT_HEAVY_SLEEPER))
		amount *= rand(1.25, 1.3)
	return ..()

/mob/living/carbon/human/cure_husk(list/sources)
	. = ..()
	if(.)
		update_body_parts()

/mob/living/carbon/human/become_husk(source)
	if(HAS_TRAIT(src, TRAIT_NOHUSK))
		cure_husk()
		return
	. = ..()
	if(.)
		update_body_parts()

/mob/living/carbon/human/set_drugginess(amount)
	..()
	if(!amount)
		remove_language(/datum/language/beachbum, source = LANGUAGE_DRUGGY)

/mob/living/carbon/human/adjust_drugginess(amount)
	..()
	if(!dna.check_mutation(/datum/mutation/stoner))
		if(druggy)
			grant_language(/datum/language/beachbum, source = LANGUAGE_DRUGGY)
		else
			remove_language(/datum/language/beachbum, source = LANGUAGE_DRUGGY)
