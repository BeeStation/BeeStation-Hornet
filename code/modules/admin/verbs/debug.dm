/client/proc/Debug2()
	set category = "Debug"
	set name = "Debug-Game"
	if(!check_rights(R_DEBUG))
		return

	if(GLOB.Debug2)
		GLOB.Debug2 = 0
		message_admins("[key_name(src)] toggled debugging off.")
		log_admin("[key_name(src)] toggled debugging off.")
	else
		GLOB.Debug2 = 1
		message_admins("[key_name(src)] toggled debugging on.")
		log_admin("[key_name(src)] toggled debugging on.")

	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Debug Two") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!



/* 21st Sept 2010
Updated by Skie -- Still not perfect but better!
Stuff you can't do:
Call proc /mob/proc/Dizzy() for some player
Because if you select a player mob as owner it tries to do the proc for
/mob/living/carbon/human/ instead. And that gives a run-time error.
But you can call procs that are of type /mob/living/carbon/human/proc/ for that player.
*/

/client/proc/Cell()
	set category = "Debug"
	set name = "Air Status in Location"
	if(!mob)
		return
	var/turf/user_turf = get_turf(mob)
	if(!isturf(user_turf))
		return
	atmos_scan(mob, user_turf, TRUE)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Air Status In Location") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_robotize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Robot"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has robotized [M.key].")
		var/mob/living/carbon/human/H = M
		spawn(0)
			H.Robotize()

	else
		alert("Invalid mob")

/client/proc/cmd_admin_blobize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Blob"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		log_admin("[key_name(src)] has blobized [M.key].")
		var/mob/living/carbon/human/H = M
		H.become_overmind()
	else
		alert("Invalid mob")


/client/proc/cmd_admin_animalize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Simple Animal"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return

	if(!M)
		alert("That mob doesn't seem to exist, close the panel and try again.")
		return

	if(isnewplayer(M))
		alert("The mob must not be a new_player.")
		return

	log_admin("[key_name(src)] has animalized [M.key].")
	spawn(0)
		M.Animalize()


/client/proc/makepAI(turf/T in GLOB.mob_list)
	set category = "Fun"
	set name = "Make pAI"
	set desc = "Specify a location to spawn a pAI device, then specify a ckey to play that pAI"

	var/list/available = list()
	for(var/mob/C in GLOB.mob_list)
		if(C.ckey)
			available.Add(C)
	var/mob/choice = input("Choose a player to play the pAI", "Spawn pAI") in sort_names(available)
	if(!choice)
		return
	if(!isobserver(choice))
		var/confirm = input("[choice.ckey] isn't ghosting right now. Are you sure you want to yank him out of them out of their body and place them in this pAI?", "Spawn pAI Confirmation", "No") in list("Yes", "No")
		if(confirm != "Yes")
			return
	var/obj/item/paicard/card = new(T)
	var/mob/living/silicon/pai/pai = new(card)
	pai.name = capped_input(choice, "Enter your pAI name:", "pAI Name", "Personal AI")
	pai.real_name = pai.name
	pai.ckey = choice.ckey
	card.setPersonality(pai)
	SSpai.candidates.Remove(SSpai.candidates[choice.ckey])
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make pAI") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_alienize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make Alien"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/Alienize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Alien") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into an alien at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into an alien."))
	else
		alert("Invalid mob")

/client/proc/cmd_admin_slimeize(mob/M in GLOB.mob_list)
	set category = "Fun"
	set name = "Make slime"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		INVOKE_ASYNC(M, /mob/living/carbon/human/proc/slimeize)
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Slime") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
		log_admin("[key_name(usr)] made [key_name(M)] into a slime at [AREACOORD(M)].")
		message_admins(span_adminnotice("[key_name_admin(usr)] made [ADMIN_LOOKUPFLW(M)] into a slime."))
	else
		alert("Invalid mob")


//TODO: merge the vievars version into this or something maybe mayhaps
/client/proc/cmd_debug_del_all(object as text)
	set category = "Debug"
	set name = "Del-All"

	var/list/matches = get_fancy_list_of_atom_types()
	if (!isnull(object) && object!="")
		matches = filter_fancy_list(matches, object)

	if(matches.len==0)
		return
	var/hsbitem = input(usr, "Choose an object to delete.", "Delete:") as null|anything in sort_list(matches)
	if(hsbitem)
		hsbitem = matches[hsbitem]
		var/counter = 0
		for(var/atom/O in world)
			if(istype(O, hsbitem))
				counter++
				qdel(O)
			CHECK_TICK
		log_admin("[key_name(src)] has deleted all ([counter]) instances of [hsbitem].")
		message_admins("[key_name_admin(src)] has deleted all ([counter]) instances of [hsbitem].")
		SSblackbox.record_feedback("tally", "admin_verb", 1, "Delete All") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!


