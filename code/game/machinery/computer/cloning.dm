#define AUTOCLONING_MINIMAL_LEVEL 3

/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	req_access = list(ACCESS_GENETICS) //for modifying records
	var/obj/machinery/dna_scannernew/scanner //Linked scanner. For scanning.
	var/clonepod_type = /obj/machinery/clonepod
	var/list/pods //Linked cloning pods
	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp_name
	var/scantemp = "Inactive"
	var/menu = 1 //Which menu screen to display
	var/use_records = TRUE	//set this to false if you don't want the console to use records
	var/list/records = list()
	var/obj/item/disk/data/diskette //Incompatible format to genetics machine
	//select which parts of the diskette to load
	var/include_se = FALSE //mutations
	var/include_ui = FALSE //appearance
	var/include_ue = FALSE //blood type, UE, and name

	var/loading = FALSE // Nice loading text
	var/autoprocess = FALSE

	var/experimental = FALSE //experimental cloner will have true. TRUE allows you to scan a weird brain.

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()
	updatemodules(TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(pods)
		for(var/pod in pods)
			DetachCloner(pod)
		pods = null
	return ..()

/obj/machinery/computer/cloning/proc/GetAvailablePod(mind = null)
	if(pods)
		for(var/obj/machinery/clonepod/pod as anything in pods)
			if(pod.occupant && pod.clonemind == mind)
				return null
			if(pod.is_operational && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/cloning/proc/HasEfficientPod()
	if(pods)
		for(var/obj/machinery/clonepod/pod as anything in pods)
			if(pod.is_operational && pod.efficiency > 5)
				return TRUE

/obj/machinery/computer/cloning/proc/GetAvailableEfficientPod(mind = null)
	if(pods)
		for(var/obj/machinery/clonepod/pod as anything in pods)
			if(pod.occupant && pod.clonemind == mind)
				return pod
			else if(!. && pod.is_operational && !(pod.occupant || pod.mess) && pod.efficiency > 5)
				. = pod

/proc/grow_clone_from_record(obj/machinery/clonepod/pod, datum/record/cloning/cloning_record, experimental)
	return pod.growclone(CLONING_STRICT_ARGS(
		/* 01 */ clonename = cloning_record.name,
		/* 02 */ unique_identity = cloning_record.unique_identity,
		/* 03 */ mutation_index = cloning_record.datum_dna.mutation_index.Copy(),
		/* 04 */ given_mind = cloning_record?.resolve_mind(),
		/* 05 */ last_death = cloning_record.last_death,
		/* 06 */ mrace = cloning_record.species,
		/* 07 */ features = cloning_record.get_copied_dna_features(),
		/* 08 */ factions = cloning_record.factions.Copy(),
		/* 09 */ insurance = cloning_record.resolve_mind_account_id(),
		/* 10 */ traumas = cloning_record.traumas.Copy(),
		/* 11 */ body_only = cloning_record.body_only,
		/* 12 */ experimental= experimental ))

/obj/machinery/computer/cloning/process()
	if(!(scanner && LAZYLEN(pods) && autoprocess))
		return

	if(scanner.occupant && scanner.scan_level > 2)
		scan_occupant(scanner.occupant)
		ui_update()

	for(var/datum/record/cloning/cloning_record in records)
		var/obj/machinery/clonepod/pod = GetAvailableEfficientPod(cloning_record.resolve_mind())

		if(!pod)
			return

		if(pod.occupant)
			break

		var/result = grow_clone_from_record(pod, cloning_record, experimental)
		if(result & CLONING_SUCCESS)
			temp = "[cloning_record.name] => Cloning cycle in progress..."
			log_cloning("Cloning of [key_name(cloning_record.resolve_mind())] automatically started via autoprocess - [src] at [AREACOORD(src)]. Pod: [pod] at [AREACOORD(pod)].")
			SStgui.update_uis(src)
		if(result & CLONING_DELETE_RECORD)
			records -= cloning_record
			ui_update()


/obj/machinery/computer/cloning/proc/connect_scanner(obj/machinery/dna_scannernew/new_scanner)
	if(scanner)
		UnregisterSignal(scanner, COMSIG_MACHINE_OPEN)
		UnregisterSignal(scanner, COMSIG_MACHINE_CLOSE)

	if(new_scanner)
		RegisterSignal(new_scanner, COMSIG_MACHINE_OPEN, PROC_REF(scanner_ui_update))
		RegisterSignal(new_scanner, COMSIG_MACHINE_CLOSE, PROC_REF(scanner_ui_update))

	scanner = new_scanner

/obj/machinery/computer/cloning/proc/scanner_ui_update()
	SIGNAL_HANDLER
	ui_update()

/obj/machinery/computer/cloning/proc/updatemodules(findfirstcloner)
	if(QDELETED(scanner))
		connect_scanner(findscanner())
	if(findfirstcloner && !LAZYLEN(pods))
		findcloner()
	if(!autoprocess)
		STOP_PROCESSING(SSmachines, src)
	else
		START_PROCESSING(SSmachines, src)

/obj/machinery/computer/cloning/proc/findscanner()
	var/obj/machinery/dna_scannernew/scannerf = null

	// Loop through every direction
	for(var/direction in GLOB.cardinals)

		// Try to find a scanner in that direction
		scannerf = locate(/obj/machinery/dna_scannernew, get_step(src, direction))

		// If found and operational, return the scanner
		if (!isnull(scannerf) && scannerf.is_operational)
			return scannerf

	// If no scanner was found, it will return null
	return null

/obj/machinery/computer/cloning/proc/findcloner()
	var/obj/machinery/clonepod/podf = null

	for(var/direction in GLOB.cardinals)

		podf = locate(clonepod_type, get_step(src, direction))
		if (!isnull(podf) && podf.is_operational)
			AttachCloner(podf)

/obj/machinery/computer/cloning/proc/AttachCloner(obj/machinery/clonepod/pod)
	if(!pod.connected)
		pod.connected = src
		LAZYADD(pods, pod)

/obj/machinery/computer/cloning/proc/DetachCloner(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(pods, pod)

/obj/machinery/computer/cloning/attackby(obj/item/used_item, mob/user, params)
	if(istype(used_item, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if (!diskette)
			if (!user.transferItemToLoc(used_item,src))
				return
			diskette = used_item
			to_chat(user, span_notice("You insert [used_item]."))
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else
		return ..()

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/cloning)

DEFINE_BUFFER_HANDLER(/obj/machinery/computer/cloning)
	if(istype(buffer, /obj/machinery/clonepod))
		if(get_area(buffer) != get_area(src))
			to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
			FLUSH_BUFFER(buffer_parent)
			return NONE
		to_chat(user, "<font color = #666633>-% Successfully linked [buffer] with [src] %-</font color>")
		var/obj/machinery/clonepod/pod = buffer
		if(pod.connected)
			pod.connected.DetachCloner(pod)
		AttachCloner(pod)
	else
		if (TRY_STORE_IN_BUFFER(buffer_parent, src))
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(src)] [name] in buffer %-</font color>")
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/computer/cloning/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	EjectDisk(user)

/obj/machinery/computer/cloning/proc/EjectDisk(mob/user)
	if(diskette)
		scantemp = "Disk Ejected"
		diskette.forceMove(drop_location())
		user.put_in_active_hand(diskette)
		diskette = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		. = TRUE

/obj/machinery/computer/cloning/proc/save_to_disk(mob/user, target)
	if(!diskette || diskette.read_only)
		scantemp = !diskette ? "Failed saving to disk: No disk." : "Failed saving to disk: Disk refuses override attempt."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target)
			found_record = each_record
			break

	if(!found_record)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Failed saving to disk: Data Corruption"
		return FALSE

	QDEL_NULL(diskette.data)
	diskette.data = new /datum/record/cloning(RECORD_STRICT_ARGS_NONE)
	found_record.copy_to(diskette.data)

	diskette.name = "data disk - '[src.diskette.data.name]'"
	scantemp = "Saved to disk successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/DeleteRecord(mob/user, target)
	var/obj/item/card/id/idcard_for_auth = usr.get_idcard(hand_first = TRUE)
	if(!istype(idcard_for_auth) || !check_access(idcard_for_auth))
		scantemp = "Cannot delete: Access Denied."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target)
			found_record = each_record
			break
	if(!found_record)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Cannot delete: Data Corrupted."
		return FALSE

	scantemp = "[found_record.name] => Record deleted."
	records.Remove(found_record)
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	var/obj/item/circuitboard/computer/cloning/board = circuit
	board.records = records // EvilDragon: moving record?? whoever coded this, it seems it's something to change someday??
	qdel(found_record)
	return TRUE

/obj/machinery/computer/cloning/proc/load_from_disk(mob/user)
	if(!diskette || !diskette.data.name || !diskette.data)
		scantemp = "Failed loading: Load error."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == diskette.data.id)
			scantemp = "Failed loading: Data already exists!"
			return FALSE

	var/datum/record/cloning/new_record = new /datum/record/cloning(RECORD_STRICT_ARGS_NONE)
	diskette.data.copy_to(new_record)

	records += new_record
	scantemp = "Loaded into internal storage successfully."
	var/obj/item/circuitboard/computer/cloning/board = circuit
	board.records = records
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/Clone(mob/user, target)
	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target)
			found_record = each_record
	//Look for that player! They better be dead!
	if(found_record)
		var/obj/machinery/clonepod/pod = GetAvailablePod()
		//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
		if(!LAZYLEN(pods))
			temp = "Error: No Clonepods detected."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else if(!pod)
			temp = "Error: No Clonepods available."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else if(!CONFIG_GET(flag/revival_cloning))
			temp = "Error: Unable to initiate cloning cycle."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else if(pod.occupant)
			temp = "Warning: Cloning cycle already in progress."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		else
			var/cloning_attempt_result = pod.growclone(CLONING_STRICT_ARGS(
				/* 01 */ clonename = found_record.name,
				/* 02 */ unique_identity = found_record.unique_identity,
				/* 03 */ mutation_index = found_record.datum_dna.mutation_index.Copy(),
				/* 04 */ given_mind = found_record.resolve_mind(),
				/* 05 */ last_death = found_record.last_death,
				/* 06 */ mrace = found_record.species,
				/* 07 */ features = found_record.get_copied_dna_features(),
				/* 08 */ factions = found_record.factions.Copy(),
				/* 09 */ insurance = found_record.resolve_mind_account_id(),
				/* 10 */ traumas = found_record.traumas.Copy(),
				/* 11 */ body_only = found_record.body_only,
				/* 12 */ experimental = experimental ))
			switch(cloning_attempt_result)
				if(CLONING_SUCCESS)
					temp = "Notice: [found_record.name] => Cloning cycle in progress..."
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
					if(!found_record.body_only)
						records.Remove(found_record)
					return TRUE
				if(CLONING_SUCCESS_EXPERIMENTAL)
					temp = "Notice: [found_record.name] => Experimental cloning cycle in progress..."
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
					return TRUE
				if(ERROR_NO_SYNTHFLESH)
					temp = "Error [ERROR_NO_SYNTHFLESH]: Out of synthflesh."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_PANEL_OPENED)
					temp = "Error [ERROR_PANEL_OPENED]: Panel opened."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_MESS_OR_ATTEMPTING)
					temp = "Error [ERROR_MESS_OR_ATTEMPTING]: Pod is already occupied."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_MISSING_EXPERIMENTAL_POD)
					temp = "Error [ERROR_MISSING_EXPERIMENTAL_POD]: Experimental pod is not detected."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_NOT_MIND)
					temp = "Error [ERROR_NOT_MIND]: [found_record.name]'s lack of their mind."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_PRESAVED_CLONE)
					temp = "Error [ERROR_PRESAVED_CLONE]: [found_record.name]'s clone record is presaved."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_OUTDATED_CLONE)
					temp = "Error [ERROR_OUTDATED_CLONE]: [found_record.name]'s clone record is outdated."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_ALREADY_ALIVE)
					temp = "Error [ERROR_ALREADY_ALIVE]: [found_record.name] already alive."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_COMMITED_SUICIDE)
					temp = "Error [ERROR_COMMITED_SUICIDE]: [found_record.name] commited a suicide."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_SOUL_DEPARTED)
					temp = "Error [ERROR_SOUL_DEPARTED]: [found_record.name]'s soul had departed."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_SUICIDED_BODY)
					temp = "Error [ERROR_SUICIDED_BODY]: Failed to capture [found_record.name]'s mind from a suicided body."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_UNCLONABLE)
					temp = "Error [ERROR_UNCLONABLE]: [found_record.name] is not clonable."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				else
					temp = "Error unknown => Initialisation failure."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

	else
		temp = "Failed to clone: Data corrupted."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/Toggle_lock(mob/user)
	if(!scanner.is_operational)
		return
	if(!scanner.locked && !scanner.occupant) //I figured out that if you're fast enough, you can lock an open pod
		return
	scanner.locked = !scanner.locked
	playsound(src, scanner.locked ? 'sound/machines/terminal_prompt_deny.ogg' : 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	. = TRUE

/obj/machinery/computer/cloning/proc/Scan(mob/user, body_only = FALSE)
	if(!scanner.is_operational || !scanner.occupant)
		return
	scantemp = "[scantemp_name] => Scanning..."
	loading = TRUE
	playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
	say("Initiating scan...")
	var/prev_locked = scanner.locked
	scanner.locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_scan), scanner.occupant, user, prev_locked, body_only), 2 SECONDS)
	. = TRUE

