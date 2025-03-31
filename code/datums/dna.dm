
/////////////////////////// DNA DATUM
/datum/dna
	var/unique_enzymes
	var/uni_identity
	var/blood_type
	var/datum/species/species = new /datum/species/human //The type of mutant race the player is if applicable (i.e. potato-man)
	var/list/features = list("FFF") //first value is mutant color
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
	destination.dna.uni_identity = uni_identity
	destination.dna.blood_type = blood_type
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
	new_dna.uni_identity = uni_identity
	new_dna.blood_type = blood_type
	new_dna.features = features.Copy()
	new_dna.species = new species.type
	new_dna.real_name = real_name
	new_dna.update_body_size() //Must come after features.Copy()
	new_dna.mutations = mutations.Copy()

/datum/dna/proc/compare_dna(datum/dna/other)
	if (!other)
		return FALSE
	return unique_enzymes == other.unique_enzymes \
		&& uni_identity == other.uni_identity \
		&& blood_type == other.blood_type \
		&& species?.type == other.species?.type \
		&& real_name == other.real_name

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

/datum/dna/proc/generate_uni_identity()
	. = ""
	var/list/L = new /list(DNA_UNI_IDENTITY_BLOCKS)

	switch(holder.gender)
		if(MALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_MALE, 3)
		if(FEMALE)
			L[DNA_GENDER_BLOCK] = construct_block(G_FEMALE, 3)
		else
			L[DNA_GENDER_BLOCK] = construct_block(G_PLURAL, 3)
	if(ishuman(holder))
		var/mob/living/carbon/human/H = holder
		if(!GLOB.hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/hair,GLOB.hair_styles_list, GLOB.hair_styles_male_list, GLOB.hair_styles_female_list)
		L[DNA_HAIR_STYLE_BLOCK] = construct_block(GLOB.hair_styles_list.Find(H.hair_style), GLOB.hair_styles_list.len)
		L[DNA_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.hair_color)
		if(!GLOB.facial_hair_styles_list.len)
			init_sprite_accessory_subtypes(/datum/sprite_accessory/facial_hair, GLOB.facial_hair_styles_list, GLOB.facial_hair_styles_male_list, GLOB.facial_hair_styles_female_list)
		L[DNA_FACIAL_HAIR_STYLE_BLOCK] = construct_block(GLOB.facial_hair_styles_list.Find(H.facial_hair_style), GLOB.facial_hair_styles_list.len)
		L[DNA_FACIAL_HAIR_COLOR_BLOCK] = sanitize_hexcolor(H.facial_hair_color)
		L[DNA_SKIN_TONE_BLOCK] = construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len)
		L[DNA_EYE_COLOR_BLOCK] = sanitize_hexcolor(H.eye_color)
		L[DNA_HAIR_GRADIENT_COLOR_BLOCK] = sanitize_hexcolor(H.gradient_color)
		L[DNA_HAIR_GRADIENT_STYLE_BLOCK] = construct_block(GLOB.hair_gradients_list.Find(H.gradient_style), GLOB.hair_gradients_list.len)

	for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
		if(L[i])
			. += L[i]
		else
			. += random_string(DNA_BLOCK_SIZE,GLOB.hex_characters)
	return .

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
		var/randnum = rand(1, length_char(sequence))
		sequence = copytext_char(sequence, 1, randnum) + "X" + copytext_char(sequence, randnum + 1)
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

