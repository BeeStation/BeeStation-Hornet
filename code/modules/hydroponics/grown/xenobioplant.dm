// Gatfruit
/obj/item/seeds/gatfruit
	name = "pack of gatfruit seeds"
	desc = "These seeds grow into .357 revolvers."
	icon_state = "seed-gatfruit"
	species = "gatfruit"
	plantname = "Gatfruit Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	genes = list(/datum/plant_gene/trait/perennial)
	lifespan = 20
	endurance = 20
	maturation = 40
	production = 10
	yield = 2
	potency = 60
	growthstages = 2
	rarity = 60 // Obtainable only with xenobio+superluck.
	growing_icon = 'icons/obj/hydroponics/growing_fruits.dmi'
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(0, 1),
		/datum/reagent/consumable/nutriment/vitamin = list(0, 1),
		/datum/reagent/carbon = list(10, 15),
		/datum/reagent/sulfur = list(10, 15),
		/datum/reagent/nitrogen = list(7, 15),
		/datum/reagent/potassium = list(5, 15))

/obj/item/reagent_containers/food/snacks/grown/shell/gatfruit
	seed = /obj/item/seeds/gatfruit
	name = "gatfruit"
	desc = "It smells like burning."
	icon_state = "gatfruit"
	trash = /obj/item/gun/ballistic/revolver
	bitesize_mod = 2
	foodtype = FRUIT
	tastes = list("gunpowder" = 1)
	wine_power = 90 //It burns going down, too.

//Cherry Bombs
/obj/item/seeds/cherry/bomb
	name = "pack of cherry bomb pits"
	desc = "They give you vibes of dread and frustration."
	icon_state = "seed-cherry_bomb"
	species = "cherry_bomb"
	plantname = "Cherry Bomb Tree"
	product = /obj/item/reagent_containers/food/snacks/grown/cherry_bomb

	volume_mod = 125
	bitesize_mod = 2
	bite_type = PLANT_BITE_TYPE_CONSTANT
	rarity = 60
	wine_power = 80

	mutatelist = list()
	genes = list(/datum/plant_gene/trait/no_maxchem)
	reagents_set = list(
		/datum/reagent/consumable/nutriment = list(8, 15),
		/datum/reagent/consumable/nutriment/vitamin = list(2, 10),
		/datum/reagent/consumable/sugar = list(10, 15),
		/datum/reagent/blackpowder = list(70, 100))

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb
	name = "cherry bombs"
	desc = "You think you can hear the hissing of a tiny fuse."
	icon_state = "cherry_bomb"
	filling_color = rgb(20, 20, 20)
	seed = /obj/item/seeds/cherry/bomb
	max_integrity = 40
	discovery_points = 300

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/attack_self(mob/living/user)
	user.visible_message("<span class='warning'>[user] plucks the stem from [src]!</span>", "<span class='userdanger'>You pluck the stem from [src], which begins to hiss loudly!</span>")
	log_bomber(user, "primed a", src, "for detonation")
	prime()

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/deconstruct(disassembled = TRUE)
	if(!disassembled)
		prime()
	if(!QDELETED(src))
		qdel(src)

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/ex_act(severity)
	qdel(src) //Ensuring that it's deleted by its own explosion. Also prevents mass chain reaction with piles of cherry bombs

/obj/item/reagent_containers/food/snacks/grown/cherry_bomb/proc/prime(mob/living/lanced_by)
	icon_state = "cherry_bomb_lit"
	playsound(src, 'sound/effects/fuse.ogg', seed.potency, 0)
	reagents.chem_temp = 1000 //Sets off the black powder
	reagents.handle_reactions()

