/*
	Telecommunications Monitoring Console displays the status of the telecommunications network it's connected to.
*/

/obj/machinery/computer/telecomms/monitor
	name = "telecommunications monitoring console"
	icon_screen = "comm_monitor"
	desc = "Monitors the details of the telecommunications network it's synced with."
	circuit = /obj/item/circuitboard/computer/comm_monitor

	/// The network to monitor
	network_id = "tcommsat"

/obj/machinery/computer/telecomms/monitor/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Telemonitor")
		ui.set_autoupdate(TRUE)
		ui.open()

/obj/machinery/computer/telecomms/monitor/ui_data(mob/user)
	var/list/data = list()

	data["network_id"] = network_id
	data["current_time"] = world.time

	data["servers"] = list()
	for(var/obj/machinery/telecomms/machine as anything in GLOB.telecomms_list)
		if(!istype(machine, /obj/machinery/telecomms))
			continue
		if(machine.network != network_id)
			continue

		// Get thermal data from server component
		var/temperature = machine.get_temperature()
		var/efficiency = machine.get_efficiency()
		var/overheat_temp = machine.get_overheat_temperature()
		var/overheated = (machine.machine_stat & OVERHEATED) ? TRUE : FALSE

		// Calculate last_update based on machine status - offline machines show stale timestamp
		var/last_update = world.time
		if(machine.machine_stat & (NOPOWER|BROKEN))
			last_update = world.time - 100 // 10 seconds ago = shows as offline

		data["servers"] += list(list(
			"name" = machine.name,
			"sender_id" = machine.id,
			"temperature" = temperature,
			"overheat_temperature" = overheat_temp,
			"efficiency" = efficiency,
			"last_update" = last_update,
			"overheated" = overheated,
		))
	return data

/obj/machinery/computer/telecomms/monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	switch(action)
		if("change_network")
			network_id = params["network_name"]
			. = TRUE
