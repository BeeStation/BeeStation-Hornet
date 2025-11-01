/datum/antagonist/ghoul
	name = "\improper ghoul"
	roundend_category = "ghouls"
	antagpanel_category = "Vampire"
	banning_key = ROLE_VAMPIRE
	show_in_roundend = FALSE

	var/ghoul_hud_name = "ghoul"

	/// The Master Vampire's antag datum.
	var/datum/antagonist/vampire/master
	/// The Vampire's team
	var/datum/team/vampire/vampire_team
	/// List of all Purchased Powers, like Vampires.
	var/list/datum/action/powers = list()
	/// Whether this ghoul is already a special type of ghoul.
	var/special_type
	/// Description of what this ghoul does.
	var/ghoul_description
	/// A link to our team monitor, used to track our master.
	var/datum/component/team_monitor/monitor

/datum/antagonist/ghoul/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/ghoul/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	// Tracking
	setup_monitor(current_mob)
	current_mob.grant_language(/datum/language/vampiric)

	// Team
	vampire_team = master.vampire_team
	vampire_team.add_member(current_mob.mind)
	current_mob.faction |= FACTION_VAMPIRE

	add_antag_hud(ANTAG_HUD_VAMPIRE, ghoul_hud_name, current_mob)

/datum/antagonist/ghoul/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	UnregisterSignal(current_mob, COMSIG_ATOM_EXAMINE)

	// Tracking
	QDEL_NULL(monitor)
	current_mob.remove_language(/datum/language/vampiric)

	// Remove traits
	for(var/vampire_trait in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, vampire_trait, TRAIT_VAMPIRE)

	// Team
	vampire_team.remove_member(current_mob.mind)
	vampire_team = null
	current_mob.faction -= FACTION_VAMPIRE

	remove_antag_hud(ANTAG_HUD_VAMPIRE, current_mob)

/datum/antagonist/ghoul/on_gain()
	. = ..()
	if(!master)
		owner.remove_antag_datum(src)
		CRASH("[owner.current] was vassilized without a master!")

	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	// Enslave them to their Master
	master.ghouls |= src
	owner.enslave_mind_to_creator(master.owner)
	owner.current.log_message("has been ghoulized by [master.owner]!", LOG_ATTACK, color="#960000")

	// Give powers
	grant_power(new /datum/action/vampire/recuperate)
	grant_power(new /datum/action/vampire/distress)

	// Give objectives
	forge_objectives()

/datum/antagonist/ghoul/on_removal()
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)

	// Free them from their Master
	if(master)
		master.ghouls -= src
		owner.enslaved_to = null

	// Remove powers
	for(var/datum/action/vampire/power in powers)
		powers -= power
		power.Remove(owner.current)

	return ..()

/datum/antagonist/ghoul/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/vampire/power in powers)
		power.Remove(old_body)
		power.Grant(new_body)

/datum/antagonist/ghoul/greet()
	. = ..()
	if(silent)
		return

	var/mob/living/living_ghoul = owner.current
	var/mob/living/living_master = master.owner.current

	// Alert ghoul
	var/list/msg = list()
	msg += span_cultlarge("You are now the mortal servant of [living_master], a Vampire!")
	msg += span_cult("You are not required to obey any other Vampire, for only [living_master] is your master. The laws of Nanotrasen do not apply to you now; only your Master's word must be obeyed.")
	to_chat(living_ghoul, examine_block(msg.Join("\n")))

	living_ghoul.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You are the mortal servant of <b>[living_master]</b>, a vampire!<br>"

	// Alert master
	to_chat(living_master, span_userdanger("[living_ghoul] has become addicted to your immortal blood. [living_ghoul.p_they(TRUE)] [living_ghoul.p_are()] now your undying servant"))
	living_master.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/ghoul/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversionmessage("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."),
		span_deconversionmessage("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will.")
	)
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

	// Alert master
	if(master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your ghoul [owner.current] has somehow been broken!"))

/datum/antagonist/ghoul/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()

	// Get possible vampires
	for(var/datum/antagonist/vampire/vampire in GLOB.antagonists)
		var/datum/mind/vampire_mind = vampire.owner
		if(QDELETED(vampire_mind?.current) || vampire_mind.current.stat == DEAD)
			continue

		possible_vampires += vampire_mind

	if(!length(possible_vampires))
		return

	// CHOOSE A DAMN PERSON
	var/datum/mind/choice = tgui_input_list(admin, "Which vampire should this ghoul belong to?", "Vampire", possible_vampires)
	if(!choice)
		return

	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a ghoul of [key_name_admin(choice)]!")
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(choice.current)
	master = vampire
	new_owner.add_antag_datum(src)

	to_chat(choice, span_notice("Through divine intervention, you've gained a new ghoul!"))

/datum/antagonist/ghoul/proc/forge_objectives()
	var/datum/objective/vampire/ghoul/ghoul_objective = new
	ghoul_objective.owner = owner
	objectives += ghoul_objective

/datum/antagonist/ghoul/proc/setup_monitor(mob/target)
	QDEL_NULL(monitor)
	if(QDELETED(master?.owner?.current) || QDELETED(master.tracker))
		return

	monitor = target.AddComponent(/datum/component/team_monitor, REF(master))
	monitor.add_to_tracking_network(master.tracker.tracking_beacon)
	monitor.show_hud(target)

/datum/antagonist/ghoul/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	var/text = icon2html('icons/vampires/vampiric.dmi', world, "ghoul")

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(examiner)
	if(src in vampiredatum?.ghouls)
		text += span_cult("<EM>This is your ghoul!</EM>")
		examine_text += text
	else if(vampiredatum || IS_CURATOR(examiner) || IS_ghoul(examiner))
		text += span_cult("<EM>This is [master.return_full_name()]'s ghoul</EM>")
		examine_text += text
