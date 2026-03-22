/obj/vehicle/sealed/mecha/mob_try_enter(mob/M)
	if(!ishuman(M)) // no silicons or drones in mechas.
		return
	if(HAS_TRAIT(M, TRAIT_PRIMITIVE)) //no lavalizards either.
		to_chat(M, span_warning("The knowledge to use this device eludes you!"))
		return
	log_message("[M] tried to move into [src].", LOG_MECHA)
	if((mecha_flags & ID_LOCK_ON) && !allowed(M))
		to_chat(M, span_warning("Access denied. Insufficient operation keycodes."))
		log_message("Permission denied (No keycode).", LOG_MECHA)
		return
	. = ..()
	if(.)
		moved_inside(M)

/obj/vehicle/sealed/mecha/enter_checks(mob/M)
	if(M.incapacitated)
		return FALSE
	if(atom_integrity <= 0)
		to_chat(M, span_warning("You cannot get in the [src], it has been destroyed!"))
		return FALSE
	if(M.buckled)
		to_chat(M, span_warning("You can't enter the exosuit while buckled."))
		log_message("Permission denied (Buckled).", LOG_MECHA)
		return FALSE
	if(M.has_buckled_mobs())
		to_chat(M, span_warning("You can't enter the exosuit with other creatures attached to you!"))
		log_message("Permission denied (Attached mobs).", LOG_MECHA)
		return FALSE
	return ..()

/obj/vehicle/sealed/mecha/proc/moved_inside(mob/living/newoccupant)
	if(!(newoccupant?.client))
		return FALSE
	if(ishuman(newoccupant) && !Adjacent(newoccupant))
		return FALSE
	add_occupant(newoccupant)
	mecha_flags &= ~PANEL_OPEN //Close panel if open
	newoccupant.forceMove(src)
	newoccupant.update_mouse_pointer()
	add_fingerprint(newoccupant)
	log_message("[newoccupant] moved in as pilot.", LOG_MECHA)
	setDir(SOUTH)
	playsound(src, 'sound/machines/windowdoor.ogg', 50, TRUE)
	set_mouse_pointer()
	if(!internal_damage)
		SEND_SOUND(newoccupant, sound('sound/mecha/nominal.ogg',volume=50))
	return TRUE

/obj/vehicle/sealed/mecha/proc/mmi_move_inside(obj/item/mmi/brain_obj, mob/user)
	if(!brain_obj.brain_check(user))
		return FALSE
	if(LAZYLEN(occupants) >= max_occupants)
		to_chat(user, span_warning("It's full!"))
		return FALSE

	visible_message(span_notice("[user] starts to insert an MMI into [name]."))

	if(!do_after(user, 4 SECONDS, target = src))
		to_chat(user, span_notice("You stop inserting the MMI."))
		return FALSE
	if(LAZYLEN(occupants) < max_occupants)
		return mmi_moved_inside(brain_obj, user)
	to_chat(user, span_warning("Maximum occupants exceeded!"))
	return FALSE

/obj/vehicle/sealed/mecha/proc/mmi_moved_inside(obj/item/mmi/brain_obj, mob/user)
	if(!(Adjacent(brain_obj) && Adjacent(user)))
		return FALSE
	if(!brain_obj.brain_check(user))
		return FALSE

	var/mob/living/brain/brain_mob = brain_obj.brainmob
	if(!user.transferItemToLoc(brain_obj, src))
		to_chat(user, span_warning("\the [brain_obj] is stuck to your hand, you cannot put it in \the [src]!"))
		return FALSE

	brain_obj.set_mecha(src)
	add_occupant(brain_mob)//Note this forcemoves the brain into the mech to allow relaymove
	mecha_flags &= ~PANEL_OPEN //Close panel if open
	mecha_flags |= SILICON_PILOT
	brain_mob.reset_perspective(src)
	brain_mob.remote_control = src
	brain_mob.update_mouse_pointer()
	setDir(SOUTH)
	log_message("[brain_obj] moved in as pilot.", LOG_MECHA)
	if(!internal_damage)
		SEND_SOUND(brain_obj, sound('sound/mecha/nominal.ogg',volume=50))
	log_game("[key_name(user)] has put the MMI/posibrain of [key_name(brain_mob)] into [src] at [AREACOORD(src)]")
	return TRUE

