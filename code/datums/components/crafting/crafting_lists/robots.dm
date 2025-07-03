
/// Robot Crafting

/datum/crafting_recipe/ed209
	name = "ED209"
	result = /mob/living/simple_animal/bot/ed209
	time = 6 SECONDS
	tool_behaviors = list(TOOL_WELDER, TOOL_SCREWDRIVER)
	reqs = list(
		/obj/item/robot_suit = 1,
		/obj/item/clothing/head/helmet = 1,
		/obj/item/clothing/suit/armor/vest = 1,
		/obj/item/bodypart/l_leg/robot = 1,
		/obj/item/bodypart/r_leg/robot = 1,
		/obj/item/stack/sheet/iron = 1,
		/obj/item/stack/cable_coil = 1,
		/obj/item/gun/energy/disabler = 1,
		/obj/item/stock_parts/cell = 1,
		/obj/item/assembly/prox_sensor = 1
		)
	category = CAT_ROBOT

/datum/crafting_recipe/secbot
	name = "Secbot"
	result = /mob/living/simple_animal/bot/secbot
	time = 6 SECONDS
	tool_behaviors = list(TOOL_WELDER)
	reqs = list(
		/obj/item/assembly/signaler = 1,
		/obj/item/clothing/head/helmet/sec = 1,
		/obj/item/melee/baton = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1
		)
	category = CAT_ROBOT

/datum/crafting_recipe/cleanbot
	name = "Cleanbot"
	result = /mob/living/simple_animal/bot/cleanbot
	time = 4 SECONDS
	reqs = list(
		/obj/item/reagent_containers/cup/bucket = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1
		)
	category = CAT_ROBOT

/datum/crafting_recipe/larry
	name = "Larry"
	result = /mob/living/simple_animal/bot/cleanbot/larry
	reqs = list(
		/obj/item/larryframe = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1
	)
	category = CAT_ROBOT

/datum/crafting_recipe/floorbot
	name = "Floorbot"
	result = /mob/living/simple_animal/bot/floorbot
	time = 4 SECONDS
	reqs = list(
		/obj/item/storage/toolbox = 1,
		/obj/item/stack/tile/iron = 10,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1
	)
	category = CAT_ROBOT

/datum/crafting_recipe/medbot
	name = "Medbot"
	result = /mob/living/simple_animal/bot/medbot
	time = 4 SECONDS
	reqs = list(
		/obj/item/healthanalyzer = 1,
		/obj/item/storage/firstaid = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bodypart/r_arm/robot = 1
		)
	category = CAT_ROBOT

/datum/crafting_recipe/honkbot
	name = "Honkbot"
	result = /mob/living/simple_animal/bot/honkbot
	time = 4 SECONDS
	reqs = list(
		/obj/item/storage/box/clown = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/bikehorn/ = 1
	)
	category = CAT_ROBOT

/datum/crafting_recipe/Firebot
	name = "Firebot"
	result = /mob/living/simple_animal/bot/firebot
	time = 4 SECONDS
	reqs = list(
		/obj/item/extinguisher = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/clothing/head/utility/hardhat/red = 1
	)
	category = CAT_ROBOT

/datum/crafting_recipe/Atmosbot
	name = "Atmosbot"
	result = /mob/living/simple_animal/bot/atmosbot
	time = 4 SECONDS
	reqs = list(
		/obj/item/analyzer = 1,
		/obj/item/bodypart/r_arm/robot = 1,
		/obj/item/assembly/prox_sensor = 1,
		/obj/item/tank/internals = 1
	)
	category = CAT_ROBOT
