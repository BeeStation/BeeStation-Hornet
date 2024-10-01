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
	hardware_flag = PROGRAM_HARDWARE_SILICON

	install_components = list(
		/obj/item/computer_hardware/hard_drive/small,
		/obj/item/computer_hardware/processor_unit/small,
		/obj/item/computer_hardware/network_card/integrated,
		/obj/item/computer_hardware/identifier
	)

	///Ref to the silicon we're installed in. Set by the borg during our creation.
	var/mob/living/silicon/borgo

/obj/item/modular_computer/tablet/integrated/Initialize(mapload, list/obj/item/computer_hardware/override_hardware, obj/item/stock_parts/override_cell)
	. = ..()
	borgo = loc
	if(!istype(borgo))
		borgo = null
		stack_trace("[type] initialized outside of a silicon, deleting.")
		return INITIALIZE_HINT_QDEL

/obj/item/modular_computer/tablet/integrated/Destroy()
	borgo = null
	return ..()

/obj/item/modular_computer/tablet/integrated/can_turn_on(mob/user)
	if(borgo?.stat == DEAD)
		return FALSE
	return ..()

/obj/item/modular_computer/tablet/integrated/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	hard_drive.store_file(new/datum/computer_file/program/messenger)

/obj/item/modular_computer/tablet/integrated/ai/install_modpc_hardware(obj/item/mainboard/MB)
	. = ..()
	MB.install_component(new/obj/item/computer_hardware/hard_drive/small/pda/ai)
	MB.install_component(new/obj/item/computer_hardware/recharger/silicon/ai)

/obj/item/modular_computer/tablet/integrated/cyborg
	///Ref to the Cyborg Self-Monitoring app. Important enough to borgs to deserve a ref.
	var/datum/computer_file/program/borg_self_monitor/self_monitoring

/obj/item/modular_computer/tablet/integrated/cyborg/Initialize(mapload, list/obj/item/computer_hardware/override_hardware, obj/item/stock_parts/override_cell)
	. = ..()
	vis_flags |= VIS_INHERIT_ID

/obj/item/modular_computer/tablet/integrated/cyborg/Destroy()
	self_monitoring = null
	return ..()

/obj/item/modular_computer/tablet/integrated/cyborg/install_modpc_hardware(obj/item/mainboard/MB)
	. = ..()
	MB.install_component(new/obj/item/computer_hardware/hard_drive/small/pda/robot)
	MB.install_component(new/obj/item/computer_hardware/recharger/silicon/cyborg)

/obj/item/modular_computer/tablet/integrated/cyborg/install_modpc_software(obj/item/computer_hardware/hard_drive/hard_drive)
	. = ..()
	self_monitoring = new (hard_drive)
	hard_drive.store_file(self_monitoring)

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
/obj/item/modular_computer/tablet/integrated/cyborg/proc/get_self_monitoring()
	if(!borgo)
		return null
	if(!isnull(self_monitoring))
		return self_monitoring
	var/obj/item/computer_hardware/hard_drive/hard_drive = mainboard.all_components[MC_HDD]
	self_monitoring = hard_drive.find_file_by_name("borg_self_monitor")
	if(isnull(self_monitoring))
		stack_trace("Cyborg [borgo] ( [borgo.type] ) was somehow missing their self-management app in their tablet. A new copy has been created.")
		self_monitoring = new(hard_drive)
		if(!hard_drive.store_file(self_monitoring))
			qdel(self_monitoring)
			self_monitoring = null
			CRASH("Cyborg [borgo]'s tablet hard drive rejected recieving a new copy of the self-management app. To fix, check the hard drive's space remaining. Please make a bug report about this.")

//Makes the light settings reflect the borg's headlamp settings
/obj/item/modular_computer/tablet/integrated/cyborg/ui_data(mob/user)
	. = ..()
	if(iscyborg(borgo))
		var/mob/living/silicon/robot/robo = borgo
		.["light_on"] = robo.lamp_enabled
		.["comp_light_color"] = robo.lamp_color
		.["has_light"] = TRUE

//Makes the flashlight button affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/cyborg/toggle_flashlight()
	if(!borgo || QDELETED(borgo) || !iscyborg(borgo))
		return FALSE
	var/mob/living/silicon/robot/robo = borgo
	robo.toggle_headlamp()
	return TRUE

//Makes the flashlight color setting affect the borg rather than the tablet
/obj/item/modular_computer/tablet/integrated/cyborg/set_flashlight_color(color)
	if(!borgo || QDELETED(borgo) || !color || !iscyborg(borgo))
		return FALSE
	var/mob/living/silicon/robot/robo = borgo
	robo.lamp_color = color
	robo.toggle_headlamp(FALSE, TRUE)
	return TRUE

/obj/item/modular_computer/tablet/integrated/cyborg/ui_state(mob/user)
	return GLOB.reverse_contained_state

/obj/item/modular_computer/tablet/integrated/cyborg/syndicate
	icon_state = "tablet-silicon-syndicate"
	icon_state_unpowered = "tablet-silicon-syndicate"
	icon_state_powered = "tablet-silicon-syndicate"
	icon_state_menu = "command-syndicate"
	syndicate_themed = TRUE

/obj/item/modular_computer/tablet/integrated/cyborg/syndicate/Initialize()
	. = ..()
	if(iscyborg(borgo))
		var/mob/living/silicon/robot/robo = borgo
		robo.lamp_color = COLOR_RED //Syndicate likes it red

/obj/item/modular_computer/tablet/integrated/pai

/obj/item/modular_computer/tablet/integrated/pai/install_modpc_hardware(obj/item/mainboard/MB)
	. = ..()
	MB.install_component(new/obj/item/computer_hardware/hard_drive/small/pda/ai)
	MB.install_component(new/obj/item/computer_hardware/recharger/silicon/pai)
