/* Summary:
	plants have 7 components: weed, pest, toxin, darkness(=light) / nutrient, water, light(=darkness)
	left 4 components are bascially bad, and flags will convert them into good or neutral things.
	right 3 commponents are necessary, and flags will convert them into bad or unnecessary things. */

#define PLANT_FAMILY_WEEDIMMUNE     (1<<0)
#define PLANT_FAMILY_PESTIMMUNE     (1<<1) // carnivory plant
#define PLANT_FAMILY_TOXINIMMUNE    (1<<2)
#define PLANT_FAMILY_DARKIMMNE      (1<<3)
#define PLANT_FAMILY_WEEDINVASIONIMMUNE  (1<<4)
// immune from bad things

#define PLANT_FAMILY_NEEDWEED       (1<<5)
#define PLANT_FAMILY_NEEDPEST       (1<<6)
#define PLANT_FAMILY_NEEDTOXIN      (1<<7)
#define PLANT_FAMILY_NEEDDARK       (1<<8)
// plants need them. usually they take damage from it. if they don't have, they'll take damage.

#define PLANT_FAMILY_HEALFROMWEED   (1<<9)
#define PLANT_FAMILY_HEALFROMPEST   (1<<10) // carnivory plant
#define PLANT_FAMILY_HEALFROMTOXIN  (1<<11)
// #define PLANT_FAMILY_HEALFROMDARK  // being healed from darkness isn't good idea.
// plants get heals from them

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


// how do they eat
#define PLANT_BITE_TYPE_CONST   "CONST"
#define PLANT_BITE_TYPE_RATIO   "RATIO"
#define PLANT_BITE_TYPE_PATCH   "PATCH"

// plant genes
#define PLANT_GENE_COMMON_REMOVABLE	(1<<0)
#define PLANT_GENE_REAGENT_ADJUSTABLE (1<<1)

// botany research factions
#define BOTANY_RESEARCHED_NANOTRASEN  (1<<0)
#define BOTANY_RESEARCHED_LIFEBRINGER (1<<1)
#define BOTANY_RESEARCHED_CENTCOM     (1<<2)
