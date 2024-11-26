/datum/food_processor_process
	var/input
	var/output
	var/time = 40
	/// The machine required to do this recipe
	var/required_machine = /obj/machinery/processor
	/// Multiplied additional food made when processed
	var/food_multiplier = 1

/datum/food_processor_process/meat
	input = /obj/item/food/meat/slab
	output = /obj/item/food/raw_meatball
	food_multiplier = 3

/datum/food_processor_process/cutlet
	input = /obj/item/food/meat/cutlet/plain
	output = /obj/item/food/raw_meatball

/datum/food_processor_process/meat/human
	input = /obj/item/food/meat/slab/human
	output = /obj/item/food/raw_meatball/human

/datum/food_processor_process/cutlet/human
	input = /obj/item/food/meat/cutlet/plain/human
	output = /obj/item/food/raw_meatball/human

/datum/food_processor_process/meat/corgi
	input = /obj/item/food/meat/slab/corgi
	output = /obj/item/food/raw_meatball/corgi

/datum/food_processor_process/meat/xeno
	input = /obj/item/food/meat/slab/xeno
	output = /obj/item/food/raw_meatball/xeno

/datum/food_processor_process/cutlet/xeno
	input = /obj/item/food/meat/cutlet/xeno
	output = /obj/item/food/raw_meatball/xeno

/datum/food_processor_process/meat/bear
	input = /obj/item/food/meat/slab/bear
	output = /obj/item/food/raw_meatball/bear

/datum/food_processor_process/cutlet/bear
	input = /obj/item/food/meat/cutlet/bear
	output = /obj/item/food/raw_meatball/bear

/datum/food_processor_process/meat/chicken
	input = /obj/item/food/meat/slab/chicken
	output = /obj/item/food/raw_meatball/chicken
	food_multiplier = 3

/datum/food_processor_process/cutlet/chicken
	input = /obj/item/food/meat/cutlet/chicken
	output = /obj/item/food/raw_meatball/chicken

/datum/food_processor_process/bacon
	input = /obj/item/food/meat/rawcutlet
	output = /obj/item/food/meat/rawbacon

/datum/food_processor_process/potatowedges
	input = /obj/item/food/grown/potato/wedges
	output = /obj/item/food/fries

/datum/food_processor_process/sweetpotato
	input = /obj/item/food/grown/potato/sweet
	output = /obj/item/food/yakiimo

/datum/food_processor_process/potato
	input = /obj/item/food/grown/potato
	output = /obj/item/food/tatortot

/datum/food_processor_process/carrot
	input = /obj/item/food/grown/carrot
	output = /obj/item/food/carrotfries

/datum/food_processor_process/soybeans
	input = /obj/item/food/grown/soybeans
	output = /obj/item/food/soydope

/datum/food_processor_process/spaghetti
	input = /obj/item/food/doughslice
	output = /obj/item/food/spaghetti/raw

/datum/food_processor_process/corn
	input = /obj/item/food/grown/corn
	output = /obj/item/food/tortilla

/datum/food_processor_process/tortilla
	input = /obj/item/food/tortilla
	output = /obj/item/food/cornchips

/datum/food_processor_process/parsnip
	input = /obj/item/food/grown/parsnip
	output = /obj/item/food/roastparsnip

/datum/food_processor_process/mob/slime
	input = /mob/living/simple_animal/slime
	output = null
	required_machine = /obj/machinery/processor/slime

/datum/food_processor_process/fish
	input = /obj/item/fish
	output = /obj/item/food/fishmeat
