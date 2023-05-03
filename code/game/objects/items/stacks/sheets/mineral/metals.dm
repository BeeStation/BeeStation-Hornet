/**********************
Metals Sheets
	Contains:
		- Iron
		- Plasteel
		- Runed Metal (cult)
		- Brass (clockwork cult)
		- Bronze (bake brass)
		- Copper
		- Titanium
		- Plastitanium
		- Coal
**********************/

/* Iron */

/obj/item/stack/sheet/iron
	name = "iron"
	desc = "Sheets made out of iron."
	singular_name = "iron sheet"
	icon_state = "sheet-metal"
	item_state = "sheet-metal"
	materials = list(/datum/material/iron=MINERAL_MATERIAL_AMOUNT)
	throwforce = 10
	flags_1 = CONDUCT_1
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/iron
	grind_results = list(/datum/reagent/iron = 20)
	point_value = 2
	tableVariant = /obj/structure/table

/obj/item/stack/sheet/iron/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/iron/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/iron/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.metal_recipes
	return ..()

/obj/item/stack/sheet/iron/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins whacking [user.p_them()]self over the head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS

/* Plasteel */

/obj/item/stack/sheet/plasteel
	name = "plasteel"
	singular_name = "plasteel sheet"
	desc = "This sheet is an alloy of iron and plasma."
	icon_state = "sheet-plasteel"
	item_state = "sheet-metal"
	materials = list(/datum/material/iron=2000, /datum/material/plasma=2000)
	throwforce = 10
	flags_1 = CONDUCT_1
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 80, STAMINA = 0)
	resistance_flags = FIRE_PROOF
	merge_type = /obj/item/stack/sheet/plasteel
	grind_results = list(/datum/reagent/iron = 20, /datum/reagent/toxin/plasma = 20)
	point_value = 23
	tableVariant = /obj/structure/table/reinforced

/obj/item/stack/sheet/plasteel/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.plasteel_recipes
	return ..()

/* Runed Metal */

/obj/item/stack/sheet/runed_metal
	name = "runed metal"
	desc = "Sheets of cold metal with shifting inscriptions writ upon them."
	singular_name = "runed metal sheet"
	icon_state = "sheet-runed"
	item_state = "sheet-runed"
	//icon = 'icons/obj/stacks/mineral.dmi'
	sheettype = "runed"
	merge_type = /obj/item/stack/sheet/runed_metal
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/blood = 15)

/obj/item/stack/sheet/runed_metal/ratvar_act()
	new /obj/item/stack/sheet/brass(loc, amount)
	qdel(src)

/obj/item/stack/sheet/runed_metal/attack_self(mob/living/user)
	if(!iscultist(user))
		to_chat(user, "<span class='warning'>Only one with forbidden knowledge could hope to work this metal...</span>")
		return
	var/turf/T = get_turf(user) //we may have moved. adjust as needed...
	var/area/A = get_area(user)
	if((!is_station_level(T.z) && !is_mining_level(T.z)) || (A && !(A.area_flags & BLOBS_ALLOWED)))
		to_chat(user, "<span class='warning'>The veil is not weak enough here.</span>")
		return FALSE
	return ..()

/obj/item/stack/sheet/runed_metal/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.runed_metal_recipes
	return ..()


/* Brass - the cult one */

/obj/item/stack/sheet/brass
	name = "brass"
	desc = "Sheets made out of brass."
	singular_name = "brass sheet"
	icon_state = "sheet-brass"
	item_state = "sheet-brass"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/teslium = 15)
	merge_type = /obj/item/stack/sheet/brass
	materials = list(/datum/material/copper=MINERAL_MATERIAL_AMOUNT*0.5, /datum/material/iron=MINERAL_MATERIAL_AMOUNT*0.5)

/obj/item/stack/sheet/brass/narsie_act()
	new /obj/item/stack/sheet/runed_metal(loc, amount)
	qdel(src)

/obj/item/stack/sheet/brass/attack_self(mob/living/user)
	if(!is_servant_of_ratvar(user))
		to_chat(user, "<span class='danger'>[src] seems far too brittle to build with.</span>") //haha that's because it's actually replicant alloy you DUMMY << WOAH TOOO FAR! << :^)
	else
		return ..()

/obj/item/stack/sheet/brass/Initialize(mapload, new_amount, merge = TRUE)
	. = ..()
	recipes = GLOB.brass_recipes
	pixel_x = 0
	pixel_y = 0

/* Bronze - the non cult one */

/obj/item/stack/sheet/bronze
	name = "brass"
	desc = "On closer inspection, what appears to be wholly-unsuitable-for-building brass is actually more structurally stable bronze."
	singular_name = "bronze sheet"
	icon_state = "sheet-brass"
	item_state = "sheet-brass"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	throwforce = 10
	max_amount = 50
	throw_speed = 1
	throw_range = 3
	novariants = FALSE
	grind_results = list(/datum/reagent/iron = 5, /datum/reagent/copper = 3) //we have no "tin" reagent so this is the closest thing
	merge_type = /obj/item/stack/sheet/bronze
	tableVariant = /obj/structure/table/bronze

/obj/item/stack/sheet/bronze/attack_self(mob/living/user)
	if(is_servant_of_ratvar(user))
		to_chat(user, "<span class='danger'>Wha... what is this cheap imitation crap? This isn't brass at all!</span>")
	else
		return ..()

/obj/item/stack/sheet/bronze/Initialize(mapload, new_amount, merge = TRUE)
	recipes = GLOB.bronze_recipes
	. = ..()
	pixel_x = 0
	pixel_y = 0
