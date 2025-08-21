/datum/species/psyphoza
	name = "\improper Psyphoza"
	plural_form = "Psyphoza"
	id = SPECIES_PSYPHOZA
	bodyflag = FLAG_PSYPHOZA
	meat = /obj/item/food/meat/slab/human/mutant/psyphoza
	species_traits = list(NOEYESPRITES, AGENDER, MUTCOLORS)
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza
	exotic_blood = /datum/reagent/drug/mushroomhallucinogen
	allow_numbers_in_name = TRUE
	inert_mutation = /datum/mutation/spores

	offset_features = list(OFFSET_UNIFORM = list(0,0), OFFSET_ID = list(0,0), OFFSET_GLOVES = list(0,0), OFFSET_GLASSES = list(0,-2), OFFSET_EARS = list(0,-3), OFFSET_SHOES = list(0,0), OFFSET_S_STORE = list(0,0), OFFSET_FACEMASK = list(0,-2), OFFSET_HEAD = list(0,-2), OFFSET_FACE = list(0,-2), OFFSET_BELT = list(0,0), OFFSET_BACK = list(0,0), OFFSET_SUIT = list(0,0), OFFSET_NECK = list(0,0))

	mutantbrain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza
	mutanttongue = /obj/item/organ/tongue/psyphoza

	mutant_bodyparts = list("psyphoza_cap" = "Portobello", "body_size" = "Normal", "mcolor" = "fff")
	hair_color = "fixedmutcolor"

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/psyphoza,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/psyphoza,
		BODY_ZONE_L_ARM = /obj/item/bodypart/l_arm/psyphoza,
		BODY_ZONE_R_ARM = /obj/item/bodypart/r_arm/psyphoza,
		BODY_ZONE_L_LEG = /obj/item/bodypart/l_leg/psyphoza,
		BODY_ZONE_R_LEG = /obj/item/bodypart/r_leg/psyphoza
	)

	//Fire bad!
	burnmod = 1.25

	species_height = SPECIES_HEIGHTS(2, 1, 0)

	//Reference to psychic highlight action
	var/datum/action/item_action/organ_action/psychic_highlight/PH

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	PH = locate(/datum/action/item_action/organ_action/psychic_highlight) in C.actions
	ADD_TRAIT(C, TRAIT_PSYCHIC_SENSE, SPECIES_TRAIT)

/datum/species/psyphoza/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	C.cure_blind(SPECIES_PSYPHOZA)
	. = ..()
	REMOVE_TRAIT(C, TRAIT_PSYCHIC_SENSE, SPECIES_TRAIT)
	PH = null

/datum/species/psyphoza/random_name(gender, unique, lastname, attempts)
	. = "[pick(GLOB.psyphoza_first_names)] [pick(GLOB.psyphoza_last_names)]"
	if(unique && attempts < 10 && findname(.))
		return .(gender, TRUE, null, ++attempts)

/datum/species/psyphoza/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/H)
	if(istype(chem, /datum/reagent/drug) && H.blood_volume < BLOOD_VOLUME_NORMAL)
		H.blood_volume += chem.volume * 15
		H.reagents.remove_reagent(chem.type, chem.volume)
		return FALSE
	return ..()

/datum/species/psyphoza/get_scream_sound(mob/living/carbon/user)
	return pick('sound/voice/psyphoza/psyphoza_scream_1.ogg', 'sound/voice/psyphoza/psyphoza_scream_2.ogg')

/datum/species/psyphoza/primary_species_action()
	. = ..()
	PH?.trigger()

/datum/species/psyphoza/get_species_description()
	return "Psyphoza are a species of extra-sensory lesser-sensory \
	fungal-form humanoids, infamous for their invulnerability to \
	occlusion-based magic tricks and sleight of hand."

