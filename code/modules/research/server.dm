/obj/machinery/rnd/server
	name = "\improper R&D Server"
	desc = "A computer system running a deep neural network that processes arbitrary information to produce data useable in the development of new technologies. In layman's terms, it makes research points."
	icon = 'icons/obj/machines/research.dmi'
	icon_state = "RD-server-on"
	base_icon_state = "RD-server"
	circuit = /obj/item/circuitboard/machine/rdserver
	idle_power_usage = 5
	active_power_usage = 50
	req_access = list(ACCESS_RD_SERVER)

	/// How many points this server generates per mining cycle at 100% efficiency
	var/base_mining_income = 1
	/// Ref to the server component
	var/datum/component/server/server_component
	/// Whether or not the server component should be made.
	var/generates_heat = TRUE

/obj/machinery/rnd/server/Initialize(mapload)
	. = ..()
	if(generates_heat)
		server_component = AddComponent(/datum/component/server)
	//servers handle techwebs differently as we are expected to be there to connect
	//every other machinery on-station.
	if(!stored_research)
		var/datum/techweb/science_web = locate(/datum/techweb/science) in SSresearch.techwebs
		connect_techweb(science_web)

	stored_research.techweb_servers |= src
	name += " [uppertext(num2hex(rand(1, 65535), -1))]" //gives us a random four-digit hex number as part of the name. Y'know, for fluff.

/obj/machinery/rnd/server/Destroy()
	if(stored_research)
		stored_research.techweb_servers -= src
	return ..()

/obj/machinery/rnd/server/RefreshParts()
	var/tot_rating = 0
	for(var/obj/item/stock_parts/part in src)
		tot_rating += part.rating
	active_power_usage = initial(src.active_power_usage) / max(1, tot_rating)

/obj/machinery/rnd/server/update_icon_state()
	if (panel_open)
		icon_state = "[base_icon_state]-on_t"
	else if (machine_stat & EMPED || machine_stat & NOPOWER)
		icon_state = "[base_icon_state]-off"
	else if (machine_stat & (TURNED_OFF|OVERHEATED))
		icon_state = "[base_icon_state]-halt"
	else
		icon_state = "[base_icon_state]-on"
	return ..()

/obj/machinery/rnd/server/proc/toggle_disable(mob/user)
	set_machine_stat(machine_stat ^ TURNED_OFF)
	user?.log_message("[(machine_stat & TURNED_OFF) ? "shut off" : "turned on"] [src]", LOG_GAME)

/// Gets status text based on this server's status for the computer.
/obj/machinery/rnd/server/proc/get_status_text()
	if(machine_stat & EMPED)
		return "R3*&O$T R@U!R%D"
	else if(machine_stat & NOPOWER)
		return "Server Unpowered"
	else if(machine_stat & OVERHEATED)
		return "Overheated"
	else if(machine_stat & TURNED_OFF)
		return "Reboot Required"

	return "Nominal"

// Can't use DEFINE_BUFFER_HANDLER because our parent uses it already
/obj/machinery/rnd/server/_buffer_handler(datum/source, mob/user, atom/buffer, obj/item/buffer_parent)
	if(!stored_research)
		return NONE
	if (TRY_STORE_IN_BUFFER(buffer_parent, stored_research))
		balloon_alert(user, "techweb saved to buffer")
		return COMPONENT_BUFFER_RECEIVED
	return NONE

/obj/machinery/rnd/server/proc/mine()
	use_power(active_power_usage, power_channel)
	var/efficiency = get_efficiency()
	if(!powered() || efficiency <= 0 || machine_stat)
		return null
	return list(TECHWEB_POINT_TYPE_GENERIC = max(base_mining_income * efficiency, 0))

/obj/machinery/rnd/server/proc/get_temperature()
	if(server_component)
		return server_component.temperature
	else
		var/turf/open/our_turf = get_turf(src)
		if(istype(our_turf))
			return our_turf.temperature

/obj/machinery/rnd/server/proc/get_overheat_temperature()
	return generates_heat ? server_component.overheated_temp : T0C + 100

/obj/machinery/rnd/server/proc/get_warning_temperature()
	return generates_heat ? server_component.warning_temp : T0C + 50

/obj/machinery/rnd/server/proc/get_efficiency()
	return generates_heat ? server_component.efficiency : 1

/obj/machinery/rnd/server/on_set_machine_stat(old_value)
	update_appearance(UPDATE_ICON_STATE)
	return ..()

/obj/machinery/rnd/server/no_heat
	generates_heat = FALSE
