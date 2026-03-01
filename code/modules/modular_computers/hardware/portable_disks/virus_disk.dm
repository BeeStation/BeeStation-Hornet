/obj/item/computer_hardware/hard_drive/role/virus
	name = "\improper generic virus disk"
	icon_state = "cart-detomatrix"
	var/charges = 5
	/// Strength of the virus, it will fight the virus buster, if it wins, it passes, if it ties theres a 50% chance of passing.
	var/virus_strength = 1
	/// A name for the virus, it will be used in network logs!
	var/virus_class = "generix"
	can_hack = FALSE
	/// If this virus bypasses Sending and Receiving being disabled
	var/sending_bypass = FALSE
	trade_flags = TRADE_CONTRABAND

/obj/item/computer_hardware/hard_drive/role/virus/proc/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(!target)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Could not find device.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Could not find device."))
		return FALSE
	if(charges <= 0)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Out of charges.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Out of charges."))
		return FALSE
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	var/datum/computer_file/program/messenger/app = drive.find_file_by_name("nt_messenger")
	if(trojan && drive.trojan)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Active virus strain already present.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Active virus strain already present."))
		return FALSE
	if(app.sending_and_receiving == FALSE && !sending_bypass)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Target has their receiving DISABLED.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Target has their receiving DISABLED."))
		return FALSE
	calculate_strength()
	if(drive.virus_defense)
		if(drive.virus_defense > virus_strength)
			virus_blocked(target, user)
			return FALSE
		else if(drive.virus_defense == virus_strength)
			if(prob(50))
				virus_blocked(target, user)
				return FALSE
	charges-- //Continues from here
	new /obj/effect/particle_effect/sparks/red(get_turf(target))	// We don't make it extremely obvious the target got trolled
	new /obj/effect/particle_effect/sparks/blue(get_turf(src))
	playsound(target, "sparks", 50, 1)
	playsound(src, "sparks", 50, 1)
	playsound(src, 'sound/machines/defib_ready.ogg', 50, TRUE)
	balloon_alert_to_viewers("<font color='#ff0000'>Virus deployed.</font> charges left: <font color='#00ff4c'>[charges]</font>.")
	to_chat(user, span_notice("<span class='cfc_red'>Virus deployed.</span> charges left: <span class='cfc_green'>[charges]</span>."))
	nt_log(target, user)
	return TRUE

/obj/item/computer_hardware/hard_drive/role/virus/proc/calculate_strength()
	var/obj/item/computer_hardware/hard_drive/drive = holder.all_components[MC_HDD]
	if(drive.virus_lethality)
		virus_strength = min((virus_strength + drive.virus_lethality), 4)
	else
		virus_strength = initial(virus_strength)

/obj/item/computer_hardware/hard_drive/role/virus/proc/nt_log(obj/item/modular_computer/tablet/target, mob/living/user, blocked = FALSE)
	var/obj/item/computer_hardware/network_card/card = holder.all_components[MC_NET]
	var/obj/item/computer_hardware/network_card/t_card = target.all_components[MC_NET]
	var/virus_name = virus_class
	if(prob(30) && !blocked)
		virus_name = "UNKNOWN"	//If the virus wasn't blocked, lets not be a tattletale (always)!
	if(!blocked)
		holder.add_log("SYSnotice :: Network anomaly class: [virus_name]! suspicious transmission detected. Trace: [card.get_network_tag()] → [t_card.get_network_tag()]")
	else
		holder.add_log("ALERT: Threat class [virus_name] suppressed by AV software. Trace: [card.get_network_tag()] → [t_card.get_network_tag()]")

/obj/item/computer_hardware/hard_drive/role/virus/proc/virus_blocked(obj/item/modular_computer/tablet/target, mob/living/user)
	charges--
	target.virus_blocked_info()
	new /obj/effect/particle_effect/sparks/red(get_turf(src))
	playsound(src, "sparks", 50, 1)
	playsound(src, 'sound/machines/defib_failed.ogg', 50, TRUE)
	balloon_alert(user, "<font color='#ff0000'>ERROR: Virus Blocked!</font> charges left: <font color='#00ff4c'>[charges]</font>.")
	to_chat(user, span_notice("<span class='cfc_red'>ERROR: Virus Blocked!</span> charges left: <span class='cfc_green'>[charges]</span>."))
	nt_log(target, user, blocked = TRUE)

