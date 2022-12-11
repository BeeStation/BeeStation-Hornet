///The limit when the psychic timer locks you out of creating more
#define PSYCHIC_OVERLAY_UPPER 400
///Burn mod for our species - we're weak to fire
#define PSYPHOZA_BURNMOD 1.25

/datum/species/psyphoza
	name = "\improper Psyphoza"
	id = SPECIES_PSYPHOZA
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/psyphoza
	species_traits = list(NOEYESPRITES, AGENDER, MUTCOLORS, TRAIT_RESISTCOLD)
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza

	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-1), OFFSET_EARS = list(0,-1), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,-1), OFFSET_HEAD = list(0,-1), OFFSET_FACE = list(0,-1), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

	mutant_brain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza
	mutanttongue = /obj/item/organ/tongue/psyphoza

	attack_verb = "slash"
	attack_sound = 'sound/weapons/slice.ogg'
	miss_sound = 'sound/weapons/slashmiss.ogg'

	mutant_bodyparts = list("psyphoza_cap")
	default_features = list("psyphoza_cap" = "Portobello", "body_size" = "Normal")

	species_chest = /obj/item/bodypart/chest/psyphoza
	species_head = /obj/item/bodypart/head/psyphoza
	species_l_arm = /obj/item/bodypart/l_arm/psyphoza
	species_r_arm = /obj/item/bodypart/r_arm/psyphoza
	species_l_leg = /obj/item/bodypart/l_leg/psyphoza
	species_r_leg = /obj/item/bodypart/r_leg/psyphoza

	//Fire bad!
	burnmod = PSYPHOZA_BURNMOD

/datum/species/psyphoza/check_roundstart_eligible()
	return TRUE

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.dna.add_mutation(TK_WEAK, MUT_OTHER)

//This originally held the psychic action until I moved it to the eyes, keep it please
/obj/item/organ/brain/psyphoza
	name = "psyphoza brain"
	desc = "Bubbling with psychic energy..no wait...that's blood."
	color = "#ff00ee"

// PSYCHIC ECHOLOCATION
/datum/action/item_action/organ_action/psychic_highlight
	name = "Psychic Sense"
	desc = "Sense your surroundings psychically."
	///The distant our psychic sense works
	var/sense_range = 5
	///The range we can hear-ping things from
	var/hear_range = 8
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS
	///Reference to the users eyes - we use this to toggle xray vision for scans
	var/obj/item/organ/eyes/eyes
	///Reference to the users ears - we use this for stuff :)
	var/obj/item/organ/ears/ears
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
	addtimer(CALLBACK(src, .proc/finish_cooldown), cooldown + (sense_time * min(1, overlays.len / PSYCHIC_OVERLAY_UPPER)))

/datum/action/item_action/organ_action/psychic_highlight/proc/finish_cooldown()
	has_cooldown_timer = FALSE

