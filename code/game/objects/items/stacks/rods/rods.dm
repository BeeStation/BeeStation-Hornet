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
	user.visible_message(span_suicide("[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!"))//it looks like theyre ur mum
	return BRUTELOSS

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/rods)

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src)) // we can be deleted during merge, check before doing stuff
		return

	update_icon()
	AddElement(/datum/element/openspace_item_click_handler)

/obj/item/stack/rods/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_left_click_tool_action("Weld into sheet", TOOL_WELDER)

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
			to_chat(user, span_warning("You need at least [amount_needed] of [src] to do this!"))
			return

		if(W.use_tool(src, user, 0, volume=40))
			var/obj/item/result = new welding_result(usr.loc)
			user.visible_message("[user.name] shaped [src] into [result] with [W].", \
						span_notice("You shape [src] into [result] with [W]."), \
						span_italics("You hear welding.</span>"))
			var/obj/item/stack/rods/R = src
			src = null
			var/replace = (user.get_inactive_held_item()==R)
			R.use(2)
			if (!R && replace)
				user.put_in_hands(result)

	else
		return ..()

/obj/item/stack/rods/scrap
	name = null
	desc =null
	singular_name = null
	icon_state = null
	item_state = null
	/// This is used to for name, descriptions and icon states that are empty above!
	var/name_type = "metal"
	w_class = WEIGHT_CLASS_SMALL
	material_flags = MATERIAL_EFFECTS //This is necessary to ensure the rods behave as the materials would have them behave
	force = 5  //being hit with this must be the equivalent of being hit with a random assortment of pebbles
	throwforce = 5
	max_amount = 100
	matter_amount = 0
	source = null
	amount_needed = 10

/obj/item/stack/rods/scrap/Initialize()
	name = "[name_type] scraps"
	if(isnull(desc))
		desc = "Scraps of [name_type] salvaged with rudimentary tools. It can be welded into a [welding_result.name]."
	singular_name = "[name_type] scrap"
	icon_state = "[name_type]_scraps"
	item_state = "[name_type]_scraps"

/obj/item/stack/rods/scrap/get_recipes()
	return list()

/obj/item/stack/rods/scrap/metal
	/// This will be used during automation for name, description and icon states!
	name_type = "metal"
	mats_per_unit = list(/datum/material/iron=100)
	merge_type = /obj/item/stack/rods/scrap
	welding_result = /obj/item/stack/sheet/iron	// We're duping this just for the sake of clarity

/obj/item/stack/rods/scrap/metal/get_recipes()
	return GLOB.metal_scrap_recipes

/obj/item/stack/rods/scrap/silver
	name_type = "silver"
	mats_per_unit = list(/datum/material/silver=100)
	merge_type = /obj/item/stack/rods/scrap/silver
	welding_result = /obj/item/stack/sheet/mineral/silver

/obj/item/stack/rods/scrap/gold
	name_type = "gold"
	mats_per_unit = list(/datum/material/gold=100)
	merge_type = /obj/item/stack/rods/scrap/gold
	welding_result = /obj/item/stack/sheet/mineral/gold

/obj/item/stack/rods/scrap/plasteel
	name_type = "plasteel"
	resistance_flags = FIRE_PROOF
	mats_per_unit = list(/datum/material/alloy/plasteel=100)
	merge_type = /obj/item/stack/rods/scrap/plasteel
	welding_result = /obj/item/stack/sheet/plasteel

/obj/item/stack/rods/scrap/bronze
	name_type = "bronze"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	mats_per_unit = list(/datum/material/copper=50, /datum/material/iron=50)
	merge_type = /obj/item/stack/rods/scrap/bronze
	welding_result = /obj/item/stack/sheet/bronze

/obj/item/stack/rods/scrap/glass
	name_type = "glass"
	flags_1 = NONE
	resistance_flags = ACID_PROOF
	mats_per_unit = list(/datum/material/glass=100)
	merge_type = /obj/item/stack/rods/scrap/glass
	attack_verb_continuous = list("stabs", "slashes", "slices", "cuts")
	attack_verb_simple = list("stab", "slash", "slice", "cut")
	hitsound = 'sound/weapons/bladeslice.ogg'
	welding_result = /obj/item/stack/sheet/glass

/obj/item/stack/rods/scrap/glass/get_recipes()
	return GLOB.glass_scrap_recipes

/obj/item/stack/rods/scrap/uranium
	name_type = "uranium"
	flags_1 = NONE
	mats_per_unit = list(/datum/material/uranium=100)
	merge_type = /obj/item/stack/rods/scrap/uranium
	welding_result = /obj/item/stack/sheet/mineral/uranium

/obj/item/stack/rods/scrap/plasma
	name = "plasma scraps"
	desc = "Scraps of plasma salvaged with rudimentary tools. Try welding them, see what happens."
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	mats_per_unit = list(/datum/material/plasma=100)
	merge_type = /obj/item/stack/rods/scrap/plasma
	welding_result = null

/obj/item/stack/rods/scrap/plasma/get_recipes()
	return GLOB.plasma_scrap_recipes

/obj/item/stack/rods/scrap/plastic
	name_type = "plastic"
	mats_per_unit = list(/datum/material/plastic=100)
	merge_type = /obj/item/stack/rods/scrap/plastic
	welding_result = /obj/item/stack/sheet/plastic

//Yes hello, Joon here, I know paper is tecnically not a mineral but I wanted a way to make crafting with paper easier since paper doesn't stack
//salvaging the paper scraps requires you to have a wirecutter anyways so might as well be able to craft while avoiding the crafting menu
/obj/item/stack/rods/scrap/paper
	name_type = "paper"
	desc = "Scraps of paper cut haphazardly."
	flags_1 = NONE
	resistance_flags = FLAMMABLE
	max_integrity = 100
	mats_per_unit = null
	merge_type = /obj/item/stack/rods/scrap/paper
	welding_result = null

/obj/item/stack/rods/scrap/paper/get_recipes()
	return GLOB.paper_scrap_recipes
