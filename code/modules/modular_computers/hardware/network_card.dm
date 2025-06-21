/obj/item/computer_hardware/network_card
	name = "network card"
	desc = "A basic wireless network card for usage with standard NTNet frequencies."
	power_usage = 50
	icon_state = "radio_mini"
	icon_open = "radio_mini_open"
	network_id = NETWORK_CARDS	// Network we are on
	var/hardware_id = null	// Identification ID. Technically MAC address of this device. Can't be changed by user.
	var/identification_string = "" 	// Identification string, technically nickname seen in the network. Can be set by user.
	/// Type of signal, High requires no Tcoms in Z-level, Lan is always on
	var/signal_level = LOW
	malfunction_probability = 1
	device_type = MC_NET
	custom_price = 10
	can_hack = TRUE

/obj/item/computer_hardware/network_card/LateInitialize()
	. = ..()
	hardware_id = GetComponent(/datum/component/ntnet_interface).hardware_id

/obj/item/computer_hardware/network_card/diagnostics(var/mob/user)
	..()
	to_chat(user, "NIX Unique ID: [hardware_id]")
	to_chat(user, "NIX User Tag: [identification_string]")
	to_chat(user, "Supported protocols:")
	switch(signal_level)
		if(NO_SIGNAL)
			to_chat(user, "N0 Signal Detected...")
		if(LOW)
			to_chat(user, "511.m SFS (Subspace) - Standard Frequency Spread")
		if(HIGH)
			to_chat(user, "511.n WFS/HB (Subspace) - Wide Frequency Spread/High Bandiwdth")
		if(NO_RELAY)
			to_chat(user, "OpenEth (Physical Connection) - Physical network connection port")
		if(HACKED)
			to_chat(user, "<font color='#d10282'>(!WARN)</font> F.N-<font color='#d10236'>72::BLUESP</font>ΔCE <font color='#02d19d'>LINK_OVRCLK@ERR_0x3F</font>")
	return

/obj/item/computer_hardware/network_card/update_overclocking()
	if(hacked)
		signal_level = HACKED
	else
		signal_level = initial(signal_level)
	return

/obj/item/computer_hardware/network_card/overclock_failure(mob/living/user, obj/item/tool)
	to_chat(user, "You hear a faint click inside... something changed!")
	signal_level = HIGH

// Returns a string identifier of this network card
/obj/item/computer_hardware/network_card/proc/get_network_tag()
	return "[identification_string] (NID [hardware_id])"

// 0 - No signal, 1 - Low signal, 2 - High signal. 3 - Wired Connection
/obj/item/computer_hardware/network_card/proc/get_signal(var/specific_action = 0)
	if(!holder) // Hardware is not installed in anything. No signal. How did this even get called?
		return 0
	if(!check_functionality())
		return 0
	if(signal_level == NO_RELAY)
		return 3
	if(signal_level == HACKED)
		return 4
	if(!SSnetworks.station_network || !SSnetworks.station_network.check_function(specific_action, get_virtual_z_level(), signal_level)) // NTNet is down and we are not connected via wired connection. No signal.
		return 0
	if(holder)
		var/turf/T = get_turf(holder)
		if((T && istype(T)) && (is_station_level(T.z) || is_mining_level(T.z)))
			// Computer is on station. Low/High signal depending on what type of network card you have
			if(signal_level == HIGH)
				return 2
			else
				return 1
	if(signal_level == HIGH) // Computer is not on station, but it has upgraded network card. Low signal.
		return 1
	return 0 // Computer is not on station and does not have upgraded network card. No signal.

/obj/item/computer_hardware/network_card/advanced
	name = "advanced network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. Its transmitter is strong enough to connect even off-station."
	signal_level = HIGH
	power_usage = 100 // Better range but higher power usage.
	icon_state = "radio"
	icon_open = "radio_open"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_TINY
	custom_price = 40

/obj/item/computer_hardware/network_card/advanced/norelay
	name = "ultra-advanced network card"
	desc = "A prototype card that mimics hardline connectivity using unstable bluespace channels. Impervious to relay interference."
	signal_level = NO_RELAY
	power_usage = 200
	icon_state = "no-relay"
	custom_price = 100

/obj/item/computer_hardware/network_card/wired
	name = "wired network card"
	desc = "An advanced network card for usage with standard NTNet frequencies. This one also supports wired connection."
	signal_level = NO_RELAY
	power_usage = 100 // Better range but higher power usage.
	icon_state = "net_wired"
	w_class = WEIGHT_CLASS_NORMAL

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
