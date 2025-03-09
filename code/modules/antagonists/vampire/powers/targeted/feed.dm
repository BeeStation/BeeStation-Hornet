#define FEED_SILENT_NOTICE_RANGE 2
#define FEED_LOUD_NOTICE_RANGE 7
#define FEED_DEFAULT_TIME 10 SECONDS
#define FEED_FRENZY_TIME 2 SECONDS
#define FEED_BLOOD_FROM_MICE 25

/datum/action/cooldown/vampire/targeted/feed
	name = "Feed"
	desc = "Feed blood off of a living creature."
	button_icon_state = "power_feed"
	power_explanation = "Activate Feed while next to someone and you will begin to feed blood off of them.\n\
		The time needed before you start feeding decreases the higher level you are.\n\
		Feeding off of someone while you have them aggressively grabbed will put them to sleep and make you feed faster.\n\
		NOTE: This is very obvious and the radius of people noticing you feed is much larger!\n\
		You are given a Masquerade Infraction if you feed too close to a mortal.\n\
		Mice can be fed off if you are in desperate need of blood."
	power_flags = BP_AM_TOGGLE|BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR|BP_CANT_USE_WHILE_STAKED|BP_CANT_USE_WHILE_INCAPACITATED|BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY|VAMPIRE_DEFAULT_POWER
	cooldown_time = 15 SECONDS
	target_range = 1
	prefire_message = "Select a target."
	power_activates_immediately = FALSE
	///Amount of blood taken, reset after each Feed. Used for logging.
	var/blood_taken = 0
	///The amount of Blood a target has since our last feed, this loops and lets us not spam alerts of low blood.
	var/warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	///Reference to the target we've fed off of
	var/datum/weakref/target_ref
	///Are we feeding with passive grab or not?
	var/silent_feed = TRUE

/datum/action/cooldown/vampire/targeted/feed/can_use()
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

/datum/action/cooldown/vampire/targeted/feed/ContinueActive()
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/target = target_ref.resolve()
	if(!target)
		return FALSE
	if(!owner.Adjacent(target))
		return FALSE
	return TRUE

/datum/action/cooldown/vampire/targeted/feed/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be living
	if(!isliving(target_atom))
		return FALSE
	var/mob/living/target = target_atom
	// Mouse and snobby?
	if(istype(target, /mob/living/simple_animal/mouse) && vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY)
		owner.balloon_alert(owner, "too disgusting!")
		return FALSE
	// Has to be human or a monkey
	var/mob/living/carbon/human/human_target = target
	if(!human_target && !ismonkey(target))
		return FALSE
	// Mindless and snobby?
	if(!target.mind && vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !vampiredatum_power.frenzied)
		owner.balloon_alert(owner, "cant drink from mindless!")
		return FALSE
	// Cannot be a curator or vampire
	if(IS_VAMPIRE(target) || IS_CURATOR(target))
		return FALSE

	// If a target has gotten this far that means it must be a monkey or human.
	// If it's a monkey, lets go ahead and return since the next checks only apply to humans.
	if(!human_target)
		return TRUE

	// Cannot drink from inorganics
	if(!human_target.dna?.species || !(human_target.mob_biotypes & MOB_ORGANIC))
		owner.balloon_alert(owner, "no blood!")
		return FALSE
	// Cannot be wearing super thick gear
	if(!human_target.can_inject(owner, BODY_ZONE_HEAD, INJECT_CHECK_PENETRATE_THICK))
		owner.balloon_alert(owner, "suit too thick!")
		return FALSE

