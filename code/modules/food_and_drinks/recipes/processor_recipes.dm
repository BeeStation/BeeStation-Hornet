/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	var/required_machine = /obj/machinery/processor

/datum/food_processor_process/meat
	input = /obj/item/food/meat/slab
	output = /obj/item/food/meatball

/datum/food_processor_process/bacon
	input = /obj/item/food/meat/rawcutlet
	output = /obj/item/food/meat/rawbacon

/datum/food_processor_process/potatowedges
	input = /obj/item/food/grown/potato/wedges
	output = /obj/item/reagent_containers/food/snacks/fries

/datum/food_processor_process/sweetpotato
	input = /obj/item/food/grown/potato/sweet
	output = /obj/item/reagent_containers/food/snacks/yakiimo

/datum/food_processor_process/potato
	input = /obj/item/food/grown/potato
	output = /obj/item/reagent_containers/food/snacks/tatortot

/datum/food_processor_process/carrot
	input = /obj/item/food/grown/carrot
	output = /obj/item/reagent_containers/food/snacks/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/food/grown/soybeans
	output = /obj/item/reagent_containers/food/snacks/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/food/doughslice
	output = /obj/item/food/spaghetti/raw

/datum/food_processor_process/corn
	input = /obj/item/food/grown/corn
	output = /obj/item/food/tortilla

/datum/food_processor_process/tortilla
	input = /obj/item/food/tortilla
	output = /obj/item/reagent_containers/food/snacks/cornchips

/datum/food_processor_process/parsnip
	input = /obj/item/food/grown/parsnip
	output = /obj/item/reagent_containers/food/snacks/roastparsnip

/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null
	required_machine = /obj/machinery/processor/slime

/datum/food_processor_process/fish
	input = /obj/item/fish
	output = /obj/item/food/fishmeat
