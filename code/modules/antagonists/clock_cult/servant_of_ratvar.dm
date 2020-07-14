//==========================
//====  Servant antag   ====
//==========================

/datum/antagonist/servant_of_ratvar
	name = "Servant Of Ratvar"
	roundend_category = "clock cultists"
	antagpanel_category = "Clockcult"
	antag_moodlet = /datum/mood_event/cult
	job_rank = ROLE_SERVANT_OF_RATVAR

	//The class of the servant
	var/datum/action/innate/clockcult/transmit/transmit_spell
	var/datum/team/clock_cult/team

	var/counts_towards_total = TRUE//Counts towards the total number of servants.

/datum/antagonist/servant_of_ratvar/New()
	. = ..()

/datum/antagonist/servant_of_ratvar/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)

/datum/antagonist/servant_of_ratvar/on_gain()
	. = ..()
	create_team()
	add_objectives()
	if(counts_towards_total)
		GLOB.servants_of_ratvar |= owner
		if(ishuman(owner.current))
			GLOB.human_servants_of_ratvar |= owner
		else if(iscyborg(owner.current))
			GLOB.cyborg_servants_of_ratvar |= owner
	check_ark_status()
	owner.announce_objectives()

/datum/antagonist/servant_of_ratvar/on_removal()
	. = ..()
	GLOB.servants_of_ratvar -= owner
	if(owner in GLOB.human_servants_of_ratvar)
		GLOB.human_servants_of_ratvar -= owner
	if(owner in GLOB.cyborg_servants_of_ratvar)
		GLOB.cyborg_servants_of_ratvar -= owner

/datum/antagonist/servant_of_ratvar/apply_innate_effects(mob/living/M)
	. = ..()
	owner.current.faction |= "ratvar"
	transmit_spell = new()
	transmit_spell.Grant(owner.current)
	owner.current.throw_alert("clockinfo", /obj/screen/alert/clockwork/clocksense)
	SSticker.mode.update_clockcult_icons_added(owner)

/datum/antagonist/servant_of_ratvar/remove_innate_effects(mob/living/M)
	owner.current.faction -= "ratvar"
	owner.current.clear_alert("clockinfo")
	transmit_spell.Remove(transmit_spell.owner)
	SSticker.mode.update_clockcult_icons_removed(owner)
	. = ..()

/datum/antagonist/servant_of_ratvar/proc/equip_servant_conversion()
	to_chat(owner.current, "<span class='heavy_brass'>You feel a flash of light and the world spin around you!</span>")
	to_chat(owner.current, "<span class='brass'>You suddenly understand so much more than you did before and are commited to a life of servitude.</span>")
	to_chat(owner.current, "<span class='brass'>Using your clockwork slab you can invoke a variety of powers to help you complete Ratvar's will.</span>")
	//Equipment apply
	var/mob/living/H = owner.current
	if(istype(H, /mob/living/carbon))
		equip_carbon(H)
	else if(istype(H, /mob/living/silicon))
		equip_silicon(H)

//Remove clown mutation
//Give the device
/datum/antagonist/servant_of_ratvar/proc/equip_servant()
	var/mob/living/H = owner.current
	var/datum/outfit/clockwork_outfit = new /datum/outfit/clockcult
	if(istype(H, /mob/living/carbon))
		clockwork_outfit.equip(H)

/datum/antagonist/servant_of_ratvar/proc/equip_carbon(mob/living/carbon/H)
	//Convert all items in their inventory to Ratvarian
	var/list/contents = H.get_contents()
	for(var/atom/A in contents)
		A.ratvar_act()
	//Equip them with a slab
	var/obj/item/clockwork/clockwork_slab/slab = new(get_turf(H))
	H.put_in_hands(slab)
	slab.pickup(H)
	//Remove cuffs
	if(H.handcuffed)
		H.handcuffed.forceMove(get_turf(H))
		H.handcuffed = null
		H.update_handcuffed()
	return FALSE

//Grant access to the clockwork tools.
//If AI, disconnect all active borgs and make it only able to control converted shells
/datum/antagonist/servant_of_ratvar/proc/equip_silicon(mob/living/silicon/S)
	S.laws = new /datum/ai_laws/ratvar
	S.laws.associate(S)
	S.show_laws()
	if(isAI(S))
		var/mob/living/silicon/ai/AI = S
		AI.disconnect_shell()
		for(var/mob/living/silicon/robot/R in AI.connected_robots)
			R.connected_ai = null
		var/mutable_appearance/ai_clock = mutable_appearance('icons/mob/clockwork_mobs.dmi', "aiframe")
		AI.add_overlay(ai_clock)
	else if(iscyborg(S))
		var/mob/living/silicon/robot/R = S
		R.connected_ai = null
		R.SetRatvar(TRUE)

/datum/antagonist/servant_of_ratvar/proc/add_objectives()
	objectives |= team.objectives

/datum/antagonist/servant_of_ratvar/get_team()
	return team

/datum/antagonist/servant_of_ratvar/can_be_owned(datum/mind/new_owner)
	. = ..()
	if(.)
		. = is_convertable_to_clockcult(new_owner.current)

/datum/antagonist/servant_of_ratvar/create_team(datum/team/clock_cult/newteam)
	if(!newteam)
		for(var/datum/antagonist/servant_of_ratvar/H in GLOB.antagonists)
			if(!H.owner)
				continue
			if(H.team)
				team = H.team
				return
		team = new /datum/team/clock_cult
		team.setup_objectives()
	if(!istype(newteam))
		stack_trace("Wrong team type passed to [type] initialization.")
	team = newteam

//==========================
//==== Clock cult team  ====
//==========================

/datum/team/clock_cult
	name = "Servants Of Ratvar"

/datum/team/clock_cult/proc/setup_objectives()
	objectives = list(new /datum/objective/clockcult)
