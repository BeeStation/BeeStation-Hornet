///The limit when the psychic timer locks you out of creating more
#define PSYCHIC_OVERLAY_UPPER 400
///Burn mod for our species - we're weak to fire
#define PSYPHOZA_BURNMOD 1.25
///Invisibility layer for shrooms
#define SHROOM_DEPOSIT_INVISIBILITY 99

GLOBAL_LIST_INIT(psychic_sense_blacklist, typecacheof(list(/turf/open, /obj/machinery/door, /obj/machinery/light, /obj/machinery/firealarm,
	/obj/machinery/camera, /obj/machinery/atmospherics, /obj/structure/cable, /obj/structure/sign, /obj/machinery/airalarm, 
	/obj/structure/disposalpipe, /atom/movable/lighting_object, /obj/machinery/power/apc, /obj/machinery/atmospherics/pipe,
	/obj/item/radio/intercom, /obj/machinery/navbeacon, /obj/structure/extinguisher_cabinet, /obj/machinery/power/terminal,
	/obj/machinery/holopad, /obj/machinery/status_display, /obj/machinery/ai_slipper, /obj/structure/lattice, /obj/effect/decal,
	/obj/structure/table, /obj/machinery/gateway, /obj/structure/rack, /obj/machinery/newscaster, /obj/structure/sink, /obj/machinery/shower,
	/obj/machinery/advanced_airlock_controller, /obj/machinery/computer/security/telescreen, /obj/structure/grille, /obj/machinery/light_switch,
	/obj/structure/noticeboard, /area, /obj/item/storage/secure/safe, /obj/machinery/requests_console, /obj/item/storage/backpack/satchel/flat,
	/obj/effect/countdown, /obj/machinery/button, /obj/effect/clockwork/overlay/floor, /obj/structure/reagent_dispensers/peppertank,
	/mob/dead/observer, /mob/camera, /obj/structure/chisel_message, /obj/effect/particle_effect)))

/datum/species/psyphoza
	name = "\improper Psyphoza"
	id = SPECIES_PSYPHOZA
	bodyflag = FLAG_PSYPHOZA
	meat = /obj/item/reagent_containers/food/snacks/meat/slab/human/mutant/psyphoza
	species_traits = list(NOEYESPRITES, AGENDER, MUTCOLORS)
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza
	exotic_blood = /datum/reagent/drug/mushroomhallucinogen
	allow_numbers_in_name = TRUE

	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-2), OFFSET_EARS = list(0,-3), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,-2), OFFSET_HEAD = list(0,-2), OFFSET_FACE = list(0,-2), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

	mutant_brain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza
	mutanttongue = /obj/item/organ/tongue/psyphoza
	mutantstomach = /obj/item/organ/stomach/psyphoza

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
	if(unique && attempts < 10 && findname(.))
		return .(gender, TRUE, null, ++attempts)

/datum/species/psyphoza/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/drug) && H.blood_volume < BLOOD_VOLUME_NORMAL)
		H.blood_volume += chem.volume * 15
		H.reagents.remove_reagent(chem.type, chem.volume)
		return FALSE
	return ..()

/datum/species/psyphoza/spec_life(mob/living/carbon/human/H)
	if(world.time % 3)
		return
	var/obj/effect/psyphoza_spores/P = locate(/obj/effect/psyphoza_spores) in H.loc
	if(P && H.health < H.maxHealth)
		//healing
		var/amount = P.take_resources(3 * P.upgrades)
		H.heal_overall_damage(amount,amount, 0, BODYTYPE_ORGANIC)

/datum/species/psyphoza/get_scream_sound(mob/living/carbon/user)
	return pick('sound/voice/psyphoza/psyphoza_scream_1.ogg', 'sound/voice/psyphoza/psyphoza_scream_2.ogg')

//This originally held the psychic action until I moved it to the eyes, keep it please.
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
	var/sense_time = 7 SECONDS
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
	///Ref to change action
	var/datum/action/change_psychic_visual/overlay_change

/datum/action/item_action/organ_action/psychic_highlight/New(Target)
	. = ..()
	//Setup massive blacklist typecache of non-renderables. Smaller than whitelist
	sense_blacklist = GLOB.psychic_sense_blacklist

/datum/action/item_action/organ_action/psychic_highlight/Destroy()
	. = ..()
	QDEL_NULL(overlay_change)

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/M)
	. = ..()
	//Register signal for TK highlights
	RegisterSignal(M, COMSIG_MOB_ATTACK_RANGED, .proc/handle_ranged, TRUE)
	//Overlay used to highlight objects
	M.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/blind/psychic_highlight)
	//Add option to change visuals
	if(!(locate(/datum/action/change_psychic_visual) in owner.actions))
		overlay_change = new()
		overlay_change.Grant(owner)

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
		eyes = locate(/obj/item/organ/eyes) in H.internal_organs
		sight_flags = eyes?.sight_flags
		//Register signal for losing our eyes
		if(eyes)
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
		animate(P, color = "#000") //This is a fix for a bug with ``animate()`` breaking
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
	if(istype(owner?.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/helmet))
		to_chat(owner, "<span class='warning'>You can't use your senses while wearing helmets!</span>")
		return
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
	//Add overlay for highlighting
	target.add_overlay(M)
	overlays += list(target, M)
	RegisterSignal(target, COMSIG_PARENT_QDELETING, .proc/handle_target, TRUE)

