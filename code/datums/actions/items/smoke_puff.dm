/datum/action/item_action/smoke_exhale

/datum/action/item_action/smoke_exhale/proc/do_exhale_spray(atom/source_item, mob/user, atom/target, amount)
	var/range = clamp(get_dist(source_item, target), 1, 2)
	var/obj/effect/decal/chempuff/smokepuff = new /obj/effect/decal/chempuff(get_turf(user))
	smokepuff.create_reagents(amount)
	var/contained = source_item.reagents.log_list()
	source_item.reagents.trans_to(smokepuff, amount)
	smokepuff.user = user
	smokepuff.block_masked_mob = TRUE
	smokepuff.lifetime = 1
	smokepuff.stream = TRUE
	var/wait_step = 2
	var/datum/move_loop/our_loop = SSmove_manager.move_towards_legacy(smokepuff, target, wait_step, timeout = range * wait_step, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	smokepuff.RegisterSignal(our_loop, COMSIG_QDELETING, TYPE_PROC_REF(/obj/effect/decal/chempuff, loop_ended))
	smokepuff.RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, TYPE_PROC_REF(/obj/effect/decal/chempuff, check_move))
	playsound(user, 'sound/effects/blow_smoke.ogg', 50, TRUE, -6)
	log_combat(user, target, "sprayed", source_item, addition="which had [contained]")

// Cigarettes, Cigars, and Rollies!

/datum/action/item_action/cigarette_spray
	parent_type = /datum/action/item_action/smoke_exhale
	name = "Blow Smoke"
	desc = "Take a sharp drag before blowing out a cloud of smoke. Uses up some of the burn time."
	requires_target = TRUE
	cooldown_time = 2 SECONDS
	/// Stored exhale budget values initialized on first exhale.
	var/exhale_stored_target_uses
	var/exhale_stored_drag_cost
	var/exhale_stored_spray_amount
	var/exhale_stored_smoketime_cost

/datum/action/item_action/cigarette_spray/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/obj/item/cigarette/cig = master
	if(!istype(cig))
		return FALSE
	if(owner.get_item_by_slot(ITEM_SLOT_MASK) != cig)
		if(feedback)
			owner.balloon_alert(owner, "not in mouth!")
		return FALSE
	if(!cig.lit)
		if(feedback)
			owner.balloon_alert(owner, "not lit!")
		return FALSE
	if(!cig.reagents?.total_volume)
		if(feedback)
			owner.balloon_alert(owner, "no reagents!")
		return FALSE
	return TRUE

/datum/action/item_action/cigarette_spray/on_activate(mob/user, atom/target)
	var/obj/item/cigarette/cig = master
	if(!istype(cig) || !cig.lit || !cig.reagents?.total_volume)
		return
	var/max_spray_amount = 3
	var/remaining_volume = cig.reagents.total_volume
	if(!exhale_stored_target_uses)
		exhale_stored_target_uses = clamp(round(remaining_volume / 4), 2, 6)
		exhale_stored_drag_cost = remaining_volume / exhale_stored_target_uses
		exhale_stored_spray_amount = min(exhale_stored_drag_cost / 3, max_spray_amount)
		exhale_stored_smoketime_cost = max(cig.smoketime / exhale_stored_target_uses, 1)
	var/drag_cost = exhale_stored_drag_cost
	var/spray_amount = exhale_stored_spray_amount
	var/final_exhale = FALSE
	if(remaining_volume <= drag_cost)
		drag_cost = remaining_volume
		spray_amount = min(drag_cost / 3, max_spray_amount)
		final_exhale = TRUE
	cig.reagents.remove_any(drag_cost - spray_amount)
	cig.smoketime -= exhale_stored_smoketime_cost * (drag_cost / max(exhale_stored_drag_cost, 0.01))

	user.visible_message(
		span_notice("[user] takes a sharp drag from [cig] and exhales a cloud of smoke!"),
		span_notice("You take a sharp drag from [cig] and exhale a cloud of smoke.")
	)
	do_exhale_spray(cig, user, target, spray_amount)
	if(!QDELETED(cig) && (final_exhale || cig.reagents.total_volume <= 0.01))
		cig.smoketime = 0
		cig.put_out(user)
	return TRUE

// Vape Code!

/datum/action/item_action/vape_spray
	parent_type = /datum/action/item_action/smoke_exhale
	name = "Blow Smoke"
	desc = "Take a hit from the vape and blow a cloud of smoke. Uses up some of the vape's liquid contents."
	requires_target = TRUE
	cooldown_time = 2 SECONDS

/datum/action/item_action/vape_spray/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/obj/item/vape/vape = master
	if(!istype(vape))
		return FALSE
	if(owner.get_item_by_slot(ITEM_SLOT_MASK) != vape)
		if(feedback)
			owner.balloon_alert(owner, "not in mouth!")
		return FALSE
	if(vape.screw)
		if(feedback)
			owner.balloon_alert(owner, "cap is open!")
		return FALSE
	if(!vape.reagents?.total_volume)
		if(feedback)
			owner.balloon_alert(owner, "no reagents!")
		return FALSE
	return TRUE

/datum/action/item_action/vape_spray/on_activate(mob/user, atom/target)
	var/obj/item/vape/vape = master
	if(!istype(vape) || vape.screw || !vape.reagents?.total_volume)
		return
	var/spray_amount = min((vape.dragtime / (1 SECONDS)) * REAGENTS_METABOLISM, vape.reagents.total_volume)
	user.visible_message(
		span_notice("[user] takes a drag from [vape] and exhales a plume of vapor!"),
		span_notice("You take a drag from [vape] and exhale a plume of vapor.")
	)
	do_exhale_spray(vape, user, target, spray_amount)
	return TRUE
