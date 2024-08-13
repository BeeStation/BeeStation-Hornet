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
	label_desc = "Charged: The artifact's design seems to incorporate looping elements. This will cause the artifact to produce more powerful effects."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 10
	conductivity = 15
	///Reference to our particle holder
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/charged/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	parent.trait_strength *= 1.25
	setup_generic_touch_hint()

/datum/xenoartifact_trait/minor/charged/remove_parent(datum/source, pensive)
	if(!parent)
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
	label_desc = "Capacitive: The artifact's design seems to incorporate a capacitive elements. This will cause the artifact to have more uses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 30
	///How many extra charges do we get?
	var/max_charges = 2
	///How many extra charges do we have?
	var/current_charge

/datum/xenoartifact_trait/minor/capacitive/register_parent(datum/source)
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
	label_desc = "Dense: The artifact's design seems to incorporate dense elements. This will cause the artifact to be much heavier than usual."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/sharp, /datum/xenoartifact_trait/minor/ringed, /datum/xenoartifact_trait/minor/shielded,
	/datum/xenoartifact_trait/minor/aerodynamic, /datum/xenoartifact_trait/minor/slippery, /datum/xenoartifact_trait/minor/ringed/attack)
	weight = 30
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old value tracker
	var/old_density
	var/old_atom_flag
	var/old_item_flag

/datum/xenoartifact_trait/minor/dense/register_parent(datum/source)
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

/datum/xenoartifact_trait/minor/dense/remove_parent(datum/source, pensive)
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
	label_desc = "Sharp: The artifact's design seems to incorporate sharp elements. This will cause the artifact to pbe sharper than usual."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///The artifact's old sharpness
	var/old_sharp
	///The artifact's old force
	var/old_force
	var/max_force = 10
	///The artifact's old attack verbs
	var/list/old_verbs
	var/list/attack_verbs = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")

/datum/xenoartifact_trait/minor/sharp/register_parent(datum/source)
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
		old_verbs = A.attack_verb_simple
		A.attack_verb_simple = attack_verbs

/datum/xenoartifact_trait/minor/sharp/remove_parent(datum/source, pensive)
	if(!parent?.parent)
		return
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.sharpness = old_sharp
		A.force = old_force
		A.attack_verb_simple = old_verbs
	return ..()

/datum/xenoartifact_trait/minor/sharp/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_MATERIAL)

/*
	Cooling
	Decreases the artifact's initial cooldown by 5 seconds
*/
/datum/xenoartifact_trait/minor/cooling
	material_desc = "cooling"
	label_name = "Cooling"
	label_desc = "Cooling: The artifact's design seems to incorporate cooling elements. This will cause the artifact to cooldown faster."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	cooldown = -4 SECONDS //Point of balance
	weight = 15
	var/atom/movable/artifact_particle_holder/particle_holder

/datum/xenoartifact_trait/minor/cooling/register_parent(datum/source)
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
	particle_holder.add_emitter(/obj/emitter/snow, "snow", 10)
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
	label_name = "Sentient"
	label_desc = "Sentient: The artifact's design seems to incorporate sentient elements. This will cause the artifact to have a mind of its own."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	can_pearl = FALSE
	///Mob who lives inside the artifact, and who we give actions to
	var/mob/living/simple_animal/shade/sentience/sentience
	///Mob spawner for ghosts
	var/obj/effect/mob_spawn/sentient_artifact/mob_spawner

/datum/xenoartifact_trait/minor/sentient/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	//Register a signal to KILL!
	RegisterSignal(parent, XENOA_CALCIFIED, PROC_REF(suicide))
	//Setup ghost canidates and mob spawners
	if(SSticker.HasRoundStarted())
		INVOKE_ASYNC(src, PROC_REF(get_canidate))
	else
		mob_spawner = new(parent.parent, src)

/datum/xenoartifact_trait/minor/sentient/Destroy(force, ...)
	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)
	return ..()

