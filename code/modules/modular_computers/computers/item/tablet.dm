/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_unpowered = "tablet"
	icon_state_powered = "tablet"
	icon_state_menu = "menu"
	hardware_flag = PROGRAM_TABLET
	max_hardware_size = 1
	w_class = WEIGHT_CLASS_SMALL
	max_bays = 3
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 2.3 //Same as the PDA
	interaction_flags_atom = INTERACT_ATOM_ALLOW_USER_LOCATION
	can_save_id = TRUE
	saved_auto_imprint = TRUE

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
	if (has_variants && !bypass_state)
		if(!finish_color)
			finish_color = pick("red","blue","brown","green","black")
		icon_state = "tablet-[finish_color]"
		icon_state_unpowered = "tablet-[finish_color]"
		icon_state_powered = "tablet-[finish_color]"

/obj/item/modular_computer/tablet/proc/try_scan_paper(obj/target, mob/user)
	if(!istype(target, /obj/item/paper))
		return FALSE
	var/obj/item/paper/paper = target
	if (!paper.info)
		to_chat(user, "<span class='warning'>Unable to scan! Paper is blank.</span>")
	else
		// clean up after ourselves
		if(stored_paper)
			qdel(stored_paper)
		stored_paper = paper.copy(src)
		to_chat(user, "<span class='notice'>Paper scanned. Saved to PDA's notekeeper.</span>")
		ui_update()
	return TRUE

/obj/item/modular_computer/tablet/attackby(obj/item/attacking_item, mob/user)
	. = ..()

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

/obj/item/modular_computer/tablet/pre_attack(atom/target, mob/living/user, params)
	if(try_scan_paper(target, user))
		return FALSE
	var/obj/item/computer_hardware/hard_drive/role/job_disk = all_components[MC_HDD_JOB]
	if(istype(job_disk) && !job_disk.process_pre_attack(target, user, params))
		return FALSE
	return ..()

/obj/item/modular_computer/tablet/attack(atom/target, mob/living/user, params)
	// Send to programs for processing - this should go LAST
	// Used to implement the physical scanner.
	for(var/datum/computer_file/program/thread in (idle_threads + active_program))
		if(thread.use_attack && !thread.attack(target, user, params))
			return
	..()

/obj/item/modular_computer/tablet/attack_obj(obj/target, mob/living/user)
	// Send to programs for processing - this should go LAST
	// Used to implement the gas scanner.
	for(var/datum/computer_file/program/thread in (idle_threads + active_program))
		if(thread.use_attack_obj && !thread.attack_obj(target, user))
			return
	..()

