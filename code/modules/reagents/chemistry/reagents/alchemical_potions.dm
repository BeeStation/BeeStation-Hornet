///////////////////////////////////////////////////////////////////
					//Noita Potions
//////////////////////////////////////////////////////////////////

#define MAGIC_REAGENT_TOUCH 10
#define TELEPORTARIUM_RANGE 4
#define TELEPORTARIUM_CYCLE 3
#define POLYMORPHIUM_DURATION 10 SECONDS

/datum/reagent/magic
	name = "alchemic precursor"
	description = "Basic component in all alchemical potions."
	random_unrestricted = FALSE
	metabolization_rate = 3 * REAGENTS_METABOLISM
	color = "#1C2EC3"
	taste_description = "earwax"

//	----	POLYMORPHINE	----

/datum/reagent/magic/polymorphine
	name = "polymorphine"
	description = "Magic potion that transforms you into a harmless animal."
	color = "#9D5A99"
	overdose_threshold = 15
	taste_description = "savory, yet sweet"
	metabolization_rate = 0.1 * REAGENTS_METABOLISM
	var/obj/shapeshift_holder/shapeshiftdata

/datum/reagent/magic/polymorphine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if (reac_volume >= overdose_threshold && (method == TOUCH || method == VAPOR))
		polymorph_target(M,reac_volume/overdose_threshold)
	..()

/datum/reagent/magic/polymorphine/overdose_start(mob/living/L)
	..()
	polymorph_target(L,volume/overdose_threshold)
	metabolization_rate = 10 * REAGENTS_METABOLISM

/datum/reagent/magic/polymorphine/proc/polymorph_target(mob/living/L, var/dur)
	shapeshiftdata = locate() in L
	if(shapeshiftdata)
		return
	var/mob/living/shape = make_mob(get_turf(L))
	shapeshiftdata = new(shape,null,L)
	addtimer(CALLBACK(shapeshiftdata, /obj/shapeshift_holder.proc/restore), POLYMORPHIUM_DURATION * dur)

/datum/reagent/magic/polymorphine/on_mob_end_metabolize(mob/living/L)
	..()
	if(!shapeshiftdata)
		return
	shapeshiftdata.restore()

/datum/reagent/magic/polymorphine/proc/make_mob(turf/T)
	return create_random_mob(T, FRIENDLY_SPAWN)

/datum/reagent/magic/polymorphine/chaotic
	name = "chaotic polymorphine"
	description = "Magic potion that transforms you into a hostile creature."

/datum/reagent/magic/polymorphine/chaotic/make_mob(turf/T)
	return create_random_mob(T, HOSTILE_SPAWN)

/datum/reagent/magic/polymorphine/unstable
	name = "unstable polymorphine"
	description = "Magic potion that transforms you into a random creature."

/datum/reagent/magic/polymorphine/unstable/make_mob(turf/T)
	return create_random_mob(T, prob(50) ? HOSTILE_SPAWN : FRIENDLY_SPAWN)

//	----	BERSERKIUM	----

/datum/reagent/magic/berserkium
	name = "berserkium"
	description = "Magic potion that enrages you when drunk."
	color = "#A14444"
	taste_description = "liquid rage"
	metabolization_rate = 1.5 * REAGENTS_METABOLISM

/datum/reagent/magic/berserkium/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, BERSERKIUM_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, BERSERKIUM_TRAIT)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, BERSERKIUM_TRAIT)

/datum/reagent/magic/berserkium/on_mob_life(mob/living/L)
	. = ..()
	var/prev_intent = L.a_intent
	L.a_intent = INTENT_HARM

	var/range = 1
	if(istype(L.get_active_held_item(), /obj/item/gun)) //get targets to shoot at
		range = 7

	var/list/mob/living/targets = list()
	for(var/mob/living/M in oview(L, range))
		targets += M
	if(LAZYLEN(targets))
		L.ClickOn(pick(targets))
	L.a_intent = prev_intent

