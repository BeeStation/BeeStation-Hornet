/datum/wires/airlock
	holder_type = /obj/machinery/door/airlock
	proper_name = "Airlock"
	randomize = TRUE
	var/security_level = 0

/datum/wires/airlock/New(atom/holder, security_level)
	//Set the default wires
	wires = list(
		WIRE_POWER1,
		WIRE_BACKUP1,
		WIRE_OPEN, WIRE_BOLTS, WIRE_IDSCAN, WIRE_AI,
		WIRE_SHOCK, WIRE_SAFETY, WIRE_TIMING, WIRE_LIGHT,
	)
	src.security_level = security_level
	//Add more power wires
	if (security_level <= AIRLOCK_WIRE_SECURITY_ELITE)
		wires |= WIRE_POWER2
		wires |= WIRE_BACKUP2
	//Add zap wires
	if (security_level >= AIRLOCK_WIRE_SECURITY_PROTECTED)
		wires |= WIRE_ZAP1
	if (security_level >= AIRLOCK_WIRE_SECURITY_ELITE)
		wires |= WIRE_ZAP2
	//Add dud wires
	if (security_level >= AIRLOCK_WIRE_SECURITY_MAXIMUM)
		add_duds(2)
	else if (security_level >= AIRLOCK_WIRE_SECURITY_ADVANCED)
		add_duds(1)

	//Add labelled wires
	if (security_level <= AIRLOCK_WIRE_SECURITY_NONE)
		labelled_wires[WIRE_POWER1] = TRUE
		labelled_wires[WIRE_BACKUP1] = TRUE
		labelled_wires[WIRE_LIGHT] = TRUE
		labelled_wires[WIRE_OPEN] = TRUE
	if (security_level <= AIRLOCK_WIRE_SECURITY_SIMPLE)
		labelled_wires[WIRE_SAFETY] = TRUE
		labelled_wires[WIRE_TIMING] = TRUE
		labelled_wires[WIRE_SHOCK] = TRUE
		labelled_wires[WIRE_IDSCAN] = TRUE
	if (security_level <= AIRLOCK_WIRE_SECURITY_PROTECTED)
		labelled_wires[WIRE_ZAP1] = TRUE
	if (security_level <= AIRLOCK_WIRE_SECURITY_ADVANCED)
		labelled_wires[WIRE_BOLTS] = TRUE
		labelled_wires[WIRE_AI] = TRUE
	..()

/datum/wires/airlock/interact(mob/user)
	var/obj/machinery/door/airlock/airlock_holder = holder
	if (!issilicon(user) && airlock_holder.isElectrified() && airlock_holder.shock(user, 100))
		return

	return ..()

/datum/wires/airlock/interactable(mob/user)
	if(!..())
		return FALSE
	var/obj/machinery/door/airlock/A = holder
	if(!issilicon(user) && A.isElectrified())
		var/mob/living/carbon/carbon_user = user
		if (!istype(carbon_user) || carbon_user.should_electrocute(src))
			return FALSE
	if(A.panel_open)
		return TRUE

/datum/wires/airlock/get_status()
	var/obj/machinery/door/airlock/A = holder
	var/list/status = list()
	status += "The door bolts [A.locked ? "have fallen!" : "look up."]"
	status += "The test light is [A.hasPower() ? (A.isElectrified() ? "bright and flicking" : "on") : "off"]."
	status += "The AI connection light is [A.aiControlDisabled ? "off" : "on"]."
	status += "The check wiring light is [A.safe ? "off" : "on"]."
	status += "The timer is powered [A.autoclose ? "on" : "off"]."
	status += "The speed light is [A.normalspeed ? "on" : "off"]."
	status += "The emergency light is [A.emergency ? "on" : "off"]."

	return status

