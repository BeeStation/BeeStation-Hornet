///////////////////////////////////////////////////////////////////
					//Food Reagents
//////////////////////////////////////////////////////////////////


// Part of the food code. Also is where all the food
// 	condiments, additives, and such go.


/datum/reagent/consumable
	name = "Consumable"
	chem_flags = CHEMICAL_NOT_DEFINED
	taste_description = "generic food"
	taste_mult = 4
	/// How much nutrition this reagent supplies
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/quality = 0	//affects mood, typically higher for mixed drinks with more complex recipes

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	current_cycle++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER) && !HAS_TRAIT(H, TRAIT_POWERHUNGRY))
			H.adjust_nutrition(nutriment_factor * REM * delta_time)
	holder.remove_reagent(type, metabolization_rate * delta_time)

/datum/reagent/consumable/expose_mob(mob/living/exposed_mob, method=TOUCH, reac_volume)
	. = ..()
	if((method != INGEST) || quality && !HAS_TRAIT(exposed_mob, TRAIT_AGEUSIA))
		return
	switch(quality)
		if (DRINK_BAD)
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
		if (DRINK_NICE)
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_nice)
		if (DRINK_GOOD)
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_good)
		if (DRINK_VERYGOOD)
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_verygood)
		if (DRINK_FANTASTIC)
			SEND_SIGNAL(exposed_mob, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(30, delta_time))
		M.heal_bodypart_damage(brute = brute_heal, burn = burn_heal, updating_health = FALSE)
		. = TRUE
	..()

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	. = ..()
	if(!data)
		return
	// taste data can sometimes be ("salt" = 3, "chips" = 1)
	// and we want it to be in the form ("salt" = 0.75, "chips" = 0.25)
	// which is called "normalizing"
	if(!supplied_data)
		supplied_data = data

	// if data isn't an associative list, this has some WEIRD side effects
	// TODO probably check for assoc list?

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return

	// data for nutriment is one or more (flavour -> ratio)
	// where all the ratio values adds up to 1

	var/list/taste_amounts = list()
	if(data)
		taste_amounts = data.Copy()

	counterlist_scale(taste_amounts, volume)

	var/list/other_taste_amounts = newdata.Copy()
	counterlist_scale(other_taste_amounts, newvolume)

	counterlist_combine(taste_amounts, other_taste_amounts)

	counterlist_normalise(taste_amounts)

	data = taste_amounts

/datum/reagent/consumable/nutriment/vitamin
	name = "Vitamin"
	description = "All the best vitamins, minerals, and carbohydrates the body needs in pure form."

	brute_heal = 1
	burn_heal = 1

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.satiety < 600)
		M.satiety += 30 * REM * delta_time
	. = ..()

/datum/reagent/consumable/nutriment/protein //this is from a tg pr that actually makes use of this reagent. At the moment that I am porting newfood, we are just using it as filler to have something other than vitamins and nutriments.
	name = "Protein"
	description = "A natural polyamide made up of amino acids. An essential constituent of mosts known forms of life."
	brute_heal = 0.8 //Rewards the player for eating a balanced diet.
	nutriment_factor = 9 * REAGENTS_METABOLISM //45% as calorie dense as oil.

/datum/reagent/consumable/nutriment/fat
	name = "Fat"
	description = "Triglycerides found in vegetable oils and fatty animal tissue."
	color = "#f0eed7"
	taste_description = "lard"
	brute_heal = 0
	burn_heal = 1
	nutriment_factor = 18 // Twice as nutritious compared to protein and carbohydrates
	var/fry_temperature = 450 //Around ~350 F (117 C) which deep fryers operate around in the real world

