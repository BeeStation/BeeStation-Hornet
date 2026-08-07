/obj/item/stack/rods
	name = "iron rod"
	desc = "Some rods. Can be used for building or something."
	singular_name = "iron rod"
	icon_state = "rods"
	base_icon_state = "rods"
	inhand_icon_state = "rods"
	obj_flags = CONDUCTS_ELECTRICITY
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

/obj/item/stack/rods/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] begins to stuff \the [src] down [user.p_their()] throat! It looks like [user.p_theyre()] trying to commit suicide!"))//it looks like theyre ur mum
	return BRUTELOSS

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/stack/rods)

/obj/item/stack/rods/Initialize(mapload, new_amount, merge = TRUE, mob/user = null)
	. = ..()
	if(QDELETED(src)) // we can be deleted during merge, check before doing stuff
		return

	update_appearance(UPDATE_ICON_STATE)
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
		icon_state = "[base_icon_state]-[amount]"
	else
		icon_state = base_icon_state

/obj/item/stack/rods/welder_act(mob/living/user, obj/item/tool)
	if(get_amount() < 2)
		balloon_alert(user, "not enough rods!")
		return
	if(tool.use_tool(src, user, delay = 0, volume = 40))
		var/obj/item/stack/sheet/iron/new_item = new(user.loc)
		user.visible_message(
			span_notice("[user.name] shaped [src] into iron sheets with [tool]."),
			blind_message = span_hear("You hear welding."),
			vision_distance = COMBAT_MESSAGE_RANGE,
			ignored_mobs = user
		)
		use(2)
		user.put_in_inactive_hand(new_item)
		return TOOL_ACT_TOOLTYPE_SUCCESS
