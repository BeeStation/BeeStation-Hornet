/datum/action/cooldown/spell/pointed/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	cooldown_time = 300 SECONDS
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT
	cast_range = 3
	icon_icon = 'icons/obj/clothing/masks.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/cluwne.dmi'
	button_icon_state = "cluwne"

/datum/action/cooldown/spell/list_target/cluwnecurse/cast(mob/living/carbon/human/cast_on)
	. = ..()
	if(cast_on == owner)
		if(tgui_alert(usr, "Are you sure you want to curse yourself to become a cluwne?", "Fool's choice", list("Yes!", "No...")) == "Yes")
			cast_on.cluwneify()

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /datum/action/cooldown/spell/list_target/cluwnecurse
