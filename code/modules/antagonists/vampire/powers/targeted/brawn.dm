/datum/action/vampire/targeted/brawn
	name = "Brawn"
	desc = "Snap restraints, break lockers and doors, or deal terrible damage with your bare hands."
	button_icon_state = "power_strength"
	power_explanation = "Use this power to deal a horrific blow. Punching a Cyborg will EMP it and deal high damage.\n\
		At level 3, you can break closets open and break restraints.\n\
		At level 4, you can bash airlocks open.\n\
		Higher ranks will increase the damage when punching someone."
	power_flags = BP_AM_TOGGLE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY | VASSAL_CAN_BUY
	bloodcost = 8
	sol_multiplier = 5
	cooldown_time = 9 SECONDS
	target_range = 1
	power_activates_immediately = TRUE
	prefire_message = "Select a target."

	/// Only changed by the '/brawn/brash' subtype; acts as a general purpose damage multipler.
	var/damage_coefficient = 1.25
	/// Boolean indicating whether or not this version of '/brawn' is in the '/brash' subtype and should
	/// bypass typical ability level restrictions. (There is probably a better way to do this.)
	var/brujah = FALSE

/datum/action/vampire/targeted/brawn/activate_power()
	// Did we break out of our handcuffs?
	if(break_restraints())
		power_activated_sucessfully()
		return
	// Did we knock a grabber down? We can only do this while not also breaking restraints if strong enough.
	if(level_current >= 3 && escape_puller())
		power_activated_sucessfully()
		return
	// Did neither, now we can PUNCH.
	. = ..()

// Look at 'biodegrade.dm' for reference
/datum/action/vampire/targeted/brawn/proc/break_restraints()
	if(!ishuman(owner))
		return FALSE

	var/mob/living/carbon/human/human_owner = owner

	var/used = FALSE

	// Lockers
	if(istype(human_owner.loc, /obj/structure/closet))
		var/obj/structure/closet/closet = human_owner.loc
		addtimer(CALLBACK(src, PROC_REF(break_closet), closet), 1)
		closet.visible_message(
			span_warning("[closet] tears apart as [human_owner] bashes it open from within!"),
			span_warning("[closet] tears apart as you bash it open from within!")
		)
		to_chat(human_owner, span_warning("We bash [closet] wide open!"))
		used = TRUE

	// Cuffs
	if(human_owner.handcuffed || human_owner.legcuffed)
		human_owner.uncuff()
		human_owner.visible_message(
			span_warning("[human_owner] discards their restraints like it's nothing!"),
			span_warning("We break through our restraints!")
		)
		used = TRUE

	// Straightjackets
	if(human_owner.wear_suit?.breakouttime)
		var/obj/item/clothing/suit/straightjacket = human_owner.get_item_by_slot(ITEM_SLOT_OCLOTHING)
		if(straightjacket && human_owner.wear_suit == straightjacket)
			qdel(straightjacket)
		human_owner.visible_message(
			span_warning("[human_owner] rips straight through the [human_owner.p_their()] [straightjacket]!"),
			span_warning("We tear through our [straightjacket]!")
		)
		used = TRUE

	if(used)
		playsound(get_turf(human_owner), 'sound/effects/grillehit.ogg', 80, 1, -1)
	return used

// This is its own proc because its done twice, to repeat code copypaste.
/datum/action/vampire/targeted/brawn/proc/break_closet(obj/structure/closet/closet)
	closet.welded = FALSE
	closet.locked = FALSE
	closet.broken = TRUE
	closet.open()

/datum/action/vampire/targeted/brawn/proc/escape_puller()
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

	log_combat(owner, pulled_mob, "used [src.name] power")
	owner.visible_message(
		span_warning("[owner] tears free of [pulled_mob]'s grasp!"),
		span_warning("You shrug off [pulled_mob]'s grasp!")
	)
	owner.pulledby = null // It's already done, but JUST IN CASE.
	return TRUE

