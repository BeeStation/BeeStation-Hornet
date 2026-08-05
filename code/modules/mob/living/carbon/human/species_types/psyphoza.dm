/datum/species/psyphoza
	name = "\improper Psyphoza"
	plural_form = "Psyphoza"
	id = SPECIES_PSYPHOZA
	meat = /obj/item/food/meat/slab/human/mutant/psyphoza
	species_traits = list(
		AGENDER,
		MUTANT_COLOR,
	)
	inherent_traits = list(
		TRAIT_PSYCHIC_SENSE,
	)
	sexes = FALSE
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_MAGIC | MIRROR_PRIDE | ERT_SPAWN | RACE_SWAP
	species_language_holder = /datum/language_holder/psyphoza
	exotic_blood = /datum/reagent/drug/mushroomhallucinogen
	allow_numbers_in_name = TRUE
	inert_mutation = /datum/mutation/spores

	mutantbrain = /obj/item/organ/brain/psyphoza
	mutanteyes = /obj/item/organ/eyes/psyphoza
	mutanttongue = /obj/item/organ/tongue/psyphoza

	mutant_bodyparts = list("psyphoza_cap" = "Portobello", "body_size" = "Normal", "mcolor" = COLOR_WHITE)
	hair_color = "fixedmutcolor"

	bodypart_overrides = list(
		BODY_ZONE_HEAD = /obj/item/bodypart/head/psyphoza,
		BODY_ZONE_CHEST = /obj/item/bodypart/chest/psyphoza,
		BODY_ZONE_L_ARM = /obj/item/bodypart/arm/left/psyphoza,
		BODY_ZONE_R_ARM = /obj/item/bodypart/arm/right/psyphoza,
		BODY_ZONE_L_LEG = /obj/item/bodypart/leg/left/psyphoza,
		BODY_ZONE_R_LEG = /obj/item/bodypart/leg/right/psyphoza
	)

	species_height = SPECIES_HEIGHTS(2, 1, 0)

	/// Weakref to the psychic highlight action given by our eyes
	var/datum/weakref/ability_weakref

/datum/species/psyphoza/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	. = ..()
	ability_weakref = WEAKREF(locate(/datum/action/item_action/organ_action/psychic_highlight) in C.actions)

/datum/species/psyphoza/on_species_loss(mob/living/carbon/human/C, datum/species/new_species, pref_load)
	. = ..()
	ability_weakref = null

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
	var/datum/action/item_action/organ_action/psychic_highlight/ability = ability_weakref?.resolve()
	ability?.trigger()

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
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "activate_psychic"
	transparent_when_unavailable = TRUE
	cooldown_time = 1 SECONDS

	/// The distant our psychic sense works
	var/psychic_scale = 2.28
	/// The amount of time you can sense things for
	var/sense_time = 10 SECONDS
	/// The eyes original sight flags - used between toggles
	var/sight_flags
	/// Reference to 'kill these overlays' timer
	var/psychic_timer

	/// Ref to change action
	var/datum/action/change_psychic_visual/overlay_change
	/// Ref to other change action
	var/datum/action/change_psychic_texture/texture_change
	/// Ref to sense auto toggle action
	var/datum/action/change_psychic_auto/auto_action

	/// Do we have auto sense toggled?
	var/auto_sense = FALSE
	/// The timer managing our auto sense
	var/auto_sense_timer

/datum/action/item_action/organ_action/psychic_highlight/Destroy()
	if(auto_sense_timer)
		deltimer(auto_sense_timer)

	if(owner)
		owner.clear_fullscreen("psychic_highlight")
		owner.clear_fullscreen("psychic_highlight_mask")
		owner.clear_fullscreen("psychic_highlight_click_mask")

	if(!QDELETED(overlay_change))
		QDEL_NULL(overlay_change)
	if(!QDELETED(texture_change))
		QDEL_NULL(texture_change)
	if(!QDELETED(auto_action))
		QDEL_NULL(auto_action)
	return ..()

/datum/action/item_action/organ_action/psychic_highlight/Grant(mob/grant_to)
	. = ..()
	// Overlay used to highlight objects
	grant_to.overlay_fullscreen("psychic_highlight", /atom/movable/screen/fullscreen/blind/psychic_highlight)
	grant_to.overlay_fullscreen("psychic_highlight_mask", /atom/movable/screen/fullscreen/blind/psychic/mask)

	var/atom/movable/screen/fullscreen/blind_context_disable/context_blocker = grant_to.overlay_fullscreen("psychic_highlight_click_mask", /atom/movable/screen/fullscreen/blind_context_disable)
	context_blocker.owner = grant_to.client
	context_blocker.mob_owner = grant_to

	// Give the actions that come alongside us
	if(!(locate(/datum/action/change_psychic_visual) in grant_to.actions))
		overlay_change = new(src)
		overlay_change.Grant(grant_to)
	if(!(locate(/datum/action/change_psychic_texture) in grant_to.actions))
		texture_change = new(src)
		texture_change.Grant(grant_to)
	if(!(locate(/datum/action/change_psychic_auto) in grant_to.actions))
		auto_action = new(src)
		auto_action.Grant(grant_to)

