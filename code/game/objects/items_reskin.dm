/// Called when alt clicked and the item has unique reskin options
/obj/item/proc/on_click_alt_reskin(datum/source, mob/user)
	SIGNAL_HANDLER

	if(current_skin)
		return NONE

	if(!user.can_perform_action(src))
		return NONE

	INVOKE_ASYNC(src, PROC_REF(reskin_obj), user)
	return CLICK_ACTION_SUCCESS

/**
 * Reskins object based on a user's choice
 *
 * Arguments:
 * * user The mob choosing a reskin option
 */
/obj/item/proc/reskin_obj(mob/user)
	var/choice = show_radial_menu(user, src, unique_reskin, radius = 42, require_near = TRUE, tooltips = TRUE)
	if(QDELETED(src) || !choice || current_skin || user.incapacitated || !in_range(user, src))
		return
	if(!unique_reskin[choice])
		return
	current_skin = choice
	icon_state = unique_reskin_icon[choice]
	to_chat(user, "[src] is now skinned as '[choice].'")
	update_icon()
