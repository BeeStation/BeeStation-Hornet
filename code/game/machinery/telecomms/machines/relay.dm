/**
 * The relay idles until it receives information. It then passes on that information
 * depending on where it came from.
 *
 * The relay is needed in order to send information to different Z levels. It
 * must be linked with a hub, the only other machine that can send to/receive
 * from other Z levels.
 */
/obj/machinery/telecomms/relay
	name = "telecommunication relay"
	icon_state = "relay"
	desc = "A mighty piece of hardware used to send massive amounts of data far away."
	telecomms_type = /obj/machinery/telecomms/relay
	density = TRUE
	use_power = NO_POWER_USE // made only so they don't overheat in whatever places they usually are in (exploration shuttle, small rooms in multi-z maps etc.)
	netspeed = 5
	long_range_link = TRUE
	circuit = /obj/item/circuitboard/machine/telecomms/relay
	/// Can this relay broadcast signals to other Z levels?
	var/broadcasting = TRUE
	/// Can this relay receive signals from other Z levels?
	var/receiving = TRUE

/obj/machinery/telecomms/relay/receive_information(datum/signal/subspace/signal, obj/machinery/telecomms/machine_from)
	// Add our level and send it back
	var/turf/T = get_turf(src)
	if(can_send(signal) && T)
		signal.levels |= T.get_virtual_z_level()

/**
 * Checks to see if the relay can send/receive the signal, by checking if it's
 * on, and if it's listening to the frequency of the signal.
 *
 * Returns `TRUE` if it can listen to the signal, `FALSE` if not.
 */
/obj/machinery/telecomms/relay/proc/can_listen_to_signal(datum/signal/signal)
	if(!on)
		return FALSE
	if(!is_freq_listening(signal))
		return FALSE
	return TRUE

/**
 * Checks to see if the relay can send this signal, which requires it to have
 * `broadcasting` set to `TRUE`.
 *
 * Returns `TRUE` if it can send the signal, `FALSE` if not.
 */
/obj/machinery/telecomms/relay/proc/can_send(datum/signal/signal)
	if(!can_listen_to_signal(signal))
		return FALSE
	return broadcasting

/**
 * Checks to see if the relay can receive this signal, which requires it to have
 * `receiving` set to `TRUE`.
 *
 * Returns `TRUE` if it can receive the signal, `FALSE` if not.
 */
/obj/machinery/telecomms/relay/proc/can_receive(datum/signal/signal)
	if(!can_listen_to_signal(signal))
		return FALSE
	return receiving

// Preset Relays
/obj/machinery/telecomms/relay/preset
	network = "tcommsat"

/obj/machinery/telecomms/relay/Initialize(mapload)
	. = ..()
	if(autolinkers.len) //We want lateloaded presets to autolink (lateloaded aways/ruins/shuttles)
		return INITIALIZE_HINT_LATELOAD

/obj/machinery/telecomms/relay/preset/station
	id = "Station Relay"
	autolinkers = list("s_relay")

/obj/machinery/telecomms/relay/preset/telecomms
	id = "Telecomms Relay"
	autolinkers = list("relay")

/obj/machinery/telecomms/relay/preset/mining
	id = "Mining Relay"
	autolinkers = list("m_relay")

/obj/machinery/telecomms/relay/preset/ruskie
	id = "Ruskie Relay"
	hide = 1
	toggled = FALSE
	autolinkers = list("r_relay")

/obj/machinery/telecomms/relay/preset/reebe
	id = "Hierophant Relay"
	hide = 1
	autolinkers = list("h_relay")
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "relay"
	broadcasting = FALSE	//It only receives

/obj/machinery/telecomms/relay/preset/reebe/attackby(obj/item/P, mob/user, params)
	if(istype(P, /obj/item/encryptionkey) || P.tool_behaviour == TOOL_SCREWDRIVER)
		if(GLOB.clockcult_eminence)
			var/mob/living/simple_animal/eminence/eminence = GLOB.clockcult_eminence
			var/obj/item/encryptionkey/E
			for(var/i in E.channels)
				E.channels[i] = 1
			eminence.internal_radio.attackby(E, user, params)
	. = ..()

// Generic preset relay
/obj/machinery/telecomms/relay/preset/auto
	hide = TRUE
	autolinkers = list("autorelay")

/obj/machinery/telecomms/relay/preset/exploration
	id = "Exploration Relay"
	autolinkers = list("exp_relay")
