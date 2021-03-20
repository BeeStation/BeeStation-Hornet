/*
 * Felinids:
 *
 * Felinids are essentially normal humans, but with some major genetic changes. They originate from a time long gone,
 * before the Animal rights consortium. Because I can't be too bothered to write up a super long and complex story
 * ill give you the basics as to where I would say they come from (take it as you will, its lore and this part literally)
 * does not matter, nor affect them mostly; but essentially genetic modification is becoming a more and more accessible thing,
 * experiments are done into modding humans into other species and as one of the first species experiments felinids were created
 * being a hybrid between humans and felines obviously. Due to their modifications ([data expunged]) felinids reproduced at
 * a heavilly increased rate compared to humans, leading to complications with station supply. (The actual numbers of
 * inhabitants was higher than predicted). As a result a large portion of the felinid population was exiled or sent
 * to transfer centers, with only a very small number being allowed to perform menial jobs. At this time almost all felinids
 * on station were of a single gender, and combined with their shorter lifespans when compared to humans caused their
 * numbers to be declining rapidly. As a result of this, and to comply with the requests of a new syndicate faction rising
 * (the animal rights consortium), the reduction of the felinid population was ceased with hopes from Nanotrasen that
 * their numbers would continue to decline. Since the future is here now, medicine is a lot better and cloning is a
 * possibility, the need for new crew and the worry that crew will be lost is only minor, so the population on most stations
 * is pretty stable, felinids can live on and with no further problems with in a long timespan, felinids can finally at
 * last be accepted into most jobs. Oh yea pretty important thing I forgot to add somewhere but makes them make sense a
 * bit more is that when exiled they were sent to some planet considered pretty dangerous, its dark and shit so they
 * have minor genetic changes due to this (natural selection and all).
 *
 * That planet I talked about properties:
 * - Cold and pretty barren, animals and plants do live on the planet, however much of the plants are toxic
 * or dangerous in some way, and only the animals that have lived and adapted there for centuries can consume them. As
 * a result the felinids living there have poor ability to consume plant based matter, and prefer meats. Additionally felinids
 * are more suited to the cold environment of this planet, and heavily dislike the heat. Obviously they had coats and stuff too,
 * so can live in environments that can support humans; they werent there for /that/ long.
 * - Since the planet was relatively dark, their eyes have adapted to be better in the dark.
 * - Due to their sensitive ears, they have a weakness to flashbangs.
 *
 * Actual changes
 * - Food preference changes
 * - Ears are weak to flashbangs
 * - Increased stamina damage (Slightly).
 * - Vision Mode:
 *   - Speed is reduced while active
 *   - Any movement, even in dark will show red blips
 *   - 10 seconds cooldown toggling on and off.
 * - Makes other people around them happier / mood buffs for others
 * - They have a tail that is waggable
 * - They drown better
 *
 * Differences to humans: These may be as a result of modification, or as a result of genetic changes due to the environment.
 *
 */
/datum/species/human/felinid
	name = "Felinid"
	id = "felinid"
	//They are basically human, so don't have too many major genetic variations apart from the tail and ear modifications.
	//They do however have minor genetic variations due to their environment, which accounts for their adaptation to coldness.
	limbs_id = "human"

	disliked_food = VEGETABLES | SUGAR
	liked_food = DAIRY | MEAT

	//Felinids are adapted to live in colder environments.
	coldmod = 0.7
	heatmod = 1.15
	staminamod = 1.2	//120% stamina damage
	toxmod = 0.9		//90% toxin damage.

	mutant_bodyparts = list("ears", "tail_human")
	default_features = list("mcolor" = "FFF", "wings" = "None")
	forced_features = list("tail_human" = "Cat", "ears" = "Cat")

	mutantears = /obj/item/organ/ears/cat
	mutanttail = /obj/item/organ/tail/cat
	changesource_flags = MIRROR_BADMIN | WABBAJACK | MIRROR_PRIDE | MIRROR_MAGIC | RACE_SWAP | ERT_SPAWN | SLIME_EXTRACT

	swimming_component = /datum/component/swimming/felinid

//Curiosity killed the cat's wagging tail.
/datum/species/human/felinid/spec_death(gibbed, mob/living/carbon/human/H)
	if(H)
		stop_wagging_tail(H)
		for(var/mob/living/carbon/human/other in view(6, H))
			if(HAS_TRAIT(other, TRAIT_CATHATER))
				SEND_SIGNAL(other, COMSIG_ADD_MOOD_EVENT, "felinid_dead", /datum/mood_event/deadcat)

/datum/species/human/felinid/spec_stun(mob/living/carbon/human/H,amount)
	if(H)
		stop_wagging_tail(H)
	. = ..()

/datum/species/human/felinid/can_wag_tail(mob/living/carbon/human/H)
	return ("tail_human" in mutant_bodyparts) || ("waggingtail_human" in mutant_bodyparts)

/datum/species/human/felinid/is_wagging_tail(mob/living/carbon/human/H)
	return ("waggingtail_human" in mutant_bodyparts)

/datum/species/human/felinid/start_wagging_tail(mob/living/carbon/human/H)
	if("tail_human" in mutant_bodyparts)
		mutant_bodyparts -= "tail_human"
		mutant_bodyparts |= "waggingtail_human"
		send_mood_events(H)
	H.update_body()

