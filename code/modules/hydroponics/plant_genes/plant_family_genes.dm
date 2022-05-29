// For flags, check `_DEFINES\plant_genes.dm`

// plant famiily that changes how they grow
/datum/plant_gene/family
	name = "Normal"
	var/fname = "Normal"
	desc = "Nothing special"
	var/family_flags = NONE
	var/research_identifier
	research_needed = 3

	//family system values
	var/weed_adjust = 1   // need PLANT_FAMILY_NEEDWEED
	var/pest_adjust = 1   // need PLANT_FAMILY_NEEDPEST
	var/toxin_adjust = 5  // need PLANT_FAMILY_NEEDTOXIN
	var/nutri_adjust = 1  // default
	var/water_adjust = 3  // default
	// adjust: amount of adjustment. if `weed_adjust = 5`,
	// all values must be integer

	var/wellfed_heal = 1
	var/weed_damage = 2    // if PLANT_FAMILY_HEALFROMWEED, heals.
	var/pest_damage = 1    // if PLANT_FAMILY_HEALFROMPEST, heals.
	var/toxin_damage = 2   // if PLANT_FAMILY_HEALFROMTOXIN, heals.
	var/nutri_damage = 2   // default, if PLANT_FAMILY_NUTRIFREE, nothing.
	var/water_damage = 1   // default, if PLANT_FAMILY_WATERFREE, nothing.
	var/light_damage = 1   // if PLANT_FAMILY_BADLIGHT, damages.
	var/dark_damage = 1    // default, if PLANT_FAMILY_DARKIMMNE, nothing.
	// damage: amount of taken damage/heal when their thresholds met.

	var/weed_danger_threshold = 5   // default, disabled with PLANT_FAMILY_WEEDIMMUNE, also used in HEAL flag
	var/pest_danger_threshold = 8   // default, disabled with PLANT_FAMILY_PESTIMMUNE, also used in HEAL flag
		// must be even
	var/toxin_danger_threshold = 80 // default, disabled with PLANT_FAMILY_TOXINIMMUNE, also used in HEAL flag
		// must be even
	var/nutri_danger_threshold = 8  // need PLANT_FAMILY_BADWATER
	var/water_danger_threshold = 5  // need PLANT_FAMILY_BADNUTRI
	// If they are more than a certain value, they take damage.

	//var/nutri_need_threshold = 10   // It's not needed
	var/water_need_threshold = 10    // default, disabled with PLANT_FAMILY_WATERFREE


	var/flags = NONE