/obj/machinery/computer/cloning/proc/Toggle_autoprocess(mob/user)
	if(!scanner || !HasEfficientPod() || scanner.scan_level < AUTOCLONING_MINIMAL_LEVEL)
		return FALSE
	autoprocess = !autoprocess
	if(autoprocess)
		START_PROCESSING(SSmachines, src)
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	else
		STOP_PROCESSING(SSmachines, src)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	. = TRUE

/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()
	data["useRecords"] = use_records
	var/list/records_to_send = list()
	if(use_records)
		if(scanner && HasEfficientPod() && scanner.scan_level >= AUTOCLONING_MINIMAL_LEVEL)
			data["hasAutoprocess"] = TRUE
		if(length(records))
			for(var/datum/record/cloning/each_record in records)
				var/list/record_entry = list()
				record_entry["name"] = "[each_record.name]"
				record_entry["id"] = "[each_record.id]"
				var/obj/item/implant/health/H = each_record.implant
				if(H && istype(H))
					record_entry["damages"] = H.sensehealth(TRUE)
				else
					record_entry["damages"] = FALSE
				record_entry["UI"] = "[each_record.unique_identity]"
				record_entry["UE"] = "[each_record.unique_enzymes]"
				record_entry["blood_type"] = "[each_record.blood_type]"
				record_entry["last_death"] = each_record.last_death
				record_entry["body_only"] = each_record.body_only
				records_to_send += list(record_entry)
			data["records"] = records_to_send
		else
			data["records"] = list()
		if(diskette && diskette.data)
			var/list/disk_data = list()
			disk_data["name"] = "[diskette.data.name]"
			disk_data["id"] = "[diskette.data.id]"
			disk_data["UI"] = "[diskette.data.unique_identity]"
			disk_data["UE"] = "[diskette.data.unique_enzymes]"
			disk_data["blood_type"] = "[diskette.data.blood_type]"
			disk_data["last_death"] = diskette.data.last_death
			disk_data["body_only"] = diskette.data.body_only
			data["diskData"] = disk_data
		else
			data["diskData"] = list()
	else
		data["hasAutoprocess"] = FALSE
	data["autoprocess"] = autoprocess
	var/list/lack_machine = list()
	if(isnull(src.scanner))
		lack_machine += "ERROR: No Scanner Detected!"
	if(!LAZYLEN(pods))
		lack_machine += "ERROR: No Pod Detected!"
	data["lacksMachine"] = lack_machine
	data["temp"] = temp
	var/build_temp = null
	var/mob/living/scanner_occupant = get_mob_or_brainmob(scanner?.occupant)
	if(scanner_occupant?.ckey != scantemp_ckey || scanner_occupant?.name != scantemp_name)
		if(use_records)
			build_temp = "Ready to Scan"
			scantemp_ckey = scanner_occupant?.ckey
			scantemp_name = scanner_occupant?.name
		else
			build_temp = "Ready to Clone"
		scantemp = "[scanner_occupant] => [build_temp]"
	data["scanTemp"] = scantemp
	data["scannerLocked"] = scanner?.locked
	data["hasOccupant"] = scanner?.occupant
	data["recordsLength"] = "View Records ([length(records)])"
	data["experimental"] = experimental
	data["diskette"] = diskette
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return

	// Return TRUE on almost every operation, since operations write to temp and scantemp to display failure messages

	switch(action)
		if("toggle_autoprocess")
			. = Toggle_autoprocess(usr)
		if("scan")
			Scan(usr, FALSE)
			. = TRUE
		if("scan_body_only")
			Scan(usr, TRUE)
			. = TRUE
		if("toggle_lock")
			. = Toggle_lock(usr)
		if("clone")
			Clone(usr, params["target"])
			. = TRUE
		if("delrecord")
			DeleteRecord(usr, params["target"])
			. = TRUE
		if("save")
			save_to_disk(usr, params["target"])
			. = TRUE
		if("load")
			load_from_disk(usr)
			. = TRUE
		if("eject")
			. = EjectDisk(usr)

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	updatemodules(TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning System Control")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/cloning/proc/finish_scan(mob/living/carbon_mob, mob/user, prev_locked, body_only)
	if(!scanner || !carbon_mob)
		return
	add_fingerprint(user)
	if(use_records)
		scan_occupant(carbon_mob, user, body_only)
	else
		clone_occupant(carbon_mob, user)

	loading = FALSE
	scanner.locked = prev_locked
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	SStgui.update_uis(src) // Immediate since it's not spammable

//Used by consoles without records
/obj/machinery/computer/cloning/proc/clone_occupant(occupant, mob/user)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(ishuman(mob_occupant))
		var/mob/living/carbon/carbon_mob = mob_occupant
		dna = carbon_mob.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/human_brain = mob_occupant
		dna = human_brain.stored_dna
	if(!can_scan(dna, mob_occupant))
		return
	var/clone_species
	if(dna.species)
		clone_species = dna.species
	else
		scantemp = "Unauthorized clone process detected => Interrupted."
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
	var/obj/machinery/clonepod/pod = GetAvailablePod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(pods))
		temp = "No Clonepods detected."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(!pod)
		temp = "No Clonepods available."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else if(pod.occupant)
		temp = "Cloning cycle already in progress."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
	else
		pod.growclone(CLONING_STRICT_ARGS(
			/* 01 */ clonename = mob_occupant.real_name,
			/* 02 */ unique_identity = dna.unique_identity,
			/* 03 */ mutation_index = dna.mutation_index.Copy(),
			/* 04 */ given_mind = null,
			/* 05 */ last_death = null,
			/* 06 */ mrace = clone_species,
			/* 07 */ features = dna.features.Copy(),
			/* 08 */ factions = mob_occupant.faction.Copy(),
			/* 09 */ insurance = null,
			/* 10 */ traumas = null,
			/* 11 */ body_only = null,
			/* 12 */ experimental = null ))
		temp = "[mob_occupant.real_name] => Cloning data sent to pod."
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		log_cloning("[user ? key_name(user) : "Unknown"] cloned [key_name(mob_occupant)] with [src] at [AREACOORD(src)].")

