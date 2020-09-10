
					







/datum/reagent/consumable
	name = "Consumable"
	taste_description = "generic food"
	taste_mult = 4
	var/nutriment_factor = 1 * REAGENTS_METABOLISM
	var/quality = 0	
	random_unrestricted = FALSE

/datum/reagent/consumable/on_mob_life(mob/living/carbon/M)
	current_cycle++
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(!HAS_TRAIT(H, TRAIT_NOHUNGER))
			H.adjust_nutrition(nutriment_factor)
	holder.remove_reagent(type, metabolization_rate)

/datum/reagent/consumable/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(method == INGEST)
		if (quality && !HAS_TRAIT(M, TRAIT_AGEUSIA))
			switch(quality)
				if (DRINK_BAD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_bad)
				if (DRINK_NICE)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_nice)
				if (DRINK_GOOD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_good)
				if (DRINK_VERYGOOD)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_verygood)
				if (DRINK_FANTASTIC)
					SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, "quality_drink", /datum/mood_event/quality_fantastic)
	return ..()

/datum/reagent/consumable/nutriment
	name = "Nutriment"
	description = "All the vitamins, minerals, and carbohydrates the body needs in pure form."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" 
	random_unrestricted = TRUE

	var/brute_heal = 1
	var/burn_heal = 0

/datum/reagent/consumable/nutriment/on_mob_life(mob/living/carbon/M)
	if(prob(50))
		M.heal_bodypart_damage(brute_heal,burn_heal, 0)
		. = 1
	..()

/datum/reagent/consumable/nutriment/on_new(list/supplied_data)
	
	
	
	if(!supplied_data)
		supplied_data = data

	
	

	data = counterlist_normalise(supplied_data)

/datum/reagent/consumable/nutriment/on_merge(list/newdata, newvolume)
	if(!islist(newdata) || !newdata.len)
		return

	
	

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

/datum/reagent/consumable/nutriment/vitamin/on_mob_life(mob/living/carbon/M)
	if(M.satiety < 600)
		M.satiety += 30
	. = ..()

/datum/reagent/consumable/cooking_oil
	name = "Cooking Oil"
	description = "A variety of cooking oil derived from fat or plants. Used in food preparation and frying."
	color = "#EADD6B" 
	taste_mult = 0.8
	taste_description = "oil"
	nutriment_factor = 7 * REAGENTS_METABOLISM 
	metabolization_rate = 10 * REAGENTS_METABOLISM
	var/fry_temperature = 450 
	var/boiling 

/datum/reagent/consumable/cooking_oil/reaction_obj(obj/O, reac_volume)
	if(holder && holder.chem_temp >= fry_temperature)
		if(isitem(O) && !istype(O, /obj/item/reagent_containers/food/snacks/deepfryholder))
			log_game("[O.name] ([O.type]) has been deep fried by a reaction with cooking oil reagent at [AREACOORD(O)].")
			O.loc.visible_message("<span class='warning'>[O] rapidly fries as it's splashed with hot oil! Somehow.</span>")
			var/obj/item/reagent_containers/food/snacks/deepfryholder/F = new(O.drop_location(), O)
			F.fry(volume)
			F.reagents.add_reagent(/datum/reagent/consumable/cooking_oil, reac_volume)

/datum/reagent/consumable/cooking_oil/reaction_mob(mob/living/M, method = TOUCH, reac_volume, show_message = 1, touch_protection = 0)
	if(!istype(M))
		return
	if(holder && holder.chem_temp >= fry_temperature)
		boiling = TRUE
	if(method == VAPOR || method == TOUCH) 
		if(boiling)
			M.visible_message("<span class='warning'>The boiling oil sizzles as it covers [M]!</span>", \
			"<span class='userdanger'>You're covered in boiling oil!</span>")
			M.emote("scream")
			playsound(M, 'sound/machines/fryer/deep_fryer_emerge.ogg', 25, TRUE)
			var/oil_damage = (holder.chem_temp / fry_temperature) * 0.33 
			M.adjustFireLoss(min(35, oil_damage * reac_volume)) 
	else
		..()
	return TRUE

/datum/reagent/consumable/cooking_oil/reaction_turf(turf/open/T, reac_volume)
	if(!istype(T) || isgroundlessturf(T))
		return
	if(reac_volume >= 5)
		T.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume * 1.5 SECONDS)
		T.name = "deep-fried [initial(T.name)]"
		T.add_atom_colour(color, TEMPORARY_COLOUR_PRIORITY)

