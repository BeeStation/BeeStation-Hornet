//CONTAINS: Suit fibers and Detective's Scanning Computer

/atom/proc/return_fingerprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.fingerprints

/atom/proc/return_hiddenprints()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.hiddenprints

/atom/proc/return_blood_DNA()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.blood_DNA

/atom/proc/blood_DNA_length()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = length(D.blood_DNA)

/atom/proc/return_fibers()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.fibers

/atom/proc/return_souls()
	var/datum/component/forensics/D = GetComponent(/datum/component/forensics)
	if(D)
		. = D.souls

/atom/proc/add_fingerprint_list(list/fingerprints)		//ASSOC LIST FINGERPRINT = FINGERPRINT
	if(length(fingerprints))
		. = AddComponent(/datum/component/forensics, fingerprints)

//Set ignoregloves to add prints irrespective of the mob having gloves on.
/atom/proc/add_fingerprint(mob/M, ignoregloves = FALSE)
	if(QDELING(src))
		return
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D?.add_fingerprint(M, ignoregloves)

	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	///the current amount of blood on the thing
	var/old_blood = blood_DNA_length()
	if(H.gloves && isclothing(H.gloves))
		var/obj/item/clothing/gloves/G = H.gloves
		if(G.transfer_blood > 1 && G.blood_DNA_length() > old_blood) //bloodied gloves transfer blood to touched objects
			if(add_blood_DNA(G.return_blood_DNA()))
				G.transfer_blood--
				H.visible_message(span_danger("[H] smears blood from [H.p_their()] gloves all over \the [src]!"), span_danger("You smear blood from your gloves all over \the [src]!"))
	else if(H.blood_in_hands > 1)
		if(add_blood_DNA(H.return_blood_DNA()) && H.blood_DNA_length() > old_blood) //if the onject you're touching is already drenched in blood, the blood from your hands won't get used up again
			H.blood_in_hands-- //we don't update icon after so you still have to wash your hands off, I don't think you'd be able to completely wipe your hands off just on the floor
			H.visible_message(span_danger("[H] smears blood from [H.p_their()] hands all over \the [src]!"), span_danger("You smear blood from your hands all over \the [src]!"))

/atom/proc/add_fiber_list(list/fibertext)				//ASSOC LIST FIBERTEXT = FIBERTEXT
	if(length(fibertext))
		. = AddComponent(/datum/component/forensics, null, null, null, fibertext)

/atom/proc/add_fibers(mob/living/carbon/human/M)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_fibers(M)

/atom/proc/add_hiddenprint_list(list/hiddenprints)	//NOTE: THIS IS FOR ADMINISTRATION FINGERPRINTS, YOU MUST CUSTOM SET THIS TO INCLUDE CKEY/REAL NAMES! CHECK FORENSICS.DM
	if(length(hiddenprints))
		. = AddComponent(/datum/component/forensics, null, hiddenprints)

/atom/proc/add_hiddenprint(mob/M)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_hiddenprint(M)

/atom/proc/add_blood_DNA(list/dna)						//ASSOC LIST DNA = BLOODTYPE
	return FALSE

/atom/proc/add_soul_list(list/souls)
	if(length(souls))
		. = AddComponent(/datum/component/forensics, null, null, null, null, souls)

/atom/proc/add_soul(mob/living/carbon/human/M)
	var/datum/component/forensics/D = AddComponent(/datum/component/forensics)
	. = D.add_soul(M)

/obj/add_blood_DNA(list/dna)
	. = ..()
	if(length(dna) && !QDELETED(src))
		. = AddComponent(/datum/component/forensics, null, null, dna)

/obj/item/clothing/gloves/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	transfer_blood = rand(2, 4)

/turf/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	var/obj/effect/decal/cleanable/blood/splatter/B = locate() in src
	if(!B)
		B = new /obj/effect/decal/cleanable/blood/splatter(src, diseases)
	if(!QDELETED(B))
		B.add_blood_DNA(blood_dna) //give blood info to the blood decal.
		return TRUE //we bloodied the floor

/mob/living/carbon/human/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	if(wear_suit)
		wear_suit.add_blood_DNA(blood_dna)
		update_worn_oversuit()
	else if(w_uniform)
		w_uniform.add_blood_DNA(blood_dna)
		update_worn_undersuit()
	if(gloves)
		var/obj/item/clothing/gloves/G = gloves
		G.add_blood_DNA(blood_dna)
	else if(length(blood_dna))
		AddComponent(/datum/component/forensics, null, null, blood_dna)
		blood_in_hands = rand(2, 4)
	update_worn_gloves()	//handles bloody hands overlays and updating
	return TRUE

/obj/effect/decal/cleanable/blood/add_blood_DNA(list/blood_dna, list/datum/disease/diseases)
	. = ..()
	if(blood_dna)
		color = get_blood_dna_color(blood_dna)

/atom/proc/transfer_fingerprints_to(atom/A)
	A.add_fingerprint_list(return_fingerprints())
	A.add_hiddenprint_list(return_hiddenprints())
	A.fingerprintslast = fingerprintslast
