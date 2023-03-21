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
	var/datum/data/record/active_record
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
		for(var/P in pods)
			DetachCloner(P)
		pods = null
	return ..()

/obj/machinery/computer/cloning/proc/GetAvailablePod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.occupant && pod.clonemind == mind)
				return null
			if(pod.is_operational && !(pod.occupant || pod.mess))
				return pod

/obj/machinery/computer/cloning/proc/HasEfficientPod()
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.is_operational && pod.efficiency > 5)
				return TRUE

/obj/machinery/computer/cloning/proc/GetAvailableEfficientPod(mind = null)
	if(pods)
		for(var/P in pods)
			var/obj/machinery/clonepod/pod = P
			if(pod.occupant && pod.clonemind == mind)
				return pod
			else if(!. && pod.is_operational && !(pod.occupant || pod.mess) && pod.efficiency > 5)
				. = pod

/proc/grow_clone_from_record(obj/machinery/clonepod/pod, datum/data/record/R, experimental)
	return pod.growclone(R.fields["name"], R.fields["UI"], R.fields["SE"], R.fields["mindref"], R.fields["last_death"], R.fields["mrace"], R.fields["features"], R.fields["factions"], R.fields["quirks"], R.fields["bank_account"], R.fields["traumas"], R.fields["body_only"], experimental)

/obj/machinery/computer/cloning/process()
	if(!(scanner && LAZYLEN(pods) && autoprocess))
		return

	if(scanner.occupant && scanner.scan_level > 2)
		scan_occupant(scanner.occupant)
		ui_update()

	for(var/datum/data/record/R in records)
		var/obj/machinery/clonepod/pod = GetAvailableEfficientPod(R.fields["mindref"])

		if(!pod)
			return

		if(pod.occupant)
			break

		var/result = grow_clone_from_record(pod, R, experimental)
		if(result & CLONING_SUCCESS)
			temp = "[R.fields["name"]] => Cloning cycle in progress..."
			log_cloning("Cloning of [key_name(R.fields["mindref"])] automatically started via autoprocess - [src] at [AREACOORD(src)]. Pod: [pod] at [AREACOORD(pod)].")
			SStgui.update_uis(src)
		if(result & CLONING_DELETE_RECORD)
			records -= R
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

/obj/machinery/computer/cloning/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/disk/data)) //INSERT SOME DISKETTES
		if (!diskette)
			if (!user.transferItemToLoc(W,src))
				return
			diskette = W
			to_chat(user, "<span class='notice'>You insert [W].</span>")
			playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
	else if(W.tool_behaviour == TOOL_MULTITOOL)
		if(!multitool_check_buffer(user, W))
			return
		var/obj/item/multitool/P = W

		if(istype(P.buffer, /obj/machinery/clonepod))
			if(get_area(P.buffer) != get_area(src))
				to_chat(user, "<font color = #666633>-% Cannot link machines across power zones. Buffer cleared %-</font color>")
				P.buffer = null
				return
			to_chat(user, "<font color = #666633>-% Successfully linked [P.buffer] with [src] %-</font color>")
			var/obj/machinery/clonepod/pod = P.buffer
			if(pod.connected)
				pod.connected.DetachCloner(pod)
			AttachCloner(pod)
		else
			P.buffer = src
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(P.buffer)] [P.buffer.name] in buffer %-</font color>")
		return
	else
		return ..()

/obj/machinery/computer/cloning/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	EjectDisk(user)

/obj/machinery/computer/cloning/proc/EjectDisk(mob/user)
	if(diskette)
		scantemp = "Disk Ejected"
		diskette.forceMove(drop_location())
		usr.put_in_active_hand(diskette)
		diskette = null
		playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, 0)
		. = TRUE

/obj/machinery/computer/cloning/proc/Save(mob/user, target)
	var/datum/data/record/GRAB = null
	for(var/datum/data/record/record in records)
		if(record.fields["id"] == target)
			GRAB = record
			break
		else
			continue
	if(!GRAB || !GRAB.fields)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Failed saving to disk: Data Corruption"
		return FALSE
	if(!diskette || diskette.read_only)
		scantemp = !diskette ? "Failed saving to disk: No disk." : "Failed saving to disk: Disk refuses override attempt."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	diskette.fields = GRAB.fields.Copy()
	diskette.name = "data disk - '[src.diskette.fields["name"]]'"
	scantemp = "Saved to disk successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/DeleteRecord(mob/user, target)
	var/datum/data/record/GRAB = null
	for(var/datum/data/record/record in records)
		if(record.fields["id"] == target)
			GRAB = record
			break
		else
			continue
	if(!GRAB)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Cannot delete: Data Corrupted."
		return FALSE
	var/obj/item/card/id/C = usr.get_idcard(hand_first = TRUE)
	if(istype(C) || istype(C, /obj/item/modular_computer/tablet))
		if(check_access(C))
			scantemp = "[GRAB.fields["name"]] => Record deleted."
			records.Remove(GRAB)
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
			var/obj/item/circuitboard/computer/cloning/board = circuit
			board.records = records
			return TRUE
	scantemp = "Cannot delete: Access Denied."
	playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/Load(mob/user)
	if(!diskette || !istype(diskette.fields) || !diskette.fields["name"] || !diskette.fields)
		scantemp = "Failed loading: Load error."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	for(var/datum/data/record/R in records)
		if(R.fields["id"] == diskette.fields["id"])
			scantemp = "Failed loading: Data already exists!"
			return FALSE
	var/datum/data/record/R = new(src)
	for(var/each in diskette.fields)
		R.fields[each] = diskette.fields[each]

	records += R
	scantemp = "Loaded into internal storage successfully."
	var/obj/item/circuitboard/computer/cloning/board = circuit
	board.records = records
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return TRUE

