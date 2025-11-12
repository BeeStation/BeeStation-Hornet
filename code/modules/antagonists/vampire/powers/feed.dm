#define FEED_SILENT_NOTICE_RANGE 1
#define FEED_LOUD_NOTICE_RANGE 7
#define FEED_DEFAULT_TIME 10 SECONDS
#define FEED_FRENZY_TIME 2 SECONDS
#define FEED_BLOOD_FROM_MICE 25

/datum/action/vampire/targeted/feed
	name = "Feed"
	desc = "Feed blood off of a living creature."
	button_icon_state = "power_feed"
	power_explanation = "Activate Feed and select a target to start draining their blood.\n\
		You will begin to entrance them into accepting your advances.\n\
		The time needed before you start feeding decreases the higher level you are.\n\
		If you are feeding normally they will forget that they were ever fed off.\n\
		Feeding off of someone while you have them aggressively grabbed while in combat mode, will put them to sleep and make you feed faster. \
		This is very obvious and the radius in which you can be detected is much larger!\n\
		Mice can be fed off if you are in desperate need of blood.\n\
		<b>IMPORTANT:</b> You are given a Masquerade Infraction if a mortal witnesses you while feeding.\n\
		<b>IMPORTANT:</b> You may feed on other vampires if they have broken the masquerade. Should you drain them, you will absorb their power!"
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	special_flags = VAMPIRE_DEFAULT_POWER
	cooldown_time = 5 SECONDS
	target_range = 1
	prefire_message = "Select a target."
	power_activates_immediately = FALSE
	/// Amount of blood taken, reset after each Feed. Used for logging.
	var/blood_taken = 0
	/// The amount of Blood a target has since our last feed, this loops and lets us not spam alerts of low blood.
	var/warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	/// Reference to the target we've fed off of
	var/datum/weakref/target_ref
	/// Are we feeding with passive grab or not?
	var/silent_feed = TRUE

	/// Have we fed till fatal?
	var/feed_fatal = FALSE
	/// Are we at a stage of the process where we can be noticed?
	var/currently_feeding = FALSE

/datum/action/vampire/targeted/feed/can_use()
	. = ..()
	if(!.)
		return FALSE

	// Already feeding
	if(target_ref)
		return FALSE
	// Mouth covered
	var/mob/living/carbon/user = owner
	if(user?.is_mouth_covered() && !isplasmaman(user))
		owner.balloon_alert(owner, "mouth covered!")
		return FALSE

/datum/action/vampire/targeted/feed/continue_active()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/target = target_ref.resolve()
	if(!target)
		return FALSE
	if(!owner.Adjacent(target))
		return FALSE

	// Check if we are seen while feeding, from the vampire's POV
	if(currently_feeding)
		for(var/mob/living/watcher in oviewers(silent_feed ? FEED_SILENT_NOTICE_RANGE : FEED_LOUD_NOTICE_RANGE, owner) - target)
			if(!watcher.client)
				continue
			if(watcher.has_unlimited_silicon_privilege)
				continue
			if(watcher.stat != CONSCIOUS)
				continue
			if(watcher.is_blind() || HAS_TRAIT(watcher, TRAIT_NEARSIGHT))
				continue
			if(IS_VAMPIRE(watcher) || IS_VASSAL(watcher))
				continue

			if(!watcher.incapacitated(IGNORE_RESTRAINTS))
				watcher.face_atom(owner)

			watcher.do_alert_animation(watcher)
			to_chat(watcher, span_dangerbold("Wait... is... [owner.first_name()] BITING [target.first_name()]?!"), type = MESSAGE_TYPE_WARNING)
			playsound(watcher, 'sound/machines/chime.ogg', 50, FALSE, -5)

			owner.balloon_alert(owner, "feed noticed!")
			vampiredatum_power.give_masquerade_infraction()
			return FALSE

		//from the victim's POV
		for(var/mob/living/watcher in oviewers(silent_feed ? FEED_SILENT_NOTICE_RANGE : FEED_LOUD_NOTICE_RANGE, target))
			if(!watcher.client)
				continue
			if(watcher.has_unlimited_silicon_privilege)
				continue
			if(watcher.stat != CONSCIOUS)
				continue
			if(watcher.is_blind() || HAS_TRAIT(watcher, TRAIT_NEARSIGHT))
				continue
			if(IS_VAMPIRE(watcher) || IS_VASSAL(watcher))
				continue

			if(!watcher.incapacitated(IGNORE_RESTRAINTS))
				watcher.face_atom(owner)

			watcher.do_alert_animation(watcher)
			to_chat(watcher, span_dangerbold("Wait... is... [owner.first_name()] BITING [target.first_name()]?!"), type = MESSAGE_TYPE_WARNING)
			playsound(watcher, 'sound/machines/chime.ogg', 50, FALSE, -5)

			owner.balloon_alert(owner, "feed noticed!")
			vampiredatum_power.give_masquerade_infraction()
			return FALSE

	return TRUE

