///////////////////////////////////////////////////////////////////
					//Noita Potions
//////////////////////////////////////////////////////////////////


/datum/reagent/magic
	name = "magic essence"
	description = "Basic component in all magical potions."
	random_unrestricted = FALSE

//	----	POLYMORPHINE	----

/datum/reagent/magic/polymorphine
	name = "polymorphine"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "a rainbow of tastes"
	overdose_threshold = 30
	metabolization_rate = 3 * REAGENTS_METABOLISM
	var/list_mobs = FRIENDLY_SPAWN
	var/obj/shapeshift_holder/shapeshiftdata

/datum/reagent/magic/polymorphine/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		polymorph_target(M)
	..()

/datum/reagent/magic/polymorphine/overdose_start(mob/living/L)
	..()
	L.reagents.remove_reagent(/datum/reagent/magic/polymorphine,overdose_threshold)
	polymorph_target(L)

/datum/reagent/magic/polymorphine/proc/polymorph_target(mob/living/L)
	shapeshiftdata = locate() in L
	if(shapeshiftdata)		//user already polymorphed
		return
	var/mob/living/shape = create_random_mob((get_turf(L)), list_mobs)
	shapeshiftdata = new(shape,null,L)
	addtimer(CALLBACK(src, .proc/restore_target, L), 15 SECONDS)

/datum/reagent/magic/polymorphine/proc/restore_target(mob/living/L)
	. = ..()
	if(!shapeshiftdata)
		return
	shapeshiftdata.restore()

/datum/reagent/magic/polymorphine/chaotic
	name = "chaotic polymorphine"
	description = "Transforms your target into a hostile creature."
	list_mobs = HOSTILE_SPAWN

/datum/reagent/magic/polymorphine/unstable
	name = "unstable polymorphine"
	description = "Nobody knows what will happen!"

/datum/reagent/magic/polymorphine/unstable/on_mob_metabolize(mob/living/L)
	..()
	list_mobs = prob(50) ? HOSTILE_SPAWN : FRIENDLY_SPAWN

//	----	BERSERKIUM	----

/datum/reagent/magic/berserkium
	name = "polymorphine"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "something that makes you angry!"
	metabolization_rate = 3 * REAGENTS_METABOLISM

/datum/reagent/magic/berserkium/on_mob_metabolize(mob/living/L)
	. = ..()
	ADD_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, REAGENT_TRAIT)
	ADD_TRAIT(L, TRAIT_NOSTAMCRIT, REAGENT_TRAIT)
	ADD_TRAIT(L, TRAIT_NOLIMBDISABLE, REAGENT_TRAIT)

/datum/reagent/magic/berserkium/on_mob_life(mob/living/L)
	. = ..()
	if(current_cycle > 10 && prob(20))
		var/prev_intent = L.a_intent
		L.a_intent = INTENT_HARM

		var/range = 1
		if(istype(L.get_active_held_item(), /obj/item/gun)) //get targets to shoot at
			range = 7

		var/list/mob/living/targets = list()
		for(var/mob/M in oview(L, range))
			if(isliving(M))
				targets += M
		if(LAZYLEN(targets))
			if(prob(33))
				L.say("ARGH!", forced = "reagent")
			L.ClickOn(pick(targets))
		L.a_intent = prev_intent
		current_cycle = 1

/datum/reagent/magic/berserkium/on_mob_end_metabolize(mob/living/L)
	..()
	REMOVE_TRAIT(L, TRAIT_IGNOREDAMAGESLOWDOWN, REAGENT_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOSTAMCRIT, REAGENT_TRAIT)
	REMOVE_TRAIT(L, TRAIT_NOLIMBDISABLE, REAGENT_TRAIT)


//	----	TELEPORTARIUM	----

/datum/reagent/magic/teleportarium
	name = "teleportarium"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "a bitterness that makes you angry!"
	var/tele_range = 3

/datum/reagent/magic/teleportarium/reaction_mob(mob/living/L, method=TOUCH, reac_volume)
	if(method == TOUCH || method == VAPOR)
		teleport_sucker(L)
	..()

/datum/reagent/magic/teleportarium/on_mob_life(mob/living/L)
	if(current_cycle > 3 SECONDS )
		to_chat(L, "<span class='warning'>You feel out of place...</span>")
		teleport_sucker()
	..()