/client/proc/cmd_debug_make_powernets()
	set category = "Debug"
	set name = "Make Powernets"
	SSmachines.makepowernets()
	log_admin("[key_name(src)] has remade the powernet. makepowernets() called.")
	message_admins("[key_name_admin(src)] has remade the powernets. makepowernets() called.")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Make Powernets") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_grantfullaccess(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Grant Full Access"

	if(!SSticker.HasRoundStarted())
		alert("Wait until the game starts")
		return
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		var/obj/item/worn = H.wear_id
		var/obj/item/card/id/id = null
		if(worn)
			id = worn.GetID()
		if(id)
			id.icon_state = "gold"
			id.access |= get_every_access()
		else
			id = new /obj/item/card/id/gold(H.loc)
			id.access |= get_every_access()
			id.registered_name = H.real_name
			id.assignment = JOB_NAME_CAPTAIN
			id.update_label()

			if(worn)
				if(istype(worn, /obj/item/modular_computer/tablet/pda))
					var/obj/item/modular_computer/tablet/pda/PDA = worn
					var/obj/item/computer_hardware/card_slot/card = PDA.all_components[MC_CARD]
					qdel(card.stored_card)
					if(card)
						card.try_insert(id, H)
				else if(istype(worn, /obj/item/storage/wallet))
					var/obj/item/storage/wallet/W = worn
					W.front_id = id
					id.forceMove(W)
					W.update_icon()
			else
				H.equip_to_slot(id,ITEM_SLOT_ID)

	else
		alert("Invalid mob")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Grant Full Access") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
	log_admin("[key_name(src)] has granted [M.key] full access.")
	message_admins(span_adminnotice("[key_name_admin(usr)] has granted [M.key] full access."))

/client/proc/cmd_assume_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Assume direct control"
	set desc = "Direct intervention"

	if(M.ckey)
		if(alert("This mob is being controlled by [M.key]. Are you sure you wish to assume control of it? [M.key] will be made a ghost.",,"Yes","No") != "Yes")
			return
		else
			var/mob/dead/observer/ghost = new/mob/dead/observer(M,1)
			ghost.ckey = M.ckey
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists."))
		return
	message_admins(span_adminnotice("[key_name_admin(usr)] assumed direct control of [M]."))
	log_admin("[key_name(usr)] assumed direct control of [M].")
	var/mob/adminmob = mob
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = ckey
	if(isobserver(adminmob))
		qdel(adminmob)
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Assume Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_give_direct_control(mob/M in GLOB.mob_list)
	set category = "Admin"
	set name = "Give direct control"

	if(!M)
		return
	if(M.ckey)
		if(alert("This mob is being controlled by [M.key]. Are you sure you wish to give someone else control of it? [M.key] will be made a ghost.",,"Yes","No") != "Yes")
			return
	var/client/newkey = input(src, "Pick the player to put in control.", "New player") as null|anything in sort_list(GLOB.clients)
	var/mob/oldmob = newkey.mob
	var/delmob = FALSE
	if((isobserver(oldmob) || alert("Do you want to delete [newkey]'s old mob?","Delete?","Yes","No") != "No"))
		delmob = TRUE
	if(!M || QDELETED(M))
		to_chat(usr, span_warning("The target mob no longer exists, aborting."))
		return
	if(M.ckey)
		M.ghostize(FALSE)
	M.ckey = newkey.key
	if(delmob)
		qdel(oldmob)
	message_admins(span_adminnotice("[key_name_admin(usr)] gave away direct control of [M] to [newkey]."))
	log_admin("[key_name(usr)] gave away direct control of [M] to [newkey].")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Give Direct Control") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!

