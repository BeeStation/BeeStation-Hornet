/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	worn_icon_state = "pda"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	hardware_flag = PROGRAM_HARDWARE_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	interaction_flags_atom = INTERACT_ATOM_ALLOW_USER_LOCATION

	install_components = list(
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/network_card
	)
	install_cell = /obj/item/stock_parts/cell/computer

	var/has_variants = TRUE
	var/finish_color = null

	var/list/contained_item = list(/obj/item/pen, /obj/item/toy/crayon, /obj/item/lipstick, /obj/item/flashlight/pen, /obj/item/clothing/mask/cigarette)
	var/obj/item/insert_type = /obj/item/pen
	var/obj/item/inserted_item

	/// If this tablet can be detonated with detomatix (needs to be refactored into a signal)
	var/detonatable = TRUE

	/// The note used by the notekeeping app, stored here for convenience.
	var/note = "Congratulations on your station upgrading to the new NtOS and Thinktronic based collaboration effort, bringing you the best in electronics and software since 2467!"
	/// Scanned paper
	var/obj/item/paper/stored_paper

/obj/item/modular_computer/tablet/Destroy()
	QDEL_NULL(stored_paper)
	return ..()

/obj/item/modular_computer/tablet/ui_static_data(mob/user)
	var/list/data = ..()
	data["show_imprint"] = TRUE
	return data

/obj/item/modular_computer/tablet/update_icon()
	..()
	if (has_variants && !bypass_icon_state)
		if(!finish_color)
			finish_color = pick("red","blue","brown","green","black")
		icon_state = "tablet-[finish_color]"
		icon_state_unpowered = "tablet-[finish_color]"
		icon_state_powered = "tablet-[finish_color]"

/obj/item/modular_computer/tablet/proc/try_scan_paper(obj/target, mob/user)
	var/obj/item/paper/paper = target
	if(!istype(paper))
		return FALSE
	if (!paper.default_raw_text)
		to_chat(user, "<span class='warning'>Unable to scan! Paper is blank.</span>")
	else
		// clean up after ourselves
		if(stored_paper)
			qdel(stored_paper)
		stored_paper = paper.copy(location = src)
		to_chat(user, "<span class='notice'>Paper scanned. Saved to PDA's notekeeper.</span>")
		ui_update()
	return TRUE

/obj/item/modular_computer/tablet/attackby(obj/item/attacking_item, mob/user)
	if(..())
		return

	if(is_type_in_list(attacking_item, contained_item))
		if(attacking_item.w_class >= WEIGHT_CLASS_SMALL) // Prevent putting spray cans, pipes, etc (subtypes of pens/crayons)
			return
		if(inserted_item)
			to_chat(user, "<span class='warning'>There is already \a [inserted_item] in \the [src]!</span>")
		else
			if(!user.transferItemToLoc(attacking_item, src))
				return
			to_chat(user, "<span class='notice'>You insert \the [attacking_item] into \the [src].</span>")
			inserted_item = attacking_item
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
			update_icon()
	if(!try_scan_paper(attacking_item, user))
		return

// Insert Job Disk
/obj/item/modular_computer/tablet/pre_attack(atom/target, mob/living/user, params)
	if(try_scan_paper(target, user))
		return FALSE
	return ..()

// Eject the pen if the ID was not ejected
/obj/item/modular_computer/tablet/AltClick(mob/user)
	. = ..()
	if(. & COMPONENT_CANCEL_ATTACK_CHAIN || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	remove_pen(user)
	return TRUE

// Always eject pen with Ctrl+Click
/obj/item/modular_computer/tablet/CtrlClick(mob/user)
	..()
	// We want to allow the user to drag the tablet still
	if(isturf(loc) || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return TRUE
	remove_pen(user)
	return TRUE

// Eject Job Disk
/obj/item/modular_computer/tablet/CtrlShiftClick(mob/user)
	..()
	// We want to allow the user to drag the tablet still
	if(isturf(loc) || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/obj/item/computer_hardware/hard_drive/role/job_disk = mainboard.all_components[MC_HDD_JOB]
	if(istype(job_disk))
		mainboard.uninstall_component(job_disk, user, TRUE)

/obj/item/modular_computer/tablet/verb/verb_toggle_light()
	set name = "Toggle Light"
	set category = "Object"
	set src in oview(1)
	toggle_flashlight()

/obj/item/modular_computer/tablet/verb/verb_remove_pen()
	set name = "Eject Pen"
	set category = "Object"
	set src in usr
	remove_pen(usr)

/obj/item/modular_computer/tablet/proc/remove_pen(mob/user)
	if(issilicon(user) || !user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK)) //TK doesn't work even with this removed but here for readability
		return
	if(inserted_item)
		to_chat(user, "<span class='notice'>You remove [inserted_item] from [src].</span>")
		user.put_in_hands(inserted_item)
		inserted_item = null
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
		update_icon()
	else
		to_chat(user, "<span class='warning'>This tablet does not have a pen in it!</span>")

// Tablet 'splosion..

/obj/item/modular_computer/tablet/proc/explode(mob/target, mob/bomber)
	var/turf/current_turf = get_turf(src)

	log_bomber(bomber, "tablet-bombed", target, "[bomber && !is_special_character(bomber) ? "(SENT BY NON-ANTAG)" : ""]")

	if (ismob(loc))
		var/mob/victim = loc
		victim.show_message("<span class='userdanger'>Your [src] explodes!</span>", MSG_VISUAL, "<span class='warning'>You hear a loud *pop*!</span>", MSG_AUDIBLE)
	else
		visible_message("<span class='danger'>[src] explodes!</span>", "<span class='warning'>You hear a loud *pop*!</span>")

	if(current_turf)
		current_turf.hotspot_expose(700,125)
		if(istype(mainboard.all_components[MC_HDD_JOB], /obj/item/computer_hardware/hard_drive/role/virus/syndicate))
			explosion(current_turf, devastation_range = -1, heavy_impact_range = 1, light_impact_range = 3, flash_range = 4)
		else
			explosion(current_turf, devastation_range = -1, heavy_impact_range = -1, light_impact_range = 2, flash_range = 3)
	qdel(src)

// SUBTYPES

/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	has_variants = FALSE
	syndicate_themed = TRUE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	icon_state_powered = "tablet-syndicate"
	icon_state_unpowered = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	light_color = COLOR_RED
	syndicate_themed = TRUE

/obj/item/modular_computer/tablet/nukeops/should_emag(mob/user)
	if(..())
		to_chat(user, "<span class='notice'>You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\".</span>")
	return FALSE