/datum/reagent/consumable/sugar
	name = "Sugar"
	description = "The organic compound commonly known as table sugar and sometimes called saccharose. This white, odorless, crystalline powder has a pleasing, sweet taste."
	reagent_state = SOLID
	color = "#FFFFFF" 
	taste_mult = 1.5 
	nutriment_factor = 10 * REAGENTS_METABOLISM
	metabolization_rate = 2 * REAGENTS_METABOLISM
	overdose_threshold = 200 
	taste_description = "sweetness"

/datum/reagent/consumable/sugar/overdose_start(mob/living/M)
	to_chat(M, "<span class='userdanger'>You go into hyperglycaemic shock! Lay off the twinkies!</span>")
	M.AdjustSleeping(600, FALSE)
	. = 1

/datum/reagent/consumable/sugar/overdose_process(mob/living/M)
	M.AdjustSleeping(40, FALSE)
	..()
	. = 1

/datum/reagent/consumable/virus_food
	name = "Virus Food"
	description = "A mixture of water and milk. Virus cells can use this mixture to reproduce."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#899613" 
	taste_description = "watery milk"

/datum/reagent/consumable/virus_food/on_mob_life(mob/living/carbon/M)
	. = ..()
	for(var/datum/disease/D in M.diseases)
		if(prob(D.stage_prob * 10))
			D.update_stage(min(D.stage += 1, D.max_stages))

/datum/reagent/consumable/soysauce
	name = "Soysauce"
	description = "A salty sauce made from the soy plant."
	nutriment_factor = 2 * REAGENTS_METABOLISM
	color = "#792300" 
	taste_description = "umami"

/datum/reagent/consumable/ketchup
	name = "Ketchup"
	description = "Ketchup, catsup, whatever. It's tomato paste."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#731008" 
	taste_description = "ketchup"


/datum/reagent/consumable/capsaicin
	name = "Capsaicin Oil"
	description = "This is what makes chilis hot."
	color = "#B31008" 
	taste_description = "hot peppers"
	taste_mult = 1.5

/datum/reagent/consumable/capsaicin/on_mob_life(mob/living/carbon/M)
	var/heating = 0
	switch(current_cycle)
		if(1 to 15)
			heating = 5 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent(/datum/reagent/cryostylane))
				holder.remove_reagent(/datum/reagent/cryostylane, 5)
			if(isslime(M))
				heating = rand(5,20)
		if(15 to 25)
			heating = 10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(10,20)
		if(25 to 35)
			heating = 15 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(15,20)
		if(35 to INFINITY)
			heating = 20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				heating = rand(20,25)
	M.adjust_bodytemperature(heating)
	..()

/datum/reagent/consumable/frostoil
	name = "Frost Oil"
	description = "A special oil that noticably chills the body. Extracted from Icepeppers and slimes."
	color = "#8BA6E9" 
	taste_description = "mint"
	random_unrestricted = TRUE

/datum/reagent/consumable/frostoil/on_mob_life(mob/living/carbon/M)
	var/cooling = 0
	switch(current_cycle)
		if(1 to 15)
			cooling = -10 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(holder.has_reagent(/datum/reagent/consumable/capsaicin))
				holder.remove_reagent(/datum/reagent/consumable/capsaicin, 5)
			if(isslime(M))
				cooling = -rand(5,20)
		if(15 to 25)
			cooling = -20 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(isslime(M))
				cooling = -rand(10,20)
		if(25 to 35)
			cooling = -30 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(1))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(15,20)
		if(35 to INFINITY)
			cooling = -40 * TEMPERATURE_DAMAGE_COEFFICIENT
			if(prob(5))
				M.emote("shiver")
			if(isslime(M))
				cooling = -rand(20,25)
	M.adjust_bodytemperature(cooling, 50)
	..()

/datum/reagent/consumable/frostoil/reaction_turf(turf/T, reac_volume)
	if(reac_volume >= 5)
		for(var/mob/living/simple_animal/slime/M in T)
			M.adjustToxLoss(rand(15,30))
	if(reac_volume >= 1) 
		if(isopenturf(T))
			var/turf/open/OT = T
			OT.MakeSlippery(wet_setting=TURF_WET_ICE, min_wet_time=100, wet_time_to_add=reac_volume SECONDS) 
			OT.air.set_temperature(OT.air.return_temperature() - MOLES_CELLSTANDARD*100*reac_volume/OT.air.heat_capacity()) 

