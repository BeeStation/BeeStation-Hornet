/*
	Artifact component
*/

/datum/component/xenoartifact
	///List of artifact-traits we have : list(PRIORITY = list(trait))
	var/list/traits_catagories = list()
	///Blacklist of components this artifact is currently incompatible with
	var/list/blacklisted_traits = list()

	///What strenght are our traits operating at?
	var/trait_strength = XENOA_TRAIT_STRENGTH_STRONG

	///Level of instability, associated with gaining malfunctions
	var/instability = 0

	///What type of artifact are we?
	var/datum/xenoartifact_material/artifact_material

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

	///Do we play a sound? - This is mostly here for admins to disable when they're doing gimmicks
	var/play_hint_sound = TRUE

	///States
	var/calcified = FALSE
	var/calibrated = FALSE
	var/atom/movable/artifact_particle_holder/calibrated_holder

/datum/component/xenoartifact/Initialize(material_type, list/traits, _do_appearance = TRUE, _do_mask = TRUE, patch_traits = TRUE)
	. = ..()
	var/atom/atom_parent = parent

	//Add discovery component
	atom_parent.AddComponent(/datum/component/discoverable/artifact)

	//Setup our typing
	artifact_material = material_type || pick_weight(SSxenoarchaeology.xenoartifact_material_weights)
	artifact_material = new artifact_material()
	atom_parent.custom_price = atom_parent.custom_price || artifact_material.custom_price

	//Build appearance from material
	old_appearance = atom_parent.appearance
	old_name = atom_parent.name
	do_texture = _do_appearance
	do_mask = _do_mask
	build_material_appearance()

	//Populate priotity list
	for(var/each_category  in SSxenoarchaeology.xenoartifact_trait_category_priorities)
		traits_catagories[each_category ] = list()

	//If we're force-generating traits
	if(traits)
		for(var/datum/xenoartifact_trait/T as() in traits)
			add_individual_trait(T)

	//Otherwise, randomly generate our own traits - Additional option to patch traits missing from trait list
	if(!length(traits) || patch_traits)
		var/list/focus_traits
		if(length(traits_catagories[TRAIT_PRIORITY_ACTIVATOR]) < artifact_material.trait_activators)
			//Generate activators
			focus_traits = artifact_material.get_activators()
			build_traits(focus_traits, artifact_material.trait_activators - length(traits_catagories[TRAIT_PRIORITY_ACTIVATOR]))
		if(length(traits_catagories[TRAIT_PRIORITY_MINOR]) < artifact_material.trait_minors)
			//Generate minors
			focus_traits = artifact_material.get_minors()
			build_traits(focus_traits, artifact_material.trait_minors - length(traits_catagories[TRAIT_PRIORITY_MINOR]))
		if(length(traits_catagories[TRAIT_PRIORITY_MAJOR]) < artifact_material.trait_majors)
			//Generate majors
			focus_traits = artifact_material.get_majors()
			build_traits(focus_traits, artifact_material.trait_majors - length(traits_catagories[TRAIT_PRIORITY_MAJOR]))
		if(length(traits_catagories[TRAIT_PRIORITY_MALFUNCTION]) < artifact_material.trait_malfunctions)
			//Generate malfunctions
			focus_traits = artifact_material.get_malfunctions()
			build_traits(focus_traits, artifact_material.trait_malfunctions - length(traits_catagories[TRAIT_PRIORITY_MALFUNCTION]))
	//Cooldown
	trait_cooldown = get_extra_cooldowns()
	//Description
	material_description = get_material_desc()
	//Setup description stuff
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))

/datum/component/xenoartifact/Destroy(force, silent)
	if(!QDELETED(parent))
		var/atom/atom_parent = parent
		//Remove discovery component
		var/datum/component/discoverable/artifact/X = atom_parent.GetComponent(/datum/component/discoverable/artifact)
		qdel(X)
		//Reset parent's visuals
		atom_parent.remove_filter("texture_overlay")
		atom_parent.remove_filter("outline_1")
		atom_parent.remove_filter("outline_2")
		atom_parent.appearance = old_appearance
		atom_parent.name = old_name
		old_appearance = null
	//Delete our traits
	for(var/i in traits_catagories)
		for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
			traits_catagories[i] -= T
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
	//Sound hint
	if(play_hint_sound)
		playsound(get_turf(parent), 'sound/magic/blink.ogg', 50, TRUE)
	//Trait triggers
	for(var/i in SSxenoarchaeology.xenoartifact_trait_category_priorities)
		SEND_SIGNAL(src, COMSIG_XENOA_TRIGGER, i)
	//Malfunctions
	if(!calibrated)
		handle_malfunctions()
	//Cleanup targets
	for(var/atom/target in targets)
		unregister_target(target)
	//Timer setup
	if(!cooldown_disabled)
		use_cooldown_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), max(0, use_cooldown + trait_cooldown), TIMER_STOPPABLE)

