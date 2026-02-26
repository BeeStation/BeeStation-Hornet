// Tomato
/obj/item/food/grown/tomato
	seed = /obj/item/plant_seeds/preset/tomato
	name = "tomato"
	desc = "I say to-mah-to, you say tom-mae-to."
	icon_state = "tomato"
	splat_type = /obj/effect/decal/cleanable/food/tomato_smudge
	foodtypes = FRUIT
	grind_results = list(/datum/reagent/consumable/ketchup = 0)
	juice_typepath = /datum/reagent/consumable/tomatojuice
	distill_reagent = /datum/reagent/consumable/enzyme

// Blood Tomato
/obj/item/food/grown/tomato/blood
	name = "blood-tomato"
	desc = "So bloody...so...very...bloody....AHHHH!!!!"
	icon_state = "bloodtomato"
	bite_consumption_mod = 3
	splat_type = /obj/effect/gibspawner/generic/bloodtomato
	foodtypes = FRUIT | GROSS
	grind_results = list(/datum/reagent/consumable/ketchup = 0, /datum/reagent/blood = 0)
	distill_reagent = /datum/reagent/consumable/ethanol/bloody_mary
	discovery_points = 300

/obj/item/food/grown/tomato/blood/throw_at(atom/target, range, speed, mob/thrower, spin=1, diagonals_first = 0, datum/callback/callback, force, quickstart = TRUE)
	if(istype(thrower) && thrower.ckey)
		thrower.investigate_log("has thrown bloodtomatoes at [AREACOORD(thrower)].", INVESTIGATE_BOTANY)
	. = ..()

// Blue Tomato
/obj/item/food/grown/tomato/blue
	name = "blue-tomato"
	desc = "I say blue-mah-to, you say blue-mae-to."
	icon_state = "bluetomato"
	bite_consumption_mod = 2
	splat_type = /obj/effect/decal/cleanable/oil
	distill_reagent = /datum/reagent/consumable/laughter
	discovery_points = 300

// Bluespace Tomato
/obj/item/food/grown/tomato/blue/bluespace
	name = "bluespace tomato"
	desc = "So lubricated, you might slip through space-time."
	icon_state = "bluespacetomato"
	bite_consumption_mod = 3
	distill_reagent = null
	wine_power = 80
	discovery_points = 300

// Killer Tomato
/obj/item/food/grown/tomato/killer
	name = "killer-tomato"
	desc = "I say to-mah-to, you say tom-mae-to... OH GOD IT'S EATING MY LEGS!!"
	icon_state = "killertomato"
	var/awakening = FALSE
	filling_color = COLOR_RED
	distill_reagent = /datum/reagent/consumable/ethanol/demonsblood
	discovery_points = 300
