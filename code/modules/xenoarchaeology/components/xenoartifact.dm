/*
	Items with this component will act like alien artifatcs
*/

//Item presets for generic shit
/obj/item/xenoartifact
	name = "artifact"
	icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	icon_state = "map_editor"
	w_class = WEIGHT_CLASS_NORMAL
	desc = "A strange alien artifact. What could it possibly do?"
	throw_range = 3
	///What type of artifact
	var/datum/xenoartifact_material/artifact_type
	///Use this for debugging or admin shit
	var/spawn_with_traits = TRUE

/obj/item/xenoartifact/Initialize(mapload, _artifact_type)
	. = ..()
	artifact_type = _artifact_type || artifact_type

/obj/item/xenoartifact/ComponentInitialize()
	. = ..()
	if(spawn_with_traits)
		AddComponent(/datum/component/xenoartifact, artifact_type)

//Maint variant for loot, has a 80% chance of being safe, 20% of not
/obj/item/xenoartifact/maint/ComponentInitialize()
	artifact_type = prob(80) ? /datum/xenoartifact_material/bluespace : null
	return ..()

//Objective variant, simply has the objective trait
/obj/item/xenoartifact/objective/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/tracking_beacon, EXPLORATION_TRACKING, null, null, TRUE, "#eb4d4d", TRUE, TRUE)
	var/datum/component/xenoartifact/X = GetComponent(/datum/component/xenoartifact)
	X?.add_individual_trait(/datum/xenoartifact_trait/misc/objective)

/obj/item/xenoartifact/no_traits
	spawn_with_traits = FALSE

/datum/component/xenoartifact
	///List of artifact-traits we have : list(PRIORITY = list(trait))
	var/list/artifact_traits = list()
	///Blacklist of components this artifact is currently incompatible with
	var/list/blacklisted_traits = list()

	///What strenght are our traits operating at?
	var/trait_strength = XENOA_TRAIT_STRENGTH_STRONG

	///Level of instability, associated with gaining malfunctions
	var/instability = 0

	///What type of artifact are we?
	var/datum/xenoartifact_material/artifact_type

	///Cooldown logic for uses
	var/use_cooldown = XENOA_GENERIC_COOLDOWN
	var/use_cooldown_timer
	///Extra cooldown from traits - update this with get_extra_cooldowns() when you add traits
	var/trait_cooldown = 0 SECONDS
	///Cooldown override. If this is true, we're on cooldown
	var/cooldown_override = FALSE
	///Is cooldown disabled
	var/cooldown_disabled = FALSE

	///List of targets we can pass to our traits
	var/list/targets = list()
	///Maximum range we can register targets from
	var/target_range = 1

	///Description for the material, based on the traits - Update this with get_material_desc() when you add traits
	var/material_description = ""

	///What the old appearance of the parent was, for resetting their appearance
	var/mutable_appearance/old_appearance
	var/old_name
	///Do we edit the parent's texture?
	var/do_texture = TRUE
	///Do we edit the parent's silhouette?
	var/do_mask = TRUE

	///Do we make pearls when we're destroyed?
	var/make_pearls = TRUE //TODO: Remeber to disable this when you're done testing - Racc

/datum/component/xenoartifact/Initialize(type, list/traits, _do_appearance = TRUE, _do_mask = TRUE)
	. = ..()
	generate_xenoa_statics()
	var/atom/A = parent

	//Setup our typing
	artifact_type = type || pick_weight(GLOB.xenoartifact_material_weights)
	artifact_type = new artifact_type()
	A.custom_price = A.custom_price || artifact_type.custom_price

	//Build appearance from material
	old_appearance = A.appearance
	old_name = A.name
	do_texture = _do_appearance
	do_mask = _do_mask
	build_material_appearance()

	//Build priotity list
	for(var/i in GLOB.xenoartifact_trait_priorities)
		artifact_traits[i] = list()

	//If we're force-generating traits
	if(traits)
		for(var/datum/xenoartifact_trait/T as() in traits)
			add_individual_trait(T)

	//Otherwise, randomly generate our own traits
	else
		var/list/focus_traits
		//Generate activators
		focus_traits = GLOB.xenoa_activators & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_activators)

		//Generate minors
		focus_traits = GLOB.xenoa_minors & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_minors)

		//Generate majors
		focus_traits = GLOB.xenoa_majors & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_majors)

		//Generate malfunctions
		focus_traits = GLOB.xenoa_malfunctions & artifact_type.get_trait_list()
		build_traits(focus_traits, artifact_type.trait_malfunctions)
	//Cooldown
	trait_cooldown = get_extra_cooldowns()
	//Description
	material_description = get_material_desc()
	//Setup description stuff
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))

/datum/component/xenoartifact/Destroy(force, silent)
	if(!QDELETED(parent))
		//Reset parent's visuals
		var/atom/A = parent
		A.remove_filter("texture_overlay")
		A.remove_filter("outline_1")
		A.remove_filter("outline_2")
		//TODO: make sure this doesn't cause issues - Racc
		A.appearance = old_appearance
		A.name = old_name
		old_appearance = null
	//Delete and/or 'pearl' our traits
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			artifact_traits[i] -= T
			if(make_pearls)
				new /obj/item/trait_pearl(get_turf(parent), T.type)
			if(!QDELETED(T))
				qdel(T)
	return ..()

