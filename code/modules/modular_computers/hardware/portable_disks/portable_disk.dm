/obj/item/computer_hardware/hard_drive/portable
	name = "data disk"
	desc = "Removable disk used to store data."
	icon_state = "datadisk6"
	w_class = WEIGHT_CLASS_TINY
	critical = 0
	max_capacity = 16
	device_type = MC_SDD
	custom_price = PAYCHECK_EASY
	open_overlay = "disk_open"
	var/virus_typepath = /obj/item/computer_hardware/hard_drive/role/virus/sledge
	/// If theres a Virus that activates when hacked

/obj/item/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/computer_hardware/hard_drive/portable/on_remove(obj/item/modular_computer/remove_from, mob/user)
	remove_from.ui_update(user)
	return //this is a floppy disk, let's not shut the computer down when it gets pulled out.

/obj/item/computer_hardware/hard_drive/portable/on_install(obj/item/modular_computer/install_into, mob/living/user)
	..()
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	if(spam_delay)
		drive.spam_delay = spam_delay	// Using a hacked job disk with message all copies that quality onto the hard drive
	install_into.ui_update(user)

/// This creates a clone that is actually a Virus disk
/obj/item/computer_hardware/hard_drive/portable/update_overclocking(mob/living/user, obj/item/tool)
	var/obj/item/computer_hardware/hard_drive/role/virus/virus_disk = new virus_typepath(get_turf(src))
	virus_disk.icon_state = initial(icon_state)
	virus_disk.icon = initial(icon)
	virus_disk.update_appearance()
	virus_disk.hacked = TRUE
	new /obj/effect/particle_effect/sparks/red(get_turf(holder))
	qdel(src)
	return

/obj/item/computer_hardware/hard_drive/portable/advanced
	name = "advanced data disk"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64
	virus_typepath = /obj/item/computer_hardware/hard_drive/role/virus/coil
	custom_price = PAYCHECK_EASY * 2

/obj/item/computer_hardware/hard_drive/portable/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256
	custom_price = 60
	virus_typepath = /obj/item/computer_hardware/hard_drive/role/virus/breacher
	custom_price = PAYCHECK_EASY * 3
