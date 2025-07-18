
/// Bread stuff crafting

/datum/crafting_recipe/food/meatbread
	name = "Meat bread"
	result = /obj/item/food/bread/meat
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/plain = 3,
		/obj/item/food/cheese/wedge = 3
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/xenomeatbread
	name = "Xenomeat bread"
	result = /obj/item/food/bread/xenomeat
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/xeno = 3,
		/obj/item/food/cheese/wedge = 3
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/spidermeatbread
	name = "Spidermeat bread"
	result = /obj/item/food/bread/spidermeat
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/meat/cutlet/spider = 3,
		/obj/item/food/cheese/wedge = 3
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/banananutbread
	name = "Banana nut bread"
	result = /obj/item/food/bread/banana
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/boiledegg = 3,
		/obj/item/food/grown/banana = 1
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/tofubread
	name = "Tofu bread"
	result = /obj/item/food/bread/tofu
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/cheese/wedge = 3
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/creamcheesebread
	name = "Cream cheese bread"
	result = /obj/item/food/bread/creamcheese
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/cheese/wedge = 2
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/mimanabread
	name = "Mimana bread"
	result = /obj/item/food/bread/mimana
	reqs = list(
		/datum/reagent/consumable/soymilk = 5,
		/obj/item/food/bread/plain = 1,
		/obj/item/food/tofu = 3,
		/obj/item/food/grown/banana/mime = 1
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/garlicbread
	name = "Garlic Bread"
	time = 4 SECONDS
	result = /obj/item/food/garlicbread
	reqs = list(
		/obj/item/food/grown/garlic = 1,
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/butter = 1
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/butterbiscuit
	name = "Butter Biscuit"
	result = /obj/item/food/butterbiscuit
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 1
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/butterdog
	name = "Butterdog"
	result = /obj/item/food/butterdog
	reqs = list(
		/obj/item/food/bun = 1,
		/obj/item/food/butter = 3
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/baguette
	name = "Baguette"
	time = 2 SECONDS
	result = /obj/item/food/baguette
	reqs = list(/datum/reagent/consumable/sodiumchloride = 1,
		/datum/reagent/consumable/blackpepper = 1,
		/obj/item/food/pastrybase = 2
		)
	category = CAT_BREAD

////////////////////////////////////////////////TOAST////////////////////////////////////////////////

/datum/crafting_recipe/food/slimetoast
	name = "Slime toast"
	result = /obj/item/food/jelliedtoast/slime
	reqs = list(
		/datum/reagent/toxin/slimejelly = 5,
		/obj/item/food/breadslice/plain = 1
		)
	category = CAT_BREAD

/datum/crafting_recipe/food/jelliedyoast
	name = "Jellied toast"
	result = /obj/item/food/jelliedtoast/cherry
	reqs = list(
		/datum/reagent/consumable/cherryjelly = 5,
		/obj/item/food/breadslice/plain = 1
	)
	category = CAT_BREAD

/datum/crafting_recipe/food/butteredtoast
	name = "Buttered Toast"
	result = /obj/item/food/butteredtoast
	reqs = list(
		/obj/item/food/breadslice/plain = 1,
		/obj/item/food/butter = 1
	)
	category = CAT_BREAD

/datum/crafting_recipe/food/twobread
	name = "Two bread"
	result = /obj/item/food/twobread
	reqs = list(
		/datum/reagent/consumable/ethanol/wine = 5,
		/obj/item/food/breadslice/plain = 2
	)
	category = CAT_BREAD

////////////////////////////////////////////////WEIRD////////////////////////////////////////////////

/datum/crafting_recipe/food/breadcat
	name = "Bread cat/bread hybrid"
	result = /mob/living/simple_animal/pet/cat/breadcat
	reqs = list(
		/obj/item/food/bread/plain = 1,
		/obj/item/organ/ears/cat = 1,
		/obj/item/organ/tail/cat = 1,
		/obj/item/food/meat/slab = 3,
		/datum/reagent/blood = 50,
		/datum/reagent/medicine/strange_reagent = 5
		)
	category = CAT_BREAD