/datum/reagent/consumable/condensedcapsaicin
	name = "Condensed Capsaicin"
	description = "A chemical agent used for self-defense and in police work."
	color = "#B31008" 
	taste_description = "scorching agony"

/datum/reagent/consumable/condensedcapsaicin/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!ishuman(M) && !ismonkey(M))
		return

	var/mob/living/carbon/victim = M
	if(method == TOUCH || method == VAPOR)
		var/pepper_proof = victim.is_pepper_proof()

		
		
		if (!(pepper_proof)) 
			if(prob(5))
				victim.emote("scream")
			victim.blur_eyes(5) 
			victim.blind_eyes(3) 
			victim.confused = max(M.confused, 5) 
			victim.Knockdown(3 SECONDS)
			victim.add_movespeed_modifier(MOVESPEED_ID_PEPPER_SPRAY, update=TRUE, priority=100, multiplicative_slowdown=0.25, blacklisted_movetypes=(FLYING|FLOATING))
			addtimer(CALLBACK(victim, /mob.proc/remove_movespeed_modifier, MOVESPEED_ID_PEPPER_SPRAY), 10 SECONDS)
		victim.update_damage_hud()

/datum/reagent/consumable/condensedcapsaicin/on_mob_life(mob/living/carbon/M)
	if(prob(5))
		M.visible_message("<span class='warning'>[M] [pick("dry heaves!","coughs!","splutters!")]</span>")
	..()

/datum/reagent/consumable/sodiumchloride
	name = "Table Salt"
	description = "A salt made of sodium chloride. Commonly used to season food."
	reagent_state = SOLID
	color = "#FFFFFF" 
	taste_description = "salt"

/datum/reagent/consumable/sodiumchloride/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	if(M.has_bane(BANE_SALT))
		M.mind.disrupt_spells(-200)
	if(method == INGEST && is_species(M, /datum/species/squid))
		to_chat(M, "<span class='danger'>Your tongue shrivels as you taste the salt! It burns!</span>")
		if(prob(25))
			M.emote("scream")
		M.adjustFireLoss(5, TRUE)
	else if(method == TOUCH && is_species(M, /datum/species/squid))
		if(M.incapacitated())
			return
		var/obj/item/I = M.get_active_held_item()
		M.throw_item(get_ranged_target_turf(M, pick(GLOB.alldirs), rand(1, 3)))
		to_chat(M, "<span class='warning'>The salt causes your arm to spasm!</span>")
		M.log_message("threw [I] due to a Muscle Spasm", LOG_ATTACK)

/datum/reagent/consumable/sodiumchloride/reaction_turf(turf/T, reac_volume) 
	if(!istype(T))
		return
	if(reac_volume < 1)
		return
	new/obj/effect/decal/cleanable/food/salt(T)

/datum/reagent/consumable/blackpepper
	name = "Black Pepper"
	description = "A powder ground from peppercorns. *AAAACHOOO*"
	reagent_state = SOLID
	
	taste_description = "pepper"

/datum/reagent/consumable/coco
	name = "Coco Powder"
	description = "A fatty, bitter paste made from coco beans."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" 
	taste_description = "bitterness"
/datum/reagent/consumable/coco/on_mob_add(mob/living/carbon/M)
	.=..()
	if(iscatperson(M))
		to_chat(M, "<span class='warning'>Your insides revolt at the presence of lethal chocolate!</span>")
		M.vomit(20)



/datum/reagent/consumable/hot_coco
	name = "Hot Chocolate"
	description = "Made with love! And coco beans."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#403010" 
	taste_description = "creamy chocolate"
	glass_icon_state  = "chocolateglass"
	glass_name = "glass of chocolate"
	glass_desc = "Tasty."

