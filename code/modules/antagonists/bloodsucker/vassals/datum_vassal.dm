/*
	* when a bloodsucker views a vassal that is not their own, the vassal icon is gray
	* however, when a bloodsucker views their own vassal, the icon is red (except for special vassals)
	*
	* when a vassal views another vassal that has the same master as their own, the icon is red (except for special vassals)
	* vassals cannot see other bloodsucker's vassals.
	* TODO: when a bloodsucker breaks the masquerade, all vassals are revealed to all bloodsuckers
*/

/datum/antagonist/vassal
	name = "\improper Vassal"
	roundend_category = "vassals"
	antagpanel_category = "Bloodsucker"
	banning_key = ROLE_BLOODSUCKER
	show_in_roundend = FALSE

	var/vassal_hud_name = "vassal"

	/// The Master Bloodsucker's antag datum.
	var/datum/antagonist/bloodsucker/master
	/// The Bloodsucker's team
	var/datum/team/bloodsucker/bloodsucker_team
	/// List of all Purchased Powers, like Bloodsuckers.
	var/list/datum/action/powers = list()
	///Whether this vassal is already a special type of Vassal.
	var/special_type = FALSE
	///Description of what this Vassal does.
	var/vassal_description

/datum/antagonist/vassal/antag_panel_data()
	return "Master : [master.owner.name]"

/datum/antagonist/vassal/apply_innate_effects(mob/living/mob_override)
	..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.apply_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

	current_mob.faction |= FACTION_BLOODSUCKER

	bloodsucker_team = master.bloodsucker_team
	bloodsucker_team.add_member(current_mob.mind)

	bloodsucker_team.hud.join_hud(current_mob)
	set_antag_hud(current_mob, vassal_hud_name)

/datum/antagonist/vassal/remove_innate_effects(mob/living/mob_override)
	..()
	var/mob/living/current_mob = mob_override || owner.current
	current_mob.remove_status_effect(/datum/status_effect/agent_pinpointer/vassal_edition)

	bloodsucker_team.remove_member(current_mob.mind)
	bloodsucker_team.hud.leave_hud(current_mob)
	set_antag_hud(current_mob, null)
	current_mob.faction -= FACTION_BLOODSUCKER

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
	BuyPower(new /datum/action/cooldown/bloodsucker/recuperate)
	/// Give Objectives
	var/datum/objective/bloodsucker/vassal/vassal_objective = new
	vassal_objective.owner = owner
	objectives += vassal_objective
	/// Give Vampire Language & Hud
	owner.current.grant_all_languages(FALSE, FALSE, TRUE)
	owner.current.grant_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_removal()
	UnregisterSignal(owner.current, COMSIG_PARENT_EXAMINE)
	UnregisterSignal(SSsunlight, COMSIG_SOL_WARNING_GIVEN)
	//Free them from their Master
	if(master && master.owner)
		if(special_type && master.special_vassals[special_type])
			master.special_vassals[special_type] -= src
		master.vassals -= src
		owner.enslaved_to = null
	//Remove ALL Traits, as long as its from BLOODSUCKER_TRAIT's source.
	for(var/all_status_traits in owner.current.status_traits)
		REMOVE_TRAIT(owner.current, all_status_traits, BLOODSUCKER_TRAIT)
	//Remove Recuperate Power
	while(powers.len)
		var/datum/action/cooldown/bloodsucker/power = pick(powers)
		powers -= power
		power.Remove(owner.current)
	//Remove Language
	owner.current.remove_language(/datum/language/vampiric)
	return ..()

/datum/antagonist/vassal/on_body_transfer(mob/living/old_body, mob/living/new_body)
	..()
	for(var/datum/action/cooldown/bloodsucker/all_powers as anything in powers)
		all_powers.Remove(old_body)
		all_powers.Grant(new_body)

/datum/antagonist/vassal/greet()
	..()
	if(silent)
		return

	to_chat(owner, "<span class='userdanger'>You are now the mortal servant of [master.owner.current], a Bloodsucker!</span>")
	to_chat(owner, "<span class='boldannounce'>The power of [master.owner.current.p_their()] immortal blood compels you to obey [master.owner.current.p_them()] in all things, even offering your own life to prolong theirs.\n\
		You are not required to obey any other Bloodsucker, for only [master.owner.current] is your master. The laws of Nanotrasen do not apply to you now; only your vampiric master's word must be obeyed.</span>") // if only there was a /p_theirs() proc...
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	antag_memory += "You are the mortal servant of <b>[master.owner.current]</b>, a bloodsucking vampire!<br>"
	/// Message told to your Master.
	to_chat(master.owner, "<span class='userdanger'>[owner.current] has become addicted to your immortal blood. [owner.current.p_they(TRUE)] [owner.current.p_are()] now your undying servant</span>")
	master.owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)

/datum/antagonist/vassal/farewell()
	if(silent)
		return

	owner.current.visible_message(
		"<span class='deconversion_message'>[owner.current]'s eyes dart feverishly from side to side, and then stop. [owner.current.p_they(TRUE)] seem[owner.current.p_s()] calm, \
			like [owner.current.p_they()] [owner.current.p_have()] regained some lost part of [owner.current.p_them()]self.</span>", \
		"<span class='deconversion_message'>With a snap, you are no longer enslaved to [master.owner]! You breathe in heavily, having regained your free will.</span>")
	owner.current.playsound_local(null, 'sound/magic/mutate.ogg', 100, FALSE, pressure_affected = FALSE)
	/// Message told to your (former) Master.
	if(master && master.owner)
		to_chat(master.owner, "<span class='cultbold'>You feel the bond with your vassal [owner.current] has somehow been broken!</span>")

/datum/antagonist/vassal/admin_add(datum/mind/new_owner, mob/admin)
	var/list/datum/mind/possible_vampires = list()
	for(var/datum/antagonist/bloodsucker/bloodsuckerdatums in GLOB.antagonists)
		var/datum/mind/vamp = bloodsuckerdatums.owner
		if(!vamp)
			continue
		if(!vamp.current)
			continue
		if(vamp.current.stat == DEAD)
			continue
		possible_vampires += vamp
	if(!length(possible_vampires))
		message_admins("[key_name_admin(usr)] tried vassalizing [key_name_admin(new_owner)], but there were no bloodsuckers!")
		return
	var/datum/mind/choice = input("Which bloodsucker should this vassal belong to?", "Bloodsucker") in possible_vampires
	if(!choice)
		return
	log_admin("[key_name_admin(usr)] turned [key_name_admin(new_owner)] into a vassal of [key_name_admin(choice)]!")
	var/datum/antagonist/bloodsucker/vampire = choice.has_antag_datum(/datum/antagonist/bloodsucker)
	master = vampire
	new_owner.add_antag_datum(src)
	to_chat(choice, "<span class='notice'>Through divine intervention, you've gained a new vassal!</span>")
