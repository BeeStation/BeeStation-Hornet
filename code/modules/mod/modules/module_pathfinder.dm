///Pathfinder - Can fly the suit from a long distance to an implant installed in someone.
/obj/item/mod/module/pathfinder
	name = "MOD pathfinder module"
	desc = "This module, brought to you by Nakamura Engineering, has two components. \
		The first component is a series of thrusters and a computerized location subroutine installed into the \
		very control unit of the suit, allowing it flight at highway speeds using the suit's access locks \
		to navigate through the station, and to be able to locate the second part of the system; \
		a pathfinding implant installed into the base of the user's spine, \
		broadcasting their location to the suit and allowing them to recall it to their person at any time. \
		The implant is stored in the module and needs to be injected in a human to function. \
		Nakamura Engineering swears up and down there's airbrakes."
	icon_state = "pathfinder"
	complexity = 1
	module_type = MODULE_USABLE
	use_power_cost = DEFAULT_CHARGE_DRAIN * 10
	incompatible_modules = list(/obj/item/mod/module/pathfinder)
	required_slots = list(ITEM_SLOT_BACK|ITEM_SLOT_BELT)
	/// The pathfinding implant.
	var/obj/item/implant/mod/implant
	/// Whether your modsuit will cheat on you instead of returning.
	var/faithful_return = FALSE

/obj/item/mod/module/pathfinder/plus
	name = "MOD pathfinder+ module"
	desc = "This modified pathfinder module, based on Nakamura Engineering's design, \
		has been altered by DonkCo with an anti-personal shock field that guarantees \
		would-be thieves a nasty surprise, and a swift return of the suit to the owner."

	faithful_return = TRUE

/obj/item/mod/module/pathfinder/Initialize(mapload)
	. = ..()
	implant = new(src)

/obj/item/mod/module/pathfinder/Destroy()
	QDEL_NULL(implant)
	return ..()

/obj/item/mod/module/pathfinder/Exited(atom/movable/gone, direction)
	if(gone == implant)
		implant = null
		update_icon_state()
	return ..()

/obj/item/mod/module/pathfinder/update_icon_state()
	. = ..()
	icon_state = implant ? "pathfinder" : "pathfinder_empty"

/obj/item/mod/module/pathfinder/examine(mob/user)
	. = ..()
	if(implant)
		. += span_notice("Use it on a human to implant them.")
	else
		. += span_warning("The implant is missing.")

/obj/item/mod/module/pathfinder/attack(mob/living/target, mob/living/user, params)
	if(!ishuman(target) || !implant)
		return
	if(!do_after(user, 1.5 SECONDS, target = target))
		balloon_alert(user, "interrupted!")
		return
	if(!implant.implant(target, user))
		balloon_alert(user, "can't implant!")
		return
	if(target == user)
		to_chat(user, span_notice("You implant yourself with [implant]."))
	else
		target.visible_message(span_notice("[user] implants [target]."), span_notice("[user] implants you with [implant]."))
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)