/datum/reagent/consumable/hot_coco/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(5 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/drug/mushroomhallucinogen
	name = "Mushroom Hallucinogen"
	description = "A strong hallucinogenic drug derived from certain species of mushroom."
	color = "#E700E7" 
	metabolization_rate = 0.2 * REAGENTS_METABOLISM
	taste_description = "mushroom"

/datum/reagent/drug/mushroomhallucinogen/on_mob_life(mob/living/carbon/M)
	if(!M.slurring)
		M.slurring = 1
	switch(current_cycle)
		if(1 to 5)
			M.Dizzy(5)
			M.set_drugginess(30)
			if(prob(10))
				M.emote(pick("twitch","giggle"))
		if(5 to 10)
			M.Jitter(10)
			M.Dizzy(10)
			M.set_drugginess(35)
			if(prob(20))
				M.emote(pick("twitch","giggle"))
		if (10 to INFINITY)
			M.Jitter(20)
			M.Dizzy(20)
			M.set_drugginess(40)
			if(prob(30))
				M.emote(pick("twitch","giggle"))
	..()

/datum/reagent/consumable/garlic 
	name = "Garlic Juice"
	description = "Crushed garlic. Chefs love it, but it can make you smell bad."
	color = "#FEFEFE"
	taste_description = "garlic"
	metabolization_rate = 0.15 * REAGENTS_METABOLISM

/datum/reagent/consumable/garlic/on_mob_life(mob/living/carbon/M)
	if(isvampire(M)) 
		if(prob(min(25,current_cycle)))
			to_chat(M, "<span class='danger'>You can't get the scent of garlic out of your nose! You can barely think...</span>")
			M.Paralyze(10)
			M.Jitter(10)
	else if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(H.job == "Cook")
			if(prob(20)) 
				H.heal_bodypart_damage(1,1, 0)
				. = 1
		else 
			H.adjust_hygiene(-0.15 * volume)
	..()

/datum/reagent/consumable/sprinkles
	name = "Sprinkles"
	description = "Multi-colored little bits of sugar, commonly found on donuts. Loved by cops."
	color = "#FF00FF" 
	taste_description = "childhood whimsy"

/datum/reagent/consumable/sprinkles/on_mob_life(mob/living/carbon/M)
	if(HAS_TRAIT(M.mind, TRAIT_LAW_ENFORCEMENT_METABOLISM))
		M.heal_bodypart_damage(1,1, 0)
		. = 1
	..()

/datum/reagent/consumable/cornoil
	name = "Corn Oil"
	description = "An oil derived from various types of corn."
	nutriment_factor = 20 * REAGENTS_METABOLISM
	color = "#302000" 
	taste_description = "slime"

/datum/reagent/consumable/cornoil/reaction_turf(turf/open/T, reac_volume)
	if (!istype(T))
		return
	T.MakeSlippery(TURF_WET_LUBE, min_wet_time = 10 SECONDS, wet_time_to_add = reac_volume*2 SECONDS)
	var/obj/effect/hotspot/hotspot = (locate(/obj/effect/hotspot) in T)
	if(hotspot)
		var/datum/gas_mixture/lowertemp = T.remove_air(T.air.total_moles())
		lowertemp.set_temperature(max( min(lowertemp.return_temperature()-2000,lowertemp.return_temperature() / 2) ,0))
		lowertemp.react(src)
		T.assume_air(lowertemp)
		qdel(hotspot)

/datum/reagent/consumable/enzyme
	name = "Universal Enzyme"
	description = "A universal enzyme used in the preperation of certain chemicals and foods."
	color = "#365E30" 
	taste_description = "sweetness"

/datum/reagent/consumable/dry_ramen
	name = "Dry Ramen"
	description = "Space age food, since August 25, 1958. Contains dried noodles, vegetables, and chemicals that boil in contact with water."
	reagent_state = SOLID
	color = "#302000" 
	taste_description = "dry and cheap noodles"

/datum/reagent/consumable/hot_ramen
	name = "Hot Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" 
	taste_description = "wet and cheap noodles"

/datum/reagent/consumable/hot_ramen/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT, 0, BODYTEMP_NORMAL)
	..()

/datum/reagent/consumable/hell_ramen
	name = "Hell Ramen"
	description = "The noodles are boiled, the flavors are artificial, just like being back in school."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#302000" 
	taste_description = "wet and cheap noodles on fire"

/datum/reagent/consumable/hell_ramen/on_mob_life(mob/living/carbon/M)
	M.adjust_bodytemperature(10 * TEMPERATURE_DAMAGE_COEFFICIENT)
	..()

/datum/reagent/consumable/flour
	name = "Flour"
	description = "This is what you rub all over yourself to pretend to be a ghost."
	reagent_state = SOLID
	color = "#FFFFFF" 
	taste_description = "chalky wheat"

/datum/reagent/consumable/flour/reaction_turf(turf/T, reac_volume)
	if(!isspaceturf(T))
		var/obj/effect/decal/cleanable/food/flour/reagentdecal = new(T)
		reagentdecal = locate() in T 
		if(reagentdecal)
			reagentdecal.reagents.add_reagent(/datum/reagent/consumable/flour, reac_volume)

/datum/reagent/consumable/cherryjelly
	name = "Cherry Jelly"
	description = "Totally the best. Only to be spread on foods with excellent lateral symmetry."
	color = "#801E28" 
	taste_description = "cherry"