/datum/plant_gene/family/proc/set_desc()
	//weed
	var/they_eat = FALSE
	desc += "<br />--------------------"
	desc += "<br />\[Common\] Plant can be healed by [wellfed_heal] at 50% chance when they eat something"
	if(!(family_flags & PLANT_FAMILY_WEEDIMMUNE))
		desc += "<br />\[Weed\] Plant takes [weed_damage] damage from more than [weed_danger_threshold] weed level"
	else
		desc += "<br />\[Weed\] Plant takes no damage from flourishing weeds"
	if(family_flags & PLANT_FAMILY_NEEDWEED)
		desc += "<br />\[Weed\] Plant needs to eat weeds, and should have more than [weed_adjust] or it takes [weed_damage] damage"
		they_eat = TRUE
	if(family_flags & PLANT_FAMILY_HEALFROMWEED)
		desc += "<br />\[Weed\] Plant can be healed by [weed_damage] from eating weeds, but it needs more than [weed_danger_threshold] weed level"
		they_eat = TRUE
	if(they_eat)
		desc += "<br />\[Weed\] Plant eats [weed_adjust] weeds"
		they_eat = FALSE
	if(family_flags & PLANT_FAMILY_WEEDINVASIONIMMUNE)
		desc += "<br />\[Weed\] Plant will not be overtaken by weeds"

	//pest
	if(!(family_flags & PLANT_FAMILY_PESTIMMUNE))
		desc += "<br />\[Pest\] Plant takes [pest_damage] damage from more than [pest_danger_threshold/2] pest level, and the damage is doubled from more than [pest_danger_threshold] pest level"
	else
		desc += "<br />\[Pest\] Plant takes no damage from flourishing pests"
	if(family_flags & PLANT_FAMILY_NEEDPEST)
		desc += "<br />\[Pest\] Plant needs to eat pests, and should have more than [pest_adjust] or it takes [pest_damage] damage"
		they_eat = TRUE
	if(family_flags & PLANT_FAMILY_HEALFROMPEST)
		desc += "<br />\[Pest\] Plant can be healed by [pest_damage*2] from eating pests, but it needs more than [pest_danger_threshold] pest level"
		they_eat = TRUE
	if(they_eat)
		desc += "<br />\[Pest\] Plant eats [pest_adjust] pests"
		they_eat = FALSE

	//toxin
	if(!(family_flags & PLANT_FAMILY_TOXINIMMUNE))
		desc += "<br />\[Toxin\] Plant takes [toxin_damage] damage from more than [toxin_danger_threshold/2] toxin level, and the damage is doubled from more than [toxin_danger_threshold] toxin level"
	else
		desc += "<br />\[Toxin\] Plant takes no damage from flourishing toxin"
	if(family_flags & PLANT_FAMILY_NEEDTOXIN)
		desc += "<br />\[Toxin\] Plant needs to eat toxin, and should have more than [toxin_adjust] or it takes [toxin_damage] damage"
		they_eat = TRUE
	if(family_flags & PLANT_FAMILY_HEALFROMTOXIN)
		desc += "<br />\[Toxin\] Plant can be healed by [toxin_damage] from eating toxin, but it needs more than [toxin_danger_threshold/2] toxin level. the heal is doubled from more than  [toxin_danger_threshold] toxin level"
		they_eat = TRUE
	if(they_eat)
		desc += "<br />\[Toxin\] Plant eats [toxin_adjust] toxin"
		they_eat = FALSE

	//nutriment
	if(!(family_flags & PLANT_FAMILY_NUTRIFREE))
		desc += "<br />\[Nutri\] Plant takes [nutri_damage] when they didn't eat any nutriment"
	else
		desc += "<br />\[Nutri\] Plant takes no damage even if they didn't eat any nutriment"
	if(family_flags & PLANT_FAMILY_BADNUTRI) // don't give too much nutriment
		desc += "<br />\[Nutri\] Plant takes [nutri_damage] from more than [nutri_danger_threshold] nutriment level"
	desc += "<br />\[Nutri\] Plant eats [nutri_adjust] nutriment"

	//water
	if(!(family_flags & PLANT_FAMILY_WATERFREE))
		desc += "<br />\[Water\] Plant takes [water_damage] when they are less than [water_need_threshold] water level"
	else
		desc += "<br />\[Water\] Plant takes no damage from water insufficient"
	if(family_flags & PLANT_FAMILY_BADWATER)
		desc += "<br />\[Water\] Plant takes [water_damage] from more than [water_danger_threshold] water level"
	desc += "<br />\[Water\] Plant eat [water_adjust+2]-[water_adjust-2] water"

	//light
	if(!(family_flags & PLANT_FAMILY_DARKIMMNE))
		desc += "<br />\[Light\] Plant takes [dark_damage] from insufficient light"
	if(!(family_flags & PLANT_FAMILY_LIGHTFREE))
		desc += "<br />\[Light\] Plant takes [light_damage] from too much light"

	return


/datum/plant_gene/family/weed_hardy
	name = "Weed Adaptation"
	fname = "Weed"
	desc = "Adaptabiltiy of weed"
	research_needed = 3
	family_flags = PLANT_FAMILY_WEEDIMMUNE | PLANT_FAMILY_NUTRIFREE | PLANT_FAMILY_WEEDINVASIONIMMUNE

/datum/plant_gene/family/fungal_metabolism
	name = "Fungal Vitality"
	fname = "Mushroom"
	desc = "Vitality of fungi"
	research_needed = 3
	family_flags = PLANT_FAMILY_WEEDIMMUNE | PLANT_FAMILY_WATERFREE | PLANT_FAMILY_LIGHTFREE | PLANT_FAMILY_WEEDINVASIONIMMUNE

/datum/plant_gene/family/carnivory
	name = "Obligate Carnivory"
	fname = "Carnivoras"
	desc = "Carnivore of plants"
	research_needed = 3
	family_flags = PLANT_FAMILY_PESTIMMUNE | PLANT_FAMILY_NEEDPEST | PLANT_FAMILY_HEALFROMPEST

/datum/plant_gene/family/alien_properties
	name = "Unidentified"
	fname = "???"
	desc = "very randomised"
	research_needed = 1

/datum/plant_gene/family/Copy()
	var/datum/plant_gene/family/G = ..()
	G.name = name
	G.desc = desc
	G.research_needed = research_needed
	G.research_identifier = research_identifier
	return G
