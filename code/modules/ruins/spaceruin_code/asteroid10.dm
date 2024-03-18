///////////	asteroid4 items

/obj/item/paper/fluff/ruins/asteroid10/welcome
	name = "Welcome to Dog Heaven!"
	default_raw_text = "The ambassador of Dog Heaven welcomes you to our humble retreat!"

/obj/item/reagent_containers/food/snacks/nugget/dog
	name = "dog treat"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1,/datum/reagent/corgium = 10)

/mob/living/simple_animal/pet/dog/corgi/chef/Initialize(mapload)
	..()
	var/obj/item/clothing/head/chefhat/hat = new (src)
	inventory_head = hat
	update_corgi_fluff()
	regenerate_icons()

/mob/living/simple_animal/pet/dog/corgi/seccie/Initialize(mapload)
	..()
	var/obj/item/clothing/head/helmet/hat = new (src)
	inventory_head = hat
	update_corgi_fluff()
	regenerate_icons()