/client/proc/cmd_admin_areatest(on_station)
	set category = "Mapping"
	set name = "Test Areas"

	var/list/dat = list()
	var/list/areas_all = list()
	var/list/areas_with_APC = list()
	var/list/areas_with_multiple_APCs = list()
	var/list/areas_with_air_alarm = list()
	var/list/areas_with_RC = list()
	var/list/areas_with_light = list()
	var/list/areas_with_LS = list()
	var/list/areas_with_intercom = list()
	var/list/areas_with_camera = list()
	var/list/station_areas_blacklist = typecacheof(list(/area/holodeck/rec_center, /area/shuttle, /area/engine/supermatter, /area/science/test_area, /area/space, /area/solar, /area/mine, /area/ruin, /area/asteroid))

	if(SSticker.current_state == GAME_STATE_STARTUP)
		to_chat(usr, "Game still loading, please hold!")
		return

	var/log_message
	if(on_station)
		dat += "<b>Only checking areas on station z-levels.</b><br><br>"
		log_message = "station z-levels"
	else
		log_message = "all z-levels"

	message_admins(span_adminnotice("[key_name_admin(usr)] used the Test Areas debug command checking [log_message]."))
	log_admin("[key_name(usr)] used the Test Areas debug command checking [log_message].")

	for(var/area/A as anything in GLOB.areas)
		if(on_station)
			var/turf/picked = safepick(get_area_turfs(A.type))
			if(picked && is_station_level(picked.z))
				if(!(A.type in areas_all) && !is_type_in_typecache(A, station_areas_blacklist))
					areas_all.Add(A.type)
		else if(!(A.type in areas_all))
			areas_all.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/power/apc/APC in GLOB.apcs_list)
		var/area/A = APC.area
		if(!A)
			dat += "Skipped over [APC] in invalid location, [APC.loc]."
			continue
		if(!(A.type in areas_with_APC))
			areas_with_APC.Add(A.type)
		else if(A.type in areas_all)
			areas_with_multiple_APCs.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/airalarm/AA in GLOB.machines)
		var/area/A = get_area(AA)
		if(!A) //Make sure the target isn't inside an object, which results in runtimes.
			dat += "Skipped over [AA] in invalid location, [AA.loc].<br>"
			continue
		if(!(A.type in areas_with_air_alarm))
			areas_with_air_alarm.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/requests_console/RC in GLOB.machines)
		var/area/A = get_area(RC)
		if(!A)
			dat += "Skipped over [RC] in invalid location, [RC.loc].<br>"
			continue
		if(!(A.type in areas_with_RC))
			areas_with_RC.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light/L in GLOB.machines)
		var/area/A = get_area(L)
		if(!A)
			dat += "Skipped over [L] in invalid location, [L.loc].<br>"
			continue
		if(!(A.type in areas_with_light))
			areas_with_light.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/light_switch/LS in GLOB.machines)
		var/area/A = get_area(LS)
		if(!A)
			dat += "Skipped over [LS] in invalid location, [LS.loc].<br>"
			continue
		if(!(A.type in areas_with_LS))
			areas_with_LS.Add(A.type)
		CHECK_TICK

	for(var/obj/item/radio/intercom/I in GLOB.machines)
		var/area/A = get_area(I)
		if(!A)
			dat += "Skipped over [I] in invalid location, [I.loc].<br>"
			continue
		if(!(A.type in areas_with_intercom))
			areas_with_intercom.Add(A.type)
		CHECK_TICK

	for(var/obj/machinery/camera/C in GLOB.machines)
		var/area/A = get_area(C)
		if(!A)
			dat += "Skipped over [C] in invalid location, [C.loc].<br>"
			continue
		if(!(A.type in areas_with_camera))
			areas_with_camera.Add(A.type)
		CHECK_TICK

	var/list/areas_without_APC = areas_all - areas_with_APC
	var/list/areas_without_air_alarm = areas_all - areas_with_air_alarm
	var/list/areas_without_RC = areas_all - areas_with_RC
	var/list/areas_without_light = areas_all - areas_with_light
	var/list/areas_without_LS = areas_all - areas_with_LS
	var/list/areas_without_intercom = areas_all - areas_with_intercom
	var/list/areas_without_camera = areas_all - areas_with_camera

	if(areas_without_APC.len)
		dat += "<h1>AREAS WITHOUT AN APC:</h1>"
		for(var/areatype in areas_without_APC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_with_multiple_APCs.len)
		dat += "<h1>AREAS WITH MULTIPLE APCS:</h1>"
		for(var/areatype in areas_with_multiple_APCs)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_air_alarm.len)
		dat += "<h1>AREAS WITHOUT AN AIR ALARM:</h1>"
		for(var/areatype in areas_without_air_alarm)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_RC.len)
		dat += "<h1>AREAS WITHOUT A REQUEST CONSOLE:</h1>"
		for(var/areatype in areas_without_RC)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_light.len)
		dat += "<h1>AREAS WITHOUT ANY LIGHTS:</h1>"
		for(var/areatype in areas_without_light)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_LS.len)
		dat += "<h1>AREAS WITHOUT A LIGHT SWITCH:</h1>"
		for(var/areatype in areas_without_LS)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_intercom.len)
		dat += "<h1>AREAS WITHOUT ANY INTERCOMS:</h1>"
		for(var/areatype in areas_without_intercom)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(areas_without_camera.len)
		dat += "<h1>AREAS WITHOUT ANY CAMERAS:</h1>"
		for(var/areatype in areas_without_camera)
			dat += "[areatype]<br>"
			CHECK_TICK

	if(!(areas_with_APC.len || areas_with_multiple_APCs.len || areas_with_air_alarm.len || areas_with_RC.len || areas_with_light.len || areas_with_LS.len || areas_with_intercom.len || areas_with_camera.len))
		dat += "<b>No problem areas!</b>"

	var/datum/browser/popup = new(usr, "testareas", "Test Areas", 500, 750)
	popup.set_content(dat.Join())
	popup.open()


/client/proc/cmd_admin_areatest_station()
	set category = "Mapping"
	set name = "Test Areas (STATION Z)"
	cmd_admin_areatest(TRUE)

/client/proc/cmd_admin_areatest_all()
	set category = "Mapping"
	set name = "Test Areas (ALL)"
	cmd_admin_areatest(FALSE)

/client/proc/robust_dress_shop()
	var/list/outfits = list("Naked","Custom","As Job...","As Job(Plasmaman)...", "Debug")
	var/list/paths = subtypesof(/datum/outfit) - typesof(/datum/outfit/job) - typesof(/datum/outfit/plasmaman) - typesof(/datum/outfit/debug)
	for(var/path in paths)
		var/datum/outfit/O = path //not much to initalize here but whatever
		if(initial(O.can_be_admin_equipped))
			outfits[initial(O.name)] = path

	var/dresscode = input("Select outfit", "Robust quick dress shop") as null|anything in outfits
	if(isnull(dresscode))
		return

	if(outfits[dresscode])
		dresscode = outfits[dresscode]



	if(dresscode == "As Job...")
		var/list/job_paths = subtypesof(/datum/outfit/job)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select job equipment", "Robust quick dress shop") as null|anything in sort_list(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "As Job(Plasmaman)...")
		var/list/job_paths = subtypesof(/datum/outfit/plasmaman)
		var/list/job_outfits = list()
		for(var/path in job_paths)
			var/datum/outfit/O = path
			if(initial(O.can_be_admin_equipped))
				job_outfits[initial(O.name)] = path

		dresscode = input("Select plasmaman equipment", "Robust quick dress shop") as null|anything in sort_list(job_outfits)
		dresscode = job_outfits[dresscode]
		if(isnull(dresscode))
			return

	if(dresscode == "Debug")
		dresscode = /datum/outfit/debug
		if(isnull(dresscode))
			return

	if(dresscode == "Custom")
		var/list/custom_names = list()
		for(var/datum/outfit/D in GLOB.custom_outfits)
			custom_names[D.name] = D
		var/selected_name = input("Select outfit", "Robust quick dress shop") as null|anything in sort_list(custom_names)
		dresscode = custom_names[selected_name]
		if(isnull(dresscode))
			return

	return dresscode

