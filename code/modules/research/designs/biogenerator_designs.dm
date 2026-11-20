///////////////////////////////////
///////Biogenerator Designs ///////
///////////////////////////////////

/datum/design/milk
	name = "10 Milk"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	make_reagents = list(/datum/reagent/consumable/milk = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/cream
	name = "10 Cream"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/cream = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/milk_carton
	name = "Milk Carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 100)
	build_path = /obj/item/reagent_containers/condiment/milk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/cream_carton
	name = "Cream Carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/reagent_containers/cup/glass/bottle/juice/cream
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/black_pepper
	name = "10u Black Pepper"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	make_reagents = list(/datum/reagent/consumable/blackpepper = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/pepper_mill
	name = "Pepper Mill"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/condiment/peppermill
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/enzyme
	name = "10u Universal Enzyme"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	make_reagents = list(/datum/reagent/consumable/enzyme = 10)
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)


/datum/design/flour_sack
	name = "Flour Sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/reagent_containers/condiment/flour
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)
/datum/design/sugar_sack
	name = "Sugar Sack"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 200)
	build_path = /obj/item/reagent_containers/condiment/sugar
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/monkey_cube
	name = "Monkey Cube"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 250)
	build_path = /obj/item/food/monkeycube
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/ez_nut
	name = "E-Z Nutrient"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 10)
	build_path = /obj/item/reagent_containers/cup/bottle/nutrient/ez
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/l4z_nut
	name = "Left 4 Zed"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 20)
	build_path = /obj/item/reagent_containers/cup/bottle/nutrient/l4z
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/rh_nut
	name = "Robust Harvest"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	build_path = /obj/item/reagent_containers/cup/bottle/nutrient/rh
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/weed_killer
	name = "Weed Killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/cup/bottle/killer/weedkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/pest_spray
	name = "Pest Killer"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/reagent_containers/cup/bottle/killer/pestkiller
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/botany_bottle
	name = "Empty Bottle"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 5)
	build_path = /obj/item/reagent_containers/cup/bottle/nutrient/empty
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_BOTANY_CHEMICALS)

/datum/design/cloth
	name = "Roll of Cloth"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 50)
	build_path = /obj/item/stack/sheet/cotton/cloth
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/cardboard
	name = "Sheet of Cardboard"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 25)
	build_path = /obj/item/stack/sheet/cardboard
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/leather
	name = "Sheet of Leather"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 150)
	build_path = /obj/item/stack/sheet/leather
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/toolbelt
	name = "Tool Belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/utility
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/botanybelt
	name = "Botanical Belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/botanical
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/secbelt
	name = "Security Belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/security
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/medbelt
	name = "Medical Belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/medical
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/janibelt
	name = "Janitorial Belt"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/storage/belt/janitor
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/s_holster
	name = "Shoulder Holster"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 400)
	build_path = /obj/item/clothing/accessory/holster
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/rice_hat
	name = "Rice Hat"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 300)
	build_path = /obj/item/clothing/head/costume/rice_hat
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_ORGANIC_MATERIALS)

/datum/design/carton_soy_milk
	name = "Soy Milk Carton"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass = 100)
	build_path = /obj/item/reagent_containers/condiment/soymilk
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)

/datum/design/seaweed_sheet
	name = "Seaweed Sheet"
	build_type = BIOGENERATOR
	materials = list(/datum/material/biomass= 30)
	build_path = /obj/item/food/seaweed_sheet
	category = list(RND_CATEGORY_INITIAL, RND_CATEGORY_FOOD)
