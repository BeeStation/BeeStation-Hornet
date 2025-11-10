/**
 * A list of numbers that keeps track of where ui blocks start in the unique_identity string variable of the dna datum.
 * Commonly used by the datum/dna/set_uni_identity_block and datum/dna/get_uni_identity_block procs.
 */
GLOBAL_LIST_INIT(total_ui_len_by_block, populate_total_ui_len_by_block())

/proc/populate_total_ui_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/block_path in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_path]
		.[block_path] += total_block_len
		total_block_len += block.block_length

///Ditto but for unique features. Used by the datum/dna/set_uni_feature_block and datum/dna/get_uni_feature_block procs.
GLOBAL_LIST_INIT(total_uf_len_by_block, populate_total_uf_len_by_block())

/proc/populate_total_uf_len_by_block()
	. = list()
	var/total_block_len = 1
	for(var/block_path in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_path]
		.[block_path] += total_block_len
		total_block_len += block.block_length

/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes
	var/unique_identity
	var/unique_features
	var/datum/blood_type/blood_type
	var/datum/species/species = new /datum/species/human //The type of mutant race the player is if applicable (i.e. potato-man)
	/// Assoc list of feature keys to their value
	/// Note if you set these manually, and do not update [unique_features] afterwards, it will likely be reset.
	var/list/features = list(FEATURE_MUTANT_COLOR = COLOR_WHITE)
	var/real_name //Stores the real name of the person who originally got this dna datum. Used primarely for changelings,
	var/list/mutations = list()   //All mutations are from now on here
	var/list/temporary_mutations = list() //Temporary changes to the UE
	var/list/previous = list() //For temporary name/ui/ue/blood_type modifications
	var/mob/living/holder
	var/delete_species = TRUE //Set to FALSE when a body is scanned by a cloner to fix #38875
	var/mutation_index[DNA_MUTATION_BLOCKS] //List of which mutations this carbon has and its assigned block
	var/default_mutation_genes[DNA_MUTATION_BLOCKS] //List of the default genes from this mutation to allow DNA Scanner highlighting
	var/stability = 100
	var/scrambled = FALSE //Did we take something like mutagen? In that case we cant get our genes scanned to instantly cheese all the powers.
	var/current_body_size = BODY_SIZE_NORMAL
	//Holder for the displacement appearance, related to species height
	var/icon/height_displacement

/datum/dna/New(mob/living/new_holder)
	if(istype(new_holder))
		holder = new_holder
	height_displacement = icon('icons/effects/64x64.dmi', "height_displacement")

/datum/dna/Destroy()
	if(iscarbon(holder))
		var/mob/living/carbon/cholder = holder
		if(cholder?.dna == src)
			cholder.dna = null
	holder?.remove_filter("species_height_displacement")
	holder = null
	QDEL_NULL(height_displacement)

	if(delete_species)
		QDEL_NULL(species)

	mutations.Cut()					//This only references mutations, just dereference.
	temporary_mutations.Cut()		//^
	previous.Cut()					//^

	return ..()

/datum/dna/proc/transfer_identity(mob/living/carbon/destination, transfer_SE = FALSE, transfer_species = TRUE)
	if(!istype(destination))
		return
	destination.dna.unique_enzymes = unique_enzymes
	destination.dna.unique_identity = unique_identity
	destination.dna.blood_type = blood_type
	destination.dna.unique_features = unique_features
	destination.dna.features = features.Copy()
	destination.dna.real_name = real_name
	destination.dna.temporary_mutations = temporary_mutations.Copy()
	if(transfer_SE)
		destination.dna.mutation_index = mutation_index
		destination.dna.default_mutation_genes = default_mutation_genes
		for(var/datum/mutation/M as() in mutations)
			if(!istype(M, /datum/mutation/race))
				destination.dna.add_mutation(M, M.class)
	if(transfer_species)
		destination.set_species(species.type, icon_update=0)

