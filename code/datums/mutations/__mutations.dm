/datum/mutation
	var/name = "mutation"
	/// Description of the mutation
	var/desc = "A mutation."
	/// Is this mutation currently locked?
	var/locked
	/// Quality of the mutation
	var/quality
	/// Visual indicators upon the character of the owner of this mutation
	var/static/list/visual_indicators = list()
	/// List of traits granted by this mutation
	var/list/traits
	/// The path of action we grant to our user on mutation gain
	var/datum/action/spell/power_path
	/// Which mutation layer to use
	var/layer_used = MUTATIONS_LAYER
	/// To restrict mutation to only certain species
	var/list/species_allowed
	/// Minimum health required to acquire the mutation
	var/health_req
	/// Required limbs to acquire this mutation
	var/limb_req
	/// The owner of this mutation's DNA
	var/datum/dna/dna
	/// Owner of this mutation
	var/mob/living/carbon/human/owner
	/// Instability the holder gets when the mutation is not native
	var/instability = 0
	/// Amount of those big blocks with gene sequences
	var/blocks = 4
	/// Amount of missing sequences. Sometimes it removes an entire pair for 2 points
	var/difficulty = 8
	/// Time between mutation creation and removal. If this exists, we have a timer
	var/timeout
	/// 'Mutation #49', decided every round to get some form of distinction between undiscovered mutations
	var/alias
	/// Whether we can read it if it's active. To avoid cheesing with mutagen
	var/scrambled = FALSE
	/// The class of mutation (MUT_NORMAL, MUT_EXTRA, MUT_OTHER)
	var/class
	/**
	 * any mutations that might conflict.
	 * put mutation typepath defines in here.
	 * make sure to enter it both ways (so that A conflicts with B, and B with A)
	 */
	var/list/conflicts
	var/allow_transfer  //Do we transfer upon cloning?
	/// aheal purges mutations, bad for mutations like monkey
	var/remove_on_aheal = TRUE

	/**
	 * can we take chromosomes?
	 * 0: CHROMOSOME_NEVER never
	 * 1: CHROMOSOME_NONE yeah
	 * 2: CHROMOSOME_USED no, already have one
	 */
	var/can_chromosome = CHROMOSOME_NONE
	/// Name of the chromosome
	var/chromosome_name
	/// Has the chromosome been modified
	var/modified = FALSE //ugly but we really don't want chromosomes and on_acquiring to overlap and apply double the powers
	/// Is this mutation mutadone proof
	var/mutadone_proof = FALSE

	//Chromosome stuff - set to -1 to prevent people from changing it. Example: It'd be a waste to decrease cooldown on mutism
	/// genetic stability coeff
	var/stabilizer_coeff = 1
	/// Makes the mutation hurt the user less
	var/synchronizer_coeff = -1
	/// Boosts mutation strength
	var/power_coeff = -1
	/// Lowers mutation cooldown
	var/energy_coeff = -1
	/// List of strings of valid chromosomes this mutation can accept.
	var/list/valid_chrom_list = list()

/datum/mutation/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	. = ..()
	class = class_
	if(timer)
		addtimer(CALLBACK(src, PROC_REF(remove)), timer)
		timeout = timer
	if(copymut && istype(copymut, /datum/mutation))
		copy_mutation(copymut)
	if(traits && !islist(traits))
		traits = list(traits)

/datum/mutation/proc/on_acquiring(mob/living/carbon/human/acquirer)
	if(!istype(acquirer) || acquirer.stat == DEAD || !acquirer.has_dna() || (src in acquirer.dna.mutations))
		return TRUE
	if(length(species_allowed) && !species_allowed.Find(acquirer.dna.species.id))
		return TRUE
	if(health_req && acquirer.health < health_req)
		return TRUE
	if(limb_req && !acquirer.get_bodypart(limb_req))
		return TRUE
	for(var/datum/mutation/mewtayshun as anything in acquirer.dna.mutations) //check for conflicting powers
		if(!(mewtayshun.type in conflicts) && !(type in mewtayshun.conflicts))
			continue
		to_chat(acquirer, span_warning("You feel your genes resisting something."))
		return TRUE
	owner = acquirer
	dna = acquirer.dna
	dna.mutations += src
	if(length(visual_indicators))
		var/list/mut_overlay = list(get_visual_indicator())
		for (var/mutable_appearance/ma in mut_overlay)
			ma.layer = CALCULATE_MOB_OVERLAY_LAYER(layer_used)
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
			mut_overlay |= get_visual_indicator()
		owner.remove_overlay(layer_used)
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)
	grant_power() //we do checks here so nothing about hulk getting magic
	if(!modified && can_chromosome == CHROMOSOME_USED)
		addtimer(CALLBACK(src, PROC_REF(modify), 0.5 SECONDS)) //gonna want children calling ..() to run first
	for(var/trait in traits)
		ADD_TRAIT(acquirer, trait, "[type]")