/obj/vehicle/sealed/mecha/mob_exit(mob/M, silent = FALSE, randomstep = FALSE, forced = FALSE)
	var/atom/movable/mob_container
	var/turf/newloc = get_turf(src)
	if(ishuman(M))
		mob_container = M
	else if(isbrain(M))
		var/mob/living/brain/brain = M
		mob_container = brain.container
	else if(isAI(M))
		var/mob/living/silicon/ai/AI = M
		if(forced)//This should only happen if there are multiple AIs in a round, and at least one is Malf.
			if(!AI.linked_core) //if the victim AI has no core
				AI.gib()  //If one Malf decides to steal a mech from another AI (even other Malfs!), they are destroyed, as they have nowhere to go when replaced.
			AI = null
			mecha_flags &= ~SILICON_PILOT
			return
		else
			if(!AI.linked_core)
				if(!silent)
					to_chat(AI, span_userdanger("Inactive core destroyed. Unable to return."))
				AI.linked_core = null
				return
			if(!silent)
				to_chat(AI, span_notice("Returning to core..."))
			AI.controlled_equipment = null
			AI.remote_control = null
			mob_container = AI
			newloc = get_turf(AI.linked_core)
			qdel(AI.linked_core)
	else
		return ..()
	var/mob/living/ejector = M
	mecha_flags  &= ~SILICON_PILOT
	mob_container.forceMove(newloc)//ejecting mob container
	log_message("[mob_container] moved out.", LOG_MECHA)
	SStgui.close_user_uis(M, src)
	if(istype(mob_container, /obj/item/mmi))
		var/obj/item/mmi/mmi = mob_container
		if(mmi.brainmob)
			ejector.forceMove(mmi)
			ejector.reset_perspective()
			remove_occupant(ejector)
		mmi.set_mecha(null)
		mmi.update_appearance()
	setDir(SOUTH)
	return ..()

/obj/vehicle/sealed/mecha/add_occupant(mob/M, control_flags)
	RegisterSignal(M, COMSIG_MOB_CLICKON, PROC_REF(on_mouseclick), TRUE)
	RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(display_speech_bubble), TRUE)
	RegisterSignal(M, COMSIG_MOVABLE_KEYBIND_FACE_DIR, PROC_REF(on_turn), TRUE)
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/remove_occupant(mob/M)
	UnregisterSignal(M, list(
		COMSIG_MOB_CLICKON,
		COMSIG_MOB_SAY,
		COMSIG_MOVABLE_KEYBIND_FACE_DIR,
	))
	M.clear_alert("charge")
	M.clear_alert("mech damage")
	if(M.client)
		M.update_mouse_pointer()
		M.client.view_size.resetToDefault()
		zoom_mode = FALSE
	. = ..()
	update_appearance()

/obj/vehicle/sealed/mecha/container_resist(mob/living/user)
	if(isAI(user))
		var/mob/living/silicon/ai/AI = user
		if(!AI.can_shunt)
			to_chat(AI, span_notice("You can't leave a mech after dominating it!."))
			return FALSE
	to_chat(user, span_notice("You begin the ejection procedure. Equipment is disabled during this process. Hold still to finish ejecting."))
	is_currently_ejecting = TRUE
	if(do_after(user, has_gravity() ? exit_delay : 0 , target = src))
		to_chat(user, span_notice("You exit the mech."))
		if(cabin_sealed)
			set_cabin_seal(user, FALSE)
		mob_exit(user, silent = TRUE)
	else
		to_chat(user, span_notice("You stop exiting the mech. Weapons are enabled again."))
	is_currently_ejecting = FALSE
