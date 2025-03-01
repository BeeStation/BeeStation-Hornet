///////////	asteroid4 items

/obj/item/paper/fluff/ruins/asteroid10/welcome
	name = "Welcome to Dog Heaven!"
	default_raw_text = "The ambassador of Dog Heaven welcomes you to our humble retreat!"

/obj/item/food/nugget/dog
	name = "dog treat"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/corgium = 10
	)

/mob/living/basic/pet/dog/corgi/chef/Initialize(mapload)
	..()
	var/obj/item/clothing/head/utility/chefhat/hat = new (src)
	inventory_head = hat
	update_corgi_fluff()
	regenerate_icons()

/mob/living/basic/pet/dog/corgi/seccie/Initialize(mapload)
	..()
	var/obj/item/clothing/head/helmet/hat = new (src)
	inventory_head = hat
	update_corgi_fluff()
	regenerate_icons()
