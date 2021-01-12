/*	
	- CHANGELING ABOMINATION -
	
	Contents:
		Reagent
		Monster
*/

/datum/reagent/shiftium
	name = "shiftium"
	description = "A strange stimulant."
	color = "#9D5A99"
	overdose_threshold = 12
	taste_description = "savory with a bit of blood"
	metabolization_rate = 0.3 * REAGENTS_METABOLISM
	var/obj/shapeshift_holder/shapeshiftdata

/datum/reagent/shiftium/on_mob_metabolize(mob/living/L)
	L.adjustStaminaLoss(-5, 0)
	if (prob (5*volume) && L.mind?.has_antag_datum(/datum/antagonist/changeling))
		to_chat(L,"<span class='danger'>You struggle to maintain your form!</span>")
	..()

/datum/reagent/shiftium/on_mob_end_metabolize(mob/living/L)
	..()
	if(!shapeshiftdata)
		return
	shapeshiftdata.restore()
	REMOVE_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)
	
/datum/reagent/shiftium/overdose_start(mob/living/L)
	..()
	var/datum/antagonist/changeling/changeling = L.mind?.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		playsound(L, 'sound/magic/demon_consume.ogg', 30, 1)
		L.visible_message("<span class='warning'>[L]'s body uncontrolably transforms into an abomination!</span>", "<span class='boldwarning'>Your body uncontrolably transforms into an abomination, revealing your true form!</span>")
		
		polymorph_target(L,volume/overdose_threshold)
		
		metabolization_rate = 10 * REAGENTS_METABOLISM
		ADD_TRAIT(L, CHANGELING_HIVEMIND_MUTE, type)

/datum/reagent/shiftium/overdose_process(mob/living/M as mob)
	M.adjustStaminaLoss(5, 0)
	..()

/datum/reagent/shiftium/proc/polymorph_target(mob/living/L, var/dur)
	if(L.anti_magic_check())
		return
	shapeshiftdata = locate() in L
	if(shapeshiftdata)
		return
	var/mob/living/simple_animal/hostile/cling_horror/shape = new (get_turf(L))
	shapeshiftdata = new(shape,null,L)
	addtimer(CALLBACK(shapeshiftdata, /obj/shapeshift_holder.proc/restore), 25 SECONDS * dur)

//	THE CREATURE
	
/mob/living/simple_animal/hostile/cling_horror
	name = "true changeling"
	desc = "A grotesque congeries of flesh and bone, barely resembling a human, and with myriads of temporary eyes and mouths forming and un-forming as pustules of meat."
	icon = 'icons/mob/mob.dmi'
	icon_state = "horror"
	icon_living = "horror"
	health = 150
	maxHealth = 150
	obj_damage = 50
	melee_damage = 25
	hardattacks = TRUE
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	speak_emote = list("gurgles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	a_intent = INTENT_HARM
	speed = 3
	ranged_message = "launches a tentacle"
	deathmessage = "falls down limp, and reverts to the original form."
	ranged = TRUE
	ranged_cooldown = 2 SECONDS
	projectilesound = 'sound/effects/splat.ogg'
	projectiletype = /obj/item/projectile/tentacle