/datum/action/vampire/targeted/brawn/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/carbon/carbon_owner = owner

	// Living Targets
	if(isliving(target_atom))
		var/mob/living/living_target = target_atom

		// Strength of the attack
		var/hit_strength = carbon_owner.dna.species.punchdamage * damage_coefficient + 2
		var/powerlevel = min(5, 1 + level_current)

		if(rand(5 + powerlevel) >= 5)
			living_target.visible_message(
				span_danger("[carbon_owner] lands a vicious punch, sending [living_target] away!"), \
				span_userdanger("[carbon_owner] has landed a horrifying punch on you, sending you flying!"),
			)
			living_target.Knockdown(min(5, rand(10, 10 * powerlevel)))

		// Attack!
		owner.balloon_alert(owner, "you punch [living_target]!")
		playsound(get_turf(living_target), 'sound/weapons/punch4.ogg', 60, 1, -1)

		carbon_owner.do_attack_animation(living_target, ATTACK_EFFECT_SMASH)

		var/obj/item/bodypart/affecting = living_target.get_bodypart(living_target.get_random_valid_zone(living_target.get_combat_bodyzone()))
		living_target.apply_damage(hit_strength, BRUTE, affecting)

		// Knockback
		var/send_dir = get_dir(owner, living_target)
		var/turf/turf_thrown_at = get_ranged_target_turf(living_target, send_dir, powerlevel)
		owner.newtonian_move(send_dir) // Bounce back in 0 G
		living_target.throw_at(turf_thrown_at, powerlevel, TRUE, owner)

		// Target Type: Cyborg (Also gets the effects above)
		if(issilicon(living_target))
			living_target.emp_act(EMP_HEAVY)
	// Lockers
	else if(istype(target_atom, /obj/structure/closet))
		var/obj/structure/closet/target_closet = target_atom

		playsound(get_turf(carbon_owner), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		carbon_owner.balloon_alert(carbon_owner, "you prepare to bash [target_closet] open...")
		if(!do_after(carbon_owner, 2.5 SECONDS, target_closet))
			carbon_owner.balloon_alert(carbon_owner, "interrupted!")
			return FALSE
		target_closet.visible_message(span_danger("[target_closet] breaks open as [carbon_owner] bashes it!"))

		INVOKE_ASYNC(src, PROC_REF(break_closet), target_closet)
		playsound(get_turf(carbon_owner), 'sound/effects/grillehit.ogg', 80, TRUE, -1)
	// Airlocks
	else if(istype(target_atom, /obj/machinery/door/airlock))
		var/obj/machinery/door/airlock/target_airlock = target_atom

		playsound(get_turf(carbon_owner), 'sound/machines/airlock_alien_prying.ogg', 40, TRUE, -1)
		owner.balloon_alert(owner, "you prepare to tear open [target_airlock]...")
		if(!do_after(carbon_owner, 2.5 SECONDS, target_airlock))
			carbon_owner.balloon_alert(carbon_owner, "interrupted!")
			return FALSE

		if(target_airlock.Adjacent(carbon_owner))
			target_airlock.visible_message(span_danger("[target_airlock] breaks open as [carbon_owner] bashes it!"))

			// Adjust cost and cooldown if Brujah
			if(brujah)
				if(target_airlock.locked)
					bloodcost = 20
					cooldown_time = 10 SECONDS
				else
					bloodcost = 10
					cooldown_time = 6 SECONDS
			else // If not Brujah then just make the vampire wait a second...
				carbon_owner.Stun(1 SECONDS)

			carbon_owner.Stun(10)
			carbon_owner.do_attack_animation(target_airlock, ATTACK_EFFECT_SMASH)
			playsound(get_turf(target_airlock), 'sound/effects/bang.ogg', 30, 1, -1)
			if(brujah && level_current >= 3 && target_airlock.locked)
				target_airlock.unbolt()
			target_airlock.open(BYPASS_DOOR_CHECKS) // open(BYPASS_DOOR_CHECKS) is like a crowbar or jaws of life.

/datum/action/vampire/targeted/brawn/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Brujah has their own checks
	if(brujah)
		return TRUE

	if(isliving(target_atom))
		return TRUE

	if(istype(target_atom, /obj/machinery/door/airlock))
		if(level_current < 4)
			owner.balloon_alert(owner, "level 4 required!")
			return FALSE

		return TRUE

	if(istype(target_atom, /obj/structure/closet))
		if(level_current < 3)
			owner.balloon_alert(owner, "level 3 required!")
			return FALSE

		var/obj/structure/closet/target_closet = target_atom
		if(target_closet.welded || target_closet.locked)
			return TRUE

	return FALSE