/datum/dna/proc/copy_dna(datum/dna/new_dna)
	new_dna.unique_enzymes = unique_enzymes
	new_dna.mutation_index = mutation_index
	new_dna.default_mutation_genes = default_mutation_genes
	new_dna.unique_identity = unique_identity
	new_dna.unique_features = unique_features
	new_dna.blood_type = blood_type
	new_dna.features = features.Copy()
	//if the new DNA has a holder, transform them immediately, otherwise save it
	if(new_dna.holder)
		new_dna.holder.set_species(species.type, icon_update = 0)
	else
		new_dna.species = new species.type
	new_dna.real_name = real_name
	new_dna.update_body_size() //Must come after features.Copy()
	// Mutations aren't gc managed, but they still aren't templates
	// Let's do a proper copy
	for(var/datum/mutation/human/mutation in mutations)
		new_dna.add_mutation(mutation, mutation.class, mutation.timeout)

//See mutation.dm for what 'class' does. 'time' is time till it removes itself in decimals. 0 for no timer
/datum/dna/proc/add_mutation(mutation, class = MUT_OTHER, time)
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/HM = mutation
		mutation_type = HM.type
	if(get_mutation(mutation_type))
		return
	return force_give(new mutation_type (class, time, copymut = mutation))

/datum/dna/proc/remove_mutation(mutation_type)
	return force_lose(get_mutation(mutation_type))

/datum/dna/proc/check_mutation(mutation_type)
	return get_mutation(mutation_type)

/datum/dna/proc/remove_all_mutations(list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	remove_mutation_group(mutations, classes, mutadone)
	scrambled = FALSE

/datum/dna/proc/remove_mutation_group(list/group, list/classes = list(MUT_NORMAL, MUT_EXTRA, MUT_OTHER), mutadone = FALSE)
	if(!group)
		return
	for(var/datum/mutation/HM as() in group)
		if((HM.class in classes) && !(HM.mutadone_proof && mutadone))
			force_lose(HM)

/datum/dna/proc/generate_unique_identity()
	. = ""
	for(var/block_type in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_type]
		. += block.unique_block(holder)

/datum/dna/proc/generate_unique_features()
	. = ""
	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_type]
		if(isnull(features[block.feature_key]))
			. += random_string(block.block_length, GLOB.hex_characters)
			continue
		. += block.unique_block(holder)

/datum/dna/proc/generate_dna_blocks()
	var/list/mutations_temp = GLOB.good_mutations + GLOB.bad_mutations + GLOB.not_good_mutations
	if(species?.inert_mutation)
		mutations_temp += GET_INITIALIZED_MUTATION(species.inert_mutation)
	if(!LAZYLEN(mutations_temp))
		return
	mutation_index.Cut()
	default_mutation_genes.Cut()
	shuffle_inplace(mutations_temp)
	if(ismonkey(holder))
		mutations |= new /datum/mutation/race(MUT_NORMAL)
		mutation_index[/datum/mutation/race] = GET_SEQUENCE(/datum/mutation/race)
	else
		mutation_index[/datum/mutation/race] = create_sequence(/datum/mutation/race, FALSE)
	default_mutation_genes[/datum/mutation/race] = mutation_index[/datum/mutation/race]
	for(var/i in 2 to DNA_MUTATION_BLOCKS)
		var/datum/mutation/M = mutations_temp[i]
		mutation_index[M.type] = create_sequence(M.type, FALSE, M.difficulty)
		default_mutation_genes[M.type] = mutation_index[M.type]
	shuffle_inplace(mutation_index)

//Used to generate original gene sequences for every mutation
/proc/generate_gene_sequence(length=4)
	var/static/list/active_sequences = list("AT","TA","GC","CG")
	var/sequence
	for(var/i in 1 to length*DNA_SEQUENCE_LENGTH)
		sequence += pick(active_sequences)
	return sequence

//Used to create a chipped gene sequence
/proc/create_sequence(mutation, active, difficulty)
	if(!difficulty)
		var/datum/mutation/A = GET_INITIALIZED_MUTATION(mutation) //leaves the possibility to change difficulty mid-round
		if(!A)
			return
		difficulty = A.difficulty
	difficulty += rand(-2,4)
	var/sequence = GET_SEQUENCE(mutation)
	if(active)
		return sequence
	while(difficulty)
		var/randnum = rand(1, length(sequence))
		sequence = copytext(sequence, 1, randnum) + "X" + copytext(sequence, randnum + 1)
		difficulty--
	return sequence

/datum/dna/proc/generate_unique_enzymes()
	. = ""
	if(istype(holder))
		real_name = holder.real_name
		. += rustg_hash_string(RUSTG_HASH_MD5, holder.real_name)
	else
		. += random_string(DNA_UNIQUE_ENZYMES_LEN, GLOB.hex_characters)
	return .

