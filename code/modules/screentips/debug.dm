/obj/structure/screentip_test
	name = "Screentip Test"
	icon_state = "speaking_tile"

/obj/structure/screentip_test/add_context_self(datum/screentip_context/context, mob/user)
	context.use_cache()
	context.add_left_click_action("Action")
	context.add_right_click_action("Alt. Action")
	context.add_left_click_tool_action("Weld", TOOL_WELDER)
	context.add_right_click_tool_action("Unweld", TOOL_WELDER)
	context.add_left_click_tool_action("Wrench", TOOL_WRENCH)
	context.add_attack_hand_action("Attack hand")
	context.add_attack_hand_secondary_action("Right click hand")

/obj/structure/screentip_test/uncache/add_context_self(datum/screentip_context/context, mob/user)
	..()
	context.add_left_click_item_action("Item Action", /obj/item)