/datum/action/vampire/targeted/feed/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be living
	if(!isliving(target_atom))
		return FALSE
	var/mob/living/target = target_atom
	// Mice check
	if(istype(target, /mob/living/simple_animal/mouse))
		if(vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
			owner.balloon_alert(owner, "too disgusting!")
			return FALSE
		else
			return TRUE
	// Has to be human or a monkey
	if(!ishuman(target) && !ismonkey(target))
		owner.balloon_alert(owner, "cant feed off!")
		return FALSE
	// Mindless and snobby?
	if(!target.mind && vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !vampiredatum_power.frenzied)
		owner.balloon_alert(owner, "ew, no!")
		return FALSE
	// Cannot be a curator
	if(IS_CURATOR(target))
		owner.balloon_alert(owner, "[target] is too powerful!")
		return FALSE
	// Only allow diablerie for masquerade breakers
	if(IS_VAMPIRE(target))
		var/datum/antagonist/vampire/target_vampire = IS_VAMPIRE(target)
		if(!target_vampire.broke_masquerade)
			return FALSE
	// Human checks
	if(ishuman(target))
		// Cannot drink from inorganics
		var/mob/living/carbon/human/human_target = target
		if(!human_target.dna?.species || !(human_target.mob_biotypes & MOB_ORGANIC))
			owner.balloon_alert(owner, "no blood!")
			return FALSE
		// Cannot be wearing super thick gear
		if(!human_target.can_inject(owner, BODY_ZONE_HEAD, INJECT_CHECK_PENETRATE_THICK))
			owner.balloon_alert(owner, "suit too thick!")
			return FALSE

	silent_feed = TRUE

/datum/action/vampire/targeted/feed/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/feed_target = target_atom
	var/mob/living/living_owner = owner
	target_ref = WEAKREF(feed_target)

	// Mice
	if(istype(feed_target, /mob/living/simple_animal/mouse))
		to_chat(owner, span_notice("You recoil at the taste of a lesser lifeform."))
		vampiredatum_power.AddBloodVolume(FEED_BLOOD_FROM_MICE)
		power_activated_sucessfully()
		feed_target.death()
		return

	//////////////////////////
	//We start here properly//
	//////////////////////////

	currently_feeding = FALSE

	if(!living_owner.combat_mode)

		owner.balloon_alert(owner, "mesmerizing [feed_target]...")

		// Initial ""mesmerize""
		if(!do_after(owner, 2 SECONDS, feed_target, NONE, TRUE, hidden = TRUE))
			owner.balloon_alert(owner, "interrupted!")
			deactivate_power()
			return

		// Succesfull. Start feeding process by getting feed time.
		var/feed_time = vampiredatum_power.frenzied ? FEED_FRENZY_TIME : clamp(round(FEED_DEFAULT_TIME / (1.25 * (level_current || 1))), 1, FEED_DEFAULT_TIME)

		feed_target.Stun(feed_time, TRUE)
		to_chat(feed_target, span_hypnophrase("[owner.first_name()]'s eyes glitter so beautifully..."), type = MESSAGE_TYPE_WARNING)
		owner.balloon_alert(owner, "subdued! starting feed...")
		owner.whisper("shhhh...")

		// Do the pre-feed.
		if(!do_after(owner, feed_time, feed_target, NONE, TRUE, hidden = TRUE))
			owner.balloon_alert(owner, "interrupted!")
			deactivate_power()
			return

		// It begins...
		currently_feeding = TRUE

		playsound(living_owner, 'sound/vampires/drinkblood1.ogg', 50, falloff_exponent = 30)

		// Just to make sure
		living_owner.stop_pulling()
		feed_target.stop_pulling()

		// omega switch
		switch(get_dir(owner.loc, feed_target.loc))
			if(NORTH)
				owner.dir = WEST
				feed_target.dir = EAST
				animate(owner, 0.2 SECONDS, pixel_x = 8, pixel_y = 16)
				animate(feed_target, 0.2 SECONDS, pixel_x = -8, pixel_y = -16)
			if(NORTHEAST)
				owner.dir = EAST
				feed_target.dir = WEST
				animate(owner, 0.2 SECONDS, pixel_x = 8, pixel_y = 16)
				animate(feed_target, 0.2 SECONDS, pixel_x = -8, pixel_y = -16)
			if(EAST)
				owner.dir = EAST
				feed_target.dir = WEST
				animate(owner, 0.2 SECONDS, pixel_x = 8)
				animate(feed_target, 0.2 SECONDS, pixel_x = -8)
			if(SOUTH)
				owner.dir = EAST
				feed_target.dir = WEST
				animate(owner, 0.2 SECONDS, pixel_x = -8, pixel_y = -16)
				animate(feed_target, 0.2 SECONDS, pixel_x = 8, pixel_y = 16)
			if(SOUTHEAST)
				owner.dir = EAST
				feed_target.dir = WEST
				animate(owner, 0.2 SECONDS, pixel_x = 8, pixel_y = -16)
				animate(feed_target, 0.2 SECONDS, pixel_x = -8, pixel_y = 16)
			if(SOUTHWEST)
				owner.dir = WEST
				feed_target.dir = EAST
				animate(owner, 0.2 SECONDS, pixel_x = -8, pixel_y = -16)
				animate(feed_target, 0.2 SECONDS, pixel_x = 8, pixel_y = 16)
			if(WEST)
				owner.dir = WEST
				feed_target.dir = EAST
				animate(owner, 0.2 SECONDS, pixel_x = -8)
				animate(feed_target, 0.2 SECONDS, pixel_x = 8)
			if(NORTHWEST)
				owner.dir = WEST
				feed_target.dir = EAST
				animate(owner, 0.2 SECONDS, pixel_x = -8, pixel_y = 16)
				animate(feed_target, 0.2 SECONDS, pixel_x = 8, pixel_y = -16)

		to_chat(feed_target, span_bigboldwarning("[owner.first_name()] embraces you tightly, sinking their fangs into your neck!"), type = MESSAGE_TYPE_WARNING)
		to_chat(feed_target, span_hypnophrase("Why does it feel soo good..."), type = MESSAGE_TYPE_WARNING)

		owner.visible_message(
			span_notice("[owner.first_name()] closes [owner.p_their()] arms around [feed_target.first_name()] in a tight embrace, biting into their neck!"),
			span_notice("You slip your fangs into [feed_target.first_name()]'s neck."),
			vision_distance = FEED_SILENT_NOTICE_RANGE, ignored_mobs = feed_target
		)

	else if(owner.pulling == feed_target && owner.grab_state == GRAB_AGGRESSIVE) // COMBAT FEED BELOW HERE!!!!!!!!!!
		playsound(living_owner, 'sound/vampires/drinkblood1.ogg', 50, falloff_exponent = 10)
		feed_target.Unconscious((5 + level_current) SECONDS)
		owner.visible_message(
			span_warning("[owner.first_name()] closes [owner.p_their()] mouth around [feed_target.first_name()]'s neck!"),
			span_warning("You sink your fangs into [feed_target.first_name()]'s neck."), ignored_mobs = feed_target
		)
		to_chat(feed_target, span_bolddanger("[owner.first_name()] SEIZES YOU WITH INCREDIBLE STRENGTH, SINKING THEIR TEETH INTO YOUR NECK!"), type = MESSAGE_TYPE_WARNING)
		currently_feeding = TRUE
		silent_feed = FALSE

	// Garlic in 'em
	var/mob/living/smacked = feed_target
	if(smacked.reagents?.has_reagent(/datum/reagent/consumable/garlic, 2))

		// We check which turf is one step away from our target, in the direction of the angle of the bullet. Christ. We do this twice, for range.
		var/target_turf = get_step_away(smacked.loc, owner, 2)

		to_chat(owner, span_bighypnophrase("eugh.. garlic..."))

		living_owner.Stun(50)
		living_owner.set_dizziness(10)
		living_owner.adjust_jitter(15)
		living_owner.blur_eyes(5)

		smacked.Unconscious(10)
		smacked.throw_at(target_turf, 2, 1, spin = TRUE)
		playsound(smacked, 'sound/weapons/cqchit2.ogg', 80)
		deactivate_power()
		return

	if(currently_feeding) // Check if we actually started successfully.
		owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_HANDS_BLOCKED), TRAIT_FEED)
		feed_target.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_WHISPER_ONLY, TRAIT_HANDS_BLOCKED), TRAIT_FEED)
	else
		owner.balloon_alert(owner, "combat feed requires aggressive grab!")
		deactivate_power()
		return FALSE

