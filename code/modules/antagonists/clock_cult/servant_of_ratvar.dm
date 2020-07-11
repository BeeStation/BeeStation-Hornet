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

/datum/antagonist/servant_of_ratvar/greet()
	if(!owner.current)
		return
	owner.current.playsound_local(get_turf(owner.current), 'sound/ambience/antag/clockcultalr.ogg', 60, FALSE, pressure_affected = FALSE)

/datum/antagonist/servant_of_ratvar/apply_innate_effects(mob/living/M)
	. = ..()
	owner.current.faction |= "ratvar"
	if(counts_towards_total)
		GLOB.servants_of_ratvar |= owner
		if(ishuman(owner.current))
			GLOB.human_servants_of_ratvar |= owner
	check_ark_status()
	transmit_spell = new()
	transmit_spell.Grant(owner.current)
	owner.current.throw_alert("clockinfo", /obj/screen/alert/clockwork/clocksense)
	SSticker.mode.update_clockcult_icons_added(owner)

/datum/antagonist/servant_of_ratvar/remove_innate_effects(mob/living/M)
	owner.current.faction -= "ratvar"
	GLOB.servants_of_ratvar -= owner
	if(owner in GLOB.human_servants_of_ratvar)
		GLOB.human_servants_of_ratvar -= owner
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
	return FALSE

/datum/antagonist/servant_of_ratvar/create_team(datum/team/newteam)
	if(!newteam)
		if(GLOB.clockcult_team)
			team = GLOB.clockcult_team
		else
			var/datum/team/clock_cult/clock_team = new()
			GLOB.clockcult_team = clock_team
			team = clock_team
		return
	team = newteam

/datum/antagonist/servant_of_ratvar/get_team()
	return team

//==========================
//==== Clock cult team  ====
//==========================

/datum/team/clock_cult
	name = "Servants Of Ratvar"
	var/list/objective

	var/power = 0
	var/vitality = 0
