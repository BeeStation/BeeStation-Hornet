// Ambrosia - base type
/obj/item/reagent_containers/food/snacks/grown/ambrosia
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia branch"
	desc = "This is a plant."
	icon_state = "ambrosiavulgaris"
	slot_flags = ITEM_SLOT_HEAD
	filling_color = "#008000"
	foodtype = VEGETABLES
	tastes = list("ambrosia" = 1)

// Ambrosia Vulgaris
/obj/item/seeds/ambrosia
	name = "pack of ambrosia vulgaris seeds"
	desc = "These seeds grow into common ambrosia, a plant grown by and from medicine."
	plantname = "Ambrosia Vulgaris"
	species = "ambrosiavulgaris"

	icon_state = "seed-ambrosiavulgaris"
	icon_dead = "ambrosia-dead"

	// seed stats
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	potency = 5
	lifespan = 60
	endurance = 25
	yield = 6
	maturation = 1 //temp
	production = 1 //temp

	// plant stats
	bitesize_mod = 2
	bite_type = PLANT_BITE_TYPE_RATIO
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/glow/random)
	family = /datum/plant_gene/family/weed_hardy
	mutatelist = list(/obj/item/seeds/ambrosia/deus)

	reagents_innate = list(
		/datum/reagent/consumable/nutriment = list(3, 9, PLANT_GENE_COMMON_REMOVABLE))
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(3, 9),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 6),
		/datum/reagent/toxin = list(5, 15),
		/datum/reagent/medicine/bicaridine = list(5, 15),
		/datum/reagent/medicine/kelotane = list(5, 5),
		/datum/reagent/drug/space_drugs = list(5, 1))

/obj/item/reagent_containers/food/snacks/grown/ambrosia/vulgaris
	seed = /obj/item/seeds/ambrosia
	name = "ambrosia vulgaris branch"
	desc = "This is a plant containing various healing chemicals."
	wine_power = 30
	wine_flavor = "the regenerative power of the earth"

// Ambrosia Deus
/obj/item/seeds/ambrosia/deus
	name = "pack of ambrosia deus seeds"
	desc = "These seeds grow into ambrosia deus. Could it be the food of the gods..?"
	icon_state = "seed-ambrosiadeus"
	species = "ambrosiadeus"
	plantname = "Ambrosia Deus"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	mutatelist = list(/obj/item/seeds/ambrosia, /obj/item/seeds/ambrosia/gaia)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(3, 9),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 6),
		/datum/reagent/medicine/omnizine = list(2, 6),
		/datum/reagent/medicine/synaptizine = list(5, 15),
		/datum/reagent/drug/space_drugs = list(5, 10))
	rarity = 40

/obj/item/reagent_containers/food/snacks/grown/ambrosia/deus
	seed = /obj/item/seeds/ambrosia/deus
	name = "ambrosia deus branch"
	desc = "Eating this makes you feel immortal!"
	icon_state = "ambrosiadeus"
	filling_color = "#008B8B"
	wine_power = 50
	wine_flavor = "the faint immortality of the gods"
	discovery_points = 300

//Ambrosia Gaia
/obj/item/seeds/ambrosia/gaia
	name = "pack of ambrosia gaia seeds"
	desc = "These seeds grow into ambrosia gaia, filled with infinite potential."
	icon_state = "seed-ambrosia_gaia"
	species = "ambrosia_gaia"
	plantname = "Ambrosia Gaia"
	product = /obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	mutatelist = list(/obj/item/seeds/ambrosia/deus)

	reagents_innate = list(
		/datum/reagent/medicine/earthsblood = 0.03)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 12),
		/datum/reagent/consumable/nutriment/vitamin = list(3, 9),
		/datum/reagent/medicine/earthsblood = list(3, 9))
	rarity = 30 //These are some pretty good plants right here
	genes = list()
	weed_rate = 4
	weed_chance = 100

/obj/item/reagent_containers/food/snacks/grown/ambrosia/gaia
	name = "ambrosia gaia branch"
	desc = "Eating this <i>makes</i> you immortal."
	icon_state = "ambrosia_gaia"
	filling_color = rgb(255, 175, 0)
	light_system = MOVABLE_LIGHT
	light_range = 3
	seed = /obj/item/seeds/ambrosia/gaia
	wine_power = 70
	wine_flavor = "the earthmother's blessing"
	discovery_points = 300
