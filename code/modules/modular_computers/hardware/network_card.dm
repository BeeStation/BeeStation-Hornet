/obj/item/computer_hardware/network_card
	name = "network card"
	desc = "A basic wireless network card for usage with standard NTNet frequencies."
	power_usage = 50
	icon_state = "radio_mini"
	network_id = NETWORK_CARDS	// Network we are on
	var/hardware_id = null	// Identification ID. Technically MAC address of this device. Can't be changed by user.
	var/identification_string = "nt_card_SFS" 	// Default Identification string, like half an IP.
	/// Type of signal, High requires no Tcoms in Z-level, Lan is always on
	var/signal_level = SIGNAL_LOW
	malfunction_probability = 1
	device_type = MC_NET
	custom_price = PAYCHECK_EASY * 2
	var/uplink = FALSE
	var/stored_telecrystals
	var/give_code = FALSE
	var/code

/obj/item/computer_hardware/network_card/Initialize(mapload)
	. = ..()
	//hardware_id = GetComponent(/datum/component/ntnet_interface).hardware_id // This was not working at all, but since this ntnet code is extremely complex I will leave this here for future's sake
	hardware_id = "[serial_code]"
	// ID_String will tell us the job of the person who did something, the hardware_ID can serve as legitimate proof (it will all be loged)

/obj/item/computer_hardware/network_card/on_install(obj/item/modular_computer/install_into, mob/living/user)
	. = ..()
	//var/datum/component/uplink/hidden_uplink = install_into.GetComponent(/datum/component/uplink)
	if(!user && install_into && identification_string == initial(identification_string))	//Only overide default string IF its being installed trough code
		identification_string = "[install_into.icon_state]"
	if(uplink)
		var/datum/component/uplink/hidden_uplink = install_into.AddComponent(/datum/component/uplink)
		hidden_uplink.telecrystals = stored_telecrystals
		if(!code)
			hidden_uplink.unlock_code = hidden_uplink.generate_code()
		else
			hidden_uplink.unlock_code = code
		if((is_special_character(user) || give_code))	// We only let ourselves be known if the player is an antag or it has been specified
			balloon_alert(user, "Welcome <font color='#d40808'>agent!</font> Your access code is <font color='#66f811'>[hidden_uplink.unlock_code]</font>.")
			to_chat(user, span_notice("Welcome <span class='cfc_red'>agent!</span> Your access code is <span class='cfc_bluegreen'>[hidden_uplink.unlock_code]</span>."))

/obj/item/computer_hardware/network_card/on_remove(obj/item/modular_computer/remove_from, mob/living/user)
	. = ..()
	var/datum/component/uplink/old_link = remove_from.GetComponent(/datum/component/uplink)
	if(old_link)
		stored_telecrystals = old_link.telecrystals
		code = old_link.unlock_code
		qdel(old_link)
		uplink = TRUE
		if((is_special_character(user) || give_code))	// We only let ourselves be known if the player is an antag or it has been specified
			balloon_alert(user, "You have removed your uplink <font color='#d40808'>agent</font>. It is currently stored inside your network card.")
			to_chat(user, span_notice("You have removed your uplink <span class='cfc_red'>agent</span>. It is currently stored inside your network card."))
		// Ok so, if this will always copy the uplink that's inside the PDA. Wich can only be granted by network cards with uplinks.
		// This is to avoid having two components and having to retouch a lot of code!

/obj/item/computer_hardware/network_card/diagnostics()
	. = ..()
	. += "NIX Unique ID: <span class='cfc_soul_glimmer_terracotta'>[hardware_id]</span>"
	. += "NIX Identification String: <span class='cfc_soul_glimmer_humour'>[identification_string]</span>"
	. += "Supported protocols:"
	switch(signal_level)
		if(SIGNAL_NO)
			. += "N0 Signal Detected..."
		if(SIGNAL_LOW)
			. += "511.m SFS (Subspace) - Standard Frequency Spread"
		if(SIGNAL_HIGH)
			. += "511.n WFS/HB (Subspace) - Wide Frequency Spread/High Bandiwdth"
		if(SIGNAL_NO_RELAY)
			. += "OpenEth (Physical Connection) - Physical network connection port"
		if(SIGNAL_HACKED)
			. += "<span class='cfc_pink'>(!WARN)</span> F.N-<span class='cfc_red'>72::BLUESP</span>ΔCE <span class='cfc_bluegreen'>LINK_OVRCLK@ERR_0x3F</span>"
	return