///Setter macro used to modify unique features blocks.
/datum/dna/proc/set_uni_feature_block(blocknum, input)
	var/precesing_blocks = copytext(unique_features, 1, GLOB.total_uf_len_by_block[blocknum])
	var/succeeding_blocks = blocknum < GLOB.total_uf_len_by_block.len ? copytext(unique_features, GLOB.total_uf_len_by_block[blocknum+1]) : ""
	unique_features = precesing_blocks + input + succeeding_blocks

/datum/dna/proc/update_ui_block(blocktype)
	if(isnull(blocktype))
		CRASH("UI block type is null")
	if(!iscarbon(holder))
		CRASH("Attempted to update DNA UI of a non-carbon, this is not supported!")

	var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[blocktype]
	unique_identity = block.modified_hash(unique_identity, block.unique_block(holder))

/datum/dna/proc/update_uf_block(blocktype)
	if(!blocktype)
		CRASH("UF block type is null")
	if(!iscarbon(holder))
		CRASH("Non-carbon mobs shouldn't have DNA")
	var/datum/dna_block/feature/block = GLOB.dna_identity_blocks[blocktype]
	unique_features = block.modified_hash(unique_features, block.unique_block(holder))

//Please use add_mutation or activate_mutation instead
/datum/dna/proc/force_give(datum/mutation/HM)
	if(holder && HM)
		if(HM.class == MUT_NORMAL)
			set_se(TRUE, HM)
		. = HM.on_acquiring(holder)
		if(.)
			qdel(HM)
		update_instability()

//Use remove_mutation instead
/datum/dna/proc/force_lose(datum/mutation/HM)
	if(holder && (HM in mutations))
		set_se(FALSE, HM)
		. = HM.on_losing(holder)
		update_instability(FALSE)
		return

/**
 * Checks if two DNAs are practically the same by comparing their most defining features
 *
 * Arguments:
 * * target_dna The DNA that we are comparing to
 */
/datum/dna/proc/is_same_as(datum/dna/target_dna)
	if( \
		unique_identity == target_dna.unique_identity \
		&& mutation_index == target_dna.mutation_index \
		&& real_name == target_dna.real_name \
		&& species.type == target_dna.species.type \
		&& compare_list(features, target_dna.features) \
		&& blood_type == target_dna.blood_type \
	)
		return TRUE

	return FALSE

/datum/dna/proc/update_instability(alert=TRUE)
	stability = 100
	for(var/datum/mutation/M as() in mutations)
		if(M.class == MUT_EXTRA)
			stability -= M.instability * GET_MUTATION_STABILIZER(M)
	if(holder)
		var/message
		if(alert)
			switch(stability)
				if(1 to 19)
					message = span_warning("You can feel your cells burning.")
				if(-INFINITY to 0)
					message = span_boldwarning("You can feel your DNA exploding, we need to do something fast!")
		if(stability <= 0)
			holder.apply_status_effect(/datum/status_effect/dna_melt)
		if(message)
			to_chat(holder, message)

/// Updates the UI, UE, and UF of the DNA according to the features, appearance, name, etc. of the DNA / holder.
/datum/dna/proc/update_dna_identity()
	if(!holder.has_dna())
		return
	unique_identity = generate_unique_identity()
	unique_features = generate_unique_features()
	unique_enzymes = generate_unique_enzymes()

/**
 * Sets up DNA codes and initializes some features.
 *
 * * newblood_type - Optional, the blood type to set the DNA to
 * * create_mutation_blocks - If true, generate_dna_blocks is called, which is used to set up mutation blocks (what a mob can naturally mutate).
 * * randomize_features - If true, all entries in the features list will be randomized.
 */
/datum/dna/proc/initialize_dna(newblood_type = random_blood_type(), create_mutation_blocks = TRUE, randomize_features = TRUE)
	if(newblood_type)
		blood_type = newblood_type
	if(create_mutation_blocks) //I hate this
		generate_dna_blocks()
	if(randomize_features)
		for(var/species_type in GLOB.species_prototypes)
			var/list/new_features = GLOB.species_prototypes[species_type].randomize_features()
			for(var/feature in new_features)
				features[feature] = new_features[feature]

		features[FEATURE_MUTANT_COLOR] = "#[random_color()]"

	update_dna_identity()


