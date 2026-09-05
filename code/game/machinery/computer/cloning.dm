/obj/machinery/computer/cloning
	name = "cloning console"
	desc = "Used to clone people and manage DNA."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning
	req_access = list(ACCESS_GENETICS) //for modifying records

	var/clonepod_type = /obj/machinery/clonepod
	var/list/connected_pods //Linked cloning pods
	var/obj/machinery/dna_scannernew/connected_scanner //Linked scanner. For scanning.

	var/list/records = list()
	var/obj/item/disk/data/diskette //Incompatible format to genetics machine

	var/temp = "Inactive"
	var/scantemp_ckey
	var/scantemp_name
	var/scantemp = "Inactive"
	// ^EvilDragon: I have no idea regarding what these variables exist for

	/// The computer is doing something and cannot do something else. Currently used in scanning
	var/busy = FALSE

	/// Used for experimental cloning. experimental clone pod also needs to have this
	var/experimental = FALSE

	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/cloning/Initialize(mapload)
	. = ..()
	update_modules(find_clonepod_first = TRUE)

/obj/machinery/computer/cloning/Destroy()
	if(length(connected_pods))
		for(var/each_pod in connected_pods)
			detach_clonepod(each_pod)
		connected_pods = null
	return ..()

// --------------------------------------
// Manages a clone pod
/obj/machinery/computer/cloning/proc/find_clonepod()
	var/obj/machinery/clonepod/found_clonepod = null
	for(var/direction in GLOB.cardinals)
		found_clonepod = locate(clonepod_type, get_step(src, direction))
		if (!isnull(found_clonepod) && found_clonepod.is_operational)
			attach_clonepod(found_clonepod)
	// multiple clonepods can be attached to a single computer, so we don't do an early return

/obj/machinery/computer/cloning/proc/attach_clonepod(obj/machinery/clonepod/found_clonepod)
	if(!found_clonepod.connected)
		found_clonepod.connected = src
		LAZYADD(connected_pods, found_clonepod)

/obj/machinery/computer/cloning/proc/detach_clonepod(obj/machinery/clonepod/pod)
	pod.connected = null
	LAZYREMOVE(connected_pods, pod)

/obj/machinery/computer/cloning/proc/get_available_clonepod()
	if(!length(connected_pods))
		return
	for(var/obj/machinery/clonepod/each_pod as anything in connected_pods)
		if(each_pod.occupant || each_pod.attempting || each_pod.mess || !each_pod.is_operational)
			continue
		if(each_pod.connected != src)
			stack_trace("Clone pod is not connected to this cloning computer for an unknown reason.")
			continue
		return each_pod

// --------------------------------------
// Manages a scanner
/obj/machinery/computer/cloning/proc/find_scanner()
	var/obj/machinery/dna_scannernew/found_scanner
	for(var/direction in GLOB.cardinals)
		found_scanner = locate(/obj/machinery/dna_scannernew, get_step(src, direction))
		if(found_scanner?.is_operational)
			return found_scanner
	return null // no scanner found

/obj/machinery/computer/cloning/proc/connect_scanner(obj/machinery/dna_scannernew/new_scanner)
	if(connected_scanner)
		UnregisterSignal(connected_scanner, COMSIG_MACHINE_OPEN)
		UnregisterSignal(connected_scanner, COMSIG_MACHINE_CLOSE)

	if(new_scanner)
		RegisterSignal(new_scanner, COMSIG_MACHINE_OPEN, PROC_REF(scanner_ui_update))
		RegisterSignal(new_scanner, COMSIG_MACHINE_CLOSE, PROC_REF(scanner_ui_update))

	connected_scanner = new_scanner

/obj/machinery/computer/cloning/proc/scanner_ui_update()
	SIGNAL_HANDLER
	ui_update()

/obj/machinery/computer/cloning/proc/update_modules(find_clonepod_first)
	if(QDELETED(connected_scanner))
		connect_scanner(find_scanner())
	if(find_clonepod_first && !LAZYLEN(connected_pods))
		find_clonepod()

// --------------------------------------
// Other standard procs
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
			pod.connected.detach_clonepod(pod)
		attach_clonepod(pod)
	else
		if (TRY_STORE_IN_BUFFER(buffer_parent, src))
			to_chat(user, "<font color = #666633>-% Successfully stored [REF(src)] [name] in buffer %-</font color>")
	return COMPONENT_BUFFER_RECEIVED

