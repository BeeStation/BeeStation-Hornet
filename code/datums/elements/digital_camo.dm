/datum/element/digital_camo
	element_flags = ELEMENT_DETACH
	var/list/attached_mobs = list()

/datum/element/digital_camo/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_login))

/datum/element/digital_camo/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN)
	. = ..()

/datum/element/digital_camo/Attach(datum/target)
	. = ..()
	if(!isliving(target) || (target in attached_mobs))
		return ELEMENT_INCOMPATIBLE
	//Register signals to handle examinations and override track behaviour
	RegisterSignal(target, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))
	//Create an override image to make them invisible on the AI's screen
	var/image/img = image(loc = target)
	img.override = TRUE
	attached_mobs[target] = img
	//Hide from currently existing siliocon huds
	HideFromSiliconHuds(target)

/datum/element/digital_camo/Detach(datum/target)
	. = ..()
	//Cleanup signal registers that we used
	UnregisterSignal(target, list(COMSIG_PARENT_EXAMINE, COMSIG_LIVING_CAN_TRACK))
	//Remove the images
	for(var/mob/living/silicon/silicon as() in GLOB.silicon_mobs)
		silicon.client?.images -= attached_mobs[target]
	attached_mobs -= target
	//Show to silicon huds again
	UnhideFromSiliconHuds(target)

/datum/element/digital_camo/proc/on_mob_login(datum/source, mob/new_login)
	SIGNAL_HANDLER
	if(issilicon(new_login))
		for(var/mob/target as() in attached_mobs)
			var/mob/living/silicon/silicon = new_login
			//Hide the mob
			silicon.client.images |= attached_mobs[target]
			//Hide from HUD
			var/datum/atom_hud/M = GLOB.huds[silicon.med_hud]
			var/datum/atom_hud/S = GLOB.huds[silicon.sec_hud]
			M.hide_single_atomhud_from(silicon, target)
			S.hide_single_atomhud_from(silicon, target)

/datum/element/digital_camo/proc/HideFromSiliconHuds(mob/living/target)
	for(var/mob/living/silicon/silicon as() in GLOB.silicon_mobs)
		var/datum/atom_hud/M = GLOB.huds[silicon.med_hud]
		var/datum/atom_hud/S = GLOB.huds[silicon.sec_hud]
		M.hide_single_atomhud_from(silicon, target)
		S.hide_single_atomhud_from(silicon, target)

/datum/element/digital_camo/proc/UnhideFromSiliconHuds(mob/living/target)
	for(var/mob/living/silicon/silicon as() in GLOB.silicon_mobs)
		var/datum/atom_hud/M = GLOB.huds[silicon.med_hud]
		var/datum/atom_hud/S = GLOB.huds[silicon.sec_hud]
		M.unhide_single_atomhud_from(silicon, target)
		S.unhide_single_atomhud_from(silicon, target)

/datum/element/digital_camo/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += "<span class='warning'>[source.p_their()] skin seems to be shifting and morphing like is moving around below it.</span>"

/datum/element/digital_camo/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK
