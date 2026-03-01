/obj/machinery/vending/dinnerware
	name = "\improper Plasteel Chef's Banquet Vendor"
	desc = "A kitchen and restaurant equipment and supply vendor."
	product_ads = "Mm, food stuffs!;Food and food accessories.;Get your plates!;You like forks?;I like forks.;Woo, utensils.;You don't really need these..."
	icon_state = "dinnerware"
	product_categories = list(
		list(
			"name" = "Dinnerwear",
			"icon" = "utensils",
			"products" = list(
				/obj/item/storage/bag/tray = 8,
				/obj/item/reagent_containers/cup/bowl = 20,
				/obj/item/kitchen/fork = 6,
				/obj/item/reagent_containers/cup/glass/drinkingglass = 8,
				/obj/item/clothing/suit/apron/chef = 2,
				/obj/item/kitchen/rollingpin = 2,
				/obj/item/knife/kitchen = 2,
				/obj/item/book/granter/crafting_recipe/cooking_sweets_101 = 2,
				/obj/item/plate/small = 5,
				/obj/item/plate = 10,
				/obj/item/plate/large = 5,
				/obj/item/sharpener = 2
			),
		),
		list(
			"name" = "Ingredients",
			"icon" = "egg",
			"products" = list(
				/obj/item/reagent_containers/condiment/milk = 4,
				/obj/item/reagent_containers/condiment/soymilk = 2,
				/obj/item/storage/fancy/egg_box = 2,
				/obj/item/food/grown/carrot = 3,
				/obj/item/food/grown/parsnip = 3,
				/obj/item/food/grown/potato = 3,
				/obj/item/food/grown/corn = 3,
				/obj/item/food/grown/tomato = 3,
				/obj/item/reagent_containers/condiment/flour = 2,
				/obj/item/reagent_containers/condiment/rice = 2,
				/obj/item/reagent_containers/condiment/sugar = 2,
				/obj/item/food/meat/slab/monkey = 2,
				/obj/item/food/meat/slab/human/mutant/ethereal = 2,
			),
		),
		list(
			"name" = "Condiments",
			"icon" = "pepper-hot",
			"products" = list(
				/obj/item/reagent_containers/condiment/enzyme = 2,
				/obj/item/reagent_containers/condiment/cherryjelly = 2,
				/obj/item/reagent_containers/condiment/bbqsauce = 2,
				/obj/item/reagent_containers/condiment/soysauce = 2,
				/obj/item/reagent_containers/condiment/mayonnaise = 2,
				/obj/item/reagent_containers/condiment/honey = 2,
				/obj/item/reagent_containers/cup/bottle/caramel = 2,
				/obj/item/reagent_containers/condiment/vanilla = 2,
				/obj/item/reagent_containers/condiment/cream = 2,
				/obj/item/reagent_containers/condiment/pack/ketchup = 5,
				/obj/item/reagent_containers/condiment/pack/hotsauce = 5,
				/obj/item/reagent_containers/condiment/pack/astrotame = 5,
				/obj/item/reagent_containers/condiment/saltshaker = 5,
				/obj/item/reagent_containers/condiment/peppermill = 5,
			),
		),
	)
	contraband = list(
		/obj/item/kitchen/rollingpin = 2,
		/obj/item/knife/butcher = 2,
		/obj/item/reagent_containers/cup/bottle/ketamine = 1
		)
	premium = list(
		/obj/item/storage/box/ingredients = 3
	)
	refill_canister = /obj/item/vending_refill/dinnerware
	default_price = PAYCHECK_ASSISTANT * 1.2
	extra_price = 200
	seller_department = ACCOUNT_SRV_BITFLAG
	light_mask = "dinnerware-light-mask"

/obj/item/vending_refill/dinnerware
	machine_name = "Plasteel Chef's Banquet Vendor"
	icon_state = "refill_smoke"
