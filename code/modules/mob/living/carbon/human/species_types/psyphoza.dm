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

/datum/species/psyphoza/check_roundstart_eligible()
	return TRUE
/obj/item/organ/brain/psyphoza
	name = "psyphoza brain"
	desc = "Bubbling with psychic energy!"
	actions_types = list(/datum/action/item_action/organ_action/psychic_highlight)
	color = "#ff00ee"

/datum/action/item_action/organ_action/psychic_highlight
	name = "Psychic Sense"
	desc = "Sense your surroundings psychically."
	///The distant our psychic sense works
	var/sense_range = 5
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 5 SECONDS

/datum/action/item_action/organ_action/psychic_highlight/New(Target)
	. = ..()
	sense_blacklist = typecacheof(list(/turf/open, /obj/machinery/door, /obj/machinery/light, /obj/machinery/firealarm,
	/obj/machinery/camera, /obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/sign, /obj/machinery/airalarm, 
	/obj/structure/disposalpipe, /atom/movable/lighting_object, /obj/machinery/power/apc, /obj/machinery/atmospherics/pipe,
	/obj/item/radio/intercom, /obj/machinery/navbeacon, /obj/structure/extinguisher_cabinet, /obj/machinery/power/terminal,
	/obj/machinery/holopad, /obj/machinery/status_display, /obj/machinery/ai_slipper))

/datum/action/item_action/organ_action/psychic_highlight/Trigger()
	. = ..()
	//Get nearby 'things'
	var/list/nearby = orange(sense_range, get_turf(src))
	//Go through the list and render whitelisted types
	for(var/atom/C as() in nearby)
		//Check typecache
		if(is_type_in_typecache(C, sense_blacklist))
			continue
		//Pull icon from pre-gen 
		var/icon/I = GLOB.psychic_images["[C.type][C.icon_state]"]
		//Build image if it doesn't exist
		if(!I)
			//Setup image base
			I = icon('icons/mob/psychic.dmi', "psychic")
			var/icon/mask = icon(C.icon_state == "" ? 'icons/mob/psychic.dmi' : C.icon, C.icon_state == "" ? "unknown" : C.icon_state, C.dir)
			I.AddAlphaMask(mask)
			GLOB.psychic_images += list("[C.type][C.icon_state]" = icon(I))
		//Setup display image
		var/image/M = image(I, get_turf(C), layer = BLIND_LAYER+1, pixel_x = C.pixel_x, pixel_y = C.pixel_y)
		M.plane = FULLSCREEN_PLANE+1
		//Animate fade & delete
		animate(M, alpha = 0, time = sense_time)
		addtimer(CALLBACK(src, .proc/handle_image, M), sense_time)
		//Add image to client
		owner.client.images += M

/datum/action/item_action/organ_action/psychic_highlight/proc/handle_image(image/image_ref)
	owner.client.images -= image_ref
	qdel(image_ref)