/datum/species/psyphoza/get_species_lore()
	return list(
		"A standing testament to the humor of mother nature, Psyphoza have evolved powerful and mystical \
			psychic abilities, which are almost completely mitigated by the fact they are absolutely \
			blind, and depend entirely on their psychic abilities to navigate their surroundings.",

		"Psyphoza culture is deeply rooted in superstition, mysticism, and the occult. It is their belief \
			that the morphology of their cap deeply impacts the course of their life, with characteristics \
			such as size, colour, and shape influencing how irrespectively lucky or unlucky they might be in \
			their experiences.",

		"An unfortunate superstition that Psyphoza 'meat' and 'blood' contain powerful psychedelics has caused \
			many individuals of the species to be targeted, and hunted, by rich & eccentric individuals who wish \
			to taste their flesh, and learn the truth for themselves. Unfortunately for Psyphoza, \
			this superstition is completely true...",

		"Although most Psyphoza have left behind a majority of the especially superstitious ideas of their \
			progenitors, some lower caste members still cling to these old ideas as strongly as ever. These beliefs \
			impact their culture deeply, resulting in very different behaviors between the typical and lower castes."
	)

/datum/species/psyphoza/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "lightbulb",
			SPECIES_PERK_NAME = "Psychic",
			SPECIES_PERK_DESC = "Psyphoza are psychic and can sense things others can't.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
			SPECIES_PERK_ICON = "biohazard",
			SPECIES_PERK_NAME = "Drug Codependance",
			SPECIES_PERK_DESC = "Consuming any kind of drug will replenish a Psyphoza's blood.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Blind",
			SPECIES_PERK_DESC = "Psyphoza are blind and can't see outside their immediate location and psychic sense.",
		),
		list(
			SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
			SPECIES_PERK_ICON = "eye",
			SPECIES_PERK_NAME = "Epilepsy Warning",
			SPECIES_PERK_DESC = "This species features effects that individuals with epilepsy may experience negatively!",
		),
	)

	return to_add

//This originally held the psychic action until I moved it to the eyes, keep it please.
/obj/item/organ/brain/psyphoza
	name = "psyphoza brain"
	desc = "Bubbling with psychic energy...no wait...that's blood."
	color = "#ff00ee"

// PSYCHIC ECHOLOCATION
/datum/action/item_action/organ_action/psychic_highlight
	name = "Psychic Sense"
	desc = "Sense your surroundings psychically."
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "activate_psychic"
	transparent_when_unavailable = TRUE
	///The distant our psychic sense works
	var/psychic_scale = 2.28
	///The range we can hear-ping things from
	var/hear_range = 8
	///List of things we can't sense
	var/list/sense_blacklist
	///The amount of time you can sense things for
	var/sense_time = 10 SECONDS
	///Reference to the users eyes - we use this to toggle xray vision for scans
	var/obj/item/organ/eyes/eyes
	///The eyes original sight flags - used between toggles
	var/sight_flags
	///Time between uses
	var/cooldown = 1 SECONDS
	///Reference to 'kill these overlays' timer
	var/psychic_timer
	///Ref to change action
	var/datum/action/change_psychic_visual/overlay_change
	///Ref to other change action
	var/datum/action/change_psychic_texture/texture_change
	///The amount of time between auto uses
	var/auto_cooldown = 1 SECONDS
	///Do we have auto sense toggled?
	var/auto_sense = FALSE
	///Ref to sense auto toggle action
	var/datum/action/change_psychic_auto/auto_action
	///has this ability been removed via surgery - ability code is weird
	var/removed = FALSE

