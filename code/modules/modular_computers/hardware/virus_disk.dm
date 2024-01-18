/obj/item/computer_hardware/hard_drive/role/virus
	name = "\improper generic virus disk"
	icon_state = "cart-detomatrix"
	var/charges = 5

/obj/item/computer_hardware/hard_drive/role/virus/proc/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	return

/obj/item/computer_hardware/hard_drive/role/virus/clown
	name = "\improper H.O.N.K. disk"
	desc = "A data disk for portable microcomputers. It smells vaguely of bananas."
	icon_state = "cart-clown"

/obj/item/computer_hardware/hard_drive/role/virus/clown/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, "<span class='notice'>ERROR: Out of charges.</span>")
		return

	if(target)
		to_chat(user, "<span class='notice'>Success!</span>")
		charges--
		target.honk_amount = rand(15, 25)
	else
		to_chat(user, "<span class='notice'>ERROR: Could not find device.</span>")

/obj/item/computer_hardware/hard_drive/role/virus/clown/process_pre_attack(atom/target, mob/living/user, params)
	// only run if we're inside a computer
	if(!istype(loc, /obj/item/modular_computer))
		return ..()
	if(!ismachinery(target))
		return TRUE
	var/obj/machinery/target_machine = target
	if(!target_machine.panel_open && !istype(target, /obj/machinery/computer))
		return TRUE
	if(!charges)
		to_chat(user, "<span class='notice'>[src] beeps: 'Out of charge. Please insert a new cartridge.'</span>")
		return TRUE
	if(target.GetComponent(/datum/component/sound_player))
		to_chat(user, "<span class='notice'>[src] beeps: 'Virus already present on client, aborting.'</span>")
		return TRUE
	to_chat(user, "<span class='notice'>You upload the virus to [target]!</span>")
	var/list/sig_list
	if(istype(target, /obj/machinery/door/airlock))
		sig_list = list(COMSIG_AIRLOCK_OPEN, COMSIG_AIRLOCK_CLOSE)
	else
		sig_list = list(COMSIG_ATOM_ATTACK_HAND)
	charges--
	target.AddComponent(
		/datum/component/sound_player, \
		uses = rand(30,50), \
		signal_list = sig_list, \
	)
	return FALSE

/obj/item/computer_hardware/hard_drive/role/virus/mime
	name = "\improper sound of silence disk"

/obj/item/computer_hardware/hard_drive/role/virus/mime/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, "<span class='notice'>ERROR: Out of charges.</span>")
		return

	if(target)
		to_chat(user, "<span class='notice'>Success!</span>")
		charges--
		var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
		for(var/datum/computer_file/program/messenger/app in drive.stored_files)
			app.ringer_status = FALSE
			app.ringtone = ""
	else
		to_chat(user, "<span class='notice'>ERROR: Could not find device.</span>")

/obj/item/computer_hardware/hard_drive/role/virus/syndicate
	name = "\improper D.E.T.O.M.A.T.I.X. disk"
	icon_state = "cart-detomatrix"
	charges = 4

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, "<span class='notice'>ERROR: Out of charges.</span>")
		return
	if(!target)
		to_chat(user, "<span class='notice'>ERROR: Could not find device.</span>")
		return
	charges--

	var/difficulty = 0
	var/obj/item/computer_hardware/hard_drive/role/disk = target.all_components[MC_HDD_JOB]

	if(disk)
		difficulty += bit_count(disk.disk_flags & (DISK_MED | DISK_SEC | DISK_POWER | DISK_MANIFEST))
		if(disk.disk_flags & DISK_MANIFEST)
			difficulty++ //if disk has manifest access it has extra snowflake difficulty
		else
			difficulty += 2
	var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
	if(!target.detonatable || prob(difficulty * 15) || (hidden_uplink))
		to_chat(user, "<span class='danger'>An error flashes on your [src].</span>")
	else
		log_bomber(user, "triggered a PDA explosion on", target, "[!is_special_character(user) ? "(TRIGGED BY NON-ANTAG)" : ""]")
		to_chat(user, "<span class='notice'>Success!</span>")
		target.explode(target, user)

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/military
	name = "\improper D.E.T.O.M.A.T.I.X. Deluxe disk"
	disk_flags = DISK_REMOTE_AIRLOCK
	// Make sure this matches the syndicate shuttle's shield/door id in _maps/shuttles/infiltrator/infiltrator_basic.dmm
	controllable_airlocks = list("smindicate")

/obj/item/computer_hardware/hard_drive/role/virus/frame
	name = "\improper F.R.A.M.E. disk"
	icon_state = "cart-prove"
	var/telecrystals = 0

/obj/item/computer_hardware/hard_drive/role/virus/frame/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(charges <= 0)
		to_chat(user, "<span class='notice'>ERROR: Out of charges.</span>")
		return
	if(!target)
		to_chat(user, "<span class='notice'>ERROR: Could not find device.</span>")
		return
	charges--
	var/lock_code = "[random_code(3)] [pick(GLOB.phonetic_alphabet)]"
	to_chat(user, "<span class='notice'>Success! The unlock code to the target is: [lock_code]</span>")
	var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
	if(!hidden_uplink)
		hidden_uplink = target.AddComponent(/datum/component/uplink)
		hidden_uplink.unlock_code = lock_code
	else
		hidden_uplink.hidden_crystals += hidden_uplink.telecrystals //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
	hidden_uplink.telecrystals = telecrystals
	telecrystals = 0
	hidden_uplink.active = TRUE