/datum/xenoartifact_trait/minor/sentient/proc/handle_ghost(datum/source, mob/M, list/examine_text)
	if(isobserver(M) && !sentience?.key && (alert(M, "Are you sure you want to control of [sentience]?", "Assume control of [sentience]", "Yes", "No") == "Yes"))
		sentience.key = M.ckey

/datum/xenoartifact_trait/minor/sentient/proc/get_canidate()
	var/list/mob/dead/observer/candidates = poll_ghost_candidates("Do you want to play as the maleviolent force inside the [parent?.parent]?", ROLE_SENTIENT_XENOARTIFACT, null, 8 SECONDS)
	if(LAZYLEN(candidates) && parent?.parent)
		var/mob/dead/observer/O = pick(candidates)
		if(istype(O) && O.ckey) //I though LAZYLEN would catch this, I guess NULL is getting injected somewhere
			setup_sentience(O.ckey)
			return
	mob_spawner = new(parent?.parent, src)

/datum/xenoartifact_trait/minor/sentient/proc/setup_sentience(ckey)
	var/atom/A = parent?.parent
	if(!parent?.parent || !ckey || !A?.loc)
		return
	//Sentience
	sentience = new(parent?.parent)
	sentience.name = pick(SSxenoarchaeology.xenoa_artifact_names)
	sentience.real_name = "[sentience.name] - [parent?.parent]"
	sentience.key = ckey
	sentience.status_flags |= GODMODE
	//Stop them from wriggling away
	var/atom/movable/AM = parent.parent
	AM.buckle_mob(AM, TRUE)
	//Action
	var/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/P = new /obj/effect/proc_holder/spell/targeted/artifact_senitent_action(parent?.parent, parent)
	sentience.AddSpell(P)
	//Display traits to sentience
	to_chat(sentience, "<span class='notice'>Your traits are: \n</span>")
	for(var/index in parent.artifact_traits)
		for(var/datum/xenoartifact_trait/T as() in parent.artifact_traits[index])
			to_chat(sentience, "<span class='notice'>[T.label_name]\n</span>")
			sentience.add_memory(T.label_name)
	playsound(get_turf(parent?.parent), 'sound/items/haunted/ghostitemattack.ogg', 50, TRUE)
	//Cleanup
	QDEL_NULL(mob_spawner)

//Throw calcification logic here
/datum/xenoartifact_trait/minor/sentient/proc/suicide(datum/source)
	SIGNAL_HANDLER

	QDEL_NULL(sentience)
	QDEL_NULL(mob_spawner)

//Spawner for sentience
/obj/effect/mob_spawn/sentient_artifact
	death = FALSE
	name = "Sentient Xenoartifact"
	short_desc = "You're a maleviolent sentience, possesing an ancient alien artifact."
	flavour_text = "Return to your master..."
	use_cooldown = TRUE
	ghost_usable = TRUE
	instant = FALSE
	roundstart = FALSE
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

/obj/effect/proc_holder/spell/targeted/artifact_senitent_action/cast(list/targets, mob/user = usr)
	if(!sentient_artifact || sentient_artifact.use_cooldown_timer)
		if(sentient_artifact?.use_cooldown_timer)
			to_chat(user, "<span class='warning'>The artifact is still cooling down, wait [timeleft(sentient_artifact.use_cooldown_timer)/10] seconds!</span>")
		return
	for(var/atom/M in targets)
		//We have to check the range ourselves
		if(get_dist(get_turf(sentient_artifact.parent), get_turf(M)) <= range)
			sentient_artifact.register_target(M)
	sentient_artifact.trigger()

/mob/living/simple_animal/shade/sentience
	desc = "Wait, what the fuck?"