/obj/machinery/computer/cloning/AltClick(mob/user)
	. = ..()
	if(!user.canUseTopic(src, !issilicon(user)))
		return
	eject_disk(user)

// --------------------------------------
// Manages record and disk
/obj/machinery/computer/cloning/proc/delete_record(mob/user, target_record)
	var/obj/item/card/id/idcard_for_auth = user.get_idcard(hand_first = TRUE)
	if(!istype(idcard_for_auth) || !check_access(idcard_for_auth))
		scantemp = "Cannot delete: Access Denied."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target_record)
			found_record = each_record
			break
	if(!found_record)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Cannot delete: Data Corrupted."
		return

	scantemp = "[found_record.name] => Record deleted."
	records.Remove(found_record)
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	qdel(found_record)

/obj/machinery/computer/cloning/proc/save_to_disk(mob/user, target_record)
	if(!diskette || diskette.read_only)
		scantemp = !diskette ? "Failed saving to disk: No disk." : "Failed saving to disk: Disk refuses override attempt."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target_record)
			found_record = each_record
			break
	if(!found_record)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Failed saving to disk: Data Corrupted"
		return

	QDEL_NULL(diskette.data)
	diskette.data = new /datum/record/cloning(RECORD_STRICT_ARGS_NONE)
	found_record.copy_to(diskette.data)

	diskette.name = "data disk - '[diskette.data.name]'"
	scantemp = "Saved to disk successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

/obj/machinery/computer/cloning/proc/load_from_disk(mob/user)
	if(!diskette || !diskette.data.name || !diskette.data)
		scantemp = "Failed loading: Load error."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == diskette.data.id)
			scantemp = "Failed loading: Data already exists!"
			return

	var/datum/record/cloning/new_record = new /datum/record/cloning(RECORD_STRICT_ARGS_NONE)
	diskette.data.copy_to(new_record)

	records += new_record
	scantemp = "Loaded into internal storage successfully."
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	return

/obj/machinery/computer/cloning/proc/eject_disk(mob/user)
	if(!diskette)
		return
	scantemp = "Disk Ejected"
	diskette.forceMove(drop_location())
	user.put_in_active_hand(diskette)
	diskette = null
	playsound(src, 'sound/machines/terminal_insert_disc.ogg', 50, FALSE)

/obj/machinery/computer/cloning/proc/toggle_lock(mob/user)
	if(!connected_scanner.is_operational)
		return
	if(!connected_scanner.locked && !connected_scanner.occupant) //I figured out that if you're fast enough, you can lock an open pod
		return
	connected_scanner.locked = !connected_scanner.locked
	playsound(src, connected_scanner.locked ? 'sound/machines/terminal_prompt_deny.ogg' : 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)

// --------------------------------------
// Actual clone codes / 1.scan procs / 2.clone proc
/obj/machinery/computer/cloning/proc/start_scan(mob/user, body_only = FALSE)
	if(isnull(connected_scanner) || !connected_scanner.is_operational || !connected_scanner.occupant)
		return
	if(busy)
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		scantemp = "Error: Too busy for scanning."
		return
	scantemp = "[scantemp_name] => Scanning..."
	busy = TRUE
	playsound(src, 'sound/machines/terminal_prompt.ogg', 50, 0)
	say("Initiating scan...")
	var/previous_lock_status = connected_scanner.locked
	connected_scanner.locked = TRUE
	addtimer(CALLBACK(src, PROC_REF(finish_scan), connected_scanner.occupant, user, previous_lock_status, body_only), 2 SECONDS)

/obj/machinery/computer/cloning/proc/finish_scan(mob/living/carbon_mob, mob/user, previous_lock_status, body_only)
	if(!connected_scanner || !carbon_mob)
		return
	add_fingerprint(user)
	scan_occupant(carbon_mob, user, body_only)

	busy = FALSE
	connected_scanner.locked = previous_lock_status
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
	SStgui.update_uis(src) // Immediate since it's not spammable