/datum/reagent/magic/berserkium/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, BERSERKIUM_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, BERSERKIUM_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, BERSERKIUM_TRAIT)


//	----	TELEPORTARIUM	----

/datum/reagent/magic/teleportarium
	name = "teleportarium"
	description = "Magic potion that teleports you a few steps forward."
	taste_description = "a flavor spectrum all over the place"
	color = "#528698"

/datum/reagent/magic/teleportarium/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if (reac_volume>=MAGIC_REAGENT_TOUCH && (method == TOUCH || method == VAPOR))
		teleport_sucker(L)
	..()

/datum/reagent/magic/teleportarium/on_mob_life(mob/living/L)
	if(current_cycle > TELEPORTARIUM_CYCLE )
		to_chat(L, "<span class='warning'>You feel out of place...</span>")
		teleport_sucker(L)
		current_cycle = 1
	..()

/datum/reagent/magic/teleportarium/proc/teleport_sucker(mob/living/carbon/L)
	if (istype(L))
		var/atom/A = get_ranged_target_turf(get_turf(L), L.dir, TELEPORTARIUM_RANGE)
		do_teleport(L, A, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_WORMHOLE)


/datum/reagent/magic/teleportarium/unstable
	name = "unstable teleportarium"
	description = "Magic potion that teleports you to a nearby random point."

/datum/reagent/magic/teleportarium/unstable/teleport_sucker(mob/living/L)
	do_teleport(L, get_turf(L), TELEPORTARIUM_RANGE, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_WORMHOLE)

//	----	INVISIBILIUM	----

/datum/reagent/magic/invisibilium
	name = "invisibilium"
	description = "Magic potion that gradually turns you invisible."
	color = "#5353C1"
	metabolization_rate = REAGENTS_METABOLISM
	var/original_alpha = 1
	var/charge = 0
	overdose_threshold = 10
	
/datum/reagent/magic/invisibilium/overdose_start(mob/living/L)
	..()
	metabolization_rate = 3 * REAGENTS_METABOLISM

/datum/reagent/magic/invisibilium/on_mob_metabolize(mob/living/L)
	. = ..()
	original_alpha = 255
	animate(L,alpha = 0,time = 3 SECONDS)

/datum/reagent/magic/invisibilium/on_mob_end_metabolize(mob/living/L)
	..()
	animate(L,alpha = original_alpha,time = 2 SECONDS)

//	----	LEVITATIUM	----

/datum/reagent/magic/levitatium
	name = "levitatium"
	description = "Magic potion that grants levitation."
	color = "#A0A68F"
	taste_description = "diet soda"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM

/datum/reagent/magic/levitatium/on_mob_metabolize(mob/living/carbon/human/H)
	..()
	if (istype(H))
		var/datum/species/S = H.dna.species
		if(!S.CanFly(H) && !(H.movement_type & FLYING))
			S.toggle_flight(H)
			to_chat(H, "<span class='notice'>You begin to hover gently above the ground...</span>")

/datum/reagent/magic/levitatium/on_mob_end_metabolize(mob/living/carbon/human/H)
	..()
	if (istype(H))
		var/datum/species/S = H.dna.species
		if(!S.CanFly(H) && (H.movement_type & FLYING))
			S.toggle_flight(H)
			to_chat(H, "<span class='notice'>You settle gently back onto the ground...</span>")
			H.set_resting(FALSE, TRUE)

//	----	ACCELERATIUM	----

/datum/reagent/magic/acceleratium
	name = "acceleratium"
	description = "Magic potion that increases the speed of whoever drinks it."
	color = "#94A77D"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	
/datum/reagent/magic/acceleratium/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1, blacklisted_movetypes=(FLYING|FLOATING))

/datum/reagent/magic/acceleratium/on_mob_end_metabolize(mob/living/L)
	..()
	L.remove_movespeed_modifier(type)

//	----	HASTIUM	----