/obj/item/computer_hardware/network_card/update_overclocking(mob/living/user, obj/item/tool)
	if(hacked)
		signal_level = SIGNAL_HACKED
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // F.N-Bluespace Connection <font color='#ffd900'>established.</font>")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // F.N-Bluespace Connection <span class='cfc_green'>established.</span>")
	else
		signal_level = initial(signal_level)
		balloon_alert(user, "<font color='#e06eb1'>Update:</font> // F.N-Bluespace Connection <font color='#ff0000'>disabled.</font>.")
		to_chat(user, "<span class='cfc_magenta'>Update:</span> // F.N-Bluespace Connection <span class='cfc_red'>disabled.</span>.")

// Returns a string identifier of this network card
/obj/item/computer_hardware/network_card/proc/get_network_tag()
	return "[identification_string] (NID [hardware_id])"

// 0 - No signal, 1 - Low signal, 2 - High signal. 3 - Wired Connection
/obj/item/computer_hardware/network_card/proc/get_signal(var/specific_action = 0)
	if(!holder) // Hardware is not installed in anything. No signal. How did this even get called?
		return 0
	if(!check_functionality())
		return 0
	if(signal_level == SIGNAL_NO_RELAY)
		return 3
	if(signal_level == SIGNAL_HACKED)
		return 4
	if(!SSnetworks.station_network || !SSnetworks.station_network.check_function(specific_action, get_virtual_z_level(), signal_level)) // NTNet is down and we are not connected via wired connection. No signal.
		return 0
	if(holder)
		var/turf/T = get_turf(holder)
		if((T && istype(T)) && (is_station_level(T.z) || is_mining_level(T.z)))
			// Computer is on station. Low/High signal depending on what type of network card you have
			if(signal_level == SIGNAL_HIGH)
				return 2
			else
				return 1
	if(signal_level == SIGNAL_HIGH) // Computer is not on station, but it has upgraded network card. Low signal.
		return 1
	return 0 // Computer is not on station and does not have upgraded network card. No signal.

/obj/item/computer_hardware/network_card/advanced
	name = "advanced network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. Its transmitter is strong enough to connect even off-station."
	signal_level = SIGNAL_HIGH
	power_usage = 100 // Better range but higher power usage.
	icon_state = "radio"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_price = PAYCHECK_MEDIUM * 2
	identification_string = "nt_card_WFS/HB"

/obj/item/computer_hardware/network_card/advanced/norelay
	name = "ultra-advanced network card"
	desc = "A prototype card that mimics hardline connectivity using unstable bluespace channels. Impervious to relay interference."
	signal_level = SIGNAL_NO_RELAY
	power_usage = 200
	icon_state = "no-relay"
	custom_price = 100
	identification_string = "x_net_card"

/obj/item/computer_hardware/network_card/wired
	name = "wired network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. This one also supports wired connection."
	signal_level = SIGNAL_NO_RELAY
	power_usage = 100 // Better range but higher power usage.
	icon_state = "net_wired"
	w_class = WEIGHT_CLASS_NORMAL
	identification_string = "open_eth"

/obj/item/computer_hardware/network_card/integrated //Borg tablet version, only works while the borg has power and is not locked
	name = "cyborg data link"

/obj/item/computer_hardware/network_card/integrated/get_signal(specific_action = 0)
	var/obj/item/modular_computer/tablet/integrated/modularInterface = holder

	if(!modularInterface || !istype(modularInterface))
		return FALSE //wrong type of tablet

	if(!modularInterface.borgo)
		return FALSE //No borg found

	var/mob/living/silicon/robot/robo = modularInterface.borgo
	if(istype(robo))
		if(robo.lockcharge)
			return FALSE //lockdown restricts borg networking

		if(!robo.cell || robo.cell.charge == 0)
			return FALSE //borg cell dying restricts borg networking
	return ..()

/obj/item/computer_hardware/network_card/uplink
	name = "foreign network card"
	desc = "A totally innocuous network card from unfamiliar parts."
	uplink = TRUE
	stored_telecrystals = 20
	give_code = TRUE