/obj/machinery/computer/cloning/proc/scan_occupant(atom/atom_occupant, mob/user, body_only)
	// Clone target variables
	var/mob/living/carbon/human/human_mob = ishuman(atom_occupant) ? atom_occupant : null
	var/mob/living/brain/brainmob = get_brainmob(atom_occupant)
	var/obj/item/organ/brain/brain_to_clone // Used when this code failed to find human_mob / brainmob (which means "atom_occupant" is an object and mindless)
	/* Note:
		Basically a minded mob can have 'brainmob' in their head or brain when they are beheaded
		but if a mob does not have any mind, they do not get brainmob.
		This is because letting ghosted players be able to find where their mind-holder exists.
		So, we should check when we clone mindless mobs
	*/
	var/datum/dna/dna
	var/datum/mind/occupant_mind
	var/datum/bank_account/has_bank_account

	// Scanning a mob; gets a human mob(likely not carbon) - We have a human body in the scanner (NOTE: carbon is not supported)
	if(human_mob)
		brain_to_clone = human_mob.get_organ_slot(ORGAN_SLOT_BRAIN)
		dna = human_mob.has_dna()
		occupant_mind = human_mob.mind // Reminder : might not exist
		var/obj/item/card/id/human_id_card = human_mob.get_idcard(TRUE)
		if(human_id_card)
			has_bank_account = human_id_card.registered_account

	// Scanning an object; gets a brain mob - We do not have a human body. We have a brain(or head) that holds a mind datum
	else if(brainmob)
		brain_to_clone = brainmob.loc
		dna = brainmob.stored_dna
		occupant_mind = brainmob.mind // Reminder : likely exist
		if(!istype(brain_to_clone, /obj/item/organ/brain))
			stack_trace("var 'brain_to_clone' is not /organ/brain for some reason. From brainmob: [brainmob]")
			brain_to_clone = null
	// Note: This might look equivalant from below, but items return "brainmob" if things have a mind(player)
	// I mean, this attempts to detect the thing from head/brain(object), but it is not actually an object (ARgh I hate this weird description)

	// Scanning an object; gets a brain item - Try to find a brain that holds a DNA
	else if(istype(occupant, /obj/item/bodypart/head)) // From head
		brain_to_clone = astype(occupant, /obj/item/bodypart/head).brain
		dna = brain_to_clone.brain_dna
		// occupant_mind = null // Reminder: does not exist. This line exists for a hint.
	else if(istype(occupant, /obj/item/organ/brain)) // From brain
		brain_to_clone = occupant
		dna = brain_to_clone.brain_dna
		// occupant_mind = null // Reminder: does not exist. This line exists for a hint.

	if(!can_scan(dna, human_mob, has_bank_account, body_only))
		return

	if(!dna.species)
		return //no dna info for species? you're not allowed to clone them. Don't harass xeno, don't try xeno farm.
		//Note: if you want to clone unusual species, you need to check 'carbon/human' rather than 'dna.species'

	var/datum/record/cloning/cloning_record = new(RECORD_CLONE_STRICT_ARGS(
		age = human_mob?.age || dna.age,
		blood_type = dna.blood_type.name,
		unique_enzymes = dna.unique_enzymes,
		unique_identity = dna.unique_identity,
		fingerprint = md5(dna.unique_identity),
		gender = human_mob?.gender || dna.gender,
		initial_rank = occupant_mind?.assigned_role,
		name = human_mob?.real_name || dna.real_name,
		species = null,
		datum_dna = dna /* the record will internally copy this dna datum */,
		weakref_mind = occupant_mind ? WEAKREF(occupant_mind) : null,
		last_death = experimental ? FALSE : (occupant_mind && occupant_mind.current.stat == DEAD) ? occupant_mind.last_death : -1,
		factions = human_mob?.faction.Copy(),
		traumas = null,
		body_only = experimental ? FALSE : body_only,
		weakref_health_implant = null,
		bank_account = has_bank_account))

	// We store the instance rather than the path,
	// because some species (abductors, slimepeople) store
	// state in their species datums
	cloning_record.datum_dna.delete_species = FALSE
	cloning_record.species = cloning_record.datum_dna.species
		// ^EvilDraogn: I do not understand what they are trying to say and do here by assigning the value FALSE

	//even if you have the same identity, this will give you different id based on your mind. body_only gets β at their id.
	if(experimental)
		cloning_record.id =  copytext_char(rustg_hash_string(RUSTG_HASH_MD5, cloning_record.name), 3, 10)+"β+" //beta plus
	else if(body_only)
		cloning_record.id = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, cloning_record.name), 3, 10)+"β" //beta
	else
		cloning_record.id = copytext_char(rustg_hash_string(RUSTG_HASH_MD5, cloning_record.name), 3, 7)+copytext_char(rustg_hash_string(RUSTG_HASH_MD5, FAST_REF(occupant_mind)), -4)

	//We'll detect the brain first because trauma is from the brain, not from the body.
	if(brainmob)
		cloning_record.traumas = brainmob.get_traumas()
	else if(human_mob)
		cloning_record.traumas = human_mob.get_traumas()
	else if(brain_to_clone)
		cloning_record.traumas = brain_to_clone.traumas.Copy()
	else
		cloning_record.traumas = list() // nothing to copy!
	//Traumas will be overriden if the brain transplant is made because '/obj/item/organ/brain/Insert' does that thing. This should be done since we want a monkey yelling to people with 'God voice syndrome'

	if(human_mob && (!body_only || experimental && human_mob.stat != DEAD))
		//Add an implant if needed
		var/obj/item/implant/health/implant = locate() in human_mob.implants
		if(!implant)
			implant = new /obj/item/implant/health()
			implant.implant(human_mob)
		cloning_record.weakref_health_implant = WEAKREF(implant)

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
		log_cloning("[key_name(user)] added the record[body_only ? "(body-only)" : ""] of [key_name(human_mob)](DNA-name:[dna.real_name]) to [src] at [AREACOORD(src)].")
	else
		log_cloning("[key_name(user)] added the record(experimental) of [key_name(human_mob)](DNA-name:[dna.real_name]) to [src] at [AREACOORD(src)].")
	playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50)
	ui_update()