/datum/reagent/consumable/nutriment/fat/expose_obj(obj/exposed_obj, reac_volume)
	if(!holder || (holder.chem_temp <= fry_temperature))
		return
	if(!isitem(exposed_obj) || HAS_TRAIT(exposed_obj, TRAIT_FOOD_FRIED))
		return
	// if the fried obj is indestructible or under the fry blacklist (His Grace), we dont want it to be fried, for obvious reasons
	if(is_type_in_typecache(exposed_obj, GLOB.oilfry_blacklisted_items) || (exposed_obj.resistance_flags & INDESTRUCTIBLE))
		exposed_obj.visible_message(span_notice("The hot oil has no effect on [exposed_obj]!"))
		return
	// if we are holding an item/atom inside, we dont want to arbitrarily fry this item
	if(exposed_obj.atom_storage)
		exposed_obj.visible_message(span_notice("The hot oil splatters about as [exposed_obj] touches it. It seems too full to cook properly!"))
		return

	log_game("[exposed_obj.name] ([exposed_obj.type]) has been deep fried by a reaction with cooking oil reagent at [AREACOORD(exposed_obj)].")
	exposed_obj.visible_message(span_warning("[exposed_obj] rapidly fries as it's splashed with hot oil! Somehow."))
	exposed_obj.AddElement(/datum/element/fried_item, volume)
	exposed_obj.reagents.add_reagent(src.type, reac_volume)

/datum/reagent/consumable/nutriment/fat/expose_mob(mob/living/exposed_mob, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!(method == VAPOR || method == TOUCH) || isnull(holder) || (holder.chem_temp < fry_temperature))
		return

	var/burn_damage = ((holder.chem_temp / fry_temperature) * 0.33) //Damage taken per unit
	if(method & TOUCH)
		burn_damage *= max(1 - touch_protection, 0)
	var/FryLoss = round(min(38, burn_damage * reac_volume))
	if(!HAS_TRAIT(exposed_mob, TRAIT_OIL_FRIED))
		exposed_mob.visible_message(span_warning("The boiling oil sizzles as it covers [exposed_mob]!"), \
		span_userdanger("You're covered in boiling oil!"))
		if(FryLoss)
			exposed_mob.emote("scream")
		playsound(exposed_mob, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
		ADD_TRAIT(exposed_mob, TRAIT_OIL_FRIED, "cooking_oil_react")
		addtimer(CALLBACK(exposed_mob, TYPE_PROC_REF(/mob/living, unfry_mob)), 3)
	if(FryLoss)
		exposed_mob.adjustFireLoss(FryLoss)

/datum/reagent/consumable/nutriment/fat/expose_turf(turf/open/exposed_turf, reac_volume)
	if(!istype(exposed_turf) || isgroundlessturf(exposed_turf) || (reac_volume < 5))
		return
	exposed_turf.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume * 1.5 SECONDS)
	exposed_turf.name = "deep-fried [initial(exposed_turf.name)]"
	exposed_turf.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)

/datum/reagent/consumable/nutriment/fat/oil
	name = "Vegetable Oil"
	description = "A variety of cooking oil derived from plant fats. Used in food preparation and frying."
	color = "#EADD6B" //RGB: 234, 221, 107 (based off of canola oil)
	taste_mult = 0.8
	taste_description = "oil"
	nutriment_factor = 7 //Not very healthy on its own
	metabolization_rate = 10 * REAGENTS_METABOLISM
	default_container = /obj/item/reagent_containers/condiment/vegetable_oil

/datum/reagent/consumable/nutriment/fat/oil/olive
	name = "Olive Oil"
	description = "A high quality oil, suitable for dishes where the oil is a key flavour."
	taste_description = "olive oil"
	color = "#DBCF5C"
	nutriment_factor = 10
	default_container = /obj/item/reagent_containers/condiment/olive_oil

/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_mult = 1.5 // stop sugar drowning out other flavours
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 100 // Hyperglycaemic shock
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/sugar

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, span_userdanger("You go into hyperglycaemic shock! Lay off the twinkies!"))
	M.AdjustSleeping(600)
	. = TRUE

