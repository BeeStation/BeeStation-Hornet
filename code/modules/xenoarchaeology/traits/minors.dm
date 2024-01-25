/*
	Minors
	These traits cause the xenoartifact to behave uniquely, just misc shit
	
	* weight - All minors should have a weight that is a multiple of 5
	* conductivity - If a minor should have conductivity, it will be a multiple of 5 too
*/

/datum/xenoartifact_trait/minor
	priority = TRAIT_PRIORITY_MINOR
	register_targets = FALSE
	weight = 5
	conductivity = 0

/*
	Charged
	Increases the artifact trait strength by 25%
*/
/datum/xenoartifact_trait/minor/charged
	material_desc = "charged"
	label_name = "Charged"
	label_desc = "Charged: The Artifact's design seems to incorporate looping elements. This will cause the artifact to produce more powerful effects."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 10
	conductivity = 15
	///Reference to our particle holder
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/charged/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	parent.trait_strength *= 1.25
	setup_generic_touch_hint()

/datum/xenoartifact_trait/minor/charged/Destroy(force, ...)
	if(!parent?.parent)
		return ..()
	parent.trait_strength /= 1.25
	return ..()

/datum/xenoartifact_trait/minor/charged/do_hint(mob/user, atom/item)
	. = ..()
	to_chat(user, "<span class='warning'>Your hair stands on end!</span>")

/datum/xenoartifact_trait/minor/charged/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(parent?.parent)
	particle_holder.add_emitter(/obj/emitter/electrified, "electrified", 10)
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/charged/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/charged/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_INHAND, XENOA_TRAIT_HINT_APPEARANCE("This trait will make static particles appear around the artifact."))

/*
	Capacitive
	Gives the artifact extra uses
*/
/datum/xenoartifact_trait/minor/capacitive
	material_desc = "capacitive"
	label_name = "Capacitive"
	label_desc = "Capacitive: The Artifact's design seems to incorporate a capacitive elements. This will cause the artifact to have more uses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 30
	///How many extra charges do we get?
	var/max_charges = 2
	///How many extra charges do we have?
	var/current_charge

/datum/xenoartifact_trait/minor/capacitive/New()
	. = ..()
	if(!parent?.parent)
		return
	current_charge = max_charges
	parent.cooldown_disabled = TRUE
	setup_generic_item_hint()

/datum/xenoartifact_trait/minor/capacitive/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(current_charge)
		parent.reset_timer()
		current_charge -= 1
		parent.cooldown_disabled = TRUE
	else
		playsound(get_turf(parent?.parent), 'sound/machines/capacitor_charge.ogg', 50, TRUE)
		current_charge = max_charges
		parent.cooldown_disabled = FALSE

/datum/xenoartifact_trait/minor/capacitive/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/multitool))
		to_chat(user, "<span class='warning'>[item] detects [current_charge] additional charges!</span>")
		return ..()

/datum/xenoartifact_trait/minor/capacitive/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_DETECT("multitool, which will also reveal the artifact's additional charges."))

/*
	Dense
	Makes the artifact behave like a structure
*/
/datum/xenoartifact_trait/minor/dense
	material_desc = "dense"
	label_name = "Dense"
	label_desc = "Dense: The Artifact's design seems to incorporate dense elements. This will cause the artifact to be much heavier than usual."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/ringed, /datum/xenoartifact_trait/minor/shielded, /datum/xenoartifact_trait/minor/aerodynamic, /datum/xenoartifact_trait/minor/slippery)
	weight = 30
	///Old value tracker
	var/old_density
	var/old_atom_flag
	var/old_item_flag

/datum/xenoartifact_trait/minor/dense/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/obj/item/A = parent.parent
	//Density
	old_density = A.density
	A.density = TRUE
	//Atom flag
	old_atom_flag = A.interaction_flags_atom
	A.interaction_flags_atom = INTERACT_ATOM_ATTACK_HAND
	//Item flag
	if(isitem(A))
		old_item_flag = A.interaction_flags_item
		A.interaction_flags_item = INTERACT_ATOM_ATTACK_HAND

