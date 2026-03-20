/datum/action/item_action/delimbing_strike
	name = "Dismembering Strike"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	COOLDOWN_DECLARE(strike_cd)
	var/strike_cooldown_time = 45 SECONDS

/datum/action/item_action/delimbing_strike/is_available(feedback = FALSE)
	return ..() && istype(owner.get_active_held_item(), /obj/item/energy_katana) && COOLDOWN_FINISHED(src, strike_cd)

/datum/action/item_action/delimbing_strike/do_effect(trigger_flags)
	. = ..()
	if (target == null)
		return FALSE
	owner.visible_message(span_warning("[owner] prepares to attack!"))
	var/mob/living/carbon/human/owner_mob = owner
	// We only delimb if we are the ninja
	var/delimbs = FALSE
	if (istype(owner_mob))
		var/obj/item/mod/control/pre_equipped/ninja/ninja_suit = owner_mob.back
		if (istype(ninja_suit) && ninja_suit.active)
			delimbs = TRUE
	// Get the direction to the clicked target
	var/direction = get_cardinal_dir(owner, target)
	var/obj/effect/temp_visual/slash/slash = new /obj/effect/temp_visual/slash(get_step(owner, SOUTHWEST))
	slash.dir = direction
	playsound(owner, 'sound/weapons/fwoosh.ogg', 100, TRUE)
	// Stop them for the duration of the slash effect
	var/mob/living/living_owner = owner
	if(istype(living_owner))
		living_owner.Immobilize(4)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(owner, direction | turn_cardinal(direction, -90)), owner, delimbs), 1)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(owner, direction), owner, delimbs), 2)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(owner, direction | turn_cardinal(direction, 90)), owner, delimbs), 3)
	owner.client?.give_cooldown_cursor(2 SECONDS)
	owner.changeNext_move(2 SECONDS)
	// Clear cloak when attacking
	if(istype(living_owner))
		living_owner.remove_status_effect(/datum/status_effect/cloaked)
	COOLDOWN_START(src, strike_cd, strike_cooldown_time)
	return TRUE

/datum/action/item_action/delimbing_strike/proc/deal_strike(turf/hit_turf, mob/living/user, delimbs)
	var/obj/item/attacking_item = target
	for (var/mob/living/living_target in hit_turf)
		// Somehow pushed onto it
		if (living_target == user)
			continue
		if (delimbs)
			var/obj/item/bodypart/part = living_target.get_active_hand()
			if (part)
				part.dismember(attacking_item.damtype)
		living_target.attackby(attacking_item, user)

/obj/effect/temp_visual/slash
	duration = 4
	icon = 'icons/effects/slash_96x96.dmi'
	icon_state = "cross_slash"
	randomdir = FALSE