/datum/reagent/consumable/sugar/overdose_process(mob/living/M, delta_time, times_fired)
	M.AdjustSleeping(40 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" // rgb: 137, 150, 19
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "watery milk"

/datum/reagent/consumable/virus_food/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	. = ..()
	for(var/datum/disease/D in M.diseases)
		if(D.spread_flags & DISEASE_SPREAD_SPECIAL || D.spread_flags & DISEASE_SPREAD_NON_CONTAGIOUS)
			continue
		if(DT_PROB(5 * D.stage_prob, delta_time))
			D.update_stage(min(D.stage += 1, D.max_stages))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" // rgb: 121, 35, 0
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "umami"
	default_container = /obj/item/reagent_containers/condiment/soysauce

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" // rgb: 115, 16, 8
	chem_flags = CHEMICAL_RNG_BOTANY
	taste_description = "ketchup"
	default_container = /obj/item/reagent_containers/condiment/ketchup

/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."
	color = "#B31008" // rgb: 179, 16, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "hot peppers"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5
			if(holder.has_reagent(/datum/reagent/cryostylane))
				holder.remove_reagent(/datum/reagent/cryostylane, 5 * REM * delta_time)
			if(isslime(M))
				heating = rand(5, 20)
		if(15 to 25)
			heating = 10
			if(isslime(M))
				heating = rand(10, 20)
		if(25 to 35)
			heating = 15
			if(isslime(M))
				heating = rand(15, 20)
		if(35 to INFINITY)
			heating = 20
			if(isslime(M))
				heating = rand(20, 25)
	M.adjust_bodytemperature(heating * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time)
	..()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "A special oil that noticably chills the body. Extracted from Icepeppers and slimes."
	color = "#8BA6E9" // rgb: 139, 166, 233
	chem_flags = CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "mint"
	///40 joules per unit.
	specific_heat = 40
	default_container = /obj/item/reagent_containers/cup/bottle/frostoil

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5 * REM * delta_time)
			if(isslime(M))
				cooling = -rand(5, 20)
		if(15 to 25)
			cooling = -20
			if(isslime(M))
				cooling = -rand(10, 20)
		if(25 to 35)
			cooling = -30
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(15, 20)
		if(35 to INFINITY)
			cooling = -40
			if(prob(5))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(20, 25)
	M.adjust_bodytemperature(cooling * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 50)
	..()

/datum/reagent/consumable/frostoil/expose_turf(turf/T, reac_volume)
	if(reac_volume >= 5)
		for(var/mob/living/simple_animal/slime/slime_animal in T)
			slime_animal.adjustToxLoss(rand(15,30))
	if(reac_volume >= 1) // Make Freezy Foam and anti-fire grenades!
		if(isopenturf(T))
			var/turf/open/exposed_open_turf = T
			exposed_open_turf.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=100, wet_time_to_add=reac_volume SECONDS) // Is less effective in high pressure/high heat capacity environments. More effective in low pressure.
			var/temperature = exposed_open_turf.air.temperature
			var/heat_capacity = exposed_open_turf.air.heat_capacity()
			exposed_open_turf.air.temperature = max(exposed_open_turf.air.temperature - ((temperature - TCMB) * (heat_capacity * reac_volume * specific_heat) / (heat_capacity + reac_volume * specific_heat)) / heat_capacity, TCMB) // Exchanges environment temperature with reagent. Reagent is at 2.7K with a heat capacity of 40J per unit.

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	color = "#B31008" // rgb: 179, 16, 8
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "scorching agony"
	default_container = /obj/item/reagent_containers/cup/bottle/capsaicin

/datum/reagent/consumable/condensedcapsaicin/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!ishuman(M) && !ismonkey(M))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		//check for protection
		//actually handle the pepperspray effects
		if(!victim.is_eyes_covered() || !victim.is_mouth_covered())
			victim.emote("cry")
			victim.blur_eyes(5) // 10 seconds
			victim.adjust_blindness(3) // 6 seconds
			victim.Knockdown(3 SECONDS)
			if(prob(5))
				victim.emote("scream")
			victim.confused = max(M.confused, 5) // 10 seconds
			victim.add_movespeed_modifier(/datum/movespeed_modifier/reagent/pepperspray)
			addtimer(CALLBACK(victim, TYPE_PROC_REF(/mob, remove_movespeed_modifier), /datum/movespeed_modifier/reagent/pepperspray), 10 SECONDS)
		victim.update_damage_hud()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(5, delta_time))
		M.visible_message(span_warning("[M] [pick("dry heaves!","coughs!","splutters!")]"))
	..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255,255,255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "salt"
	default_container = /obj/item/reagent_containers/condiment/saltshaker