/datum/dna/stored //subtype used by brain mob's stored_dna

/datum/dna/stored/add_mutation(mutation_name) //no mutation changes on stored dna.
	return

/datum/dna/stored/remove_mutation(mutation_name)
	return

/datum/dna/stored/check_mutation(mutation_name)
	return

/datum/dna/stored/remove_all_mutations(list/classes, mutadone = FALSE)
	return

/datum/dna/stored/remove_mutation_group(list/group)
	return

/////////////////////////// DNA MOB-PROCS //////////////////////
/datum/dna/proc/update_body_size(force)
	var/list/heights = species?.get_species_height()
	if((!holder || !features[FEATURE_BODY_SIZE] || !length(heights)) && !force)
		return

	var/desired_size = heights[features[FEATURE_BODY_SIZE]]

	if(desired_size == current_body_size && !force)
		return

	//Weird little fix - if height < 0, our guy gets cut off!! We can fix this by layering an invisible 64x64 icon, aka the displacement
	holder.remove_filter("height_cutoff_fix")
	holder.add_filter("height_cutoff_fix", 1, layering_filter(icon = height_displacement, color = "#ffffff00"))
	//Build / setup displacement filter
	holder.remove_filter("species_height_displacement")
	holder.add_filter("species_height_displacement", 1.1, displacement_map_filter(icon = height_displacement, y = 8, size = desired_size))

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	SHOULD_NOT_SLEEP(TRUE)
	return

/mob/living/brain/set_species(datum/species/mrace, icon_update = 1)
	if(mrace)
		if(ispath(mrace))
			stored_dna.species = new mrace()
		else
			stored_dna.species = mrace //not calling any species update procs since we're a brain, not a monkey/human


/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	if(QDELETED(src))
		CRASH("You're trying to change your species post deletion, this is a recipe for madness")
	if(isnull(mrace))
		CRASH("set_species called without a species to set to")
	if(!has_dna())
		return

	var/datum/species/new_race
	if(ispath(mrace))
		new_race = new mrace
	else if(istype(mrace))
		if(QDELING(mrace))
			CRASH("someone is calling set_species() and is passing it a qdeling species datum, this is VERY bad, stop it")
		new_race = mrace
	else
		CRASH("set_species called with an invalid mrace [mrace]")

	deathsound = new_race.death_sound

	var/datum/species/old_species = dna.species
	dna.species = new_race

	if (old_species.properly_gained)
		old_species.on_species_loss(src, new_race, pref_load)

	dna.species.on_species_gain(src, old_species, pref_load, regenerate_icons = icon_update)
	SEND_SIGNAL(src, COMSIG_CARBON_SPECIESCHANGE, new_race)

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	..()
	if(icon_update)
		update_body(is_creating = TRUE)
		update_mutations_overlay()// no lizard with human hulk overlay please.


/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna

/// Returns TRUE if the mob is allowed to mutate via its DNA, or FALSE if otherwise.
/// Only an organic Carbon with valid DNA may mutate; not robots, AIs, aliens, Ians, or other mobs.
/mob/proc/can_mutate()
	return FALSE

/mob/living/carbon/can_mutate()
	if(!(mob_biotypes & MOB_ORGANIC))
		return FALSE
	if(has_dna() && !HAS_TRAIT(src, TRAIT_GENELESS) && !HAS_TRAIT(src, TRAIT_BADDNA))
		return TRUE