/datum/wires/airlock/on_pulse(wire)
	set waitfor = FALSE
	var/obj/machinery/door/airlock/A = holder
	// Pulsing a wire while it is shocked will shock you
	if(isliving(usr) && A.hasPower() && A.isElectrified())
		if (A.shock(usr, 100))
			return
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Pulse to lose power, or reset the delay before restoring power if already lost
			A.loseMainPower()
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Pulse to lose backup power, or reset the delay before restoring power if already lost
			A.loseBackupPower()
	if(A.hasPower()) //Multitool has no effect on other wires if the door has no power
		switch(wire)
			if(WIRE_OPEN) // Pulse to open door
				if(A.id_scan_hacked() || A.check_access(null))
					if(A.density)
						INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, open))
					else
						INVOKE_ASYNC(A, TYPE_PROC_REF(/obj/machinery/door/airlock, close))
			if(WIRE_BOLTS) // Pulse to toggle bolts
				if(!A.locked)
					A.bolt()
				else
					A.unbolt()
				A.update_icon()
			if(WIRE_IDSCAN) // Pulse to disable emergency access and flash red lights.
				if(A.hasPower() && A.density)
					A.do_animate("deny")
					if(A.emergency)
						A.emergency = FALSE
						A.update_icon()
			if(WIRE_AI) // Pulse to disable WIRE_AI control for 10 ticks (follows same rules as cutting).
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
				addtimer(CALLBACK(A, TYPE_PROC_REF(/obj/machinery/door/airlock, reset_ai_wire)), 1 SECONDS)
			if(WIRE_SHOCK) // Pulse to shock the door for 10 ticks.
				if(!A.secondsElectrified)
					A.set_electrified(MACHINE_DEFAULT_ELECTRIFY_TIME, usr)
					A.shock(usr, 100)
			if(WIRE_SAFETY)
				A.safe = !A.safe
				if(!A.density)
					A.close()
			if(WIRE_TIMING)
				A.normalspeed = !A.normalspeed
			if(WIRE_LIGHT)
				A.lights = !A.lights
				A.update_icon()
			if(WIRE_ZAP1, WIRE_ZAP2) // Doors have a lot of power coursing through them, even a multitool can be overloaded on the wrong wires
				if(isliving(usr))
					A.shock(usr, 100)
	ui_update()
	A.ui_update()

/obj/machinery/door/airlock/proc/reset_ai_wire()
	if(aiControlDisabled == 1)
		aiControlDisabled = 0
	else if(aiControlDisabled == 2)
		aiControlDisabled = -1
	wires.ui_update()
	ui_update()

/datum/wires/airlock/on_cut(wire, mob/user, mend)
	var/obj/machinery/door/airlock/A = holder
	switch(wire)
		if(WIRE_POWER1, WIRE_POWER2) // Cut to loose power, repair all to gain power.
			if(mend && !is_cut(WIRE_POWER1) && !is_cut(WIRE_POWER2))
				A.regainMainPower()
			else
				A.loseMainPower()
			if(isliving(user))
				A.shock(user, 50)
		if(WIRE_BACKUP1, WIRE_BACKUP2) // Cut to loose backup power, repair all to gain backup power.
			if(mend && !is_cut(WIRE_BACKUP1) && !is_cut(WIRE_BACKUP2))
				A.regainBackupPower()
			else
				A.loseBackupPower()
		if(WIRE_BOLTS) // Cut to drop bolts, mend does nothing.
			if(!mend)
				A.bolt()
		if(WIRE_AI) // Cut to disable WIRE_AI control, mend to re-enable.
			if(mend)
				if(A.aiControlDisabled == 1) // 0 = normal, 1 = locked out, 2 = overridden by WIRE_AI, -1 = previously overridden by WIRE_AI
					A.aiControlDisabled = 0
				else if(A.aiControlDisabled == 2)
					A.aiControlDisabled = -1
			else
				if(A.aiControlDisabled == 0)
					A.aiControlDisabled = 1
				else if(A.aiControlDisabled == -1)
					A.aiControlDisabled = 2
		if(WIRE_SHOCK) // Cut to shock the door, mend to unshock.
			if(mend)
				if(A.secondsElectrified)
					A.set_electrified(MACHINE_NOT_ELECTRIFIED, user)
			else
				if(A.secondsElectrified != MACHINE_ELECTRIFIED_PERMANENT)
					A.set_electrified(MACHINE_ELECTRIFIED_PERMANENT, user)
					A.shock(usr, 100)
			if(isliving(user))
				A.shock(user, 50)
		if(WIRE_SAFETY) // Cut to disable safeties, mend to re-enable.
			A.safe = mend
		if(WIRE_TIMING) // Cut to disable auto-close, mend to re-enable.
			A.autoclose = mend
			if(A.autoclose && !A.density)
				A.close()
		if(WIRE_LIGHT) // Cut to disable lights, mend to re-enable.
			A.lights = mend
			A.update_icon()
	ui_update()
	A.ui_update()