/datum/reagent/consumable/bluecherryjelly
	name = "Blue Cherry Jelly"
	description = "Blue and tastier kind of cherry jelly."
	color = "#00F0FF"
	taste_description = "blue cherry"

/datum/reagent/consumable/rice
	name = "Rice"
	description = "tiny nutritious grains"
	reagent_state = SOLID
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFFFFF" 
	taste_description = "rice"

/datum/reagent/consumable/vanilla
	name = "Vanilla Powder"
	description = "A fatty, bitter paste made from vanilla pods."
	reagent_state = SOLID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#FFFACD"
	taste_description = "vanilla"

/datum/reagent/consumable/eggyolk
	name = "Egg Yolk"
	description = "It's full of protein."
	nutriment_factor = 3 * REAGENTS_METABOLISM
	color = "#FFB500"
	taste_description = "egg"

/datum/reagent/consumable/corn_starch
	name = "Corn Starch"
	description = "A slippery solution."
	color = "#C8A5DC"
	taste_description = "slime"

/datum/reagent/consumable/corn_syrup
	name = "Corn Syrup"
	description = "Decays into sugar."
	color = "#C8A5DC"
	metabolization_rate = 3 * REAGENTS_METABOLISM
	taste_description = "sweet slime"

/datum/reagent/consumable/corn_syrup/on_mob_life(mob/living/carbon/M)
	holder.add_reagent(/datum/reagent/consumable/sugar, 3)
	..()
/datum/reagent/consumable/honey
	name = "Honey"
	description = "Sweet sweet honey that decays into sugar. Has antibacterial and natural healing properties."
	color = "#d3a308"
	nutriment_factor = 15 * REAGENTS_METABOLISM
	metabolization_rate = 1 * REAGENTS_METABOLISM
	taste_description = "sweetness"
	var/power = 0
	random_unrestricted = TRUE

/datum/reagent/consumable/honey/on_mob_life(mob/living/carbon/M)
	if(power == 0)
		M.reagents.add_reagent(/datum/reagent/consumable/sugar,3)
	if(prob(55))
		M.adjustBruteLoss(-1*REM+power, 0)
		M.adjustFireLoss(-1*REM+power, 0)
		M.adjustOxyLoss(-1*REM+power, 0)
		M.adjustToxLoss(-1*REM+power, 0)
	..()

/datum/reagent/consumable/honey/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
  if(iscarbon(M) && (method in list(TOUCH, VAPOR, PATCH)))
    var/mob/living/carbon/C = M
    for(var/s in C.surgeries)
      var/datum/surgery/S = s
      S.success_multiplier = max(0.6, S.success_multiplier) 
  ..()

/datum/reagent/consumable/honey/special
	name = "Royal Honey"
	description = "A special honey which heals the imbiber far faster than normal honey"
	power = 1

/datum/reagent/consumable/mayonnaise
	name = "Mayonnaise"
	description = "An white and oily mixture of mixed egg yolks."
	color = "#DFDFDF"
	taste_description = "mayonnaise"

/datum/reagent/consumable/tearjuice
	name = "Tear Juice"
	description = "A blinding substance extracted from certain onions."
	color = "#c0c9a0"
	taste_description = "bitterness"

/datum/reagent/consumable/tearjuice/reaction_mob(mob/living/M, method=TOUCH, reac_volume)
	if(!istype(M))
		return
	var/unprotected = FALSE
	switch(method)
		if(INGEST)
			unprotected = TRUE
		if(INJECT)
			unprotected = FALSE
		else	
			if(!M.is_mouth_covered() && !M.is_eyes_covered())
				unprotected = TRUE
	if(unprotected)
		if(!M.getorganslot(ORGAN_SLOT_EYES))	
			to_chat(M, "<span class = 'notice'>Your eye sockets feel wet.</span>")
		else
			if(!M.eye_blurry)
				to_chat(M, "<span class = 'warning'>Tears well up in your eyes!</span>")
			M.blind_eyes(2)
			M.blur_eyes(5)
	..()

/datum/reagent/consumable/tearjuice/on_mob_life(mob/living/carbon/M)
	..()
	if(M.eye_blurry)	
		M.blur_eyes(4)
		if(prob(10))
			to_chat(M, "<span class = 'warning'>Your eyes sting!</span>")
			M.blind_eyes(2)