/datum/action/vampire/targeted/feed/UsePower()
	var/mob/living/user = owner

	var/mob/living/feed_target = target_ref?.resolve()
	if(!feed_target)
		power_activated_sucessfully()
		return

	if(!silent_feed)
		feed_target.SetUnconscious(10 SECONDS)

	if(!continue_active())
		if(!silent_feed)
			user.visible_message(
				span_warning("[user] is ripped from [feed_target.first_name()]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"),
				span_warning("Your teeth are ripped from [feed_target.first_name()]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"))

			// Time to start bleeding
			if(iscarbon(feed_target))
				var/mob/living/carbon/carbon_target = feed_target
				carbon_target.bleed(15)
			playsound(get_turf(feed_target), 'sound/effects/splat.ogg', 40, TRUE)
			if(ishuman(feed_target))
				var/mob/living/carbon/human/target_user = feed_target
				target_user.add_bleeding(BLEED_CRITICAL)
			feed_target.add_splatter_floor(get_turf(feed_target))

			// Cover both parties in blood
			user.add_mob_blood(feed_target) // Put target's blood on us. The donor goes in the ( )
			feed_target.add_mob_blood(feed_target)

			// Ow
			feed_target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
			INVOKE_ASYNC(feed_target, TYPE_PROC_REF(/mob, emote), "scream")

		power_activated_sucessfully()
		return

	// Adjust blood
	var/feed_strength_mult = 0.3
	if(vampiredatum_power.frenzied)
		feed_strength_mult = 2
	else if(!silent_feed)
		feed_strength_mult = 1

	handle_feeding(feed_target, feed_strength_mult)

	// Mood events
	if(vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !feed_target.mind) // Snobby
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
	else if(feed_target.stat == DEAD) // Dead
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_dead)
	else // Normal
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood)

	// Alert the vampire to the target's blood level
	if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
		owner.balloon_alert(owner, "your victim's blood is fatally low!")
		feed_fatal = TRUE
	else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
		owner.balloon_alert(owner, "your victim's blood is dangerously low.")
	else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
		owner.balloon_alert(owner, "your victim's blood is at an unsafe level.")
	warning_target_bloodvol = feed_target.blood_volume

	// Check if full on blood
	if(vampiredatum_power.vampire_blood_volume >= vampiredatum_power.max_blood_volume)
		if(IS_VAMPIRE(feed_target))
			owner.balloon_alert(owner, "we are full on blood, but we can continue feeding to absorb their power!")
		else
			owner.balloon_alert(owner, "we are full on blood!")

	// Check if target has an acceptable amount of blood left
	if(feed_target.blood_volume <= 10)
		owner.balloon_alert(owner, "no blood left!")
		if(IS_VAMPIRE(feed_target))
			diablerie(feed_target)
		power_activated_sucessfully()
		return

	// Play heartbeat sound effect to vampire and target
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/// We assume the target is a vampire.
/datum/action/vampire/targeted/feed/proc/diablerie(mob/living/poor_sap)
	var/datum/antagonist/vampire/victim = IS_VAMPIRE(poor_sap)

	var/levels_absorbed = victim.vampire_level / DIABLERIE_DIVISOR

	for(var/county; county<levels_absorbed; county++)
		vampiredatum_power.rank_up()

	vampiredatum_power.deduct_humanity(victim.humanity / 3)

	poor_sap.dust(drop_items = TRUE)