/datum/reagent/magic/levitatium/hastium
	name = "hastium"
	description = "Magic potion that increases the speed of whoever drinks it, and grants levitation."
	color = "#94A77D"
	metabolization_rate = 1.25 * REAGENTS_METABOLISM
	
/datum/reagent/magic/levitatium/hastium/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(type, update=TRUE, priority=100, multiplicative_slowdown=-1)

/datum/reagent/magic/levitatium/hastium/on_mob_end_metabolize(mob/living/L)
	..()
	L.remove_movespeed_modifier(type)

//	----	DRAUGHT OF MIDAS	----

/datum/reagent/magic/midas
	name = "draught of midas"
	description = "Magic potion that transforms everything that touches into gold."
	color = "#FFFF91"
	taste_description = "the best beer you've ever had"

/datum/reagent/magic/midas/reaction_obj(obj/O, reac_volume)
	if(ismob(O.loc))
		return
	reac_volume = round(reac_volume,0.1)
	if(istype(O, /obj/machinery/door) || (O.type!=/obj/structure/mineral_door/gold && istype(O, /obj/structure/mineral_door)))
		if (reac_volume<MAGIC_REAGENT_TOUCH)
			return
		var/obj/structure/mineral_door/D = new /obj/structure/mineral_door/gold(get_turf(O))
		qdel(O)
		D.Open()
	else if (reac_volume>=MAGIC_REAGENT_TOUCH*0.5)
		if (O.type == /obj/item/bikehorn)	//bikehorn
			new /obj/item/bikehorn/golden(get_turf(O))
		else if (O.type == /obj/item/instrument/violin)
			new /obj/item/instrument/violin/golden(get_turf(O))
		else if (istype(O,/obj/item/stack/ore) && O.type!=/obj/item/stack/ore/gold)
			var/obj/item/stack/ore/catalyst = O
			new /obj/item/stack/ore/gold(get_turf(O),catalyst.amount)
		else if (istype(O,/obj/item/stack/sheet/mineral) && O.type!=/obj/item/stack/sheet/mineral/gold)
			var/obj/item/stack/sheet/mineral/catalyst = O
			new /obj/item/stack/sheet/mineral/gold(get_turf(O),catalyst.amount)
		else if (istype(O,/obj/item/clothing/head))
			new /obj/item/clothing/head/crown(get_turf(O))
		else
			return
		qdel(O)

/datum/reagent/magic/midas/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	if (reac_volume<MAGIC_REAGENT_TOUCH)
		return
	if(isclosedturf(T) && !isindestructiblewall(T))
		T.ChangeTurf(/turf/closed/wall/mineral/gold, flags = CHANGETURF_INHERIT_AIR)
	else if (isopenturf(T))
		T.ChangeTurf(/turf/open/floor/mineral/gold, flags = CHANGETURF_INHERIT_AIR)

//	----	LIVLELY CONCOCTION	----

/datum/reagent/magic/lc
	name = "lively concoction"
	description = "Magic potion with superior healing properties."
	color = "#7AC179"
	metabolization_rate = 10 * REAGENTS_METABOLISM
	taste_description = "bitter-sweet"

/datum/reagent/magic/lc/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if (method == TOUCH)
		L.heal_bodypart_damage(reac_volume,reac_volume,reac_volume)
		L.adjustBruteLoss(-reac_volume*3,0)
		L.adjustOxyLoss(-reac_volume*3,0)
		L.adjustFireLoss(-reac_volume*3,0)
		L.adjustToxLoss(-reac_volume*3,0)		
	..()
	
/datum/reagent/magic/lc/on_mob_metabolize(mob/living/L)
	..()
	L.heal_bodypart_damage(5,5,5)
	L.adjustBruteLoss(-15,0)
	L.adjustOxyLoss(-15,0)
	L.adjustFireLoss(-15,0)
	L.adjustToxLoss(-15,0)

#undef MAGIC_REAGENT_TOUCH
#undef TELEPORTARIUM_RANGE
#undef TELEPORTARIUM_CYCLE
#undef POLYMORPHIUM_DURATION