/datum/dna/proc/update_ui_block(blocknumber)
	if(!blocknumber || !ishuman(holder))
		return
	var/mob/living/carbon/human/H = holder
	switch(blocknumber)
		if(DNA_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.hair_color))
		if(DNA_FACIAL_HAIR_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.facial_hair_color))
		if(DNA_SKIN_TONE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.skin_tones.Find(H.skin_tone), GLOB.skin_tones.len))
		if(DNA_EYE_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.eye_color))
		if(DNA_GENDER_BLOCK)
			switch(H.gender)
				if(MALE)
					setblock(uni_identity, blocknumber, construct_block(G_MALE, 3))
				if(FEMALE)
					setblock(uni_identity, blocknumber, construct_block(G_FEMALE, 3))
				else
					setblock(uni_identity, blocknumber, construct_block(G_PLURAL, 3))
		if(DNA_FACIAL_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.facial_hair_styles_list.Find(H.facial_hair_style), GLOB.facial_hair_styles_list.len))
		if(DNA_HAIR_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.hair_styles_list.Find(H.hair_style), GLOB.hair_styles_list.len))
		if(DNA_HAIR_GRADIENT_COLOR_BLOCK)
			setblock(uni_identity, blocknumber, sanitize_hexcolor(H.gradient_color))
		if(DNA_HAIR_GRADIENT_STYLE_BLOCK)
			setblock(uni_identity, blocknumber, construct_block(GLOB.hair_gradients_list.Find(H.gradient_style), GLOB.hair_gradients_list.len))

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

/datum/dna/proc/is_same_as(datum/dna/D)
	if(uni_identity == D.uni_identity && mutation_index == D.mutation_index && real_name == D.real_name)
		if(species.type == D.species.type && features == D.features && blood_type == D.blood_type)
			return 1
	return 0

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

//used to update dna UI, UE, and dna.real_name.
/datum/dna/proc/update_dna_identity()
	uni_identity = generate_uni_identity()
	unique_enzymes = generate_unique_enzymes()

/datum/dna/proc/initialize_dna(newblood_type, skip_index = FALSE)
	if(newblood_type)
		blood_type = newblood_type
	unique_enzymes = generate_unique_enzymes()
	uni_identity = generate_uni_identity()
	if(!skip_index) //I hate this
		generate_dna_blocks()
	features = random_features(holder.gender)


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
	if((!holder || !features["body_size"] || !length(heights)) && !force)
		return

	var/desired_size = heights[features["body_size"]]

	if(desired_size == current_body_size && !force)
		return

	//Weird little fix - if height < 0, our guy gets cut off!! We can fix this by layering an invisible 64x64 icon, aka the displacement
	holder.remove_filter("height_cutoff_fix")
	holder.add_filter("height_cutoff_fix", 1, layering_filter(icon = height_displacement, color = "#ffffff00"))
	//Build / setup displacement filter
	holder.remove_filter("species_height_displacement")
	holder.add_filter("species_height_displacement", 1.1, displacement_map_filter(icon = height_displacement, y = 8, size = desired_size))

/mob/proc/set_species(datum/species/mrace, icon_update = 1)
	return

/mob/living/brain/set_species(datum/species/mrace, icon_update = 1)
	if(mrace)
		if(ispath(mrace))
			stored_dna.species = new mrace()
		else
			stored_dna.species = mrace //not calling any species update procs since we're a brain, not a monkey/human


/mob/living/carbon/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	if(mrace && has_dna())
		var/datum/species/new_race
		if(ispath(mrace))
			new_race = new mrace
		else if(istype(mrace))
			new_race = mrace
		else
			return
		deathsound = new_race.deathsound
		dna.species.on_species_loss(src, new_race, pref_load)
		var/datum/species/old_species = dna.species
		dna.species = new_race
		dna.species.on_species_gain(src, old_species, pref_load)
		SEND_SIGNAL(src, COMSIG_CARBON_SPECIESCHANGE, new_race)
		if(icon_update)
			update_mutations_overlay()// no lizard with human hulk overlay please.

/mob/living/carbon/human/set_species(datum/species/mrace, icon_update = TRUE, pref_load = FALSE)
	..()
	if(icon_update)
		update_hair()


/mob/proc/has_dna()
	return

/mob/living/carbon/has_dna()
	return dna