/datum/reagent/magic/teleportarium/proc/teleport_sucker(mob/living/L)
	var/atom/target = get_ranged_target_turf(get_turf(L), L.dir, tele_range)
	do_teleport(L, target, 0, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)


/datum/reagent/magic/teleportarium/unstable
	name = "unstable teleportarium"
	description = "Transforms your target into a harmless animal."

/datum/reagent/magic/teleportarium/unstable/teleport_sucker(mob/living/L)
	do_teleport(L, get_turf(L), tele_range, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)

//	----	INVISIBILIUM	----

/datum/reagent/magic/invisibilium
	name = "invisibilium"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "something that makes you angry!"
	metabolization_rate = 0.5 * REAGENTS_METABOLISM
	var/original_alpha = 1
	var/charge = 0
	var/last_volume = 0

/datum/reagent/magic/invisibilium/on_mob_metabolize(mob/living/L)
	. = ..()
	original_alpha = L.alpha

/datum/reagent/magic/invisibilium/on_mob_life(mob/living/L)
	. = ..()
	if (volume >= last_volume)
		last_volume = volume
		charge = max(300,charge + volume * 10)
	else
		charge = volume/last_volume * 300
	animate(L,alpha = CLAMP(255 - charge,0,255),time = 10)

/datum/reagent/magic/invisibilium/on_mob_end_metabolize(mob/living/L)
	..()
	L.alpha = original_alpha

//	----	LEVITATIUM	----

/datum/reagent/magic/levitatium
	name = "polymorphine"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "something that makes you angry!"
	metabolization_rate = 3 * REAGENTS_METABOLISM

/datum/reagent/magic/levitatium/on_mob_metabolize(mob/living/L)
	..()
	L.add_movespeed_modifier(MOVESPEED_ID_LEVITATION_POTION, priority=13, multiplicative_slowdown=-2, movetypes=(FLYING|FLOATING))

/datum/reagent/magic/levitatium/on_mob_end_metabolize(mob/living/L)
	..()
	L.remove_movespeed_modifier(MOVESPEED_ID_LEVITATION_POTION)

//	----	DRAUGHT OF MIDAS	----


/datum/reagent/magic/midas
	name = "draught of midas"
	description = "Transforms your target into a harmless animal."
	color = "#cccccc"
	taste_description = "something that makes you angry!"
	var/static/c_v = 10

/datum/reagent/magic/midas/reaction_obj(obj/O, reac_volume)
	if(ismob(O.loc)) //handled in human acid_act()
		return
	reac_volume = round(reac_volume,0.1)
	if(istype(O, /obj/machinery/door) || (O.type!=/obj/structure/mineral_door/gold && istype(O, /obj/structure/mineral_door)))
		if (reac_volume<c_v)
			return
		var/obj/structure/mineral_door/D = new /obj/structure/mineral_door/gold(get_turf(O))
		qdel(O)
		D.Open()
	else if (reac_volume>=c_v/2)
		if (O.type == /obj/item/bikehorn)	//bikehorn
			new /obj/item/bikehorn/golden(get_turf(O))
		else if (O.type == /obj/item/instrument/violin)
			new /obj/item/instrument/violin/golden(get_turf(O))
		else if (istype(O,/obj/item/stack/sheet/mineral) && O.type!=/obj/item/stack/sheet/mineral/gold)
			var/obj/item/stack/sheet/mineral/catalyst = O
			var/obj/item/stack/sheet/mineral/gold/output = new /obj/item/stack/sheet/mineral/gold(get_turf(O))
			output.add(catalyst.amount-1)
		else if (istype(O,/obj/item/clothing/head))
			new /obj/item/clothing/head/crown(get_turf(O))
		else
			return
		qdel(O)

/datum/reagent/magic/midas/reaction_turf(turf/T, reac_volume)
	if (!istype(T))
		return
	if (reac_volume<c_v)
		return
	if(isclosedturf(T) && !isindestructiblewall(T))
		T.ChangeTurf(/turf/closed/wall/mineral/gold, flags = CHANGETURF_INHERIT_AIR)
	else if (isopenturf(T))
		T.ChangeTurf(/turf/open/floor/mineral/gold, flags = CHANGETURF_INHERIT_AIR)