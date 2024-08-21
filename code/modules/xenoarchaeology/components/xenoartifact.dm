/*
	Artifact component
*/

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

	///Do we play a sound? - This is mostly here for admins to disable when they're doing gimmicks
	var/play_hint_sound = TRUE

	///States
	var/calcified = FALSE
	var/calibrated = FALSE
	var/atom/movable/artifact_particle_holder/calibrated_holder

/datum/component/xenoartifact/Initialize(type, list/traits, _do_appearance = TRUE, _do_mask = TRUE, patch_traits = TRUE)
	. = ..()
	var/atom/A = parent

	//Add discovery component
	A.AddComponent(/datum/component/discoverable/artifact)

	//Setup our typing
	artifact_type = type || pick_weight(SSxenoarchaeology.xenoartifact_material_weights)
	artifact_type = new artifact_type()
	A.custom_price = A.custom_price || artifact_type.custom_price

	//Build appearance from material
	old_appearance = A.appearance
	old_name = A.name
	do_texture = _do_appearance
	do_mask = _do_mask
	build_material_appearance()

	//Populate priotity list
	for(var/i in SSxenoarchaeology.xenoartifact_trait_priorities)
		artifact_traits[i] = list()

	//If we're force-generating traits
	if(traits)
		for(var/datum/xenoartifact_trait/T as() in traits)
			add_individual_trait(T)

	//Otherwise, randomly generate our own traits - Additional option to patch traits missing from trait list
	if(!length(traits) || patch_traits)
		var/list/focus_traits
		if(length(artifact_traits[TRAIT_PRIORITY_ACTIVATOR]) < artifact_type.trait_activators)
			//Generate activators
			focus_traits = artifact_type.get_activators()
			build_traits(focus_traits, artifact_type.trait_activators - length(artifact_traits[TRAIT_PRIORITY_ACTIVATOR]))
		if(length(artifact_traits[TRAIT_PRIORITY_MINOR]) < artifact_type.trait_minors)
			//Generate minors
			focus_traits = artifact_type.get_minors()
			build_traits(focus_traits, artifact_type.trait_minors - length(artifact_traits[TRAIT_PRIORITY_MINOR]))
		if(length(artifact_traits[TRAIT_PRIORITY_MAJOR]) < artifact_type.trait_majors)
			//Generate majors
			focus_traits = artifact_type.get_majors()
			build_traits(focus_traits, artifact_type.trait_majors - length(artifact_traits[TRAIT_PRIORITY_MAJOR]))
		if(length(artifact_traits[TRAIT_PRIORITY_MALFUNCTION]) < artifact_type.trait_malfunctions)
			//Generate malfunctions
			focus_traits = artifact_type.get_malfunctions()
			build_traits(focus_traits, artifact_type.trait_malfunctions - length(artifact_traits[TRAIT_PRIORITY_MALFUNCTION]))
	//Cooldown
	trait_cooldown = get_extra_cooldowns()
	//Description
	material_description = get_material_desc()
	//Setup description stuff
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examined))

