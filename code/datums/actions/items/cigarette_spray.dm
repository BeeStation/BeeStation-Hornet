/proc/do_exhale_spray(atom/source_item, mob/user, atom/target, amount)
	var/range = min(2, max(1, get_dist(source_item, target)))
	var/obj/effect/decal/chempuff/D = new /obj/effect/decal/chempuff(get_turf(user))
	D.create_reagents(amount)
	var/contained = source_item.reagents.log_list()
	source_item.reagents.trans_to(D, amount)
	D.user = user
	D.block_masked_mobs = TRUE
	D.lifetime = 1
	D.stream = TRUE
	var/wait_step = 2
	var/datum/move_loop/our_loop = SSmove_manager.move_towards_legacy(D, target, wait_step, timeout = range * wait_step, flags = MOVEMENT_LOOP_START_FAST, priority = MOVEMENT_ABOVE_SPACE_PRIORITY)
	D.RegisterSignal(our_loop, COMSIG_QDELETING, TYPE_PROC_REF(/obj/effect/decal/chempuff, loop_ended))
	D.RegisterSignal(our_loop, COMSIG_MOVELOOP_POSTPROCESS, TYPE_PROC_REF(/obj/effect/decal/chempuff, check_move))
	playsound(user, 'sound/effects/blow_smoke.ogg', 50, 1, -6)
	log_combat(user, target, "sprayed", source_item, addition="which had [contained]")

// Cigarettes, Cigars, and Rollies!
/datum/action/item_action/cigarette_spray
	name = "Blow Smoke"
	desc = "Take a sharp drag before blowing out a cloud of smoke. Uses up some of the burn time."
	requires_target = TRUE
	cooldown_time = 2 SECONDS

/datum/action/item_action/cigarette_spray/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/mask/cigarette/cig = master
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
	var/obj/item/clothing/mask/cigarette/cig = master
	if(!istype(cig) || !cig.lit || !cig.reagents?.total_volume)
		return
	var/drag_cost = min(cig.dragtime * REAGENTS_METABOLISM * 3, cig.reagents.total_volume)
	var/spray_amount = drag_cost / 3
	cig.reagents.remove_any(drag_cost - spray_amount)
	cig.smoketime -= cig.dragtime * 3

	user.visible_message(
		span_notice("[user] takes a sharp drag from [cig] and exhales a cloud of smoke!"),
		span_notice("You take a sharp drag from [cig] and exhale a cloud of smoke.")
	)
	do_exhale_spray(cig, user, target, spray_amount)
	if(!cig.reagents.total_volume)
		cig.smoketime = 0
	return TRUE

// Vape Code!

/datum/action/item_action/vape_spray
	name = "Blow Smoke"
	desc = "Take a hit from the vape and blow a cloud of smoke. Uses up some of the vape's liquid contents."
	requires_target = TRUE
	cooldown_time = 2 SECONDS

/datum/action/item_action/vape_spray/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return
	var/obj/item/clothing/mask/vape/vape = master
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
	var/obj/item/clothing/mask/vape/vape = master
	if(!istype(vape) || vape.screw || !vape.reagents?.total_volume)
		return
	var/spray_amount = min(vape.vapedelay * REAGENTS_METABOLISM, vape.reagents.total_volume)
	user.visible_message(
		span_notice("[user] takes a drag from [vape] and exhales a plume of vapor!"),
		span_notice("You take a drag from [vape] and exhale a plume of vapor.")
	)
	do_exhale_spray(vape, user, target, spray_amount)
	return TRUE