/mob/living/carbon/human/proc/hardset_dna(ui, list/mutation_index, newreal_name, newblood_type, datum/species/mrace, newfeatures, list/mutations, force_transfer_mutations, list/default_mutation_genes)
//Do not use force_transfer_mutations for stuff like cloners without some precautions, otherwise some conditional mutations could break (timers, drill hat etc)
	if(newfeatures)
		dna.features = newfeatures
		dna.generate_unique_features()

	if(mrace)
		var/datum/species/newrace = new mrace.type
		newrace.copy_properties_from(mrace)
		set_species(newrace, icon_update=0)

	if(LAZYLEN(mutation_index))
		dna.mutation_index = mutation_index.Copy()
		if(LAZYLEN(default_mutation_genes))
			dna.default_mutation_genes = default_mutation_genes.Copy()
		else
			dna.default_mutation_genes = mutation_index.Copy()
		domutcheck()

	if(newreal_name)
		real_name = newreal_name
		dna.generate_unique_enzymes()

	if(newblood_type)
		dna.blood_type = newblood_type

	if(ui)
		dna.unique_identity = ui
		//TODO: Existing update_appearance bug that can alter players preferences vs ingame appearance, not optimal solution
		// Don't call updateappearance() - it decodes DNA blocks and overwrites dna.features and organ appearances
		// This function is used for respawning, and the features are already set correctly above
		// updateappearance() is only needed for mutations/cloning when DNA blocks should override current state
		// updateappearance(icon_update=0)

	if(mrace || newfeatures || ui)
		update_body(is_creating = TRUE)
		update_mutations_overlay()

	if(LAZYLEN(mutations))
		for(var/datum/mutation/HM as() in mutations)
			if(HM.allow_transfer || force_transfer_mutations)
				dna.force_give(new HM.type(HM.class, copymut=HM)) //using force_give since it may include exotic mutations that otherwise wont be handled properly

/mob/living/carbon/proc/create_dna()
	dna = new /datum/dna(src)
	if(!dna.species)
		var/rando_race = pick(get_selectable_species())
		dna.species = new rando_race()

//proc used to update the mob's appearance after its dna UI has been changed
//2025: Im unsure if dna is meant to be living, carbon, or human level.. there's contradicting stuff and bugfixes going back 8 years
//If youre reading this, and you know for sure, update this, or maybe remove the carbon part entirely
/mob/living/carbon/proc/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	if(!has_dna())
		return

/mob/living/carbon/human/updateappearance(icon_update = TRUE, mutcolor_update = FALSE, mutations_overlay_update = FALSE)
	. = ..()
	for(var/block_type in GLOB.dna_identity_blocks)
		var/datum/dna_block/identity/block_to_apply = GLOB.dna_identity_blocks[block_type]
		block_to_apply.apply_to_mob(src, dna.unique_identity)

	for(var/block_type in GLOB.dna_feature_blocks)
		var/datum/dna_block/feature/block_to_apply = GLOB.dna_feature_blocks[block_type]
		if(dna.features[block_to_apply.feature_key])
			block_to_apply.apply_to_mob(src, dna.unique_features)

	for(var/obj/item/organ/organ in organs)
		organ.mutate_feature(dna.unique_features, src)

	if(icon_update)
		update_body(is_creating = mutcolor_update)
	if(mutations_overlay_update)
		update_mutations_overlay()

/mob/proc/domutcheck()
	return

/mob/living/carbon/domutcheck()
	if(!has_dna())
		return

	for(var/mutation in dna.mutation_index)
		if(ismob(dna.check_block(mutation)))
			return //we got monkeyized/humanized, this mob will be deleted, no need to continue.

	update_mutations_overlay()

/datum/dna/proc/check_block(mutation)
	var/datum/mutation/HM = get_mutation(mutation)
	if(check_block_string(mutation))
		if(!HM)
			. = add_mutation(mutation, MUT_NORMAL)
		return
	return force_lose(HM)

//Return the active mutation of a type if there is one
/datum/dna/proc/get_mutation(mutation_path)
	for(var/datum/mutation/mutation in mutations)
		if(mutation.type == mutation_path)
			return mutation

/datum/dna/proc/check_block_string(mutation)
	if((LAZYLEN(mutation_index) > DNA_MUTATION_BLOCKS) || !(mutation in mutation_index))
		return FALSE
	return is_gene_active(mutation)

/datum/dna/proc/is_gene_active(mutation)
	return (mutation_index[mutation] == GET_SEQUENCE(mutation))

/datum/dna/proc/set_se(on=TRUE, datum/mutation/HM)
	if(!HM || !(HM.type in mutation_index) || (LAZYLEN(mutation_index) < DNA_MUTATION_BLOCKS))
		return
	. = TRUE
	if(on)
		mutation_index[HM.type] = GET_SEQUENCE(HM.type)
		default_mutation_genes[HM.type] = mutation_index[HM.type]
	else if(GET_SEQUENCE(HM.type) == mutation_index[HM.type])
		mutation_index[HM.type] = create_sequence(HM.type, FALSE, HM.difficulty)
		default_mutation_genes[HM.type] = mutation_index[HM.type]

