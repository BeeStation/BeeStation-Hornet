///The limit when the psychic timer locks you out of creating more
#define psychic_overlay_upper 450

/datum/species/psyphoza
	name = "\improper Psyphoza"
	id = SPECIES_PSYPHOZA
	sexes = 0
	species_traits = list(NOEYESPRITES)
	attack_verb = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	miss_sound = 'sound/weapons/punchmiss.ogg'
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	mutant_brain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza

	species_chest = /obj/item/bodypart/chest/pumpkin_man
	species_head = /obj/item/bodypart/head/pumpkin_man
	species_l_arm = /obj/item/bodypart/l_arm/pumpkin_man
	species_r_arm = /obj/item/bodypart/r_arm/pumpkin_man
	species_l_leg = /obj/item/bodypart/l_leg/pumpkin_man
	species_r_leg = /obj/item/bodypart/r_leg/pumpkin_man

/datum/species/psyphoza/check_roundstart_eligible()
	return TRUE
/obj/item/organ/brain/psyphoza
	name = "psyphoza brain"
	desc = "Bubbling with psychic energy!"
	actions_types = list(/datum/action/item_action/organ_action/psychic_highlight)
	color = "#ff00ee"

// PSYCHIC ECHOLOCATION
/datum/action/item_action/organ_action/psychic_highlight
	name = "Psychic Sense"
	desc = "Sense your surroundings psychically."
	///The distant our psychic sense works
	var/sense_range = 5
	///The range we can hear-ping things from
	var/hear_range = 9
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users eyes - we use this to toggle xray vision for scans
	var/obj/item/organ/eyes/eyes
	///The eyes original sight flags - used between toggles
	var/sight_flags
	///Time between uses
	var/cooldown = 2 SECONDS
	///List of overlays we made
	var/list/overlays = list()
	///Reference to 'kill these overlays' timer
	var/overlay_timer

/datum/action/item_action/organ_action/psychic_highlight/New(Target)
	. = ..()
	//Setup massive blacklist typecache of non-renderables. Smaller than whitelist
	sense_blacklist = typecacheof(list(/turf/open, /obj/machinery/door, /obj/machinery/light, /obj/machinery/firealarm,
	/obj/machinery/camera, /obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/sign, /obj/machinery/airalarm, 
	/obj/structure/disposalpipe, /atom/movable/lighting_object, /obj/machinery/power/apc, /obj/machinery/atmospherics/pipe,
	/obj/item/radio/intercom, /obj/machinery/navbeacon, /obj/structure/extinguisher_cabinet, /obj/machinery/power/terminal,
	/obj/machinery/holopad, /obj/machinery/status_display, /obj/machinery/ai_slipper, /obj/structure/lattice, /obj/effect/decal,
	/obj/structure/table, /obj/machinery/gateway, /obj/structure/rack, /obj/machinery/newscaster, /obj/structure/sink, /obj/machinery/shower,
	/obj/machinery/advanced_airlock_controller, /obj/machinery/computer/security/telescreen, /obj/structure/grille, /obj/machinery/light_switch,
	/obj/structure/noticeboard, /area, /obj/item/storage/secure/safe, /obj/machinery/requests_console, /obj/item/storage/backpack/satchel/flat,
	/obj/effect/countdown, /obj/machinery/button, /obj/effect/clockwork/overlay/floor, /obj/structure/reagent_dispensers/peppertank,
	/mob/dead/observer))

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/M)
	. = ..()
	//Register signal for TK highlights
	RegisterSignal(M, COMSIG_MOB_ATTACK_RANGED, .proc/handle_ranged)
	//Register signal for sensing voices
	RegisterSignal(SSdcs, COMSIG_GLOB_LIVING_SAY_SPECIAL, .proc/handle_hear)
	//Register signal for sensing sounds
	RegisterSignal(SSdcs, COMSIG_GLOB_SOUND_PLAYED, .proc/handle_hear)
	//Overlay used to highlight objects
	M.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/blind/psychic_highlight)

/datum/action/item_action/organ_action/psychic_highlight/Trigger()
	. = ..()
	if(has_cooldown_timer)
		return
	ping_turf(get_turf(owner))
	has_cooldown_timer = TRUE
	addtimer(CALLBACK(src, .proc/finish_cooldown), cooldown + (sense_time * min(1, overlays.len / psychic_overlay_upper)))

/datum/action/item_action/organ_action/psychic_highlight/proc/finish_cooldown()
	has_cooldown_timer = FALSE

