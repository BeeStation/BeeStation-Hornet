/datum/species/dullahan
	name = "\improper Dullahan"
	id = SPECIES_DULLAHAN
	max_bodypart_count = 5 //No head
	default_color = "FFFFFF"
	species_traits = list(EYECOLOR,HAIR,FACEHAIR,LIPS)
	inherent_traits = list(TRAIT_NOHUNGER,TRAIT_NOBREATH, TRAIT_NONECRODISEASE)
	default_features = list("mcolor" = "FFF", "tail_human" = "None", "ears" = "None", "wings" = "None", "body_size" = "Normal")
	use_skintones = TRUE
	mutant_brain = /obj/item/organ/brain/dullahan
	mutanteyes = /obj/item/organ/eyes/dullahan
	mutanttongue = /obj/item/organ/tongue/dullahan
	mutantears = /obj/item/organ/ears/dullahan
	examine_limb_id = SPECIES_HUMAN
	skinned_type = /obj/item/stack/sheet/animalhide/human
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | ERT_SPAWN

	var/obj/item/dullahan_relay/myhead


/datum/species/dullahan/check_roundstart_eligible()
	if(SSevents.holidays && SSevents.holidays[HALLOWEEN])
		return TRUE
	return FALSE

/datum/species/dullahan/on_species_gain(mob/living/carbon/human/H, datum/species/old_species)
	. = ..()
	REMOVE_TRAIT(src, TRAIT_HEARING_SENSITIVE, TRAIT_GENERIC)
	var/obj/item/bodypart/head/head = H.get_bodypart(BODY_ZONE_HEAD)
	if(head)
		head.drop_limb()
		head.throwforce = 25
		myhead = new /obj/item/dullahan_relay (head, H)
		H.put_in_hands(head)

/datum/species/dullahan/on_species_loss(mob/living/carbon/human/H)
	H.become_hearing_sensitive()
	H.reset_perspective(H)
	if(myhead)
		var/obj/item/dullahan_relay/DR = myhead
		myhead = null
		DR.owner = null
		qdel(DR)
	H.regenerate_limb(BODY_ZONE_HEAD,FALSE)
	..()

/datum/species/dullahan/spec_life(mob/living/carbon/human/H)
	if(QDELETED(myhead))
		myhead = null
		H.gib()
	var/obj/item/bodypart/head/head2 = H.get_bodypart(BODY_ZONE_HEAD)
	if(head2)
		myhead = null
		H.gib()

/datum/species/dullahan/proc/update_vision_perspective(mob/living/carbon/human/H)
	var/obj/item/organ/eyes/eyes = H.getorganslot(ORGAN_SLOT_EYES)
	if(eyes)
		H.update_tint()
		if(eyes.tint)
			H.reset_perspective(H)
		else
			H.reset_perspective(myhead)


/datum/species/dullahan/get_species_description()
	return "An angry spirit, hanging onto the land of the living for \
		unfinished business. Or that's what the books say. They're quite nice \
		when you get to know them."

/datum/species/dullahan/get_species_lore()
	return list(
		"\"No wonder they're all so grumpy! Their hands are always full! I used to think, \
		\"Wouldn't this be cool?\" but after watching these creatures suffer from their head \
		getting dunked down disposals for the nth time, I think I'm good.\" - Captain Larry Dodd"
	)

/datum/species/dullahan/create_pref_unique_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_NEGATIVE_PERK,
		SPECIES_PERK_ICON = "horse-head",
		SPECIES_PERK_NAME = "Headless and Horseless",
		SPECIES_PERK_DESC = "Dullahans must lug their head around in their arms. While \
			many creative uses can come out of your head being independent of your \
			body, Dullahans will find it mostly a pain.",
	))

	return to_add

// There isn't a "Minor Undead" biotype, so we have to explain it in an override (see: vampires)
/datum/species/dullahan/create_pref_biotypes_perks()
	var/list/to_add = list()

	to_add += list(list(
		SPECIES_PERK_TYPE = SPECIES_POSITIVE_PERK,
		SPECIES_PERK_ICON = "skull",
		SPECIES_PERK_NAME = "Minor Undead",
		SPECIES_PERK_DESC = "[name] are minor undead. \
			Minor undead enjoy some of the perks of being dead, like \
			not needing to breathe or eat, but do not get many of the \
			environmental immunities involved with being fully undead.",
	))

	return to_add

/obj/item/organ/brain/dullahan
	decoy_override = TRUE
	organ_flags = 0

/obj/item/organ/tongue/dullahan
	zone = "abstract"
	modifies_speech = TRUE

/obj/item/organ/tongue/dullahan/handle_speech(datum/source, list/speech_args)
	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == SPECIES_DULLAHAN)
			var/datum/species/dullahan/D = H.dna.species
			if(isobj(D.myhead.loc))
				var/obj/O = D.myhead.loc
				O.say(speech_args[SPEECH_MESSAGE])
	speech_args[SPEECH_MESSAGE] = ""

/obj/item/organ/ears/dullahan
	zone = "abstract"

/obj/item/organ/eyes/dullahan
	name = "head vision"
	desc = "An abstraction."
	actions_types = list(/datum/action/item_action/organ_action/dullahan)
	zone = "abstract"

/datum/action/item_action/organ_action/dullahan
	name = "Toggle Perspective"
	desc = "Switch between seeing normally from your head, or blindly from your body."

/datum/action/item_action/organ_action/dullahan/Trigger()
	. = ..()
	var/obj/item/organ/eyes/dullahan/DE = target
	if(DE.tint)
		DE.tint = 0
	else
		DE.tint = INFINITY

	if(ishuman(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == SPECIES_DULLAHAN)
			var/datum/species/dullahan/D = H.dna.species
			D.update_vision_perspective(H)

/obj/item/dullahan_relay
	var/mob/living/owner

/obj/item/dullahan_relay/Initialize(mapload,new_owner)
	. = ..()
	owner = new_owner
	START_PROCESSING(SSobj, src)
	become_hearing_sensitive(ROUNDSTART_TRAIT)

/obj/item/dullahan_relay/process()
	if(!istype(loc, /obj/item/bodypart/head) || QDELETED(owner))
		. = PROCESS_KILL
		qdel(src)

/obj/item/dullahan_relay/Hear(message, atom/movable/speaker, message_language, raw_message, radio_freq, list/spans, list/message_mods = list())
	. = ..()
	if(!QDELETED(owner))
		message = compose_message(speaker, message_language, raw_message, radio_freq, spans, message_mods)
		to_chat(owner,message)
	else
		qdel(src)


/obj/item/dullahan_relay/Destroy()
	if(!QDELETED(owner))
		var/mob/living/carbon/human/H = owner
		if(H.dna.species.id == SPECIES_DULLAHAN)
			var/datum/species/dullahan/D = H.dna.species
			D.myhead = null
			owner.gib()
	owner = null
	return ..()