/datum/xenoartifact_trait/minor/dense/Destroy(force, ...)
	if(!parent?.parent)
		return ..()
	var/obj/item/A = parent.parent
	A.density = old_density
	A.interaction_flags_atom = old_atom_flag
	if(isitem(A))
		A.interaction_flags_item = old_item_flag
	return ..()

/datum/xenoartifact_trait/minor/dense/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Sharp
	Makes the artifact sharp
*/
/datum/xenoartifact_trait/minor/sharp
	material_desc = "sharp"
	label_name = "Sharp"
	label_desc = "Sharp: The Artifact's design seems to incorporate sharp elements. This will cause the artifact to pbe sharper than usual."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	///The artifact's old sharpness
	var/old_sharp
	///The artifact's old force
	var/old_force
	var/max_force = 10
	///The artifact's old attack verbs
	var/list/old_verbs
	var/list/attack_verbs = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")

/datum/xenoartifact_trait/minor/sharp/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/obj/item/A = parent.parent
	if(isitem(A))
		//Sharpness
		old_sharp = A.sharpness
		A.sharpness = IS_SHARP
		//Force
		old_force = A.force
		A.force = max_force * (parent.trait_strength/100)
		//Verbs
		old_verbs = A.attack_verb
		A.attack_verb = attack_verbs

/datum/xenoartifact_trait/minor/sharp/Destroy(force, ...)
	if(!parent?.parent)
		return
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.sharpness = old_sharp
		A.force = old_force
		A.attack_verb = old_verbs
	return ..()

/datum/xenoartifact_trait/minor/sharp/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Cooling
	Decreases the artifact's initial cooldown by XENOA_TRAIT_COOLDOWN_EXTRA_SAFE seconds
*/
/datum/xenoartifact_trait/minor/cooling
	material_desc = "cooling"
	label_name = "Cooling"
	label_desc = "Cooling: The Artifact's design seems to incorporate cooling elements. This will cause the artifact to cooldown faster."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = -5 SECONDS //Point of balance
	weight = 15
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/cooling/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	setup_generic_touch_hint()

/datum/xenoartifact_trait/minor/cooling/do_hint(mob/user, atom/item)
	. = ..()
	to_chat(user, "<span class='warning'>[parent?.parent] feels cool to the touch!</span>")

/datum/xenoartifact_trait/minor/cooling/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	//Build particle holder
	particle_holder = new(parent?.parent)
	particle_holder.add_emitter(/obj/emitter/snow_smoke, "snow_smoke", 10) //TODO: make this a proper effect, it's a placeholder for now - Racc
	//Layer onto parent
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/cooling/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/cooling/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_INHAND, XENOA_TRAIT_HINT_APPEARANCE("This trait will make frost particles appear around the artifact."))

/*
	Sentient
	Allows ghosts to control the artifact
*/
/datum/xenoartifact_trait/minor/sentient
	label_name = "Senitent"
	label_desc = "Senitent: The Artifact's design seems to incorporate sentient elements. This will cause the artifact to have a mind of its own."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	///Mob who lives inside the artifact, and who we give actions to
	var/mob/living/simple_animal/shade/sentience
	///Mob spawner for ghosts
	var/obj/effect/mob_spawn/sentient_artifact/mob_spawner

/datum/xenoartifact_trait/minor/sentient/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	//Setup ghost canidates and mob spawners
	if(SSticker.HasRoundStarted())
		INVOKE_ASYNC(src, PROC_REF(get_canidate))
	else
		mob_spawner = new(parent.parent, src)

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)
	return ..()

/datum/xenoartifact_trait/minor/sentient/get_dictionary_hint()
	. = ..()
	return list(list("icon" = "exclamation", "desc" = "This trait will make the artifact unable to be sold."))

