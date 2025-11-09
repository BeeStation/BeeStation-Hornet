/obj/item/computer_hardware/hard_drive/role
	name = "job data disk"
	desc = "A disk meant to give a worker the needed programs to work."
	icon = 'icons/obj/pda.dmi'
	icon_state = "cart"
	w_class = WEIGHT_CLASS_TINY
	critical = FALSE
	max_capacity = 500
	device_type = MC_HDD_JOB
	default_installs = FALSE
	custom_price = 100
	max_demand = 20
	power_usage = 0
	var/list/progs_to_store = list()
	/// Job disk will ignore programs to instal if this is TRUE
	var/dont_instal = FALSE
	var/disk_flags = 0 // bit flag for the programs

/obj/item/computer_hardware/hard_drive/role/on_inserted(mob/user)
	..()
	if(holder)
		playsound(holder, 'sound/machines/pda_button1.ogg', 50, TRUE)

/obj/item/computer_hardware/hard_drive/role/on_remove(obj/item/modular_computer/remove_from, mob/user)
	remove_from.ui_update(user)
	return

/obj/item/computer_hardware/hard_drive/role/Initialize(mapload)
	. = ..()
	if(dont_instal)
		return
	if(disk_flags & DISK_POWER)
		progs_to_store += new /datum/computer_file/program/power_monitor(src)
		progs_to_store += new /datum/computer_file/program/alarm_monitor(src)

	if(disk_flags & DISK_SM)
		progs_to_store += new /datum/computer_file/program/supermatter_monitor(src)

	if(disk_flags & DISK_ATMOS)
		progs_to_store += new /datum/computer_file/program/atmosscan(src)
		progs_to_store += new /datum/computer_file/program/power_monitor(src)
		progs_to_store += new /datum/computer_file/program/gasrig_monitor(src)

	if(disk_flags & DISK_NETWORK)	//Put this higher up so players see it easier and try to interact with it
		progs_to_store += new /datum/computer_file/program/ntnetmonitor(src)

	if(disk_flags & DISK_SEC)
		progs_to_store += new /datum/computer_file/program/records/security(src)

	if(disk_flags & DISK_JANI)
		progs_to_store += new /datum/computer_file/program/radar/custodial_locator(src)

	if((disk_flags & DISK_CHEM) || (disk_flags & DISK_MED) || (disk_flags & DISK_POWER) || (disk_flags & DISK_ATMOS))
		var/datum/computer_file/program/phys_scanner/scanner = new(src)

		progs_to_store += scanner

	if(disk_flags & DISK_ROBOS)
		var/datum/computer_file/program/robocontrol/robo = new(src)
		progs_to_store += robo

	if(disk_flags & DISK_CARGO)
		progs_to_store += new /datum/computer_file/program/bounty(src)

	if(disk_flags & DISK_SILO_LOG)
		progs_to_store += new /datum/computer_file/program/log_viewer(src)

	if(disk_flags & DISK_SIGNAL)
		progs_to_store += new /datum/computer_file/program/signaller(src)

	if(disk_flags & DISK_NEWSCASTER)
		progs_to_store += new /datum/computer_file/program/newscaster(src)

	if(disk_flags & DISK_BUDGET)
		progs_to_store += new /datum/computer_file/program/budgetorders(src)

	if(disk_flags & DISK_STATUS)
		progs_to_store += new /datum/computer_file/program/status(src)

	if(disk_flags & DISK_REMOTE_AIRLOCK)
		progs_to_store += new /datum/computer_file/program/remote_airlock(src)

	if(disk_flags & DISK_HOP)
		progs_to_store += new /datum/computer_file/program/card_mod(src)
		progs_to_store += new /datum/computer_file/program/job_management(src)

	for (var/datum/computer_file/program/prog in progs_to_store)
		prog.transfer_access = list()
		store_file(prog)

/// This creates a clone of the original job disk except its a portable disk (which we use to copy the files that are inside)
/obj/item/computer_hardware/hard_drive/role/update_overclocking(mob/living/user, obj/item/tool)
	var/obj/item/computer_hardware/hard_drive/portable/new_disk = new /obj/item/computer_hardware/hard_drive/portable(get_turf(src))
	for(var/datum/computer_file/program/prog in stored_files)
		var/datum/computer_file/program/clone = new prog.type(new_disk)
		new_disk.store_file(clone)
	new_disk.hacked = TRUE
	new_disk.name = "modified job data disk"
	new_disk.desc = "A disk meant to give a worker the needed programs to work, modified to allow the transfer of its programs and now behaves more like a portable disk."
	new_disk.max_capacity = max_capacity
	new_disk.icon_state = initial(icon_state)
	new_disk.icon = initial(icon)
	new_disk.update_appearance()
	new_disk.spam_delay = initial(spam_delay)
	new_disk.can_hack = FALSE
	new /obj/effect/particle_effect/sparks/red(get_turf(holder))
	qdel(src)
	return

// Disk Definitions

/obj/item/computer_hardware/hard_drive/role/engineering
	name = "\improper Power-ON disk"
	desc = "Engineers ignoring station power-draw since 2400."
	icon_state = "cart-engie"
	disk_flags = DISK_POWER | DISK_SM