/*
	Delicate
	The artifact has limited uses
*/
/datum/xenoartifact_trait/minor/delicate
	material_desc = "delicate"
	label_name = "Delicate"
	label_desc = "Delicate: The artifact's design seems to delicate cooling elements. This will cause the artifact to potentially break."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = -5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
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
	label_desc = "Aura: The artifact's design seems to incorporate aura elements. This will cause the artifact to target things nearby."
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
	label_desc = "Scoped: The artifact's design seems to incorporate scoped elements. This will cause the artifact to have a larger target range."
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
	label_desc = "Ringed: The artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn, and catch information from the wearer."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/ringed/attack)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old wearable state
	var/old_wearable

/datum/xenoartifact_trait/minor/ringed/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	//Item equipping
	var/obj/item/A = parent.parent
	if(isitem(A))
		old_wearable = A.slot_flags
		A.slot_flags |= ITEM_SLOT_GLOVES
		//Action
		RegisterSignal(A, COMSIG_ITEM_EQUIPPED, PROC_REF(equip_action))
		RegisterSignal(A, COMSIG_ITEM_DROPPED, PROC_REF(drop_action))

/datum/xenoartifact_trait/minor/ringed/remove_parent(datum/source, pensive)
	if(!parent?.parent)
		return ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.slot_flags = old_wearable
	return ..()

/datum/xenoartifact_trait/minor/ringed/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pass attacks on the user to the artifact, when worn. This only applies to attacks involving items"))

/datum/xenoartifact_trait/minor/ringed/proc/equip_action(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER

	if(slot == ITEM_SLOT_GLOVES)
		RegisterSignal(equipper, COMSIG_PARENT_ATTACKBY, PROC_REF(catch_attack))

/datum/xenoartifact_trait/minor/ringed/proc/drop_action(datum/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_PARENT_ATTACKBY)

//Foward the attack to our artifact
/datum/xenoartifact_trait/minor/ringed/proc/catch_attack(datum/source, obj/item, mob/living, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(cool_async_action), item, living, params)

/datum/xenoartifact_trait/minor/ringed/proc/cool_async_action(obj/item, mob/living, params)
	var/atom/A = parent?.parent
	A?.attackby(item, living, params)

//Variant for when the user attacks
/datum/xenoartifact_trait/minor/ringed/attack
	material_desc = "ringed"
	label_name = "Ringed Δ"
	label_desc = "Ringed Δ: The artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn, and catch information from the wearer."
	conductivity = 15
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense, /datum/xenoartifact_trait/minor/ringed)

/datum/xenoartifact_trait/minor/ringed/attack/equip_action(datum/source, mob/equipper, slot)
	if(slot == ITEM_SLOT_GLOVES)
		RegisterSignal(equipper, COMSIG_MOB_ATTACK_HAND, PROC_REF(catch_user_attack))

/datum/xenoartifact_trait/minor/ringed/attack/drop_action(datum/source, mob/user)
	UnregisterSignal(user, COMSIG_MOB_ATTACK_HAND)

/datum/xenoartifact_trait/minor/ringed/attack/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pass attacks from the user to the artifact, when worn"))

/datum/xenoartifact_trait/minor/ringed/attack/proc/catch_user_attack(datum/source, mob/user, mob/target, params)
	SIGNAL_HANDLER

	INVOKE_ASYNC(src, PROC_REF(other_cool_async_action), user, target, params)

/datum/xenoartifact_trait/minor/ringed/attack/proc/other_cool_async_action(mob/user, mob/target, params)
	if(user == target)
		return
	var/obj/item/A = parent?.parent
	A?.afterattack(target, user, TRUE)

/*
	Shielded
	Makes the artifact act like a shield
*/
/datum/xenoartifact_trait/minor/shielded
	material_desc = "shielded"
	label_name = "Shielded"
	label_desc = "Shielded: The artifact's design seems to incorporate shielded elements. This will allow the artifact to be used like a shield."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = 15
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old block level
	var/old_block_level
	var/max_block_level = 4
	///old block power
	var/old_block_power
	var/max_block_power = 80
	///Old block upgrade
	var/old_block_upgrade