/obj/machinery/computer/cloning/proc/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/bank_account/account, body_only)
	if(!istype(dna))
		scantemp = "Unable to locate valid genetic data."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if(HAS_TRAIT(mob_occupant, TRAIT_NO_DNA_COPY))
		scantemp = "The DNA of this lifeform could not be read due to an unknown error!"
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if((HAS_TRAIT(mob_occupant, TRAIT_HUSK)) && (src.scanner.scan_level < 2))
		scantemp = "Subject's body is too damaged to scan properly."
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return FALSE
	if(HAS_TRAIT(mob_occupant, TRAIT_BADDNA))
		scantemp = "Subject's DNA is damaged beyond any hope of recovery."
		playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
		return FALSE
	if(!experimental)
		if(!body_only && mob_occupant.suiciding)
			scantemp = "Subject's brain is not responding to scanning stimuli."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		if(!body_only && isnull(mob_occupant.mind))
			scantemp = "Mental interface failure."
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		if(!body_only && SSeconomy.full_ancap)
			if(!account)
				scantemp = "Subject is either missing an ID card with a bank account on it, or does not have an account to begin with. Please ensure the ID card is on the body before attempting to scan."
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				return FALSE
	return TRUE

/obj/machinery/computer/cloning/proc/scan_occupant(occupant, mob/user, body_only)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	var/datum/bank_account/has_bank_account

	// Do not use unless you know what they are.
	var/mob/living/carbon/human/human_mob = mob_occupant
	var/mob/living/brain/human_brain = mob_occupant

	if(ishuman(mob_occupant))
		dna = human_mob.has_dna()
		var/obj/item/card/id/human_id_card = human_mob.get_idcard(TRUE)
		if(human_id_card)
			has_bank_account = human_id_card.registered_account
	if(isbrain(mob_occupant))
		dna = human_brain.stored_dna

	if(!can_scan(dna, mob_occupant, has_bank_account, body_only))
		return

	var/datum/record/cloning/cloning_record = new(RECORD_CLONE_STRICT_ARGS(
		age = human_mob.age,
		blood_type = dna.blood_type.name,
		unique_enzymes = dna.unique_enzymes,
		unique_identity = dna.unique_identity,
		fingerprint = md5(dna.unique_identity),
		gender = mob_occupant.gender,
		initial_rank = mob_occupant.mind?.assigned_role,
		name = mob_occupant.real_name,
		species = null /* Species */,
		datum_dna = dna,
		weakref_mind = WEAKREF(mob_occupant.mind),
		last_death = FALSE,
		factions = mob_occupant.faction,
		traumas = list(),
		body_only = body_only,
		implant = null,
		bank_account = has_bank_account))

	if(dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		dna.delete_species = FALSE
		cloning_record.species = dna.species
	else
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
		//Note: if you want to clone unusual species, you need to check 'carbon/human' rather than 'dna.species'

	if(experimental) //even if you have the same identity, this will give you different id based on your mind. body_only gets β at their id.
		cloning_record.id =  copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β+" //beta plus
	else if(body_only)
		cloning_record.id = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β" //beta
	else
		cloning_record.id = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 7)+copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.mind), -4)

	if(isbrain(mob_occupant)) //We'll detect the brain first because trauma is from the brain, not from the body.
		cloning_record.traumas = human_brain.get_traumas()
	else if(ishuman(mob_occupant))
		cloning_record.traumas = human_mob.get_traumas()
	//Traumas will be overriden if the brain transplant is made because '/obj/item/organ/brain/Insert' does that thing. This should be done since we want a monkey yelling to people with 'God voice syndrome'

	cloning_record.bank_account = has_bank_account
	if(!experimental)
		cloning_record.weakref_mind = WEAKREF(mob_occupant.mind)
		cloning_record.last_death = (mob_occupant.stat == DEAD && mob_occupant.mind) ? mob_occupant.mind.last_death : -1
		cloning_record.body_only = body_only
	else
		cloning_record.last_death = FALSE
		cloning_record.body_only = FALSE

	if(!body_only || experimental && mob_occupant.stat != DEAD)
		//Add an implant if needed
		var/obj/item/implant/health/implant
		for(var/obj/item/implant/health/health_implant in mob_occupant.implants)
			implant = health_implant
			break
		if(!implant)
			implant = new /obj/item/implant/health(mob_occupant)
			implant.implant(mob_occupant)
		cloning_record.implant = "[REF(implant)]"

	var/found_old_record = null
	for(var/datum/record/cloning/old_record as anything in records)
		if(old_record.id == cloning_record.id)
			found_old_record = old_record


	if(found_old_record)
		records -= found_old_record
		scantemp = "Record updated."
	else
		scantemp = "Subject successfully scanned."

	records += cloning_record

	if(!experimental)
		log_cloning("[user ? key_name(user) : "Autoprocess"] added the [body_only ? "body-only " : ""]record of [key_name(mob_occupant)] to [src] at [AREACOORD(src)].")
	else
		log_cloning("[user ? key_name(user) : "Autoprocess"] added the experimental record of [key_name(mob_occupant)] to [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50)
	ui_update()

//Prototype cloning console, much more rudimental and lacks modern functions such as saving records, autocloning, or safety checks.
/obj/machinery/computer/cloning/prototype
	name = "prototype cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning/prototype
	clonepod_type = /obj/machinery/clonepod/experimental
	experimental = TRUE

#undef AUTOCLONING_MINIMAL_LEVEL