/datum/dna/proc/activate_mutation(mutation) //note that this returns a boolean and not a new mob
	if(!mutation)
		return FALSE
	var/mutation_type = mutation
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/M = mutation
		mutation_type = M.type
	if(!mutation_in_sequence(mutation_type)) //cant activate what we dont have, use add_mutation
		return FALSE
	add_mutation(mutation, MUT_NORMAL)
	return TRUE

/////////////////////////// DNA HELPER-PROCS //////////////////////////////

/datum/dna/proc/mutation_in_sequence(mutation)
	if(!mutation)
		return
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/HM = mutation
		if(HM.type in mutation_index)
			return TRUE
	else if(mutation in mutation_index)
		return TRUE


/mob/living/carbon/proc/random_mutate(list/candidates, difficulty = 2)
	if(!has_dna())
		return
	var/mutation = pick(candidates)
	. = dna.add_mutation(mutation)

/mob/living/carbon/proc/easy_random_mutate(quality = POSITIVE + NEGATIVE + MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, exclude_monkey = TRUE)
	if(!has_dna())
		return
	var/list/mutations = list()
	if(quality & POSITIVE)
		mutations += GLOB.good_mutations
	if(quality & NEGATIVE)
		mutations += GLOB.bad_mutations
	if(quality & MINOR_NEGATIVE)
		mutations += GLOB.not_good_mutations
	var/list/possible = list()
	for(var/datum/mutation/A as() in mutations)
		if((!sequence || dna.mutation_in_sequence(A.type)) && !dna.get_mutation(A.type))
			possible += A.type
	if(exclude_monkey)
		possible.Remove(/datum/mutation/race)
	if(LAZYLEN(possible))
		var/mutation = pick(possible)
		. = dna.activate_mutation(mutation)
		if(scrambled)
			var/datum/mutation/HM = dna.get_mutation(mutation)
			if(HM)
				HM.scrambled = TRUE
		return TRUE

/mob/living/carbon/proc/random_mutate_unique_identity()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutblock_path = pick(GLOB.dna_identity_blocks)
	var/datum/dna_block/identity/mutblock = GLOB.dna_identity_blocks[mutblock_path]
	dna.unique_identity = mutblock.modified_hash(dna.unique_identity, random_string(mutblock.block_length, GLOB.hex_characters))
	updateappearance(mutations_overlay_update = TRUE)

/mob/living/carbon/proc/random_mutate_unique_features()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	var/mutblock_path = pick(GLOB.dna_feature_blocks)
	var/datum/dna_block/feature/mutblock = GLOB.dna_feature_blocks[mutblock_path]
	dna.unique_features = mutblock.modified_hash(dna.unique_features, random_string(mutblock.block_length, GLOB.hex_characters))
	updateappearance(mutcolor_update = TRUE, mutations_overlay_update = TRUE)

/mob/living/carbon/proc/clean_dna()
	if(!has_dna())
		CRASH("[src] does not have DNA")
	dna.remove_all_mutations()

/mob/living/carbon/proc/clean_random_mutate(list/candidates, difficulty = 2)
	clean_dna()
	random_mutate(candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui = FALSE, se = FALSE, uf = FALSE, probability = 100)
	if(!M.has_dna())
		CRASH("[M] does not have DNA")
	if(se)
		for(var/i=1, i<=DNA_MUTATION_BLOCKS, i++)
			if(prob(probability))
				M.dna.generate_dna_blocks()
		M.domutcheck()
	if(ui)
		for(var/block_id in GLOB.dna_identity_blocks)
			var/datum/dna_block/identity/block = GLOB.dna_identity_blocks[block_id]
			if(prob(probability))
				M.dna.unique_identity = block.modified_hash(M.dna.unique_identity, random_string(block.block_length, GLOB.hex_characters))
	if(uf)
		for(var/block_id in GLOB.dna_feature_blocks)
			var/datum/dna_block/feature/block = GLOB.dna_feature_blocks[block_id]
			if(prob(probability))
				M.dna.unique_identity = block.modified_hash(M.dna.unique_identity, random_string(block.block_length, GLOB.hex_characters))
	if(ui || uf)
		M.updateappearance(mutcolor_update=uf, mutations_overlay_update=1)

//value in range 1 to values. values must be greater than 0
//all arguments assumed to be positive integers
/proc/construct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	if(value < 1)
		value = 1
	value = (value * width) - rand(1,width)
	return num2hex(value, blocksize)