/obj/item/computer_hardware/hard_drive/role/atmos
	name = "\improper BreatheDeep disk"
	icon_state = "cart-atmos"
	disk_flags = DISK_ATMOS | DISK_ROBOS | DISK_POWER

/obj/item/computer_hardware/hard_drive/role/medical
	name = "\improper Med-U disk"
	icon_state = "cart-med"
	disk_flags = DISK_MED | DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/chemistry
	name = "\improper ChemWhiz disk"
	icon_state = "cart-chem"
	disk_flags = DISK_CHEM | DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/brig_physician
	name = "\improper R.O.B.U.S.T. MED-U disk"
	icon_state = "cart-brigphys"
	disk_flags = DISK_MED | DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/security
	name = "\improper R.O.B.U.S.T. disk"
	icon_state = "cart-sec"
	disk_flags = DISK_SEC | DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/detective
	name = "\improper D.E.T.E.C.T. disk"
	icon_state = "cart-det"
	disk_flags = DISK_MED | DISK_SEC | DISK_ROBOS | DISK_CHEM

/obj/item/computer_hardware/hard_drive/role/janitor
	name = "\improper CustodiPRO disk"
	icon_state = "cart-jan"
	desc = "The ultimate in clean-room design."
	disk_flags = DISK_JANI | DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/lawyer
	name = "\improper P.R.O.V.E. disk"
	icon_state = "cart-prove"
	disk_flags = DISK_SEC
	spam_delay = 2.5

/obj/item/computer_hardware/hard_drive/role/curator
	name = "\improper Lib-Tweet disk"
	icon_state = "cart-cur"
	disk_flags = DISK_NEWSCASTER
	spam_delay = 3.5

/obj/item/computer_hardware/hard_drive/role/roboticist
	name = "\improper B.O.O.P. Remote Control disk"
	icon_state = "cart-robo"
	desc = "Packed with heavy duty quad-bot interlink!"
	disk_flags = DISK_ROBOS

/obj/item/computer_hardware/hard_drive/role/signal
	name = "generic signaler disk"
	icon_state = "cart-signal"
	desc = "A data disk with an integrated radio signaler module."
	disk_flags = DISK_SIGNAL

/obj/item/computer_hardware/hard_drive/role/signal/toxins
	name = "\improper Signal Ace 2 disk"
	icon_state = "cart-tox"
	desc = "Complete with integrated radio signaler!"
	disk_flags = DISK_NETWORK | DISK_ATMOS | DISK_SIGNAL | DISK_CHEM

/obj/item/computer_hardware/hard_drive/role/quartermaster
	name = "space parts DELUXE disk"
	icon_state = "cart-qm"
	desc = "Perfect for the Quartermaster on the go!"
	disk_flags = DISK_CARGO | DISK_SILO_LOG | DISK_ROBOS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/cargo_technician
	name = "space parts disk"
	icon_state = "cart-cargo"
	desc = "Perfect for the Cargo Tech on the go!"
	disk_flags = DISK_CARGO | DISK_ROBOS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/head
	name = "\improper Easy-Record DELUXE disk"
	icon_state = "cart-val"
	disk_flags = DISK_STATUS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/hop
	name = "\improper HumanResources9001 disk"
	icon_state = "cart-hop"
	disk_flags = DISK_STATUS | DISK_JANI | DISK_SEC | DISK_NEWSCASTER | DISK_CARGO | DISK_SILO_LOG | DISK_ROBOS | DISK_BUDGET | DISK_HOP

/obj/item/computer_hardware/hard_drive/role/hos
	name = "\improper R.O.B.U.S.T. DELUXE disk"
	icon_state = "cart-hos"
	disk_flags = DISK_STATUS | DISK_SEC | DISK_ROBOS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/ce
	name = "\improper Power-On DELUXE disk"
	icon_state = "cart-ce"
	disk_flags = DISK_POWER | DISK_ATMOS | DISK_SM | DISK_STATUS | DISK_ROBOS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/cmo
	name = "\improper Med-U DELUXE disk"
	icon_state = "cart-cmo"
	disk_flags = DISK_STATUS | DISK_MED | DISK_CHEM | DISK_ROBOS | DISK_BUDGET

/obj/item/computer_hardware/hard_drive/role/rd
	name = "\improper Signal Ace DELUXE disk"
	icon_state = "cart-rd"
	disk_flags = DISK_NETWORK | DISK_ATMOS | DISK_STATUS | DISK_CHEM | DISK_ROBOS | DISK_BUDGET | DISK_SIGNAL

/obj/item/computer_hardware/hard_drive/role/captain
	name = "\improper Value-PAK disk"
	icon_state = "cart-cap"
	desc = "Now with 350% more value!"
	//Give the Captain...EVERYTHING! (except the remote airlock control)
	disk_flags = ~(DISK_REMOTE_AIRLOCK)
	spam_delay = 2
	custom_price = 300

/obj/item/computer_hardware/hard_drive/role/vip //the only purpose of this disk is to allow the VIP to be annoying
	name = "\improper TWIT disk"
	icon_state = "cart-twit"
	spam_delay = 1.5

/obj/item/computer_hardware/hard_drive/role/maint //HoP can give you this
	name = "\improper FACEBUCKS disk"
	icon_state = "cart-signal" // might need a new sprite
	spam_delay = 5
