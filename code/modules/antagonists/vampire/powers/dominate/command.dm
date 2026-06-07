/**
 *	Command
 *	 Gives a one-word brainwash-command to a target for 60 seconds.
 * 	Level 2: Now lasts 180 seconds.
 */
/datum/action/vampire/targeted/command
	name = "Command"
	desc = "Dominate the mind of a mortal with a simple verbal command."
	button_icon_state = "power_command"
	power_explanation = "Click any player to attempt to compell them.\n\
		If your target is already commanded or a Curator, you will fail.\n\
		Once commanded, the target will do their best to fulfill it, with a duration scaling with level.\n\
		At level 1, your command will stay for 60 seconds.\n\
		At level 2, it will remain for 3 minutes.\n\
		Be smart with your wording. They will become pacified, and won't obey violent commands."
	power_flags = NONE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 120
	cooldown_time = 80 SECONDS
	target_range = 6
	power_activates_immediately = FALSE
	prefire_message = "Whom will you subvert to your will?"

	var/power_time = 60 SECONDS

	/// Reference to the target
	var/datum/weakref/target_ref

/datum/action/vampire/targeted/command/two
	name = "Command"
	power_time = 180 SECONDS
	vitaecost = 240
	cooldown_time = 200 SECONDS

/datum/action/vampire/targeted/command/can_use()
	. = ..()
	if(!.)
		return FALSE
	var/mob/living/carbon/carbon_owner = owner

	// Must have ears
	if(!owner.get_organ_slot(ORGAN_SLOT_TONGUE))
		to_chat(owner, span_warning("You have no tongue with which to command!"))
		return FALSE

	// Must have mouth unobstructed
	if(carbon_owner.is_mouth_covered() || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "your mouth is blocked.")
		return FALSE

	if(HAS_TRAIT(carbon_owner, TRAIT_MUTE) || !isturf(carbon_owner.loc))
		owner.balloon_alert(owner, "you cannot speak!")
		return FALSE
	return TRUE

/datum/action/vampire/targeted/command/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	// Must be a carbon or silicon
	if(!iscarbon(target_atom) && !issilicon(target_atom))
		return FALSE
	var/mob/living/living_target = target_atom

	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "[living_target] is mindless.")
		return FALSE

	// Vampire/Curator check
	if(IS_CURATOR(living_target))
		owner.balloon_alert(owner, "too powerful.")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "[living_target] is not [(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"].")
		return FALSE

	// Is our target deaf?
	if(!living_target.get_organ_slot(ORGAN_SLOT_EARS))
		owner.balloon_alert(owner, "[living_target] cannot hear you!")
		return FALSE

	// Is our target a silicon?
	if(issilicon(living_target))
		owner.balloon_alert(owner, "[living_target] cannot be compelled!")
		return FALSE

	// Already commanded?
	if(living_target.has_status_effect(/datum/status_effect/commanded))
		owner.balloon_alert(owner, "[living_target] is already compelled!")
		return FALSE

/datum/action/vampire/targeted/command/FireTargetedPower(atom/target_atom)
	. = ..()

	var/mob/living/living_target = target_atom
	target_ref = WEAKREF(living_target)

	owner.balloon_alert(owner, "commanding [living_target]...")

	var/command = get_single_word_command()

	if(!command)
		deactivate_power()
		return

	// They left while we were writing
	if(!(living_target in hearers(6, owner)))
		deactivate_power()
		return

	// Put the objective list together
	var/list/brainwash_list = list()
	brainwash_list += "[command]!"

	//Actually command them now
	owner.say(command)

	var/power_time_adjusted = FALSE
	if(HAS_TRAIT(living_target, TRAIT_MINDSHIELD))
		power_time /= 2
		power_time_adjusted = TRUE

	if(IS_VAMPIRE(living_target))
		var/datum/antagonist/vampire/target_vampdatum = IS_VAMPIRE(living_target)
		if(target_vampdatum.vampire_level > vampiredatum_power.vampire_level)
			owner.balloon_alert(owner, "kindred stronger than you.")
			deactivate_power()
			return

	living_target.apply_status_effect(/datum/status_effect/commanded, owner, command, power_time)

	if(power_time_adjusted)
		power_time *= 2
		power_time_adjusted = FALSE

	power_activated_sucessfully() // PAY COST! BEGIN COOLDOWN!

