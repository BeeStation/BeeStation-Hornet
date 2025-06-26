/obj/item/computer_hardware/hard_drive/portable
	name = "data disk"
	desc = "Removable disk used to store data."
	power_usage = 10
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = 0
	max_capacity = 16
	device_type = MC_SDD
	custom_price = 10
	can_hack = TRUE
	hack_visible = FALSE // These are meant to be sneaky viruses, if someone puts them on their computer for whatever reason (need to add reason to do so)
	/// If this is a former diskjob that was hacked
	var/former_jobdisk = FALSE

/obj/item/computer_hardware/hard_drive/portable/on_remove(obj/item/modular_computer/remove_from, mob/user)
	return //this is a floppy disk, let's not shut the computer down when it gets pulled out.

/obj/item/computer_hardware/hard_drive/portable/on_install(obj/item/modular_computer/install_into, mob/living/user)
	..()
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	if(spam_delay)
		drive.spam_delay = spam_delay	// Using a hacked job disk with message all copies that quality onto the hard drive
	if(hacked && !former_jobdisk)
		if(drive.virus_defense)
			new /obj/effect/particle_effect/sparks/blue(get_turf(holder))
			playsound(install_into, "sparks", 50, 1)
			playsound(install_into, 'sound/machines/defib_ready.ogg', 50, TRUE)
			to_chat(user, span_notice("Virus <font color='#ff0000'>BUSTED!</font> Your <font color='#00f7ff'>NTOS Virus Buster Lvl-[drive.virus_defense]</font> kept your data <font color='#00ff2a'>SAFE!</font>"))
			install_into.uninstall_component(src)
			qdel(src)
			return
		else
			run_virus(install_into, user)
		return

/obj/item/computer_hardware/hard_drive/portable/proc/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/basic/basic = new(src)
	basic.computer = install_into
	basic.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = basic
	ui_interact(user)
	install_into.update_icon()

/obj/item/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/computer_hardware/hard_drive/portable/advanced
	name = "advanced data disk"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64

/obj/item/computer_hardware/hard_drive/portable/advanced/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/advanced/basic = new(src)
	basic.computer = install_into
	basic.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = basic
	ui_interact(user)
	install_into.update_icon()

/obj/item/computer_hardware/hard_drive/portable/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256
	custom_price = 60

/obj/item/computer_hardware/hard_drive/portable/super/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/super/basic = new(src)
	basic.computer = install_into
	basic.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = basic
	ui_interact(user)
	install_into.update_icon()
