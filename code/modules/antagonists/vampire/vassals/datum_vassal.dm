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
	///Whether this vassal is already a special type of Vassal.
	var/special_type = FALSE
	///Description of what this Vassal does.
	var/vassal_description

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	RegisterSignal(current_mob, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	current_mob.faction |= FACTION_VAMPIRE

	vampire_team = master.vampire_team
	vampire_team.add_member(current_mob.mind)

	add_antag_hud(ANTAG_HUD_VAMPIRE, vassal_hud_name, current_mob)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	. = ..()
	var/mob/living/current_mob = mob_override || owner.current

	vampire_team.remove_member(current_mob.mind)

	remove_antag_hud(ANTAG_HUD_VAMPIRE, current_mob)

	current_mob.faction -= FACTION_VAMPIRE

/datum/antagonist/vassal/on_gain()
	RegisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN, PROC_REF(give_warning))
	/// Enslave them to their Master
	if(!master || !istype(master, master))
		return
	if(special_type)
		if(!master.special_vassals[special_type])
			master.special_vassals[special_type] = list()
		master.special_vassals[special_type] |= src
	master.vassals |= src
	owner.enslave_mind_to_creator(master.owner.current)
	owner.current.log_message("has been vassalized by [master.owner.current]!", LOG_ATTACK, color="#960000")
	/// Give Recuperate Power
	BuyPower(new /datum/action/vampire/recuperate)
	BuyPower(new /datum/action/vampire/distress)
	/// Give Objectives
	forge_objectives()
	/// Give Vampire Language
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_removal()
	UnregisterSignal(owner.current, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)
	//Free them from their Master
	if(master?.owner)
		if(special_type && master.special_vassals[special_type])
			master.special_vassals[special_type] -= src
		master.vassals -= src
		owner.enslaved_to = null

	for(var/all_status_traits in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, all_status_traits, TRAIT_VAMPIRE)

	for(var/datum/action/vampire/power as anything in powers)
		powers -= power
		power.Remove(owner.current)

	owner.current.remove_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	. = ..()
	for(var/datum/action/vampire/power as anything in powers)
		power.Remove(old_body)
		power.Grant(new_body)

/datum/antagonist/vassal/greet()
	. = ..()
	if(silent)
		return

	to_chat(owner, span_userdanger("You are now the mortal servant of [master.owner.current], a Vampire!"))
	to_chat(owner, span_boldannounce("The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Vampire, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You are the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, span_userdanger("[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant"))
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		span_deconversionmessage("[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self."),
		span_deconversionmessage("With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will."))
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, span_cultbold("You feel the bond with your vassal [owner.current] has somehow been broken!"))

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()
	for(var/datum/antagonist/vampire/vampiredatums in GLOB.antagonists)
		var/datum/mind/vamp = vampiredatums.owner
		if(!vamp || !vamp?.current || vamp?.current?.stat == DEAD)
			continue
		possible_vampires += vamp

	if(!length(possible_vampires))
		message_admins("[key_name_admin(usr)] tried vassalizing [key_name_admin(new_owner)], but there were no vampires!")
		return
	var/datum/mind/choice = input("Which vampire should this vassal belong to?", "Vampire") in possible_vampires
	if(!choice)
		return
	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/vampire/vampire = choice.has_antag_datum(/datum/antagonist/vampire)
	master = vampire
	new_owner.add_antag_datum(src)
	to_chat(choice, span_notice("Through divine intervention, you've gained a new vassal!"))

/datum/antagonist/vassal/proc/forge_objectives()
	var/datum/objective/vampire/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective

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