///Used to trigger all our traits in order
/datum/component/xenoartifact/proc/trigger(force)
	//Timer logic
	if((use_cooldown_timer || cooldown_override) && !force)
		return
	else if(use_cooldown_timer)
		reset_timer(use_cooldown_timer)
	//Trait triggers
	for(var/i in GLOB.xenoartifact_trait_priorities)
		SEND_SIGNAL(src, XENOA_TRIGGER, i)
	//Malfunctions
	handle_malfunctions()
	//Cleanup targets
	for(var/atom/A in targets)
		unregister_target(A)
	//Timer setup
	if(!cooldown_disabled)
		use_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), max(0, use_cooldown + trait_cooldown), TIMER_STOPPABLE)

/datum/component/xenoartifact/proc/build_traits(list/trait_list, amount)
	var/list/options = trait_list
	options -= blacklisted_traits
	for(var/i in 1 to amount)
		//Pick a random trait
		var/datum/xenoartifact_trait/T = pick_weight(options)
		add_individual_trait(T)
		options -= blacklisted_traits

//Cooldown finish logic goes here
/datum/component/xenoartifact/proc/reset_timer()
	if(use_cooldown_timer)
		deltimer(use_cooldown_timer)
	use_cooldown_timer = null //Just incase

/datum/component/xenoartifact/proc/get_extra_cooldowns()
	var/time = 0 SECONDS
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			time += T.cooldown
	return time

/datum/component/xenoartifact/proc/handle_malfunctions(itterate = TRUE)
	if(!prob(instability))
		if(itterate)
			instability += artifact_type.instability_step
		return
	var/list/focus_traits
	focus_traits = GLOB.xenoa_malfunctions & artifact_type.get_trait_list()
	build_traits(focus_traits, artifact_type.trait_malfunctions)

/datum/component/xenoartifact/proc/register_target(atom/target, force)
	//Don't register new targets unless the cooldown is finished
	if(use_cooldown_timer && !force)
		return
	//Range check
	if(get_dist(get_turf(parent), get_turf(target))> target_range && !force)
		return
	//Anti-artifact check
	var/mob/M = target
	if(M.anti_artifact_check())
		return
	targets += target
	RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(unregister_target), TRUE)

/datum/component/xenoartifact/proc/unregister_target(datum/source)
	SIGNAL_HANDLER

	targets -= source
	UnregisterSignal(source, COMSIG_PARENT_QDELETING)

/datum/component/xenoartifact/proc/on_examined(datum/source, mob/user, list/examine_text)
	SIGNAL_HANDLER

	var/mob/living/carbon/M = user
	if(iscarbon(user) && M.can_see_reagents() || isobserver(user))
		examine_text += "<span class='notice'>[parent] seems to be made from a [material_description]material.</span>"
	//Special case for observers that shows all the traits
	if(isobserver(user))
		for(var/i in artifact_traits)
			for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
				if(T.label_name)
					examine_text += "<span class='info'>- [T.label_name]</span>"
	return

//Build the description for the scientific examination
/datum/component/xenoartifact/proc/get_material_desc()
	var/temp = ""
	var/list/description_category = list()
	//Get descriptions from each category
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			if(!description_category[i])
				description_category[i] = list()
			if(T.material_desc) //Avoid adding null, so later logic works
				description_category[i] += initial(T.material_desc)
	//Pick one from each category to build an entire description
	var/unknown_used = FALSE
	for(var/i in description_category)
		//Descriptor
		if(length(description_category[i]))
			temp = "[temp][pick(description_category[i])] "
		else if(!unknown_used)
			temp = "unknown [temp]"
			unknown_used = TRUE
	return temp

/datum/component/xenoartifact/proc/get_material_weight()
	var/total_weight = 0
	//Get descriptions from each category
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			total_weight += T.weight
	return total_weight

/datum/component/xenoartifact/proc/get_material_conductivity()
	var/total_conductivity = 0
	//Get descriptions from each category
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			total_conductivity += T.conductivity
	return total_conductivity

/datum/component/xenoartifact/proc/add_individual_trait(datum/xenoartifact_trait/trait, force = TRUE)
	//Is this trait in the blacklist?
	if((locate(trait) in blacklisted_traits) && !force)
		return FALSE
	//We can either pass paths, or initialized traits
	if(ispath(trait))
		trait = new trait(src)
	else
		trait.remove_parent()
		trait.register_parent(src)
	//TODO: Setup a proc for traits to register a new parent - Racc
	//List building, handle custom priorities, just appened to the end
	if(!artifact_traits[trait.priority])
		artifact_traits[trait.priority] = list()
	//handle adding trait
	artifact_traits[trait.priority] += trait
	blacklisted_traits += trait.blacklist_traits
	blacklisted_traits += trait

	return TRUE

