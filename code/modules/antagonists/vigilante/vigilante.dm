/datum/antagonist/vigilante
	name = "Fanatic Vigilante"
	antagpanel_category = "Vigilante"
	roundend_category = "Vigilantes"
	banning_key = ROLE_VIGILANTE
	required_living_playtime = 10
	var/datum/component/uplink/uplink
	var/list/justice_delivered = list()

/datum/antagonist/vigilante/greet()
	var/stash_location = create_stash()
	to_chat(owner.current, span_userdanger("You are a fanatic vigilante!"))
	to_chat(owner.current, "<span class='secradio'>This world... This world is ruled by <b>criminals</b>. A violent underworld dances amongst the peaceful happenings of the station, ruining the purity of our new system. <b>It is up to you to take matters into your own hands!</b></span>")
	to_chat(owner.current, {"<span class='secradio'><ul style='display: flex; flex-direction: column'>
		<li>You will gain a kill directive on anyone who gets put in prison.</li>
		<li>You will gain a kill directive on anyone who gets marked for arrest.</li>
		<li>Find the station's key infiltrator and ensure they fail their objectives.</li>
		<li>You have some information that might be of use to you [stash_location].</li>
	</ul></span>"})

	var/datum/objective/prevent_greentext/prevent_greentext = new
	prevent_greentext.owner = owner
	objectives += prevent_greentext
	log_objective(owner, prevent_greentext.explanation_text)

	var/datum/objective/escape/escape = new
	escape.owner = owner
	objectives += escape
	log_objective(owner, escape.explanation_text)

	owner.announce_objectives()
	owner.current.client?.tgui_panel?.give_antagonist_popup("Fanatic Vigilante", "Investigate and uncover the station's infiltrator, elimating any small-fry criminals along the way.")
	// Start with some TC, enough to buy some extremely basic rubbish if you have an idea, but still few enough that you have to mostly rely on your job.
	uplink = owner.equip_standard_uplink(employer = "You", silent = TRUE, uplink_owner = src, telecrystals = TELECRYSTALS_VIGILANTE, directive_flags = NONE)
	uplink.reputation = 0
	to_chat(owner.current, "<span class='secradio'>You have managed to <b>obtain access</b> to <b>the Syndicate market</b>. Perhaps you could use this illegal equipment against the very people who brought it to this station, however as an outsider you will be unable to gain any reputation. The uplink came with a message:</span><br>[span_traitorobjective(uplink.unlock_text)]")
	RegisterSignal(uplink, COMSIG_QDELETING, PROC_REF(deconvert))
	RegisterSignal(SSdcs, COMSIG_GLOB_PRISONER_REGISTERED, PROC_REF(on_prisoner_created))
	RegisterSignal(SSdcs, COMSIG_GLOB_WANTED_STATUS_CHANGED, PROC_REF(on_wanted_level_changed))
	RegisterSignal(SSdcs, COMSIG_GLOB_JOB_AFTER_SPAWN, PROC_REF(on_job_spawned))
	// Register all the prisoners who are already here
	for (var/datum/mind/mind in SSticker.minds)
		var/datum/job/job = SSjob.GetJob(mind.assigned_role)
		if (!job)
			continue
		if (!mind.current)
			continue
		on_job_spawned(src, job, mind.current, mind.current, FALSE)

/datum/antagonist/vigilante/apply_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_added()

/datum/antagonist/vigilante/remove_innate_effects(mob/living/mob_override)
	. = ..()
	update_traitor_icons_removed()

/datum/antagonist/vigilante/proc/update_traitor_icons_added()
	var/datum/atom_hud/antag/hudicon = GLOB.huds[ANTAG_HUD_VIGILANTE]
	hudicon.join_hud(owner.current)
	set_antag_hud(owner.current, "vigilante")

/datum/antagonist/vigilante/proc/update_traitor_icons_removed()
	var/datum/atom_hud/antag/hudicon = GLOB.huds[ANTAG_HUD_VIGILANTE]
	hudicon.leave_hud(owner.current)
	set_antag_hud(owner.current, null)

/datum/antagonist/vigilante/proc/create_stash()
	var/list/bad_people = list()
	var/list/valid_people = list()
	// Add the actual bad guy
	for (var/datum/dynamic_ruleset/gamemode/gamemode in SSdynamic.gamemode_executed_rulesets)
		for (var/datum/mind/mind in SSticker.minds)
			// Make sure they are a station role
			var/datum/job/job = SSjob.GetJob(mind.assigned_role)
			if (!job)
				continue
			if (!mind.current)
				continue
			if (!ishuman(mind.current))
				continue
			if (!find_record(mind.name, GLOB.manifest.general))
				continue
			valid_people += mind.name
			if (!mind.has_antag_datum(gamemode.antag_datum))
				continue
			bad_people += mind.name
	while (length(bad_people) < 3 && length(valid_people) > 0)
		var/valid_person = pick_n_take(valid_people)
		if (valid_person in bad_people)
			continue
		bad_people += valid_person
	// Generate the paper text
	var/paper_text = "<span style='font-family: [FOUNTAIN_PEN_FONT]'>Hey mate, I managed to intercept this document which you might find useful. Best of luck taking down the scum of the station, don't forget to keep an eye on command or security though. I'm building up a lot of dirt on them.</span>"
	paper_text += "<br>"
	paper_text += SScommunications.generate_security_report(FALSE)
	paper_text += "<br>"
	paper_text += "<span style='font-family: [FOUNTAIN_PEN_FONT]'>Another thing I found while digging is Nanotrasen's internal profiling database for suspicious individuals. While it's not much, it will be a good place for you to start your investigation and I would bet money that one of these dudes is who you are looking for. It only lists humans and station personnel though, so don't turn a blind eye to the other threats that could be present.</span>"
	paper_text += "<br>"
	if (length(bad_people) > 0)
		paper_text += "<span style='font-family: [FOUNTAIN_PEN_FONT]'>The first name that comes up is [pick_n_take(bad_people)].</span>"
		paper_text += "<br>"
	if (length(bad_people) > 0)
		paper_text += "<span style='font-family: [FOUNTAIN_PEN_FONT]'>The second name on the list is [pick_n_take(bad_people)].</span>"
		paper_text += "<br>"
	if (length(bad_people) > 0)
		paper_text += "<span style='font-family: [FOUNTAIN_PEN_FONT]'>The final person who should take fancy to is [pick_n_take(bad_people)].</span>"
		paper_text += "<br>"
	paper_text += "<span style='font-family: [FOUNTAIN_PEN_FONT]'>Alright mate, just make sure you burn this fucking document when you are done with it; possession of intercepted documents is a major crime and we could both get in trouble for this.</span>"

	// Create the items
	var/obj/item/paper/paper = new()
	paper.add_raw_text(advanced_html = paper_text)
	paper.update_appearance()
	var/obj/item/detective_scanner/scanner = new()

	// Spawn the stash
	return generate_stash(list(scanner, paper), list(owner), null, silent = TRUE)

/datum/antagonist/vigilante/farewell()
	. = ..()
	if (uplink)
		QDEL_NULL(uplink)
	to_chat(owner.current, span_userdanger("You are no longer the fanatic vigilante!"))
	to_chat(owner.current, span_bold("Whether it be through capture or incompetence, you have failed your mission. Without your uplink, you have lost all leverage over the criminals and are forced into hiding. Crime has won, justice has lost..."))
	UnregisterSignal(SSdcs, COMSIG_GLOB_PRISONER_REGISTERED)
	UnregisterSignal(SSdcs, COMSIG_GLOB_WANTED_STATUS_CHANGED)

/datum/antagonist/vigilante/proc/deconvert()
	uplink = null
	owner.remove_antag_datum(/datum/antagonist/vigilante)

/// Prisoners need to die
/datum/antagonist/vigilante/proc/on_job_spawned(datum/source, datum/job/job, mob/living/H, mob/M, latejoin)
	SIGNAL_HANDLER
	if (!istype(job, /datum/job/prisoner))
		return
	if (!H.mind)
		return
	on_prisoner_created(source, null, H.mind.name, pick(\
		"littering",\
		"possessing unauthorised literature",\
		"pushing a disabled person down the stairs",\
		"doing their job in an inconvenient way",\
		"burning plasma inside the burn chamber",\
		"posting negative comments about Nanotrasen online",\
		"being marked for arrest by an AI crime prediction algorithm",\
		"suspiciously using recreational equipment while on duty",\
		"preventing the resurrection of ancient gods without authorisation",\
		"blowing up the chemistry lab again",\
		"stealing crates from other departments",\
		"misusing office equipment",\
	))

/datum/antagonist/vigilante/proc/on_wanted_level_changed(datum/source, datum/record/crew/record, datum/update_source, wanted_status)
	SIGNAL_HANDLER
	if (wanted_status != WANTED_ARREST && wanted_status != WANTED_PRISONER && wanted_status != WANTED_SUSPECT)
		return
	if (!isliving(update_source))
		log_objective("Vigilante Reject: Author of wanted level was a [update_source] which is not a person.")
		return
	var/mob/living/officer = update_source
	if (!officer || !officer.mind)
		log_objective("Vigilante Reject: Author of wanted level was [officer], but they had no mind.")
		return
	if (length(officer.mind.antag_datums))
		log_objective("Vigilante Reject: Author of wanted level was [officer.mind.name], but they were an antagonist.")
		return
	var/datum/job/job = SSjob.GetJob(officer.mind.assigned_role)
	if (!job)
		log_objective("Vigilante Reject: Author of wanted level was [officer.mind.name], but they had no job.")
		return
	if (!CHECK_BITFIELD(job.departments, DEPT_BITFLAG_COM) && !CHECK_BITFIELD(job.departments, DEPT_BITFLAG_SEC))
		log_objective("Vigilante Reject: Author of wanted level was [officer.mind.name], but they were a [job.title] which is not command or sec.")
		return
	on_prisoner_created(source, officer, record.name, "Wanted level updated to [wanted_status]")

/datum/antagonist/vigilante/proc/on_prisoner_created(datum/source, mob/user, desired_name, desired_crime)
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
	if (!target.mind)
		return
	if (REF(target.mind) in justice_delivered)
		return
	log_directive("New vigilante target added, [target.mind.name] with the type [justice.type].")
	justice_delivered += REF(target.mind)
	justice.details = replacetext(justice.details, "%NAME%", desired_name)
	justice.details = replacetext(justice.details, "%CRIME%", desired_crime)
	justice.set_target(target)
	var/list/uplink_team = list(uplink)
	justice.add_antagonist_team(uplink_team)
	justice.start(uplink_team)
	SSdirectives.active_directives += justice

/datum/priority_directive/assassination/justice
	details = "The prison registrar has found %NAME% guilty of '%CRIME%', an offense that cannot go unpunished if society is to prosper. Eliminate them and show them the meaning of justice."
	last_for = INFINITY
	reputation_reward = 0
	reputation_loss = 0

/datum/priority_directive/assassination/justice/_generate(list/teams)
	return rand(4, 8)

/datum/priority_directive/assassination/justice/_allocate_teams(list/uplinks, list/player_minds, force)
	reject()

/datum/priority_directive/assassination/justice/badcop
	details = "Corruption runs wild within the station's prison system. Teach %NAME% a lesson about inputing prisoner details correctly through death."