/datum/species/human/felinid/stop_wagging_tail(mob/living/carbon/human/H)
	if("waggingtail_human" in mutant_bodyparts)
		mutant_bodyparts -= "waggingtail_human"
		mutant_bodyparts |= "tail_human"
	H.update_body()

/datum/species/human/felinid/proc/send_mood_events(mob/living/carbon/human/H)
	for(var/mob/living/carbon/human/other in view(3, H))
		send_mood_event(H, other)

/datum/species/human/felinid/proc/send_mood_event(mob/living/carbon/human/H, mob/living/carbon/human/other)
	if(iscatperson(H))
		return
	if(HAS_TRAIT(other, TRAIT_CATHATER))
		SEND_SIGNAL(other, COMSIG_ADD_MOOD_EVENT, "felinid", /datum/mood_event/badcat, H)
	else
		SEND_SIGNAL(other, COMSIG_ADD_MOOD_EVENT, "felinid", /datum/mood_event/cutecat, H)

/datum/species/human/felinid/help(mob/living/carbon/human/user, mob/living/carbon/human/target, datum/martial_art/attacker_style)
	. = ..()
	if(.)
		send_mood_event(user, target)

/datum/species/human/felinid/on_species_gain(mob/living/carbon/C, datum/species/old_species, pref_load)
	if(ishuman(C))
		var/mob/living/carbon/human/H = C
		if(!pref_load)			//Hah! They got forcefully purrbation'd. Force default felinid parts on them if they have no mutant parts in those areas!
			if(H.dna.features["tail_human"] == "None")
				H.dna.features["tail_human"] = "Cat"
			if(H.dna.features["ears"] == "None")
				H.dna.features["ears"] = "Cat"
		if(H.dna.features["ears"] == "Cat")
			var/obj/item/organ/ears/cat/ears = new
			ears.Insert(H, drop_if_replaced = FALSE)
		else
			mutantears = /obj/item/organ/ears
		if(H.dna.features["tail_human"] == "Cat")
			var/obj/item/organ/tail/cat/tail = new
			tail.Insert(H, drop_if_replaced = FALSE)
		else
			mutanttail = null
	//Should have seen it coming
	if(HAS_TRAIT(C, TRAIT_CATHATER))
		SEND_SIGNAL(C, COMSIG_ADD_MOOD_EVENT, "cathateriscat", /datum/mood_event/cathateriscat)
	return ..()

/datum/species/human/felinid/on_species_loss(mob/living/carbon/H, datum/species/new_species, pref_load)
	var/obj/item/organ/ears/cat/ears = H.getorgan(/obj/item/organ/ears/cat)
	var/obj/item/organ/tail/cat/tail = H.getorgan(/obj/item/organ/tail/cat)

	if(ears)
		var/obj/item/organ/ears/NE
		if(new_species?.mutantears)
			// Roundstart cat ears override new_species.mutantears, reset it here.
			new_species.mutantears = initial(new_species.mutantears)
			if(new_species.mutantears)
				NE = new new_species.mutantears
		if(!NE)
			// Go with default ears
			NE = new /obj/item/organ/ears
		NE.Insert(H, drop_if_replaced = FALSE)

	if(tail)
		var/obj/item/organ/tail/NT
		if(new_species && new_species.mutanttail)
			// Roundstart cat tail overrides new_species.mutanttail, reset it here.
			new_species.mutanttail = initial(new_species.mutanttail)
			if(new_species.mutanttail)
				NT = new new_species.mutanttail
		if(NT)
			NT.Insert(H, drop_if_replaced = FALSE)
		else
			tail.Remove(H)
	SEND_SIGNAL(other, COMSIG_CLEAR_MOOD_EVENT, "cathateriscat")

/datum/species/human/felinid/handle_chemicals(datum/reagent/chem, mob/living/carbon/human/M)
	. = ..()
	if(istype(chem, /datum/reagent/consumable/cocoa))
		if(prob(40))
			M.adjust_disgust(20)
		if(prob(5))
			M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
		if(prob(10))
			var/sick_message = pick("You feel nauseous.", "You're nya't feeling so good.","You feel like your insides are melting.","You feel illsies.")
			to_chat(M, "<span class='notice'>[sick_message]</span>")
		if(prob(15))
			var/obj/item/organ/guts = pick(M.internal_organs)
			guts.applyOrganDamage(15)
		M.adjustToxLoss(3)
		return FALSE

//====================
// Purrbation
// - Cattification
//====================

/proc/mass_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishumanbasic(M))
			purrbation_apply(M)
		CHECK_TICK

/proc/mass_remove_purrbation()
	for(var/M in GLOB.mob_list)
		if(ishumanbasic(M))
			purrbation_remove(M)
		CHECK_TICK

/proc/purrbation_toggle(mob/living/carbon/human/H, silent = FALSE)
	if(!ishumanbasic(H))
		return
	if(!iscatperson(H))
		purrbation_apply(H, silent)
		. = TRUE
	else
		purrbation_remove(H, silent)
		. = FALSE

/proc/purrbation_apply(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || iscatperson(H))
		return
	H.set_species(/datum/species/human/felinid)

	if(!silent)
		to_chat(H, "Something is nya~t right.")
		playsound(get_turf(H), 'sound/effects/meow1.ogg', 50, 1, -1)

/proc/purrbation_remove(mob/living/carbon/human/H, silent = FALSE)
	if(!ishuman(H) || !iscatperson(H))
		return

	H.set_species(/datum/species/human)

	if(!silent)
		to_chat(H, "You are no longer a cat.")
