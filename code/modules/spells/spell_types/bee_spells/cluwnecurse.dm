/datum/action/cooldown/spell/list_target/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	cooldown_time = 300 SECONDS
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT
	target_radius = 3
	icon_icon = 'icons/obj/clothing/masks.dmi'
	button_icon_state = "cluwne"
	choose_target_message = "Choose your victim"

/// Get a list of living targets in radius of the center to put in the target list.
/datum/action/cooldown/spell/list_target/cluwnecurse/get_list_targets(atom/center, target_radius = 7)
	var/list/things = list()
	for(var/mob/living/carbon/nearby_living_carbon in view(target_radius, center))
		if(nearby_living_carbon == owner || nearby_living_carbon == center)
			continue

		things += nearby_living_carbon

	return things

/datum/action/cooldown/spell/list_target/cluwnecurse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	cast_on.cluwneify()

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /datum/action/cooldown/spell/list_target/cluwnecurse
