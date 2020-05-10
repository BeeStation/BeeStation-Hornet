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
	var/datum/clockcult/servant_class/servant_class = /datum/clockcult/servant_class
	var/datum/action/innate/clockcult/transmit/transmit_spell

/datum/antagonist/servant_of_ratvar/New(datum/mind/M)
	. = ..()
	//Assign the default class
	servant_class = new servant_class()

/datum/antagonist/servant_of_ratvar/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)
	GLOB.servants_of_ratvar |= owner
	transmit_spell = new()
	transmit_spell.Grant(owner.current)

/datum/antagonist/servant_of_ratvar/farewell()
	. = ..()
	GLOB.servants_of_ratvar -= owner

/datum/antagonist/servant_of_ratvar/remove_innate_effects(mob/living/M)
	. = ..()
	transmit_spell.Remove(M)

/datum/antagonist/servant_of_ratvar/apply_innate_effects(mob/living/M)
	. = ..()

//Remove clown mutation
//Give the device
/datum/antagonist/servant_of_ratvar/proc/equip_servant_basic(var/give_class_equipment = FALSE)
	var/mob/living/H = owner.current
	if(istype(H, /mob/living/carbon))
		if(give_class_equipment)
			servant_class.equip_mob(H)
		return equip_carbon(H)
	else if(istype(H, /mob/living/silicon))
		return equip_silicon(H)

/datum/antagonist/servant_of_ratvar/proc/equip_carbon(mob/living/carbon/H)
	if(!istype(H))
		return FALSE

//Grant access to the clockwork tools.
//If AI, disconnect all active borgs and make it only able to control converted shells
/datum/antagonist/servant_of_ratvar/proc/equip_silicon(mob/living/silicon/S)
	if(!istype(S))
		return FALSE

//==========================
//==== Clock cult team  ====
//==========================

/datum/team/servant_of_ratvar
	name = "Clockcult"
	var/list/objective
	var/datum/mind/eminence
