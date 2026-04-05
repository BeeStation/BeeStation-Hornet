/**
 * # Livestock Cargo Items
 *
 * Animals and creature crates orderable through cargo.
 */

// =============================================================================
// INDIVIDUAL ITEMS
// =============================================================================

// Pet accessories and supplies ship in a plain crate — they're items, not animals.
/datum/cargo_list/livestock_supplies
	crate_type = /obj/structure/closet/crate
	small_item = TRUE
	entries = list(
		// -- Pet accessories & supplies --
		list("path" = /obj/item/dog_bone, "cost" = 100, "max_supply" = 5),
		list("path" = /obj/item/toy/cattoy, "cost" = 50, "max_supply" = 5),
		list("path" = /obj/item/clothing/neck/petcollar, "cost" = 50, "max_supply" = 10),
		list("path" = /obj/item/pet_carrier, "cost" = 250, "max_supply" = 3, "small_item" = FALSE),
		list("path" = /obj/item/storage/box/monkeycubes, "cost" = 800, "max_supply" = 3),
	)

// All actual animals ship in a critter crate.
/datum/cargo_list/livestock
	crate_type = /obj/structure/closet/crate/critter
	entries = list(
		// -- Small/harmless animals --
		list("path" = /mob/living/simple_animal/parrot, "cost" = 800, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/butterfly, "cost" = 150, "max_supply" = 5),
		list("path" = /mob/living/simple_animal/crab, "cost" = 300, "max_supply" = 4),
		list("path" = /mob/living/simple_animal/chick, "cost" = 200, "max_supply" = 6),
		list("path" = /mob/living/simple_animal/chicken, "cost" = 400, "max_supply" = 4),
		list("path" = /mob/living/simple_animal/cardinal, "cost" = 300, "max_supply" = 4),
		list("path" = /mob/living/simple_animal/rabbit, "cost" = 400, "max_supply" = 4),
		list("path" = /mob/living/simple_animal/turtle, "cost" = 600, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/sloth, "cost" = 600, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/pet/hamster, "cost" = 300, "max_supply" = 4),
		list("path" = /mob/living/simple_animal/pet/penguin/emperor, "cost" = 600, "max_supply" = 3),
		list("path" = /mob/living/simple_animal/pet/penguin/baby, "cost" = 400, "max_supply" = 3),
		list("path" = /mob/living/simple_animal/hostile/lizard, "cost" = 200, "max_supply" = 5),
		list("path" = /mob/living/basic/mouse, "cost" = 100, "max_supply" = 6),
		list("path" = /mob/living/basic/mothroach, "cost" = 300, "max_supply" = 4),
		list("path" = /mob/living/basic/pet/cat/kitten, "cost" = 500, "max_supply" = 4),
		list("path" = /mob/living/basic/pet/gondola, "cost" = 1500, "max_supply" = 2),
		// -- Dogs --
		list("path" = /mob/living/basic/pet/dog/corgi, "cost" = 1000, "max_supply" = 2),
		list("path" = /mob/living/basic/pet/dog/corgi/exoticcorgi, "cost" = 1500, "max_supply" = 2),
		list("path" = /mob/living/basic/pet/dog/pug, "cost" = 1000, "max_supply" = 2),
		list("path" = /mob/living/basic/pet/dog/bullterrier, "cost" = 1000, "max_supply" = 2),
		list("path" = /mob/living/basic/pet/dog/corgi/capybara, "cost" = 1000, "max_supply" = 2),
		// -- Cats --
		list("path" = /mob/living/basic/pet/cat, "cost" = 1000, "max_supply" = 2),
		// -- Farm animals --
		list("path" = /mob/living/basic/cow, "cost" = 800, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/hostile/retaliate/goat, "cost" = 600, "max_supply" = 2),
		// -- Exotic pets --
		list("path" = /mob/living/simple_animal/pet/fox, "cost" = 1000, "max_supply" = 2),
		list("path" = /mob/living/simple_animal/hostile/retaliate/poison/snake, "cost" = 400, "max_supply" = 4),
		list("path" = /mob/living/basic/garden_gnome, "cost" = 500, "max_supply" = 3),
	)


