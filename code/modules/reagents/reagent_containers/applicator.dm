/// Generic reagent applicator type for pills and patches
/obj/item/reagent_containers/applicator
	abstract_type = /obj/item/reagent_containers/applicator
	name = "generic reagent applicator"
	desc = "Report this please."
	has_variable_transfer_amount = FALSE
	/// Action string displayed in vis_message
	var/apply_method = "swallow"
	/// Does the item get its name changed as volume when its produced
	var/rename_with_volume = FALSE
	/// How long does it take to apply this item to someone else?
	var/application_delay = 3 SECONDS
	/// How long does it take to apply this item to self?
	var/self_delay = 0

/obj/item/reagent_containers/applicator/Initialize(mapload)
	. = ..()
	if(reagents.total_volume && rename_with_volume)
		name += " ([reagents.total_volume]u)"

/obj/item/reagent_containers/applicator/interact_with_atom(atom/interacting_with, mob/living/user, list/modifiers)
	if (!ismob(interacting_with))
		return NONE
	return attempt_application(interacting_with, user)

/obj/item/reagent_containers/applicator/proc/attempt_application(mob/target_mob, mob/living/user, obj/item/bodypart/affected_limb)
	if(!canconsume(target_mob, user))
		return ITEM_INTERACT_BLOCKING

	user.changeNext_move(CLICK_CD_MELEE)
	if(target_mob == user)
		target_mob.visible_message(span_notice("[user] attempts to [apply_method] [src]."))
		if(self_delay && !do_after(user, self_delay, target_mob))
			return ITEM_INTERACT_BLOCKING
		to_chat(target_mob, span_notice("You [apply_method] [src]."))
		on_consumption(user, user, affected_limb)
		return ITEM_INTERACT_SUCCESS

	target_mob.visible_message(
		span_danger("[user] attempts to force [target_mob] to [apply_method] [src]."),
		span_userdanger("[user] attempts to force you to [apply_method] [src]."),
	)
	if(!do_after(user, CHEM_INTERACT_DELAY(application_delay, user), target_mob))
		return ITEM_INTERACT_BLOCKING

	target_mob.visible_message(span_danger("[user] forces [target_mob] to [apply_method] [src]."), span_userdanger("[user] forces you to [apply_method] [src]."))
	on_consumption(target_mob, user, affected_limb)
	return ITEM_INTERACT_SUCCESS

/// Consumption effects, must be overriden by children
/obj/item/reagent_containers/applicator/proc/on_consumption(mob/consumer, mob/giver, obj/item/bodypart/affected_limb)
	return