//Allows user to see images through walls
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_fowards()
	//Grab organs - we do this here becuase of fuckery :tm:
	if((!eyes || !ears) && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		//eyes
		eyes = eyes || locate(/obj/item/organ/eyes) in H.internal_organs
		sight_flags = eyes?.sight_flags
		//Register signal for losing our eyes
		RegisterSignal(eyes, COMSIG_PARENT_QDELETING, .proc/handle_eyes)
		//ears
		ears = ears || locate(/obj/item/organ/ears) in H.internal_organs
		//Register signal for losing our ears
		RegisterSignal(ears, COMSIG_PARENT_QDELETING, .proc/handle_ears)

	//handle eyes - make them xray so we can see all the things
	eyes?.sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	owner.update_sight()

//Dims blind overlay - Lightens highlight layer
/datum/action/item_action/organ_action/psychic_highlight/proc/dim_overlay()
	//Blind layer
	var/atom/movable/screen/fullscreen/blind/psychic/P = locate (/atom/movable/screen/fullscreen/blind/psychic) in owner.client?.screen
	if(P)
		//We change the color instead of alpha, otherwise we'd reveal our actual surroundings!
		P.color = "#000"
		animate(P, color = P.origin_color, time = sense_time, easing = QUAD_EASING, flags = EASE_IN)
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
	//Build image
	var/image/M = new()
	M.appearance = target.appearance
	M.pixel_x = 0 //Reset pixel adjustments to avoid unique bug - comment these two lines for funny
	M.pixel_y = 0
	M.pixel_z = 0
	M.pixel_w = 0
	M.plane = PSYCHIC_PLANE
	M.dir = target.dir //Not sure why I have to do this?
	//make another image to obscure the name of the most likely xray'd target - also acts as the insert for the target
	var/image/N = new(M)
	N.name = "???"
	N.override = TRUE
	N.loc = target
	N.plane = target.plane
	owner.client.images += N
	//Add overlay for highlighting
	N.add_overlay(M)
	//Append overlay-holder image for removal later
	overlays += N

//Handle clicking for ranged trigger
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_ranged(datum/source, atom/target)
	SIGNAL_HANDLER

	if(has_cooldown_timer)
		return
	var/turf/T = get_turf(target)
	if(get_dist(get_turf(owner), T) > 1)
		ping_turf(T, 2)
		has_cooldown_timer = TRUE
		addtimer(CALLBACK(src, .proc/finish_cooldown), (cooldown/2) + (sense_time * min(1, overlays.len / PSYCHIC_OVERLAY_UPPER)))

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
			if(!isnull(overlays[i]))
				var/image/M = overlays[i]
				M.cut_overlays()
				owner.client.images -= M
				qdel(M)
			continue
	overlays.Cut(1, 0)
	//eyes
	eyes?.sight_flags = sight_flags
	owner.update_sight()

//Dim blind overlay for blind_sense component
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_hear(datum/source, atom/speaker, message)
	SIGNAL_HANDLER

	if(ears?.deaf)
		return
	var/dist = get_dist(get_turf(owner), get_turf(speaker))
	if(dist <= hear_range && dist > 1)
		dim_overlay()
		toggle_eyes_fowards()

//Handles eyes being deleted
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_eyes()
	SIGNAL_HANDLER

	eyes = null

//Handles ears being deleted
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_ears()
	SIGNAL_HANDLER

	ears = null

/atom/movable/screen/plane_master/psychic
	name = "psychic plane master"
	plane = PSYCHIC_PLANE
	appearance_flags = PLANE_MASTER
	blend_mode = BLEND_OVERLAY
	alpha = 0

//keep this type-
/atom/movable/screen/fullscreen/blind/psychic
	icon_state = "trip"
	icon = 'icons/mob/psychic.dmi'
	var/origin_color = "#1a1a1a"

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	//Display type
	filters += filter(type = "radial_blur", size = 0.012)
	//Set color to a darker shade, for the sake of our eyes
	color = origin_color

//And this seperate to avoid issues with animations & locate()
/atom/movable/screen/fullscreen/blind/psychic_highlight
	icon_state = "trip"
	icon = 'icons/mob/psychic.dmi'
	plane = PSYCHIC_PLANE
	blend_mode = BLEND_INSET_OVERLAY
	
/atom/movable/screen/fullscreen/blind/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	filters += filter(type = "radial_blur", size = 0.012)
	//All the colors
	color = "#f00" // start at red
	animate(src, color = "#ff0", time = 0.3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(color = "#0f0", time = 0.3 SECONDS)
	animate(color = "#0ff", time = 0.3 SECONDS)
	animate(color = "#00f", time = 0.3 SECONDS)
	animate(color = "#f0f", time = 0.3 SECONDS)
	animate(color = "#f00", time = 0.3 SECONDS)

//Overwrite this so the head is drawn on the upmost, otherwise head sprite, for psyphoza, clips into arms
/datum/species/psyphoza/replace_body(mob/living/carbon/C, var/datum/species/new_species)
	..()
	new_species ||= C.dna.species
	
	for(var/obj/item/bodypart/old_part as() in C.bodyparts)
		if(old_part.change_exempt_flags & BP_BLOCK_CHANGE_SPECIES)
			continue

		switch(old_part.body_zone)
			if(BODY_ZONE_HEAD)
				var/obj/item/bodypart/head/new_part = new new_species.species_head()
				new_part.replace_limb(C, TRUE)
				new_part.update_limb(is_creating = TRUE)
				qdel(old_part)


#undef PSYCHIC_OVERLAY_UPPER
#undef PSYPHOZA_BURNMOD
