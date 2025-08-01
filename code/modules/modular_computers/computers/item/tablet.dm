/obj/item/modular_computer/tablet  //Its called tablet for theme of 90ies but actually its a "big smartphone" sized
	name = "tablet computer"
	icon = 'icons/obj/modular_tablet.dmi'
	icon_state = "tablet-red"
	icon_state_menu = "menu"
	worn_icon_state = "pda"
	max_hardware_size = WEIGHT_CLASS_SMALL
	w_class = WEIGHT_CLASS_SMALL
	custom_price = PAYCHECK_MEDIUM * 2
	max_bays = 3
	steel_sheet_cost = 1
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	has_light = TRUE //LED flashlight!
	comp_light_luminosity = 3 //not the same as the PDA
	interaction_flags_atom = INTERACT_ATOM_ALLOW_USER_LOCATION
	can_save_id = TRUE
	saved_auto_imprint = TRUE
	var/list/contained_item = list(/obj/item/pen, /obj/item/toy/crayon, /obj/item/lipstick, /obj/item/flashlight/pen, /obj/item/clothing/mask/cigarette)
	//This is the typepath to load "into" the pda
	var/obj/item/insert_type = /obj/item/pen
	//This is the currently inserted item
	var/obj/item/inserted_item
	can_store_pai = TRUE

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

/obj/item/modular_computer/tablet/update_overlays()
	. = ..()
	var/init_icon = initial(icon)
	if(!init_icon)
		return
	var/obj/item/computer_hardware/card_slot/card = all_components[MC_CARD]
	if(card)
		if(card.stored_card)
			. += mutable_appearance(init_icon, "id_overlay")
	if(inserted_item)
		. += mutable_appearance(init_icon, "insert_overlay")
	if(light_on)
		. += mutable_appearance(init_icon, "light_overlay")


/obj/item/modular_computer/tablet/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	var/obj/item/card/id/inserted_id = GetID() // chain EMP to cards
	if(inserted_id)
		inserted_id.emp_act(severity)

/obj/item/modular_computer/tablet/proc/try_scan_paper(obj/target, mob/user)
	if(!istype(target, /obj/item/paper))
		return FALSE
	var/obj/item/paper/paper = target
	if (!LAZYLEN(paper.raw_text_inputs))
		to_chat(user, span_warning("Unable to scan! Paper is blank."))
	else
		// clean up after ourselves
		if(stored_paper)
			qdel(stored_paper)
		stored_paper = paper.copy(/obj/item/paper, src)
		to_chat(user, span_notice("Paper scanned. Saved to PDA's notekeeper."))
		ui_update()
	return TRUE

/obj/item/modular_computer/tablet/attackby(obj/item/attacking_item, mob/user)
	. = ..()

	if(is_type_in_list(attacking_item, contained_item))
		if(attacking_item.w_class >= WEIGHT_CLASS_SMALL) // Prevent putting spray cans, pipes, etc (subtypes of pens/crayons)
			return
		if(inserted_item)
			to_chat(user, span_warning("There is already \a [inserted_item] in \the [src]!"))
		else
			if(!user.transferItemToLoc(attacking_item, src))
				return
			to_chat(user, span_notice("You insert \the [attacking_item] into \the [src]."))
			inserted_item = attacking_item
			playsound(src, 'sound/machines/pda_button1.ogg', 50, TRUE)
			update_appearance()

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

/obj/item/modular_computer/tablet/attack_atom(obj/target, mob/living/user)
	// Send to programs for processing - this should go LAST
	// Used to implement the gas scanner.
	for(var/datum/computer_file/program/thread in (idle_threads + active_program))
		if(thread.use_attack_obj && !thread.attack_atom(target, user))
			return
	..()

// Eject the PAI then pen if the ID was not ejected
/obj/item/modular_computer/tablet/AltClick(mob/user)
	if(..() || issilicon(user) || !user.canUseTopic(src, BE_CLOSE))
		return
	if(!inserted_item && stored_pai_card)
		usr.put_in_hands(stored_pai_card)
		remove_pai()
	else
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
		to_chat(user, span_notice("You remove [inserted_item] from [src]."))
		user.put_in_hands(inserted_item)
		inserted_item = null
		playsound(src, 'sound/machines/pda_button2.ogg', 50, TRUE)
		update_appearance()
	else
		to_chat(user, span_warning("This tablet does not have a pen in it!"))

