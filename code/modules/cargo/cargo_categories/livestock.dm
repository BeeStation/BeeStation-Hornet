/**
 * # Livestock Cargo Items
 *
 * Animals and creature crates orderable through cargo.
 */

// =============================================================================
// INDIVIDUAL ITEMS
// =============================================================================

/datum/cargo_list/livestock
	small_item = TRUE
	entries = list(
		list("path" = /obj/item/dog_bone, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/storage/box/monkeycubes, "cost" = 800, "max_supply" = 3),
	)

// =============================================================================
// ANIMAL CRATES
// =============================================================================

/datum/cargo_crate/livestock
	crate_type = /obj/structure/closet/crate/critter

/datum/cargo_crate/livestock/parrot
	name = "Parrot Crate"
	cost = 800
	max_supply = 2
	contains = list(/mob/living/simple_animal/parrot)

/datum/cargo_crate/livestock/parrot/generate()

/datum/cargo_crate/livestock/butterfly
	name = "Butterfly Crate"
	cost = 500
	max_supply = 3
	contains = list(/mob/living/simple_animal/butterfly)

/datum/cargo_crate/livestock/butterfly/generate()

/datum/cargo_crate/livestock/cat
	name = "Cat Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/pet/cat,
		/obj/item/clothing/neck/petcollar,
		/obj/item/toy/cattoy,
	)

/datum/cargo_crate/livestock/cat/generate()

/datum/cargo_crate/livestock/cat_exotic
	name = "Exotic Cat Crate"
	cost = 1500
	max_supply = 2
	contains = list(
		/obj/item/clothing/neck/petcollar,
		/obj/item/toy/cattoy,
	)

/datum/cargo_crate/livestock/cat_exotic/generate()

/datum/cargo_crate/livestock/chick
	name = "Chick Crate"
	cost = 300
	max_supply = 4
	contains = list(/mob/living/simple_animal/chick)

/datum/cargo_crate/livestock/corgi
	name = "Corgi Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/corgi,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/corgi/generate()

/datum/cargo_crate/livestock/corgi_exotic
	name = "Exotic Corgi Crate"
	cost = 1500
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/corgi/exoticcorgi,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/cow
	name = "Cow Crate"
	cost = 800
	max_supply = 2
	contains = list(/mob/living/basic/cow)

/datum/cargo_crate/livestock/crab
	name = "Crab Crate"
	cost = 400
	max_supply = 3
	contains = list(/mob/living/simple_animal/crab)

/datum/cargo_crate/livestock/crab/generate()

/datum/cargo_crate/livestock/fox
	name = "Fox Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/pet/fox,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/goat
	name = "Goat Crate"
	cost = 600
	max_supply = 2
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)

/datum/cargo_crate/livestock/mothroach
	name = "Mothroach Crate"
	cost = 400
	max_supply = 3
	contains = list(/mob/living/basic/mothroach)

/datum/cargo_crate/livestock/pug
	name = "Pug Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/pug,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/bullterrier
	name = "Bull Terrier Crate"
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/bullterrier,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/snake
	name = "Snake Crate"
	cost = 1200
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
	)

/datum/cargo_crate/livestock/capybara
	name = "Capybara Crate"
	cost = 1000
	max_supply = 2
	contains = list(/mob/living/basic/pet/dog/corgi/capybara)

/datum/cargo_crate/livestock/garden_gnome
	name = "Garden Gnome Crate"
	cost = 500
	max_supply = 3
	contains = list(/mob/living/basic/garden_gnome)

/datum/cargo_crate/livestock/garden_gnome/generate()
