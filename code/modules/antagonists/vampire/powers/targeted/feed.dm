#define FEED_NOTICE_RANGE 7
#define FEED_DEFAULT_TIME 10 SECONDS
#define FEED_FRENZY_TIME 2 SECONDS
#define FEED_BLOOD_FROM_MICE 25

/datum/action/vampire/targeted/feed
	name = "Feed"
	desc = "Feed blood off of a living creature."
	button_icon_state = "power_feed"
	power_explanation = "Activate Feed and select a target to start draining their blood.\n\
		The time needed before you start feeding decreases the higher level you are.\n\
		You <b>must</b> be aggressively grabbing your target to feed off of them.\n\
		Mice can be fed off if you are in desperate need of blood.\n\
		<b>IMPORTANT:</b> You are given a Masquerade Infraction if a mortal witnesses you while feeding."
	power_flags = BP_AM_TOGGLE | BP_AM_STATIC_COOLDOWN
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	purchase_flags = VAMPIRE_CAN_BUY | VAMPIRE_DEFAULT_POWER
	cooldown_time = 15 SECONDS
	target_range = 1
	prefire_message = "Select a target."
	power_activates_immediately = FALSE

	/// Amount of blood taken, reset after each Feed. Used for logging.
	var/blood_taken = 0
	/// The amount of Blood a target has since our last feed, this loops and lets us not spam alerts of low blood.
	var/warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	/// Reference to the target we are feeding off of
	var/datum/weakref/target_ref
	/// Have we received a masquerade infraction for this current feed?
	var/has_received_infraction = FALSE

/datum/action/vampire/targeted/feed/can_use()
	. = ..()
	if(!.)
		return FALSE

	// Already feeding
	if(target_ref)
		return FALSE
	// Mouth covered
	var/mob/living/carbon/carbon_owner = owner
	if(carbon_owner.is_mouth_covered() && !isplasmaman(carbon_owner))
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
			target.balloon_alert(owner, "too disgusting!")
			return FALSE
		else
			return TRUE
	// Has to be human or a monkey
	if(!ishuman(target) && !ismonkey(target))
		target.balloon_alert(owner, "can't feed off!")
		return FALSE
	// Mindless and snobby?
	if(!target.mind && vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !vampiredatum_power.frenzied)
		target.balloon_alert(owner, "can't drink from the mindless!")
		return FALSE
	// Cannot be a curator or vampire
	if(IS_VAMPIRE(target) || IS_CURATOR(target))
		target.balloon_alert(owner, "[target] is too powerful!")
		return FALSE

	// Check grab state
	if(owner.pulling != target || owner.grab_state != GRAB_AGGRESSIVE)
		target.balloon_alert(owner, "must be aggressively grabbed!")
		return FALSE

	// Human checks
	if(ishuman(target))
		// Cannot drink from inorganics
		var/mob/living/carbon/human/human_target = target
		if(!human_target.dna?.species || !(human_target.mob_biotypes & MOB_ORGANIC))
			target.balloon_alert(owner, "no blood!")
			return FALSE
		// Cannot be wearing super thick gear
		if(!human_target.can_inject(owner, BODY_ZONE_HEAD, INJECT_CHECK_PENETRATE_THICK))
			target.balloon_alert(owner, "suit too thick!")
			return FALSE

/datum/action/vampire/targeted/feed/FireTargetedPower(atom/target_atom)
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

	if(!do_after(owner, feed_time, feed_target, hidden = TRUE))
		owner.balloon_alert(owner, "interrupted!")
		deactivate_power()
		return

	// Make it obvious we are feeding
	feed_target.Unconscious((5 + level_current) SECONDS, ignore_canstun = TRUE)
	feed_target.set_jitter((5 + level_current) SECONDS)

	owner.visible_message(
		span_userdanger("[owner] closes [owner.p_their()] mouth around [feed_target]'s neck!"),
		span_boldwarning("You sink your fangs into [feed_target]'s neck.")
	)

	// Check if we were seen while feeding
	has_received_infraction = FALSE
	check_masquerade_infraction()

	owner.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_MUTE, TRAIT_HANDS_BLOCKED), TRAIT_FEED)
	feed_target.add_traits(list(TRAIT_IMMOBILIZED, TRAIT_HANDS_BLOCKED), TRAIT_FEED)

