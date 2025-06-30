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
	/// Strength of the virus, it will fight the virus buster, if it wins, it passes, if it ties theres a 50% chance of passing.
	var/virus_strength = 1
	/// If theres a Virus that activates when hacked
	var/dormant_virus = TRUE // This should be replaced with something else later down the line

/obj/item/computer_hardware/hard_drive/portable/install_default_programs()
	return // Empty by default

/obj/item/computer_hardware/hard_drive/portable/on_remove(obj/item/modular_computer/remove_from, mob/user)
	return //this is a floppy disk, let's not shut the computer down when it gets pulled out.

/obj/item/computer_hardware/hard_drive/portable/on_install(obj/item/modular_computer/install_into, mob/living/user)
	..()
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	if(spam_delay)
		drive.spam_delay = spam_delay	// Using a hacked job disk with message all copies that quality onto the hard drive
	if(hacked && dormant_virus)
		if(drive.virus_defense)
			if(drive.virus_defense > virus_strength)
				virus_blocked(install_into, user)
				return
			else if(drive.virus_defense == virus_strength)
				if(prob(50))
					virus_blocked(install_into, user)
					return
			return
		else
			run_virus(install_into, user)
		return

/obj/item/computer_hardware/hard_drive/portable/proc/virus_blocked(obj/item/modular_computer/install_into, mob/living/user)
	var/obj/item/computer_hardware/hard_drive/drive = install_into.all_components[MC_HDD]
	new /obj/effect/particle_effect/sparks/blue(get_turf(install_into))
	playsound(install_into, "sparks", 50, 1)
	playsound(install_into, 'sound/machines/defib_ready.ogg', 50, TRUE)
	to_chat(user, span_notice("Virus <font color='#ff0000'>BUSTED!</font> Your <font color='#00f7ff'>NTOS Virus Buster Lvl-[drive.virus_defense]</font> kept your data <font color='#00ff2a'>SAFE!</font>"))
	install_into.uninstall_component(src)
	qdel(src)

/obj/item/computer_hardware/hard_drive/portable/proc/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/basic/virus = new(src)
	virus.computer = install_into
	virus.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = virus
	ui_interact(user)
	install_into.update_icon()

/obj/item/computer_hardware/hard_drive/portable/advanced
	name = "advanced data disk"
	power_usage = 20
	icon_state = "datadisk5"
	max_capacity = 64
	virus_strength = 2


/obj/item/computer_hardware/hard_drive/portable/advanced/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/advanced/virus = new(src)
	virus.computer = install_into
	virus.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = virus
	ui_interact(user)
	install_into.update_icon()

/obj/item/computer_hardware/hard_drive/portable/super
	name = "super data disk"
	desc = "Removable disk used to store large amounts of data."
	power_usage = 40
	icon_state = "datadisk3"
	max_capacity = 256
	custom_price = 60
	virus_strength = 3

/obj/item/computer_hardware/hard_drive/portable/super/run_virus(obj/item/modular_computer/install_into, mob/living/user)
	var/datum/computer_file/program/virus_basic/super/virus = new(src)
	virus.computer = install_into
	virus.program_state = PROGRAM_STATE_ACTIVE
	install_into.active_program = virus
	ui_interact(user)
	install_into.update_icon()