/datum/xenoartifact_trait/minor/shielded/register_parent(datum/source)
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

/datum/xenoartifact_trait/minor/shielded/remove_parent(datum/source, pensive)
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
	label_desc = "Aerodynamic: The artifact's design seems to incorporate aerodynamicded elements. This will allow the artifact to be thrown further."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	weight = -5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Old throw range
	var/old_throw_range

/datum/xenoartifact_trait/minor/aerodynamic/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/movable/A = parent.parent
	if(ismovable(A))
		old_throw_range = A.throw_range
		A.throw_range = 9

/datum/xenoartifact_trait/minor/aerodynamic/remove_parent(datum/source, pensive)
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
	label_desc = "Signaller: The artifact's design seems to incorporate signalling elements. This will cause the artifact to send a signal when activated."
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

/datum/xenoartifact_trait/minor/signaller/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	setup_generic_item_hint()
	if(!(locate(/datum/xenoartifact_trait/activator/signal) in parent.artifact_traits[TRAIT_PRIORITY_ACTIVATOR]))
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
	return list(XENOA_TRAIT_HINT_DETECT("analyzer, which will also reveal its output code & frequency"),
	XENOA_TRAIT_HINT_RANDOMISED, XENOA_TRAIT_HINT_APPEARANCE("This trait will make radar particles appear around the artifact."),
	XENOA_TRAIT_HINT_SOUND("sonar ping"))

/*
	Anchor
	Anchors the artifact
*/
/datum/xenoartifact_trait/minor/anchor
	label_name = "Anchor"
	label_desc = "Anchor: The artifact's design seems to incorporate anchoring elements. This will cause the artifact to anchor when triggered, it can also be unanchored with typical tools."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 10
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE

/datum/xenoartifact_trait/minor/anchor/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/movable/AM = parent.parent
	if(ismovable(AM))
		RegisterSignal(AM, COMSIG_ATOM_TOOL_ACT(TOOL_WRENCH), PROC_REF(toggle_anchor))

/datum/xenoartifact_trait/minor/anchor/remove_parent(datum/source, pensive)
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
		playsound(get_turf(parent?.parent), 'sound/items/handling/wrench_pickup.ogg', 50, TRUE)
	//Message
	AM.visible_message("<span class='warning'>[AM] [AM.anchored ? "anchors to" : "unanchors from"] [get_turf(AM)]!</span>", allow_inside_usr = TRUE)

/*
	Slippery
	makes the artifact slippery
*/
/datum/xenoartifact_trait/minor/slippery
	material_desc = "slippery"
	label_name = "Slippery"
	label_desc = "Slippery: The artifact's design seems to incorporate slippery elements. This will cause the artifact to be slippery."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	conductivity = 5
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Refernce to slip component for later cleanup
	var/datum/component/slippery/slip_comp

/datum/xenoartifact_trait/minor/slippery/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/A = parent.parent
	slip_comp = A.AddComponent(/datum/component/slippery, 60)

/datum/xenoartifact_trait/minor/slippery/remove_parent(datum/source, pensive)
	if(!parent?.parent)
		return ..()
	slip_comp.RemoveComponent()
	slip_comp = null
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
	label_desc = "Haunted: The artifact's design seems to incorporate incorporeal elements. This will cause the artifact to move unexpectedly."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	conductivity = 35
	blacklist_traits = list(/datum/xenoartifact_trait/minor/haunted/instant)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB
	can_pearl = FALSE
	///Refernce to move component for later cleanup
	var/datum/component/deadchat_control/controller
	///How long between moves
	var/move_delay = 8 SECONDS

