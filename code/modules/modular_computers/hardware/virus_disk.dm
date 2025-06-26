/obj/item/computer_hardware/hard_drive/role/virus
	name = "\improper generic virus disk"
	icon_state = "cart-detomatrix"
	var/charges = 5
	/// Strength of the virus, it will fight the virus buster, if it wins, it passes, if it ties theres a 50% chance of passing.
	var/virus_strength = 1

/obj/item/computer_hardware/hard_drive/role/virus/proc/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(!target)
		to_chat(user, span_notice("ERROR: Could not find device."))
		return FALSE
	if(charges <= 0)
		to_chat(user, span_notice("ERROR: Out of charges."))
		return FALSE
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	var/datum/computer_file/program/messenger/app = drive.find_file_by_name("nt_messenger")
	if(app.sending_and_receiving == FALSE)
		to_chat(user, span_notice("ERROR: Target has their recieving DISABLED."))
		return FALSE
	if(drive.virus_defense)
		if(drive.virus_defense > virus_strength)
			virus_blocked(target, user)
			return FALSE
		else if(drive.virus_defense == virus_strength)
			if(prob(50))
				virus_blocked(target, user)
				return FALSE
	charges-- //Continues from here
	new /obj/effect/particle_effect/sparks/red(get_turf(target))
	playsound(target, "sparks", 50, 1)
	to_chat(user, span_notice("<font color='#ff0000'>Virus deployed.</font> charges left: <font color='#00ff4c'>[charges]</font>."))
	return TRUE

/obj/item/computer_hardware/hard_drive/role/virus/proc/virus_blocked(obj/item/modular_computer/tablet/target, mob/living/user)
	charges--
	target.virus_blocked()
	new /obj/effect/particle_effect/sparks/blue(get_turf(target))
	playsound(src, "sparks", 50, 1)
	playsound(src, 'sound/machines/defib_failed.ogg', 50, TRUE)
	to_chat(user, span_notice("<font color='#ff0000'>ERROR: Virus Blocked!</font> charges left: <font color='#00ff4c'>[charges]</font>."))

/obj/item/computer_hardware/hard_drive/role/virus/clown
	name = "\improper H.O.N.K. disk"
	desc = "A data disk for portable microcomputers. It smells vaguely of bananas."
	icon_state = "cart-clown"

/obj/item/computer_hardware/hard_drive/role/virus/clown/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	target.honk_amount = rand(15, 25)

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
		to_chat(user, span_notice("[src] beeps: 'Out of charge. Please insert a new cartridge.'"))
		return TRUE
	if(target.GetComponent(/datum/component/sound_player))
		to_chat(user, span_notice("[src] beeps: 'Virus already present on client, aborting.'"))
		return TRUE
	to_chat(user, span_notice("You upload the virus to [target]!"))
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
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	for(var/datum/computer_file/program/messenger/app in drive.stored_files)
		app.ringer_status = FALSE
		app.ringtone = ""

/obj/item/computer_hardware/hard_drive/role/virus/syndicate
	name = "\improper D.E.T.O.M.A.T.I.X. disk"
	icon_state = "cart-detomatrix"
	charges = 4
	virus_strength = 2

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	log_bomber(user, "triggered a PDA explosion on", target, "[!is_special_character(user) ? "(TRIGGED BY NON-ANTAG)" : ""]")
	target.explode(target, user)

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/military
	name = "\improper D.E.T.O.M.A.T.I.X. Deluxe disk"
	disk_flags = DISK_REMOTE_AIRLOCK
	// Make sure this matches the syndicate shuttle's shield/door id in _maps/shuttles/infiltrator/infiltrator_basic.dmm
	controllable_airlocks = list("smindicate")
	virus_strength = 3

/obj/item/computer_hardware/hard_drive/role/virus/frame
	name = "\improper F.R.A.M.E. disk"
	icon_state = "cart-prove"
	var/telecrystals = 0
	virus_strength = 2

/obj/item/computer_hardware/hard_drive/role/virus/frame/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/lock_code = "[random_code(3)] [pick(GLOB.phonetic_alphabet)]"
	to_chat(user, span_notice("The unlock code to the target is: [lock_code]"))
	var/datum/component/uplink/hidden_uplink = target.GetComponent(/datum/component/uplink)
	if(!hidden_uplink)
		hidden_uplink = target.AddComponent(/datum/component/uplink)
		hidden_uplink.unlock_code = lock_code
	else
		hidden_uplink.hidden_crystals += hidden_uplink.telecrystals //Temporarially hide the PDA's crystals, so you can't steal telecrystals.
	hidden_uplink.telecrystals = telecrystals
	telecrystals = 0
	hidden_uplink.active = TRUE
