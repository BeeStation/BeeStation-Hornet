/*
	- CHANGELING ABOMINATION -

	Contents:
		Reagent
		Monster
*/

/datum/reagent/shiftium
	name = "shifium"
	description = "A changeling matter derived stimulant that overexcites the nervous system, forcing transformations in changelings."
	color = "#9D5A99"
	overdose_threshold = 8
	taste_description = "savory with a bit of blood"
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	var/obj/shapeshift_holder/shapeshiftdata

/datum/reagent/shiftium/on_mob_metabolize(mob/living/L)
	L.adjustStaminaLoss(-10, 0)
	..()

/datum/reagent/shiftium/overdose_start(mob/living/L)
	if(L.mind?.has_antag_datum(/datum/antagonist/changeling))
		to_chat(L,"<span class='danger'>You struggle to maintain your form!</span>")
	..()

/datum/reagent/shiftium/overdose_process(mob/living/L)
	L.adjustStaminaLoss(5, 0)
	if(!shapeshiftdata && prob(volume * 2.5))
		var/datum/antagonist/changeling/changeling = L.mind?.has_antag_datum(/datum/antagonist/changeling)
		if(changeling)
			playsound(L, 'sound/magic/demon_consume.ogg', 30, 1)
			L.visible_message("<span class='warning'>[L]'s body uncontrollably transforms into an abomination!</span>", "<span class='boldwarning'>Your body uncontrollably transforms, revealing your true form!</span>")

			polymorph_target(L,volume/overdose_threshold)
			L.reagents.remove_reagent(/datum/reagent/shiftium,volume)
	..()

/datum/reagent/shiftium/proc/polymorph_target(mob/living/L, var/dur)
	shapeshiftdata = locate() in L
	if(shapeshiftdata)
		return
	var/mob/living/simple_animal/hostile/cling_horror/shape = new (get_turf(L))
	shapeshiftdata = new(shape,null,L)
	addtimer(CALLBACK(shapeshiftdata, /obj/shapeshift_holder.proc/restore),  max(600, 600 * dur))

/datum/reagent/clinggibs
	name = "changeling spinal fluid"
	color = "#FF9966"
	description = "Matter sample from a fluid living being that is able to reform flesh and send nervous impulses. This sample is dead."
	taste_description = "gross iron"

//	CLING GIBS

/obj/effect/decal/cleanable/blood/gibs/changeling
	icon_state = "gib1"
	random_icon_states = list("gib1", "gib2", "gib3", "gib4", "gib5", "gib6","gibup1","gibdown1")

/obj/effect/decal/cleanable/blood/gibs/changeling/Initialize(mapload, list/datum/disease/diseases)
	. = ..()
	reagents.remove_reagent(/datum/reagent/liquidgibs, 5)
	reagents.add_reagent(/datum/reagent/clinggibs, 10)

//	THE CREATURE

/mob/living/simple_animal/hostile/cling_horror
	name = "true changeling"
	desc = "A grotesque congeries of flesh and bone, barely resembling a human, and with myriads of temporary eyes and mouths forming and un-forming as pustules of meat."
	icon = 'icons/mob/mob.dmi'
	icon_state = "horror"
	icon_living = "horror"
	health = 180
	maxHealth = 180
	obj_damage = 35
	melee_damage = 20
	hardattacks = TRUE
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("gurgles")
	a_intent = INTENT_HARM
	ranged_message = "launches a tentacle"
	deathmessage = "falls down limp, and reverts to the original form."
	ranged = TRUE
	ranged_cooldown = 6 SECONDS
	projectilesound = 'sound/effects/splat.ogg'
	projectiletype = /obj/item/projectile/tentacle/creep