/datum/action/item_action/organ_action/psychic_highlight/Destroy()
	remove()
	return ..()

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/M)
	. = ..()
	//Overlay used to highlight objects
	M.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/blind/psychic_highlight)
	M.overlay_fullscreen("psychic_highlight_mask", /atom/movable/screen/fullscreen/blind/psychic/mask)
	var/atom/movable/screen/fullscreen/blind_context_disable/B = M.overlay_fullscreen("psychic_highlight_click_mask", /atom/movable/screen/fullscreen/blind_context_disable)
	B.owner = M?.client
	B.mob_owner = M
	//Add option to change visuals
	if(!(locate(/datum/action/change_psychic_visual) in owner.actions))
		overlay_change = new(src)
		overlay_change.Grant(owner)
	///Give owner texture action
	if(!(locate(/datum/action/change_psychic_texture) in owner.actions))
		texture_change = new(src)
		texture_change.Grant(M)
	///Give owner auto action
	if(!(locate(/datum/action/change_psychic_auto) in owner.actions))
		auto_action = new(src)
		auto_action.Grant(M)
	///Start auto timer
	addtimer(CALLBACK(src, PROC_REF(auto_sense)), auto_cooldown)

/datum/action/item_action/organ_action/psychic_highlight/on_activate(mob/user, atom/target)
	if(!owner || !check_head())
		return
	//Reveal larger area of sense
	dim_overlay()
	//Blind sense stuffs
	var/datum/component/blind_sense/BS = owner.GetComponent(/datum/component/blind_sense)
	if(BS)
		for(var/mob/living/L in urange(9, owner, 1))
			BS.highlight_object(L, "mob", L.dir)
	update_buttons()
	addtimer(CALLBACK(src, PROC_REF(finish_cooldown)), cooldown + sense_time) //Overwrite this line from the original to support my fucked up use

/datum/action/item_action/organ_action/psychic_highlight/proc/remove()
	owner?.clear_fullscreen("psychic_highlight")
	owner?.clear_fullscreen("psychic_highlight_mask")
	owner?.clear_fullscreen("psychic_highlight_click_mask")
	eyes = null
	//This can get *tricky*
	if(!QDELETED(overlay_change))
		qdel(overlay_change)
	if(!QDELETED(texture_change))
		qdel(texture_change)
	if(!QDELETED(auto_action))
		qdel(auto_action)

/datum/action/item_action/organ_action/psychic_highlight/proc/auto_sense()
	if(auto_sense)
		trigger()
	addtimer(CALLBACK(src, PROC_REF(auto_sense)), auto_cooldown)

/datum/action/item_action/organ_action/psychic_highlight/proc/finish_cooldown()
	update_buttons()

//Allows user to see images through walls - mostly for if this action is added to something without xray
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_fowards()
	//Grab organs - we do this here becuase of fuckery :tm:
	if(!eyes && istype(owner, /mob/living/carbon/human))
		var/mob/living/carbon/human/H = owner
		//eyes
		eyes = locate(/obj/item/organ/eyes) in H.internal_organs
		sight_flags = eyes?.sight_flags
		//Register signal for losing our eyes
		if(eyes)
			RegisterSignal(eyes, COMSIG_QDELETING, PROC_REF(handle_eyes))

	//handle eyes - make them xray so we can see all the things
	eyes?.sight_flags = SEE_MOBS | SEE_OBJS | SEE_TURFS
	owner.update_sight()

//Handle images deleting, stops hardel - also does eyes stuff
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_backwards()
	//Timer steps
	if(psychic_timer)
		deltimer(psychic_timer)
		psychic_timer = null
	//Set eyes back to normal
	eyes?.sight_flags = sight_flags
	owner.update_sight()

//Dims blind overlay - Lightens highlight layer
/datum/action/item_action/organ_action/psychic_highlight/proc/dim_overlay()
	//Blind layer
	var/atom/movable/screen/fullscreen/blind/psychic/P = locate(/atom/movable/screen/fullscreen/blind/psychic) in owner.client?.screen
	if(P)
		//We change the color instead of alpha, otherwise we'd reveal our actual surroundings!
		animate(P, color = "#000") //This is a fix for a bug with ``animate()`` breaking
		animate(P, color = P.origin_color, time = sense_time, easing = SINE_EASING, flags = EASE_IN)
	//Highlight layer
	var/atom/movable/screen/fullscreen/blind/psychic/mask/B = locate(/atom/movable/screen/fullscreen/blind/psychic/mask) in owner.client?.screen
	if(B)
		var/matrix/ntransform = matrix(B.transform) //new scale
		ntransform.Scale(psychic_scale)
		var/matrix/otransform = matrix(B.transform) //old scale
		animate(B, transform = ntransform)
		animate(B, transform = otransform, time = sense_time, easing = SINE_EASING, flags = EASE_IN)
	//Setup timer to delete image
	if(psychic_timer)
		deltimer(psychic_timer)
	psychic_timer = addtimer(CALLBACK(src, PROC_REF(toggle_eyes_backwards)), sense_time, TIMER_STOPPABLE)