/obj/item/computer_hardware/hard_drive/role/virus/clown
	name = "\improper H.O.N.K. disk"
	desc = "A data disk for portable microcomputers. It smells vaguely of bananas."
	icon_state = "cart-clown"
	virus_class = "HONK::CORE"
	trade_flags = NONE
	spam_delay = 3 //For my honkers, spread out your message to everyone on the station.

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
		balloon_alert(user, "Out of charge. Please insert a new cartridge.")
		to_chat(user, span_notice("[src] beeps: 'Out of charge. Please insert a new cartridge.'"))
		return TRUE
	if(target.GetComponent(/datum/component/sound_player))
		balloon_alert(user, "Virus already present on client, aborting.")
		to_chat(user, span_notice("[src] beeps: 'Virus already present on client, aborting.'"))
		return TRUE
	balloon_alert(user, "Upload Successful.")
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
	virus_class = "MUTEWORM.VRS"
	trade_flags = NONE

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
	virus_class = "ViperClass.Syn"

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/battery/controler = target.all_components[MC_CELL]
	if(!controler)
		return
	var/obj/item/stock_parts/cell/computer/cell = controler.battery
	log_bomber(user, "triggered a PDA explosion on", target, "[!is_special_character(user) ? "(TRIGGED BY NON-ANTAG)" : ""]")
	cell.use(cell.charge - 1)	// We want to delay the explosion a bit so the target receives the overclocking notification and gets spooked
	if(controler.hacked)
		return
	if(ismob(loc))
		var/mob/victim = loc
		controler.overclock(victim)
	else
		controler.hacked = TRUE

/obj/item/computer_hardware/hard_drive/role/virus/syndicate/military
	name = "\improper D.E.T.O.M.A.T.I.X. Deluxe disk"
	disk_flags = DISK_REMOTE_AIRLOCK
	// Make sure this matches the syndicate shuttle's shield/door id in _maps/shuttles/infiltrator/infiltrator_basic.dmm
	controllable_airlocks = list("smindicate")
	virus_strength = 3
	virus_class = "WIDDOWCLASS.Syn"

/obj/item/computer_hardware/hard_drive/role/virus/frame
	name = "\improper F.R.A.M.E. disk"
	icon_state = "cart-prove"
	var/telecrystals = 0
	virus_strength = 2
	virus_class = "TagInject.Syn"

/obj/item/computer_hardware/hard_drive/role/virus/frame/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/lock_code = "[random_code(3)] [pick(GLOB.phonetic_alphabet)]"
	to_chat(user, span_notice("The unlock code to the target is: [lock_code]"))
	var/datum/component/uplink/hidden_uplink = target.AddComponent(/datum/component/uplink, directive_flags = NONE)
	hidden_uplink.unlock_code = lock_code
	hidden_uplink.telecrystals = telecrystals
	telecrystals = 0
	hidden_uplink.active = TRUE

/obj/item/computer_hardware/hard_drive/role/virus/coil
	name = "\improper Coilvrs Drive"
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk6"
	virus_strength = 1
	charges = 1
	virus_class = "Coilvrs.exe"

/obj/item/computer_hardware/hard_drive/role/virus/coil/Initialize(mapload)
	. = ..()
	store_file(new/datum/computer_file/program/readme/coil_readme())
	store_file(new/datum/computer_file/program/coil_virus())

/obj/item/computer_hardware/hard_drive/role/virus/coil/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	empulse(get_turf(target), 1, 1, 1)
	playsound(get_turf(target), "sparks", 50)
	playsound(get_turf(target), 'sound/machines/defib_zap.ogg', 25, TRUE)
	component_qdel()

/obj/item/computer_hardware/hard_drive/role/virus/breacher
	name = "\improper BrexerTrojn Drive"
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk6"
	virus_strength = 2
	charges = 1
	virus_class = "BrexerTrojn.exe"
	sending_bypass = TRUE
	trojan = BREACHER

/obj/item/computer_hardware/hard_drive/role/virus/breacher/Initialize(mapload)
	. = ..()
	store_file(new/datum/computer_file/program/readme/breacher_readme())
	store_file(new/datum/computer_file/program/breacher_virus())