/datum/action/vampire/targeted/command/proc/get_single_word_command()
	. = TRUE
	var/command = tgui_input_text(owner, "What would you like to command?", "Input a command", "STOP", encode = FALSE, timeout = 2 MINUTES)
	if(QDELETED(src))
		return FALSE
	if(CHAT_FILTER_CHECK(command))
		to_chat(owner, span_warning("The command '[span_boldname("[command]")]' is forbidden!"))
		return FALSE
	if(findtext(command, " "))
		to_chat(owner, span_warning("Please only input a single word."))
		return FALSE
	if(length_char(command) > 7)
		to_chat(owner, span_warning("Command too long!"))
		return FALSE
	// qol to avoid confusion
	if(copytext(command, 1, 5) == "kill" || copytext(command, 1, 7) == "murder" || copytext(command, 1, 8) == "suicide" || copytext(command, 1, 4) == "die")
		owner.balloon_alert(owner, "that won't work!")
		to_chat(owner, span_warning(" * Remember, victims will be pacified for the duration of the command!"))
		return FALSE

	return(command)

/datum/action/vampire/targeted/command/continue_active()
	. = ..()
	if(!.)
		return FALSE

	if(!can_use())
		return FALSE

	var/mob/living/living_target = target_ref?.resolve()
	if(!living_target || !check_valid_target(living_target))
		return FALSE

/datum/action/vampire/targeted/command/deactivate_power()
	. = ..()
	target_ref = null

/datum/status_effect/commanded
	id = "commanded"
	duration = 1 MINUTES
	tick_interval = STATUS_EFFECT_NO_TICK
	on_remove_on_mob_delete = TRUE
	alert_type = null
	/// The vampire that casted this command.
	var/mob/living/caster
	/// The actual command used for the objective.
	var/command
	/// The brainwash objectives, so we can unbrainwash when it ends.
	var/list/directives

/datum/status_effect/commanded/on_creation(mob/living/new_owner, mob/living/caster, command, duration)
	src.caster = caster
	src.command = command
	if(duration)
		src.duration = duration
	return ..()

/datum/status_effect/commanded/on_apply()
	ADD_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	directives = brainwash(owner, "[command]!", "[caster.real_name]'s Command")

	// make sure they have a moment to realize what's going on
	owner.Immobilize(2 SECONDS, TRUE)
	to_chat(owner, "<br>" + span_awe("<font size='15'>[command]!</font>") + "<br>", type = MESSAGE_TYPE_WARNING)

	// also log it.
	message_admins("[ADMIN_LOOKUPFLW(caster)] used the COMMAND ability on [ADMIN_LOOKUPFLW(owner)], commanding them to [command].")
	log_game("[key_name(caster)] used the command ability on [key_name(owner)], commanding them to [command].")

	/* owner.AddElement(/datum/element/relay_attackers)
	RegisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED, PROC_REF(on_attacked)) */
	return TRUE

/datum/status_effect/commanded/on_remove()
	/* UnregisterSignal(owner, COMSIG_ATOM_WAS_ATTACKED) */
	REMOVE_TRAIT(owner, TRAIT_PACIFISM, TRAIT_STATUS_EFFECT(id))
	unbrainwash(owner, directives)
	directives = null
	owner.balloon_alert(caster, "[owner] snapped out of [owner.p_their()] trance!")
	caster = null

/* /datum/status_effect/commanded/proc/on_attacked(datum/source, atom/attacker, attack_flags)
	SIGNAL_HANDLER
	if(attacker != caster || !(attack_flags & ATTACKER_DAMAGING_ATTACK))
		return
	if(owner.pulledby == caster)
		caster.stop_pulling()
	owner.SetAllImmobility(0)
	if(caster.Adjacent(owner)) // give them a split second to run away
		caster.Stun(0.5 SECONDS, TRUE)
	to_chat(owner, span_awe(span_reallybig("You quickly come back to your senses as you're hit by [attacker]!")))
	qdel(src) */
