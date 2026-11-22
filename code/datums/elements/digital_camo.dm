/datum/element/digital_camo
	element_flags = ELEMENT_DETACH
	var/list/attached_mobs = list()

/datum/element/digital_camo/New()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN, PROC_REF(on_mob_login))

/datum/element/digital_camo/Destroy(force)
	UnregisterSignal(SSdcs, COMSIG_GLOB_MOB_LOGGED_IN)
	return ..()

/datum/element/digital_camo/Attach(datum/target)
	. = ..()
	if(!isliving(target) || (target in attached_mobs))
		return ELEMENT_INCOMPATIBLE
	//Register signals to handle examinations and override track behaviour
	RegisterSignal(target, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))
	RegisterSignal(target, COMSIG_LIVING_CAN_TRACK, PROC_REF(can_track))
	//Create an override image to make them invisible on the AI's screen
	var/image/img = image(loc = target)
	img.override = TRUE
	attached_mobs[target] = img
	//Hide from currently existing siliocon huds
	hide_from_silicons(target)

/datum/element/digital_camo/Detach(datum/target)
	. = ..()
	//Cleanup signal registers that we used
	UnregisterSignal(target, list(COMSIG_ATOM_EXAMINE, COMSIG_LIVING_CAN_TRACK))
	//Remove the images
	for(var/mob/living/silicon/silicon as anything in GLOB.silicon_mobs)
		silicon.client?.images -= attached_mobs[target]
	attached_mobs -= target
	//Show to silicon huds again
	show_to_silicons(target)

/datum/element/digital_camo/proc/on_mob_login(datum/source, mob/living/silicon/new_login)
	SIGNAL_HANDLER
	if(!istype(new_login))
		return

	for(var/mob/target as anything in attached_mobs)
		//Hide the mob
		new_login.client.images |= attached_mobs[target]
		//Hide from HUD
		for (var/hud_trait in new_login.silicon_huds)
			var/datum/atom_hud/silicon_hud = GLOB.huds[GLOB.trait_to_hud[hud_trait]]
			silicon_hud.hide_single_atomhud_from(new_login, target)

/datum/element/digital_camo/proc/hide_from_silicons(mob/living/target)
	for(var/mob/living/silicon/silicon as anything in GLOB.silicon_mobs)
		for (var/hud_trait in silicon.silicon_huds)
			var/datum/atom_hud/silicon_hud = GLOB.huds[GLOB.trait_to_hud[hud_trait]]
			silicon_hud.hide_single_atomhud_from(silicon, target)

/datum/element/digital_camo/proc/show_to_silicons(mob/living/target)
	for(var/mob/living/silicon/silicon as anything in GLOB.silicon_mobs)
		for (var/hud_trait in silicon.silicon_huds)
			var/datum/atom_hud/silicon_hud = GLOB.huds[GLOB.trait_to_hud[hud_trait]]
			silicon_hud.unhide_single_atomhud_from(silicon, target)

/datum/element/digital_camo/proc/on_examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	examine_list += span_warning("[source.p_Their()] skin seems to be shifting like something is moving below it.")

/datum/element/digital_camo/proc/can_track(datum/source)
	SIGNAL_HANDLER
	return COMPONENT_CANT_TRACK