//Get a list of nearby things & run 'em through a typecache
/datum/action/item_action/organ_action/psychic_highlight/proc/check_head()
	if(istype(owner?.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/helmet))
		to_chat(owner, span_warning("You can't use your senses while wearing helmets!"))
		return FALSE
	return TRUE

//Handles eyes being deleted
/datum/action/item_action/organ_action/psychic_highlight/proc/handle_eyes()
	SIGNAL_HANDLER

	eyes = null

//keep this type-
/atom/movable/screen/fullscreen/blind/psychic
	icon_state = "trip"
	icon = 'icons/hud/fullscreen/psychic.dmi'
	///The color we return to after going black & back.
	var/origin_color = "#111"
	///Index for texture setting - Useful if we add more presets
	var/texture_index = 0

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	cycle_textures()

//Copied code, it'll be fine
/atom/movable/screen/fullscreen/blind/psychic/proc/cycle_textures(new_texture)
	++texture_index
	color = origin_color
	if(new_texture)
		appearance = new_texture
		return
	else
		//Set animation
		switch(texture_index)
			if(1)
				icon_state = "trip"
			if(2)
				icon_state = "trip_static"
			if(3)
				icon_state = "trip_static_hole"
				color = "#000"
	//Wrap index back around
	texture_index = texture_index >= 3 ? 0 :  texture_index

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	unique_filters()
	color = origin_color

/atom/movable/screen/fullscreen/blind/psychic/proc/unique_filters()
	filters += filter(type = "radial_blur", size = 0.0125)

/atom/movable/screen/fullscreen/blind/psychic/mask
	icon_state = "mask_small"
	render_target = "psychic_mask"

/atom/movable/screen/fullscreen/blind/psychic/mask/unique_filters()
	filters += filter(type = "alpha", render_source = "blind_fullscreen_overlay")

//And this type as a seperate type-path to avoid issues with animations & locate()
/atom/movable/screen/fullscreen/blind/psychic_highlight
	icon_state = "trip"
	icon = 'icons/hud/fullscreen/psychic.dmi'
	render_target = ""
	plane = FULLSCREEN_PLANE
	layer = 4.1
	///Index for visual setting - Useful if we add more presets
	var/visual_index = 0
	///Index for texture setting - Useful if we add more presets
	var/texture_index = 0

/atom/movable/screen/fullscreen/blind/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "alpha", render_source = GAME_PLANE_RENDER_TARGET)
	filters += filter(type = "alpha", render_source = ANTI_PSYCHIC_PLANE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type = "alpha", render_source = "psychic_mask")
	filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	filters += filter(type = "radial_blur", size = 0.0125)
	cycle_visuals()
	cycle_textures()

/atom/movable/screen/fullscreen/blind/psychic_highlight/proc/cycle_visuals(new_color)
	++visual_index
	//Reset animations
	animate(src, color = "#fff")
	if(new_color)
		color = new_color
	else
		//Set animation
		switch(visual_index)
			if(1) //Rainbow
				color = "#f00" // start at red
				animate(src, color = "#ff0", time = 1 SECONDS, loop = -1)
				animate(color = "#0f0", time = 1 SECONDS)
				animate(color = "#0ff", time = 1 SECONDS)
				animate(color = "#00f", time = 1 SECONDS)
				animate(color = "#f0f", time = 1 SECONDS)
				animate(color = "#f00", time = 1 SECONDS)
			if(2) //Custom
				color = tgui_color_picker(usr, "Pick new color", "[src]", COLOR_WHITE)
				. = color
	//Wrap index back around
	visual_index = visual_index >= 2 ? 0 :  visual_index

