/// Adds a list of fingerprints to the atom
/atom/proc/add_fingerprint_list(list/fingerprints_to_add) //ASSOC LIST FINGERPRINT = FINGERPRINT
	if (QDELETED(src))
		return
	if (isnull(fingerprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(fingerprints = fingerprints_to_add)
	else
		forensics = new(src, fingerprints = fingerprints_to_add)
	return TRUE

/// Adds a single fingerprint to the atom
/atom/proc/add_fingerprint(mob/suspect, ignoregloves = FALSE) //Set ignoregloves to add prints irrespective of the mob having gloves on.
	if (QDELETED(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fingerprint(suspect, ignoregloves)

	blood_smear(suspect)

	return TRUE

/// Wipes blood onto the atom
/atom/proc/blood_smear(mob/living/carbon/human/suspect)
	if(!istype(suspect))
		return
	var/old_length = GET_ATOM_BLOOD_DNA_LENGTH(src)
	var/obj/item/clothing/gloves/gloves = suspect.gloves
	if(istype(gloves))
		if(gloves.transfer_blood <= 1)
			return
		add_blood_DNA(GET_ATOM_BLOOD_DNA(gloves))
		if(GET_ATOM_BLOOD_DNA_LENGTH(src) == old_length)
			return
		gloves.transfer_blood--
		suspect.visible_message(span_danger("[suspect] smears blood from [suspect.p_their()] gloves all over \the [src]!"), span_danger("You smear blood from your gloves all over \the [src]!"))
	else if(suspect.blood_in_hands > 1)
		add_blood_DNA(GET_ATOM_BLOOD_DNA(suspect))
		if(GET_ATOM_BLOOD_DNA_LENGTH(src) == old_length)
			return
		// Hands stay visibly bloody until washed, so no icon update
		suspect.blood_in_hands--
		suspect.visible_message(span_danger("[suspect] smears blood from [suspect.p_their()] hands all over \the [src]!"), span_danger("You smear blood from your hands all over \the [src]!"))

/// Add a list of fibers to the atom
/atom/proc/add_fiber_list(list/fibers_to_add) //ASSOC LIST FIBERTEXT = FIBERTEXT
	if (QDELETED(src))
		return
	if (isnull(fibers_to_add))
		return
	if (forensics)
		forensics.inherit_new(fibers = fibers_to_add)
	else
		forensics = new(src, fibers = fibers_to_add)
	return TRUE

/// Adds a single fiber to the atom
/atom/proc/add_fibers(mob/living/carbon/human/suspect)
	if (QDELETED(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_fibers(suspect)
	return TRUE

/// Adds a list of hiddenprints to the atom
/atom/proc/add_hiddenprint_list(list/hiddenprints_to_add) //NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if (QDELETED(src))
		return
	if (isnull(hiddenprints_to_add))
		return
	if (forensics)
		forensics.inherit_new(hiddenprints = hiddenprints_to_add)
	else
		forensics = new(src, hiddenprints = hiddenprints_to_add)
	return TRUE

/// Adds a single hiddenprint to the atom
/atom/proc/add_hiddenprint(mob/suspect)
	if (QDELETED(src))
		return
	if (isnull(forensics))
		forensics = new(src)
	forensics.add_hiddenprint(suspect)
	return TRUE

/// Adds blood dna to the atom
/atom/proc/add_blood_DNA(list/blood_DNA_to_add) //ASSOC LIST DNA = BLOODTYPE
	return FALSE

/obj/add_blood_DNA(list/blood_DNA_to_add)
	if (QDELETED(src))
		return
	. = ..()
	if (isnull(blood_DNA_to_add))
		return .
	if (forensics)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
	else
		forensics = new(src, blood_DNA = blood_DNA_to_add)
	return TRUE

/obj/item/add_blood_DNA(list/blood_DNA_to_add)
	if(item_flags & NO_BLOOD_ON_ITEM)
		return FALSE
	return ..()

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	transfer_blood = rand(2, 4)
	return ..()

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/blood_splatter = locate() in src
	if(!blood_splatter)
		blood_splatter = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	if(!QDELETED(blood_splatter))
		blood_splatter.add_blood_DNA(blood_dna) //give blood info to the blood decal.
		return TRUE //we bloodied the floor
	return FALSE

/turf/closed/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	return FALSE

/mob/living/carbon/human/add_blood_DNA(list/blood_DNA_to_add, list/datum/disease/diseases)
	if (QDELETED(src))
		return
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_DNA_to_add)
		update_worn_oversuit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_DNA_to_add)
		update_worn_undersuit()
	if(gloves)
		var/obj/item/clothing/gloves/mob_gloves = gloves
		mob_gloves.add_blood_DNA(blood_DNA_to_add)
	else if(length(blood_DNA_to_add))
		if (isnull(forensics))
			forensics = new(src)
		forensics.inherit_new(blood_DNA = blood_DNA_to_add)
		blood_in_hands = rand(2, 4)
	update_worn_gloves()
	return TRUE

/*
 * Transfer all the fingerprints and hidden prints from [src] to [transfer_to].
 */
/atom/proc/transfer_fingerprints_to(atom/transfer_to)
	transfer_to.add_fingerprint_list(GET_ATOM_FINGERPRINTS(src))
	transfer_to.add_hiddenprint_list(GET_ATOM_HIDDENPRINTS(src))
	transfer_to.fingerprintslast = fingerprintslast

/*
 * Transfer all the fibers from [src] to [transfer_to].
 */
/atom/proc/transfer_fibers_to(atom/transfer_to)
	transfer_to.add_fiber_list(GET_ATOM_FIBRES(src))
