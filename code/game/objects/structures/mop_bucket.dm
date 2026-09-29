/obj/structure/mop_bucket
	name = "mop bucket"
	desc = "Fill it with water, but don't forget a mop!"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "mopbucket"
	density = TRUE

/obj/structure/mop_bucket/Initialize(mapload)
	. = ..()
	create_reagents(100, OPENCONTAINER)

/obj/item/modular_computer/add_context_self(datum/screentip_context/context, mob/user)
	context.add_right_click_item_action("Wet mop", /obj/item/mop)
	context.add_right_click_item_action("Fill mop bucket", /obj/item/reagent_containers)

/obj/structure/mop_bucket/item_interaction_secondary(mob/living/user, obj/item/tool, list/modifiers)
	if(!istype(tool, /obj/item/mop))
		return NONE

	if(tool.reagents.total_volume >= tool.reagents.maximum_volume)
		balloon_alert(user, "already soaked!")
		return ITEM_INTERACT_BLOCKING

	if(reagents.total_volume < 1)
		balloon_alert(user, "empty!")
		return ITEM_INTERACT_BLOCKING

	reagents.trans_to(tool, tool.reagents.maximum_volume, transfered_by = user)
	balloon_alert(user, "doused mop")
	playsound(src, 'sound/effects/slosh.ogg', 25, vary = TRUE)
	update_appearance(UPDATE_OVERLAYS)
	return ITEM_INTERACT_SUCCESS

/obj/structure/mop_bucket/update_overlays()
	. = ..()
	if(reagents.total_volume > 0)
		. += "mopbucket_water"