/datum/reagent/consumable/nutriment/stabilized
	name = "Stabilized Nutriment"
	description = "A bioengineered protien-nutrient structure designed to decompose in high saturation. In layman's terms, it won't get you fat."
	reagent_state = SOLID
	nutriment_factor = 15 * REAGENTS_METABOLISM
	color = "#664330" 

/datum/reagent/consumable/nutriment/stabilized/on_mob_life(mob/living/carbon/M)
	if(M.nutrition > NUTRITION_LEVEL_FULL - 25)
		M.adjust_nutrition(-3*nutriment_factor)
	..()




/datum/reagent/consumable/entpoly
	name = "Entropic Polypnium"
	description = "An ichor, derived from a certain mushroom, makes for a bad time."
	color = "#1d043d"
	taste_description = "bitter mushroom"

/datum/reagent/consumable/entpoly/on_mob_life(mob/living/carbon/M)
	if(current_cycle >= 10)
		M.Unconscious(40, 0)
		. = 1
	if(prob(20))
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
	taste_description = "tingling mushroom"

/datum/reagent/consumable/tinlux/reaction_mob(mob/living/M)
	M.set_light(2)

/datum/reagent/consumable/tinlux/on_mob_end_metabolize(mob/living/M)
	M.set_light(-2)

/datum/reagent/consumable/vitfro
	name = "Vitrium Froth"
	description = "A bubbly paste that heals wounds of the skin."
	color = "#d3a308"
	nutriment_factor = 3 * REAGENTS_METABOLISM
	taste_description = "fruity mushroom"

/datum/reagent/consumable/vitfro/on_mob_life(mob/living/carbon/M)
	if(prob(80))
		M.adjustBruteLoss(-1*REM, 0)
		M.adjustFireLoss(-1*REM, 0)
		. = TRUE
	..()

/datum/reagent/consumable/clownstears
	name = "Clown's Tears"
	description = "The sorrow and melancholy of a thousand bereaved clowns, forever denied their Honkmechs."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#eef442" 
	taste_description = "mournful honking"


/datum/reagent/consumable/liquidelectricity
	name = "Liquid Electricity"
	description = "The blood of Ethereals, and the stuff that keeps them going. Great for them, horrid for anyone else."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#97ee63"
	taste_description = "pure electrictiy"

/datum/reagent/consumable/liquidelectricity/on_mob_life(mob/living/carbon/M)
	if(isethereal(M))
		var/mob/living/carbon/human/H = M
		var/datum/species/ethereal/E = H.dna?.species
		E.adjust_charge(5*REM)
	else if(prob(25)) 
		M.electrocute_act(rand(10,15), "Liquid Electricity in their body", 1) 
		playsound(M, "sparks", 50, 1)
	return ..()

/datum/reagent/consumable/astrotame
	name = "Astrotame"
	description = "A space age artifical sweetener."
	nutriment_factor = 0
	metabolization_rate = 2 * REAGENTS_METABOLISM
	reagent_state = SOLID
	color = "#FFFFFF" 
	taste_mult = 8
	taste_description = "sweetness"
	overdose_threshold = 17

/datum/reagent/consumable/astrotame/overdose_process(mob/living/carbon/M)
	if(M.disgust < 80)
		M.adjust_disgust(10)
	..()
	. = 1

/datum/reagent/consumable/caramel
	name = "Caramel"
	description = "Who would have guessed that heating sugar is so delicious?"
	nutriment_factor = 10 * REAGENTS_METABOLISM
	color = "#C65A00"
	taste_mult = 2
	taste_description = "bitter sweetness"
	reagent_state = SOLID

/datum/reagent/consumable/bbqsauce
	name = "BBQ Sauce"
	description = "Sweet, Smokey, Savory, and gets everywhere. Perfect for Grilling."
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#78280A" 
	taste_mult = 2.5 
	taste_description = "smokey sweetness"

/datum/reagent/consumable/char
	name = "Char"
	description = "Essence of the grill. Has strange properties when overdosed."
	reagent_state = LIQUID
	nutriment_factor = 5 * REAGENTS_METABOLISM
	color = "#C8C8C8"
	taste_mult = 6
	taste_description = "smoke"
	overdose_threshold = 25

/datum/reagent/consumable/char/overdose_process(mob/living/carbon/M)
	if(prob(10))
		M.say(pick("I hate my wife.", "I just want to grill for God's sake.", "I wish I could just go on my lawnmower and cut the grass.", "Yep, Quake. That was a good game...", "Yeah, my PDA has wi-fi. A wife I hate."), forced = /datum/reagent/consumable/char)
	..()