/datum/xenoartifact_trait/minor/haunted/register_parent(datum/source)
	. = ..()
	if(!parent?.parent)
		return
	var/atom/A = parent.parent
	controller = A._AddComponent(list(/datum/component/deadchat_control, "democracy", list(
			 "up" = CALLBACK(src, PROC_REF(haunted_step), A, NORTH),
			 "down" = CALLBACK(src, PROC_REF(haunted_step), A, SOUTH),
			 "left" = CALLBACK(src, PROC_REF(haunted_step), A, WEST),
			 "right" = CALLBACK(src, PROC_REF(haunted_step), A, EAST),
			 "activate" = CALLBACK(src, PROC_REF(activate_parent), A)), move_delay))
	addtimer(CALLBACK(src, PROC_REF(do_wail)), 35 SECONDS)

/datum/xenoartifact_trait/minor/haunted/Destroy(force, ...)
	QDEL_NULL(controller)
	return ..()

/datum/xenoartifact_trait/minor/haunted/do_hint(mob/user, atom/item)
	if(istype(item, /obj/item/storage/book/bible))
		to_chat(user, "<span class='warning'>[item] upsets the sprits of [parent?.parent]!</span>")
		return ..()

/datum/xenoartifact_trait/minor/haunted/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_DETECT("bible"),
	XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("allow the artifact to be moved, by ghosts, every 8 seconds"),
	XENOA_TRAIT_HINT_SOUND("ghost moaning"))

/datum/xenoartifact_trait/minor/haunted/proc/do_wail(repeat = TRUE)
	if(QDELETED(src))
		return
	var/atom/A = parent.parent
	if(isturf(A.loc))
		playsound(get_turf(parent?.parent), 'sound/spookoween/ghost_whisper_short.ogg', 30, TRUE)
	addtimer(CALLBACK(src, PROC_REF(do_wail)), 35 SECONDS)


/datum/xenoartifact_trait/minor/haunted/proc/haunted_step(atom/movable/target, dir)
	if(parent.calcified)
		return
	//Make any mobs drop this before it moves
	if(isliving(target.loc))
		var/mob/living/M = target.loc
		M.dropItemToGround(target)
	playsound(get_turf(target), 'sound/effects/magic.ogg', 50, TRUE)
	step(target, dir)

/datum/xenoartifact_trait/minor/haunted/proc/activate_parent()
	if(parent.calcified)
		return
	//Find a target
	for(var/atom/target in oview(parent.target_range, get_turf(parent?.parent)))
		parent.register_target(target, TRUE)
		parent.trigger(TRUE)
		return

//Instant variant, no move delay. Can only move when not seen
/datum/xenoartifact_trait/minor/haunted/instant
	label_name = "Haunted Δ"
	label_desc = "Haunted Δ: The artifact's design seems to incorporate incorporeal elements. This will cause the artifact to move unexpectedly, when not observed."
	move_delay = 1 SECONDS
	blacklist_traits = list(/datum/xenoartifact_trait/minor/haunted)
	conductivity = 5
	///Cooldown for the use action
	var/action_cooldown
	var/action_cooldown_time = 8 SECONDS
	///How far we look for mobs
	var/seek_distance = 9

/datum/xenoartifact_trait/minor/haunted/instant/haunted_step(atom/movable/target, dir)
	if(parent.calcified)
		return
	//This may seem scary, and expensive, but it's only called WHEN ghosts try to move the artifact
	var/list/mobs = oview(seek_distance, parent.parent)
	for(var/mob/living/M in mobs)
		if(!M.stat && M.ckey)
			return
	return ..()

/datum/xenoartifact_trait/minor/haunted/instant/activate_parent()
	if(!action_cooldown)
		action_cooldown = addtimer(CALLBACK(src, PROC_REF(reset_action_timer)), action_cooldown_time, TIMER_STOPPABLE)
		return ..()

/datum/xenoartifact_trait/minor/haunted/instant/get_dictionary_hint()
	return list(XENOA_TRAIT_HINT_DETECT("bible"),
	XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("allow the artifact to be moved, by ghosts, when no-one is looking"),
	XENOA_TRAIT_HINT_SOUND("ghost moaning"))

