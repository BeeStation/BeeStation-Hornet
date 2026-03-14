// Cannabis
/obj/item/food/grown/cannabis
	seed = /obj/item/plant_seeds/preset/cannabis
	name = "cannabis leaf"
	desc = "Recently legalized in most galaxies."
	icon_state = "cannabis"
	bite_consumption_mod = 4
	foodtypes = VEGETABLES //i dont really know what else weed could be to be honest
	tastes = list("cannabis" = 1)
	wine_power = 20
	trade_flags = TRADE_CONTRABAND

/obj/item/food/grown/cannabis/rainbow
	name = "rainbow cannabis leaf"
	desc = "Is it supposed to be glowing like that...?"
	icon_state = "megacannabis"
	wine_power = 60
	discovery_points = 300

/obj/item/food/grown/cannabis/death
	name = "death cannabis leaf"
	desc = "Looks a bit dark. Oh well."
	icon_state = "blackcannabis"
	wine_power = 40
	discovery_points = 300

/obj/item/food/grown/cannabis/white
	name = "white cannabis leaf"
	desc = "It feels smooth and nice to the touch."
	icon_state = "whitecannabis"
	wine_power = 10
	discovery_points = 300

/obj/item/food/grown/cannabis/ultimate
	name = "omega cannabis leaf"
	desc = "You feel dizzy looking at it. What the fuck?"
	icon_state = "ocannabis"
	bite_consumption_mod = 2 // Ingesting like 40 units of drugs in 1 bite at 100 potency
	max_volume = 420
	wine_power = 90
	discovery_points = 300