//Allows user to see images through walls
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_fowards()
	//Grab eyes
	if(!eyes && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = owner
		eyes = locate(/obj/item/organ/eyes) in M.internal_organs
		sight_flags = eyes?.sight_flags
		//Register signal for losing our eyes
		RegisterSignal(eyes, COMSIG_PARENT_QDELETING, .proc/handle_eyes)
	//handle eyes
	eyes?.sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	owner.update_sight()

//Dims blind overlay - Lightens highlight layer
/datum/action/item_action/organ_action/psychic_highlight/proc/dim_overlay()
	//Blind layer
	var/atom/movable/screen/fullscreen/blind/psychic/P = locate (/atom/movable/screen/fullscreen/blind/psychic) in owner.client?.screen
	if(P)
		//We change the color instead of alpha, otherwise we'd reveal our actual surroundings!
		P.color = "#000"
		animate(P, color = "#fff", time = sense_time, easing = QUAD_EASING, flags = EASE_IN)
	//Highlight layer
	var/atom/movable/screen/plane_master/psychic/B = locate (/atom/movable/screen/plane_master/psychic) in owner.client?.screen
	if(B)
		B.alpha = 255
		animate(B, alpha = 0, time = sense_time, easing = QUAD_EASING, flags = EASE_IN)
	//Setup timer to delete image
	if(overlay_timer)
		deltimer(overlay_timer)
	overlay_timer = addtimer(CALLBACK(src, .proc/toggle_eyes_backwards), sense_time, TIMER_STOPPABLE)

//Get a list of nearby things & run 'em through a typecache
/datum/action/item_action/organ_action/psychic_highlight/proc/ping_turf(turf/T, size = sense_range)
	//call eye goof
	toggle_eyes_fowards()
	//Dull blind overlay
	dim_overlay()
	//Get nearby 'things'
	var/list/nearby = range(size, T)
	nearby -= owner
	//Go through the list and render whitelisted types
	for(var/atom/C as() in nearby)
		//Check typecache
		if(is_type_in_typecache(C, sense_blacklist))
			continue
		highlight_object(C)

//Add overlay for psychic plane
/datum/action/item_action/organ_action/psychic_highlight/proc/highlight_object(atom/target)
	var/image/M = new()
	M.appearance = target.appearance
	M.plane = PSYCHIC_PLANE
	M.pixel_x = 0
	M.pixel_y = 0
	target.add_overlay(M)
	//Append goober and his image to overlay list to get GC'd
	overlays += target
	overlays += M

//Handle clicking for ranged trigger
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_ranged(datum/source, atom/target)
	SIGNAL_HANDLER

	if(has_cooldown_timer)
		return
	var/turf/T = get_turf(target)
	if(get_dist(get_turf(owner), T) > 1)
		ping_turf(T, 2)
		has_cooldown_timer = TRUE
		addtimer(CALLBACK(src, .proc/finish_cooldown), (cooldown/2) + (sense_time * min(1, overlays.len / psychic_overlay_upper)))

//Handle images deleting, stops hardel - also does eyes stuff
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_backwards()
	//Timer
	if(overlay_timer)
		deltimer(overlay_timer)
		overlay_timer = null

	//Remove all the overlays
	if(!overlays.len)
		return
	for(var/i in 1 to overlays.len)
		if(istype(overlays[i], /image) || isnull(overlays[i]))
			continue
		var/atom/T = overlays[i]
		T?.cut_overlay(overlays[i+1])
	overlays.Cut(1, 0)
	eyes?.sight_flags = sight_flags
	owner.update_sight()

//Dim blind overlay for blind_sense component
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_hear(datum/source, atom/speaker, message)
	SIGNAL_HANDLER

	var/dist = get_dist(get_turf(owner), get_turf(speaker))
	if(dist <= hear_range && dist > 1)
		dim_overlay()
		toggle_eyes_fowards()

//Handles eyes being deleted
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_eyes()
	SIGNAL_HANDLER

	eyes = null

/atom/movable/screen/plane_master/psychic
	name = "psychic plane master"
	plane = PSYCHIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 0

//keep this-
/atom/movable/screen/fullscreen/blind/psychic
	icon_state = "tv"
	icon = 'icons/mob/psychic.dmi'

//And this seperate to avoid issues with animations & locate()
/atom/movable/screen/fullscreen/blind/psychic_highlight
	icon_state = "tv_highlight"
	icon = 'icons/mob/psychic.dmi'
	plane = PSYCHIC_PLANE
	blend_mode = BLEND_INSET_OVERLAY

#undef psychic_overlay_upper