/obj/machinery/computer/cloning/proc/can_scan(datum/dna/dna, mob/living/mob_occupant, datum/bank_account/account, body_only)
	if(!istype(dna))
		scantemp = "Unable to locate valid genetic data."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return FALSE
	if(isliving(mob_occupant))
		if(HAS_TRAIT(mob_occupant, TRAIT_NO_DNA_COPY))
			scantemp = "The DNA of this lifeform could not be read due to an unknown error!"
			playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
			return FALSE
		if((HAS_TRAIT(mob_occupant, TRAIT_HUSK)) && (connected_scanner.scan_level < 2))
			scantemp = "Subject's body is too damaged to scan properly."
			playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
			return FALSE
		if(HAS_TRAIT(mob_occupant, TRAIT_BADDNA))
			scantemp = "Subject's DNA is damaged beyond any hope of recovery."
			playsound(src, 'sound/machines/terminal_alert.ogg', 50, 0)
			return FALSE
		if(!experimental && !body_only)
			if(mob_occupant.suiciding)
				scantemp = "Subject's brain is not responding to scanning stimuli."
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				return FALSE
			if(isnull(mob_occupant.mind))
				scantemp = "Mental interface failure."
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
				return FALSE
			if(SSeconomy.full_ancap && !account)
				scantemp = "Subject is either missing an ID card with a bank account on it, or does not have an account to begin with. Please ensure the ID card is on the body before attempting to scan."
				playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, FALSE)
				return FALSE
	return TRUE

