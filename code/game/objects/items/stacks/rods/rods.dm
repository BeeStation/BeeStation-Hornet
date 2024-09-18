/obj/item/stack/rods
	name = "iron rod"
	desc = "Some rods. Can be used for building or something."
	singular_name = "iron rod"
	icon_state = "rods"
	item_state = "rods"
	flags_1 = CONDUCT_1
	w_class = WEIGHT_CLASS_NORMAL
	force = 9
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	mats_per_unit = list(/datum/material/iron=1000)
	max_amount = 50
	merge_type = /obj/item/stack/rods
	attack_verb_continuous = list("hits", "bludgeons", "whacks")
	attack_verb_simple = list("hit", "bludgeon", "whack")
	hitsound = 'sound/weapons/grenadelaunch.ogg'
	embedding = list()
	novariants = TRUE
	matter_amount = 2
	cost = 250
	source = /datum/robot_energy_storage/metal

	///What is the result when we weld 2 rods together?
	var/obj/item/welding_result = /obj/item/stack/sheet/iron
	///How many of this rod do we need to be able to weld it into a sheet of usable material
	var/amount_needed = 2

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!</span>")//it looks like theyre ur mum
	return BRUTELOSS

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/rods)

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src)) // we can be deleted during merge, check before doing stuff
		return

	update_icon()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/stack/rods/get_recipes()
	return GLOB.rod_recipes

/obj/item/stack/rods/handle_openspace_click(turf/target, mob/user, proximity_flag, click_parameters)
	if(proximity_flag)
		target.attackby(src, user, click_parameters)

/obj/item/stack/rods/update_icon_state()
	. = ..()
	var/amount = get_amount()
	if(amount <= 5)
		icon_state = "[initial(icon_state)]-[amount]"
	else
		icon_state = "[initial(icon_state)]"

/obj/item/stack/rods/attackby(obj/item/W, mob/user, params)
	if(W.tool_behaviour == TOOL_WELDER && welding_result != null)
		if(get_amount() < amount_needed)
			to_chat(user, "<span class='warning'>You need at least [amount_needed] of [src] to do this!</span>")
			return

		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/result = new welding_result(usr.loc)
			user.visible_message("[user.name] shaped [src] into [result] with [W].", \
						"<span class='notice'>You shape [src] into [result] with [W].</span>", \
						"<span class='italics'>You hear welding.</span>")
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(result)

	else
		return ..()

/obj/item/stack/rods/scrap
	name = "metal scraps"
	desc = "Scraps of metal salvaged with rudimentary tools. It can be welded into an iron sheet."
	singular_name = "metal scrap"
	icon_state = "metal_scraps"
	item_state = "metal_scraps"
	w_class = WEIGHT_CLASS_SMALL
	force = 5  //being hit with this must be the equivalent of being hit with a random assortment of pebbles
	throwforce = 5
	mats_per_unit = list(/datum/material/iron=100)
	max_amount = 100
	merge_type = /obj/item/stack/rods/scrap
	matter_amount = 0
	source = null
	amount_needed = 10

/obj/item/stack/rods/scrap/get_recipes()
	return GLOB.metal_scrap_recipes

/obj/item/stack/rods/scrap/silver
	name = "silver scraps"
	desc = "Scraps of silver salvaged with rudimentary tools. It can be welded into a silver sheet."
	singular_name = "silver scrap"
	icon_state = "silver_scraps"
	item_state = "silver_scraps"
	mats_per_unit = list(/datum/material/silver=100)
	merge_type = /obj/item/stack/rods/scrap/silver
	welding_result = /obj/item/stack/sheet/mineral/silver

/obj/item/stack/rods/scrap/silver/get_recipes()
	return

/obj/item/stack/rods/scrap/plasteel
	name = "plasteel scraps"
	desc = "Scraps of plasteel salvaged with rudimentary tools. It can be welded into a plasteel sheet."
	singular_name = "plasteel scrap"
	icon_state = "plasteel_scraps"
	item_state = "plasteel_scraps"
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 80, STAMINA = 0, BLEED = 0)
	resistance_flags = FIRE_PROOF
	mats_per_unit = list(/datum/material/alloy/plasteel=100)
	merge_type = /obj/item/stack/rods/scrap/plasteel
	welding_result = /obj/item/stack/sheet/plasteel

/obj/item/stack/rods/scrap/plasteel/get_recipes()
	return