/datum/xenoartifact_trait/minor/haunted/instant/proc/reset_action_timer()
	if(action_cooldown)
		deltimer(action_cooldown)
	action_cooldown = null

/*
	Bleeding
	The artifact bleeds for a short period after being activated
*/
/datum/xenoartifact_trait/minor/bleed
	label_name = "Bleeding"
	label_desc = "Bleeding: The artifact's design seems to incorporate bleeding elements. This will cause the artifact to bleed when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	blacklist_traits = list(/datum/xenoartifact_trait/minor/bleed/fun)
	///Timer stuff to keep track of when we're bleeding
	var/bleed_duration = 5 SECONDS
	var/bleed_timer
	///Which blood decal do we use?
	var/blood_splat = /obj/effect/decal/cleanable/blood
	var/blood_tracks = /obj/effect/decal/cleanable/blood/tracks

/datum/xenoartifact_trait/minor/bleed/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!. || bleed_timer)
		return
	playsound(parent.parent, 'sound/effects/splat.ogg', 50, TRUE)
	new blood_splat(get_turf(parent.parent))
	bleed_timer = addtimer(CALLBACK(src, PROC_REF(reset_timer)), bleed_duration, TIMER_STOPPABLE)

/datum/xenoartifact_trait/minor/bleed/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("bleed red blood"))

/datum/xenoartifact_trait/minor/bleed/catch_move(datum/source, atom/target, dir)
	. = ..()
	if(!bleed_timer)
		return
	var/obj/effect/decal/cleanable/blood/tracks/T = new blood_tracks(get_turf(parent.parent))
	T.setDir(dir)

/datum/xenoartifact_trait/minor/bleed/proc/reset_timer()
	if(bleed_timer)
		deltimer(bleed_timer)
	bleed_timer = null

//Fun variant
/obj/effect/decal/cleanable/blood/fun

/obj/effect/decal/cleanable/blood/fun/Initialize(mapload)
	color = "#[random_color()]"
	return ..()

/obj/effect/decal/cleanable/blood/tracks/fun

/obj/effect/decal/cleanable/blood/tracks/fun/Initialize(mapload)
	color = "#[random_color()]"
	return ..()

/datum/xenoartifact_trait/minor/bleed/fun
	label_name = "Bleeding Δ"
	label_desc = "Bleeding Δ: The artifact's design seems to incorporate bleeding elements. This will cause the artifact to bleed when triggered."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/bleed)
	blood_splat = /obj/effect/decal/cleanable/blood/fun
	blood_tracks = /obj/effect/decal/cleanable/blood/tracks/fun

/datum/xenoartifact_trait/minor/bleed/fun/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("bleed 'clown' blood"))

/*
	Magnetic
	The artifact attracts metalic objects when activated
*/
/datum/xenoartifact_trait/minor/magnetic
	label_name = "Magnetic"
	label_desc = "Magnetic: The artifact's design seems to incorporate magnetic elements. This will cause the artifact to attract metalic objects when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 30
	blacklist_traits = list(/datum/xenoartifact_trait/minor/magnetic/push)
	///Maximum magnetic pull
	var/max_pull_steps = 2
	///Maximum range
	var/max_pull_range = 4

/datum/xenoartifact_trait/minor/magnetic/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_turf(parent.parent)
	var/pull_steps = max_pull_steps * (parent.trait_strength/100)
	var/pull_range = max_pull_range * (parent.trait_strength/100)
	for(var/obj/M in orange(pull_range, T))
		if(M.anchored || !(M.flags_1 & CONDUCT_1))
			continue
		INVOKE_ASYNC(src, PROC_REF(magnetize), M, T, pull_steps)
	for(var/mob/living/silicon/S in orange(pull_range, T))
		if(isAI(S))
			continue
		INVOKE_ASYNC(src, PROC_REF(magnetize), S, T, pull_steps)

/datum/xenoartifact_trait/minor/magnetic/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("pull metalic objects towards it"))

