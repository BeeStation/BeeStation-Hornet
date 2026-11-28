#define BORER_CONTROL_WINDUP (5 SECONDS)
#define BORER_MINDSHIELD_WINDUP_MULTIPLIER 5
#define BORER_CONTROL_RESIST_DURATION (12 SECONDS)
#define BORER_CONTROL_RESIST_COOLDOWN (45 SECONDS)
#define BORER_CONTROL_WEAK_AFTER (2 MINUTES)
#define BORER_CONTROL_WEAK_CHEMICALS 0.35

/mob/living/simple_animal/borer/proc/can_take_host_control(feedback = FALSE)
	if(controlling_host || stat != CONSCIOUS || !host || host.stat == DEAD || cyst?.zone != BODY_ZONE_HEAD || !has_evolution(/datum/borer_evolution/neural_domination))
		return FALSE
	if(world.time < next_host_control)
		if(feedback)
			to_chat(src, span_warning("Your host is still resisting your influence. You cannot attempt another takeover yet."))
		return FALSE
	if(!client || !host.client)
		if(feedback)
			to_chat(src, span_warning("Both you and your host must be present to exchange control."))
		return FALSE
	if(chemicals < control_activation_cost)
		if(feedback)
			to_chat(src, span_warning("You need [control_activation_cost] chemicals to seize control of your host."))
		return FALSE
	return TRUE

/mob/living/simple_animal/borer/proc/assume_host_control()
	if(control_attempt_ends_at || !can_take_host_control(feedback = TRUE))
		return
	control_attempt_duration = get_host_control_windup()
	control_attempt_ends_at = world.time + control_attempt_duration
	control_attempt_progress = new(src, control_attempt_duration, host)
	to_chat(src, span_notice("You begin threading your influence into your host's mind."))
	if(HAS_TRAIT(host, TRAIT_MINDSHIELD))
		to_chat(src, span_warning("Your host's mindshield obstructs your influence. Forcing your will past the implant will take twenty-five seconds."))
	to_chat(host, span_userdanger("Something presses against your thoughts, trying to seize control of your body! Use RESIST now to fight back!"))

/mob/living/simple_animal/borer/proc/get_host_control_windup()
	return BORER_CONTROL_WINDUP * (HAS_TRAIT(host, TRAIT_MINDSHIELD) ? BORER_MINDSHIELD_WINDUP_MULTIPLIER : 1)

/// Implanting or removing a mindshield during takeover preserves elapsed time.
/mob/living/simple_animal/borer/proc/update_control_windup()
	if(!control_attempt_ends_at)
		return
	var/required_duration = get_host_control_windup()
	if(required_duration == control_attempt_duration)
		return
	if(required_duration > control_attempt_duration)
		to_chat(src, span_warning("A mindshield pushes back against your influence, slowing your takeover."))
	control_attempt_ends_at += required_duration - control_attempt_duration
	control_attempt_duration = required_duration
	QDEL_NULL(control_attempt_progress)
	control_attempt_progress = new(src, control_attempt_duration, host)

/// Resisting during the windup carries through into possession.
/mob/living/simple_animal/borer/proc/is_host_control_weak()
	return control_attempt_ends_at || (controlling_host && (chemicals < max_chemicals * BORER_CONTROL_WEAK_CHEMICALS || world.time - control_started_at > BORER_CONTROL_WEAK_AFTER))

/mob/living/simple_animal/borer/proc/on_host_resist(mob/living/source)
	SIGNAL_HANDLER
	begin_control_resistance(source)

/mob/living/simple_animal/borer/proc/begin_control_resistance(mob/living/resister)
	if((controlling_host && resister != host_backseat) || (!controlling_host && (!control_attempt_ends_at || resister != host)))
		return FALSE
	if(control_resist_ends_at)
		to_chat(resister, span_notice("You are already fighting its influence. Keep focusing!"))
		return FALSE
	if(!is_host_control_weak())
		to_chat(resister, span_boldwarning("You try to resist, but it is no use. No matter how you struggle, the presence holds your mind in an unyielding grip!"))
		return FALSE
	control_resist_ends_at = world.time + BORER_CONTROL_RESIST_DURATION
	update_control_resistance_progress()
	to_chat(resister, span_usernotice("You focus on pushing the foreign presence out of your mind. Keep fighting for twelve seconds to reclaim your body!"))
	to_chat(controlling_host ? host : src, span_warning("Your host is fighting your influence!"))
	return TRUE

/// Uses an absolute deadline so movement, stuns and the mind transfer do not reset the struggle.
/mob/living/simple_animal/borer/proc/process_host_control()
	if(!controlling_host && !control_attempt_ends_at)
		return
	if(control_resist_ends_at)
		update_control_resistance_progress()
		if(world.time >= control_resist_ends_at)
			if(controlling_host)
				to_chat(host_backseat, span_usernotice("You wrench the foreign presence from your thoughts and reclaim control of your body!"))
				to_chat(host, span_userdanger("Your host fights through your influence. Your control slips!"))
				release_host_control()
			else
				to_chat(host, span_usernotice("You drive the foreign presence from your thoughts before it can seize control!"))
				to_chat(src, span_userdanger("Your host repels your takeover attempt!"))
				clear_host_control_state()
			return
	if(control_attempt_ends_at)
		if(!can_take_host_control())
			to_chat(host, span_notice("The pressure against your thoughts recedes."))
			clear_host_control_state()
			return
		update_control_windup()
		control_attempt_progress?.update(control_attempt_duration - max(0, control_attempt_ends_at - world.time))
		if(world.time >= control_attempt_ends_at && !take_host_control())
			clear_host_control_state()
			return
	if(controlling_host && !control_resist_ends_at && !control_weak_notice_sent && is_host_control_weak())
		control_weak_notice_sent = TRUE
		to_chat(host_backseat, span_userdanger("You feel the tendrils gripping your mind begin to slacken... Use RESIST to fight for control!"))

/mob/living/simple_animal/borer/proc/update_control_resistance_progress()
	if(!control_resist_ends_at || !host)
		return
	var/mob/resister = controlling_host ? host_backseat : host
	if(!control_resist_progress)
		control_resist_progress = new(resister, BORER_CONTROL_RESIST_DURATION, host)
	control_resist_progress.update(BORER_CONTROL_RESIST_DURATION - max(0, control_resist_ends_at - world.time))

/mob/living/simple_animal/borer/proc/clear_host_control_state()
	// Releasing early must not let the borer reset an ongoing struggle with another takeover.
	if(control_resist_ends_at)
		next_host_control = world.time + BORER_CONTROL_RESIST_COOLDOWN
		assume_control_action?.start_cooldown(BORER_CONTROL_RESIST_COOLDOWN)
	control_attempt_ends_at = 0
	control_attempt_duration = 0
	control_started_at = 0
	control_resist_ends_at = 0
	control_weak_notice_sent = FALSE
	QDEL_NULL(control_attempt_progress)
	QDEL_NULL(control_resist_progress)

#undef BORER_CONTROL_WINDUP
#undef BORER_MINDSHIELD_WINDUP_MULTIPLIER
#undef BORER_CONTROL_RESIST_DURATION
#undef BORER_CONTROL_RESIST_COOLDOWN
#undef BORER_CONTROL_WEAK_AFTER
#undef BORER_CONTROL_WEAK_CHEMICALS