/obj/machinery/computer/cloning/proc/start_clone(mob/user, target_record)
	var/datum/record/cloning/found_record
	for(var/datum/record/cloning/each_record in records)
		if(each_record.id == target_record)
			found_record = each_record
			break
	if(!found_record)
		temp = "Failed to clone: No Data corrupted."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/obj/machinery/clonepod/pod = get_available_clonepod()
	//Can't clone without someone to clone.  Or a pod.  Or if the pod is busy. Or full of gibs.
	if(!LAZYLEN(connected_pods))
		temp = "Error: No Clonepods detected."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(!pod)
		temp = "Error: No Clonepods available."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if((!found_record.body_only || !experimental) && !CONFIG_GET(flag/revival_cloning))
		temp = "Error: Unable to initiate cloning cycle."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return
	if(pod.occupant)
		temp = "Warning: Cloning cycle already in progress."
		playsound(src, 'sound/machines/terminal_prompt_deny.ogg', 50, 0)
		return

	var/cloning_attempt_result = pod.growclone(CLONING_STRICT_ARGS(
		/* 01 */ clonename = found_record.name,
		/* 02 */ unique_identity = found_record.unique_identity,
		/* 03 */ mutation_index = found_record.datum_dna.mutation_index.Copy(),
		/* 04 */ given_mind = found_record.resolve_mind(),
		/* 05 */ last_death = found_record.last_death,
		/* 06 */ mrace = found_record.species,
		/* 07 */ features = found_record.datum_dna.features.Copy(),
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
		if(CLONING_SUCCESS_EXPERIMENTAL)
			temp = "Notice: [found_record.name] => Experimental cloning cycle in progress..."
			playsound(src, 'sound/machines/terminal_prompt_confirm.ogg', 50, 0)
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

// --------------------------------------
// TGUI parts
/obj/machinery/computer/cloning/ui_data(mob/user)
	var/list/data = list()
	data["useRecords"] = TRUE // This exists because of the old function.
	data["records"] = list()
	for(var/datum/record/cloning/each_record in records)
		var/list/record_entry = list()
		record_entry["name"] = "[each_record.name]"
		record_entry["id"] = "[each_record.id]"
		var/obj/item/implant/health/health_imp = each_record.weakref_health_implant?.resolve()
		if(health_imp)
			record_entry["damages"] = health_imp.sensehealth(TRUE)
		else
			record_entry["damages"] = FALSE
		record_entry["UI"] = "[each_record.unique_identity]"
		record_entry["UE"] = "[each_record.unique_enzymes]"
		record_entry["blood_type"] = "[each_record.blood_type]"
		record_entry["last_death"] = each_record.last_death
		record_entry["body_only"] = each_record.body_only

		data["records"] += list(record_entry)
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
	var/list/lack_machine = list()
	if(isnull(connected_scanner))
		lack_machine += "ERROR: No Scanner Detected!"
	if(!LAZYLEN(connected_pods))
		lack_machine += "ERROR: No Pod Detected!"
	data["lacksMachine"] = lack_machine
	data["temp"] = temp
	var/build_temp = null
	var/mob/living/scanner_occupant = connected_scanner && (isliving(connected_scanner.occupant) ? connected_scanner.occupant : get_brainmob(connected_scanner.occupant))
	if(scanner_occupant?.ckey != scantemp_ckey || scanner_occupant?.name != scantemp_name)
		build_temp = "Ready to Scan"
		scantemp_ckey = scanner_occupant?.ckey
		scantemp_name = scanner_occupant?.name
		scantemp = "[scanner_occupant] => [build_temp]"
	data["scanTemp"] = scantemp
	data["scannerLocked"] = connected_scanner?.locked
	data["hasOccupant"] = connected_scanner?.occupant
	data["recordsLength"] = "View Records ([length(records)])"
	data["experimental"] = experimental
	data["diskette"] = diskette
	return data

/obj/machinery/computer/cloning/ui_act(action, params)
	if(..())
		return

	// Return TRUE on almost every operation, since operations write to temp and scantemp to display failure messages
	switch(action)
		if("scan")
			start_scan(usr, FALSE)
			return TRUE
		if("scan_body_only")
			start_scan(usr, TRUE)
			return TRUE
		if("clone")
			start_clone(usr, target_record = params["target"])
			return TRUE
		if("delrecord")
			delete_record(usr, target_record = params["target"])
			return TRUE
		if("save")
			save_to_disk(usr, target_record = params["target"])
			return TRUE
		if("load")
			load_from_disk(usr)
			return TRUE
		if("eject")
			eject_disk(usr)
			return TRUE
		if("toggle_lock")
			toggle_lock(usr)
			return TRUE

/obj/machinery/computer/cloning/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	update_modules(find_clonepod_first = TRUE)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CloningConsole", "Cloning System Control")
		ui.open()
		ui.set_autoupdate(TRUE)

//Prototype cloning console, that cannot clone a person as how they really are - experimental clone, individual identities
/obj/machinery/computer/cloning/prototype
	name = "prototype cloning console"
	desc = "Used to operate an experimental cloner."
	icon_screen = "dna"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/cloning/prototype
	clonepod_type = /obj/machinery/clonepod/experimental
	experimental = TRUE
