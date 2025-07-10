/datum/wires/robot
	holder_type = /mob/living/silicon/robot
	randomize = TRUE

/datum/wires/robot/New(atom/holder)
	wires = list(
		WIRE_AI, WIRE_CAMERA,
		WIRE_LAWSYNC, WIRE_LOCKDOWN,
		WIRE_RESET_MODEL
	)
	add_duds(2)
	..()

/datum/wires/robot/interactable(mob/user)
	if(!..())
		return FALSE
	var/mob/living/silicon/robot/robot = holder
	if(robot.wiresexposed)
		return TRUE

/datum/wires/robot/get_status()
	var/mob/living/silicon/robot/robot = holder
	var/list/status = list()
	status += "The law sync module is [robot.lawupdate ? "on" : "off"]."
	status += "The intelligence link display shows [robot.connected_ai ? robot.connected_ai.name : "NULL"]."
	status += "The camera light is [!isnull(robot.builtInCamera) && robot.builtInCamera.status ? "on" : "off"]."
	status += "The lockdown indicator is [robot.lockcharge ? "on" : "off"]."
	status += "The [get_color_of_wire(WIRE_RESET_MODEL)] wire is marked 'reset'."
	return status

/datum/wires/robot/on_pulse(wire, user)
	var/mob/living/silicon/robot/robot = holder
	switch(wire)
		if(WIRE_AI) // Pulse to pick a new AI.
			if(!robot.emagged)
				var/new_ai
				if(user)
					new_ai = select_active_ai(user)
				else
					new_ai = select_active_ai(robot)
				robot.notify_ai(DISCONNECT)
				if(new_ai && (new_ai != robot.connected_ai))
					log_combat(usr, robot, "synced cyborg [robot.connected_ai ? "from [ADMIN_LOOKUP(robot.connected_ai)]": "false"] to [ADMIN_LOOKUP(new_ai)]", important = FALSE)
					robot.connected_ai = new_ai
					if(robot.shell)
						robot.undeploy() //If this borg is an AI shell, disconnect the controlling AI and assign ti to a new AI
						robot.notify_ai(AI_SHELL)
					else
						robot.notify_ai(TRUE)
		if(WIRE_CAMERA) // Pulse to disable the camera.
			if(!QDELETED(robot.builtInCamera) && !robot.scrambledcodes)
				robot.builtInCamera.toggle_cam(usr, FALSE)
				robot.visible_message("[robot]'s camera lens focuses loudly.", "Your camera lens focuses loudly.")
				log_combat(usr, robot, "toggled cyborg camera to [robot.builtInCamera.status ? "on" : "off"] via pulse", important = FALSE)
		if(WIRE_LAWSYNC) // Forces a law update if possible.
			if(robot.lawupdate)
				robot.visible_message("[robot] gently chimes.", "LawSync protocol engaged.")
				log_combat(usr, robot, "forcibly synced cyborg laws via pulse", important = FALSE)
				// TODO, log the laws they gained here
				robot.lawsync()
				robot.show_laws()
		if(WIRE_LOCKDOWN)
			robot.SetLockdown(!robot.lockcharge) // Toggle
			log_combat(usr, robot, "[!robot.lockcharge ? "locked down" : "released"] via pulse", important = FALSE)
		if(WIRE_RESET_MODEL)
			if(robot.has_model())
				robot.ResetModel()
				if (user)
					log_combat(user, robot, "reset the cyborg module via wire", important = FALSE)
	ui_update()

/datum/wires/robot/on_cut(wire, mob/user, mend)
	var/mob/living/silicon/robot/robot = holder
	switch(wire)
		if(WIRE_AI) // Cut the AI wire to reset AI control.
			if(!mend)
				robot.notify_ai(DISCONNECT)
				if (user)
					log_combat(user, robot, "cut AI wire on cyborg[robot.connected_ai ? " and disconnected from [ADMIN_LOOKUP(robot.connected_ai)]": ""]", important = FALSE)
				if(robot.shell)
					robot.undeploy()
				robot.connected_ai = null
			robot.logevent("AI connection fault [mend?"cleared":"detected"]")
		if(WIRE_LAWSYNC) // Cut the law wire, and the borg will no longer receive law updates from its AI. Repair and it will re-sync.
			if(mend)
				if(!robot.emagged)
					robot.lawupdate = TRUE
					if (user)
						log_combat(user, robot, "enabled lawsync via wire", important = FALSE)
			else if(!robot.deployed) //AI shells must always have the same laws as the AI
				robot.lawupdate = FALSE
				if (user)
					log_combat(user, robot, "disabled lawsync via wire")
			robot.logevent("Lawsync Module fault [mend ? "cleared" : "detected"]")
		if (WIRE_CAMERA) // Disable the camera.
			if(!QDELETED(robot.builtInCamera) && !robot.scrambledcodes)
				robot.builtInCamera.status = mend
				robot.builtInCamera.toggle_cam(user, FALSE)
				robot.visible_message("[robot]'s camera lens focuses loudly.", "Your camera lens focuses loudly.")
				robot.logevent("Camera Module fault [mend?"cleared":"detected"]")
				if (user)
					log_combat(user, robot, "[mend ? "enabled" : "disabled"] cyborg camera via wire")
		if(WIRE_LOCKDOWN) // Simple lockdown.
			robot.SetLockdown(!mend)
			robot.logevent("Motor Controller fault [mend?"cleared":"detected"]")
			if (user)
				log_combat(user, robot, "[!robot.lockcharge ? "locked down" : "released"] via wire", important = FALSE)
		if(WIRE_RESET_MODEL)
			if(robot.has_model() && !mend)
				robot.ResetModel()
				if (user)
					log_combat(user, robot, "reset the cyborg module via wire", important = FALSE)
	ui_update()