/datum/mutation/proc/get_visual_indicator()
	return

/datum/mutation/proc/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	return

/datum/mutation/proc/on_life(delta_time, times_fired)
	return

/datum/mutation/proc/on_losing(mob/living/carbon/owner)
	if(!istype(owner) || !(owner.dna.mutations.Remove(src)))
		return TRUE
	. = FALSE
	if(length(visual_indicators))
		var/list/mut_overlay = list()
		if(owner.overlays_standing[layer_used])
			mut_overlay = owner.overlays_standing[layer_used]
		owner.remove_overlay(layer_used)
		mut_overlay.Remove(get_visual_indicator())
		owner.overlays_standing[layer_used] = mut_overlay
		owner.apply_overlay(layer_used)
	if(power_path)
	// Any powers we made are linked to our mutation datum,
	// so deleting ourself will also delete it and remove it
	// ...Why don't all mutations delete on loss? Not sure.
		qdel(src)
	REMOVE_TRAITS_IN(owner, "[type]")

/mob/living/carbon/proc/update_mutations_overlay()
	return

/mob/living/carbon/human/update_mutations_overlay()
	if(!has_dna())
		return
	for(var/datum/mutation/mutation in dna.mutations)
		if(length(mutation.species_allowed) && !mutation.species_allowed.Find(dna.species.id))
			dna.force_lose(mutation) //shouldn't have that mutation at all
			continue
		if(mutation.visual_indicators.len == 0)
			continue
		var/list/mut_overlay = list()
		if(overlays_standing[mutation.layer_used])
			mut_overlay = overlays_standing[mutation.layer_used]
		var/mutable_appearance/indicator_to_add = mutation.get_visual_indicator()
		if(!mut_overlay.Find(indicator_to_add)) //either we lack the visual indicator or we have the wrong one
			remove_overlay(mutation.layer_used)
			for(var/mutable_appearance/indicator_to_remove in mutation.visual_indicators[mutation.type])
				mut_overlay.Remove(indicator_to_remove)
			mut_overlay |= indicator_to_add
			overlays_standing[mutation.layer_used] = mut_overlay
			apply_overlay(mutation.layer_used)

/**
 * Called when a chromosome is applied so we can properly update some stats
 * without having to remove and reapply the mutation from someone
 *
 * Returns `null` if no modification was done, and
 * returns an instance of a power if modification was complete
 */
/datum/mutation/proc/modify()
	if(modified || !power_path || !owner)
		return
	var/datum/action/spell/modified_power = locate(power_path) in owner.actions
	if(!modified_power)
		CRASH("Genetic mutation [type] called modify(), but could not find a action to modify!")
	modified_power.cooldown_time *= GET_MUTATION_ENERGY(src) // Doesn't do anything for mutations with energy_coeff unset
	return modified_power

/datum/mutation/proc/copy_mutation(datum/mutation/mutation_to_copy)
	if(!istype(mutation_to_copy))
		return
	chromosome_name = mutation_to_copy.chromosome_name
	stabilizer_coeff = mutation_to_copy.stabilizer_coeff
	synchronizer_coeff = mutation_to_copy.synchronizer_coeff
	power_coeff = mutation_to_copy.power_coeff
	energy_coeff = mutation_to_copy.energy_coeff
	mutadone_proof = mutation_to_copy.mutadone_proof
	can_chromosome = mutation_to_copy.can_chromosome
	valid_chrom_list = mutation_to_copy.valid_chrom_list

/datum/mutation/proc/remove_chromosome()
	stabilizer_coeff = initial(stabilizer_coeff)
	synchronizer_coeff = initial(synchronizer_coeff)
	power_coeff = initial(power_coeff)
	energy_coeff = initial(energy_coeff)
	mutadone_proof = initial(mutadone_proof)
	can_chromosome = initial(can_chromosome)
	chromosome_name = null

/datum/mutation/proc/remove()
	if(dna)
		dna.force_lose(src)
	else
		qdel(src)

/datum/mutation/proc/grant_power()
	if(!ispath(power_path) || !owner)
		return FALSE

	var/datum/action/spell/new_power = new power_path(src)
	new_power.background_icon_state = "bg_tech_blue_active"
	new_power.Grant(owner)

	return new_power

// Runs through all the coefficients and uses this to determine which chromosomes the
// mutation can take. Stores these as text strings in a list.
/datum/mutation/proc/update_valid_chromosome_list()
	valid_chrom_list.Cut()

	if(can_chromosome == CHROMOSOME_NEVER)
		valid_chrom_list += "none"
		return

	valid_chrom_list += "Reinforcement"

	if(stabilizer_coeff != -1)
		valid_chrom_list += "Stabilizer"
	if(synchronizer_coeff != -1)
		valid_chrom_list += "Synchronizer"
	if(power_coeff != -1)
		valid_chrom_list += "Power"
	if(energy_coeff != -1)
		valid_chrom_list += "Energetic"