/mob/living/carbon/human/proc/hardset_dna(ui, list/mutation_index, newreal_name, newblood_type, datum/species/mrace, newfeatures, list/mutations, force_transfer_mutations, list/default_mutation_genes)
//Do not use force_transfer_mutations for stuff like cloners without some precautions, otherwise some conditional mutations could break (timers, drill hat etc)
	if(newfeatures)
		dna.features = newfeatures

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
		dna.uni_identity = ui
		updateappearance(icon_update=0)

	if(mrace || newfeatures || ui)
		update_body()
		update_hair()
		update_body_parts()
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
/mob/living/carbon/proc/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	if(!has_dna())
		return
	switch(deconstruct_block(getblock(dna.uni_identity, DNA_GENDER_BLOCK), 3))
		if(G_MALE)
			set_gender(MALE, TRUE, forced = TRUE)
		if(G_FEMALE)
			set_gender(FEMALE, TRUE, forced = TRUE)
		else
			set_gender(PLURAL, TRUE, forced = TRUE)

/mob/living/carbon/human/updateappearance(icon_update=1, mutcolor_update=0, mutations_overlay_update=0)
	..()
	var/structure = dna.uni_identity
	hair_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_COLOR_BLOCK))
	facial_hair_color = sanitize_hexcolor(getblock(structure, DNA_FACIAL_HAIR_COLOR_BLOCK))
	skin_tone = GLOB.skin_tones[deconstruct_block(getblock(structure, DNA_SKIN_TONE_BLOCK), GLOB.skin_tones.len)]
	eye_color = sanitize_hexcolor(getblock(structure, DNA_EYE_COLOR_BLOCK))
	facial_hair_style = GLOB.facial_hair_styles_list[deconstruct_block(getblock(structure, DNA_FACIAL_HAIR_STYLE_BLOCK), GLOB.facial_hair_styles_list.len)]
	hair_style = GLOB.hair_styles_list[deconstruct_block(getblock(structure, DNA_HAIR_STYLE_BLOCK), GLOB.hair_styles_list.len)]
	gradient_color = sanitize_hexcolor(getblock(structure, DNA_HAIR_GRADIENT_COLOR_BLOCK))
	gradient_style = GLOB.hair_gradients_list[deconstruct_block(getblock(structure, DNA_HAIR_GRADIENT_STYLE_BLOCK), GLOB.hair_gradients_list.len)]
	// Ensure we update the skin tone of all non-foreign bodyparts
	for(var/obj/item/bodypart/part in bodyparts)
		if(part.no_update)
			continue
		part.update_limb(dropping_limb = FALSE, source = src, is_creating = TRUE)
	var/obj/item/organ/eyes/organ_eyes = getorgan(/obj/item/organ/eyes)
	if(organ_eyes)
		organ_eyes.eye_color = eye_color
		organ_eyes.old_eye_color = eye_color
	if(icon_update)
		update_body()
		update_hair()
		if(mutcolor_update)
			update_body_parts()
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
/datum/dna/proc/get_mutation(A)
	for(var/datum/mutation/HM in mutations)
		if(HM.type == A)
			return HM

/datum/dna/proc/check_block_string(mutation)
	if((LAZYLEN(mutation_index) > DNA_MUTATION_BLOCKS) || !(mutation in mutation_index))
		return 0
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

/proc/getleftblocks(input,blocknumber,blocksize)
	if(blocknumber > 1)
		return copytext_char(input,1,((blocksize*blocknumber)-(blocksize-1)))

/proc/getrightblocks(input,blocknumber,blocksize)
	if(blocknumber < (length(input)/blocksize))
		return copytext_char(input,blocksize*blocknumber+1,length(input)+1)

/proc/getblock(input, blocknumber, blocksize=DNA_BLOCK_SIZE)
	return copytext_char(input, blocksize*(blocknumber-1)+1, (blocksize*blocknumber)+1)

/proc/setblock(istring, blocknumber, replacement, blocksize=DNA_BLOCK_SIZE)
	if(!istring || !blocknumber || !replacement || !blocksize)
		return 0
	return getleftblocks(istring, blocknumber, blocksize) + replacement + getrightblocks(istring, blocknumber, blocksize)

