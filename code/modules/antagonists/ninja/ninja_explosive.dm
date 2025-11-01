/**
 * # Spider Charge
 *
 * A unique version of c4 possessed only by the space ninja. Has a stronger blast radius.
 * Can only be detonated by space ninjas with the bombing objective. Can only be set up where the objective says it can.
 * When it primes, the space ninja responsible will have their objective set to complete.
 *
 */
/obj/item/grenade/plastic/ninja
	name = "spider charge"
	desc = "A modified C-4 charge supplied by the Spider Clan. It has great explosive power, but is keyed to only work in one specific area."
	icon_state = "ninja-explosive0"
	inhand_icon_state = "ninja-explosive"
	boom_sizes = list(4, 8, 12)
	///Weakref to the mob that has planted the charge
	var/datum/weakref/detonator
	///The only area that the charge is allowed to be planted, and detonated in (defaulting to space)
	var/area/detonation_area = /area/space/nearstation

/obj/item/grenade/plastic/ninja/Destroy()
	detonator = null
	detonation_area = null
	return ..()

/obj/item/grenade/plastic/ninja/examine(mob/user)
	. = ..()
	if (!IS_SPACE_NINJA(user))
		return
	if (isnull(detonation_area))
		. += span_notice("This one was provided with no destination set, and cannot be used.")
	else
		. += span_notice("This device will only function in [detonation_area].")

/**
 * set_detonation_area
 *
 * Proc used to set the allowed location for charge detonation
 *
 * Arguments
 * * datum/antagonist/ninja/ninja_antag - The antag datum for the owner of the c4
 */
/obj/item/grenade/plastic/ninja/proc/set_detonation_area(datum/antagonist/ninja/ninja_antag)
	if (!ninja_antag)
		return
	var/datum/objective/plant_explosive/objective = locate() in ninja_antag.objectives
	if (!objective)
		return
	detonation_area = objective.detonation_location

/obj/item/grenade/plastic/ninja/afterattack(atom/movable/target, mob/ninja, flag)
	if(!IS_SPACE_NINJA(ninja))
		say("Access denied.")
		return
	if (!check_loc(ninja))
		return
	detonator = WEAKREF(ninja)
	return ..()

/obj/item/grenade/plastic/ninja/prime(mob/living/lanced_by)
	if(!check_loc(detonator.resolve())) // if its moved, deactivate the c4
		var/obj/item/grenade/plastic/ninja/new_c4 = new /obj/item/grenade/plastic/ninja(target.loc)
		new_c4.detonation_area = detonation_area
		new_c4.say("Invalid location!")
		target.cut_overlay(plastic_overlay, TRUE)
		qdel(src)
		return
	//Since we already did the checks in afterattack, the detonator must be a ninja with the bomb objective.
	if(isnull(detonator))
		return
	var/mob/ninja = detonator.resolve()
	. = ..()
	if(!.)
		return
	if (isnull(ninja))
		return

/**
 * check_loc
 *
 * Checks to see if the c4 is in the correct place when being planted.
 *
 * Arguments
 * * mob/user - The planter of the c4
 */
/obj/item/grenade/plastic/ninja/proc/check_loc(mob/user)
	if(isnull(detonation_area))
		balloon_alert(user, "no location set!")
		return FALSE
	if((get_area(target) != detonation_area) && (get_area(src) != detonation_area))
		if (!active)
			balloon_alert(user, "wrong location!")
		return FALSE
	return TRUE
