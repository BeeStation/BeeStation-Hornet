/obj/item/computer_hardware/identifier
	name = "identifier"
	desc = "Used to manage the names of modular devices."
	power_usage = 0
	w_class = WEIGHT_CLASS_TINY
	device_type = MC_IDENTIFY
	expansion_hw = FALSE

	/// The cached ID name
	var/saved_identification
	/// The cached job name
	var/saved_job

/obj/item/computer_hardware/identifier/proc/UpdateDisplay(var/change_identification = null, var/change_job = null)
	if(!isnull(change_identification))
		saved_identification = change_identification
	if(!isnull(change_job))
		saved_job = change_job

	var/obj/item/modular_computer/tablet/pda/pda = holder.physical_holder
	if(!istype(pda))
		return

	pda.name = "PDA-[isnull(saved_identification) ? "" : saved_identification][isnull(saved_job) ? "" : " ([saved_job])"]"
