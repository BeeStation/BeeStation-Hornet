// Citrus - base type
/obj/item/reagent_containers/food/snacks/grown/citrus
	seed = /obj/item/seeds/lime
	name = "citrus"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 30

// Lime
/obj/item/seeds/lime
	name = "pack of lime seeds"
	desc = "These are very sour seeds."
	icon_state = "seed-lime"
	species = "lime"
	plantname = "Lime Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lime
	lifespan = 55
	endurance = 50
	yield = 4
	potency = 15
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	genes = list(/datum/plant_gene/trait/perennial)
	mutatelist = list(/obj/item/seeds/orange)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8))

/obj/item/reagent_containers/food/snacks/grown/citrus/lime
	seed = /obj/item/seeds/lime
	name = "lime"
	desc = "It's so sour, your face will twist."
	icon_state = "lime"
	filling_color = "#00FF00"
	juice_results = list(/datum/reagent/consumable/limejuice = 0)

// Orange
/obj/item/seeds/orange
	name = "pack of orange seeds"
	desc = "Sour seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Orange Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/orange
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/perennial)
	mutatelist = list(/obj/item/seeds/lime, /obj/item/seeds/orange_3d)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8))

/obj/item/reagent_containers/food/snacks/grown/citrus/orange
	seed = /obj/item/seeds/orange
	name = "orange"
	desc = "It's a tangy fruit."
	icon_state = "orange"
	filling_color = "#FFA500"
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec

// Lemon
/obj/item/seeds/lemon
	name = "pack of lemon seeds"
	desc = "These are sour seeds."
	icon_state = "seed-lemon"
	species = "lemon"
	plantname = "Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	lifespan = 55
	endurance = 45
	yield = 4
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/perennial)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 8))
	mutatelist = list(/obj/item/seeds/firelemon)

/obj/item/reagent_containers/food/snacks/grown/citrus/lemon
	seed = /obj/item/seeds/lemon
	name = "lemon"
	desc = "When life gives you lemons, make lemonade."
	icon_state = "lemon"
	filling_color = "#FFD700"
	juice_results = list(/datum/reagent/consumable/lemonjuice = 0)

// Combustible lemon
/obj/item/seeds/firelemon //combustible lemon is too long so firelemon
	name = "pack of combustible lemon seeds"
	desc = "When life gives you lemons, don't make lemonade. Make life take the lemons back! Get mad! I don't want your damn lemons!"
	icon_state = "seed-firelemon"
	species = "firelemon"
	plantname = "Combustible Lemon Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/firelemon
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/perennial)
	lifespan = 55
	endurance = 45
	yield = 4
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(4, 8),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 6))
	mutatelist = list(/obj/item/seeds/lemon)

/obj/item/reagent_containers/food/snacks/grown/firelemon
	seed = /obj/item/seeds/firelemon
	name = "Combustible Lemon"
	desc = "Made for burning houses down."
	icon_state = "firelemon"
	bitesize_mod = 2
	foodtype = FRUIT
	wine_power = 70
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/firelemon/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] primes [src]!</span>", "<span class='userdanger'>You prime [src]!</span>")
	log_bomber(user, "primed a", src, "for detonation")
	icon_state = "firelemon_active"
	playsound(loc, 'sound/weapons/armbomb.ogg', 75, 1, -3)
	addtimer(CALLBACK(src, .proc/prime), rand(10, 60))

/obj/item/reagent_containers/food/snacks/grown/firelemon/burn()
	prime()
	..()

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/update_mob()
	if(ismob(loc))
		var/mob/M = loc
		M.dropItemToGround(src)

/obj/item/reagent_containers/food/snacks/grown/firelemon/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion

/obj/item/reagent_containers/food/snacks/grown/firelemon/proc/prime(mob/living/lanced_by)
	update_mob()
	switch(seed.potency) //Combustible lemons are alot like IEDs, lots of flame, very little bang.
		if(0 to 30)
			explosion(src.loc,-1,-1,2, flame_range = 1)
		if(31 to 50)
			explosion(src.loc,-1,-1,2, flame_range = 2)
		if(51 to 70)
			explosion(src.loc,-1,-1,2, flame_range = 3)
		if(71 to 90)
			explosion(src.loc,-1,-1,2, flame_range = 4)
		else
			explosion(src.loc,-1,-1,2, flame_range = 5)
	qdel(src) //Ensuring that it's deleted by its own explosion

//3D Orange
/obj/item/seeds/orange_3d
	name = "pack of extradimensional orange seeds"
	desc = "Polygonal seeds."
	icon_state = "seed-orange"
	species = "orange"
	plantname = "Extradimensional Orange Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d
	lifespan = 60
	endurance = 50
	yield = 5
	potency = 20
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_grow = "lime-grow"
	icon_dead = "lime-dead"
	genes = list(/datum/plant_gene/trait/perennial)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(3, 9),
		/datum/reagent/consumable/nutriment/vitamin = list(6, 12))
	mutatelist = list(/obj/item/seeds/orange)

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d
	seed = /obj/item/seeds/orange_3d
	name = "extradimensional orange"
	desc = "You can hardly wrap your head around this thing."
	icon_state = "orang"
	filling_color = "#FFA500"
	juice_results = list(/datum/reagent/consumable/orangejuice = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/triple_sec
	tastes = list("polygons" = 1, "oranges" = 1)
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d/pickup(mob/user)
	..()
	icon_state = "orange"

/obj/item/reagent_containers/food/snacks/grown/citrus/orange_3d/dropped(mob/user)
	..()
	icon_state = "orang"