/client/proc/startSinglo()

	set category = "Debug"
	set name = "Start Singularity"
	set desc = "Sets up the singularity and all machines to get power flowing through the station"

	if(alert("Are you sure? This will start up the engine. Should only be used during debug!",,"Yes","No") != "Yes")
		return

	for(var/obj/machinery/power/emitter/E in GLOB.machines)
		if(E.anchored)
			E.active = TRUE

	for(var/obj/machinery/field/generator/F in GLOB.machines)
		if(F.active == FALSE)
			F.set_anchored(TRUE)
			F.active = TRUE
			F.state = 2
			F.power = 250
			F.warming_up = 3
			F.start_fields()
			F.update_icon()

	spawn(30)
		for(var/obj/machinery/the_singularitygen/G in GLOB.machines)
			if(G.anchored)
				var/obj/anomaly/singularity/S = new /obj/anomaly/singularity(get_turf(G), 50)
//				qdel(G)
				S.energy = 1750
				S.current_size = 7
				S.icon = 'icons/effects/224x224.dmi'
				S.icon_state = "singularity_s7"
				S.pixel_x = -96
				S.pixel_y = -96
				S.grav_pull = 0
				//S.consume_range = 3
				S.dissipate = 0
				//S.dissipate_delay = 10
				//S.dissipate_track = 0
				//S.dissipate_strength = 10

	for(var/obj/machinery/power/rad_collector/Rad in GLOB.machines)
		if(Rad.anchored)
			if(!Rad.loaded_tank)
				var/obj/item/tank/internals/plasma/Plasma = new/obj/item/tank/internals/plasma(Rad)
				var/datum/gas_mixture/plasma_air = Plasma.return_air()
				SET_MOLES(/datum/gas/plasma, plasma_air, 70)

				Rad.drainratio = 0
				Rad.loaded_tank = Plasma
				Plasma.forceMove(Rad)

			if(!Rad.active)
				Rad.toggle_power()

	for(var/obj/machinery/power/smes/SMES in GLOB.machines)
		if(SMES.anchored)
			SMES.input_attempt = 1

/client/proc/cmd_debug_mob_lists()
	set category = "Debug"
	set name = "Debug Mob Lists"
	set desc = "For when you just gotta know"

	switch(input("Which list?") in list("Players","Admins","Mobs","Living Mobs","Dead Mobs","Clients","Joined Clients"))
		if("Players")
			to_chat(usr, jointext(GLOB.player_list,","))
		if("Admins")
			to_chat(usr, jointext(GLOB.admins,","))
		if("Mobs")
			to_chat(usr, jointext(GLOB.mob_list,","))
		if("Living Mobs")
			to_chat(usr, jointext(GLOB.alive_mob_list,","))
		if("Dead Mobs")
			to_chat(usr, jointext(GLOB.dead_mob_list,","))
		if("Clients")
			to_chat(usr, jointext(GLOB.clients,","))
		if("Joined Clients")
			to_chat(usr, jointext(GLOB.joined_player_list,","))

/client/proc/cmd_display_del_log()
	set category = "Debug"
	set name = "Display del() Log"
	set desc = "Display del's log of everything that's passed through it."

	var/list/dellog = list("<B>List of things that have gone through qdel this round</B><BR><BR><ol>")
	sortTim(SSgarbage.items, cmp=GLOBAL_PROC_REF(cmp_qdel_item_time), associative = TRUE)
	for(var/path in SSgarbage.items)
		var/datum/qdel_item/I = SSgarbage.items[path]
		dellog += "<li><u>[path]</u><ul>"
		if (I.qdel_flags & QDEL_ITEM_SUSPENDED_FOR_LAG)
			dellog += "<li>SUSPENDED FOR LAG</li>"
		if (I.failures)
			dellog += "<li>Failures: [I.failures]</li>"
		dellog += "<li>qdel() Count: [I.qdels]</li>"
		dellog += "<li>Destroy() Cost: [I.destroy_time]ms</li>"
		if (I.hard_deletes)
			dellog += "<li>Total Hard Deletes [I.hard_deletes]</li>"
			dellog += "<li>Time Spent Hard Deleting: [I.hard_delete_time]ms</li>"
			dellog += "<li>Highest Time Spent Hard Deleting: [I.hard_delete_max]ms</li>"
			if (I.hard_deletes_over_threshold)
				dellog += "<li>Hard Deletes Over Threshold: [I.hard_deletes_over_threshold]</li>"
		if (I.slept_destroy)
			dellog += "<li>Sleeps: [I.slept_destroy]</li>"
		if (I.no_respect_force)
			dellog += "<li>Ignored force: [I.no_respect_force]</li>"
		if (I.no_hint)
			dellog += "<li>No hint: [I.no_hint]</li>"
		dellog += "</ul></li>"

	dellog += "</ol>"

	usr << browse(HTML_SKELETON(dellog.Join()), "window=dellog")