/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && !sentience?.key && (alert(M, "Are you sure you want to control of [sentience]?", "Assume control of [sentience]", "Yes", "No") == "Yes"))
		sentience.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the maleviolent force inside the [parent?.parent]?", ROLE_SENTIENT_XENOARTIFACT, null, 8 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/O = pick(candidates)
		if(istype(O)) //I though LAZYLEN would catch this, I guess NULL is getting injected somewhere
			setup_sentience(O.ckey)
			return
	mob_spawner = new(parent?.parent, src)

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(ckey)
	//Sentience
	sentience = new(parent?.parent)
	sentience.name = pick(GLOB.xenoa_artifact_names)
	sentience.real_name = "[sentience.name] - [parent?.parent]"
	sentience.key = ckey
	sentience.status_flags |= GODMODE
	//Action
	var/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/artifact_senitent_action(parent?.parent, parent)
	sentience.AddSpell(P)
	//Display traits to sentience
	to_chat(sentience, "<span class='notice'>Your traits are: \n</span>")
	for(var/datum/xenoartifact_trait/T in parent.artifact_traits)
		to_chat(sentience, "<span class='notice'>[T.label_name]\n</span>")
		sentience.add_memory(T.label_name)
	playsound(get_turf(parent?.parent), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	//Cleanup
	QDEL_NULL(mob_spawner)

//Spawner for sentience
/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "You're a maleviolent sentience, possesing an ancient alien artifact."
	flavour_text = "Return to your master..."
	use_cooldown = TRUE
	ghost_usable = TRUE
	banType = ROLE_SENTIENT_XENOARTIFACT
	density = FALSE
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	invisibility = 101
	///Ref to the trait we're handling
	var/datum/xenoartifact_trait/minor/sentient/trait

/obj/effect/mob_spawn/sentient_artifact/Initialize(mapload, datum/xenoartifact_trait/minor/sentient/new_trait)
	trait = new_trait
	return ..()

/obj/effect/mob_spawn/sentient_artifact/create(ckey)
	trait?.setup_sentience(ckey)

//Action for sentience
/obj/effect/proc_holder/spell/targeted/artifact_senitent_action
	name = "Trigger Artifact"
	desc = "Select a target to activate your artifact on."
	range = 1
	charge_max = 0 SECONDS
	clothes_req = 0
	include_user = 0
	action_icon = 'icons/mob/actions/actions_revenant.dmi'
	action_icon_state = "r_transmit"
	action_background_icon_state = "bg_spell"
	///Ref to the artifact we're handling
	var/datum/component/xenoartifact/sentient_artifact

/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/Initialize(mapload, datum/component/xenoartifact/artifact)
	. = ..()
	sentient_artifact = artifact
	range = sentient_artifact?.target_range

/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/cast(list/targets,mob/user = usr)
	if(!sentient_artifact)
		return
	for(var/atom/M in targets)
		//We have to check the range ourselves
		if(get_dist(get_turf(sentient_artifact.parent), get_turf(M)) <= range)
			sentient_artifact.register_target(M, TRUE)
	if(length(sentient_artifact.targets))	
		sentient_artifact.trigger(TRUE)

/*
	Delicate
	The artifact has limited uses
*/
/datum/xenoartifact_trait/minor/delicate
	material_desc = "delicate"
	label_name = "Delicate"
	label_desc = "Delicate: The Artifact's design seems to delicate cooling elements. This will cause the artifact to potentially break."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = -5
	///Max amount of uses
	var/max_uses
	///How many uses we have left
	var/current_uses

/datum/xenoartifact_trait/minor/delicate/New(atom/_parent)
	. = ..()
	//Generate uses
	max_uses = pick(list(3, 6, 9))
	current_uses = max_uses

/datum/xenoartifact_trait/minor/delicate/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(parent?.parent), 'sound/effects/glass_step.ogg', 50, TRUE)
	if(current_uses)
		current_uses -= 1
	else if(prob(50)) //After we run out of uses, there is a 50% on use for it to break
		parent.calcify()
		playsound(get_turf(parent?.parent), 'sound/effects/glassbr1.ogg', 50, TRUE)

/datum/xenoartifact_trait/minor/delicate/generate_trait_appearance(atom/target)
	. = ..()
	target.alpha *= 0.7

/datum/xenoartifact_trait/minor/delicate/cut_trait_appearance(atom/target)
	. = ..()
	target.alpha /= 0.7

