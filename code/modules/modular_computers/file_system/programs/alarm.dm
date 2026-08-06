/datum/computer_file/program/alarm_monitor
	filename = "alarmmonitor"
	filedesc = "Alarm & Work Monitor"
	ui_header = "alarm_green.gif"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "alert-green"
	extended_desc = "This program provides a visual interface for the station's alarm system, and \
lists outstanding engineering work orders raised against it."
	requires_ntnet = TRUE
	network_destination = "alarm monitoring network"
	size = 4
	tgui_id = "NtosStationAlertConsole"
	program_icon = "bell"
	power_consumption = 50 WATT
	// Can it raise annoying notifications, see /obj/item/modular_computer/proc/alert_call()
	alert_able = TRUE
	/// If there is any station alert
	var/has_alert = FALSE
	/// Station alert datum for showing alerts UI
	var/datum/station_alert/alert_control

/datum/computer_file/program/alarm_monitor/New()
	//We want to send an alarm if we're in one of the mining home areas
	//Or if we're on station. Otherwise, die.
	var/list/allowed_areas = GLOB.the_station_areas + typesof(/area/mine)
	alert_control = new(computer, list(ALARM_ATMOS, ALARM_FIRE, ALARM_POWER), listener_areas = allowed_areas)
	RegisterSignals(alert_control.listener, list(COMSIG_ALARM_TRIGGERED, COMSIG_ALARM_CLEARED), PROC_REF(update_alarm_display))
	SSwork_orders.monitors += src
	return ..()

/datum/computer_file/program/alarm_monitor/Destroy()
	SSwork_orders.monitors -= src
	QDEL_NULL(alert_control)
	return ..()

/// Announces new raised jobs. Push it to installed monitors. I deliberately left this off process_tick() so it works on programs not opened.
/datum/computer_file/program/alarm_monitor/proc/notify_new_orders(count)
	if(!computer?.enabled)
		return
	// Badge it on the main menu too, in case the beep was missed.
	alert_pending = TRUE
	computer.alert_call(src, "[count] new work order[count > 1 ? "s" : ""].", 'sound/machines/ping.ogg')

/datum/computer_file/program/alarm_monitor/on_start(mob/living/user)
	. = ..()
	alert_pending = FALSE

/datum/computer_file/program/alarm_monitor/process_tick()
	..()

	if(has_alert)
		program_icon_state = "alert-red"
		ui_header = "alarm_red.gif"
		update_computer_icon()
	else
		if(!has_alert)
			program_icon_state = "alert-green"
			ui_header = "alarm_green.gif"
			update_computer_icon()
	return 1

/datum/computer_file/program/alarm_monitor/ui_static_data(mob/user)
	var/list/data = list()
	data += alert_control.ui_static_data(user)
	return data

/datum/computer_file/program/alarm_monitor/ui_data(mob/user)
	var/list/data = list()
	// Drop it from a PDA
	data["full_capability"] = !istype(computer, /obj/item/modular_computer/tablet/pda)
	data += alert_control.ui_data(user)
	return data

/datum/computer_file/program/alarm_monitor/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return
	return alert_control.ui_act(action, params, ui, state)

/datum/computer_file/program/alarm_monitor/proc/update_alarm_display()
	SIGNAL_HANDLER
	has_alert = FALSE
	if(length(alert_control.listener.alarms))
		has_alert = TRUE