/datum/component/xenoartifact/proc/build_traits(list/trait_list, amount, incompatabilities = TRUE)
	var/list/options = trait_list.Copy()
	//Remove any blacklisted traits
	options -= blacklisted_traits
	//Remove any incompatible traits
	if(incompatabilities)
		options -= SSxenoarchaeology.get_trait_incompatibilities(parent)
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
	for(var/i in traits_catagories)
		for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
			time += T.cooldown
	return time

/datum/component/xenoartifact/proc/handle_malfunctions(itterate = TRUE)
	//Instability rolls
	if(!prob(instability))
		if(itterate)
			instability += artifact_material.instability_step
		return
	//Max malfunction checks, against our material
	if(length(traits_catagories[TRAIT_PRIORITY_MALFUNCTION]) >= artifact_material.max_trait_malfunctions)
		return
	//Hint sound
	var/atom/atom_parent = parent
	playsound(atom_parent, 'sound/effects/light_flicker.ogg', 60)
	atom_parent.visible_message("<span class='warning'>[atom_parent] makes a concerning sound, as if something has gone terribly wrong...</span>")
	//Build malfunctions
	var/list/focus_traits
	focus_traits = artifact_material.get_malfunctions()
	build_traits(focus_traits, 1)
	//Reset instability
	instability = 0

/datum/component/xenoartifact/proc/register_target(atom/target, force, type = XENOA_ACTIVATION_CONTACT)
	//Don't register new targets unless the cooldown is finished
	if((use_cooldown_timer || cooldown_override) && !force)
		return
	//Range check
	if(get_dist(get_turf(parent), get_turf(target))> target_range && !force)
		return
	//Anti-artifact check
	if(anti_check(target, type) && !force)
		return
	//Prexisting check
	if((target in targets) && !force)
		return
	//Mob check, so we don't tag ghosts or camera
	if((iscameramob(target) || isobserver(target)) && !force)
		return
	//Regular target follow through
	create_beam(target)
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
		for(var/i in traits_catagories)
			for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
				if(T.label_name)
					examine_text += "<span class='info'>- [T.label_name]</span>"

//Build the description for the scientific examination
/datum/component/xenoartifact/proc/get_material_desc()
	var/temp = ""
	var/list/description_category = list()
	//Get descriptions from each category
	for(var/i in traits_catagories)
		for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
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
	for(var/i in traits_catagories)
		for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
			total_weight += T.weight
	return total_weight

/datum/component/xenoartifact/proc/get_material_conductivity()
	var/total_conductivity = 0
	//Get descriptions from each category
	for(var/i in traits_catagories)
		for(var/datum/xenoartifact_trait/T as() in traits_catagories[i])
			total_conductivity += T.conductivity
	return total_conductivity

/datum/component/xenoartifact/proc/add_individual_trait(datum/xenoartifact_trait/trait, force = TRUE)
	//Is this trait in the blacklist?
	if((locate(trait) in blacklisted_traits) && !force)
		return FALSE
	//Double check our material restrictions
	var/list/trait_type = list(/datum/xenoartifact_trait/activator, /datum/xenoartifact_trait/minor, /datum/xenoartifact_trait/major, /datum/xenoartifact_trait/malfunction)
	for(var/datum/xenoartifact_trait/i in trait_type)
		if(istype(trait, i) && length(traits_catagories[initial(i.priority)]) >= artifact_material)
			return FALSE
	//We can either pass paths, or initialized traits
	if(ispath(trait))
		trait = new trait(src)
	else
		trait.remove_parent(pensive = FALSE)
		trait.register_parent(src)
	//List building, handle custom priorities, just appened to the end
	if(!traits_catagories[trait.priority])
		traits_catagories[trait.priority] = list()
	//handle adding trait
	traits_catagories[trait.priority] += trait
	blacklisted_traits += trait.blacklist_traits
	blacklisted_traits += trait.type
	//Ant-hardel stuff
	RegisterSignal(trait, COMSIG_PARENT_QDELETING, PROC_REF(handle_trait))

	return TRUE

//Calcifies, aka breaks, the artifact
/datum/component/xenoartifact/proc/calcify(override_cooldown = TRUE)
	var/atom/movable/atom_parent = parent
	//Appearnce
	artifact_material = new /datum/xenoartifact_material/calcified()
	var/old_mask = do_mask
	do_mask = FALSE
	if(do_texture)
		build_material_appearance()
	do_mask = old_mask
	//States
	calcified = TRUE
	atom_parent.custom_price /= 2
	//Disable artifact
	cooldown_override = TRUE

	SEND_SIGNAL(src, COMSIG_XENOA_CALCIFIED)