// Eject the pen if the ID was not ejected
/obj/item/modular_computer/tablet/AltClick(mob/user)
	if(..() || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	remove_pen(user)

// Always eject pen with Ctrl+Click
/obj/item/modular_computer/tablet/CtrlClick(mob/user)
	..()
	// We want to allow the user to drag the tablet still
	if(isturf(loc) || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	remove_pen(user)

// Eject Job Disk
/obj/item/modular_computer/tablet/CtrlShiftClick(mob/user)
	..()
	// We want to allow the user to drag the tablet still
	if(isturf(loc) || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	var/obj/item/computer_hardware/hard_drive/role/disk = all_components[MC_HDD_JOB]
	if(istype(disk))
		uninstall_component(disk, user, TRUE)

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
		if(istype(all_components[MC_HDD_JOB], /obj/item/computer_hardware/hard_drive/role/virus/syndicate))
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
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	icon_state_powered = "tablet-syndicate"
	icon_state_unpowered = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/should_emag(mob/user)
	if(..())
		to_chat(user, "<span class='notice'>You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\".</span>")
	return FALSE

/// Borg Built-in tablet interface
/obj/item/modular_computer/tablet/integrated
	name = "modular interface"
	icon_state = "tablet-silicon"
	icon_state_unpowered = "tablet-silicon"
	icon_state_powered = "tablet-silicon"
	icon_state_menu = "menu"
	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
	has_variants = FALSE
	///Ref to the silicon we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/borgo
	///Ref to the Cyborg Self-Monitoring app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/borg_self_monitor/self_monitoring
	///IC log that borgs can view in their personal management app
	var/list/borglog = list()

/obj/item/modular_computer/tablet/integrated/Initialize(mapload)
	. = ..()
	vis_flags |= VIS_INHERIT_ID
	borgo = loc
	if(!istype(borgo))
		borgo = null
		stack_trace("[type] initialized outside of a borg, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/tablet/integrated/Destroy()
	borgo = null
	return ..()

/obj/item/modular_computer/tablet/integrated/turn_on(mob/user, open_ui = FALSE)
	if(borgo?.stat != DEAD)
		return ..()
	return FALSE

/**
  * Returns a ref to the Cyborg Self-Monitoring app, creating the app if need be.
  *
  * The Cyborg Self-Monitoring app is important for borgs, and so should always be available.
  * This proc will look for it in the tablet's self_monitoring var, then check the
  * hard drive if the self_monitoring var is unset, and finally attempt to create a new
  * copy if the hard drive does not contain the app. If the hard drive rejects
  * the new copy (such as due to lack of space), the proc will crash with an error.
  * Cyborg Self-Monitoring is supposed to be undeletable, so these will create runtime messages.
  */
/obj/item/modular_computer/tablet/integrated/proc/get_self_monitoring()
	if(!borgo)
		return null
	if(!self_monitoring)
		var/obj/item/computer_hardware/hard_drive/hard_drive = all_components[MC_HDD]
		self_monitoring = hard_drive.find_file_by_name("borg_self_monitor")
		if(!self_monitoring)
			stack_trace("Cyborg [borgo] ( [borgo.type] ) was somehow missing their self-management app in their tablet. A new copy has been created.")
			self_monitoring = new(hard_drive)
			if(!hard_drive.store_file(self_monitoring))
				qdel(self_monitoring)
				self_monitoring = null
				CRASH("Cyborg [borgo]'s tablet hard drive rejected recieving a new copy of the self-management app. To fix, check the hard drive's space remaining. Please make a bug report about this.")
	return self_monitoring

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/ui_data(mob/user)
	. = ..()
	if(iscyborg(borgo))
		var/mob/living/silicon/robot/robo = borgo
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color
		.["has_light"] = TRUE

//Makes the flashlight button affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/toggle_flashlight()
	if(!borgo || QDELETED(borgo) || !iscyborg(borgo))
		return FALSE
	var/mob/living/silicon/robot/robo = borgo
	robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/set_flashlight_color(color)
	if(!borgo || QDELETED(borgo) || !color || !iscyborg(borgo))
		return FALSE
	var/mob/living/silicon/robot/robo = borgo
	robo.lamp_color = color
	robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/tablet/integrated/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		sound = pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg')
	borgo.playsound_local(src, sound, 50, TRUE)
	to_chat(borgo, "<span class='notice'>The [src] displays a [caller.filedesc] notification: [alerttext]</span>")

/obj/item/modular_computer/tablet/integrated/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	icon_state_menu = "command-syndicate"
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize()
	. = ..()
	if(iscyborg(borgo))
		var/mob/living/silicon/robot/robo = borgo
		robo.lamp_color = COLOR_RED //Syndicate likes it red

// Round start tablets

/obj/item/modular_computer/tablet/pda
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'

	bypass_state = TRUE
	can_store_pai = TRUE

	var/default_disk = 0
	/// If the PDA has been picked up / equipped before. This is used to set the user's preference background color / theme.
	var/equipped = FALSE

/obj/item/modular_computer/tablet/pda/send_sound()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 15, TRUE)
	else
		..()

/obj/item/modular_computer/tablet/pda/send_select_sound()
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		playsound(src, pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg'), 15, TRUE)
	else
		..()

/obj/item/modular_computer/tablet/pda/equipped(mob/user, slot)
	. = ..()
	if(equipped || !user.client)
		return
	equipped = TRUE
	if(!user.client.prefs)
		return
	var/pref_theme = user.client.prefs.pda_theme
	if(!theme_locked && !ignore_theme_pref)
		for(var/key in allowed_themes) // i am going to scream. DM lists stop sucking please
			if(allowed_themes[key] == pref_theme)
				device_theme = pref_theme
				break
	classic_color = user.client.prefs.pda_color

/obj/item/modular_computer/tablet/pda/update_icon()
	..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	var/obj/item/computer_hardware/card_slot/card = all_components[MC_CARD]
	if(card)
		if(card.stored_card)
			add_overlay(mutable_appearance(init_icon, "id_overlay"))
	if(inserted_item)
		add_overlay(mutable_appearance(init_icon, "insert_overlay"))
	if(light_on)
		add_overlay(mutable_appearance(init_icon, "light_overlay"))


/obj/item/modular_computer/tablet/pda/attack_ai(mob/user)
	to_chat(user, "<span class='notice'>It doesn't feel right to snoop around like that...</span>")
	return // we don't want ais or cyborgs using a private role tablet

/obj/item/modular_computer/tablet/pda/Initialize(mapload)
	. = ..()
	install_component(new /obj/item/computer_hardware/hard_drive/small/pda)
	install_component(new /obj/item/computer_hardware/processor_unit/small)
	install_component(new /obj/item/computer_hardware/battery(src, /obj/item/stock_parts/cell/computer))
	install_component(new /obj/item/computer_hardware/network_card)
	install_component(new /obj/item/computer_hardware/card_slot)
	install_component(new /obj/item/computer_hardware/identifier)
	install_component(new /obj/item/computer_hardware/sensorpackage)

	if(default_disk)
		var/obj/item/computer_hardware/hard_drive/portable/disk = new default_disk(src)
		install_component(disk)

	if(insert_type)
		inserted_item = new insert_type(src)
		// show the inserted item
		update_icon()
