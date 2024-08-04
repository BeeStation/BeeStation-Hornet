/obj/item/computer_hardware/identifier
	name = "identifier"
	desc = "Used to automatically update the names of modular devices."
	power_usage = 0
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_IDENTIFY
	expansion_hw = FALSE

/obj/item/computer_hardware/identifier/proc/UpdateDisplay()
	var/obj/item/computer_hardware/id_slot/id_slot = holder.all_components[MC_ID_AUTH]
	if(!istype(id_slot))
		return

	var/obj/item/mainboard/physical_holder = holder.physical_holder
	if(!istype(physical_holder))
		return

	physical_holder.name = "PDA-[id_slot.saved_identification] ([id_slot.saved_job])"
