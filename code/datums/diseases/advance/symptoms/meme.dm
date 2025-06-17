/datum/symptom/meme
	name = "Hysteria"
	desc = "The virus causes mass hysteria involving a random concept."
	stealth = 1
	resistance = 1
	stage_speed = -1
	transmission = 3
	level = 9
	severity = 0
	base_message_chance = 50
	symptom_delay_min = 15
	symptom_delay_max = 45
	suffixes = list(" Hysteria", " Madness")
	var/emote
	var/emotelist = list("flip", "spin", "laugh", "dance", "grin", "grimace", "wave", "yawn", "snap", "clap", "moan", "wink", "eyebrow", "scream", "raise", "shrug")
	threshold_desc = "<b>Transmission 14:</b>The virus spreads memetically, infecting hosts who can see the target."

/datum/symptom/meme/Copy()
	var/datum/symptom/meme/new_symp = new type
	new_symp.name = name
	new_symp.id = id
	new_symp.neutered = neutered
	if(emote)
		new_symp.emote = emote
	return new_symp


/datum/symptom/meme/Start(datum/disease/advance/A)
	if(!..())
		return
	if(!emote)
		emote = pick(emotelist)

/datum/symptom/meme/Activate(datum/disease/advance/A)
	if(!..())
		return
	var/mob/living/carbon/M = A.affected_mob
	if(M.stat == DEAD)
		return
	if(prob(20 * A.stage) && !M.stat && !HAS_TRAIT(M, TRAIT_MINDSHIELD))
		M.emote(emote)
		if(A.stage >= 5 && prob(20) && (A.transmission >= 14 || CONFIG_GET(flag/unconditional_virus_spreading) || A.event))
			for(var/mob/living/carbon/C in oviewers(M, 4))
				var/obj/item/organ/eyes/eyes = C.get_organ_slot(ORGAN_SLOT_EYES)
				if(!eyes || HAS_TRAIT(C, TRAIT_BLIND) || HAS_TRAIT(C, TRAIT_MINDSHIELD) || istype(C.get_item_by_slot(ITEM_SLOT_HEAD), /obj/item/clothing/head/costume/foilhat))
					continue
				if(C.ForceContractDisease(A))
					C.emote(emote)