/datum/action/vampire/targeted/feed/deactivate_power()
	. = ..()
	REMOVE_TRAITS_IN(owner, TRAIT_FEED)

	// Did we already take humanity for killing them?
	var/humanity_deducted = FALSE
	var/mob/living/feed_target = target_ref?.resolve()

	if(feed_target && currently_feeding)
		REMOVE_TRAITS_IN(feed_target, TRAIT_FEED)

		animate(owner, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)
		animate(feed_target, 0.2 SECONDS, pixel_x = 0, pixel_y = 0)

		log_combat(owner, feed_target, "fed on blood", addition = "(and took [blood_taken] blood)")
		to_chat(owner, span_notice("You slowly release [feed_target]."))

		if(feed_target.stat != DEAD && silent_feed)
			to_chat(owner, span_notice("<i>[feed_target.p_they(TRUE)] look[feed_target.p_s()] dazed, and will not remember this.</i>"))
			to_chat(feed_target, span_bighypnophrase("You don't remember anything since you first saw their eyes, everything is so... hazy..."))
			if(feed_target.blood_volume >= BLOOD_VOLUME_OKAY)
				to_chat(feed_target, span_announce("You feel dizzy, but it will probably pass by itself!"))
			message_admins("TSUNAMIANT ALERT, IGNORE IF YOU AINT ME")

		if(feed_target.stat == DEAD)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled)
			humanity_deducted = TRUE

		if(feed_fatal && !humanity_deducted)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled)
			to_chat(owner, span_userdanger("No way will [feed_target.p_they()] survive that..."))
			vampiredatum_power.deduct_humanity(1)

	feed_fatal = FALSE
	humanity_deducted = FALSE

	target_ref = null

	warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	blood_taken = 0

