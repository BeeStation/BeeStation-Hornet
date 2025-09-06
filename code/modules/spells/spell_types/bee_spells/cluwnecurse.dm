/datum/action/spell/pointed/cluwnecurse
	name = "Curse of the Cluwne"
	desc = "This spell dooms the fate of any unlucky soul to the live of a pitiful cluwne, a terrible creature that is hunted for fun."
	school = "transmutation"
	cooldown_time = 60 SECONDS
	invocation = "CLU WO'NIS CA'TE'BEST'IS MAXIMUS!"
	invocation_type = INVOCATION_SHOUT
	cast_range = 3
	button_icon = 'icons/obj/clothing/masks.dmi'
	ranged_mousepointer = 'icons/effects/mouse_pointers/cluwne.dmi'
	button_icon_state = "cluwne"

/datum/action/spell/pointed/cluwnecurse/is_valid_spell(mob/user, atom/target)
	return ..() && istype(target, /mob/living/carbon)

/datum/action/spell/pointed/cluwnecurse/on_cast(mob/user, mob/living/carbon/target)
	. = ..()
	if(target.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY|MAGIC_RESISTANCE_MIND))
		return
	target.cluwneify()

/datum/spellbook_entry/cluwnecurse
	name = "Cluwne Curse"
	spell_type = /datum/action/spell/pointed/cluwnecurse
