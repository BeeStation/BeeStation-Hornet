/obj/item/overthrow_converter // nearly equal to an implanter, as an object
	name = "agent activation implant"
	desc = "Wakes up syndicate sleeping agents."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "implanter1"
	item_state = "syringe_0"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	throw_speed = 3
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	materials = list(/datum/material/iron = 600, /datum/material/glass = 200)
	var/uses = 2

/obj/item/overthrow_converter/proc/convert(mob/living/carbon/human/target, mob/living/carbon/human/user) // Should probably also delete any mindshield implant. Not sure.
	if(istype(target) && target.mind && user && user.mind)
		var/datum/mind/target_mind = target.mind
		var/datum/mind/user_mind = user.mind
		var/datum/antagonist/overthrow/TO = target_mind.has_antag_datum(/datum/antagonist/overthrow)
		var/datum/antagonist/overthrow/UO = user_mind.has_antag_datum(/datum/antagonist/overthrow)
		if(!UO)
			to_chat(user, span_danger("You don't know how to use this thing!")) // It needs a valid team to work, if you aren't an antag don't use this thing
			return FALSE
		if(TO)
			to_chat(user, span_notice("[target.name] woke up already, the implant would be ineffective against him!"))
			return FALSE
		target_mind.add_antag_datum(/datum/antagonist/overthrow, UO.team)
		log_combat(user, target, "implanted", "\a [name]")
		return TRUE

/obj/item/overthrow_converter/attack(mob/living/carbon/human/M, mob/living/carbon/human/user)
	if(!istype(M) || !istype(user))
		return
	if(!uses)
		to_chat(user,span_warning("The converter is empty!"))
		return
	if(M == user)
		to_chat(user,span_warning("You cannot convert yourself!"))
		return
	if(HAS_TRAIT(M, TRAIT_MINDSHIELD))
		to_chat(user, span_danger("This mind is too strong to convert, try to remove whatever is protecting it first!"))
		return
	M.visible_message(span_warning("[user] is attempting to implant [M]."))
	if(do_mob(user, M, 50))
		if(convert(M,user))
			M.visible_message("[user] has implanted [M].", span_notice("[user] implants you."))
			uses--
			update_icon()
		else
			to_chat(user, span_warning("[user] fails to implant [M]."))

/obj/item/overthrow_converter/update_icon()
	if(uses)
		icon_state = "implanter1"
	else
		icon_state = "implanter0"