//Calcifies, aka breaks, the artifact
/datum/component/xenoartifact/proc/calcify(override_cooldown = TRUE)
	//Appearnce
	artifact_type = new /datum/xenoartifact_material/calcified()
	var/old_mask = do_mask
	do_mask = FALSE
	build_material_appearance()
	do_mask = old_mask
	//Disable artifact
	cooldown_override = TRUE


//Calibrates. Does the opposite of calcify
/datum/component/xenoartifact/proc/calibrate()
	var/atom/A = parent
	//Stats
	artifact_type.instability_step = 0
	//Effect
	var/mutable_appearance/MA = mutable_appearance('icons/obj/xenoarchaeology/xenoartifact.dmi', "calibrated")
	MA.blend_mode = BLEND_ADD
	MA.color = artifact_type.material_color
	A.add_overlay(MA)

//Build the artifact's appearance
/datum/component/xenoartifact/proc/build_material_appearance()
	var/atom/A = parent
	//Remove old filters, if they exist
	A.remove_filter("texture_overlay")
	A.remove_filter("outline_1")
	A.remove_filter("outline_2")
	//Apply new stuff
	if(do_mask)
		//Build the silhouette of the artifact
		var/mutable_appearance/MA = artifact_type.get_mask()
		MA.plane = A.plane //This is important lol
		MA.layer = A.layer
		A.appearance = MA
		//Reset name
		var/old_desc = A.desc
		A.name = "[artifact_type.name] [old_name]"
		A.desc = old_desc //Appearance resets this shit
	if(do_texture)
		//Overlay the material texture
		var/icon/I = artifact_type.get_texture()
		A.add_filter("texture_overlay", 1, layering_filter(icon = I, blend_mode = BLEND_INSET_OVERLAY))
		//Throw on some outlines
		A.add_filter("outline_1", 2, outline_filter(2, "#000"))
		A.add_filter("outline_2", 3, outline_filter(1, artifact_type.material_color))

/*
	material datums
*/

/datum/xenoartifact_material
	var/name = "debugium"
	///What color we associate with this material
	var/material_color = "#ff4800"

	///Trait info, how many of each trait are we allowed
	var/trait_activators = 1
	var/trait_minors = 3
	var/trait_majors = 1
	var/trait_malfunctions = 0

	///How much we increase artifact instability by for every use
	var/instability_step = 0

	///Custom price we use if the item doesn't have its own
	var/custom_price = 100

	///Artifact textures
	var/texture_icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	var/list/texture_icon_states = list("texture-debug1", "texture-debug2", "texture-debug3")
	///Artifact masks
	var/mask_icon = 'icons/obj/xenoarchaeology/xenoartifact.dmi'
	var/list/mask_icon_states = list("map_editor")

//Set this proc to return a pre-made list so we can avoid some overhead
/datum/xenoartifact_material/proc/get_trait_list()
	return GLOB.xenoa_all_traits

/datum/xenoartifact_material/proc/get_texture()
	return icon(texture_icon, pick(texture_icon_states))

/datum/xenoartifact_material/proc/get_mask()
	return mutable_appearance(mask_icon, pick(mask_icon_states))

/datum/xenoartifact_material/bananium
	name = "bananium"
	material_color = "#f2ff00"
	instability_step = 0.5
	texture_icon_states = list("texture-bananium1", "texture-bananium2", "texture-bananium3")
	mask_icon_states = list("mask-bananium1")

/datum/xenoartifact_material/bananium/get_trait_list()
	return GLOB.xenoa_bananium_traits

/datum/xenoartifact_material/uranium
	name = "uranium"
	material_color = "#88ff00ff"
	instability_step = 25
	texture_icon_states = list("texture-uranium1", "texture-uranium2", "texture-uranium3")
	mask_icon_states = list("mask-uranium1")

/datum/xenoartifact_material/uranium/get_trait_list()
	return GLOB.xenoa_uranium_traits

/datum/xenoartifact_material/plasma
	name = "plasma"
	material_color = "#f200ffff"
	instability_step = 5
	texture_icon_states = list("texture-plasma1", "texture-plasma2", "texture-plasma3")
	mask_icon_states = list("mask-plasma1")

/datum/xenoartifact_material/plasma/get_trait_list()
	return GLOB.xenoa_plasma_traits

/datum/xenoartifact_material/bluespace
	name = "bluespace"
	material_color = "#006affff"
	instability_step = 1
	texture_icon_states = list("texture-bluespace1", "texture-bluespace2", "texture-bluespace3")
	mask_icon_states = list("mask-bluespace1")

/datum/xenoartifact_material/bluespace/get_trait_list()
	return GLOB.xenoa_bluespace_traits

//Artificial
/datum/xenoartifact_material/pearl
	name = "pearl"
	material_color = "#f1ffca"
	instability_step = 50
	texture_icon_states = list("texture-pearl1", "texture-pearl2", "texture-pearl3")
	mask_icon_states = list("mask-pearl1") //This is pretty much a place holder, since artificial artifacts use the item as a mask

//Calcified
/datum/xenoartifact_material/calcified
	name = "calcified"
	material_color = "#726387"
	texture_icon_states = list("texture-calcified1", "texture-calcified2", "texture-calcified3")