/datum/action/cooldown/vampire/targeted/feed/FireTargetedPower(atom/target_atom)
	. = ..()

	var/mob/living/feed_target = target_atom
	target_ref = WEAKREF(feed_target)

	// Mice
	if(istype(feed_target, /mob/living/simple_animal/mouse))
		to_chat(owner, span_notice("You recoil at the taste of a lesser lifeform."))
		vampiredatum_power.AddBloodVolume(FEED_BLOOD_FROM_MICE)
		power_activated_sucessfully()
		feed_target.death()
		return

	// How long should the pre-feed last
	var/feed_time = vampiredatum_power.frenzied ? FEED_FRENZY_TIME : clamp(round(FEED_DEFAULT_TIME / (1.25 * (level_current || 1))), 1, FEED_DEFAULT_TIME)
	owner.balloon_alert(owner, "feeding off [feed_target]...")
	if(!do_after(owner, feed_time, feed_target, NONE, TRUE))
		owner.balloon_alert(owner, "feed stopped")
		deactivate_power()
		return

	// Agressively grabbing a target will make them fall asleep and alert nearby people
	if(owner.pulling == feed_target && owner.grab_state == GRAB_AGGRESSIVE)
		feed_target.Unconscious((5 + level_current) SECONDS)
		owner.visible_message(
			span_warning("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
			span_warning("You sink your fangs into [feed_target]'s neck."))
		silent_feed = FALSE
	else
		var/dazed_message = feed_target.stat != DEAD ? "<i>[feed_target.p_they(TRUE)] looks dazed, and will not remember this.</i>" : ""
		owner.visible_message(
			span_notice("[owner] puts [feed_target]'s wrist up to [owner.p_their()] mouth."), \
			span_notice("You slip your fangs into [feed_target]'s wrist. [dazed_message]"), \
			vision_distance = FEED_SILENT_NOTICE_RANGE, ignored_mobs = feed_target)
		to_chat(feed_target, span_deconversionmessage("You don't remember how you got here..."))

	// Check if we were seen while feeding
	for(var/mob/living/watcher in oviewers(silent_feed ? FEED_SILENT_NOTICE_RANGE : FEED_LOUD_NOTICE_RANGE) - feed_target)
		if(!watcher.client)
			continue
		if(watcher.has_unlimited_silicon_privilege)
			continue
		if(watcher.stat >= DEAD)
			continue
		if(watcher.is_blind() || HAS_TRAIT(watcher, TRAIT_NEARSIGHT))
			continue
		if(IS_VAMPIRE(watcher) || IS_VASSAL(watcher))
			continue

		owner.balloon_alert(owner, "feed noticed!")
		vampiredatum_power.give_masquerade_infraction()
		break

	ADD_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_FEED)
	ADD_TRAIT(owner, TRAIT_MUTE, TRAIT_FEED)

/datum/action/cooldown/vampire/targeted/feed/UsePower()
	var/mob/living/user = owner
	var/mob/living/feed_target = target_ref.resolve()

	if(!ContinueActive())
		if(!silent_feed)
			user.visible_message(
				span_warning("[user] is ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"),
				span_warning("Your teeth are ripped from [feed_target]'s throat. [feed_target.p_their(TRUE)] blood sprays everywhere!"))

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
	blood_taken += vampiredatum_power.handle_feeding(feed_target, feed_strength_mult, level_current)

	// Mood events
	if(vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !feed_target.mind) // Snobby
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
	else if(feed_target.stat == DEAD) // Dead
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
	else // Normal
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood)

	// Alert the vampire to the target's blood level
	if(feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
		owner.balloon_alert(owner, "your victim's blood is fatally low!")
	else if(feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
		owner.balloon_alert(owner, "your victim's blood is dangerously low.")
	else if(feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
		owner.balloon_alert(owner, "your victim's blood is at an unsafe level.")
	warning_target_bloodvol = feed_target.blood_volume

	// Check if full on blood
	if(vampiredatum_power.vampire_blood_volume >= vampiredatum_power.max_blood_volume)
		user.balloon_alert(owner, "full on blood!")
		power_activated_sucessfully()
		return

	// Check if target has an acceptable amount of blood left
	if(feed_target.blood_volume <= 10)
		user.balloon_alert(owner, "no blood left!")
		power_activated_sucessfully()
		return

	// Play heartbeat sound effect to vampire (and maybe target)
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	if(!silent_feed)
		feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/datum/action/cooldown/vampire/targeted/feed/deactivate_power()
	. = ..()

	if(target_ref)
		var/mob/living/feed_target = target_ref.resolve()
		log_combat(owner, feed_target, "fed on blood", addition="(and took [blood_taken] blood)")
		to_chat(owner, span_notice("You slowly release [feed_target]."))
		if(feed_target.stat == DEAD)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled)
	target_ref = null

	warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	blood_taken = 0

	REMOVE_TRAIT(owner, TRAIT_IMMOBILIZED, TRAIT_FEED)
	REMOVE_TRAIT(owner, TRAIT_MUTE, TRAIT_FEED)

#undef FEED_NOTICE_RANGE
#undef FEED_DEFAULT_TIME
#undef FEED_BLOOD_FROM_MICE
