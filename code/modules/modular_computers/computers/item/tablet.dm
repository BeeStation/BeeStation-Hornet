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
	var/has_variants = TRUE
	var/finish_color = null

/obj/item/modular_computer/tablet/update_icon()
	..()
	if (has_variants)
		if(!finish_color)
			finish_color = pick("red","blue","brown","green","black")
		icon_state = "tablet-[finish_color]"
		icon_state_unpowered = "tablet-[finish_color]"
		icon_state_powered = "tablet-[finish_color]"

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

/// Given to Nuke Ops members.
/obj/item/modular_computer/tablet/nukeops
	icon_state = "tablet-syndicate"
	icon_state_powered = "tablet-syndicate"
	icon_state_unpowered = "tablet-syndicate"
	comp_light_luminosity = 6.3
	has_variants = FALSE
	device_theme = "syndicate"
	light_color = COLOR_RED

/obj/item/modular_computer/tablet/nukeops/emag_act(mob/user)
	if(!enabled)
		to_chat(user, "<span class='warning'>You'd need to turn the [src] on first.</span>")
		return FALSE
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
	///Ref to the borg we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/robot/borgo
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

/obj/item/modular_computer/tablet/integrated/turn_on(mob/user)
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
	.["has_light"] = TRUE
	.["light_on"] = borgo?.lamp_enabled
	.["comp_light_color"] = borgo?.lamp_color

//Overrides the ui_act to make the flashlight controls link to the borg instead
/obj/item/modular_computer/tablet/integrated/ui_act(action, params)
	switch(action)
		if("PC_toggle_light")
			if(!borgo)
				return FALSE
			borgo.toggle_headlamp()
			return TRUE

		if("PC_light_color")
			if(!borgo)
				return FALSE
			var/mob/user = usr
			var/new_color
			while(!new_color)
				new_color = input(user, "Choose a new color for [src]'s flashlight.", "Light Color",light_color) as color|null
				if(!new_color || QDELETED(borgo))
					return
				if(color_hex2num(new_color) < 200) //Colors too dark are rejected
					to_chat(user, "<span class='warning'>That color is too dark! Choose a lighter one.</span>")
					new_color = null
			borgo.lamp_color = new_color
			borgo.toggle_headlamp(FALSE, TRUE)
			return TRUE
	return ..()

/obj/item/modular_computer/tablet/integrated/alert_call(datum/computer_file/program/caller, alerttext, sound = 'sound/machines/twobeep_high.ogg')
	if(!caller || !caller.alert_able || caller.alert_silenced || !alerttext) //Yeah, we're checking alert_able. No, you don't get to make alerts that the user can't silence.
		return
	borgo.playsound_local(src, sound, 50, TRUE)
	to_chat(borgo, "<span class='notice'>The [src] displays a [caller.filedesc] notification: [alerttext]</span>")

/obj/item/modular_computer/tablet/integrated/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	icon_state_menu = "command-syndicate"
	device_theme = "syndicate"


/obj/item/modular_computer/tablet/integrated/syndicate/Initialize()
	. = ..()
	borgo.lamp_color = COLOR_RED //Syndicate likes it red
