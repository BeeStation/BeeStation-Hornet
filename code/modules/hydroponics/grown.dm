// ***********************************************************
// Foods that are produced from hydroponics ~~~~~~~~~~
// Data from the seeds carry over to these grown foods
// ***********************************************************

// Base type. Subtypes are found in /grown dir. Lavaland-based subtypes can be found in mining/ash_flora.dm
/obj/item/reagent_containers/food/snacks/grown
	icon = 'icons/obj/hydroponics/harvest.dmi'
	var/obj/item/seeds/seed = null // type path, gets converted to item on New(). It's safe to assume it's always a seed item.
	var/plantname = ""
	var/splat_type = /obj/effect/decal/cleanable/food/plant_smudge
	dried_type = -1
	// Saves us from having to define each stupid grown's dried_type as itself.
	// If you don't want a plant to be driable (watermelons) set this to null in the time definition.
	// #EvilDragon notes: How is a crop not able to be dried? Evne dried watermelons exist in real world. steelcap might not be.
	resistance_flags = FLAMMABLE
	var/dry_grind = FALSE    //If TRUE, this object needs to be dry to be ground up
	var/wine_flavor          //If NULL, this is automatically set to the fruit's flavor. Determines the flavor of the wine if distill_reagent is NULL.

	// -----
	// Plant stats from seed - Check the detail in the seeds code
	var/bitesize_mod = 5
	var/bite_type = PLANT_BITE_TYPE_CONST
	var/can_distill = TRUE
	var/distill_reagent
	var/wine_power = 10
	var/rarity = 0
	// ------

	var/roundstart = 0           //roundstart crops are not researchable. Grown crops will become 0, so that you can scan them.
	var/discovery_points = 200   //Amount of discovery points given for scanning
	var/research_identifier      //used to check if a plant was researched. strange seed needs customised identifier.

/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()
		seed.adjust_potency(50-seed.potency)

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed)
		for(var/datum/plant_gene/T in seed.genes)
			T.on_new_seed(seed, loc)
			T.on_new_plant(src, loc)
		can_distill = seed.can_distill
		seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency/1.33+25, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()

	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points)

	if(!isnull(seed))
		research_identifier = seed.research_identifier



/obj/item/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents && bitesize_mod > 0)
		switch(bite_type)
			if(PLANT_BITE_TYPE_CONST)
				var/calcuation = reagents.total_volume / bitesize_mod % 1
				bitesize = reagents.total_volume / bitesize_mod - calcuation
				// This makes 5~5.999 bites to 5 bites
			if(PLANT_BITE_TYPE_RATIO)
				var/calcuation = 1 / bitesize_mod * 100 % 1
				bitesize = round(1 / bitesize_mod * 100 - calcuation)
				// 51~100% = 1 bites, 34~50% = 2 bites
			if(PLANT_BITE_TYPE_PATCH)
				bitesize = 1
				if(reagents.total_volume>30)
					eat_delay += (reagents.total_volume-30)/2
		if(bitesize<0)
			bitesize = 1
		return 1
	return 0

/obj/item/reagent_containers/food/snacks/grown/examine(user)
	. = ..()
	if(seed)
		for(var/datum/plant_gene/trait/T in seed.genes)
			if(T.examine_line)
				. += T.examine_line

/obj/item/reagent_containers/food/snacks/grown/attack_self(mob/user)
	if(seed)
		if(user.a_intent == INTENT_HARM)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.attack(user)