/datum/action/vampire/targeted/feed/proc/handle_feeding(mob/living/carbon/target, mult = 1)
	var/feed_amount = 50 + (level_current * 2)

	// If we are already at fatal, we speed up more.
	if(feed_fatal)
		feed_amount *= 1.5

	var/blood_to_take = min(feed_amount * mult, target.blood_volume)

	// Remove target's blood
	target.blood_volume -= blood_to_take

	// Shift body temperature (toward target's temp, by volume taken)
	// ((vamp_blood_volume * vamp_temp) + (target_blood_volume * target_temp)) / (vamp_blood_volume + blood_to_take)
	owner.bodytemperature = ((vampiredatum_power.vampire_blood_volume * owner.bodytemperature) + (blood_to_take * target.bodytemperature)) / (vampiredatum_power.vampire_blood_volume + blood_to_take)

	// Penalty for dead blood(at least it's still human, right?)
	if(target.stat == DEAD)
		blood_to_take /= 3
	// Penalty for non-human blood
	if(!ishuman(target))
		blood_to_take /= 10
	// Penalty for frenzy(messy eater)
	if(vampiredatum_power.frenzied)
		blood_to_take /= 2

	// Give vampire the blood
	vampiredatum_power.AddBloodVolume(blood_to_take * 4)

	// Diablerie takes vitae directly
	if(IS_VAMPIRE(target))
		var/datum/antagonist/vampire/vampire_target = IS_VAMPIRE(target)
		vampire_target.RemoveBloodVolume(blood_to_take * 4)

	// Transfer the target's reagents into the vampire's blood
	if(target.reagents?.total_volume)
		target.reagents.trans_to(owner, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.

	// Play heartbeat sound for flavor
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

	vampiredatum_power.total_blood_drank += blood_to_take
	blood_taken += blood_to_take

#undef FEED_SILENT_NOTICE_RANGE
#undef FEED_LOUD_NOTICE_RANGE
#undef FEED_DEFAULT_TIME
#undef FEED_FRENZY_TIME
#undef FEED_BLOOD_FROM_MICE
