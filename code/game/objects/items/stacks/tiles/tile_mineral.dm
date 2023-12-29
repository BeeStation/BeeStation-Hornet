/obj/item/stack/tile/mineral/plasma
	name = "plasma tile"
	singular_name = "plasma floor tile"
	desc = "A tile made out of highly flammable plasma. This can only end well."
	icon_state = "tile_plasma"
	item_state = "tile-plasma"
	turf_type = /turf/open/floor/mineral/plasma
	mineralType = "plasma"
	mats_per_unit = list(/datum/material/plasma=500)

/obj/item/stack/tile/mineral/uranium
	name = "uranium tile"
	singular_name = "uranium floor tile"
	desc = "A tile made out of uranium. You feel a bit woozy."
	icon_state = "tile_uranium"
	item_state = "tile-uranium"
	turf_type = /turf/open/floor/mineral/uranium
	mineralType = "uranium"
	mats_per_unit = list(/datum/material/uranium=500)

/obj/item/stack/tile/mineral/gold
	name = "gold tile"
	singular_name = "gold floor tile"
	desc = "A tile made out of gold, the swag seems strong here."
	icon_state = "tile_gold"
	item_state = "tile-gold"
	turf_type = /turf/open/floor/mineral/gold
	mineralType = "gold"
	mats_per_unit = list(/datum/material/gold=500)

/obj/item/stack/tile/mineral/silver
	name = "silver tile"
	singular_name = "silver floor tile"
	desc = "A tile made out of silver, the light shining from it is blinding."
	icon_state = "tile_silver"
	item_state = "tile-silver"
	turf_type = /turf/open/floor/mineral/silver
	mineralType = "silver"
	mats_per_unit = list(/datum/material/silver=500)

/obj/item/stack/tile/mineral/copper
	name = "copper tile"
	singular_name = "copper floor tile"
	desc = "A tile made out of copper, so shiny!"
	icon_state = "tile_copper"
	turf_type = /turf/open/floor/mineral/copper
	mineralType = "copper"
	mats_per_unit = list(/datum/material/copper=500)

/obj/item/stack/tile/mineral/diamond
	name = "diamond tile"
	singular_name = "diamond floor tile"
	desc = "A tile made out of diamond. Wow, just, wow."
	icon_state = "tile_diamond"
	item_state = "tile-diamond"
	turf_type = /turf/open/floor/mineral/diamond
	mineralType = "diamond"
	mats_per_unit = list(/datum/material/diamond=500)

/obj/item/stack/tile/mineral/bananium
	name = "bananium tile"
	singular_name = "bananium floor tile"
	desc = "A tile made out of bananium, HOOOOOOOOONK!"
	icon_state = "tile_bananium"
	item_state = "tile-bananium"
	turf_type = /turf/open/floor/mineral/bananium
	mineralType = "bananium"
	mats_per_unit = list(/datum/material/bananium=500)
	material_flags = NONE //The slippery comp makes it unpractical for good clown decor. The material tiles should still slip.

/obj/item/stack/tile/mineral/abductor
	name = "alien floor tile"
	singular_name = "alien floor tile"
	desc = "A tile made out of alien alloy."
	icon = 'icons/obj/abductor.dmi'
	icon_state = "tile_abductor"
	item_state = "tile-abductor"
	turf_type = /turf/open/floor/mineral/abductor
	mineralType = "abductor"

/obj/item/stack/tile/mineral/titanium
	name = "titanium tile"
	singular_name = "titanium floor tile"
	desc = "A tile made of titanium, used for shuttles. Use while in your hand to change what type of titanium tiles you want."
	icon_state = "tile_shuttle"
	item_state = "tile-shuttle"
	turf_type = /turf/open/floor/mineral/titanium
	mineralType = "titanium"
	mats_per_unit = list(/datum/material/titanium=500)
	tile_reskin_types = list(
		/obj/item/stack/tile/mineral/titanium,
		/obj/item/stack/tile/mineral/titanium/yellow,
		/obj/item/stack/tile/mineral/titanium/blue,
		/obj/item/stack/tile/mineral/titanium/white,
		/obj/item/stack/tile/mineral/titanium/purple,
		/obj/item/stack/tile/mineral/titanium/alt,
		/obj/item/stack/tile/mineral/titanium/alt/yellow,
		/obj/item/stack/tile/mineral/titanium/alt/blue,
		/obj/item/stack/tile/mineral/titanium/alt/white,
		/obj/item/stack/tile/mineral/titanium/alt/purple,
		)