/obj/item/computer_hardware/hard_drive/role/virus/breacher/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	var/datum/computer_file/program/messenger/app = drive.find_file_by_name("nt_messenger")
	drive.trojan = BREACHER
	app.sending_and_receiving = TRUE
	component_qdel()

/obj/item/computer_hardware/hard_drive/role/virus/sledge
	name = "\improper Sleghamr Drive"
	icon = 'icons/obj/module.dmi'
	icon_state = "datadisk6"
	virus_strength = 2
	charges = 1
	virus_class = "Sleghamr.exe"
	trojan = SLEDGE

/obj/item/computer_hardware/hard_drive/role/virus/sledge/Initialize(mapload)
	. = ..()
	store_file(new/datum/computer_file/program/readme/sledge_readme())
	store_file(new/datum/computer_file/program/sledge_virus())

/obj/item/computer_hardware/hard_drive/role/virus/sledge/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	. = ..()
	if(!.)
		return
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	drive.trojan = SLEDGE
	if(drive.virus_defense)
		drive.virus_defense --
	component_qdel()

/obj/item/computer_hardware/hard_drive/role/virus/antivirus
	name = "\improper NT Virus Buster (Crack)"
	icon = 'icons/obj/module.dmi'
	icon_state = "antivirus1"
	charges = 1
	virus_strength = 1
	virus_class = "NTVBGiftBsc.exe"

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/Initialize(mapload)
	. = ..()
	store_file(new/datum/computer_file/program/readme/antivirus_readme())

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/send_virus(obj/item/modular_computer/tablet/target, mob/living/user)
	if(!target)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Could not find device.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Could not find device."))
		return FALSE
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]
	var/datum/computer_file/program/messenger/app = drive.find_file_by_name("nt_messenger")
	if(app.sending_and_receiving == FALSE)
		balloon_alert(user, "<font color='#c70000'>ERROR:</font> Target has their receiving DISABLED.")
		to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Target has their receiving DISABLED."))
		return FALSE
	calculate_strength()
	if(drive.virus_defense >= virus_strength)
		virus_blocked(target, user)
		return FALSE
	else
		target.antivirus_gift(virus_strength)
		playsound(src, 'sound/machines/defib_ready.ogg', 50, TRUE)
		new /obj/effect/particle_effect/sparks/blue(get_turf(src))
		playsound(src, "sparks", 50, 1)
		nt_log(target, user)
		balloon_alert(user, "<font color='#1eff00'>SUCCESS!</font> your colleague is now enjoying their new <font color='#00f7ff'>NTOS Virus Buster</font> subscription package!")
		to_chat(user, span_notice("<span class='cfc_green'>>SUCCESS!</span> your colleague is now enjoying their new <span class='cfc_cyan'>NTOS Virus Buster</span> subscription package!"))
		component_qdel()

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/virus_blocked(obj/item/modular_computer/tablet/target, mob/living/user)
	var/obj/item/computer_hardware/hard_drive/drive = target.all_components[MC_HDD]

	target.virus_blocked_info(gift_card = TRUE)
	new /obj/effect/particle_effect/sparks/red(get_turf(src))
	playsound(src, "sparks", 50, 1)
	playsound(src, 'sound/machines/defib_failed.ogg', 50, TRUE)
	balloon_alert(user, "<font color='#c70000'>ERROR:</font> Target already has an NTOS Virus Buster Lvl-[drive.virus_defense] package!")
	to_chat(user, span_notice("<span class='cfc_red'>ERROR:</span> Target already has an NTOS Virus Buster Lvl-[drive.virus_defense] package!"))
	nt_log(target, user)

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_2
	icon_state = "antivirus2"
	virus_strength = 2
	charges = 1
	virus_class = "NTVBGiftStndrd.exe"

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_3
	icon_state = "antivirus3"
	virus_strength = 3
	charges = 1
	virus_class = "NTVBGiftEssl.exe"

/obj/item/computer_hardware/hard_drive/role/virus/antivirus/tier_4
	icon_state = "antivirus4"
	virus_strength = 4
	charges = 1
	virus_class = "NTVBGiftPrm.exe"
