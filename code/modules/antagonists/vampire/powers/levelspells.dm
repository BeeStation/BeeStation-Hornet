/**
 * Given to Vampires at the start and taken away as soon as they select a clan.
 */
/datum/action/vampire/clanselect
	name = "Select Clan"
	desc = "Take the first step as a true kindred and remember your true lineage."
	button_icon_state = "clanselect"
	power_explanation = "Activate to select your unique vampire clan."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/clanselect/activate_power()
	. = ..()
	vampiredatum_power.assign_clan_and_bane()
	deactivate_power()

/**
 * Given to Vampires every levelup. Opens the radial.
 */
/datum/action/vampire/levelup
	name = "Level Up"
	desc = "Take another step as a full kindred, and remember your true lineage."
	button_icon_state = "power_levelup"
	power_explanation = "Activate to level one of your disciplines."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 5 SECONDS

/datum/action/vampire/levelup/activate_power()
	. = ..()
	vampiredatum_power.my_clan.spend_rank()
	deactivate_power()

/**
 * Given to Princes once chosen. Picks a scourge.
 */
/datum/action/vampire/targeted/scourgify
	name = "Select Scourge"
	desc = "Select another kindred or one of your vassals as your scourge."
	button_icon_state = "power_scourge"
	power_explanation = "Activate to select another kindred, or one of your vassals, as your personal scourge.\n\n\
						When used on another kindred, they will receive some levels and an objective to obey you.\n\
						When used on your vassal, you will become their sire, embracing them as a full-blooded vampire.\n\
						They will be part of your own clan, and of course receive some bonus levels as well.\n\n\
						The Scourge is your enforcer, your tool to wield in the name of the camarilla. Use them to enforce the masquerade, and to keep control over your fellow kindred."
	power_flags = BP_AM_SINGLEUSE
	check_flags = BP_CANT_USE_IN_TORPOR | BP_CANT_USE_IN_FRENZY | BP_CANT_USE_WHILE_STAKED | BP_CANT_USE_WHILE_INCAPACITATED | BP_CANT_USE_WHILE_UNCONSCIOUS
	vitaecost = 0
	cooldown_time = 35 SECONDS
	power_activates_immediately = FALSE
	prefire_message = "Whom will you choose?"

	/// Reference to the target antag datum
	var/datum/weakref/target_ref

/datum/action/vampire/targeted/scourgify/check_valid_target(atom/target_atom)
	. = ..()
	if(!isliving(target_atom))
		return FALSE

	var/mob/living/living_target = target_atom
	var/datum/antagonist/vampire/target_vampire = IS_VAMPIRE(living_target)

	// No mind
	if(!living_target.mind)
		owner.balloon_alert(owner, "mindless")
		return FALSE

	// No client
	if(!living_target.client)
		owner.balloon_alert(owner, "not a player")
		return FALSE

	// Is our target alive or unconcious?
	if(living_target.stat != CONSCIOUS)
		owner.balloon_alert(owner, "not [(living_target.stat == DEAD || HAS_TRAIT(living_target, TRAIT_FAKEDEATH)) ? "alive" : "conscious"]")
		return FALSE

	if(IS_VASSAL(living_target) && !(IS_VASSAL(living_target) in vampiredatum_power.vassals)) // Only our own vassal may be promoted.
		owner.balloon_alert(owner, "not your vassal")
		return FALSE

	if(!IS_VAMPIRE(living_target) && !IS_VASSAL(living_target))
		owner.balloon_alert(owner, "not vassal or vampire")
		return FALSE

	if(target_vampire && (target_vampire.prince || target_vampire.scourge))
		owner.balloon_alert(owner, "cannot promote elders!")
		return FALSE

	if(target_ref) // Already offering
		owner.balloon_alert(owner, "already offering!")
		return FALSE

	return TRUE

/datum/action/vampire/targeted/scourgify/FireTargetedPower(atom/target_atom)
	. = ..()
	var/mob/living/living_target = target_atom

	if(IS_VASSAL(living_target)) // We don't need to ask a lowly vassal.
		living_target.mind.remove_antag_datum(/datum/antagonist/vassal)

		// Make, then give the datum
		var/datum/antagonist/vampire/scourgedatum = new(living_target.mind)
		living_target.mind.add_antag_datum(scourgedatum)

		// Pull them into our clan
		var/datum/vampire_clan/masterclan_type = vampiredatum_power.my_clan.type

		if(!masterclan_type) // How did a caitiff get prince, bro. Fine.
			owner.balloon_alert(owner, "select clan first!")
			deactivate_power()

		scourgedatum.my_clan = new masterclan_type(scourgedatum)
		scourgedatum.my_clan.on_apply()

		// Scourgify and end power
		scourgedatum.scourgify()
		target_ref = null
		power_activated_sucessfully()
	else
		target_ref = WEAKREF(IS_VAMPIRE(living_target))

		tgui_alert_async(living_target,
		message = "Your Prince has selected you as their enforcer. Should you accept, you will receive the rank of 'Scourge', be bound to their authority, and increase in power considerably.",
		title = "Scourge Offer",
		buttons = list("Accept", "Refuse"),
		callback = CALLBACK(src, PROC_REF(handle_choice)),
		timeout = cooldown_time - 5 SECONDS,
		autofocus = TRUE
		)

	addtimer(CALLBACK(src, PROC_REF(choice_timeout)), cooldown_time)
	deactivate_power()

/datum/action/vampire/targeted/scourgify/proc/accepted()
	var/datum/antagonist/vampire/target_datum = target_ref.resolve()
	target_datum.scourgify()
	target_ref = null
	power_activated_sucessfully()

/datum/action/vampire/targeted/scourgify/proc/refused()
	owner.balloon_alert(owner, "offer refused")
	target_ref = null

/datum/action/vampire/targeted/scourgify/proc/choice_timeout()
	if(owner && target_ref) // This might happen AFTER we remove the power from our owner.
		owner.balloon_alert(owner, "offer ignored")
		target_ref = null

/datum/action/vampire/targeted/scourgify/proc/handle_choice(choice)
	switch(choice)
		if("Accept")
			accepted()
			return
		if("Refuse")
			refused()
			return
