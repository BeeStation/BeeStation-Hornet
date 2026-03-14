/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Vampire"
	banning_key = ROLE_VAMPIRE
	show_in_roundend = FALSE

	var/vassal_hud_name = "vassal"

	/// The Master Vampire's antag datum.
	var/datum/antagonist/vampire/master
	/// The Vampire's team
	var/datum/team/vampire/vampire_team
	/// List of all Purchased Powers, like Vampires.
	var/list/datum/action/powers = list()
	/// Whether this vassal is already a special type of Vassal.
	var/special_type
	/// Description of what this Vassal does.
	var/vassal_description
	/// A link to our team monitor, used to track our master.
	var/datum/component/team_monitor/monitor

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
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

	add_antag_hud(ANTAG_HUD_VAMPIRE, vassal_hud_name, current_mob)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
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

/datum/antagonist/vassal/on_gain()
	. = ..()
	if(!master)
		owner.remove_antag_datum(src)
		CRASH("[owner.current] was vassilized without a master!")

	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))

	// Enslave them to their Master
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner)
	owner.current.log_message("has been vassalized by [master.owner]!", LOG_ATTACK, color="#960000")

	// Handle special vassalss
	if(special_type)
		master.special_vassals[special_type] += 1

	// Give powers
	grant_power(new /datum/action/vampire/recuperate)
	grant_power(new /datum/action/vampire/distress)

	// Give objectives
	forge_objectives()

/datum/antagonist/vassal/on_removal()
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)

	// Free them from their Master
	if(master)
		if(special_type)
			master.special_vassals[special_type] -= 1
		master.vassals -= src
		owner.enslaved_to = null

	// Remove powers
	for(var/datum/action/vampire/power in powers)
		powers -= power
		power.Remove(owner.current)

	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/vampire/power in powers)
		power.Remove(old_body)
		power.Grant(new_body)

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return

	var/mob/living/living_vassal = owner.current
	var/mob/living/living_master = master.owner.current

	// Alert vassal
	var/list/msg = list()
	msg += span_cultlarge("You are now the mortal servant of [living_master], a Vampire!")
	msg += span_cult("You are not required to obey any other Vampire, for only [living_master] is your master. The laws of Nanotrasen do not apply to you now; only your Master's word must be obeyed.")
	to_chat(living_vassal, examine_block(msg.Join("\n")))

	living_vassal.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You are the mortal servant of <b>[living_master]</b>, a vampire!<br>"

	// Alert master
	to_chat(living_master, span_userdanger("[living_vassal] has become addicted to your immortal blood. [living_vassal.p_They()] [living_vassal.p_are()] now your undying servant"))
	living_master.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversionmessage("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_They()] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."),
		span_deconversionmessage("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will.")
	)
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

	// Alert master
	if(master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
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
	var/datum/mind/choice = tgui_input_list(admin, "Which vampire should this vassal belong to?", "Vampire", possible_vampires)
	if(!choice)
		return

	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/vampire/vampire = IS_VAMPIRE(choice.current)
	master = vampire
	new_owner.add_antag_datum(src)

	to_chat(choice, span_notice("Through divine intervention, you've gained a new vassal!"))

/datum/antagonist/vassal/forge_objectives()
	var/datum/objective/vampire/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective

/datum/antagonist/vassal/proc/setup_monitor(mob/target)
	QDEL_NULL(monitor)
	if(QDELETED(master?.owner?.current) || QDELETED(master.tracker))
		return

	monitor = target.AddComponent(/datum/component/team_monitor, REF(master))
	monitor.add_to_tracking_network(master.tracker.tracking_beacon)
	monitor.show_hud(target)

/datum/antagonist/vassal/proc/on_examine(datum/source, mob/examiner, list/examine_text)
	SIGNAL_HANDLER

	var/text = icon2html('icons/vampires/vampiric.dmi', world, "vassal")

	var/datum/antagonist/vampire/vampiredatum = IS_VAMPIRE(examiner)
	if(src in vampiredatum?.vassals)
		text += span_cult("<EM>This is your vassal!</EM>")
		examine_text += text
	else if(vampiredatum || IS_CURATOR(examiner) || IS_VASSAL(examiner))
		text += span_cult("<EM>This is [master.return_full_name()]'s vassal</EM>")
		examine_text += text
