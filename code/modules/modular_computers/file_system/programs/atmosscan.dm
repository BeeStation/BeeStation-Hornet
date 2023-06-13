/datum/computer_file/program/atmosscan
	filename = "atmosscan"
	filedesc = "Atmospheric Scanner"
	category = PROGRAM_CATEGORY_ENGI
	program_icon_state = "atmos_control"
	extended_desc = "A small built-in sensor reads out the atmospheric conditions around the device."
	network_destination = "atmos scan"
	size = 4
	tgui_id = "NtosAtmos"
	program_icon = "thermometer-half"

/datum/computer_file/program/atmosscan/on_start(mob/living/user)
	. = ..()
	if (!.)
		return
	if(!computer?.get_modular_computer_part(MC_SENSORS)) //Giving a clue to users why the program is spitting out zeros.
		to_chat(user, "<span class='warning'>\The [computer] flashes an error: \"hardware\\sensorpackage\\startup.bin -- file not found\".</span>")


/datum/computer_file/program/atmosscan/ui_data(mob/user)
	var/list/data = list()
	var/list/airlist = list()
	var/turf/T = get_turf(computer.ui_host())
	var/obj/item/computer_hardware/sensorpackage/sensors = computer?.get_modular_computer_part(MC_SENSORS)
	if(T && sensors?.check_functionality())
		var/datum/gas_mixture/environment = T.return_air()
		var/pressure = environment.return_pressure()
		var/total_moles = environment.total_moles()
		data["AirPressure"] = round(pressure,0.1)
		data["AirTempC"] = round(environment.return_temperature() - T0C)
		data["AirTempK"] = round(environment.return_temperature())
		if (total_moles)
			for(var/id in environment.get_gases())
				var/gas_level = environment.get_moles(id)/total_moles
				if(gas_level > 0)
					airlist += list(list("name" = "[GLOB.gas_data.names[id]]", "percentage" = round(gas_level*100, 0.01)))
		data["AirData"] = airlist
	else
		data["AirPressure"] = 0
		data["AirTempC"] = 0
		data["AirTempK"] = 0
		data["AirData"] = list(list())
	return data

/datum/computer_file/program/atmosscan/ui_act(action, list/params)
	if(..())
		return TRUE