/datum/component/xenoartifact/Destroy(force, silent)
	if(!QDELETED(parent))
		var/atom/A = parent
		//Remove discovery component
		var/datum/component/discoverable/artifact/X = A.GetComponent(/datum/component/discoverable/artifact)
		X.RemoveComponent()
		//Reset parent's visuals
		A.remove_filter("texture_overlay")
		A.remove_filter("outline_1")
		A.remove_filter("outline_2")
		A.appearance = old_appearance
		A.name = old_name
		old_appearance = null
	//Delete our traits
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			artifact_traits[i] -= T
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
	for(var/i in SSxenoarchaeology.xenoartifact_trait_priorities)
		SEND_SIGNAL(src, XENOA_TRIGGER, i)
	//Malfunctions
	if(!calibrated)
		handle_malfunctions()
	//Cleanup targets
	for(var/atom/A in targets)
		unregister_target(A)
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
	for(var/i in artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
			time += T.cooldown
	return time

/datum/component/xenoartifact/proc/handle_malfunctions(itterate = TRUE)
	//Instability rolls
	if(!prob(instability))
		if(itterate)
			instability += artifact_type.instability_step
		return
	//Max malfunction checks, against our material
	if(length(artifact_traits[TRAIT_PRIORITY_MALFUNCTION]) >= artifact_type.max_trait_malfunctions)
		return
	//Hint sound
	var/atom/A = parent
	playsound(A, 'sound/effects/light_flicker.ogg', 60)
	A.visible_message("<span class='warning'>[A] makes a concerning sound, as if something has gone terribly wrong...</span>")
	//Build malfunctions
	var/list/focus_traits
	focus_traits = artifact_type.get_malfunctions()
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
		for(var/i in artifact_traits)
			for(var/datum/xenoartifact_trait/T as() in artifact_traits[i])
				if(T.label_name)
					examine_text += "<span class='info'>- [T.label_name]</span>"

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
	//Double check our material restrictions
	var/list/trait_type = list(/datum/xenoartifact_trait/activator, /datum/xenoartifact_trait/minor, /datum/xenoartifact_trait/major, /datum/xenoartifact_trait/malfunction)
	for(var/datum/xenoartifact_trait/i in trait_type)
		if(istype(trait, i) && length(artifact_traits[initial(i.priority)]) >= artifact_type)
			return FALSE
	//We can either pass paths, or initialized traits
	if(ispath(trait))
		trait = new trait(src)
	else
		trait.remove_parent()
		trait.register_parent(src)
	//List building, handle custom priorities, just appened to the end
	if(!artifact_traits[trait.priority])
		artifact_traits[trait.priority] = list()
	//handle adding trait
	artifact_traits[trait.priority] += trait
	blacklisted_traits += trait.blacklist_traits
	blacklisted_traits += trait.type
	//Ant-hardel stuff
	RegisterSignal(trait, COMSIG_PARENT_QDELETING, PROC_REF(handle_trait))

	return TRUE

//Calcifies, aka breaks, the artifact
/datum/component/xenoartifact/proc/calcify(override_cooldown = TRUE)
	var/atom/movable/A = parent
	//Appearnce
	artifact_type = new /datum/xenoartifact_material/calcified()
	var/old_mask = do_mask
	do_mask = FALSE
	if(do_texture)
		build_material_appearance()
	do_mask = old_mask
	//States
	calcified = TRUE
	A.custom_price /= 2
	//Disable artifact
	cooldown_override = TRUE

	SEND_SIGNAL(src, XENOA_CALCIFIED)

//Calibrates. Does the opposite of calcify
/datum/component/xenoartifact/proc/calibrate()
	var/atom/movable/A = parent
	//Stats
	calibrated = TRUE
	A.custom_price *= 2
	//Effect
	calibrated_holder = new(A)
	var/obj/emitter/spiral/S = calibrated_holder.add_emitter(/obj/emitter/spiral, "calibration", 11)
	S.setup(artifact_type.material_color)
	A.vis_contents += calibrated_holder

//Build the artifact's appearance
/datum/component/xenoartifact/proc/build_material_appearance()
	var/atom/A = parent
	//Remove old filters, if they exist
	A.remove_filter("texture_overlay")
	A.remove_filter("outline_fix")
	A.remove_filter("outline_1")
	A.remove_filter("outline_2")
	//Apply new stuff
	if(do_mask)
		var/old_desc = A.desc
		//Build the silhouette of the artifact
		var/mutable_appearance/MA = artifact_type.get_mask()
		MA.plane = A.plane //This is important lol
		MA.layer = A.layer
		A.appearance = MA
		//Rset name & desc
		A.name = "[artifact_type.name] [old_name]"
		A.desc = old_desc //Appearance resets this shit
	if(do_texture)
		//Overlay the material texture
		var/icon/I = artifact_type.get_texture()
		A.add_filter("texture_overlay", 1, layering_filter(icon = I, blend_mode = BLEND_INSET_OVERLAY))
		//Throw on some outlines
		//TODO: Check if this fix is still needed in 515 - Racc from 514 : PLAYTEST
		A.add_filter("outline_fix", 2, outline_filter(0)) //This fixes a weird byond thing. BLEND_INSET_OVERLAY will encrouch on outline 1 if we dont do this
		A.add_filter("outline_1", 3, outline_filter(1, "#000", flags = OUTLINE_SHARP))
		A.add_filter("outline_2", 4, outline_filter(1, artifact_type.material_color, flags = OUTLINE_SHARP))

///Create a hint beam from the artifact to the target
/datum/component/xenoartifact/proc/create_beam(atom/movable/target)
	if(!get_turf(target) || locate(parent) in target.contents)
		return
	var/atom/A = parent
	var/datum/beam/xenoa_beam/B = new((!isturf(A.loc) ? A.loc : A), (!isturf(target.loc) ? target.loc : target), time=1.5 SECONDS, beam_icon='icons/obj/xenoarchaeology/xenoartifact.dmi', beam_icon_state="xenoa_beam", btype=/obj/effect/ebeam/xenoa_ebeam)
	B.color_override = artifact_type.material_color
	INVOKE_ASYNC(B, TYPE_PROC_REF(/datum/beam, Start))

/datum/component/xenoartifact/proc/anti_check(atom/target, type = XENOA_ACTIVATION_CONTACT)
	var/mob/M = target
	var/slot = ~ITEM_SLOT_GLOVES
	//Throw you custom clothing block logic here
	switch(type)
		if(XENOA_ACTIVATION_TOUCH)
			slot = ITEM_SLOT_GLOVES
	if(isliving(M) && M.anti_artifact_check(FALSE, slot))
		return TRUE
	//Just check if the thing itself has the anti-component
	var/datum/component/anti_artifact/A = target.GetComponent(/datum/component/anti_artifact)
	if(A?.charges && prob(A.chance))
		A.charges -= 1
		return TRUE
	return FALSE

/datum/component/xenoartifact/proc/handle_trait(datum/source)
	SIGNAL_HANDLER

	var/datum/xenoartifact_trait/T = source
	artifact_traits[T.priority] -= T

/datum/component/xenoartifact/proc/remove_individual_trait(datum/xenoartifact_trait/trait, destroy = FALSE)
	artifact_traits[trait.priority] -= trait
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