/datum/xenoartifact_trait/minor/delicate/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_APPEARANCE("This trait will make the artifact noticeably transparent."))

/*
	Aura
	Adds nearby atoms to the target list
*/
/datum/xenoartifact_trait/minor/aura
	label_name = "Aura"
	label_desc = "Aura: The Artifact's design seems to incorporate aura elements. This will cause the artifact to target things nearby."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	extra_target_range = 2
	weight = 15
	conductivity = 5
	///Max amount of extra targets we can have
	var/max_extra_targets = 10

/datum/xenoartifact_trait/minor/aura/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		if(length(parent.targets) > (max_extra_targets * (parent.trait_strength/100)))
			continue
		//Only add mobs or items
		if(!ismob(target) && !isitem(target))
			continue
		parent.register_target(target)

/*
	Scoped
	Increases target range
*/
/datum/xenoartifact_trait/minor/scoped
	material_desc = "scoped"
	label_name = "Scoped"
	label_desc = "Scoped: The Artifact's design seems to incorporate scoped elements. This will cause the artifact to have a larger target range."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	extra_target_range = 9
	weight = 10
	conductivity = 15

/datum/xenoartifact_trait/minor/scoped/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Ringed
	Allows the artifact to be worn in the glove slot
*/
/datum/xenoartifact_trait/minor/ringed
	material_desc = "ringed"
	label_name = "Ringed"
	label_desc = "Ringed: The Artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	///Old wearable state
	var/old_wearable
	///Ref to action
	var/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/artifact_action

/datum/xenoartifact_trait/minor/ringed/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	//Artifact action
	artifact_action = new /obj/effect/proc_holder/spell/targeted/artifact_senitent_action(parent.parent, parent)
	//Item equipping
	var/obj/item/A = parent.parent
	if(isitem(A))
		old_wearable = A.slot_flags
		A.slot_flags |= ITEM_SLOT_GLOVES
		//Action
		RegisterSignal(A, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_action))
		RegisterSignal(A, COMSIG_ITEM_DROPPED, PROC_REF(drop_action))

/datum/xenoartifact_trait/minor/ringed/Destroy(force, ...)
	QDEL_NULL(artifact_action)
	if(!parent?.parent)
		return ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.slot_flags = old_wearable
	return ..()

/datum/xenoartifact_trait/minor/ringed/proc/equip_action(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	var/obj/item/A = parent?.parent
	if(isitem(A) && A.slot_flags & slot)
		equipper.AddSpell(artifact_action)

/datum/xenoartifact_trait/minor/ringed/proc/drop_action(datum/source, mob/user)
	SIGNAL_HANDLER

	user.RemoveSpell(artifact_action, FALSE)

/datum/xenoartifact_trait/minor/delicate/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Shielded
	Makes the artifact act like a shield
*/
/datum/xenoartifact_trait/minor/shielded
	material_desc = "shielded"
	label_name = "Shielded"
	label_desc = "Shielded: The Artifact's design seems to incorporate shielded elements. This will allow the artifact to be used like a shield."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 15
	///Old block level
	var/old_block_level
	var/max_block_level = 4
	///old block power
	var/old_block_power
	var/max_block_power = 80
	///Old block upgrade
	var/old_block_upgrade

/datum/xenoartifact_trait/minor/shielded/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/obj/item/A = parent.parent
	if(isitem(A))
		//Level
		old_block_level = A.block_level
		A.block_level = ROUND_UP(max_block_level * (parent.trait_strength/100))
		//power
		old_block_power = A.block_power
		A.block_power = ROUND_UP(max_block_power * (parent.trait_strength/100))
		//upgrade
		old_block_upgrade = A.block_upgrade_walk
		A.block_upgrade_walk = 1

/datum/xenoartifact_trait/minor/shielded/Destroy(force, ...)
	if(!parent?.parent)
		return ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.block_level = old_block_level
		A.block_power = old_block_power
		A.block_upgrade_walk = old_block_upgrade
	return ..()

/datum/xenoartifact_trait/minor/shielded/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL, XENOA_TRAIT_HINT_RANDOMISED)

