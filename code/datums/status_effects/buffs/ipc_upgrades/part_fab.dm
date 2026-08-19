/datum/status_effect/ipc_upgrade/part_fab
	id = "ipc part fab"
	name = "Part Fabricator"
	slot = UPGRADE_UTILITY
	action_type = /datum/action/innate/ipc_upgrade_action/untargeted
	action_icon = "part_fab"
	power_requirement = 150
	singleton = TRUE
	cooldown_length = 1 SECONDS
	item_type = /obj/item/ipc_upgrade/part_fab
	var/list/part_types = list(/obj/item/stock_parts/manipulator, /obj/item/stock_parts/micro_laser, /obj/item/stock_parts/matter_bin, /obj/item/stock_parts/capacitor, /obj/item/stock_parts/scanning_module)

/datum/status_effect/ipc_upgrade/part_fab/on_activate(atom/target)
	var/list/choice_list = list()
	var/list/type_list = list()
	for(var/atom/item_type as anything in part_types) // why this works??? no clue! I guess you can get default vars from typepaths, but only if you cast it as an atom...?
		choice_list[item_type.name] = image(icon = item_type.icon, icon_state = item_type.icon_state)
		type_list[item_type.name] = item_type
	var/choice_type = type_list[show_radial_menu(owner, owner, choice_list)]
	if(!choice_type)
		return
	var/obj/item/choice = new choice_type(get_turf(owner))
	owner.put_in_hand(choice, owner.active_hand_index)
	playsound(owner, 'sound/machines/click.ogg', 50)
	owner.visible_message(span_notice("[owner] fabricates \a [choice]."), span_notice("You fabricate \a [choice]."))
