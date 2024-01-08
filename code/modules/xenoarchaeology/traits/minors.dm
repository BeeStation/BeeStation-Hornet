/datum/xenoartifact_trait/minor
	priority = TRAIT_PRIORITY_MINOR
	register_targets = FALSE

/*
	Charged
	Increases the artifact trait strength by 25%
*/
/datum/xenoartifact_trait/minor/charged
	examine_desc = "charged"
	label_name = "Charged"
	label_desc = "Charged: The Artifact's design seems to incorporate looping elements. This will cause the artifact to produce more powerful effects."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT

/datum/xenoartifact_trait/minor/charged/New(atom/_parent)
	. = ..()
	parent.trait_strength *= 1.25

/datum/xenoartifact_trait/minor/charged/Destroy(force, ...)
	. = ..()
	parent.trait_strength /= 1.25

/*
	Capacitive
	Gives the artifact extra uses
*/
/datum/xenoartifact_trait/minor/capacitive
	examine_desc = "capacitive"
	label_name = "Capacitive"
	label_desc = "Capacitive: The Artifact's design seems to incorporate a capacitive elements. This will cause the artifact to have more uses."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	///How many extra charges do we get?
	var/max_charges = 2
	///How many extra charges do we have?
	var/current_charge

/datum/xenoartifact_trait/minor/capacitive/New()
	. = ..()
	current_charge = max_charges

/datum/xenoartifact_trait/minor/capacitive/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	if(current_charge)
		parent.reset_timer()
		current_charge -= 1
	else
		playsound(get_turf(parent.parent), 'sound/machines/capacitor_charge.ogg', 50, TRUE)
		current_charge = max_charges

/*
	Dense
	Makes the artifact behave like a structure
*/
/datum/xenoartifact_trait/minor/dense
	examine_desc = "dense"
	label_name = "Dense"
	label_desc = "Dense: The Artifact's design seems to incorporate dense elements. This will cause the artifact to be much heavier than usual."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	///Old value tracker
	var/old_density
	var/old_atom_flag
	var/old_item_flag

/datum/xenoartifact_trait/minor/dense/New(atom/_parent)
	. = ..()
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
	. = ..()
	var/obj/item/A = parent.parent
	A.density = old_density
	A.interaction_flags_atom = old_atom_flag
	if(isitem(A))
		A.interaction_flags_item = old_item_flag

/*
	Sharp
	Makes the artifact sharp
*/
/datum/xenoartifact_trait/minor/sharp
	examine_desc = "sharp"
	label_name = "Sharp"
	label_desc = "Sharp: The Artifact's design seems to incorporate sharp elements. This will cause the artifact to pbe sharper than usual."
	flags = XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_SAFE
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
	. = ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.sharpness = old_sharp
		A.force = old_force
		A.attack_verb = old_verbs

/*
	Cooling
	Decreases the artifact's initial cooldown by XENOA_TRAIT_COOLDOWN_EXTRA_SAFE seconds
*/
/datum/xenoartifact_trait/minor/cooling
	examine_desc = "cooling"
	label_name = "Cooling"
	label_desc = "Cooling: The Artifact's design seems to incorporate cooling elements. This will cause the artifact to cooldown faster."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_EXTRA_SAFE

/*
	Sentient
	Allows ghosts to control the artifact
*/
//datum/xenoartifact_trait/minor/sentient

/*
	Delicate
	The artifact has limited uses
*/
/datum/xenoartifact_trait/minor/delicate
	examine_desc = "delicate"
	label_name = "Delicate"
	label_desc = "Delicate: The Artifact's design seems to delicate cooling elements. This will cause the artifact to potentially break."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	///Max amount of uses
	var/max_uses
	///How many uses we have left
	var/current_uses

/datum/xenoartifact_trait/minor/delicate/New(atom/_parent)
	. = ..()
	//Generate uses
	max_uses = pick(list(3, 6, 9))
	current_uses = max_uses
	//TODO: Move this to the didicated appearance proc - Racc
	var/atom/A = parent.parent
	A.alpha *= 0.7

/datum/xenoartifact_trait/minor/delicate/Destroy(force, ...)
	. = ..()
	var/atom/A = parent.parent
	A.alpha /= 0.7	

/datum/xenoartifact_trait/minor/delicate/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	playsound(get_turf(parent.parent), 'sound/effects/glass_step.ogg', 50, TRUE)
	if(current_uses)
		current_uses -= 1
	else if(prob(50)) //After we run out of uses, there is a 50% on use for it to break
		parent.cooldown_override = TRUE
		playsound(get_turf(parent.parent), 'sound/effects/glassbr1.ogg', 50, TRUE)
		//TODO: Make this calcify the artifact - Racc

/*
	Aura
	Adds nearby atoms to the target list
*/
/datum/xenoartifact_trait/minor/aura
	label_name = "Aura"
	label_desc = "Aura: The Artifact's design seems to incorporate aura elements. This will cause the artifact to target things nearby."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	cooldown = XENOA_TRAIT_COOLDOWN_DANGEROUS
	extra_target_range = 2
	///Max amount of extra targets we can have
	var/max_extra_targets = 5

/datum/xenoartifact_trait/minor/aura/trigger(datum/source, _priority, atom/override)
	. = ..()
	if(!.)
		return
	for(var/atom/target in oview(parent.target_range, get_turf(parent.parent)))
		if(length(parent.targets) > (max_extra_targets * (parent.trait_strength/100)))
			continue
		parent.register_target(target)

/*
	Scoped
	Increases target range
*/
/datum/xenoartifact_trait/minor/scoped
	examine_desc = "scoped"
	label_name = "Scoped"
	label_desc = "Scoped: The Artifact's design seems to incorporate scoped elements. This will cause the artifact to have a larger target range."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	extra_target_range = 9

/*
	Ringed
	Allows the artifact to be worn in the glove slot
*/
/datum/xenoartifact_trait/minor/ringed
	examine_desc = "ringed"
	label_name = "Ringed"
	label_desc = "Ringed: The Artifact's design seems to incorporate ringed elements. This will allow the artifact to be worn."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
	///Old wearable state
	var/old_wearable

/datum/xenoartifact_trait/minor/ringed/New(atom/_parent)
	. = ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		old_wearable = A.slot_flags
		A.slot_flags |= ITEM_SLOT_GLOVES

/datum/xenoartifact_trait/minor/ringed/Destroy(force, ...)
	. = ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.slot_flags = old_wearable

//TODO: Add item action to trigger the artifact - Racc

/*
	Shielded
	Makes the artifact act like a shield
*/
/datum/xenoartifact_trait/minor/shielded
	examine_desc = "shielded"
	label_name = "Shielded"
	label_desc = "Shielded: The Artifact's design seems to incorporate shielded elements. This will allow the artifact to be used like a shield."
	flags = XENOA_BLUESPACE_TRAIT | XENOA_PLASMA_TRAIT | XENOA_URANIUM_TRAIT | XENOA_BANANIUM_TRAIT
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
	. = ..()
	var/obj/item/A = parent.parent
	if(isitem(A))
		A.block_level = old_block_level
		A.block_power = old_block_power
		A.block_upgrade_walk = old_block_upgrade

/*
	Light
	Makes the artifact easy to throw
*/
//datum/xenoartifact_trait/minor/light

/*
	Heavy
	Makes the artifact hard to throw
*/
//datum/xenoartifact_trait/minor/heavy