//value is hex
/proc/deconstruct_block(value, values, blocksize=DNA_BLOCK_SIZE)
	var/width = round((16**blocksize)/values)
	value = round(hex2num(value) / width) + 1
	if(value > values)
		value = values
	return value

/////////////////////////// DNA HELPER-PROCS

/mob/living/carbon/proc/something_horrible(ignore_stability)
	if(!has_dna()) //shouldn't ever happen anyway so it's just in really weird cases
		return
	if(!ignore_stability && (dna.stability > 0))
		return
	var/instability = -dna.stability
	dna.remove_all_mutations()
	dna.stability = 100
	if(prob(max(70-instability,0)))
		switch(rand(0,10)) //not complete and utter death
			if(0)
				teratomize()
			if(1)
				gain_trauma(/datum/brain_trauma/severe/paralysis/paraplegic)
				new/obj/vehicle/ridden/wheelchair(get_turf(src)) //don't buckle, because I can't imagine to plethora of things to go through that could otherwise break
				to_chat(src, span_warning("My flesh turned into a wheelchair and I can't feel my legs."))
			if(2)
				corgize()
			if(3)
				to_chat(src, span_notice("Oh, I actually feel quite alright!"))
			if(4)
				to_chat(src, span_notice("Oh, I actually feel quite alright!"))
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					H.physiology.damage_resistance -= 20000 //you thought
			if(5)
				to_chat(src, span_notice("Oh, I actually feel quite alright!"))
				reagents.add_reagent(/datum/reagent/aslimetoxin, 10)
			if(6)
				apply_status_effect(/datum/status_effect/go_away)
			if(7)
				to_chat(src, span_notice("Oh, I actually feel quite alright!"))
				ForceContractDisease(new/datum/disease/decloning()) //slow acting, non-viral clone damage based GBS
			if(8)
				var/list/elligible_organs = list()
				for(var/obj/item/organ/internal_organ as anything in organs) //make sure we dont get an implant or cavity item
					elligible_organs += internal_organ
				vomit(20, TRUE)
				if(length(elligible_organs))
					var/obj/item/organ/O = pick(elligible_organs)
					O.Remove(src)
					visible_message(span_danger("[src] vomits up [p_their()] [O.name]!"), span_danger("You vomit up your [O.name]!")) //no "vomit up your the heart"
					O.forceMove(drop_location())
					if(prob(20))
						O.animate_atom_living()
			if(9 to 10)
				ForceContractDisease(new/datum/disease/gastrolosis())
				to_chat(src, span_notice("Oh, I actually feel quite alright!"))
	else
		switch(rand(0,5))
			if(0)
				investigate_log("has been gibbed by DNA instability.", INVESTIGATE_DEATHS)
				gib()
			if(1)
				investigate_log("has been dusted by DNA instability.", INVESTIGATE_DEATHS)
				dust()

			if(2)
				investigate_log("has been killed by DNA instability.", INVESTIGATE_DEATHS)
				death()
				petrify(INFINITY)
			if(3)
				var/obj/item/bodypart/BP = get_bodypart(pick(BODY_ZONE_CHEST,BODY_ZONE_HEAD))
				if(BP)
					BP.dismember()
				else
					investigate_log("has been gibbed by DNA instability.", INVESTIGATE_DEATHS)
					gib()
			if(4)
				visible_message(span_warning("[src]'s skin melts off!"), span_boldwarning("Your skin melts off!"))
				spawn_gibs()
				set_species(/datum/species/skeleton)
				if(prob(90) && !QDELETED(src))
					addtimer(CALLBACK(src, PROC_REF(death)), 30)
			if(5)
				to_chat(src, span_phobia("LOOK UP!"))
				addtimer(CALLBACK(src, PROC_REF(something_horrible_mindmelt)), 30)

/mob/living/carbon/proc/something_horrible_mindmelt()
	if(!is_blind())
		var/obj/item/organ/eyes/eyes = locate(/obj/item/organ/eyes) in organs
		if(!eyes)
			return
		eyes.Remove(src)
		qdel(eyes)
		visible_message(span_notice("[src] looks up and their eyes melt away!"), span_userdanger("I understand now."))
		addtimer(CALLBACK(src, PROC_REF(adjustOrganLoss), ORGAN_SLOT_BRAIN, 200), 20)
