

/* Summary:
	plants have 7 components: weed, pest, toxin, darkness(=light) / nutrient, water, light(=darkness)
	left 4 components are bascially bad, and flags will convert them into good things.
	right 3 commponents are necessary, and flags will convert them into bad or unnecessary things. */

#define PLANT_FAMILY_WEEDIMMUNE     (1<<0)
#define PLANT_FAMILY_PESTIMMUNE     (1<<1) // carnivory plant
#define PLANT_FAMILY_TOXINIMMUNE    (1<<2)
#define PLANT_FAMILY_DARKIMMNE      (1<<3)
// immune from bad things

#define PLANT_FAMILY_HEALFROMWEED   (1<<4)
#define PLANT_FAMILY_HEALFROMPEST   (1<<5) // carnivory plant
#define PLANT_FAMILY_HEALFROMTOXIN  (1<<6)
// #define PLANT_FAMILY_HEALFROMDARK  // being healed from darkness isn't good idea.
// plants get heals from them

#define PLANT_FAMILY_NEEDWEED       (1<<8)
#define PLANT_FAMILY_NEEDPEST       (1<<9)
#define PLANT_FAMILY_NEEDTOXIN      (1<<10)
#define PLANT_FAMILY_NEEDDARK       (1<<11)
// plants need them. usually they take damage from it. if they don't have, they'll take damage.

#define PLANT_FAMILY_WATERFREE      (1<<12)
#define PLANT_FAMILY_NUTRIFREE      (1<<13)
#define PLANT_FAMILY_LIGHTFREE      (1<<14)
// plants don't need them

#define PLANT_FAMILY_BADWATER       (1<<15)
#define PLANT_FAMILY_BADNUTRI       (1<<16)
#define PLANT_FAMILY_BADLIGHT       (1<<17)
// plants take damage from them
// BAD flags needs FREE flags too, because plants still need BAD things without FREE flag.
// i.e.) Plant takes damage from Water(if BADWATER), but plant takes damage from no water(if not WATERFREE) - so you need WATERFREE too.


// plant famiily that changes how they grow
/datum/plant_gene/family
	name = "Normal"
	var/fname = "Normal"
	var/desc = "Nothing special"
	var/research_identifier
	research_needed = 0

	//family system values
	var/weed_adjust = 1
	var/pest_adjust = 1
	var/toxin_adjust = 1
	var/nutri_adjust = 1
	var/water_adjust = 1
	// adjust: amount of adjustment. if `weed_adjust = 5`,

	var/weed_damage = 2    // if PLANT_FAMILY_HEALFROMWEED, heals.
	var/pest_damage = 2    // if PLANT_FAMILY_HEALFROMPEST, heals.
	var/toxin_damage = 2   // if PLANT_FAMILY_HEALFROMTOXIN, heals.
	var/nutri_damage = 2   // default, if PLANT_FAMILY_NUTRIFREE, nothing.
	var/water_damage = 2   // default, if PLANT_FAMILY_WATERFREE, nothing.
	var/light_damage = 2   // if PLANT_FAMILY_BADLIGHT, damages.
	var/dark_damage = 2    // default, if PLANT_FAMILY_DARKIMMNE, nothing.
	// damage: amount of taken damage/heal when their thresholds met.

	var/weed_danger_threshold = 5   // default, disabled with PLANT_FAMILY_WEEDIMMUNE
	var/pest_danger_threshold = 5   // default, disabled with PLANT_FAMILY_PESTIMMUNE
	var/toxin_danger_threshold = 5  // default, disabled with PLANT_FAMILY_TOXINIMMUNE
	var/nutri_danger_threshold = 5  // need PLANT_FAMILY_BADWATER
	var/water_danger_threshold = 5  // need PLANT_FAMILY_BADNUTRI
	// If they are more than a certain value, they take damage.

	var/weed_need_threshold = 0     // need PLANT_FAMILY_NEEDWEED
	var/pest_need_threshold = 0     // need PLANT_FAMILY_NEEDPEST
	var/toxin_need_threshold = 0    // need PLANT_FAMILY_NEEDTOXIN
	var/nutri_need_threshold = 2    // default, disabled with PLANT_FAMILY_NUTRIFREE
	var/water_need_threshold = 10    // default, disabled with PLANT_FAMILY_WATERFREE
	// If they are less than a certain value, they take damage.


	var/flags = NONE


/datum/plant_gene/family/weed_hardy
	name = "Weed Adaptation"
	fname = "Weed"
	desc = "Adaptabiltiy of weed"
	research_needed = 3

/datum/plant_gene/family/fungal_metabolism
	name = "Fungal Vitality"
	fname = "Mushroom"
	desc = "Vitality of fungi"
	research_needed = 3

/datum/plant_gene/family/carnivory
	name = "Obligate Carnivory"
	fname = "Carnivoras"
	desc = "Carnivore of plants"
	research_needed = 3

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