/obj/item/mod/module/pathfinder/proc/attach(mob/living/user)
	if(!ishuman(user))
		return
	var/mob/living/carbon/human/human_user = user
	if(human_user.get_item_by_slot(mod.slot_flags) && !human_user.dropItemToGround(human_user.get_item_by_slot(mod.slot_flags)))
		return
	if(!human_user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	mod.quick_deploy(user)
	human_user.update_action_buttons(TRUE)
	balloon_alert(human_user, "[mod] attached")
	playsound(mod, 'sound/machines/ping.ogg', 50, TRUE)
	drain_power(use_power_cost)
	module_type = MODULE_PASSIVE

/obj/item/mod/module/pathfinder/on_use()
	. = ..()
	if (!ishuman(mod.wearer) || !implant)
		return
	if(!implant.implant(mod.wearer, mod.wearer))
		balloon_alert(mod.wearer, "can't implant!")
		return
	balloon_alert(mod.wearer, "implanted")
	playsound(src, 'sound/effects/spray.ogg', 30, TRUE, -6)
	module_type = MODULE_PASSIVE
	var/datum/action/item_action/mod/pinned_module/existing_action = pinned_to[REF(mod.wearer)]
	if(existing_action)
		//mod.remove_item_action(existing_action)
		qdel(existing_action)

/obj/item/implant/mod
	name = "MOD pathfinder implant"
	desc = "Lets you recall a MODsuit to you at any time."
	actions_types = list(/datum/action/item_action/mod_recall)
	/// The pathfinder module we are linked to.
	var/obj/item/mod/module/pathfinder/module
	/// The jet icon we apply to the MOD.
	var/image/jet_icon

/obj/item/implant/mod/Initialize(mapload)
	. = ..()
	if(!istype(loc, /obj/item/mod/module/pathfinder))
		return INITIALIZE_HINT_QDEL
	module = loc
	jet_icon = image(icon = 'icons/obj/clothing/modsuit/mod_modules.dmi', icon_state = "mod_jet", layer = LOW_ITEM_LAYER)

/obj/item/implant/mod/Destroy()
	if(module?.mod?.ai_controller)
		end_recall(successful = FALSE)
	module = null
	jet_icon = null
	return ..()

/obj/item/implant/mod/get_data()
	var/dat = {"<b>Implant Specifications:</b><BR>
				<b>Name:</b> Nakamura Engineering Pathfinder Implant<BR>
				<b>Implant Details:</b> Allows for the recall of a Modular Outerwear Device by the implant owner at any time.<BR>"}
	return dat

/obj/item/implant/mod/proc/recall()
	if(!module?.mod)
		balloon_alert(imp_in, "no connected suit!")
		return FALSE
	if(module.mod.open)
		balloon_alert(imp_in, "suit is open!")
		return FALSE
	if(module.mod.ai_controller)
		balloon_alert(imp_in, "already in transit!")
		return FALSE
	if(ismob(get_atom_on_turf(module.mod)))
		var/mob/living/carbon/carrying_mob = get_atom_on_turf(module.mod)
		if(carrying_mob == imp_in)
			balloon_alert(imp_in, "already on user!")
			return FALSE
		if(!module.faithful_return)
			balloon_alert(imp_in, "already on someone!")
			return FALSE //Someone is in the suit, but our suit doesn't love us
		check_recall_mob() //The suit is stolen, and is faithful to us
		return FALSE
	//balloon_alert(imp_in, "check returned TRUE!")
	if(module.z != z || get_dist(imp_in, module.mod) > MOD_AI_RANGE)
		balloon_alert(imp_in, "too far away!")
		return FALSE
	var/datum/ai_controller/mod_ai = new /datum/ai_controller/mod(module.mod)
	module.mod.ai_controller = mod_ai
	mod_ai.current_movement_target = imp_in
	mod_ai.blackboard[BB_MOD_TARGET] = imp_in
	mod_ai.blackboard[BB_MOD_IMPLANT] = src
	module.mod.interaction_flags_item &= ~INTERACT_ITEM_ATTACK_HAND_PICKUP
	module.mod.AddElement(/datum/element/movetype_handler)
	ADD_TRAIT(module.mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	animate(module.mod, 0.2 SECONDS, pixel_x = base_pixel_y, pixel_y = base_pixel_y)
	module.mod.add_overlay(jet_icon)
	RegisterSignal(module.mod, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	balloon_alert(imp_in, "suit recalled")
	return TRUE

/obj/item/implant/mod/proc/check_recall_mob()
	balloon_alert(imp_in, "deploying countermeasures in 3 seconds.")
	var/mob/living/carbon/carrying_mob = get_atom_on_turf(module.mod)
	balloon_alert(carrying_mob, "deploying countermeasures!")
	playsound(carrying_mob, 'sound/creatures/guarddeath2.ogg', 50, TRUE)
	addtimer(CALLBACK(src, PROC_REF(recall_zap_thief), carrying_mob), 3 SECONDS)
	//return FALSE //We zapped them, but its still not valid until the modsuit is actually dropped

/obj/item/implant/mod/proc/recall_zap_thief(var/mob/living/carrying_mob)
	if(!ismob(get_atom_on_turf(module.mod)))
		return FALSE //They dropped it
	carrying_mob.Paralyze(5 SECONDS)
	carrying_mob?.dropItemToGround(module.mod)
	recall()

/obj/item/implant/mod/proc/end_recall(successful = TRUE)
	if(!module?.mod)
		return
	QDEL_NULL(module.mod.ai_controller)
	module.mod.interaction_flags_item |= INTERACT_ITEM_ATTACK_HAND_PICKUP
	REMOVE_TRAIT(module.mod, TRAIT_MOVE_FLYING, MOD_TRAIT)
	module.mod.RemoveElement(/datum/element/movetype_handler)
	module.mod.cut_overlay(jet_icon)
	module.mod.transform = matrix()
	UnregisterSignal(module.mod, COMSIG_MOVABLE_MOVED)
	if(!successful)
		balloon_alert(imp_in, "suit lost connection!")
	else
		balloon_alert(imp_in, "I missed you!")

/obj/item/implant/mod/proc/on_move(atom/movable/source, atom/old_loc, dir, forced)
	SIGNAL_HANDLER

	var/matrix/mod_matrix = matrix()
	mod_matrix.Turn(get_angle(source, imp_in))
	source.transform = mod_matrix

/datum/action/item_action/mod_recall
	name = "Recall MOD"
	desc = "Recall a MODsuit anyplace, anytime."
	check_flags = AB_CHECK_CONSCIOUS
	background_icon_state = "bg_mod"
	icon_icon = 'icons/hud/actions/actions_mod.dmi'
	button_icon_state = "recall"
	/// The cooldown for the recall.
	COOLDOWN_DECLARE(recall_cooldown)

/datum/action/item_action/mod_recall/New(Target)
	..()
	if(!istype(Target, /obj/item/implant/mod))
		qdel(src)
		return

/datum/action/item_action/mod_recall/on_activate()
	var/obj/item/implant/mod/implant = master
	if(!COOLDOWN_FINISHED(src, recall_cooldown))
		implant.balloon_alert(implant.imp_in, "on cooldown!")
		return
	if(implant.recall())
		COOLDOWN_START(src, recall_cooldown, 15 SECONDS)