/obj/item/stack/tile/mineral/titanium/yellow
	name = "yellow titanium tile"
	singular_name = "yellow titanium floor tile"
	desc = "Yellow titanium tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/yellow
	icon_state = "tile_titanium_yellow"

/obj/item/stack/tile/mineral/titanium/blue
	name = "blue titanium tile"
	singular_name = "blue titanium floor tile"
	desc = "Blue titanium tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/blue
	icon_state = "tile_titanium_blue"

/obj/item/stack/tile/mineral/titanium/white
	name = "white titanium tile"
	singular_name = "white titanium floor tile"
	desc = "White titanium tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/white
	icon_state = "tile_titanium_white"

/obj/item/stack/tile/mineral/titanium/purple
	name = "purple titanium tile"
	singular_name = "purple titanium floor tile"
	desc = "Purple titanium tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/purple
	icon_state = "tile_titanium_purple"

/obj/item/stack/tile/mineral/titanium/alt
	name = "sleek titanium tile"
	singular_name = "sleek titanium floor tile"
	desc = "Sleek titanium floor tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/alt
	icon_state = "tile_titanium_alt"

/obj/item/stack/tile/mineral/titanium/alt/yellow
	name = "sleek yellow titanium tile"
	singular_name = "sleek yellow titanium floor tile"
	desc = "Sleek yellow titanium floor tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/alt/yellow
	icon_state = "tile_titanium_yellow_alt"

/obj/item/stack/tile/mineral/titanium/alt/blue
	name = "sleek blue titanium tile"
	singular_name = "sleek blue titanium floor tile"
	desc = "Sleek blue titanium floor tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/alt/blue
	icon_state = "tile_titanium_blue_alt"

/obj/item/stack/tile/mineral/titanium/alt/white
	name = "sleek white titanium tile"
	singular_name = "sleek white titanium floor tile"
	desc = "Sleek white titanium floor tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/alt/white
	icon_state = "tile_titanium_white_alt"

/obj/item/stack/tile/mineral/titanium/alt/purple
	name = "sleek purple titanium tile"
	singular_name = "sleek purple titanium floor tile"
	desc = "Sleek purple titanium floor tiles. Use while in your hand to change what type of titanium tiles you want."
	turf_type = /turf/open/floor/mineral/titanium/alt/purple
	icon_state = "tile_titanium_purple_alt"

/obj/item/stack/tile/mineral/plastitanium
	name = "plastitanium tile"
	singular_name = "plastitanium floor tile"
	desc = "A tile made of plastitanium, used for very evil shuttles."
	icon_state = "tile_darkshuttle"
	item_state = "tile-darkshuttle"
	turf_type = /turf/open/floor/mineral/plastitanium
	mineralType = "plastitanium"
	mats_per_unit = list(/datum/material/titanium=500, /datum/material/plasma=500)

/obj/item/stack/tile/mineral/snow
	name = "snow tile"
	singular_name = "snow tile"
	desc = "A layer of snow."
	icon_state = "tile_snow"
	item_state = "tile-silver"
	turf_type = /turf/open/floor/grass/snow/safe
	mineralType = "snow"

/obj/item/stack/tile/mineral/wax
	name = "wax tile"
	singular_name = "wax tile"
	desc = "A large, flat sheet of wax."
	icon_state = "tile_wax"
	item_state = "tile-wax"
	turf_type = /turf/open/floor/wax
	mineralType = "wax"

/obj/item/stack/tile/mineral/brass
	name = "brass tiles"
	desc = "An ornante tile made out of brass."
	icon_state = "tile_brass"
	item_state = "tile_brass"
	turf_type = /turf/open/floor/clockwork
	mineralType = "brass"

/obj/item/stack/tile/mineral/bronze
	name = "bronze tiles"
	desc = "An ornante tile made out of... wait this is bronze!"
	icon_state = "tile_brass"
	item_state = "tile_brass"
	turf_type = /turf/open/floor/bronze
	mineralType = "bronze"