//handle highlight object being deleted early
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_target(datum/source)
	SIGNAL_HANDLER

	overlays -= source

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
			continue
		var/atom/M = overlays[i]
		M.cut_overlay(overlays[i+1])
	overlays.Cut(1, 0)
	//Set eyes back to normal
	eyes?.sight_flags = sight_flags
	owner.update_sight()

//Handle clicking for ranged trigger
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_ranged(datum/source, atom/target)
	SIGNAL_HANDLER

	if(has_cooldown_timer || !owner)
		return
	var/turf/T = get_turf(target)
	if(get_dist(get_turf(owner), T) > 1)
		ping_turf(T, 2)
		has_cooldown_timer = TRUE
		addtimer(CALLBACK(src, .proc/finish_cooldown), (cooldown/1.5) + (sense_time * min(1, overlays.len / PSYCHIC_OVERLAY_UPPER)))

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
	var/origin_color = "#111"

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
	///Index for visual setting - Useful if we add more presets
	var/visual_index = 0
	
/atom/movable/screen/fullscreen/blind/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	filters += filter(type = "radial_blur", size = 0.012)
	cycle_visuals()

/atom/movable/screen/fullscreen/blind/psychic_highlight/proc/cycle_visuals()
	++visual_index
	//Reset animations
	animate(src, color = "#fff")
	//Set animation
	switch(visual_index)
		if(1) //Rainbow
			color = "#f00" // start at red
			animate(src, color = "#ff0", time = 0.3 SECONDS, loop = -1)
			animate(color = "#0f0", time = 0.3 SECONDS)
			animate(color = "#0ff", time = 0.3 SECONDS)
			animate(color = "#00f", time = 0.3 SECONDS)
			animate(color = "#f0f", time = 0.3 SECONDS)
			animate(color = "#f00", time = 0.3 SECONDS)
		if(2) //Custom
			color = input(usr,"","Choose Color","#fff") as color|null
	//Wrap index back around
	visual_index = visual_index >= 2 ? 0 :  visual_index

/datum/action/change_psychic_visual
	name = "Change Psychic Sense"
	desc = "Change the visual style of your psychic sense."
	icon_icon = 'icons/mob/actions.dmi'
	button_icon_state = "unknown"
	///Ref to the overlay - hard del edition
	var/atom/movable/screen/fullscreen/blind/psychic_highlight/psychic_overlay

/datum/action/change_psychic_visual/Trigger()
	. = ..()
	if(!psychic_overlay)
		psychic_overlay = locate(/atom/movable/screen/fullscreen/blind/psychic_highlight) in owner?.client?.screen
	psychic_overlay?.cycle_visuals()

/obj/effect/psyphoza_spores
	name = "psyphoza sprore deposit"
	icon = 'icons/effects/effects.dmi'
	icon_state = "shrooms"
	invisibility = SHROOM_DEPOSIT_INVISIBILITY
	plane = HUD_PLANE
	///Internal resources for healing
	var/resources = 0
	///Internal resource limit
	var/resource_limit = 20
	///Amount of upgrades
	var/upgrades = 1
	///Limit to upgrades
	var/upgrade_limit = 3
	///The calling card for this particular deposit
	var/message = ""
	///Resource rate
	var/resource_rate = 0.2

/obj/effect/psyphoza_spores/Initialize(mapload, new_message, col)
	. = ..()
	adjust_cap_color(mcol = col)
	message = new_message
	START_PROCESSING(SSobj, src)

/obj/effect/psyphoza_spores/proc/adjust_cap_color(mcol = "f0f")
	var/mutable_appearance/mut = mutable_appearance('icons/effects/effects.dmi', "shrooms_cap", layer+1, plane, color = "#[mcol]")
	add_overlay(mut)

/obj/effect/psyphoza_spores/attack_hand(mob/living/user)
	. = ..()
	to_chat(user, "<span class='notice'>Available resources: [resources] \nThe deposit echos: '[message]'</span>")

/obj/effect/psyphoza_spores/process(delta_time)
	resources = min(resources + (upgrades * resource_rate * delta_time), resource_limit*upgrades)

/obj/effect/psyphoza_spores/proc/take_resources(amount = 0)
	var/exchange = min(amount, resources)
	resources = max(0, resources-amount)
	return exchange

/obj/effect/psyphoza_spores/proc/upgrade()
	upgrades = min(upgrade_limit, upgrades+1)

#undef PSYCHIC_OVERLAY_UPPER
#undef PSYPHOZA_BURNMOD
#undef SHROOM_DEPOSIT_INVISIBILITY
