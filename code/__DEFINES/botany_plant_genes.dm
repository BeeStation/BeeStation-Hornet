// Botany value configuration
#define BTNY_CFG_NUTRI_START 2.5
#define BTNY_CFG_NUTRI_ADD   0.5
#define BTNY_CFG_VITAMIN_START 1.25
#define BTNY_CFG_VITAMIN_ADD   0.25
#define BTNY_CFG_NEEDED_PLANT_FOR_BONUS_STAT 15
#define BTNY_CFG_RNG_REAG_CHANCE_FIRST 100  // you always get a reagent. 100%
#define BTNY_CFG_RNG_REAG_CHANCE_SECOND 80   // at second reagent, 80%
#define BTNY_CFG_RNG_TRAIT_CHANCE 80


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


// plant genes flags
#define PLANT_GENE_QDEL_TARGET        (1<<1)
	// If a plant gene has this, qdel it, if not, it doesn't.
	// Core genes, Reagent genes have different values for each object
	// Trait genes are all the same ones - so they are all the same object to save memory
#define PLANT_GENE_COMMON_REMOVABLE   (1<<2)
#define PLANT_GENE_REAGENT_ADJUSTABLE (1<<3)
#define PLANT_GENE_RANDOM_ALLOWED     (1<<4)

// botany research factions
#define BOTANY_RESEARCHED_NANOTRASEN  (1<<0)
#define BOTANY_RESEARCHED_LIFEBRINGER (1<<1)
#define BOTANY_RESEARCHED_CENTCOM     (1<<2)


// how do they eat
#define PLANT_BITE_TYPE_DYNAM   "Dynamic"
#define PLANT_BITE_TYPE_CONST   "Constant"
#define PLANT_BITE_TYPE_PATCH   "Patch"


// path defines
#define PLANT_GENEPATH_COMMON /datum/plant_gene/
#define PLANT_GENEPATH_POTENT /datum/plant_gene/core/potency
#define PLANT_GENEPATH_YIELD  /datum/plant_gene/core/yield
#define PLANT_GENEPATH_MATURA /datum/plant_gene/core/maturation
#define PLANT_GENEPATH_PRODUC /datum/plant_gene/core/production
#define PLANT_GENEPATH_LIFESP /datum/plant_gene/core/lifespan
#define PLANT_GENEPATH_ENDURA /datum/plant_gene/core/endurance
#define PLANT_GENEPATH_WEEDRA /datum/plant_gene/core/weed_rate
#define PLANT_GENEPATH_WEEDCH /datum/plant_gene/core/weed_chance
#define PLANT_GENEPATH_VOLUME /datum/plant_gene/core/volume_mod
#define PLANT_GENEPATH_BITESI /datum/plant_gene/core/bitesize_mod
#define PLANT_GENEPATH_BITETY /datum/plant_gene/core/bite_type
#define PLANT_GENEPATH_DISTIL /datum/plant_gene/core/distill_reagent
#define PLANT_GENEPATH_WINEPO /datum/plant_gene/core/wine_power
#define PLANT_GENEPATH_RARITY /datum/plant_gene/core/rarity
