/datum/mutation
	var/name = "mutation"
	var/desc = "A mutation."
	var/locked
	var/quality
	var/static/list/visual_indicators = list()
	var/list/traits
	var/layer_used = MUTATIONS_LAYER //which mutation layer to use
	var/datum/action/spell/power_path /// The path of action we grant to our user on mutation gain
	var/list/species_allowed = list() //to restrict mutation to only certain species
	var/list/mobtypes_allowed = list() //to restrict mutation to only certain mobs
	var/health_req //minimum health required to acquire the mutation
	var/limb_req //required limbs to acquire this mutation
	var/datum/dna/dna
	var/mob/living/carbon/owner
	var/instability = 0 //instability the holder gets when the mutation is not native
	var/blocks = 4 //Amount of those big blocks with gene sequences
	var/difficulty = 8 //Amount of missing sequences. Sometimes it removes an entire pair for 2 points
	var/timeout //Time between mutation creation and removal. If this exists, we have a timer
	var/alias           //'Mutation #49', decided every round to get some form of distinction between undiscovered mutations
	var/scrambled = FALSE //Wheter we can read it if it's active. To avoid cheesing with mutagen
	var/class           //Decides player accesibility, sorta
	var/list/conflicts //any mutations that might conflict. put mutation typepath defines in here. make sure to enter it both ways (so that A conflicts with B, and B with A)
	var/allow_transfer  //Do we transfer upon cloning?
		/// Message given to the user upon gaining this mutation
	var/text_gain_indication = ""
	/// Message given to the user upon losing this mutation
	var/text_lose_indication = ""
	//MUT_NORMAL - A mutation that can be activated and deactived by completing a sequence
	//MUT_EXTRA - A mutation that is in the mutations tab, and can be given and taken away through though the DNA console. Has a 0 before it's name in the mutation section of the dna console
	//MUT_OTHER Cannot be interacted with by players through normal means. I.E. wizards mutate
	var/list/valid_chrom_list = list() //List of strings of valid chromosomes this mutation can accept.


	var/can_chromosome = CHROMOSOME_NONE //can we take chromosomes? 0: CHROMOSOME_NEVER never,  1:CHROMOSOME_NONE yeah, 2: CHROMOSOME_USED no, already have one
	var/chromosome_name   //purely cosmetic
	var/modified = FALSE  //ugly but we really don't want chromosomes and on_acquiring to overlap and apply double the powers
	var/mutadone_proof = FALSE

	//Chromosome stuff - set to -1 to prevent people from changing it. Example: It'd be a waste to decrease cooldown on mutism
	var/stabilizer_coeff = 1 //genetic stability coeff
	var/synchronizer_coeff = -1 //makes the mutation hurt the user less
	var/power_coeff = -1 //boosts mutation strength
	var/energy_coeff = -1 //lowers mutation cooldown

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

/datum/mutation/proc/on_acquiring(mob/living/carbon/C)
	if(!istype(C) || C.stat == DEAD || !C.has_dna() || (src in C.dna.mutations))
		return TRUE
	if(length(mobtypes_allowed) && !mobtypes_allowed.Find(C.type))
		return TRUE
	if(length(species_allowed) && !species_allowed.Find(C.dna.species.id))
		return TRUE
	if(health_req && C.health < health_req)
		return TRUE
	if(limb_req && !C.get_bodypart(limb_req))
		return TRUE
	for(var/datum/mutation/M as() in C.dna.mutations)//check for conflicting powers
		if(!(M.type in conflicts) && !(type in M.conflicts))
			continue
		to_chat(C, span_warning("You feel your genes resisting something."))
		return TRUE
	owner = C
	dna = C.dna
	dna.mutations += src
	if(text_gain_indication)
		to_chat(owner, text_gain_indication)
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
		addtimer(CALLBACK(src, PROC_REF(modify), 5)) //gonna want children calling ..() to run first
	RegisterSignal(owner, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	for(var/trait in traits)
		ADD_TRAIT(C, trait, "[type]")

/datum/mutation/proc/get_visual_indicator()
	return

/datum/mutation/proc/on_attack_hand(atom/target, proximity)
	return

/datum/mutation/proc/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	return

/datum/mutation/proc/on_move(new_loc)
	SIGNAL_HANDLER
	return

/datum/mutation/proc/on_life(delta_time, times_fired)
	return

/datum/mutation/proc/on_losing(mob/living/carbon/owner)
	if(istype(owner) && (owner.dna.mutations.Remove(src)))
		if(text_lose_indication && owner.stat != DEAD)
			to_chat(owner, text_lose_indication)
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
		UnregisterSignal(owner, COMSIG_MOVABLE_MOVED)
		REMOVE_TRAITS_IN(owner, "[type]")
		return FALSE
	return TRUE

/mob/living/carbon/proc/update_mutations_overlay()
	if(!has_dna())
		return
	for(var/datum/mutation/CM as() in dna.mutations)
		if(length(CM.mobtypes_allowed) && !CM.mobtypes_allowed.Find(src.type))
			dna.force_lose(CM)
			continue
		if(length(CM.species_allowed) && !CM.species_allowed.Find(dna.species.id))
			dna.force_lose(CM) //shouldn't have that mutation at all
			continue
		if(length(CM.visual_indicators))
			var/list/mut_overlay = list()
			if(overlays_standing[CM.layer_used])
				mut_overlay = overlays_standing[CM.layer_used]
			var/mutable_appearance/V = CM.get_visual_indicator()
			if(!mut_overlay.Find(V)) //either we lack the visual indicator or we have the wrong one
				remove_overlay(CM.layer_used)
				for(var/mutable_appearance/MA in CM.visual_indicators[CM.type])
					mut_overlay.Remove(MA)
				mut_overlay |= V
				overlays_standing[CM.layer_used] = mut_overlay
				apply_overlay(CM.layer_used)

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

/datum/mutation/proc/copy_mutation(datum/mutation/HM)
	if(!istype(HM))
		return
	chromosome_name = HM.chromosome_name
	stabilizer_coeff = HM.stabilizer_coeff
	synchronizer_coeff = HM.synchronizer_coeff
	power_coeff = HM.power_coeff
	energy_coeff = HM.energy_coeff
	mutadone_proof = HM.mutadone_proof
	can_chromosome = HM.can_chromosome
	valid_chrom_list = HM.valid_chrom_list

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