/datum/reagent/consumable/sodiumchloride/expose_turf(turf/exposed_turf, reac_volume) //Creates an umbra-blocking salt pile
	if(!istype(exposed_turf) || (reac_volume < 1))
		return
	new /obj/effect/decal/cleanable/food/salt(exposed_turf)

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	reagent_state = SOLID
	// no color (ie, black)
	taste_description = "pepper"
	default_container = /obj/item/reagent_containers/condiment/peppermill

/datum/reagent/consumable/cocoa
	name = "Cocoa Powder"
	description = "A fatty, bitter paste made from cocoa beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "bitterness"

/datum/reagent/consumable/cocoa/on_mob_add(mob/living/carbon/M)
	.=..()
	if(iscatperson(M))
		to_chat(M, span_warning("Your insides revolt at the presence of lethal chocolate!"))
		M.vomit(20)

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" // rgb: 231, 0, 231
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "mushroom"

/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(ispsyphoza(M))
		return
	if(!M.slurring)
		M.slurring = 1 * REM * delta_time
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(5 * REM * delta_time)
			M.set_drugginess(30 * REM * delta_time)
			if(DT_PROB(5, delta_time))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(10 * REM * delta_time)
			M.Dizzy(10 * REM * delta_time)
			M.set_drugginess(35 * REM * delta_time)
			if(DT_PROB(10, delta_time))
				M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			M.Jitter(20 * REM * delta_time)
			M.Dizzy(20 * REM * delta_time)
			M.set_drugginess(40 * REM * delta_time)
			if(DT_PROB(16, delta_time))
				M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/consumable/garlic //NOTE: having garlic in your blood stops vampires from biting you.
	name = "Garlic Juice"
	description = "Crushed garlic. Chefs love it, but it can make you smell bad."
	color = "#FEFEFE"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "garlic"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(isvampire(M)) //incapacitating but not lethal. Unfortunately, vampires cannot vomit.
		if(DT_PROB(min(current_cycle/2, 12.5), delta_time))
			to_chat(M, span_danger("You can't get the scent of garlic out of your nose! You can barely think..."))
			M.Paralyze(10)
			M.Jitter(10)
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job == JOB_NAME_COOK)
			if(DT_PROB(10, delta_time)) //stays in the system much longer than sprinkles/banana juice, so heals slower to partially compensate
				H.heal_bodypart_damage(1,1, 0)
				. = TRUE
	..()

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#FF00FF" // rgb: 255, 0, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_BOTANY
	taste_description = "childhood whimsy"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.mind && HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(1 * REM * delta_time, 1 * REM * delta_time, 0)
		. = TRUE
	..()

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preparation of certain chemicals and foods."
	color = "#365E30" // rgb: 54, 94, 48
	chem_flags = NONE
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/enzyme

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "dry and cheap noodles"
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "wet and cheap noodles"
	default_container = /obj/item/reagent_containers/cup/glass/dry_ramen

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time, 0, M.get_body_temp_normal())
	..()

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" // rgb: 48, 32, 0
	chem_flags = NONE
	taste_description = "wet and cheap noodles on fire"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/target_mob, delta_time, times_fired)
	target_mob.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT * REM * delta_time)
	..()

/datum/reagent/consumable/flour
	name = "Flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 0, 0, 0
	chem_flags = NONE
	taste_description = "chalky wheat"
	default_container = /obj/item/reagent_containers/condiment/flour