/*
	Aerodynamic
	Makes the artifact easy to throw
*/
/datum/xenoartifact_trait/minor/aerodynamic
	material_desc = "aerodynamic"
	label_name = "Aerodynamic"
	label_desc = "Aerodynamic: The Artifact's design seems to incorporate shielAerodynamicded elements. This will allow the artifact to be thrown further."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = -5
	///Old throw range
	var/old_throw_range

/datum/xenoartifact_trait/minor/aerodynamic/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/movable/A = parent.parent
	if(ismovable(A))
		old_throw_range = A.throw_range
		A.throw_range = 9

/datum/xenoartifact_trait/minor/aerodynamic/Destroy(force, ...)
	if(!parent?.parent)
		return ..()
	var/atom/movable/A = parent.parent
	if(ismovable(A))
		A.throw_range = old_throw_range
	return ..()

/datum/xenoartifact_trait/minor/aerodynamic/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Signaller
	Sends a signal when the artifact is activated
*/
/datum/xenoartifact_trait/minor/signaller
	label_name = "Signaller"
	label_desc = "Signaller: The Artifact's design seems to incorporate signalling elements. This will cause the artifact to send a signal when activated."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 15
	var/atom/movable/artifact_particle_holder/particle_holder
	///Signal code
	var/code
	///Signal frequency
	var/datum/radio_frequency/radio_connection
	//Signal
	var/datum/signal/signal
	
/datum/xenoartifact_trait/minor/signaller/New(atom/_parent)
	. = ..()
	//Code
	code = rand(0, 100)
	//Signal
	signal = new(list("code" = code))
	//Frequency
	radio_connection = SSradio.add_object(src, FREQ_SIGNALER, "[RADIO_XENOA]_[REF(src)]")

	if(!parent?.parent)
		return
	setup_generic_item_hint()
	if(!(locate(/datum/xenoartifact_trait/activator) in parent.artifact_traits[TRAIT_PRIORITY_ACTIVATOR]))
		addtimer(CALLBACK(src, PROC_REF(do_sonar)), 2 SECONDS)

/datum/xenoartifact_trait/minor/signaller/Destroy(force, ...)
	SSradio.remove_object(src, FREQ_SIGNALER)
	QDEL_NULL(signal)
	return ..()

/datum/xenoartifact_trait/minor/signaller/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	INVOKE_ASYNC(src, PROC_REF(do_signal))

/datum/xenoartifact_trait/minor/signaller/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/analyzer))
		to_chat(user, "<span class='warning'>[item] detects an output frequency & code of [FREQ_SIGNALER]-[code]!</span>")
		return ..()

/datum/xenoartifact_trait/minor/signaller/generate_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	particle_holder = new(parent?.parent)
	particle_holder.add_emitter(/obj/emitter/sonar/out, "sonar", 10)
	target.vis_contents += particle_holder

/datum/xenoartifact_trait/minor/signaller/cut_trait_appearance(atom/movable/target)
	. = ..()
	if(!ismovable(target))
		return
	target.vis_contents -= particle_holder
	QDEL_NULL(particle_holder)

/datum/xenoartifact_trait/minor/signaller/proc/do_signal()
	if(!radio_connection || !signal)
		return
	radio_connection.post_signal(src, signal)

/datum/xenoartifact_trait/minor/signaller/proc/receive_signal(datum/signal/signal)
	return

/datum/xenoartifact_trait/minor/signaller/proc/do_sonar(repeat = TRUE)
	if(QDELETED(src))
		return
	playsound(get_turf(parent?.parent), 'sound/effects/ping.ogg', 60, TRUE)
	var/rand_time = rand(6, 12) SECONDS
	addtimer(CALLBACK(src, PROC_REF(do_sonar)), rand_time)

/datum/xenoartifact_trait/minor/signaller/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its output code & frequency"), XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_APPEARANCE("This trait will make radar particles appear around the artifact."))

/*
	Anchor
	Anchors the artifact
*/
/datum/xenoartifact_trait/minor/anchor
	label_name = "Anchor"
	label_desc = "Anchor: The Artifact's design seems to incorporate anchoring elements. This will cause the artifact to anchor when triggered, it can also be unanchored with typical tools."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	extra_target_range = 2
	weight = 10

