//modular computer program version is located in code\modules\modular_computers\file_system\programs\powermonitor.dm, /datum/computer_file/program/power_monitor

/obj/machinery/computer/monitor
	name = "power monitoring console"
	desc = "It monitors power levels across the station."
	icon_screen = "power"
	icon_keyboard = "power_key"
	light_color = LIGHT_COLOR_DIM_YELLOW
	use_power = ACTIVE_POWER_USE
	idle_power_usage = 20
	active_power_usage = 100
	circuit = /obj/item/circuitboard/computer/powermonitor

	var/datum/weakref/attached_wire_ref
	var/datum/weakref/local_apc_ref

	var/list/history = list()
	var/record_size = 60
	var/record_interval = 5 SECONDS
	COOLDOWN_DECLARE(record_cooldown)

/obj/machinery/computer/monitor/secret //Hides the power monitor (such as ones on ruins & CentCom) from PDA's to prevent metagaming.
	name = "outdated power monitoring console"
	desc = "It monitors power levels across the local powernet."
	circuit = /obj/item/circuitboard/computer/powermonitor/secret

/obj/machinery/computer/monitor/secret/examine(mob/user)
	. = ..()
	. += span_notice("It's operating system seems quite outdated... It doesn't seem like it'd be compatible with the latest remote NTOS monitoring systems.")

/obj/machinery/computer/monitor/Initialize(mapload)
	. = ..()
	search()
	history["supply"] = list()
	history["demand"] = list()

/obj/machinery/computer/monitor/process()
	if(!get_powernet())
		update_use_power(IDLE_POWER_USE)
		search()
	else
		update_use_power(ACTIVE_POWER_USE)
		record()

/obj/machinery/computer/monitor/proc/search() //keep in sync with /datum/computer_file/program/power_monitor's version
	var/turf/our_turf = get_turf(src)
	attached_wire_ref = WEAKREF(locate(/obj/structure/cable) in our_turf)
	if(attached_wire_ref)
		return
	var/area/our_area = get_area(src) //if the computer isn't directly connected to a wire, attempt to find the APC powering it to pull it's powernet instead
	if(!our_area)
		return
	var/obj/machinery/power/apc/local_apc = our_area.apc
	if(!local_apc)
		return
	if(!local_apc.terminal) //this really shouldn't happen without badminnery.
		local_apc = null
	local_apc_ref = WEAKREF(local_apc)

/obj/machinery/computer/monitor/proc/get_powernet() //keep in sync with /datum/computer_file/program/power_monitor's version //np
	var/obj/structure/cable/attached_wire = attached_wire_ref?.resolve()
	var/obj/machinery/power/apc/local_apc = local_apc_ref?.resolve()
	return attached_wire?.powernet || local_apc?.terminal?.powernet

/obj/machinery/computer/monitor/proc/record() //keep in sync with /datum/computer_file/program/power_monitor's version
	if(!COOLDOWN_FINISHED(src, record_cooldown))
		return
	COOLDOWN_START(src, record_cooldown, record_interval)

	var/datum/powernet/connected_powernet = get_powernet()

	var/list/supply = history["supply"]
	if(connected_powernet)
		supply += connected_powernet.viewavail
	if(supply.len > record_size)
		supply.Cut(1, 2)

	var/list/demand = history["demand"]
	if(connected_powernet)
		demand += connected_powernet.viewload
	if(demand.len > record_size)
		demand.Cut(1, 2)

/obj/machinery/computer/monitor/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "PowerMonitor")
		ui.open()
		ui.set_autoupdate(TRUE) // Power in powernet

/obj/machinery/computer/monitor/ui_data()
	var/datum/powernet/connected_powernet = get_powernet()
	var/list/data = list()
	data["stored"] = record_size
	data["interval"] = record_interval / 10
	data["attached"] = !!connected_powernet
	data["history"] = history
	data["areas"] = list()

	if(connected_powernet)
		data["supply"] = display_power_persec(connected_powernet.viewavail)
		data["demand"] = display_power_persec(connected_powernet.viewload)
		for(var/obj/machinery/power/terminal/term in connected_powernet.nodes)
			var/obj/machinery/power/apc/A = term.master
			if(istype(A))
				var/cell_charge
				if(!A.cell)
					cell_charge = 0
				else if(A.integration_cog)
					cell_charge = 100
				else
					cell_charge = A.cell.percent()
				data["areas"] += list(list(
					"name" = A.area.name,
					"charge" = cell_charge,
					"load" = display_power_persec(A.lastused_total),
					"charging" = A.integration_cog ? 2 : A.charging,
					"eqp" = A.equipment,
					"lgt" = A.lighting,
					"env" = A.environ
				))

	return data
