/obj/machinery/computer/shuttle
	name = "shuttle console"
	desc = "A shuttle control computer."
	icon_screen = "shuttle"
	icon_keyboard = "tech_key"
	light_color = LIGHT_COLOR_CYAN
	req_access = list( )
	var/shuttleId
	var/possible_destinations = ""
	var/admin_controlled
	var/no_destination_swap = 0

/obj/machinery/computer/shuttle/ui_interact(mob/user)
	//Ash walkers cannot use the console because they are unga bungas
	if(user.mind?.has_antag_datum(/datum/antagonist/ashwalker))
		to_chat(user, "<span class='warning'>This computer has been designed to keep the natives like you from meddling with it, you have no hope of using it.</span>")
		return
	. = ..()
	var/list/options = params2list(possible_destinations)
	var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
	var/dat = "Status: [M ? M.getStatusText() : "*Missing*"]<br><br>"
	if(M)
		var/destination_found
		for(var/obj/docking_port/stationary/S in SSshuttle.stationary)
			if(!options.Find(S.id))
				continue
			if(!M.check_dock(S, silent=TRUE))
				continue
			destination_found = 1
			dat += "<A href='?src=[REF(src)];move=[S.id]'>Send to [S.name]</A><br>"
		if(!destination_found)
			dat += "<B>Shuttle Locked</B><br>"
			if(admin_controlled)
				dat += "Authorized personnel only<br>"
				dat += "<A href='?src=[REF(src)];request=1]'>Request Authorization</A><br>"
	dat += "<a href='?src=[REF(user)];mach_close=computer'>Close</a>"

	var/datum/browser/popup = new(user, "computer", M ? M.name : "shuttle", 300, 200)
	popup.set_content("<center>[dat]</center>")
	popup.open()

/obj/machinery/computer/shuttle/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(!allowed(usr))
		to_chat(usr, "<span class='danger'>Access denied.</span>")
		return

	if(href_list["move"])
		var/obj/docking_port/mobile/M = SSshuttle.getShuttle(shuttleId)
		if(M.launch_status == ENDGAME_LAUNCHED)
			to_chat(usr, "<span class='warning'>You've already escaped. Never going back to that place again!</span>")
			return
		if(no_destination_swap)
			if(M.mode == SHUTTLE_RECHARGING)
				to_chat(usr, "<span class='warning'>Shuttle engines are not ready for use.</span>")
				return
			if(M.mode != SHUTTLE_IDLE)
				to_chat(usr, "<span class='warning'>Shuttle already in transit.</span>")
				return
		if(!(href_list["move"] in params2list(possible_destinations)))
			log_admin("[usr] attempted to forge a target location through a href exploit on [src]")
			message_admins("[ADMIN_FULLMONTY(usr)] attempted to forge a target location through a href exploit on [src]")
			return
		switch(SSshuttle.moveShuttle(shuttleId, href_list["move"], 1))
			if(0)
				say("Shuttle departing. Please stand away from the doors.")
			if(1)
				to_chat(usr, "<span class='warning'>Invalid shuttle requested.</span>")
			else
				to_chat(usr, "<span class='notice'>Unable to comply.</span>")

/obj/machinery/computer/shuttle/emag_act(mob/user)
	if(obj_flags & EMAGGED)
		return
	req_access = list()
	obj_flags |= EMAGGED
	to_chat(user, "<span class='notice'>You fried the consoles ID checking system.</span>")

/obj/machinery/computer/shuttle/connect_to_shuttle(obj/docking_port/mobile/port, obj/docking_port/stationary/dock, idnum, override=FALSE)
	if(port && (shuttleId == initial(shuttleId) || override))
		shuttleId = port.id
