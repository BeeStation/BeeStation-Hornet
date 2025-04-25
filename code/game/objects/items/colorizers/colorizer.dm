
/obj/item/colorizer
	name = "ERROR Colorizer"
	desc = "This colorizer will apply a new set of colors to an item."
	icon = 'icons/obj/crayons.dmi'
	icon_state = "rainbowcan"
	var/uses_left = 1

	var/list/allowed_targets = list()
	var/list/forbidden_targets = list()
	var/apply_icon = null
	var/apply_icon_state = null
	var/apply_item_state = null
	var/apply_righthand_file = null
	var/apply_lefthand_file = null

/obj/item/colorizer/attack_self(mob/user)
	var/obj/item/target_atom = user.get_inactive_held_item()
	do_colorize(target_atom, user)
	. = ..()

/obj/item/colorizer/proc/can_use(atom/target, mob/user)
	if(!user || !ismob(user) || user.incapacitated() || !user.Adjacent(target))
		return FALSE
	return TRUE

/obj/item/colorizer/pre_attack(atom/target, mob/living/user, params)
	if(can_use(target, user))
		do_colorize(target, user)
	. = ..()

/obj/item/colorizer/proc/do_colorize(atom/to_be_colored, mob/user)
	if(!to_be_colored)
		return
	if(!is_type_in_list(to_be_colored, allowed_targets) || is_type_in_list(to_be_colored, forbidden_targets))
		to_chat(user, span_warning("This colorizer is not compatible with that!"))
		return

	if(apply_icon)
		to_be_colored.icon = apply_icon
	if(apply_icon_state)
		to_be_colored.icon_state = apply_icon_state

	var/obj/item/target_item = to_be_colored
	if(istype(target_item))
		if(apply_item_state)
			target_item.item_state = apply_item_state
		if(apply_righthand_file)
			target_item.righthand_file = apply_righthand_file
		if(apply_lefthand_file)
			target_item.righthand_file = apply_lefthand_file

	to_chat(user, span_notice("Color applied!"))
	playsound(src, 'sound/effects/spray.ogg', 5, TRUE, 5)
	uses_left --
	if(!uses_left)
		qdel(src)