/datum/reagent/consumable/flour/expose_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/food/flour/reagentdecal = new(T)
		reagentdecal = locate() in T //Might have merged with flour already there.
		if(reagentdecal)
			reagentdecal.reagents.add_reagent(/datum/reagent/consumable/flour, reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	color = "#801E28" // rgb: 128, 30, 40
	chem_flags = NONE
	taste_description = "cherry"
	default_container = /obj/item/reagent_containers/condiment/cherryjelly

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Blue and tastier kind of cherry jelly."
	color = "#00F0FF"
	chem_flags = NONE
	taste_description = "blue cherry"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "Tiny nutritious grains. A fast and filling meal!"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" // rgb: 0, 0, 0
	chem_flags = NONE
	taste_description = "rice"
	default_container = /obj/item/reagent_containers/condiment/rice

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	chem_flags = CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "vanilla"

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "It's full of protein."
	nutriment_factor = 4 * REAGENTS_METABOLISM
	color = "#FFB500"
	chem_flags = NONE
	taste_description = "egg"

/datum/reagent/consumable/eggwhite
	name = "Egg White"
	description = "It's full of even more protein."
	nutriment_factor = 1.5 * REAGENTS_METABOLISM
	color = "#fffdf7"
	taste_description = "bland egg"
	chem_flags = NONE

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "A slippery solution."
	color = "#DBCE95"
	chem_flags = NONE
	taste_description = "slime"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Decays into sugar."
	color = "#DBCE95"
	chem_flags = NONE
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "sweet slime"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	holder.add_reagent(/datum/reagent/consumable/sugar, 3 * REM * delta_time)
	..()

/datum/reagent/consumable/honey
	name = "Honey"
	description = "Sweet, sweet honey that decays into sugar. Has antibacterial and natural healing properties."
	color = "#d3a308"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	nutriment_factor = 0 * REAGENTS_METABOLISM //Honey converts 2:5 into sugar, so this may as well be 15
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "sweetness"
	default_container = /obj/item/reagent_containers/condiment/honey

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	holder.add_reagent(/datum/reagent/consumable/sugar, 1 * REM * delta_time)
	M.adjustBruteLoss(-1, 0)
	M.adjustFireLoss(-1, 0)
	M.adjustOxyLoss(-1, 0)
	M.adjustToxLoss(-1, 0)
	..()

/datum/reagent/consumable/honey/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
		var/mob/living/carbon/C = M
		for(var/s in C.surgeries)
			var/datum/surgery/S = s
			S.speed_modifier = max(0.6, S.speed_modifier) // +60% surgery speed on each step, compared to bacchus' blessing's ~46%
	..()

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "An white and oily mixture of mixed egg yolks."
	color = "#DFDFDF"
	chem_flags = NONE
	taste_description = "mayonnaise"
	default_container = /obj/item/reagent_containers/condiment/mayonnaise

/datum/reagent/consumable/mold // yeah, ok, togopal, I guess you could call that a condiment
	name = "Mold"
	description = "This condiment will make any food break the mold. Or your stomach."
	color ="#708a88"
	taste_description = "rancid fungus"
	chem_flags = NONE

/datum/reagent/consumable/eggrot
	name = "Rotten Eggyolk"
	description = "It smells absolutely dreadful."
	color ="#708a88"
	taste_description = "rotten eggs"
	chem_flags = NONE

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "A blinding substance extracted from certain onions."
	color = "#c0c9a0"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "bitterness"

/datum/reagent/consumable/tearjuice/expose_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	var/unprotected = FALSE
	switch(method)
		if(INGEST)
			unprotected = TRUE
		if(INJECT)
			unprotected = FALSE
		else	//Touch or vapor
			if(!M.is_mouth_covered() && !M.is_eyes_covered())
				unprotected = TRUE
	if(unprotected)
		if(!M.get_organ_slot(ORGAN_SLOT_EYES))	//can't blind somebody with no eyes
			to_chat(M, span_notice("Your eye sockets feel wet."))
		else
			if(!M.eye_blurry)
				to_chat(M, span_warning("Tears well up in your eyes!"))
			M.adjust_blindness(2)
			M.blur_eyes(5)
	..()

/datum/reagent/consumable/tearjuice/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	..()
	if(M.eye_blurry)	//Don't worsen vision if it was otherwise fine
		M.blur_eyes(4 * REM * delta_time)
		if(DT_PROB(5, delta_time))
			to_chat(M, span_warning("Your eyes sting!"))
			M.adjust_blindness(2)


/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "A bioengineered protein-nutrient structure designed to decompose in high saturation. In layman's terms, it won't get you fat."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" // rgb: 102, 67, 48
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(M.nutrition > NUTRITION_LEVEL_FULL - 25)
		M.adjust_nutrition(-3 * REM * nutriment_factor * delta_time)
	..()

/datum/reagent/consumable/maltodextrin
	name = "Maltodextrin"
	description = "A common filler found in processed foods. Foods containing it will leave you feeling full for a much shorter time."
	color = "#d4e1ee"
	chem_flags = CHEMICAL_RNG_GENERAL
	taste_mult = 0.1 // Taste the salt and sugar not the cheap carbs
	taste_description = "processed goodness"
	nutriment_factor = -0.3
	metabolization_rate = 0.05 * REAGENTS_METABOLISM //Each unit will last 50 ticks

/datum/reagent/consumable/maltodextrin/microplastics
	name = "Microplastics"
	description = "A byproduct of industrial clothing, Cloths containing it will weaken you in the long term!"
	color = "#dbd6cb"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN // The funny
	taste_description = "Plastic"
	nutriment_factor = -0.15 // it's plastic after all, it taste really good and it's real special!
	metabolization_rate = 0.025 * REAGENTS_METABOLISM //A bit more than maltodextrin

/datum/reagent/consumable/maltodextrin/microplastics/on_mob_metabolize(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	H.physiology.tox_mod *= 2

/datum/reagent/consumable/maltodextrin/microplastics/on_mob_end_metabolize(mob/living/carbon/human/H)
	. = ..()
	if(!istype(H))
		return
	H.physiology.tox_mod *= 0.5

////Lavaland Flora Reagents////

/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	description = "An ichor derived from a certain mushroom. Makes for a bad time."
	color = "#1d043d"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "bitter mushroom"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(current_cycle >= 10)
		M.Unconscious(40 * REM * delta_time, FALSE)
		. = TRUE
	if(DT_PROB(10, delta_time))
		M.losebreath += 4
		M.adjustOrganLoss(ORGAN_SLOT_BRAIN, 2*REM, 150)
		M.adjustToxLoss(3*REM,0)
		M.adjustStaminaLoss(10*REM,0)
		M.blur_eyes(5)
		. = TRUE
	..()


/datum/reagent/consumable/tinlux
	name = "Tinea Luxor"
	description = "A stimulating ichor which causes luminescent fungi to grow on the skin. "
	color = "#b5a213"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "tingling mushroom"
	//Lazy list of mobs affected by the luminosity of this reagent.
	var/list/mobs_affected

/datum/reagent/consumable/tinlux/expose_mob(mob/living/M)
	add_reagent_light(M)

/datum/reagent/consumable/tinlux/on_mob_end_metabolize(mob/living/M)
	remove_reagent_light(M)

/datum/reagent/consumable/tinlux/proc/on_living_holder_deletion(mob/living/source)

	remove_reagent_light(source)

/datum/reagent/consumable/tinlux/proc/add_reagent_light(mob/living/living_holder)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = living_holder.mob_light(2)
	LAZYSET(mobs_affected, living_holder, mob_light_obj)
	RegisterSignal(living_holder, COMSIG_PARENT_QDELETING, PROC_REF(on_living_holder_deletion))

/datum/reagent/consumable/tinlux/proc/remove_reagent_light(mob/living/living_holder)
	UnregisterSignal(living_holder, COMSIG_PARENT_QDELETING)
	var/obj/effect/dummy/lighting_obj/moblight/mob_light_obj = LAZYACCESS(mobs_affected, living_holder)
	LAZYREMOVE(mobs_affected, living_holder)
	if(mob_light_obj)
		qdel(mob_light_obj)


/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	description = "A bubbly paste that heals wounds of the skin."
	color = "#d3a308"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY | CHEMICAL_GOAL_BOTANIST_HARVEST
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "fruity mushroom"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(DT_PROB(55, delta_time))
		M.adjustBruteLoss(-1, 0)
		M.adjustFireLoss(-1, 0)
		. = TRUE
	..()

/datum/reagent/consumable/clownstears
	name = "Clown's Tears"
	description = "The sorrow and melancholy of a thousand bereaved clowns, forever denied their Honkmechs."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#eef442" // rgb: 238, 244, 66
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN
	taste_description = "mournful honking"


/datum/reagent/consumable/liquidelectricity
	name = "Liquid Electricity"
	description = "The blood of Ethereals, and the stuff that keeps them going. Great for them, horrid for anyone else."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#97ee63"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "pure electrictiy"

/datum/reagent/consumable/liquidelectricity/on_mob_life(mob/living/carbon/M, delta_time, times_fired)
	if(HAS_TRAIT(M, TRAIT_POWERHUNGRY))
		var/obj/item/organ/stomach/battery/stomach = M.get_organ_slot(ORGAN_SLOT_STOMACH)
		if(istype(stomach))
			stomach.adjust_charge(40*REM)
	else if(DT_PROB(1.5, delta_time)) //scp13 optimization
		M.electrocute_act(rand(3,5), "Liquid Electricity in their body", 1) //lmao at the newbs who eat energy bars
		playsound(M, "sparks", 50, 1)
	return ..()

/datum/reagent/consumable/chlorophyll
	name = "Liquid Chlorophyll"
	description = "A plant-specific elixir of life."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#00df30"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_description = "bitter, dry, broccoli soup"

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "A space age artifical sweetener."
	nutriment_factor = 0
	metabolization_rate = 2 * REAGENTS_METABOLISM
	reagent_state = SOLID
	color = "#FFFFFF" // rgb: 255, 255, 255
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY
	taste_mult = 8
	taste_description = "sweetness"
	overdose_threshold = 17

/datum/reagent/consumable/astrotame/overdose_process(mob/living/carbon/M, delta_time, times_fired)
	if(M.disgust < 80)
		M.adjust_disgust(10 * REM * delta_time)
	..()
	. = TRUE

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Who would have guessed that heating sugar is so delicious?"
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#C65A00"
	chem_flags = NONE
	taste_mult = 2
	taste_description = "bitter sweetness"
	reagent_state = SOLID

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Sweet, Smokey, Savory, and gets everywhere. Perfect for Grilling."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#78280A" // rgb: 120 40, 10
	chem_flags = NONE
	taste_mult = 2.5 //sugar's 1.5, capsacin's 1.5, so a good middle ground.
	taste_description = "smokey sweetness"
	default_container = /obj/item/reagent_containers/condiment/bbqsauce

/datum/reagent/consumable/char
	name = "Char"
	description = "Essence of the grill. Has strange properties when overdosed."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#C8C8C8"
	chem_flags = NONE
	taste_mult = 6
	taste_description = "smoke"
	overdose_threshold = 25

/datum/reagent/consumable/char/overdose_process(mob/living/M, delta_time, times_fired)
	if(DT_PROB(13, delta_time))
		M.say(pick("I hate my wife.", "I just want to grill for God's sake.", "I wish I could just go on my lawnmower and cut the grass.", "Yep, Quake. That was a good game...", "Yeah, my PDA has wi-fi. A wife I hate."), forced = /datum/reagent/consumable/char)
	..()

/datum/reagent/consumable/nutriment/cloth
	name = "Cloth"
	description = "The finest fabric in the universe..."
	reagent_state = SOLID
	color = "#c2bbb7"
	chem_flags = CHEMICAL_RNG_GENERAL | CHEMICAL_RNG_FUN | CHEMICAL_GOAL_BOTANIST_HARVEST
	taste_description = "a roll of gauze"
	metabolization_rate = 2 * REAGENTS_METABOLISM //speedy metabolization (per tick)

/datum/reagent/consumable/nutriment/cloth/on_mob_metabolize(mob/living/carbon/M)
	holder.add_reagent(/datum/reagent/consumable/nutriment, 1)
	holder.add_reagent(/datum/reagent/consumable/maltodextrin/microplastics, 1)

/datum/reagent/consumable/gravy
	name = "Gravy"
	description = "A mixture of flour, water, and the juices of cooked meat."
	taste_description = "gravy"
	color = "#623301"
	taste_mult = 1.2
	chem_flags = NONE

/datum/reagent/consumable/pancakebatter
	name = "pancake batter"
	description = "A very milky batter. 5 units of this on the griddle makes a mean pancake."
	taste_description = "milky batter"
	color = "#fccc98"
	chem_flags = NONE

/datum/reagent/consumable/whipped_cream
	name = "Whipped Cream"
	description = "A white fluffy cream made from whipping cream at intense speed."
	color = "#efeff0"
	nutriment_factor = 4
	taste_description = "fluffy sweet cream"
	chem_flags = NONE
	//default_container = /obj/item/reagent_containers/condiment/creamer
