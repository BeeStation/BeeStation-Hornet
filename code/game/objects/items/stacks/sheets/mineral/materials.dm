/**********************
Mineral Sheets
	Contains:
		- Sandstone
		- Diamond
		- Uranium
		- Plasma
		- Gold
		- Silver
		- Copper
		- Titanium
		- Plastitanium
		- Coal
**********************/

//the "/mineral" don't make sense, but i'm keeping it because holy shit changing a tons of name is going to be pain, if you're gonna replace it, do replace it with something like "/fancy" or "/random"

/* Sandstone */

/obj/item/stack/sheet/mineral/sandstone
	name = "sandstone brick"
	desc = "This appears to be a combination of both sand and stone."
	singular_name = "sandstone brick"
	icon_state = "sheet-sandstone"
	item_state = "sheet-sandstone"
	throw_speed = 3
	throw_range = 5
	mats_per_unit = list(/datum/material/glass=MINERAL_MATERIAL_AMOUNT)
	sheettype = "sandstone"
	merge_type = /obj/item/stack/sheet/mineral/sandstone

/obj/item/stack/sheet/mineral/sandstone/get_main_recipes()
	. = ..()
	. += GLOB.sandstone_recipes

/* Diamond */

/obj/item/stack/sheet/mineral/diamond
	name = "diamond"
	icon_state = "sheet-diamond"
	item_state = "sheet-diamond"
	singular_name = "diamond"
	sheettype = "diamond"
	mats_per_unit = list(/datum/material/diamond=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/carbon = 20)
	point_value = 25
	merge_type = /obj/item/stack/sheet/mineral/diamond
	material_type = /datum/material/diamond

/obj/item/stack/sheet/mineral/diamond/get_main_recipes()
	. = ..()
	. += GLOB.diamond_recipes

/* Uranium */

/obj/item/stack/sheet/mineral/uranium
	name = "uranium"
	icon_state = "sheet-uranium"
	item_state = "sheet-uranium"
	singular_name = "uranium rod"
	sheettype = "uranium"
	mats_per_unit = list(/datum/material/uranium=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/uranium = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/uranium
	material_type = /datum/material/uranium

/obj/item/stack/sheet/mineral/uranium/get_main_recipes()
	. = ..()
	. += GLOB.uranium_recipes

/* Plasma */

/obj/item/stack/sheet/mineral/plasma
	name = "solid plasma"
	icon_state = "sheet-plasma"
	item_state = "sheet-plasma"
	singular_name = "plasma crystal"
	sheettype = "plasma"
	resistance_flags = FLAMMABLE
	max_integrity = 100
	mats_per_unit = list(/datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/toxin/plasma = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/plasma
	material_type = /datum/material/plasma

/obj/item/stack/sheet/mineral/plasma/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins licking \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return TOXLOSS//dont you kids know that stuff is toxic?

/obj/item/stack/sheet/mineral/plasma/get_main_recipes()
	. = ..()
	. += GLOB.plasma_recipes

/obj/item/stack/sheet/mineral/plasma/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		plasma_ignition(amount/5, user)
	else
		return ..()

/obj/item/stack/sheet/mineral/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		plasma_ignition(amount/5)

/obj/item/stack/sheet/mineral/plasma/bullet_act(obj/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		plasma_ignition(amount/5, Proj?.firer)
	. = ..()

/* Gold */

/obj/item/stack/sheet/mineral/gold
	name = "gold"
	icon_state = "sheet-gold"
	item_state = "sheet-gold"
	singular_name = "gold bar"
	sheettype = "gold"
	mats_per_unit = list(/datum/material/gold=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/gold = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/gold
	material_type = /datum/material/gold

/obj/item/stack/sheet/mineral/gold/get_main_recipes()
	. = ..()
	. += GLOB.gold_recipes

/* Silver */

/obj/item/stack/sheet/mineral/silver
	name = "silver"
	icon_state = "sheet-silver"
	item_state = "sheet-silver"
	singular_name = "silver bar"
	sheettype = "silver"
	mats_per_unit = list(/datum/material/silver=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/silver = 20)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/silver
	material_type = /datum/material/silver
	tableVariant = /obj/structure/table/optable

/obj/item/stack/sheet/mineral/silver/get_main_recipes()
	. = ..()
	. += GLOB.silver_recipes

/* Copper */

/obj/item/stack/sheet/mineral/copper
	name = "copper"
	icon_state = "sheet-copper"
	item_state = "sheet-copper"
	singular_name = "copper bar"
	sheettype = "copper"
	mats_per_unit = list(/datum/material/copper=MINERAL_MATERIAL_AMOUNT)
	grind_results = list(/datum/reagent/copper = 20)
	point_value = 3
	merge_type = /obj/item/stack/sheet/mineral/copper


/obj/item/stack/sheet/mineral/copper/get_main_recipes()
	. = ..()
	. += GLOB.copper_recipes

/* Titanium */

/obj/item/stack/sheet/mineral/titanium
	name = "titanium"
	icon_state = "sheet-titanium"
	item_state = "sheet-titanium"
	singular_name = "titanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "titanium"
	mats_per_unit = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT)
	point_value = 20
	merge_type = /obj/item/stack/sheet/mineral/titanium
	material_type = /datum/material/titanium

/obj/item/stack/sheet/mineral/titanium/get_main_recipes()
	. = ..()
	. += GLOB.titanium_recipes

/* Plastitanium */

/obj/item/stack/sheet/mineral/plastitanium
	name = "plastitanium"
	icon_state = "sheet-plastitanium"
	item_state = "sheet-plastitanium"
	singular_name = "plastitanium sheet"
	force = 5
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	throw_speed = 1
	throw_range = 3
	sheettype = "plastitanium"
	mats_per_unit = list(/datum/material/titanium=MINERAL_MATERIAL_AMOUNT, /datum/material/plasma=MINERAL_MATERIAL_AMOUNT)
	point_value = 45
	merge_type = /obj/item/stack/sheet/mineral/plastitanium
	material_flags = NONE

/obj/item/stack/sheet/mineral/plastitanium/get_main_recipes()
	. = ..()
	. += GLOB.plastitanium_recipes

/* Coal */

/obj/item/stack/sheet/mineral/coal
	name = "coal"
	desc = "Someone's gotten on the naughty list."
	icon_state = "coal"
	singular_name = "coal lump"
	merge_type = /obj/item/stack/sheet/mineral/coal
	grind_results = list(/datum/reagent/carbon = 20)
	novariants = TRUE

/obj/item/stack/sheet/mineral/coal/attackby(obj/item/W, mob/user, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		var/turf/T = get_turf(src)
		message_admins("Coal ignited by [ADMIN_LOOKUPFLW(user)] in [ADMIN_VERBOSEJMP(T)]")
		log_game("Coal ignited by [key_name(user)] in [AREACOORD(T)]")
		fire_act(W.is_hot())
		return TRUE
	else
		return ..()

/obj/item/stack/sheet/mineral/coal/fire_act(exposed_temperature, exposed_volume)
	atmos_spawn_air("co2=[amount*10];TEMP=[exposed_temperature]")
	qdel(src)