/datum/action/item_action/organ_action/psychic_highlight/on_activate(mob/user, atom/target)
	if(!owner || !check_head())
		return

	// Reveal larger area of sense
	dim_overlay()

	// Blind sense stuffs
	var/datum/component/blind_sense/blind_sense = owner.GetComponent(/datum/component/blind_sense)
	if(blind_sense)
		for(var/mob/living/nearby_living in urange(9, owner, TRUE))
			blind_sense.highlight_object(nearby_living, "mob", nearby_living.dir)

	start_cooldown()

/datum/action/item_action/organ_action/psychic_highlight/proc/auto_sense_loop()
	if(!auto_sense)
		return
	trigger()
	auto_sense_timer = addtimer(CALLBACK(src, PROC_REF(auto_sense_loop)), cooldown_time)

//Handle images deleting, stops hardel - also does eyes stuff
/datum/action/item_action/organ_action/psychic_highlight/proc/toggle_eyes_backwards()
	// Timer steps
	if(psychic_timer)
		deltimer(psychic_timer)
		psychic_timer = null

	// Set eyes back to normal
	var/obj/item/organ/eyes/eyes = master
	if(istype(eyes))
		eyes.sight_flags = sight_flags
	owner.update_sight()

//Dims blind overlay - Lightens highlight layer
/datum/action/item_action/organ_action/psychic_highlight/proc/dim_overlay()
	// Blind layer
	var/atom/movable/screen/fullscreen/blind/psychic/P = locate() in owner.client?.screen
	if(P)
		//We change the color instead of alpha, otherwise we'd reveal our actual surroundings!
		animate(P, color = COLOR_BLACK) //This is a fix for a bug with ``animate()`` breaking
		animate(P, color = P.origin_color, time = sense_time, easing = SINE_EASING, flags = EASE_IN)

	// Highlight layer
	var/atom/movable/screen/fullscreen/blind/psychic/mask/B = locate() in owner.client?.screen
	if(B)
		var/matrix/ntransform = matrix(B.transform) //new scale
		ntransform.Scale(psychic_scale)
		var/matrix/otransform = matrix(B.transform) //old scale
		animate(B, transform = ntransform)
		animate(B, transform = otransform, time = sense_time, easing = SINE_EASING, flags = EASE_IN)

	// Setup timer to delete image
	if(psychic_timer)
		deltimer(psychic_timer)
	psychic_timer = addtimer(CALLBACK(src, PROC_REF(toggle_eyes_backwards)), sense_time, TIMER_STOPPABLE)

//Get a list of nearby things & run 'em through a typecache
/datum/action/item_action/organ_action/psychic_highlight/proc/check_head()
	if(istype(owner?.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/helmet))
		to_chat(owner, span_warning("You can't use your senses while wearing helmets!"))
		return FALSE
	return TRUE

//keep this type-
/atom/movable/screen/fullscreen/blind/psychic
	icon_state = "trip"
	icon = 'icons/hud/fullscreen/psychic.dmi'
	///The color we return to after going black & back.
	var/origin_color = "#111"
	///Index for texture setting - Useful if we add more presets
	var/texture_index = 1

/atom/movable/screen/fullscreen/blind/psychic/Initialize(mapload)
	. = ..()
	cycle_textures()

//Copied code, it'll be fine
/atom/movable/screen/fullscreen/blind/psychic/proc/cycle_textures()
	color = origin_color

	//Set animation
	switch(texture_index)
		if(1)
			icon_state = "trip"
		if(2)
			icon_state = "trip_static"
		if(3)
			icon_state = "trip_static_hole"
			color = COLOR_BLACK

	// Wrap index back around
	texture_index++
	if(texture_index >= 4)
		texture_index = 1

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
	var/visual_index = 1
	///Index for texture setting - Useful if we add more presets
	var/texture_index = 1

/atom/movable/screen/fullscreen/blind/psychic_highlight/Initialize(mapload)
	. = ..()
	filters += filter(type = "alpha", render_source = GAME_PLANE_RENDER_TARGET)
	filters += filter(type = "alpha", render_source = ANTI_PSYCHIC_PLANE_RENDER_TARGET, flags = MASK_INVERSE)
	filters += filter(type = "alpha", render_source = "psychic_mask")
	filters += filter(type = "bloom", size = 2, threshold = rgb(85,85,85))
	filters += filter(type = "radial_blur", size = 0.0125)
	INVOKE_ASYNC(src, PROC_REF(cycle_visuals))
	cycle_textures()

