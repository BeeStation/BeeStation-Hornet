/obj/item/computer_hardware/identifier
	name = "identifier"
	desc = "Used to automatically update the names of modular devices."
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_IDENTIFY
	var/stored_name

/obj/item/computer_hardware/identifier/on_install(obj/item/modular_computer/install_into, mob/living/user)
	. = ..()
	UpdateDisplay()

/obj/item/computer_hardware/identifier/proc/UpdateDisplay()
	if(hacked && stored_name)
		holder.name = "[stored_name]"
		return
	stored_name = holder.saved_identification
	var/job = holder.saved_job
	if(hacked)
		return
	if(istype(holder, /obj/item/modular_computer/tablet/pda))
		holder.name = "PDA-[stored_name] ([job])"
	else if(istype(holder, /obj/item/modular_computer/tablet))
		holder.name = "Tablet-[stored_name] ([job])"

/obj/item/computer_hardware/identifier/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		var/input = tgui_input_text(user, "Device Name Overide: Insert", "NAME DEVICE", "Name", MAX_NAME_LEN)
		if(!input)
			return
		stored_name = input