//Calibrates. Does the opposite of calcify
/datum/component/xenoartifact/proc/calibrate()
	var/atom/movable/atom_parent = parent
	//Stats
	calibrated = TRUE
	atom_parent.custom_price *= 2
	//Effect
	calibrated_holder = new(atom_parent)
	var/obj/emitter/spiral/S = calibrated_holder.add_emitter(/obj/emitter/spiral, "calibration", 11)
	S.setup(artifact_material.material_color)
	atom_parent.vis_contents += calibrated_holder

//Build the artifact's appearance
/datum/component/xenoartifact/proc/build_material_appearance()
	var/atom/atom_parent = parent
	//Remove old filters, if they exist
	atom_parent.remove_filter("texture_overlay")
	atom_parent.remove_filter("outline_fix")
	atom_parent.remove_filter("outline_1")
	atom_parent.remove_filter("outline_2")
	//Apply new stuff
	if(do_mask)
		var/old_desc = atom_parent.desc
		//Build the silhouette of the artifact
		var/mutable_appearance/MA = artifact_material.get_mask()
		MA.plane = atom_parent.plane //This is important lol
		MA.layer = atom_parent.layer
		atom_parent.appearance = MA
		//Rset name & desc
		atom_parent.name = "[artifact_material.name] [old_name]"
		atom_parent.desc = old_desc //Appearance resets this shit
	if(do_texture)
		//Overlay the material texture
		var/icon/I = artifact_material.get_texture()
		atom_parent.add_filter("texture_overlay", 1, layering_filter(icon = I, blend_mode = BLEND_INSET_OVERLAY))
		//Throw on some outlines
		//TODO: Check if this fix is still needed in 515 - Racc from 514 : PLAYTEST
		atom_parent.add_filter("outline_fix", 2, outline_filter(0)) //This fixes a weird byond thing. BLEND_INSET_OVERLAY will encrouch on outline 1 if we dont do this
		atom_parent.add_filter("outline_1", 3, outline_filter(1, "#000", flags = OUTLINE_SHARP))
		atom_parent.add_filter("outline_2", 4, outline_filter(1, artifact_material.material_color, flags = OUTLINE_SHARP))

///Create a hint beam from the artifact to the target
/datum/component/xenoartifact/proc/create_beam(atom/movable/target)
	if(!get_turf(target) || locate(parent) in target.contents)
		return
	var/atom/atom_parent = parent
	var/datum/beam/xenoa_beam/B = new((!isturf(atom_parent.loc) ? atom_parent.loc : atom_parent), (!isturf(target.loc) ? target.loc : target), time=1.5 SECONDS, beam_color = artifact_material.material_color, icon='icons/obj/xenoarchaeology/xenoartifact.dmi', icon_state="xenoa_beam", beam_type=/obj/effect/ebeam/xenoa_ebeam)
	INVOKE_ASYNC(B, TYPE_PROC_REF(/datum/beam, Start))

/datum/component/xenoartifact/proc/anti_check(atom/target, activation_type = XENOA_ACTIVATION_CONTACT)
	if(!isatom(target))
		return
	var/mob/M = target
	var/slot = ~ITEM_SLOT_GLOVES
	//Throw you custom clothing block logic here
	switch(activation_type)
		if(XENOA_ACTIVATION_TOUCH)
			slot = ITEM_SLOT_GLOVES
	if(isliving(M) && M.anti_artifact_check(FALSE, slot))
		return TRUE
	//Just check if the thing itself has the anti-component
	var/datum/component/anti_artifact/anti_component = target.GetComponent(/datum/component/anti_artifact)
	if(anti_component?.charges && prob(anti_component.chance))
		anti_component.charges -= 1
		return TRUE
	return FALSE

/datum/component/xenoartifact/proc/handle_trait(datum/source)
	SIGNAL_HANDLER

	var/datum/xenoartifact_trait/T = source
	traits_catagories[T.priority] -= T

/datum/component/xenoartifact/proc/remove_individual_trait(datum/xenoartifact_trait/trait, destroy = FALSE)
	traits_catagories[trait.priority] -= trait
	UnregisterSignal(trait, COMSIG_PARENT_QDELETING)
	if(destroy)
		qdel(trait)

/*
	Artifact beam subtype
*/

/obj/effect/ebeam/xenoa_ebeam
	name = "artifact beam"

/datum/beam/xenoa_beam/redrawing(atom/movable/mover, atom/oldloc, direction)
	//Add a custom check to stop the beam shooting off into infinity, artifact traits fuck with default beam stuff
	if(!isturf(target?.loc) || oldloc?.z != target?.z)
		target = get_turf(oldloc)
	if(!target)
		qdel(src)
	return ..()