/datum/xenoartifact_trait/minor/anchor/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/movable/AM = parent.parent
	if(ismovable(AM))
		RegisterSignal(AM, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(toggle_anchor))

/datum/xenoartifact_trait/minor/anchor/Destroy(force, ...)
	if(!parent?.parent)
		return ..()
	var/atom/movable/AM = parent.parent
	if(ismovable(AM))
		AM.anchored = FALSE
	return ..()

/datum/xenoartifact_trait/minor/anchor/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	toggle_anchor()

/datum/xenoartifact_trait/minor/anchor/proc/toggle_anchor(datum/source, mob/living/user, obj/item/I, list/recipes)
	SIGNAL_HANDLER

	var/atom/movable/AM = parent?.parent
	//handle being held
	if(isliving(AM.loc))
		var/mob/living/M = AM.loc
		M.dropItemToGround(AM)
	//Anchor
	if(ismovable(AM) && isturf(AM.loc))
		AM.anchored = !AM.anchored
	//Message
	AM.visible_message("<span class='warning'>[AM] [AM.anchored ? "anchors to" : "unanchors from"] [get_turf(AM)]!</span>", allow_inside_usr = TRUE)

/*
	Slippery
	makes the artifact slippery
*/
/datum/xenoartifact_trait/minor/slippery
	material_desc = "slippery"
	label_name = "Slippery"
	label_desc = "Slippery: The Artifact's design seems to incorporate slippery elements. This will cause the artifact to be slippery."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	conductivity = 5
	///Refernce to slip component for later cleanup
	var/datum/component/slippery/slip_comp

/datum/xenoartifact_trait/minor/slippery/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/A = parent.parent
	slip_comp = A.AddComponent(/datum/component/slippery, 60)

/datum/xenoartifact_trait/minor/slippery/Destroy(force, ...)
	QDEL_NULL(slip_comp)
	return ..()

/datum/xenoartifact_trait/minor/slippery/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Haunted
	Allows the artifact to be controlled by ghosts
*/
/datum/xenoartifact_trait/minor/haunted
	label_name = "Haunted"
	label_desc = "Haunted: The Artifact's design seems to incorporate incorporeal elements. This will cause the artifact to move unexpectedly."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 35
	///Refernce to move component for later cleanup
	var/datum/component/deadchat_control/controller

/datum/xenoartifact_trait/minor/haunted/New(atom/_parent)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/A = parent.parent
	controller = A._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(src, PROC_REF(haunted_step), A, NORTH),
			 "down" = CALLBACK(src, PROC_REF(haunted_step), A, SOUTH),
			 "left" = CALLBACK(src, PROC_REF(haunted_step), A, WEST),
			 "right" = CALLBACK(src, PROC_REF(haunted_step), A, EAST),
			 "activate" = CALLBACK(src, PROC_REF(activate_parent), A)), 8 SECONDS))
	addtimer(CALLBACK(src, PROC_REF(do_wail)), 17 SECONDS)

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	QDEL_NULL(controller)
	return ..()

/datum/xenoartifact_trait/minor/haunted/proc/do_wail(repeat = TRUE)
	if(QDELETED(src))
		return
	playsound(get_turf(parent?.parent), 'sound/spookoween/ghost_whisper.ogg', 30, TRUE)
	var/rand_time = rand(26, 34) SECONDS
	addtimer(CALLBACK(src, PROC_REF(do_wail)), rand_time)


/datum/xenoartifact_trait/minor/haunted/proc/haunted_step(atom/movable/target, dir)
	//Make any mobs drop this before it moves
	if(isliving(target.loc))
		var/mob/living/M = target.loc
		M.dropItemToGround(target)
	playsound(get_turf(target), 'sound/effects/magic.ogg', 50, TRUE)
	step(target, dir)

/datum/xenoartifact_trait/minor/haunted/proc/activate_parent()
	//Find a target
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		parent.register_target(target, TRUE)
		parent.trigger(TRUE)
		return
