
/// Soups Crafting

/datum/crafting_recipe/food/oatmeal
	name = "Oatmeal"
	result = /obj/item/food/soup/oatmeal
	reqs = list(
		/datum/reagent/consumable/milk = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/oat = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/meatballsoup
	name = "Meatball soup"
	result = /obj/item/food/soup/meatball
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/meatball = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/potato = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/vegetablesoup
	name = "Vegetable soup"
	result = /obj/item/food/soup/vegetable
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/corn = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/potato = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/nettlesoup
	name = "Nettle soup"
	result = /obj/item/food/soup/nettle
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/nettle = 1,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/boiledegg = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/wingfangchu
	name = "Wingfangchu"
	result = /obj/item/food/soup/wingfangchu
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/datum/reagent/consumable/soysauce = 5,
		/obj/item/food/meat/cutlet/xeno = 2
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/wishsoup
	name = "Wish soup"
	result= /obj/item/food/soup/wish
	reqs = list(
		/datum/reagent/water = 20,
		/obj/item/reagent_containers/cup/bowl = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/hotchili
	name = "Hot chili"
	result = /obj/item/food/soup/hotchili
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/coldchili
	name = "Cold chili"
	result = /obj/item/food/soup/coldchili
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/meat/cutlet = 2,
		/obj/item/food/grown/icepepper = 1,
		/obj/item/food/grown/tomato = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/tomatosoup
	name = "Tomato soup"
	result = /obj/item/food/soup/tomato
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/tomato = 2
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/eyeballsoup
	name = "Eyeball soup"
	result = /obj/item/food/soup/tomato/eyeball
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/tomato = 2,
		/obj/item/organ/eyes = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/misosoup
	name = "Miso soup"
	result = /obj/item/food/soup/miso
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/soydope = 2,
		/obj/item/food/tofu = 2
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/bloodsoup
	name = "Blood soup"
	result = /obj/item/food/soup/blood
	reqs = list(
		/datum/reagent/blood = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/tomato/blood = 2
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/slimesoup
	name = "Slime soup"
	result = /obj/item/food/soup/slime
	reqs = list(
	/datum/reagent/water = 10,
	/datum/reagent/toxin/slimejelly = 5,
	/obj/item/reagent_containers/cup/bowl = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/clownstears
	name = "Clowns tears"
	result = /obj/item/food/soup/clownstears
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/banana = 1,
		/obj/item/stack/sheet/mineral/bananium = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/mysterysoup
	name = "Mystery soup"
	result = /obj/item/food/soup/mystery
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/badrecipe = 1,
		/obj/item/food/tofu = 1,
		/obj/item/food/boiledegg = 1,
		/obj/item/food/cheese/wedge = 1,
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/mushroomsoup
	name = "Mushroom soup"
	result = /obj/item/food/soup/mushroom
	reqs = list(
		/datum/reagent/consumable/milk = 5,
		/datum/reagent/water = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/chanterelle = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/beetsoup
	name = "Beet soup"
	result = /obj/item/food/soup/beet
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/whitebeet = 1,
		/obj/item/food/grown/cabbage = 1,
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/stew
	name = "Stew"
	result = /obj/item/food/soup/stew
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/tomato = 1,
		/obj/item/food/meat/cutlet = 3,
		/obj/item/food/grown/potato = 1,
		/obj/item/food/grown/carrot = 1,
		/obj/item/food/grown/eggplant = 1,
		/obj/item/food/grown/mushroom = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/spacylibertyduff
	name = "Spacy liberty duff"
	result = /obj/item/food/soup/spacylibertyduff
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/libertycap = 3
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/amanitajelly
	name = "Amanita jelly"
	result = /obj/item/food/soup/amanitajelly
	reqs = list(
		/datum/reagent/consumable/ethanol/vodka = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/amanita = 3
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/sweetpotatosoup
	name = "Sweet potato soup"
	result = /obj/item/food/soup/sweetpotato
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sugar = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/potato/sweet = 2
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/redbeetsoup
	name = "Red beet soup"
	result = /obj/item/food/soup/beet/red
	reqs = list(
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/redbeet = 1,
		/obj/item/food/grown/cabbage = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/bisque
	name = "Bisque"
	result = /obj/item/food/soup/bisque
	reqs = list(
		/obj/item/reagent_containers/cup/bowl = 1,
		/datum/reagent/water = 10,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/meat/crab = 1,
		/obj/item/food/boiledrice = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/bungocurry
	name = "Bungo Curry"
	result = /obj/item/food/soup/bungocurry
	reqs = list(
		/datum/reagent/water = 5,
		/datum/reagent/consumable/cream = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/chili = 1,
		/obj/item/food/grown/bungofruit = 1
	)
	category = CAT_SOUP

/datum/crafting_recipe/food/electron
	name = "Electron Soup"
	result = /obj/item/food/soup/electron
	reqs = list(
		/datum/reagent/water = 10,
		/datum/reagent/consumable/sodiumchloride = 5,
		/obj/item/reagent_containers/cup/bowl = 1,
		/obj/item/food/grown/mushroom/jupitercup = 1
	)
	category = CAT_SOUP
