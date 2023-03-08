/datum/computer_file/program/revelation
	filename = "revelation"
	filedesc = "Revelation"
	category = PROGRAM_CATEGORY_MISC
	program_icon_state = "hostile"
	extended_desc = "This virus can destroy hard drive of system it is executed on. It may be obfuscated to look like another non-malicious program. Once armed, it will destroy the system upon next execution."
	size = 13
	requires_ntnet = FALSE
	available_on_ntnet = FALSE
	available_on_syndinet = TRUE
	tgui_id = "NtosRevelation"
	program_icon = "magnet"
	var/armed = 0

/datum/computer_file/program/revelation/on_start(mob/living/user)
	. = ..()
	if(!.)
		return
	if(armed)
		activate()

/datum/computer_file/program/revelation/proc/activate()
	if(computer)
		if(istype(computer, /obj/item/modular_computer/tablet/integrated)) //If this is a borg's integrated tablet
			var/obj/item/modular_computer/tablet/integrated/modularInterface = computer
			to_chat(modularInterface.borgo,"<span class='userdanger'>SYSTEM PURGE DETECTED/</span>")
			addtimer(CALLBACK(modularInterface.borgo, TYPE_PROC_REF(/mob/living/silicon/robot, death)), 2 SECONDS, TIMER_UNIQUE)
			return

		computer.visible_message("<span class='notice'>\The [computer]'s screen brightly flashes and loud electrical buzzing is heard.</span>")
		computer.enabled = FALSE
		computer.update_icon()
		var/obj/item/computer_hardware/hard_drive/hard_drive = computer.all_components[MC_HDD]
		var/obj/item/computer_hardware/battery/battery_module = computer.all_components[MC_CELL]
		var/obj/item/computer_hardware/recharger/recharger = computer.all_components[MC_CHARGE]
		qdel(hard_drive)
		computer.take_damage(25, BRUTE, 0, 0)
		if(battery_module && prob(25))
			qdel(battery_module)
			computer.visible_message("<span class='notice'>\The [computer]'s battery explodes in rain of sparks.</span>")
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
			spark_system.start()

		if(recharger && prob(50))
			qdel(recharger)
			computer.visible_message("<span class='notice'>\The [computer]'s recharger explodes in rain of sparks.</span>")
			var/datum/effect_system/spark_spread/spark_system = new /datum/effect_system/spark_spread
			spark_system.start()


/datum/computer_file/program/revelation/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("PRG_arm")
			armed = !armed
			return TRUE
		if("PRG_activate")
			activate()
			return TRUE
		if("PRG_obfuscate")
			var/newname = params["new_name"]
			if(!newname)
				return
			filedesc = newname
			return TRUE


/datum/computer_file/program/revelation/clone()
	var/datum/computer_file/program/revelation/temp = ..()
	temp.armed = armed
	return temp

/datum/computer_file/program/revelation/ui_data(mob/user)
	var/list/data = get_header_data()

	data["armed"] = armed

	return data
