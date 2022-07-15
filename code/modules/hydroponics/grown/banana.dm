// Banana
/obj/item/seeds/banana
	name = "pack of banana seeds"
	desc = "They're seeds that grow into banana trees. When grown, keep away from clown."
	plantname = "Banana Tree"
	species = "banana"
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_state = "seed-banana"
	icon_dead = "banana-dead"
	product = /obj/item/reagent_containers/food/snacks/grown/banana

	lifespan = 50
	endurance = 30
	bitesize_mod = 5
	bite_type = PLANT_BITE_TYPE_DYNAMIC
	distill_reagent = /datum/reagent/consumable/ethanol/bananahonk

	mutatelist = list(/obj/item/seeds/banana/mime, /obj/item/seeds/banana/bluespace)
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/perennial)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(2, 6),
		/datum/reagent/consumable/nutriment/vitamin = list(3, 9),
		/datum/reagent/consumable/banana = list(5, 5),
		/datum/reagent/potassium = list(5, 10))

/obj/item/reagent_containers/food/snacks/grown/banana
	seed = /obj/item/seeds/banana
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon_state = "banana"
	item_state = "banana"
	trash = /obj/item/grown/bananapeel
	filling_color = "#FFFF00"
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/banana = 0)

/obj/item/reagent_containers/food/snacks/grown/banana/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is aiming [src] at [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	if(!user)
		return (OXYLOSS)
	user.say("BANG!", forced = /datum/reagent/consumable/banana)
	sleep(25)
	if(!user)
		return (OXYLOSS)
	user.visible_message("<B>[user]</B> laughs so hard they begin to suffocate!")
	return (OXYLOSS)

//Banana Peel
/obj/item/grown/bananapeel
	seed = /obj/item/seeds/banana
	name = "banana peel"
	desc = "A peel from a banana."
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	icon_state = "banana_peel"
	item_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7

/obj/item/grown/bananapeel/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is deliberately slipping on [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return (BRUTELOSS)


// Mimana - invisible sprites are totally a feature!
/obj/item/seeds/banana/mime
	name = "pack of mimana seeds"
	desc = "They're seeds that grow into mimana trees. When grown, keep away from mime."
	plantname = "Mimana Tree"
	species = "mimana"
	icon_state = "seed-mimana"
	growthstages = 4
	product = /obj/item/reagent_containers/food/snacks/grown/banana/mime

	rarity = 15
	distill_reagent = /datum/reagent/consumable/ethanol/silencer

	mutatelist = list(/obj/item/seeds/banana)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(2, 6),
		/datum/reagent/consumable/nothing = list(5, 20),
		/datum/reagent/toxin/mutetoxin = list(5, 15))

/obj/item/reagent_containers/food/snacks/grown/banana/mime
	seed = /obj/item/seeds/banana/mime
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash = /obj/item/grown/bananapeel/mimanapeel
	filling_color = "#FFFFEE"
	discovery_points = 300

/obj/item/grown/bananapeel/mimanapeel
	seed = /obj/item/seeds/banana/mime
	name = "mimana peel"
	desc = "A mimana peel."
	icon_state = "mimana_peel"
	item_state = "mimana_peel"

// Bluespace Banana
/obj/item/seeds/banana/bluespace
	name = "pack of bluespace banana seeds"
	desc = "They're seeds that grow into bluespace banana trees. When grown, keep away from bluespace clown."
	plantname = "Bluespace Banana Tree"
	species = "bluespacebanana"
	icon_state = "seed-banana-blue"
	icon_grow = "banana-grow"
	product = /obj/item/reagent_containers/food/snacks/grown/banana/bluespace

	wine_power = 60
	rarity = 30

	mutatelist = list()
	genes = list(/datum/plant_gene/trait/slip, /datum/plant_gene/trait/teleport, /datum/plant_gene/trait/perennial)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(2, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(3, 12),
		/datum/reagent/consumable/banana = list(10, 20),
		/datum/reagent/bluespace = list(10, 20))

/obj/item/reagent_containers/food/snacks/grown/banana/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana"
	icon_state = "banana_blue"
	item_state = "bluespace_peel"
	trash = /obj/item/grown/bananapeel/bluespace
	filling_color = "#0000FF"
	tastes = list("banana" = 1)
	wine_flavor = "slippery hypercubes"
	discovery_points = 300

/obj/item/grown/bananapeel/bluespace
	seed = /obj/item/seeds/banana/bluespace
	name = "bluespace banana peel"
	desc = "A peel from a bluespace banana."
	icon_state = "banana_peel_blue"

// Other
/obj/item/grown/bananapeel/specialpeel     //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/grown/bananapeel/specialpeel/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 40)