/obj/item/reagent_containers/food/snacks/grown/attack(mob/M, mob/user, def_zone)
	if(!seed)
		..()
	else
		if(user.a_intent == INTENT_HARM)
			. = ..()
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.attack(M)
		else
			if(ishuman(M) && apply_type == PATCH) // Patch type application
				var/mob/living/L = M
				var/obj/item/bodypart/affecting = L.get_bodypart(check_zone(user.zone_selected))
				if(!affecting)
					balloon_alert(user, "The limb is missing.")
					return
				if(!IS_ORGANIC_LIMB(affecting))
					balloon_alert(user, "[src] doesn't work on robotic limbs.")
					return
				if(!canconsume(M, user))
					return FALSE
				if(iscarbon(M))
					var/mob/living/carbon/C = M
					if(/datum/surgery/dental_implant in C.surgeries)
						return
				if(M == user)
					M.visible_message("<span class='notice'>[user] attempts to [eatverb] [src].</span>")
					if(eat_delay)
						if(!do_mob(user, M, eat_delay))
							return FALSE
					to_chat(M, "<span class='notice'>You [eatverb] [src].</span>")

				else
					M.visible_message("<span class='danger'>[user] attempts to force [M] to [eatverb] [src].</span>", \
										"<span class='userdanger'>[user] attempts to force you to [eatverb] [src].</span>")
					if(!do_mob(user, M))
						return FALSE
					M.visible_message("<span class='danger'>[user] forces [M] to [eatverb] [src].</span>", \
										"<span class='userdanger'>[user] forces you to [eatverb] [src].</span>")

				if(reagents)
					injest()

				return
			. = ..()


/obj/item/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.\n"
		if(seed)
			msg += seed.get_analyzer_text()
		var/reag_txt = ""
		if(seed)
			for(var/reagent_id in seed.reagents_set) //$$$need to change - check health analyzer
				var/datum/reagent/R  = GLOB.chemical_reagents_list[reagent_id]
				var/amt = reagents.get_reagent_amount(reagent_id)
				reag_txt += "\n<span class='info'>- [R.name]: [amt]</span>"

		if(reag_txt)
			msg += reag_txt
			msg += "<br><span class='info'>*---------*</span>"
		to_chat(user, msg)
	else
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attackby(src, O, user)


// Various gene procs
/obj/item/reagent_containers/food/snacks/grown/On_Consume()
	if(iscarbon(usr))
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_consume(src, usr)
	..()

/obj/item/reagent_containers/food/snacks/grown/generate_trash(atom/location)
	if(trash && (ispath(trash, /obj/item/grown) || ispath(trash, /obj/item/reagent_containers/food/snacks/grown)))
		. = new trash(location, seed)
		trash = null
		return
	return ..()

/obj/item/reagent_containers/food/snacks/grown/grind_requirements()
	if(dry_grind && !dry)
		to_chat(usr, "<span class='warning'>[src] needs to be dry before it can be ground up!</span>")
		return
	return TRUE

/obj/item/reagent_containers/food/snacks/grown/on_grind()
	var/nutriment = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(grind_results&&grind_results.len)
		for(var/i in 1 to grind_results.len)
			grind_results[grind_results[i]] = nutriment
		reagents.del_reagent(/datum/reagent/consumable/nutriment)
		reagents.del_reagent(/datum/reagent/consumable/nutriment/vitamin)

/obj/item/reagent_containers/food/snacks/grown/on_juice()
	var/nutriment = reagents.get_reagent_amount(/datum/reagent/consumable/nutriment)
	if(juice_results?.len)
		for(var/i in 1 to juice_results.len)
			juice_results[juice_results[i]] = nutriment
		reagents.del_reagent(/datum/reagent/consumable/nutriment)
		reagents.del_reagent(/datum/reagent/consumable/nutriment/vitamin)

/*
 * Attack self for growns
 *
 * Spawns the trash item at the growns drop_location()
 *
 * Then deletes the grown object
 *
 * Then puts trash item into the hand of user attack selfing, or drops it back on the ground
 */
/obj/item/reagent_containers/food/snacks/grown/shell/attack_self(mob/user)
	var/obj/item/T
	if(trash)
		T = generate_trash()
		T.remove_item_from_storage(get_turf(T))
		qdel(src)
		user.put_in_hands(T, FALSE)
		to_chat(user, "<span class='notice'>You open [src]\'s shell, revealing \a [T].</span>")
