/datum/antagonist/vigilante
	name = "Fanatic Vigilante"
	antagpanel_category = "Vigilante"
	banning_key = ROLE_VIGILANTE
	required_living_playtime = 10
	var/datum/component/uplink/uplink

/datum/antagonist/vigilante/greet()
	to_chat(owner.current, span_userdanger("You are a fanatic vigilante!"))
	to_chat(owner.current, "<span class='secradio'>This world... This world is ruled by <b>criminals</b>. A violent underworld dances amongst the peaceful happenings of the station, ruining the purity of our new system. <b>It is up to you to take matters into your own hands</b>, when anyone gets <b>arrested</b> you shall shine <b>true justice</b> upon their hearts, and as for the infiltrator rumoured to be on-board... You shall show them what it truly means to mess with Nanotrasen.</span>")

	var/datum/objective/escape/escape = new
	escape.owner = owner
	objectives += escape
	log_objective(owner, escape.explanation_text)

	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Fanatic Vigilante", "Investigate and uncover the station's infiltrator, elimating any small-fry criminals along the way.")
	// Start with 3 TC, enough to buy some extremely basic rubbish if you have an idea, but still few enough that you have to mostly rely on your job.
	uplink = owner.equip_standard_uplink(silent = TRUE, uplink_owner = src, telecrystals = 3, directive_flags = NONE)
	uplink.reputation = 0
	// This is a really light antagonist, you are not going to be making a big impact at all
	uplink.directive_tc_multiplier = 0.35
	to_chat(owner.current, "<span class='secradio'>You have managed to <b>obtain access</b> to <b>the Syndicate market</b>. Perhaps you could use this illegal equipment against the very people who brought it to this station, however as an outsider you will be unable to gain any reputation. The uplink came with a message:</span><br>[span_traitorobjective(uplink.unlock_text)]")
	RegisterSignal(uplink, COMSIG_QDELETING, PROC_REF(deconvert))
	RegisterSignal(SSdcs, COMSIG_GLOB_PRISONER_REGISTERED, PROC_REF(on_prisoner_created))

/datum/antagonist/vigilante/farewell()
	. = ..()
	if (uplink)
		QDEL_NULL(uplink)
	to_chat(owner.current, span_userdanger("You are no longer the fanatic vigilante!"))
	to_chat(owner.current, span_bold("Whether it be through capture or incompetence, you have failed your mission. Without your uplink, you have lost all leverage over the criminals and are forced into hiding. Crime has won, justice has lost..."))
	UnregisterSignal(SSdcs, COMSIG_GLOB_PRISONER_REGISTERED)

/datum/antagonist/vigilante/proc/deconvert()
	uplink = null
	owner.remove_antag_datum(/datum/antagonist/vigilante)

/datum/antagonist/vigilante/proc/on_prisoner_created(datum/source, mob/user, desired_name, desired_crime, desired_sentence)
	SIGNAL_HANDLER
	var/mob/living/target = null
	var/datum/priority_directive/assassination/justice
	for (var/datum/mind/mind in SSticker.minds)
		if (mind.name == desired_name || findtext(mind.name, desired_name) || findtext(desired_name, mind.name))
			if (!mind.current)
				return
			// Justice doesn't apply to you
			if (mind == owner)
				return
			justice = new /datum/priority_directive/assassination/justice
			target = mind.current
			break
	if (target == null)
		justice = new /datum/priority_directive/assassination/justice/badcop
		target = user
	if (!target)
		return
	justice.details = replacetext(justice.details, "%NAME%", desired_name)
	justice.details = replacetext(justice.details, "%CRIME%", desired_crime)
	justice.set_target(target)
	var/list/uplink_team = list(uplink)
	justice.add_antagonist_team(uplink_team)
	justice.start(uplink_team)
	SSdirectives.active_directives += justice

/datum/priority_directive/assassination/justice
	details = "The prison registrar has found %NAME% guilty of %CRIME%, an offense that cannot go unpunished if society is to propser. Eliminate them, and show them the meaning of justice."
	last_for = INFINITY
	reputation_reward = 0
	reputation_loss = 0

/datum/priority_directive/assassination/justice/_allocate_teams(list/uplinks, list/player_minds, force)
	reject()

/datum/priority_directive/assassination/justice/badcop
	details = "Corruption runs wild within the station's prison system. Teach %NAME% a lesson about inputing prisoner details correctly through death."
