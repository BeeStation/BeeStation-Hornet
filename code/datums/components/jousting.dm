/datum/component/jousting
	var/mounted_damage_boost_per_tile = 4
	var/unmounted_damage_boost_per_tile = 1
	var/mounted_knockdown_chance_per_tile = 6
	var/mounted_knockdown_time = 20
	var/reach = 2
	var/unmounted_target_damage_multiplier = 1.3
	var/mob/current_holder

/datum/component/jousting/Initialize()
	if(!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_drop))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK, PROC_REF(on_attack))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))

/datum/component/jousting/proc/on_equip(datum/source, mob/user, slot)
	SIGNAL_HANDLER
	current_holder = user

/datum/component/jousting/proc/on_drop(datum/source, mob/user)
	SIGNAL_HANDLER
	current_holder = null

/datum/component/jousting/proc/get_charge(mob/user)
	if(!user.buckled || !ismovable(user.buckled))
		return 0
	var/atom/movable/mount = user.buckled
	var/datum/component/riding/riding = mount.GetComponent(/datum/component/riding)
	if(!riding || riding.joust_charge < 2)
		return 0
	return riding.joust_charge

/datum/component/jousting/proc/on_attack(datum/source, mob/living/target, mob/user)
	SIGNAL_HANDLER
	if(user != current_holder)
		return
	var/charge = get_charge(user)
	if(charge <= 0)
		return
	var/target_buckled = target.buckled ? TRUE : FALSE
	var/damage = (target_buckled ? mounted_damage_boost_per_tile : unmounted_damage_boost_per_tile) * charge
	if(!target_buckled)
		damage *= unmounted_target_damage_multiplier
	var/obj/item/I = parent
	target.apply_damage(damage, BRUTE, user.get_combat_bodyzone(target), I.armour_penetration)

	var/was_buckled = target.buckled
	if(was_buckled && target_buckled)
		var/knockdown_chance = min(72, mounted_knockdown_chance_per_tile * charge)
		if(prob(knockdown_chance))
			target.buckled.unbuckle_mob(target)
			target.Paralyze(mounted_knockdown_time)
			target.Knockdown(2 SECONDS)

	if(was_buckled && !target.buckled)
		user.visible_message(
			span_bolddanger("[user] charges through [target] with [I], sending them flying!"),
			span_bolddanger("You charge through [target] with [I], sending them flying!")
		)
	else
		user.visible_message(
			span_bolddanger("[user] charges through [target] with [I]!"),
			span_bolddanger("You charge through [target] with [I]!")
		)

/datum/component/jousting/proc/on_afterattack(datum/source, atom/target, mob/user, proximity_flag, click_parameters)
	SIGNAL_HANDLER
	if(proximity_flag || !isliving(target))
		return
	if(!user.buckled)
		return
	if(get_dist(user, target) > reach)
		return
	var/charge = get_charge(user)
	if(charge <= 0)
		return
	var/mob/living/living_target = target
	if(!check_line_of_sight(user, living_target))
		return
	user.do_attack_animation(living_target)
	var/obj/item/I = parent
	playsound(I, I.hitsound, 50, 1)

	var/target_buckled = living_target.buckled ? TRUE : FALSE
	var/damage = (target_buckled ? mounted_damage_boost_per_tile : unmounted_damage_boost_per_tile) * charge
	if(!target_buckled)
		damage *= unmounted_target_damage_multiplier
	damage += I.force
	living_target.apply_damage(damage, BRUTE, user.get_combat_bodyzone(living_target), I.armour_penetration)

	var/was_buckled = living_target.buckled
	if(was_buckled && target_buckled)
		var/knockdown_chance = min(72, mounted_knockdown_chance_per_tile * charge)
		if(prob(knockdown_chance))
			living_target.buckled.unbuckle_mob(living_target)
			living_target.Paralyze(mounted_knockdown_time)
			living_target.Knockdown(2 SECONDS)

	if(was_buckled && !living_target.buckled)
		user.visible_message(
			span_bolddanger("[user] thrusts [I] at [living_target], throwing them to the ground!"),
			span_bolddanger("You thrust [I] at [living_target], throwing them off their mount!")
		)
	else
		user.visible_message(
			span_danger("[user] thrusts [I] at [living_target] from a distance."),
			span_notice("You thrust [I] at [living_target].")
		)
	user.changeNext_move(CLICK_CD_MELEE * 1.5)

/datum/component/jousting/proc/check_line_of_sight(mob/user, atom/target)
	var/turf/user_turf = get_turf(user)
	var/turf/target_turf = get_turf(target)
	if(!user_turf || !target_turf)
		return FALSE
	if(!(target in view(reach + 1, user)))
		return FALSE
	var/turf/current = user_turf
	var/step_dir = get_dir(current, target_turf)
	var/steps = get_dist(user_turf, target_turf)
	for(var/i in 1 to steps)
		current = get_step(current, step_dir)
		if(!current)
			return FALSE
		if(current.density)
			return FALSE
		if(current != target_turf)
			for(var/obj/structure/S in current)
				if(S.density)
					return FALSE
	return TRUE