/obj/item/stack/rods/scrap/bronze
	name = "bronze scraps"
	desc = "Scraps of bronze salvaged with rudimentary tools. It can be welded into a bronze sheet."
	singular_name = "bronze scrap"
	icon_state = "bronze_scraps"
	item_state = "bronze_scraps"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mats_per_unit = list(/datum/material/copper=50, /datum/material/iron=50)
	merge_type = /obj/item/stack/rods/scrap/bronze
	welding_result = /obj/item/stack/sheet/bronze

/obj/item/stack/rods/scrap/bronze/get_recipes()
	return

/obj/item/stack/rods/scrap/glass
	name = "glass scraps"
	desc = "Scraps of glass salvaged with rudimentary tools. It can be welded into a glass sheet."
	singular_name = "glass scrap"
	icon_state = "glass_scraps"
	item_state = "glass_scraps"
	flags_1 = NONE
	resistance_flags = ACID_PROOF
	armor = list(MELEE = 100,  BULLET = 0, LASER = 0, ENERGY = 100, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 100, STAMINA = 0, BLEED = 0)
	mats_per_unit = list(/datum/material/glass=100)
	merge_type = /obj/item/stack/rods/scrap/glass
	attack_verb_continuous = list("stabs", "slashes", "slices", "cuts")
	attack_verb_simple = list("stab", "slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	welding_result = /obj/item/stack/sheet/glass

/obj/item/stack/rods/scrap/glass/get_recipes()
	return GLOB.glass_scrap_recipes

/obj/item/stack/rods/scrap/uranium
	name = "uranium scraps"
	desc = "Scraps of uranium salvaged with rudimentary tools. Can be welded into an uranium bar. You... probably shouldn't be holding this for too long..."
	singular_name = "uranium scrap"
	icon_state = "uranium_scraps"
	item_state = "uranium_scraps"
	flags_1 = NONE
	mats_per_unit = list(/datum/material/glass=100)
	merge_type = /obj/item/stack/rods/scrap/uranium
	welding_result = /obj/item/stack/sheet/mineral/uranium

/obj/item/stack/rods/scrap/uranium/Initialize(mapload, new_amount, merge, mob/user)
	. = ..()
	AddComponent(/datum/component/radioactive, amount / 5, source, 0)

/obj/item/stack/rods/scrap/uranium/get_recipes()
	return

/obj/item/stack/rods/scrap/plasma
	name = "plasma scraps"
	desc = "Scraps of plasma salvaged with rudimentary tools. Try welding it, see what happens."
	singular_name = "plasma scrap"
	icon_state = "plasma_scraps"
	item_state = "plasma_scraps"
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	mats_per_unit = list(/datum/material/plasma=100)
	merge_type = /obj/item/stack/rods/scrap/plasma
	welding_result = null

/obj/item/stack/rods/scrap/plasma/get_recipes()
	return GLOB.plasma_scrap_recipes

/obj/item/stack/rods/scrap/plasma/attackby(obj/item/W as obj, mob/user as mob, params)
	if(W.is_hot() > 300)//If the temperature of the object is over 300, then ignite
		plasma_ignition(amount/50, user)
	else
		return ..()

/obj/item/stack/rods/scrap/plasma/temperature_expose(datum/gas_mixture/air, exposed_temperature, exposed_volume)
	if(exposed_temperature > 300)
		plasma_ignition(amount/50)

/obj/item/stack/rods/scrap/plasma/bullet_act(obj/projectile/Proj)
	if(!(Proj.nodamage) && Proj.damage_type == BURN)
		plasma_ignition(amount/50, Proj?.firer)
	. = ..()

/obj/item/stack/rods/scrap/plastic
	name = "plastic scraps"
	desc = "Scraps of plastic salvaged with rudimentary tools. It can be welded into a plastic sheet."
	singular_name = "plastic scrap"
	icon_state = "plastic_scraps"
	item_state = "plastic_scraps"
	mats_per_unit = list(/datum/material/plastic=100)
	merge_type = /obj/item/stack/rods/scrap/plastic
	welding_result = /obj/item/stack/sheet/plastic

/obj/item/stack/rods/scrap/silver/get_recipes()
	return

//Yes hello, Joon here, I know paper is tecnically not a mineral butI wanted a way to make crafting with paper easier since paper doesn't stack
//salvaging the paper scraps requires you to have a wirecutter anyways so might as well be able to craft while avoiding the crafting menu
/obj/item/stack/rods/scrap/paper
	name = "paper scraps"
	desc = "Scraps of paper cut haphazardly."
	singular_name = "paper scrap"
	icon_state = "paper_scraps"
	item_state = "paper_scraps"
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	mats_per_unit = null
	merge_type = /obj/item/stack/rods/scrap/paper
	welding_result = null

/obj/item/stack/rods/scrap/paper/get_recipes()
	return GLOB.paper_scrap_recipes
