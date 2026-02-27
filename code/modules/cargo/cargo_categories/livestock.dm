/**
 * # Livestock Cargo Items
 *
 * Animals and creature crates orderable through cargo.
 */

// =============================================================================
// INDIVIDUAL ITEMS
// =============================================================================

/datum/cargo_item/livestock
	category = "Livestock"
	subcategory = "Animals"

/datum/cargo_item/livestock/dog_bone
	name = "Dog Bone"
	item_path = /obj/item/dog_bone
	cost = 100
	max_supply = 5
	small_item = TRUE

/datum/cargo_item/livestock/monkey_cubes
	name = "Monkey Cube Box"
	item_path = /obj/item/storage/box/monkeycubes
	cost = 800
	max_supply = 3
	small_item = TRUE

// =============================================================================
// ANIMAL CRATES
// =============================================================================

/datum/cargo_crate/livestock
	category = "Livestock"
	subcategory = "Animals"
	crate_type = /obj/structure/closet/crate/critter

/datum/cargo_crate/livestock/parrot
	name = "Parrot Crate"
	desc = "Contains one parrot."
	cost = 800
	max_supply = 2
	contains = list(/mob/living/simple_animal/parrot)

/datum/cargo_crate/livestock/parrot/generate()

/datum/cargo_crate/livestock/butterfly
	name = "Butterfly Crate"
	desc = "Contains one butterfly."
	cost = 500
	max_supply = 3
	contains = list(/mob/living/simple_animal/butterfly)

/datum/cargo_crate/livestock/butterfly/generate()

/datum/cargo_crate/livestock/cat
	name = "Cat Crate"
	desc = "Contains one cat with a pet collar and cat toy."
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
	desc = "Contains a random exotic cat with a pet collar and cat toy."
	cost = 1500
	max_supply = 2
	contains = list(
		/obj/item/clothing/neck/petcollar,
		/obj/item/toy/cattoy,
	)

/datum/cargo_crate/livestock/cat_exotic/generate()

/datum/cargo_crate/livestock/chick
	name = "Chick Crate"
	desc = "Contains one baby chick."
	cost = 300
	max_supply = 4
	contains = list(/mob/living/simple_animal/chick)

/datum/cargo_crate/livestock/corgi
	name = "Corgi Crate"
	desc = "Contains one corgi with a pet collar."
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/corgi,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/corgi/generate()

/datum/cargo_crate/livestock/corgi_exotic
	name = "Exotic Corgi Crate"
	desc = "Contains one exotic corgi with a pet collar."
	cost = 1500
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/corgi/exoticcorgi,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/cow
	name = "Cow Crate"
	desc = "Contains one cow."
	cost = 800
	max_supply = 2
	contains = list(/mob/living/basic/cow)

/datum/cargo_crate/livestock/crab
	name = "Crab Crate"
	desc = "Contains one crab."
	cost = 400
	max_supply = 3
	contains = list(/mob/living/simple_animal/crab)

/datum/cargo_crate/livestock/crab/generate()

/datum/cargo_crate/livestock/fox
	name = "Fox Crate"
	desc = "Contains one fox with a pet collar."
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/pet/fox,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/goat
	name = "Goat Crate"
	desc = "Contains one goat."
	cost = 600
	max_supply = 2
	contains = list(/mob/living/simple_animal/hostile/retaliate/goat)

/datum/cargo_crate/livestock/mothroach
	name = "Mothroach Crate"
	desc = "Contains one mothroach."
	cost = 400
	max_supply = 3
	contains = list(/mob/living/basic/mothroach)

/datum/cargo_crate/livestock/pug
	name = "Pug Crate"
	desc = "Contains one pug with a pet collar."
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/pug,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/bullterrier
	name = "Bull Terrier Crate"
	desc = "Contains one bull terrier with a pet collar."
	cost = 1000
	max_supply = 2
	contains = list(
		/mob/living/basic/pet/dog/bullterrier,
		/obj/item/clothing/neck/petcollar,
	)

/datum/cargo_crate/livestock/snake
	name = "Snake Crate"
	desc = "Contains three snakes. Handle with care."
	cost = 1200
	max_supply = 2
	contains = list(
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
		/mob/living/simple_animal/hostile/retaliate/poison/snake,
	)

/datum/cargo_crate/livestock/capybara
	name = "Capybara Crate"
	desc = "Contains one capybara."
	cost = 1000
	max_supply = 2
	contains = list(/mob/living/basic/pet/dog/corgi/capybara)

/datum/cargo_crate/livestock/garden_gnome
	name = "Garden Gnome Crate"
	desc = "Contains one garden gnome."
	cost = 500
	max_supply = 3
	contains = list(/mob/living/basic/garden_gnome)

/datum/cargo_crate/livestock/garden_gnome/generate()
