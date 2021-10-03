/datum/action/changeling/digitalcamo
	name = "Digital Camouflage"
	desc = "By evolving the ability to distort our form and proportions, we defeat common algorithms used to detect lifeforms on cameras."
	helptext = "We cannot be tracked by camera or seen by AI units while using this skill. However, humans looking at us will find us... uncanny."
	button_icon_state = "digital_camo"
	dna_cost = 1

//Prevents AIs tracking you but makes you easily detectable to the human-eye.
/datum/action/changeling/digitalcamo/sting_action(mob/user)
	..()
	if(HAS_TRAIT(user,TRAIT_DIGICAMO))
		to_chat(user, "<span class='notice'>We return to normal.</span>")
		REMOVE_TRAIT(user, TRAIT_DIGICAMO, CHANGELING_TRAIT)
		REMOVE_TRAIT(user, TRAIT_DIGINVIS, CHANGELING_TRAIT)
	else
		to_chat(user, "<span class='notice'>We distort our form to hide from the AI.</span>")		
		ADD_TRAIT(user, TRAIT_DIGICAMO, CHANGELING_TRAIT)		
		ADD_TRAIT(user, TRAIT_DIGINVIS, CHANGELING_TRAIT)
	return TRUE

/datum/action/changeling/digitalcamo/Remove(mob/user)
	REMOVE_TRAIT(user, TRAIT_DIGICAMO, CHANGELING_TRAIT)
	REMOVE_TRAIT(user, TRAIT_DIGINVIS, CHANGELING_TRAIT)
	..()
