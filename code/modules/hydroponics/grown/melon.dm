// Watermelon
/obj/item/seeds/watermelon
	name = "pack of watermelon seeds"
	desc = "These seeds grow into watermelon plants."
	icon_state = "seed-watermelon"
	species = "watermelon"
	plantname = "Watermelon Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/watermelon
	lifespan = 50
	endurance = 40
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	icon_dead = "watermelon-dead"
	genes = list(/datum/plant_gene/trait/repeated_harvest)
	mutatelist = list(/obj/item/seeds/watermelon/holy)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(15, 20),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 6),
		/datum/reagent/water = list(15, 20))

/obj/item/seeds/watermelon/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is swallowing [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	user.gib()
	new product(drop_location())
	qdel(src)
	return MANUAL_SUICIDE

/obj/item/reagent_containers/food/snacks/grown/watermelon
	seed = /obj/item/seeds/watermelon
	name = "watermelon"
	desc = "It's full of watery goodness."
	icon_state = "watermelon"
	slice_path = /obj/item/reagent_containers/food/snacks/watermelonslice
	slices_num = 5
	dried_type = null
	w_class = WEIGHT_CLASS_NORMAL
	filling_color = "#008000"
	bitesize_mod = 3
	foodtype = FRUIT
	juice_results = list(/datum/reagent/consumable/watermelonjuice = 0)
	wine_power = 40

// Holymelon
/obj/item/seeds/watermelon/holy
	name = "pack of holymelon seeds"
	desc = "These seeds grow into holymelon plants."
	icon_state = "seed-holymelon"
	species = "holymelon"
	plantname = "Holy Melon Vines"
	product = /obj/item/reagent_containers/food/snacks/grown/holymelon
	genes = list(/datum/plant_gene/trait/glow/yellow)
	mutatelist = list(/obj/item/seeds/watermelon)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(10, 20),
		/datum/reagent/consumable/nutriment/vitamin = list(4, 6),
		/datum/reagent/water/holywater = list(20, 5)) // Holywater is only fluent when it is in holymelon
	rarity = 20

/obj/item/reagent_containers/food/snacks/grown/holymelon
	seed = /obj/item/seeds/watermelon/holy
	name = "holymelon"
	desc = "The water within this melon has been blessed by some deity that's particularly fond of watermelon."
	icon_state = "holymelon"
	filling_color = "#FFD700"
	dried_type = null
	wine_power = 70 //Water to wine, baby.
	wine_flavor = "divinity"
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/holymelon/Initialize(mapload)
	. = ..()
	var/uses = 1
	if(seed)
		uses = round(seed.potency / 20)
	AddComponent(/datum/component/anti_magic, TRUE, TRUE, uses, TRUE, CALLBACK(src, .proc/block_magic), CALLBACK(src, .proc/expire)) //deliver us from evil o melon god

/obj/item/reagent_containers/food/snacks/grown/holymelon/proc/block_magic(mob/user, major)
	if(major)
		to_chat(user, "<span class='warning'>[src] hums slightly, and seems to decay a bit.</span>")

/obj/item/reagent_containers/food/snacks/grown/holymelon/proc/expire(mob/user)
	to_chat(user, "<span class='warning'>[src] rapidly turns into ash!</span>")
	qdel(src)
	new /obj/effect/decal/cleanable/ash(drop_location())
