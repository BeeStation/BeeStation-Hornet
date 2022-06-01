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
	var/bite_type = PLANT_BITE_TYPE_DYNAM
	var/can_distill = TRUE
	var/distill_reagent
	var/wine_power = 10
	var/rarity = 0
	// ------

	var/roundstart = 0           //roundstart crops are not researchable. Grown crops will become 0, so that you can scan them.
	var/discovery_points = 200   //Amount of discovery points given for scanning
	var/research_identifier      //used to check if a plant was researched. strange seed needs customised identifier.
	var/eat_delay = 30 // used for patch trait

/obj/item/reagent_containers/food/snacks/grown/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	if(!tastes)
		tastes = list("[name]" = 1)

	if(new_seed)
		seed = new_seed.Copy()
	else if(ispath(seed))
		// This is for adminspawn or map-placed growns. They get the default stats of their seed type.
		seed = new seed()

	pixel_x = rand(-5, 5)
	pixel_y = rand(-5, 5)

	if(dried_type == -1)
		dried_type = src.type

	if(seed)
		for(var/datum/plant_gene/T in seed.genes)
			T.on_new_plant(src, loc) // apply seed genes on this crop
		can_distill = seed.can_distill
		seed.prepare_result(src)
		transform *= TRANSFORM_USING_VARIABLE(seed.potency/1.33+25, 100) + 0.5 //Makes the resulting produce's sprite larger or smaller based on potency!
		add_juice()

	if(discovery_points)
		AddComponent(/datum/component/discoverable, discovery_points)

	if(!isnull(seed))
		research_identifier = seed.research_identifier

/obj/item/reagent_containers/food/snacks/grown/Destroy()
	if(seed)
		qdel(seed)
		seed = null
	return ..()

/obj/item/reagent_containers/food/snacks/grown/proc/add_juice()
	if(reagents && bitesize_mod > 0)
		switch(bite_type)
			if(PLANT_BITE_TYPE_DYNAM)
				var/calcuation = reagents.total_volume % bitesize_mod
				bitesize = (reagents.total_volume-calcuation) / bitesize_mod
				// This makes 5~5.999 bites to 5 bites
			if(PLANT_BITE_TYPE_CONST)
				bitesize = round(bitesize_mod)
				// Always the constant value
			if(PLANT_BITE_TYPE_PATCH)
				bitesize = 1
				eat_delay += reagents.total_volume/2
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


// ----------grown plant behaves---------
// Squash
/obj/item/reagent_containers/food/snacks/grown/proc/squash(atom/target)
	var/turf/T = get_turf(target)
	forceMove(T)
	if(ispath(splat_type, /obj/effect/decal/cleanable/food/plant_smudge))
		if(filling_color)
			var/obj/O = new splat_type(T)
			O.color = filling_color
			O.name = "[name] smudge"
	else if(splat_type)
		new splat_type(T)

	if(trash)
		generate_trash(T)

	visible_message("<span class='warning'>[src] has been squashed.</span>","<span class='italics'>You hear a smack.</span>")
	if(seed)
		for(var/datum/plant_gene/trait/trait in seed.genes)
			trait.on_squash(src, target)

	if(seed.get_gene(/datum/plant_gene/trait/noreact))
		visible_message("<span class='warning'>[src] crumples, and bubbles ominously as its contents mix.</span>")
		addtimer(CALLBACK(src, .proc/squashreact), 20)
	else
		reagents.reaction(T)
		for(var/A in T)
			reagents.reaction(A)
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/proc/squashreact()
	for(var/datum/plant_gene/trait/trait in seed.genes)
		trait.on_squashreact(src)
	qdel(src)

/obj/item/reagent_containers/food/snacks/grown/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_throw_impact(src, hit_atom)
			if(seed.get_gene(/datum/plant_gene/trait/squash))
				squash(hit_atom)

// attack
/obj/item/reagent_containers/food/snacks/grown/attack_self(mob/user)
	if(user.a_intent == INTENT_HARM)
		if(seed && iscarbon(user))
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attack(user)
	..()

/obj/item/reagent_containers/food/snacks/grown/attack(mob/M, mob/user, def_zone)
	if(!seed)
		. = ..()
	else
		if(user.a_intent == INTENT_HARM)
			. = ..()
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attack(M) // proc plant efects
		else
			if(iscarbon(M) && apply_type == PATCH && seed.get_gene(/datum/plant_gene/trait/squash)) // Patch type application

				// duplication code from Patch.dm
				var/mob/living/carbon/C = M
				var/obj/item/bodypart/affecting = C.get_bodypart(check_zone(user.zone_selected))
				if(!affecting)
					balloon_alert(user, "The limb is missing.")
					return
				if(!IS_ORGANIC_LIMB(affecting))
					balloon_alert(user, "[src] doesn't work on robotic limbs.")
					return

				// and this is from Pill.dm
				if(M == user)
					M.visible_message("<span class='notice'>[user] attempts to [eatverb] [src].</span>")
					if(eat_delay)
						if(!do_mob(user, M, eat_delay))
							visible_message(M, "<span class='notice'>[user] is interrupted to [eatverb] [src]!</span>")
							if(prob(50))
								squash(loc)
							else
								squash(user)
							return
					to_chat(M, "<span class='notice'>You [eatverb] [src].</span>")
				else
					M.visible_message("<span class='danger'>[user] attempts to force [M] to [eatverb] [src].</span>", \
										"<span class='userdanger'>[user] attempts to force you to [eatverb] [src].</span>")
					if(!do_mob(user, M, eat_delay))
						to_chat(M, "<span class='notice'>You are interrupted to [eatverb] [src]!</span>")
						if(prob(50))
							squash(loc)
						else if(prob(50))
							squash(user)
						else
							squash(M)
						return
					M.visible_message("<span class='danger'>[user] forces [M] to [eatverb] [src].</span>", \
										"<span class='userdanger'>[user] forces you to [eatverb] [src].</span>")

				if(reagents)
					act_eat(M, user)

				return
			. = ..()
	if(!. && !reagents.total_volume)
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/attackby(obj/item/O, mob/user, params)
	..()
	if (istype(O, /obj/item/plant_analyzer))
		var/msg = "<span class='info'>*---------*\n This is \a <span class='name'>[src]</span>.\n"
		if(seed)
			msg += seed.get_analyzer_text()
		var/reag_txt = ""
		if(seed)
			if(length(reagents.reagent_list))
				for(var/datum/reagent/R in reagents.reagent_list)
					reag_txt += "\n<span class='info'>- [R.name]: [R.volume] units</span>"
		if(reag_txt)
			msg += reag_txt
			msg += "<br><span class='info'>*---------*</span>"
		to_chat(user, msg)
	else
		if(seed)
			for(var/datum/plant_gene/trait/T in seed.genes)
				T.on_attackby(src, O, user)


/obj/item/reagent_containers/pill/patch/canconsume(mob/eater, mob/user)
	if(!iscarbon(eater))
		return 0
	return 1

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