/datum/dna/proc/mutation_in_sequence(mutation)
	if(!mutation)
		return
	if(istype(mutation, /datum/mutation))
		var/datum/mutation/HM = mutation
		if(HM.type in mutation_index)
			return TRUE
	else if(mutation in mutation_index)
		return TRUE


/mob/living/carbon/proc/randmut(list/candidates, difficulty = 2)
	if(!has_dna())
		return
	var/mutation = pick(candidates)
	. = dna.add_mutation(mutation)

/mob/living/carbon/proc/easy_randmut(quality = POSITIVE + NEGATIVE + MINOR_NEGATIVE, scrambled = TRUE, sequence = TRUE, exclude_monkey = TRUE)
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

/mob/living/carbon/proc/randmuti()
	if(!has_dna())
		return
	var/num = rand(1, DNA_UNI_IDENTITY_BLOCKS)
	var/newdna = setblock(dna.uni_identity, num, random_string(DNA_BLOCK_SIZE, GLOB.hex_characters))
	dna.uni_identity = newdna
	updateappearance(mutations_overlay_update=1)

/mob/living/carbon/proc/clean_dna()
	if(!has_dna())
		return
	dna.remove_all_mutations()

/mob/living/carbon/proc/clean_randmut(list/candidates, difficulty = 2)
	clean_dna()
	randmut(candidates, difficulty)

/proc/scramble_dna(mob/living/carbon/M, ui=FALSE, se=FALSE, probability)
	if(!M.has_dna())
		return 0
	if(se)
		for(var/i=1, i<=DNA_MUTATION_BLOCKS, i++)
			if(prob(probability))
				M.dna.generate_dna_blocks()
		M.domutcheck()
	if(ui)
		for(var/i=1, i<=DNA_UNI_IDENTITY_BLOCKS, i++)
			if(prob(probability))
				M.dna.uni_identity = setblock(M.dna.uni_identity, i, random_string(DNA_BLOCK_SIZE, GLOB.hex_characters))
		M.updateappearance(mutations_overlay_update=1)
	return 1

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
				to_chat(src, span_notice("Oh, I actually feel quite alright!")) //you thought
				if(ishuman(src))
					var/mob/living/carbon/human/H = src
					H.physiology.damage_resistance = -20000
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
				for(var/obj/item/organ/O in internal_organs) //make sure we dont get an implant or cavity item
					elligible_organs += O
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
				if(prob(95))
					var/obj/item/bodypart/BP = get_bodypart(pick(BODY_ZONE_CHEST,BODY_ZONE_HEAD))
					if(BP)
						BP.dismember()
					else
						investigate_log("has been gibbed by DNA instability.", INVESTIGATE_DEATHS)
						gib()
				else
					set_species(/datum/species/dullahan)
			if(4)
				visible_message(span_warning("[src]'s skin melts off!"), span_boldwarning("Your skin melts off!"))
				spawn_gibs()
				set_species(/datum/species/skeleton)
				if(prob(90) && !QDELETED(src))
					addtimer(CALLBACK(src, PROC_REF(death)), 30)
					if(mind)
						mind.hasSoul = FALSE
			if(5)
				to_chat(src, span_phobia("LOOK UP!"))
				addtimer(CALLBACK(src, PROC_REF(something_horrible_mindmelt)), 30)


/mob/living/carbon/proc/something_horrible_mindmelt()
	if(!is_blind())
		var/obj/item/organ/eyes/eyes = locate(/obj/item/organ/eyes) in internal_organs
		if(!eyes)
			return
		eyes.Remove(src)
		qdel(eyes)
		visible_message(span_notice("[src] looks up and their eyes melt away!"), span_userdanger("I understand now."))
		addtimer(CALLBACK(src, PROC_REF(adjustOrganLoss), ORGAN_SLOT_BRAIN, 200), 20)
