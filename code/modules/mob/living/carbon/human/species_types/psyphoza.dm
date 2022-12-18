///The limit when the psychic timer locks you out of creating more
#define PSYCHIC_OVERLAY_UPPER 400
///Burn mod for our species - we're weak to fire
#define PSYPHOZA_BURNMOD 1.25

/datum/species/psyphoza
	name = "\improper Psyphoza"
	id = SPECIES_PSYPHOZA
	bodyflag = FLAG_PSYPHOZA
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/psyphoza
	species_traits = list(NOEYESPRITES, AGENDER, MUTCOLORS, TRAIT_RESISTCOLD)
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza
	allow_numbers_in_name = TRUE

	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-2), OFFSET_EARS = list(0,-3), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,-2), OFFSET_HEAD = list(0,-2), OFFSET_FACE = list(0,-2), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

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

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.dna.add_mutation(TK_WEAK, MUT_OTHER)

/datum/species/psyphoza/random_name(gender, unique, lastname, attempts)
	var/num = rand(1, 9)
	var/end
	switch(num)
		if(1)
			end = "st"
		if(2)
			end = "nd"
		if(3)
			end = "rd"
		else
			end = "th"
	. = "[pick(GLOB.psyphoza_first_names)] the [rand(1, 10) * 100 + num][end]"
	if(unique && attempts < 10)
		if(findname(.))
			. = .(gender, TRUE, null, ++attempts)


/datum/species/psyphoza/get_scream_sound(mob/living/carbon/user)
	return pick('sound/voice/psyphoza/psyphoza_scream_1.ogg', 'sound/voice/psyphoza/psyphoza_scream_2.ogg')

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
	///The eyes original sight flags - used between toggles
	var/sight_flags
	///Time between uses
	var/cooldown = 1 SECONDS
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
	/mob/dead/observer, /mob/camera, /obj/structure/chisel_message))

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/M)
	. = ..()
	//Register signal for TK highlights
	RegisterSignal(M, COMSIG_MOB_ATTACK_RANGED, .proc/handle_ranged)
	//Overlay used to highlight objects
	M.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/blind/psychic_highlight)

/datum/action/item_action/organ_action/psychic_highlight/Trigger()
	. = ..()
	if(has_cooldown_timer || !owner)
		return
	ping_turf(get_turf(owner))
	has_cooldown_timer = TRUE
	addtimer(CALLBACK(src, .proc/finish_cooldown), cooldown + (sense_time * min(1, overlays.len / PSYCHIC_OVERLAY_UPPER)))

/datum/action/item_action/organ_action/psychic_highlight/proc/finish_cooldown()
	has_cooldown_timer = FALSE

//Allows user to see images through walls
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_fowards()
	//Grab organs - we do this here becuase of fuckery :tm:
	if(!eyes && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		//eyes
		eyes = eyes || locate(/obj/item/organ/eyes) in H.internal_organs
		sight_flags = eyes?.sight_flags
		//Register signal for losing our eyes
		RegisterSignal(eyes, COMSIG_PARENT_QDELETING, .proc/handle_eyes)

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
	toggle_eyes_fowards()
	dim_overlay()
	//Get nearby 'things' to see with sense
	var/list/nearby = range(size, T)
	nearby -= owner
	//Go through the list and render whitelisted types
	for(var/atom/C as() in nearby)
		if(is_type_in_typecache(C, sense_blacklist))
			continue
		highlight_object(C)

//Add overlay for psychic plane
/datum/action/item_action/organ_action/psychic_highlight/proc/highlight_object(atom/target)
	//Build image
	var/image/M = new()
	M.appearance = target.appearance
	M.transform = target.transform
	M.pixel_x = 0 //Reset pixel adjustments to avoid bug where overlays tower
	M.pixel_y = 0
	M.pixel_z = 0
	M.pixel_w = 0
	M.plane = PSYCHIC_PLANE //Draw overlay on this plane so we can use it as a mask
	M.dir = target.dir
	//make another image to obscure the name of the most likely xray'd target - also acts as the insert for the target in overlay list
	var/image/N = new(M)
	N.override = TRUE
	N.loc = target
	N.plane = target.plane
	N.layer = target.layer
	N.name = "???" //Stop players reading names
	owner.client.images += N
	//Add overlay for highlighting
	N.add_overlay(M)
	overlays += N
	//Register signal for direction stuff (WHY THE FUCK WOULDNT AN IMAGE UPDATE ITS DIRECTION TO ITS LOC?)
	if(ismovable(target))
		N.RegisterSignal(target, COMSIG_MOVABLE_MOVED, /image/.proc/update_dir)

/image/proc/update_dir(datum/source, atom/target, _dir)
	SIGNAL_HANDLER

	dir = _dir
	transform = target.transform

//Handle clicking for ranged trigger
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_ranged(datum/source, atom/target)
	SIGNAL_HANDLER

	if(has_cooldown_timer || !owner)
		return
	var/turf/T = get_turf(target)
	if(get_dist(get_turf(owner), T) > 1)
		ping_turf(T, 2)
		has_cooldown_timer = TRUE
		addtimer(CALLBACK(src, .proc/finish_cooldown), (cooldown/2) + (sense_time * min(1, overlays.len / PSYCHIC_OVERLAY_UPPER)))

//Handle images deleting, stops hardel - also does eyes stuff
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_backwards()
	//Timer steps
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
	//Set eyes back to normal
	eyes?.sight_flags = sight_flags
	owner.update_sight()

//Handles eyes being deleted
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_eyes()
	SIGNAL_HANDLER

	eyes = null

//Plane that holds the masks for psychic ping
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
	//The color we return to after going black & back.
	var/origin_color = "#1a1a1a"

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	filters += filter(type = "radial_blur", size = 0.012)
	color = origin_color

//And this type as a seperate type-path to avoid issues with animations & locate()
/atom/movable/screen/fullscreen/blind/psychic_highlight
	icon_state = "trip"
	icon = 'icons/mob/psychic.dmi'
	plane = PSYCHIC_PLANE
	blend_mode = BLEND_INSET_OVERLAY
	
/atom/movable/screen/fullscreen/blind/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	filters += filter(type = "radial_blur", size = 0.012)
	//Color animation
	color = "#f00" // start at red
	animate(src, color = "#ff0", time = 0.3 SECONDS, loop = -1, flags = ANIMATION_PARALLEL)
	animate(color = "#0f0", time = 0.3 SECONDS)
	animate(color = "#0ff", time = 0.3 SECONDS)
	animate(color = "#00f", time = 0.3 SECONDS)
	animate(color = "#f0f", time = 0.3 SECONDS)
	animate(color = "#f00", time = 0.3 SECONDS)

#undef PSYCHIC_OVERLAY_UPPER
#undef PSYPHOZA_BURNMOD