/atom/movable/screen/fullscreen/blind/psychic_highlight/proc/cycle_visuals()
	// Reset animations
	animate(src, color = COLOR_WHITE)
	//Set animation
	switch(visual_index)
		if(1) //Rainbow
			color = COLOR_RED // start at red
			animate(src, color = COLOR_YELLOW, time = 1 SECONDS, loop = -1)
			animate(color = COLOR_VIBRANT_LIME, time = 1 SECONDS)
			animate(color = COLOR_CYAN, time = 1 SECONDS)
			animate(color = COLOR_BLUE, time = 1 SECONDS)
			animate(color = COLOR_MAGENTA, time = 1 SECONDS)
			animate(color = COLOR_RED, time = 1 SECONDS)
		if(2) //Custom
			var/new_color = tgui_color_picker(usr, "Pick new color", "Psychic Texture Color", COLOR_WHITE)
			color = new_color

	// Wrap index back around
	visual_index++
	if(visual_index >= 3)
		visual_index = 1

/atom/movable/screen/fullscreen/blind/psychic_highlight/proc/cycle_textures()
	//Set animation
	switch(texture_index)
		if(1)
			icon_state = "trip"
		if(2)
			icon_state = "trip_static"
		if(3)
			icon_state = "trip_static_white"

	// Wrap index back around
	texture_index++
	if(texture_index >= 4)
		texture_index = 1

//Action for changing screen color
/datum/action/change_psychic_visual
	name = "Change Psychic Sense"
	desc = "Change the visual style of your psychic sense."
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_color"
	/// Ref to the overlay - hard del edition
	var/atom/movable/screen/fullscreen/blind/psychic_highlight/psychic_overlay

/datum/action/change_psychic_visual/Destroy()
	if(!isnull(psychic_overlay))
		UnregisterSignal(psychic_overlay, COMSIG_QDELETING)
		psychic_overlay = null
	return ..()

/datum/action/change_psychic_visual/on_activate(mob/user, atom/target)
	if(isnull(psychic_overlay))
		set_psychic_overlay(owner?.screens["psychic_highlight"])
	psychic_overlay?.cycle_visuals()

/datum/action/change_psychic_visual/proc/set_psychic_overlay(atom/movable/screen/fullscreen/blind/psychic_highlight/new_overlay)
	if(!isnull(psychic_overlay))
		UnregisterSignal(psychic_overlay, COMSIG_QDELETING)
	if(!isnull(new_overlay))
		RegisterSignal(psychic_overlay, COMSIG_QDELETING, PROC_REF(overlay_destroyed))
	psychic_overlay = new_overlay

/datum/action/change_psychic_visual/proc/overlay_destroyed(datum/source)
	SIGNAL_HANDLER
	qdel(src)

//Action for toggling auto sense
/datum/action/change_psychic_auto
	name = "Auto Psychic Sense"
	desc = "Change your psychic sense to automatically pulse."
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_generic"

/datum/action/change_psychic_auto/on_activate(mob/user, atom/target, trigger_flags)
	var/datum/action/item_action/organ_action/psychic_highlight/psychic_action = master
	if(istype(psychic_action))
		psychic_action.auto_sense = !psychic_action.auto_sense
		psychic_action.auto_sense_loop()

//Action for toggling auto sense
/datum/action/change_psychic_texture
	name = "Change Psychic Texture"
	desc = "Change your psychic texture."
	button_icon = 'icons/hud/actions/action_generic.dmi'
	button_icon_state = "change_texture"
	/// Refs to the overlays - hard del edition
	var/atom/movable/screen/fullscreen/blind/psychic_highlight/psychic_overlay
	var/atom/movable/screen/fullscreen/blind/psychic/blind_overlay

/datum/action/change_psychic_texture/Destroy()
	if(!isnull(psychic_overlay))
		UnregisterSignal(psychic_overlay, COMSIG_QDELETING)
		psychic_overlay = null
	if(!isnull(blind_overlay))
		UnregisterSignal(blind_overlay, COMSIG_QDELETING)
		blind_overlay = null
	return ..()

/datum/action/change_psychic_texture/on_activate(mob/user, atom/target)
	if(isnull(psychic_overlay))
		set_psychic_overlay(owner?.screens["psychic_highlight"])
	if(isnull(blind_overlay)) // The blind overlay given by our eyes
		set_blind_overlay(owner?.screens["blind"])

	psychic_overlay?.cycle_textures()
	blind_overlay?.cycle_textures()

/datum/action/change_psychic_texture/proc/set_psychic_overlay(atom/movable/screen/fullscreen/blind/psychic_highlight/new_overlay)
	if(!isnull(psychic_overlay))
		UnregisterSignal(psychic_overlay, COMSIG_QDELETING)
	if(!isnull(new_overlay))
		RegisterSignal(psychic_overlay, COMSIG_QDELETING, PROC_REF(overlay_destroyed))
	psychic_overlay = new_overlay

/datum/action/change_psychic_texture/proc/set_blind_overlay(atom/movable/screen/fullscreen/blind/psychic_highlight/new_overlay)
	if(!isnull(blind_overlay))
		UnregisterSignal(blind_overlay, COMSIG_QDELETING)
	if(!isnull(new_overlay))
		RegisterSignal(blind_overlay, COMSIG_QDELETING, PROC_REF(overlay_destroyed))
	blind_overlay = new_overlay

/datum/action/change_psychic_texture/proc/overlay_destroyed(datum/source)
	SIGNAL_HANDLER
	qdel(src)