// SUBTYPES
/obj/item/modular_computer/tablet/syndicate_contract_uplink
	name = "contractor tablet"
	icon = 'icons/obj/contractor_tablet.dmi'
	icon_state = "tablet"
	icon_state_menu = "assign"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_ID | ITEM_SLOT_BELT
	comp_light_luminosity = 6.3
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	comp_light_luminosity = 6.3
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/should_emag(mob/user)
	if(..())
		to_chat(user, span_notice("You swipe \the [src]. It's screen briefly shows a message reading \"MEMORY CODE INJECTION DETECTED AND SUCCESSFULLY QUARANTINED\"."))
	return FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/modular_computer/tablet/integrated)

/// Borg Built-in tablet interface
/obj/item/modular_computer/tablet/integrated
	name = "modular interface"
	icon_state = "tablet-silicon"
	icon_state_menu = "menu"
	has_light = FALSE //tablet light button actually enables/disables the borg lamp
	comp_light_luminosity = 0
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
	for(var/port in all_components)
		var/obj/item/computer_hardware/component = all_components[port]	//This hopefully stops borgs from just shitting out their parts when they die
		qdel(component)
		forget_component(component)
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
				CRASH("Cyborg [borgo]'s tablet hard drive rejected receiving a new copy of the self-management app. To fix, check the hard drive's space remaining. Please make a bug report about this.")
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

/obj/item/modular_computer/tablet/integrated/alert_call(datum/computer_file/program/alerting_program, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!alerting_program || !alerting_program.alert_able || alerting_program.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	if(HAS_TRAIT(SSstation, STATION_TRAIT_PDA_GLITCHED))
		sound = pick('sound/machines/twobeep_voice1.ogg', 'sound/machines/twobeep_voice2.ogg')
	borgo.playsound_local(src, sound, 50, TRUE)
	to_chat(borgo, span_notice("The [src] displays a [alerting_program.filedesc] notification: [alerttext]"))

/obj/item/modular_computer/tablet/integrated/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_menu = "command-syndicate"
	device_theme = THEME_SYNDICATE
	theme_locked = TRUE


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize(mapload)
	. = ..()
	if(iscyborg(borgo))
		var/mob/living/silicon/robot/robo = borgo
		robo.lamp_color = COLOR_RED //Syndicate likes it red

GLOBAL_LIST_EMPTY(PDAs)

// Round start tablets

/obj/item/modular_computer/tablet/pda
	icon = 'icons/obj/pda.dmi'
	icon_state = "pda"
	worn_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	comp_light_luminosity = 2.3
	max_hardware_size = WEIGHT_CLASS_TINY

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
	var/pref_theme = user.client.prefs.read_character_preference(/datum/preference/choiced/pda_theme)
	if(!theme_locked && !ignore_theme_pref && (pref_theme in allowed_themes))
		device_theme = allowed_themes[pref_theme]
	classic_color = user.client.prefs.read_character_preference(/datum/preference/color/pda_classic_color)

/obj/item/modular_computer/tablet/pda/attack_silicon(mob/user)
	to_chat(user, span_notice("It doesn't feel right to snoop around like that..."))
	return // we don't want ais or cyborgs using a private role tablet

/// Return a list of types you want to pregenerate and use later
/// Do not pass in things that care about their init location, or expect extra input
/// Also as a courtesy to me, don't pass in any bombs
/obj/item/modular_computer/tablet/pda/proc/get_types_to_preload()
	var/list/preload = list()
	//preload += default_cartridge
	preload += insert_type
	return preload

/// Callbacks for preloading pdas
/obj/item/modular_computer/tablet/pda/proc/display_pda()
	GLOB.PDAs += src

/// See above, we don't want jerry from accounting to try and message nullspace his new bike
/obj/item/modular_computer/tablet/pda/proc/cloak_pda()
	GLOB.PDAs -= src