/atom/movable/screen/fullscreen/blind/psychic_highlight/proc/cycle_textures(new_texture)
	++texture_index
	if(new_texture)
		appearance = new_texture
		return
	else
		//Set animation
		switch(texture_index)
			if(1)
				icon_state = "trip"
			if(2)
				icon_state = "trip_static"
			if(3)
				icon_state = "trip_static_white"
	//Wrap index back around
	texture_index = texture_index >= 3 ? 0 :  texture_index

//Action for changing screen color
/datum/action/change_psychic_visual
	name = "Change Psychic Sense"
	desc = "Change the visual style of your psychic sense."
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_color"
	///Ref to the overlay - hard del edition
	var/atom/movable/screen/fullscreen/blind/psychic_highlight/psychic_overlay

/datum/action/change_psychic_visual/New(Target)
	. = ..()
	RegisterSignal(psychic_overlay, COMSIG_QDELETING, PROC_REF(parent_destroy))

/datum/action/change_psychic_visual/Destroy()
	psychic_overlay = null
	return ..()

/datum/action/change_psychic_visual/proc/parent_destroy()
	SIGNAL_HANDLER

	qdel(src)

/datum/action/change_psychic_visual/on_activate(mob/user, atom/target)
	if(!psychic_overlay)
		psychic_overlay = locate(/atom/movable/screen/fullscreen/blind/psychic_highlight) in owner?.client?.screen
	psychic_overlay?.cycle_visuals()

//Action for toggling auto sense
/datum/action/change_psychic_auto
	name = "Auto Psychic Sense"
	desc = "Change your psychic sense to auto."
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_generic"
	///Ref to the action
	var/datum/action/item_action/organ_action/psychic_highlight/psychic_action

/datum/action/change_psychic_auto/New(Target)
	. = ..()
	psychic_action = Target
	//Bad, but not my job to fix your runtimes
	RegisterSignal(psychic_action, COMSIG_QDELETING, PROC_REF(parent_destroy), override = TRUE)

/datum/action/change_psychic_auto/Destroy()
	psychic_action = null
	return ..()

/datum/action/change_psychic_auto/proc/parent_destroy()
	SIGNAL_HANDLER

	qdel(src)

/datum/action/change_psychic_auto/on_activate(mob/user, atom/target)
	psychic_action?.auto_sense = !psychic_action?.auto_sense
	update_buttons()

/datum/action/change_psychic_auto/is_available()
	. = ..()
	if(psychic_action?.auto_sense)
		return FALSE

//Action for toggling auto sense
/datum/action/change_psychic_texture
	name = "Change Psychic Texture"
	desc = "Change your psychic texture."
	icon_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_texture"
	///Ref to the overlay - hard del edition
	var/atom/movable/screen/fullscreen/blind/psychic_highlight/psychic_overlay
	var/atom/movable/screen/fullscreen/blind/psychic/blind_overlay

/datum/action/change_psychic_texture/New(Target)
	. = ..()
	RegisterSignal(psychic_overlay, COMSIG_QDELETING, PROC_REF(parent_destroy))
	RegisterSignal(blind_overlay, COMSIG_QDELETING, PROC_REF(parent_destroy))


/datum/action/change_psychic_texture/Destroy()
	psychic_overlay = null
	blind_overlay = null
	return ..()

/datum/action/change_psychic_texture/proc/parent_destroy()
	SIGNAL_HANDLER

	qdel(src)

/datum/action/change_psychic_texture/on_activate(mob/user, atom/target)
	psychic_overlay = psychic_overlay || owner?.screens["psychic_highlight"]
	psychic_overlay?.cycle_textures()
	blind_overlay = blind_overlay || owner?.screens["blind"]
	blind_overlay?.cycle_textures()