/client/proc/cmd_display_overlay_log()
	set category = "Debug"
	set name = "Display overlay Log"
	set desc = "Display SSoverlays log of everything that's passed through it."

	render_stats(SSoverlays.stats, src)

/client/proc/cmd_display_init_log()
	set category = "Debug"
	set name = "Display Initialize() Log"
	set desc = "Displays a list of things that didn't handle Initialize() properly"

	var/datum/browser/browser = new(usr, "initlog", "Initialize Log", 500, 500)
	browser.set_content(replacetext(SSatoms.InitLog(), "\n", "<br>"))
	browser.open()

/client/proc/debug_huds(i as num)
	set category = "Debug"
	set name = "Debug HUDs"
	set desc = "Debug the data or antag HUDs"

	if(!holder)
		return
	debug_variables(GLOB.huds[i])

/client/proc/jump_to_ruin()
	set category = "Debug"
	set name = "Jump to Ruin"
	set desc = "Displays a list of all placed ruins to teleport to."
	if(!holder)
		return
	var/list/names = list()
	for(var/obj/effect/landmark/ruin/ruin_landmark as anything in GLOB.ruin_landmarks)
		var/datum/map_template/ruin/template = ruin_landmark.ruin_template

		var/count = 1
		var/name = template.name
		var/original_name = name

		while(name in names)
			count++
			name = "[original_name] ([count])"

		names[name] = ruin_landmark

	var/ruinname = input("Select ruin", "Jump to Ruin") as null|anything in sort_list(names)


	var/obj/effect/landmark/ruin/landmark = names[ruinname]

	if(istype(landmark))
		var/datum/map_template/ruin/template = landmark.ruin_template
		usr.forceMove(get_turf(landmark))
		to_chat(usr, span_name("[template.name]"))
		to_chat(usr, span_italics("[template.description]"))

/client/proc/place_ruin()
	set category = "Debug"
	set name = "Spawn Ruin"
	set desc = "Attempt to randomly place a specific ruin."
	if (!holder)
		return

	var/list/exists = list()
	for(var/landmark in GLOB.ruin_landmarks)
		var/obj/effect/landmark/ruin/L = landmark
		exists[L.ruin_template] = landmark

	var/list/names = list()
	names += "---- Dynamic Levels ----"
	for(var/name in SSmapping.space_ruins_templates)
		names[name] = list(SSmapping.space_ruins_templates[name], ZTRAIT_DYNAMIC_LEVEL, /area/space)
	names += "---- Lava Ruins ----"
	for(var/name in SSmapping.lava_ruins_templates)
		names[name] = list(SSmapping.lava_ruins_templates[name], ZTRAIT_LAVA_RUINS, /area/lavaland/surface/outdoors/unexplored)

	var/ruinname = input("Select ruin", "Spawn Ruin") as null|anything in sort_list(names)
	var/data = names[ruinname]
	if (!data)
		return
	var/datum/map_template/ruin/template = data[1]
	if (exists[template])
		var/response = alert("There is already a [template] in existence.", "Spawn Ruin", "Jump", "Place Another", "Cancel")
		if (response == "Jump")
			usr.forceMove(get_turf(exists[template]))
			return
		else if (response != "Place Another")
			return

	var/len = GLOB.ruin_landmarks.len
	seedRuins(SSmapping.levels_by_trait(data[2]), max(1, template.cost), data[3], list(ruinname = template), clear_below = TRUE)
	if (GLOB.ruin_landmarks.len > len)
		var/obj/effect/landmark/ruin/landmark = GLOB.ruin_landmarks[GLOB.ruin_landmarks.len]
		log_admin("[key_name(src)] randomly spawned ruin [ruinname] at [COORD(landmark)].")
		usr.forceMove(get_turf(landmark))
		to_chat(src, span_name("[template.name]"))
		to_chat(src, span_italics("[template.description]"))
	else
		to_chat(src, span_warning("Failed to place [template.name]."))

/client/proc/run_empty_query(val as num)
	set category = "Debug"
	set name = "Run empty query"
	set desc = "Amount of queries to run"

	var/list/queries = list()
	for(var/i in 1 to val)
		var/datum/db_query/query = SSdbcore.NewQuery("NULL")
		INVOKE_ASYNC(query, TYPE_PROC_REF(/datum/db_query, Execute))
		queries += query

	for(var/datum/db_query/query as anything in queries)
		query.sync()
		qdel(query)
	queries.Cut()

	message_admins("[key_name_admin(src)] ran [val] empty queries.")

/client/proc/generate_ruin()
	set category = "Debug"
	set name = "Generate Ruin"
	set desc = "Randomly generate a space ruin."
	if (!holder)
		return
	var/ruin_size = input(src, "Ruin size (NxN) (Between 10 and 200)", "Ruin Size", 0) as num
	if(ruin_size < 10 || ruin_size >= 200)
		return
	var/response = alert(src, "This will place the ruin at your current location.", "Spawn Ruin", "Spawn Ruin", "Cancel")
	if (response != "Spawn Ruin")
		return
	var/border_size = (world.maxx - ruin_size) / 2
	generate_space_ruin(mob.x, mob.y, mob.z, border_size, border_size)
	log_admin("[key_name(src)] randomly generated a space ruin at [COORD(mob)].")

