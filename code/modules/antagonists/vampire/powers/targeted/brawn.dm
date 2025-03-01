/datum/action/cooldown/vampire/targeted/brawn
	name = "Brawn"
	desc = "Snap restraints, break lockers and doors, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	power_explanation = "Use this power to deal a horrific blow. Punching a Cyborg will EMP it and deal high damage.\n\
		At level 3, you can break closets open and break restraints.\n\
		At level 4, you can bash airlocks open.\n\
		Higher ranks will increase the damage when punching someone."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 8
	sol_multiplier = 5
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

/datum/action/cooldown/vampire/targeted/brawn/ActivatePower()
	// Did we break out of our handcuffs?
	if(break_restraints())
		power_activated_sucessfully()
		return FALSE
	// Did we knock a grabber down? We can only do this while not also breaking restraints if strong enough.
	if(level_current >= 3 && escape_puller())
		power_activated_sucessfully()
		return FALSE
	// Did neither, now we can PUNCH.
	return ..()

// Look at 'biodegrade.dm' for reference
/datum/action/cooldown/vampire/targeted/brawn/proc/break_restraints()
	var/mob/living/carbon/human/user = owner
	if(!user) // how
		return FALSE
	var/used = FALSE

	// Lockers
	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, closet), 1)
		closet.visible_message(
			span_warning("[closet] tears apart as [user] bashes it open from within!"),
			span_warning("[closet] tears apart as you bash it open from within!"))
		to_chat(user, span_warning("We bash [closet] wide open!"))
		used = TRUE

	// Cuffs
	if(user.handcuffed || user.legcuffed)
		user.uncuff()
		user.visible_message(
			span_warning("[user] discards their restraints like it's nothing!"),
			span_warning("We break through our restraints!"))
		used = TRUE

	// Straightjackets
	if(user.wear_suit?.breakouttime)
		var/obj/item/clothing/suit/straightjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(straightjacket && user.wear_suit == straightjacket)
			qdel(straightjacket)
		user.visible_message(
			span_warning("[user] rips straight through the [user.p_their()] [straightjacket]!"),
			span_warning("We tear through our [straightjacket]!"))
		used = TRUE

	if(used)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, 1, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/cooldown/vampire/targeted/brawn/proc/break_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()

/datum/action/cooldown/vampire/targeted/brawn/proc/escape_puller()
	if(!owner.pulledby)
		return FALSE

	var/mob/pulled_mob = owner.pulledby
	var/pull_power = pulled_mob.grab_state
	playsound(get_turf(pulled_mob), 'sound/effects/woodhit.ogg', 75, 1, -1)
	// Knock Down (if Living)
	if(isliving(pulled_mob))
		var/mob/living/hit_target = pulled_mob
		hit_target.Knockdown(pull_power * 10 + 20)
	// Knock Back (before Knockdown, which probably cancels pull)
	var/send_dir = get_dir(owner, pulled_mob)
	var/turf/turf_thrown_at = get_ranged_target_turf(pulled_mob, send_dir, pull_power)
	owner.newtonian_move(send_dir) // Bounce back in 0 G
	pulled_mob.throw_at(turf_thrown_at, pull_power, TRUE, owner, FALSE) // Throw distance based on grab state! Harder grabs punished more aggressively.
	log_combat(owner, pulled_mob, "used Brawn power")
	owner.visible_message(
		span_warning("[owner] tears free of [pulled_mob]'s grasp!"),
		span_warning("You shrug off [pulled_mob]'s grasp!"))
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/cooldown/vampire/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner

	// Living Targets
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		// Knockdown!
		var/powerlevel = min(5, 1 + level_current)
		target.visible_message(
			span_danger("[user] lands a vicious punch, sending [target] away!"), \
			span_userdanger("[user] has landed a horrifying punch on you and sends you flying!"))
		target.Knockdown(min(5, rand(10, 10 * powerlevel)))
		// Attack!
		owner.balloon_alert(owner, "you punch [target]!")
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.get_combat_bodyzone()))
		target.apply_damage(carbonuser.dna.species.punchdamage * 1.25 + 2, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, powerlevel, TRUE, owner)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)
	// Lockers
	else if(istype(target_atom, /obj/structure/closet) && level_current >= 3)
		var/obj/structure/closet/target_closet = target_atom
		user.balloon_alert(user, "you prepare to bash [target_closet] open...")
		if(!do_after(user, 2.5 SECONDS, target_closet))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		target_closet.visible_message(span_danger("[target_closet] breaks open as [user] bashes it!"))
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, target_closet), 1)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	// Airlocks
	else if(istype(target_atom, /obj/machinery/door) && level_current >= 4)
		var/obj/machinery/door/target_airlock = target_atom
		playsound(get_turf(user), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		owner.balloon_alert(owner, "you prepare to tear open [target_airlock]...")
		if(!do_after(user, 2.5 SECONDS, target_airlock))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		if(target_airlock.Adjacent(user))
			target_airlock.visible_message(span_danger("[target_airlock] breaks open as [user] bashes it!"))
			user.Stun(10)
			user.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, 1, -1)
			target_airlock.open(2) // open(2) is like a crowbar or jaws of life.

/datum/action/cooldown/vampire/targeted/brawn/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/structure/closet)

/datum/action/cooldown/vampire/targeted/brawn/CheckCanTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Can't be in a locker when targeting someone
	if(istype(owner.loc, /obj/structure/closet))
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/structure/closet)
