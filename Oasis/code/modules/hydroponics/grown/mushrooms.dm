//Add mutation to walking mush
/obj/item/seeds/plump/walkingmushroom
	mutatelist = list(/obj/item/seeds/plump/spongy_mushroom)

// Spongy Mushroom This mutated walking mushroom will try to kill you by drugging you with his bites, arasnep, space drugs and happiness are his main drugs.
/obj/item/seeds/plump/spongy_mushroom
	name = "pack of walking mushroom mycelium"
	desc = "This mycelium will grow into huge stuff!"
	icon_state = "mycelium-spongy"
	species = "spongymushroom"
	plantname = "Spongy Mushrooms"
	product = /obj/item/reagent_containers/food/snacks/grown/mushroom/spongy_mushroom
	lifespan = 50
	endurance = 35
	maturation = 4
	growthstages = 3
	yield = 1
	growing_icon = 'Oasis/icons/obj/hydroponics/growing_mushrooms.dmi'
	mutatelist = list()
	reagents_add = list(/datum/reagent/consumable/nutriment/vitamin = 0.05, /datum/reagent/consumable/nutriment = 0.5, /datum/reagent/drug/space_drugs = 0.1, /datum/reagent/drug/aranesp = 1, /datum/reagent/drug/happiness = 0.5, /datum/reagent/drug/nicotine = 0.05, /datum/reagent/drug/crank = 0.05, /datum/reagent/drug/krokodil = 0.05, /datum/reagent/drug/methamphetamine = 0.05, /datum/reagent/drug/bath_salts = 0.05)
	rarity = 80

/obj/item/reagent_containers/food/snacks/grown/mushroom/spongy_mushroom
	seed = /obj/item/seeds/plump/spongy_mushroom
	name = "Spongy Mushroom"
	desc = "<I>Plumus Locomotus</I>: The beginning of the great walk."
	icon_state = "spongy_mushroom"
	filling_color = "#9370DB"
	can_distill = FALSE

/obj/item/reagent_containers/food/snacks/grown/mushroom/spongy_mushroom/attack_self(mob/user)
	if(isspaceturf(user.loc))
		return
	var/mob/living/simple_animal/hostile/spongy_mushroom/M = new /mob/living/simple_animal/hostile/spongy_mushroom(user.loc)
	M.maxHealth += round(seed.endurance / 4)
	M.melee_damage += round(seed.potency / 20)
	M.move_to_delay -= round(seed.production / 50)
	M.health = M.maxHealth
	qdel(src)
	to_chat(user, "<span class='notice'>You plant the spongy mushroom.</span>")
