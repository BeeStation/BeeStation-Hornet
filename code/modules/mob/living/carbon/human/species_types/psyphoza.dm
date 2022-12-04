///A list of generated images from psychic sight. Saves us generating more than once.
GLOBAL_LIST_EMPTY(psychic_images)

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

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	C.dna.add_mutation(TK, MUT_NORMAL)

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
	/obj/structure/noticeboard, /area, /obj/item/storage/secure/safe, /obj/machinery/requests_console))

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/M)
	. = ..()
	//Register signal for TK highlights
	RegisterSignal(M, COMSIG_HUMAN_MELEE_UNARMED_ATTACK, .proc/handle_tk)

/datum/action/item_action/organ_action/psychic_highlight/Trigger()
	. = ..()
	if(has_cooldown_timer)
		return
	ping_turf(get_turf(owner))
	has_cooldown_timer = TRUE
	addtimer(CALLBACK(src, .proc/finish_cooldown), cooldown)

/datum/action/item_action/organ_action/psychic_highlight/proc/finish_cooldown()
	has_cooldown_timer = FALSE

/datum/action/item_action/organ_action/psychic_highlight/proc/ping_turf(turf/T, size = sense_range)
	//Grab eyes
	if(istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/M = owner
		eyes = locate(/obj/item/organ/eyes) in M.internal_organs
		sight_flags = eyes?.sight_flags
	//handle eyes
	eyes?.sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	owner.update_sight()

	//Dull blind overlay
	var/atom/movable/screen/fullscreen/blind/psychic/P = locate (/atom/movable/screen/fullscreen/blind/psychic) in owner.client?.screen
	if(P)
		//We change the color instead of alpha, otherwise we'd reveal our actual surroundings!
		P.color = "#000"
		animate(P, color = "#fff", time = sense_time+1 SECONDS, easing = QUAD_EASING, flags = EASE_IN)
	//Get nearby 'things'
	var/list/nearby = range(size, T)
	nearby -= owner
	//Go through the list and render whitelisted types
	for(var/atom/C as() in nearby)
		//Check typecache
		if(is_type_in_typecache(C, sense_blacklist))
			continue
		highlight_object(C)

//Highlight a given object
/datum/action/item_action/organ_action/psychic_highlight/proc/highlight_object(atom/target)
	//Pull icon from pre-gen, if it exists
	var/icon/I = GLOB.psychic_images["[target.type][target.icon_state]"]
	//Build icon if it doesn't exist
	if(!I)
		I = icon('icons/mob/psychic.dmi', "texture")
		var/icon/mask = icon(target.icon, target.icon_state, target.dir)
		if(target.icon_state == "")
			var/state = isliving(target) ? "mob" : "unknown"
			mask = icon('icons/mob/psychic.dmi', state)
		I.AddAlphaMask(mask)
		GLOB.psychic_images += list("[target.type][target.icon_state]" = icon(I))
	//Setup display image
	var/image/M = image(I, target, layer = BLIND_LAYER+1, pixel_x = target.pixel_x, pixel_y = target.pixel_y)
	M.plane = FULLSCREEN_PLANE+1
	M.filters += filter(type = "bloom", size = 3, threshold = rgb(85,85,85))
	M.override = 1
	M.name = "???"
	//Animate fade & delete
	animate(M, alpha = 0, time = sense_time, easing = QUAD_EASING, flags = EASE_IN)
	addtimer(CALLBACK(src, .proc/handle_image, M), sense_time)
	//Add image to client
	owner.client.images += M

/datum/action/item_action/organ_action/psychic_highlight/proc/handle_tk(datum/source, atom/target)
	if(has_cooldown_timer)
		return
	var/turf/T = get_turf(target)
	if(get_dist(get_turf(owner), T) > 1)
		ping_turf(T, 2)
		has_cooldown_timer = TRUE
		addtimer(CALLBACK(src, .proc/finish_cooldown), cooldown/2)

/datum/action/item_action/organ_action/psychic_highlight/proc/handle_image(image/image_ref)
	owner.client.images -= image_ref
	qdel(image_ref)
	if(!owner.client.images.len)
		eyes?.sight_flags = sight_flags
		owner.update_sight()


/mob/living/proc/become_psychic_blind(source)
	if(!HAS_TRAIT(src, TRAIT_BLIND))
		blind_eyes(1, /atom/movable/screen/fullscreen/blind/psychic)
	ADD_TRAIT(src, TRAIT_BLIND, source)
