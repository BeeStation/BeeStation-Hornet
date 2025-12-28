/datum/antagonist/vigilante
	name = "Fanatic Vigilante"
	antagpanel_category = "Vigilante"
	banning_key = ROLE_VIGILANTE
	required_living_playtime = 10
	var/datum/component/uplink/uplink

/datum/antagonist/vigilante/greet()
	to_chat(owner.current, span_userdanger("You are a fanatic vigilante!"))
	to_chat(owner.current, span_bold("This world... This world is ruled by criminals. A violent underworld dances amongst the peaceful happenings of the station, ruining the purity of our new system. It is up to you to take matters into your own hands, when anyone gets arrested you shall shine true justice upon their hearts, and as for the infiltrator rumoured to be on-board... You shall show them what it truly means to mess with Nanotrasen."))
	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Fanatic Vigilante", "Investigate and uncover the station's infiltrator, elimating any small-fry criminals along the way.")
	uplink = owner.equip_standard_uplink(silent = TRUE, uplink_owner = src, telecrystals = 0, directive_flags = NONE)
	uplink.reputation = 0
	to_chat(owner.current, span_bold("You have managed to obtain access to the Syndicate market. Perhaps you could use this illegal equipment against the very people who brought it to this station..."))
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

/datum/priority_directive/assassination/justice/_allocate_teams(list/uplinks, list/player_minds, force)
	reject()

/datum/priority_directive/assassination/justice/badcop
	details = "Corruption runs wild within the station's prison system. Teach %NAME% a lesson about inputing prisoner details correctly through death."