/client/proc/clear_dynamic_transit()
	set category = "Debug"
	set name = "Clear Dynamic Turf Reservations"
	set desc = "Deallocates all reserved space, restoring it to round start conditions."
	if(!holder)
		return
	var/answer = alert("WARNING: THIS WILL WIPE ALL RESERVED SPACE TO A CLEAN SLATE! ANY MOVING SHUTTLES, ELEVATORS, OR IN-PROGRESS PHOTOGRAPHY WILL BE DELETED!", "Really wipe dynamic turfs?", "YES", "NO")
	if(answer != "YES")
		return
	message_admins(span_adminnotice("[key_name_admin(src)] cleared dynamic transit space."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Clear Dynamic Transit") // If...
	log_admin("[key_name(src)] cleared dynamic transit space.")
	SSmapping.wipe_reservations()				//this goes after it's logged, incase something horrible happens.

/client/proc/fucky_wucky()
	set category = "Debug"
	set name = "Fucky Wucky"
	set desc = "Inform the players that the code monkeys at our headquarters are working very hard to fix this."

	if(!check_rights(R_DEBUG))
		return
	remove_verb(/client/proc/fucky_wucky)
	message_admins(span_adminnotice("[key_name_admin(src)] did a fucky wucky."))
	log_admin("[key_name(src)] did a fucky wucky.")
	for(var/m in GLOB.player_list)
		var/datum/asset/fuckywucky = get_asset_datum(/datum/asset/simple/fuckywucky)
		fuckywucky.send(m)
		SEND_SOUND(m, 'sound/misc/fuckywucky.ogg')
		to_chat(m, "<img src='[SSassets.transport.get_asset_url("fuckywucky.png")]'>")

	addtimer(CALLBACK(src, PROC_REF(restore_fucky_wucky)), 600)

/client/proc/restore_fucky_wucky()
	add_verb(/client/proc/fucky_wucky)

/client/proc/toggle_medal_disable()
	set category = "Debug"
	set name = "Toggle Achievement Disable"
	set desc = "Toggles the safety lock on trying to contact the achievement hub."

	if(!check_rights(R_DEBUG))
		return

	SSachievements.achievements_enabled = !SSachievements.achievements_enabled

	message_admins(span_adminnotice("[key_name_admin(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the achievement hub lockout."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Toggle Achievement Disable") // If...
	log_admin("[key_name(src)] [SSachievements.achievements_enabled ? "disabled" : "enabled"] the achievement hub lockout.")

/client/proc/view_runtimes()
	set category = "Debug"
	set name = "View Runtimes"
	set desc = "Open the runtime Viewer"

	if(!holder)
		return

	GLOB.error_cache.show_to(src)

/client/proc/pump_random_event()
	set category = "Debug"
	set name = "Pump Random Event"
	set desc = "Schedules the event subsystem to fire a new random event immediately. Some events may fire without notification."
	if(!holder)
		return

	SSevents.scheduled = world.time

	message_admins(span_adminnotice("[key_name_admin(src)] pumped a random event."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Pump Random Event")
	log_admin("[key_name(src)] pumped a random event.")

/client/proc/start_line_profiling()
	set category = "Profile"
	set name = "Start Line Profiling"
	set desc = "Starts tracking line by line profiling for code lines that support it"

	LINE_PROFILE_START

	message_admins(span_adminnotice("[key_name_admin(src)] started line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Start Line Profiling")
	log_admin("[key_name(src)] started line by line profiling.")

/client/proc/stop_line_profiling()
	set category = "Profile"
	set name = "Stops Line Profiling"
	set desc = "Stops tracking line by line profiling for code lines that support it"

	LINE_PROFILE_STOP

	message_admins(span_adminnotice("[key_name_admin(src)] stopped line by line profiling."))
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Stop Line Profiling")
	log_admin("[key_name(src)] stopped line by line profiling.")

/client/proc/show_line_profiling()
	set category = "Profile"
	set name = "Show Line Profiling"
	set desc = "Shows tracked profiling info from code lines that support it"

	var/sortlist = list(
		"Avg time"		=	/proc/cmp_profile_avg_time_dsc,
		"Total Time"	=	/proc/cmp_profile_time_dsc,
		"Call Count"	=	/proc/cmp_profile_count_dsc
	)
	var/sort = input(src, "Sort type?", "Sort Type", "Avg time") as null|anything in sortlist
	if (!sort)
		return
	sort = sortlist[sort]
	profile_show(src, sort)

/client/proc/reload_configuration()
	set category = "Server"
	set name = "Reload Configuration"
	set desc = "Force config reload to world default"
	if(!check_rights(R_DEBUG))
		return
	if(alert(usr, "Are you absolutely sure you want to reload the configuration from the default path on the disk, wiping any in-round modificatoins?", "Really reset?", "No", "Yes") == "Yes")
		//Reload the config
		config.admin_reload()
		//Reload badges
		load_badge_ranks()

/client/proc/modify_canister_gas(obj/machinery/portable_atmospherics/canister/C)
	if(!check_rights(R_DEBUG) || !C)
		return

	var/gas_to_add = input(usr, "Choose a gas to modify.", "Choose a gas.") as null|anything in subtypesof(/datum/gas)
	var/amount = input(usr, "Choose the amount of moles.", "Choose the amount.", 0) as num
	var/temp = input(usr, "Choose the temperature (Kelvin).", "Choose the temp (K).", 0) as num

	var/datum/gas_mixture/C_air = C.return_air()

	SET_MOLES(gas_to_add, C_air, amount)

	C_air.temperature = (temp)
	C.update_icon()

	message_admins(span_adminnotice("[key_name_admin(src)] modified \the [C.name] at [AREACOORD(C)] - Gas: [gas_to_add], Moles: [amount], Temp: [temp]."))
	log_admin("[key_name_admin(src)] modified \the [C.name] at [AREACOORD(C)] - Gas: [gas_to_add], Moles: [amount], Temp: [temp].")


/client/proc/give_all_spells_touch()
	set category = "Debug"
	set name = "Give all touch spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/touch))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_aoe()
	set category = "Debug"
	set name = "Give all aoe spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/aoe))
		if(ispath(power, /datum/action/spell/aoe/revenant))
			continue
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spell_aoe_rev()
	set category = "Debug"
	set name = "Give all revenant aoe spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/aoe/revenant))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_cone()
	set category = "Debug"
	set name = "Give all cone spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/cone))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_conjure()
	set category = "Debug"
	set name = "Give all conjure spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/conjure))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_conjure_item()
	set category = "Debug"
	set name = "Give all conjure item spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/conjure_item))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_jaunt()
	set category = "Debug"
	set name = "Give all jaunt spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/jaunt))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_pointed()
	set category = "Debug"
	set name = "Give all pointed spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/pointed))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_projectile()
	set category = "Debug"
	set name = "Give all projectile spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/basic_projectile))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_shapeshift()
	set category = "Debug"
	set name = "Give all shapeshift spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/shapeshift))
		GRANT_ACTION_MOB(power, mob)

/client/proc/give_all_spells_teleport()
	set category = "Debug"
	set name = "Give all teleport spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in subtypesof(/datum/action/spell/teleport))
		GRANT_ACTION_MOB(power, mob)

/client/proc/remove_all_spells()
	set category = "Debug"
	set name = "Remove all spells"
	if(!check_rights(R_DEBUG))
		return
	for (var/datum/action/spell/power as anything in mob.actions)
		if(istype(power, /datum/action/spell))
			power.Remove(mob)

/client/proc/give_all_action_mutations()
	set category = "Debug"
	set name = "Give all action mutations"
	if(!check_rights(R_DEBUG))
		return
	var/mob/living/carbon/human/human = mob
	if (!istype(human))
		return
	for (var/datum/mutation/mutation as anything in subtypesof(/datum/mutation))
		if (!initial(mutation.power_path))
			continue
		human.dna.add_mutation(mutation)

/client/proc/give_all_mutations()
	set category = "Debug"
	set name = "Give all mutations"
	if(!check_rights(R_DEBUG))
		return
	var/mob/living/carbon/human/human = mob
	if (!istype(human))
		return
	for (var/datum/mutation/test as anything in subtypesof(/datum/mutation))
		if(tgui_alert(mob, "Do you want to [test] yourself?", "", list("Yes", "No")) == "Yes")
			human.dna.add_mutation(test)


/// A debug verb to check the sources of currently running timers
/client/proc/check_timer_sources()
	set category = "Debug"
	set name = "Check Timer Sources"
	set desc = "Checks the sources of the running timers"
	if (!check_rights(R_DEBUG))
		return

	var/bucket_list_output = generate_timer_source_output(SStimer.bucket_list)
	var/second_queue = generate_timer_source_output(SStimer.second_queue)

	var/datum/browser/browser = new(usr, "check_timer_sources", "Timer Sources", 700, 700)
	browser.set_content({"
		<h3>bucket_list</h3>
		[bucket_list_output]

		<h3>second_queue</h3>
		[second_queue]
	"})
	browser.open()

/proc/generate_timer_source_output(list/datum/timedevent/events)
	var/list/per_source = list()

	// Collate all events and figure out what sources are creating the most
	for (var/_event in events)
		if (!_event)
			continue
		var/datum/timedevent/event = _event

		do
			if (event.source)
				if (per_source[event.source] == null)
					per_source[event.source] = 1
				else
					per_source[event.source] += 1
			event = event.next
		while (event && event != _event)

	// Now, sort them in order
	var/list/sorted = list()
	for (var/source in per_source)
		sorted += list(list("source" = source, "count" = per_source[source]))
	sorted = sortTim(sorted, GLOBAL_PROC_REF(cmp_timer_data))

	// Now that everything is sorted, compile them into an HTML output
	var/output = "<table border='1'>"

	for (var/_timer_data in sorted)
		var/list/timer_data = _timer_data
		output += {"<tr>
			<td><b>[timer_data["source"]]</b></td>
			<td>[timer_data["count"]]</td>
		</tr>"}

	output += "</table>"

	return output

/proc/cmp_timer_data(list/a, list/b)
	return b["count"] - a["count"]

#ifdef TESTING
/client/proc/check_missing_sprites()
	set category = "Debug"
	set name = "Debug Worn Item Sprites"
	set desc = "We're cancelling the Spritemageddon. (This will create a LOT of runtimes! Don't use on a live server!)"
	var/actual_file_name
	for(var/test_obj in subtypesof(/obj/item))
		var/obj/item/sprite = new test_obj
		if(!sprite.slot_flags || (sprite.item_flags & ABSTRACT))
			continue
		//Is there an explicit worn_icon to pick against the worn_icon_state? Easy street expected behavior.
		if(sprite.worn_icon)
			if(!(sprite.icon_state in icon_states(sprite.worn_icon)))
				to_chat(src, span_warning("ERROR sprites for [sprite.type]. Slot Flags are [sprite.slot_flags]."))
		else if(sprite.worn_icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Mask slot."))
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Neck slot."))
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Back slot."))
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Head slot."))
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Belt slot."))
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.worn_icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."))
		else if(sprite.icon_state)
			if(sprite.slot_flags & ITEM_SLOT_MASK)
				actual_file_name = 'icons/mob/clothing/mask.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Mask slot."))
			if(sprite.slot_flags & ITEM_SLOT_NECK)
				actual_file_name = 'icons/mob/clothing/neck.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Neck slot."))
			if(sprite.slot_flags & ITEM_SLOT_BACK)
				actual_file_name = 'icons/mob/clothing/back.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Back slot."))
			if(sprite.slot_flags & ITEM_SLOT_HEAD)
				actual_file_name = 'icons/mob/clothing/head/default.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Head slot."))
			if(sprite.slot_flags & ITEM_SLOT_BELT)
				actual_file_name = 'icons/mob/clothing/belt.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Belt slot."))
			if(sprite.slot_flags & ITEM_SLOT_SUITSTORE)
				actual_file_name = 'icons/mob/clothing/belt_mirror.dmi'
				if(!(sprite.icon_state in icon_states(actual_file_name)))
					to_chat(src, span_warning("ERROR sprites for [sprite.type]. Suit Storage slot."))
#endif

/*
 * Test Luminosity Changes vs Dview
 *
 * A simple debug verb that rapidly changes you current turf's
 * luminosity value and runs view() to test the performance
 * compared to dview()
*/
/client/proc/test_dview_to_lum_changes()
	set category = "Debug"
	set name = "Test Lum Changes"
	set desc = "Changes your current turf's luminosity repeatedly to test how long it takes"
	//Check if the user running this verb has sufficient privellages
	if (!check_rights(R_DEBUG))
		return
	//Get the turf of the user
	var/turf/T = get_turf(usr)
	//if the current turf is null, don't act
	if(!T)
		return

	//Count the total of view
	var/total_dview = 0
	var/total_lum = 0

	//Get the timer of the world
	var/timer_dview = TICK_USAGE
	//Run the DVIEW test
	for(var/i in 1 to 10000)
		var/list/L = dview(6, T)
		total_dview += length(L)
	//Get the results of the dview test
	var/total_time_dview = TICK_USAGE_TO_MS(timer_dview)

	//Get the timer of the world
	var/timer_lum_changes = TICK_USAGE
	//Run the LUM CHANGES test
	for(var/i in 1 to 10000)
		T.luminosity = 6
		var/list/L = view(6, T)
		total_lum += length(L)
		T.luminosity = 1
	//Get the result of the lum change test
	var/total_time_lum = TICK_USAGE_TO_MS(timer_lum_changes)

	//Print the results
	to_chat(usr, span_notice("10000 dview calls resulted in a [total_time_dview]ms overhead. ([total_dview] items located)"))
	to_chat(usr, span_notice("10000 lum changes resulted in a [total_time_lum]ms overhead. ([total_lum] items located)"))

/client/proc/cmd_regenerate_asset_cache()
	set category = "Debug"
	set name = "Regenerate Asset Cache"
	set desc = "Clears the asset cache and regenerates it immediately."
	if(!CONFIG_GET(flag/cache_assets))
		to_chat(usr, span_warning("Asset caching is disabled in the config!"))
		return
	var/regenerated = 0
	for(var/datum/asset/A as() in subtypesof(/datum/asset))
		if(!initial(A.cross_round_cachable))
			continue
		if(A == initial(A._abstract))
			continue
		var/datum/asset/asset_datum = GLOB.asset_datums[A]
		asset_datum.regenerate()
		regenerated++
	to_chat(usr, span_notice("Regenerated [regenerated] asset\s."))

/client/proc/cmd_clear_smart_asset_cache()
	set category = "Debug"
	set name = "Clear Smart Asset Cache"
	set desc = "Clears the smart asset cache."
	if(!CONFIG_GET(flag/smart_cache_assets))
		to_chat(usr, span_warning("Smart asset caching is disabled in the config!"))
		return
	var/cleared = 0
	for(var/datum/asset/spritesheet_batched/A as() in subtypesof(/datum/asset/spritesheet_batched))
		if(A == initial(A._abstract))
			continue
		fdel("[ASSET_CROSS_ROUND_SMART_CACHE_DIRECTORY]/spritesheet_cache.[initial(A.name)].json")
		cleared++
	to_chat(usr, span_notice("Cleared [cleared] asset\s."))