/obj/machinery/computer/cloning/proc/Clone(mob/user, target)
	var/datum/data/record/C = find_record("id", target, records)
	//Look for that player! They better be dead!
	if(C)
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
			switch(pod.growclone(C.fields["name"], C.fields["UI"], C.fields["SE"], C.fields["mindref"], C.fields["last_death"], C.fields["mrace"], C.fields["features"], C.fields["factions"], C.fields["quirks"], C.fields["bank_account"], C.fields["traumas"], C.fields["body_only"], experimental))
				if(CLONING_SUCCESS)
					temp = "Notice: [C.fields["name"]] => Cloning cycle in progress..."
					playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
					if(!C.fields["body_only"])
						records.Remove(C)
					return TRUE
				if(CLONING_SUCCESS_EXPERIMENTAL)
					temp = "Notice: [C.fields["name"]] => Experimental cloning cycle in progress..."
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
					temp = "Error [ERROR_NOT_MIND]: [C.fields["name"]]'s lack of their mind."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_PRESAVED_CLONE)
					temp = "Error [ERROR_PRESAVED_CLONE]: [C.fields["name"]]'s clone record is presaved."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_OUTDATED_CLONE)
					temp = "Error [ERROR_OUTDATED_CLONE]: [C.fields["name"]]'s clone record is outdated."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_ALREADY_ALIVE)
					temp = "Error [ERROR_ALREADY_ALIVE]: [C.fields["name"]] already alive."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_COMMITED_SUICIDE)
					temp = "Error [ERROR_COMMITED_SUICIDE]: [C.fields["name"]] commited a suicide."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_SOUL_DEPARTED)
					temp = "Error [ERROR_SOUL_DEPARTED]: [C.fields["name"]]'s soul had departed."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_SUICIDED_BODY)
					temp = "Error [ERROR_SUICIDED_BODY]: Failed to capture [C.fields["name"]]'s mind from a suicided body."
					playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				if(ERROR_SOUL_DAMNED)
					temp = "Err#^ [ERROR_SOUL_DAMNED]: #$%SGFG$#their@soul&is$mine@#%# => 1(i*i@%i$(t!0n $A!l^r#."
				if(ERROR_UNCLONABLE)
					temp = "Error [ERROR_UNCLONABLE]: [C.fields["name"]] is not clonable."
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
			for(var/datum/data/record/R in records)
				var/list/record_entry = list()
				record_entry["name"] = "[R.fields["name"]]"
				record_entry["id"] = "[R.fields["id"]]"
				var/obj/item/implant/health/H = locate(R.fields["imp"])
				if(H && istype(H))
					record_entry["damages"] = H.sensehealth(TRUE)
				else
					record_entry["damages"] = FALSE
				record_entry["UI"] = "[R.fields["UI"]]"
				record_entry["UE"] = "[R.fields["UE"]]"
				record_entry["blood_type"] = "[R.fields["blood_type"]]"
				record_entry["last_death"] = R.fields["last_death"]
				record_entry["body_only"] = R.fields["body_only"]
				records_to_send += list(record_entry)
			data["records"] = records_to_send
		else
			data["records"] = list()
		if(diskette && diskette.fields)
			var/list/disk_data = list()
			disk_data["name"] = "[diskette.fields["name"]]"
			disk_data["id"] = "[diskette.fields["id"]]"
			disk_data["UI"] = "[diskette.fields["UI"]]"
			disk_data["UE"] = "[diskette.fields["UE"]]"
			disk_data["blood_type"] = "[diskette.fields["blood_type"]]"
			disk_data["last_death"] = diskette.fields["last_death"]
			disk_data["body_only"] = diskette.fields["body_only"]
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
			Save(usr, params["target"])
			. = TRUE
		if("load")
			Load(usr)
			. = TRUE
		if("eject")
			. = EjectDisk(usr)

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	updatemodules(TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning System Control")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/cloning/proc/finish_scan(mob/living/L, mob/user, prev_locked, body_only)
	if(!scanner || !L)
		return
	src.add_fingerprint(usr)
	if(use_records)
		scan_occupant(L, user, body_only)
	else
		clone_occupant(L, user)

	loading = FALSE
	scanner.locked = prev_locked
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	SStgui.update_uis(src) // Immediate since it's not spammable

//Used by consoles without records
/obj/machinery/computer/cloning/proc/clone_occupant(occupant, mob/user)
	var/mob/living/mob_occupant = get_mob_or_brainmob(occupant)
	var/datum/dna/dna
	if(ishuman(mob_occupant))
		var/mob/living/carbon/C = mob_occupant
		dna = C.has_dna()
	if(isbrain(mob_occupant))
		var/mob/living/brain/B = mob_occupant
		dna = B.stored_dna
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
		pod.growclone(mob_occupant.real_name, dna.uni_identity, dna.mutation_index, null, null, clone_species, dna.blood_type, mob_occupant.faction)
		temp = "[mob_occupant.real_name] => Cloning data sent to pod."
		playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
		log_cloning("[user ? key_name(user) : "Unknown"] cloned [key_name(mob_occupant)] with [src] at [AREACOORD(src)].")

/obj/machinery/computer/cloning/proc/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/bank_account/account, body_only)
	if(!istype(dna))
		scantemp = "Unable to locate valid genetic data."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if(NO_DNA_COPY in dna.species.species_traits)
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
		if(!body_only && (mob_occupant.suiciding || mob_occupant.ishellbound()))
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
	var/mob/living/carbon/C = mob_occupant
	var/mob/living/brain/B = mob_occupant

	if(ishuman(mob_occupant))
		dna = C.has_dna()
		var/obj/item/card/id/I = C.get_idcard(TRUE)
		if(I)
			has_bank_account = I.registered_account
	if(isbrain(mob_occupant))
		dna = B.stored_dna

	if(!can_scan(dna, mob_occupant, has_bank_account, body_only))
		return

	var/datum/data/record/R = new()
	if(dna.species)
		// We store the instance rather than the path, because some
		// species (abductors, slimepeople) store state in their
		// species datums
		dna.delete_species = FALSE
		R.fields["mrace"] = dna.species
	else
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
		//Note: if you want to clone unusual species, you need to check 'carbon/human' rather than 'dna.species'

	R.fields["name"] = mob_occupant.real_name
	if(experimental) //even if you have the same identity, this will give you different id based on your mind. body_only gets β at their id.
		R.fields["id"] =  copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β+" //beta plus
	else if(body_only)
		R.fields["id"] = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 10)+"β" //beta
	else
		R.fields["id"] = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.real_name), 3, 7)+copytext_char(rustg_hash_string(RUSTG_HASH_MD5, mob_occupant.mind), -4)
	R.fields["UE"] = dna.unique_enzymes
	R.fields["UI"] = dna.uni_identity
	R.fields["SE"] = dna.mutation_index
	R.fields["blood_type"] = dna.blood_type
	R.fields["features"] = dna.features
	R.fields["factions"] = mob_occupant.faction
	R.fields["quirks"] = list()
	R.fields["traumas"] = list()
	if(!body_only || experimental) //Body only will not copy quirks.
		for(var/V in mob_occupant.roundstart_quirks)
			var/datum/quirk/T = V
			R.fields["quirks"][T.type] = T.clone_data()
			/*
			Quirks 'should be' personal features from a brain, not a body. but quirks actually come from a body.
			This will not transfer your quirks if your brain is transfered to the body_only cloned body, because someone's brain in your clone is not a musician/smoker/brain-tumored or something else.
			This is likely a bug from the structure of quirks. We need to fix the quirk code.
			*/

	if(isbrain(mob_occupant)) //We'll detect the brain first because trauma is from the brain, not from the body.
		R.fields["traumas"] = B.get_traumas()
	else if(ishuman(mob_occupant))
		R.fields["traumas"] = C.get_traumas()
	//Traumas will be overriden if the brain transplant is made because '/obj/item/organ/brain/Insert' does that thing. This should be done since we want a monkey yelling to people with 'God voice syndrome'

	R.fields["bank_account"] = has_bank_account
	if(!experimental)
		R.fields["mindref"] = "[REF(mob_occupant.mind)]"
		R.fields["last_death"] = (mob_occupant.stat == DEAD && mob_occupant.mind) ? mob_occupant.mind.last_death : -1
		R.fields["body_only"] = body_only
	else
		R.fields["last_death"] = 0
		R.fields["body_only"] = 0

	if(!body_only || experimental && mob_occupant.stat != DEAD)
	    //Add an implant if needed
		var/obj/item/implant/health/imp
		for(var/obj/item/implant/health/HI in mob_occupant.implants)
			imp = HI
			break
		if(!imp)
			imp = new /obj/item/implant/health(mob_occupant)
			imp.implant(mob_occupant)
		R.fields["imp"] = "[REF(imp)]"

	var/datum/data/record/old_record = find_record("id", R.fields["id"], records)
	if(old_record)
		records -= old_record
		scantemp = "Record updated."
	else
		scantemp = "Subject successfully scanned."
	records += R

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
