/datum/action/cooldown/bloodsucker/targeted/brawn
	name = "Brawn"
	desc = "Snap restraints, break lockers and doors, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	power_explanation = "Brawn:\n\
		Click any person to bash into them, break restraints you have or knocking a grabber down. Only one of these can be done per use.\n\
		Punching a Cyborg will heavily EMP them in addition to deal damage.\n\
		At level 3, you get the ability to break closets open, additionally can both break restraints AND knock a grabber down in the same use.\n\
		At level 4, you get the ability to bash airlocks open, as long as they aren't bolted.\n\
		Higher levels will increase the damage and knockdown when punching someone."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_IN_FRENZY|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = BLOODSUCKER_CAN_BUY|VASSAL_CAN_BUY
	bloodcost = 8
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

/datum/action/cooldown/bloodsucker/targeted/brawn/ActivatePower(trigger_flags)
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
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_restraints()
	var/mob/living/carbon/human/user = owner
	///Only one form of shackles removed per use
	var/used = FALSE

	// Breaks out of lockers
	if(istype(user.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = user.loc
		if(!istype(closet))
			return FALSE
		closet.visible_message(
			"<span class='warning'>[closet] tears apart as [user] bashes it open from within!</span>",
			"<span class='warning'>[closet] tears apart as you bash it open from within!</span>",
		)
		to_chat(user, "<span class='warning'>We bash [closet] wide open!</span>")
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, closet), 1)
		used = TRUE

	// Remove both Handcuffs & Legcuffs
	var/obj/cuffs = user.get_item_by_slot(ITEM_SLOT_HANDCUFFED)
	var/obj/legcuffs = user.get_item_by_slot(ITEM_SLOT_LEGCUFFED)
	if(!used && (istype(cuffs) || istype(legcuffs)))
		user.visible_message(
			"<span class='warning'>[user] discards their restraints like it's nothing!</span>",
			"<span class='warning'>We break through our restraints!</span>",
		)
		user.clear_cuffs(cuffs, TRUE)
		user.clear_cuffs(legcuffs, TRUE)
		used = TRUE

	// Remove Straightjackets
	if(user.wear_suit?.breakouttime && !used)
		var/obj/item/clothing/suit/straightjacket = user.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		user.visible_message(
			"<span class='warning'>[user] rips straight through the [user.p_their()] [straightjacket]!</span>",
			"<span class='warning'>We tear through our [straightjacket]!</span>",
		)
		if(straightjacket && user.wear_suit == straightjacket)
			qdel(straightjacket)
		used = TRUE

	// Did we end up using our ability? If so, play the sound effect and return TRUE
	if(used)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, 1, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/cooldown/bloodsucker/targeted/brawn/proc/break_closet(mob/living/carbon/human/user, obj/structure/closet/closet)
	if(closet)
		closet.welded = FALSE
		closet.locked = FALSE
		closet.broken = TRUE
		closet.open()

/datum/action/cooldown/bloodsucker/targeted/brawn/proc/escape_puller()
	if(!owner.pulledby) // || owner.pulledby.grab_state <= GRAB_PASSIVE)
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
		"<span class='warning'>[owner] tears free of [pulled_mob]'s grasp!</span>",
		"<span class='warning'>You shrug off [pulled_mob]'s grasp!</span>",
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/cooldown/bloodsucker/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/user = owner
	// Target Type: Mob
	if(isliving(target_atom))
		var/mob/living/target = target_atom
		var/mob/living/carbon/carbonuser = user
		var/hitStrength = carbonuser.dna.species.punchdamage * 1.25 + 2
		// Knockdown!
		var/powerlevel = min(5, 1 + level_current)
		if(rand(5 + powerlevel) >= 5)
			target.visible_message(
				"<span class='danger'>[user] lands a vicious punch, sending [target] away!</span>", \
				"<span class='userdanger'>[user] has landed a horrifying punch on you, sending you flying!</span>",
			)
			target.Knockdown(min(5, rand(10, 10 * powerlevel)))
		// Attack!
		owner.balloon_alert(owner, "you punch [target]!")
		playsound(get_turf(target), 'sound/weapons/punch4.ogg', 60, 1, -1)
		user.do_attack_animation(target, ATTACK_EFFECT_SMASH)
		var/obj/item/bodypart/affecting = target.get_bodypart(ran_zone(target.zone_selected))
		target.apply_damage(hitStrength, BRUTE, affecting)
		// Knockback
		var/send_dir = get_dir(owner, target)
		var/turf/turf_thrown_at = get_ranged_target_turf(target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		target.throw_at(turf_thrown_at, powerlevel, TRUE, owner) //new /datum/forced_movement(target, get_ranged_target_turf(target, send_dir, (hitStrength / 4)), 1, FALSE)
		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(target))
			target.emp_act(EMP_HEAVY)
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet) && level_current >= 3)
		var/obj/structure/closet/target_closet = target_atom
		user.balloon_alert(user, "you prepare to bash [target_closet] open...")
		if(!do_after(user, 2.5 SECONDS, target_closet))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		target_closet.visible_message("<span class='danger'>[target_closet] breaks open as [user] bashes it!</span>")
		addtimer(CALLBACK(src, PROC_REF(break_closet), user, target_closet), 1)
		playsound(get_turf(user), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door) && level_current >= 4)
		var/obj/machinery/door/target_airlock = target_atom
		playsound(get_turf(user), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		owner.balloon_alert(owner, "you prepare to tear open [target_airlock]...")
		if(!do_after(user, 2.5 SECONDS, target_airlock))
			user.balloon_alert(user, "interrupted!")
			return FALSE
		if(target_airlock.Adjacent(user))
			target_airlock.visible_message("<span class='danger'>[target_airlock] breaks open as [user] bashes it!</span>")
			user.Stun(10)
			user.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, 1, -1)
			target_airlock.open(2) // open(2) is like a crowbar or jaws of life.

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckValidTarget(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE
	return isliving(target_atom) || istype(target_atom, /obj/machinery/door) || istype(target_atom, /obj/structure/closet)

/datum/action/cooldown/bloodsucker/targeted/brawn/CheckCanTarget(atom/target_atom)
	// DEFAULT CHECKS (Distance)
	. = ..()
	if(!.) // Disable range notice for Brawn.
		return FALSE
	// Must outside Closet to target anyone!
	if(!isturf(owner.loc))
		return FALSE
	// Target Type: Living
	if(isliving(target_atom))
		return TRUE
	// Target Type: Door
	else if(istype(target_atom, /obj/machinery/door))
		return TRUE
	// Target Type: Locker
	else if(istype(target_atom, /obj/structure/closet))
		return TRUE
	return FALSE