/datum/action/vampire/targeted/feed/UsePower()
	var/mob/living/feed_target = target_ref?.resolve()
	if(!feed_target)
		power_activated_sucessfully()
		return

	// Check if our feed target was moved, if so, let's get freaky
	if(!continue_active())
		owner.visible_message(
			span_boldwarning("[owner] is ripped from [feed_target]'s throat. [feed_target.p_Their()] blood sprays everywhere!"),
			span_boldwarning("Your teeth are ripped from [feed_target]'s throat. [feed_target.p_Their()] blood sprays everywhere!"),
		)

		// Time to start bleeding
		feed_target.bleed(15)
		playsound(feed_target, 'sound/effects/splat.ogg', 40, TRUE)
		if(ishuman(feed_target))
			var/mob/living/carbon/human/human_victim = feed_target
			human_victim.add_bleeding(BLEED_CRITICAL)

		feed_target.add_splatter_floor(get_turf(feed_target))
		owner.add_mob_blood(feed_target)
		feed_target.add_mob_blood(feed_target)

		// Ow
		feed_target.apply_damage(10, BRUTE, BODY_ZONE_HEAD)
		feed_target.emote("scream")

		power_activated_sucessfully()
		return

	// This is for alerting people that the person is being fed off of
	feed_target.SetUnconscious((5 + level_current) SECONDS, ignore_canstun = TRUE)
	feed_target.set_jitter((5 + level_current) SECONDS)
	playsound(feed_target, 'sound/items/drink.ogg', 10, TRUE)

	// Deal with blood (the actual feeding)
	handle_feeding(feed_target, (vampiredatum_power.frenzied ? 2 : 1))

	// Check if we were seen while feeding
	check_masquerade_infraction()

	// Mood events
	if (vampiredatum_power.my_clan?.blood_drink_type == VAMPIRE_DRINK_SNOBBY && !feed_target.mind)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
	else if (feed_target.stat == DEAD)
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood_bad)
	else
		SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankblood", /datum/mood_event/drankblood)

	// Alert the vampire to the target's blood level
	if (feed_target.blood_volume <= BLOOD_VOLUME_BAD && warning_target_bloodvol > BLOOD_VOLUME_BAD)
		feed_target.balloon_alert(owner, "your victim's blood is fatally low!")
	else if (feed_target.blood_volume <= BLOOD_VOLUME_OKAY && warning_target_bloodvol > BLOOD_VOLUME_OKAY)
		feed_target.balloon_alert(owner, "your victim's blood is dangerously low.")
	else if (feed_target.blood_volume <= BLOOD_VOLUME_SAFE && warning_target_bloodvol > BLOOD_VOLUME_SAFE)
		feed_target.balloon_alert(owner, "your victim's blood is at an unsafe level.")
	warning_target_bloodvol = feed_target.blood_volume

	// Check if full on blood
	if(vampiredatum_power.vampire_blood_volume >= vampiredatum_power.max_blood_volume)
		owner.balloon_alert(owner, "full on blood!")
		power_activated_sucessfully()
		return

	// Check if target has an acceptable amount of blood left
	if(feed_target.blood_volume <= 10)
		feed_target.balloon_alert(owner, "no blood left!")
		power_activated_sucessfully()
		return

	// Play heartbeat sound effect to vampire and target
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)
	feed_target.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

/datum/action/vampire/targeted/feed/deactivate_power()
	. = ..()
	REMOVE_TRAITS_IN(owner, TRAIT_FEED)

	var/mob/living/feed_target = target_ref?.resolve()
	if(feed_target)
		REMOVE_TRAITS_IN(feed_target, TRAIT_FEED)

		log_combat(owner, feed_target, "fed on blood", addition = "(and took [blood_taken] blood)")
		to_chat(owner, span_notice("You slowly release [feed_target]."))

		if(feed_target.stat != DEAD)
			to_chat(owner, span_notice("<i>[feed_target.p_They()] look[feed_target.p_s()] dazed, and will not remember this.</i>"))
			to_chat(feed_target, span_bighypnophrase("You don't remember how you got here..."))

		if(feed_target.stat == DEAD)
			SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "drankkilled", /datum/mood_event/drankkilled)
	target_ref = null

	warning_target_bloodvol = BLOOD_VOLUME_MAXIMUM
	blood_taken = 0

/datum/action/vampire/targeted/feed/proc/handle_feeding(mob/living/carbon/target, mult = 1)
	var/feed_amount = 15 + (level_current * 2)
	var/blood_to_take = min(feed_amount * mult, target.blood_volume)

	// Remove target's blood
	target.blood_volume -= blood_to_take

	// Shift body temperature (toward target's temp, by volume taken)
	// ((vamp_blood_volume * vamp_temp) + (target_blood_volume * target_temp)) / (vamp_blood_volume + blood_to_take)
	owner.bodytemperature = ((vampiredatum_power.vampire_blood_volume * owner.bodytemperature) + (blood_to_take * target.bodytemperature)) / (vampiredatum_power.vampire_blood_volume + blood_to_take)

	// Penalty for dead blood
	if(target.stat == DEAD)
		blood_to_take /= 3
	// Penalty for non-human blood
	if(!ishuman(target))
		blood_to_take /= 2

	// Give vampire the blood
	vampiredatum_power.AddBloodVolume(blood_to_take)

	// Transfer the target's reagents into the vampire's blood
	if(target.reagents?.total_volume)
		target.reagents.trans_to(owner, INGEST, 1) // Run transfer of 1 unit of reagent from them to me.

	// Play heartbeat sound for flavor
	owner.playsound_local(null, 'sound/effects/singlebeat.ogg', 40, TRUE)

	vampiredatum_power.total_blood_drank += blood_to_take
	blood_taken += blood_to_take

/datum/action/vampire/targeted/feed/proc/check_masquerade_infraction()
	if (has_received_infraction)
		return

	var/mob/living/feed_target = target_ref?.resolve()
	for (var/mob/living/watcher in oviewers(FEED_NOTICE_RANGE, owner) - feed_target)
		if (!watcher.client)
			continue
		if (watcher.has_unlimited_silicon_privilege)
			continue
		if (watcher.stat != CONSCIOUS)
			continue
		if (watcher.is_blind() || HAS_TRAIT(watcher, TRAIT_NEARSIGHT))
			continue
		if (IS_VAMPIRE(watcher) || IS_VASSAL(watcher))
			continue

		owner.balloon_alert(owner, "feed noticed!")
		vampiredatum_power.give_masquerade_infraction()
		has_received_infraction = TRUE
		break

#undef FEED_NOTICE_RANGE
#undef FEED_DEFAULT_TIME
#undef FEED_FRENZY_TIME
#undef FEED_BLOOD_FROM_MICE