/datum/xenoartifact_trait/minor/magnetic/proc/magnetize(atom/movable/AM, atom/target, _pull_steps)
	for(var/i in 1 to _pull_steps)
		magnetic_direction(AM, target)
		sleep(1)

/datum/xenoartifact_trait/minor/magnetic/proc/magnetic_direction(atom/movable/AM, atom/target)
	step_towards(AM, target)

//Inverse variant
/datum/xenoartifact_trait/minor/magnetic/push
	label_name = "Magnetic Δ"
	label_desc = "Magnetic Δ: The artifact's design seems to incorporate magnetic elements. This will cause the artifact to repulse metalic objects when triggered."
	blacklist_traits = list(/datum/xenoartifact_trait/minor/magnetic)
	conductivity = 10

/datum/xenoartifact_trait/minor/magnetic/push/get_dictionary_hint()
	. = ..()
	return list(XENOA_TRAIT_HINT_TWIN, XENOA_TRAIT_HINT_TWIN_VARIANT("push metalic objects away from it"))

/datum/xenoartifact_trait/minor/magnetic/push/magnetic_direction(atom/movable/AM, atom/target)
	step_away(AM, target)

/*
	Impulsing
	The artifact dashes away when activated
*/
/datum/xenoartifact_trait/minor/impulse
	label_name = "Impulsing"
	label_desc = "Impulsing: The artifact's design seems to incorporate impulsing elements. This will cause the artifact to have a impulsing away from its current position, when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	weight = 15
	conductivity = 10
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	///Max force we can use, aka how far we throw things
	var/max_force = 7

/datum/xenoartifact_trait/minor/impulse/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/turf/T = get_edge_target_turf(get_turf(parent.parent), pick(NORTH, EAST, SOUTH, WEST))
	var/atom/movable/AM = parent.parent
	//handle being held
	if(isliving(AM.loc))
		var/mob/living/L = AM.loc
		L.dropItemToGround(AM)
	//Get the fuck outta dodge
	AM.throw_at(T, max_force*(parent.trait_strength/100), 4)

/*
	Sticky
	The artifact briefly becomes sticky when activated
*/
/datum/xenoartifact_trait/minor/sticky
	material_desc = "sticky"
	label_name = "Sticky"
	label_desc = "Sticky: The artifact's design seems to incorporate sticky elements. This will cause the artifact to briefly become sticky, when triggered."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT | XENOA_PEARL_TRAIT
	blacklist_traits = list(/datum/xenoartifact_trait/minor/dense)
	incompatabilities = TRAIT_INCOMPATIBLE_MOB | TRAIT_INCOMPATIBLE_STRUCTURE
	weight = 10
	conductivity = 15
	///Max amount of time we can be sticky for
	var/sticky_time = 25 SECONDS
	var/sticky_timer

/datum/xenoartifact_trait/minor/sticky/remove_parent(datum/source, pensive)
	var/atom/movable/AM = parent?.parent
	if(!AM)
		return ..()
	REMOVE_TRAIT(AM, TRAIT_NODROP, src)
	deltimer(sticky_timer)
	return ..()

/datum/xenoartifact_trait/minor/sticky/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	var/atom/movable/AM = parent.parent
	AM.visible_message("<span class='warning'>[AM] starts secreting a sticky substance!</span>", TRUE, allow_inside_usr = TRUE)
	if(HAS_TRAIT_FROM(AM, TRAIT_NODROP, "[REF(src)]"))
		return
	ADD_TRAIT(AM, TRAIT_NODROP, "[REF(src)]")
	sticky_timer = addtimer(CALLBACK(src, PROC_REF(unstick)), sticky_time, TIMER_STOPPABLE)

/datum/xenoartifact_trait/minor/sticky/proc/unstick()
	var/atom/movable/AM = parent.parent
	REMOVE_TRAIT(AM, TRAIT_NODROP, "[REF(src)]")
