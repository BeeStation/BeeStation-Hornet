/datum/action/item_action/delimbing_strike
	name = "Dismembering Strike"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED|AB_CHECK_INCAPACITATED|AB_CHECK_LYING
	requires_target = TRUE
	cooldown_time = 45 SECONDS

/datum/action/item_action/delimbing_strike/set_click_ability(mob/on_who)
	on_who.visible_message(span_warning("[on_who] prepares to attack!"))
	return ..()

/datum/action/item_action/delimbing_strike/is_available()
	return ..() && istype(owner.get_active_held_item(), /obj/item/energy_katana)

/datum/action/item_action/delimbing_strike/on_activate(mob/living/user, atom/target)
	if (target == null)
		return FALSE
	var/mob/living/carbon/human/owner_mob = owner
	// We only delimb if we are the ninja
	var/delimbs = FALSE
	if (istype(owner_mob))
		var/obj/item/mod/control/pre_equipped/ninja/ninja_suit = owner_mob.back
		if (istype(ninja_suit) && ninja_suit.active)
			delimbs = TRUE
	// Get the direction to the clicked target
	var/direction = get_cardinal_dir(user, target)
	var/obj/effect/temp_visual/slash/slash = new /obj/effect/temp_visual/slash(get_step(user, SOUTHWEST))
	slash.dir = direction
	playsound(user, 'sound/weapons/fwoosh.ogg', 100, TRUE)
	// Stop them for the duration of the slash effect
	user.Immobilize(4)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction | turn_cardinal(direction, -90)), user, delimbs), 1)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction), user, delimbs), 2)
	addtimer(CALLBACK(src, PROC_REF(deal_strike), get_step(user, direction | turn_cardinal(direction, 90)), user, delimbs), 3)
	user.client?.give_cooldown_cursor(2 SECONDS)
	user.changeNext_move(2 SECONDS)
	// Clear cloak when attacking
	user.remove_status_effect(/datum/status_effect/cloaked)
	return TRUE

/datum/action/item_action/delimbing_strike/proc/deal_strike(turf/hit_turf, mob/living/user, delimbs)
	var/obj/item/attacking_item = master
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
