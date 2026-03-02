/*
 * Cryogenic refrigeration unit. Basically a despawner.
 * Stealing a lot of concepts/code from sleepers due to massive laziness.
 * The despawn tick will only fire if it's been more than time_till_despawned ticks
 * since time_entered, which is world.time when the occupant moves in.
 * ~ Zuhayr
 */
GLOBAL_LIST_EMPTY(cryopod_computers)

//Main cryopod console.

/obj/machinery/computer/cryopod
	name = "cryogenic oversight console"
	desc = "An interface between crew and the cryogenic storage oversight systems."
	icon = 'icons/obj/Cryogenic2.dmi'
	icon_state = "cellconsole_1"

	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

	// circuit = /obj/item/circuitboard/cryopodcontrol
	density = FALSE
	layer = ABOVE_WINDOW_LAYER
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE
	req_one_access = list(ACCESS_HEADS, ACCESS_ARMORY) //Heads of staff or the warden can go here to claim recover items from their department that people went were cryodormed with.
	var/mode = null

	//Used for logging people entering cryosleep and important items they are carrying.
	var/list/frozen_crew = list()
	var/list/frozen_items = list()

	var/storage_type = "crewmembers"
	var/storage_name = "Cryogenic Oversight Control"
	var/allow_items = TRUE

/obj/machinery/computer/cryopod/Initialize(mapload)
	. = ..()
	GLOB.cryopod_computers += src

/obj/machinery/computer/cryopod/Destroy()
	GLOB.cryopod_computers -= src
	..()

/obj/machinery/computer/cryopod/attack_silicon()
	return attack_hand()

/obj/machinery/computer/cryopod/attack_hand(mob/user = usr)
	if(machine_stat & (NOPOWER|BROKEN))
		return

	user.set_machine(src)
	add_fingerprint(user)

	var/dat

	dat += "<hr/><br/><b>[storage_name]</b><br/>"
	dat += "<i>Welcome, [user.real_name].</i><br/><br/><hr/>"
	dat += "<a href='byond://?src=[REF(src)];log=1'>View storage log</a>.<br>"
	if(allow_items)
		dat += "<a href='byond://?src=[REF(src)];view=1'>View objects</a>.<br>"
		dat += "<a href='byond://?src=[REF(src)];item=1'>Recover object</a>.<br>"
		dat += "<a href='byond://?src=[REF(src)];allitems=1'>Recover all objects</a>.<br>"

	user << browse(HTML_SKELETON(dat), "window=cryopod_console")
	onclose(user, "cryopod_console")

/obj/machinery/computer/cryopod/Topic(href, href_list)
	if(..())
		return 1

	var/mob/user = usr

	add_fingerprint(user)

	if(href_list["log"])

		var/dat = "<b>Recently stored [storage_type]</b><br/><hr/><br/>"
		for(var/person in frozen_crew)
			dat += "[person]<br/>"
		dat += "<hr/>"

		user << browse(HTML_SKELETON(dat), "window=cryolog")

	if(href_list["view"])
		if(!allow_items) return

		var/dat = "<b>Recently stored objects</b><br/><hr/><br/>"
		for(var/obj/item/I in frozen_items)
			dat += "[I.name]<br/>"
		dat += "<hr/>"

		user << browse(HTML_SKELETON(dat), "window=cryoitems")

	else if(href_list["item"])
		if(!allowed(user))
			to_chat(user, span_warning("Access Denied."))
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, span_notice("There is nothing to recover from storage."))
			return

		var/obj/item/I = input(user, "Please choose which object to retrieve.","Object recovery",null) as null|anything in frozen_items
		if(!I)
			return

		if(!(I in frozen_items))
			to_chat(user, span_notice("\The [I] is no longer in storage."))
			return

		visible_message(span_notice("The console beeps happily as it disgorges \the [I]."))

		I.forceMove(get_turf(src))
		frozen_items -= I

	else if(href_list["allitems"])
		if(!allowed(user))
			to_chat(user, span_warning("Access Denied."))
			return
		if(!allow_items) return

		if(frozen_items.len == 0)
			to_chat(user, span_notice("There is nothing to recover from storage."))
			return

		visible_message(span_notice("The console beeps happily as it disgorges the desired objects."))

		for(var/obj/item/I in frozen_items)
			I.forceMove(get_turf(src))
			frozen_items -= I

	updateUsrDialog()
	return
/* Should more cryos be buildable?
	/obj/item/circuitboard/cryopodcontrol
	name = "Circuit board (Cryogenic Oversight Console)"
	build_path = "/obj/machinery/computer/cryopod"
	origin_tech = "programming=1"
*/
//Cryopods themselves.
/obj/machinery/cryopod
	name = "cryogenic freezer"
	desc = "Suited for Cyborgs and Humanoids, the pod is a safe place for personnel affected by the Space Sleep Disorder to get some rest."
	icon = 'icons/obj/cryogenic2.dmi'
	icon_state = "cryopod-open"
	density = TRUE
	anchored = TRUE
	state_open = TRUE

	var/on_store_message = "has entered long-term storage."
	var/on_store_name = "Cryogenic Oversight"

	// 5 minutes-ish safe period before being despawned.
	var/time_till_despawn = 5 MINUTES // Players are ghosted immediately if they manually chose to enter cryo
	var/despawn_world_time = null // Used to keep track of the safe period.
	var/ghost_offering = FALSE //Sets to true when the occupant is currently being offered to ghosts, to pause despawning them

	var/datum/weakref/control_computer_weakref
	var/last_no_computer_message = 0

	// These items are preserved when the process() despawn proc occurs.
	var/static/list/preserve_items = list(
		/obj/item/hand_tele,
		/obj/item/card/id/captains_spare,
		/obj/item/aicard,
		/obj/item/mmi,
		/obj/item/paicard,
		/obj/item/gun,
		/obj/item/pinpointer,
		/obj/item/clothing/shoes/magboots,
		/obj/item/areaeditor/blueprints,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor,
		/obj/item/defibrillator/compact,
		/obj/item/reagent_containers/hypospray/CMO,
		/obj/item/clothing/accessory/medal/gold/captain,
		/obj/item/clothing/gloves/krav_maga,
		/obj/item/nullrod,
		/obj/item/tank/jetpack,
		/obj/item/documents,
		/obj/item/nuke_core_container
	)

/obj/machinery/cryopod/Initialize(mapload)
	..()
	return INITIALIZE_HINT_LATELOAD //Gotta populate the cryopod computer GLOB first

/obj/machinery/cryopod/LateInitialize()
	update_icon()
	find_control_computer()

// This is not a good situation
/obj/machinery/cryopod/Destroy()
	control_computer_weakref = null
	return ..()

/obj/machinery/cryopod/proc/find_control_computer(urgent = FALSE)
	for(var/cryo_console as anything in GLOB.cryopod_computers)
		var/obj/machinery/computer/cryopod/console = cryo_console
		if(get_area(console) == get_area(src))
			control_computer_weakref = WEAKREF(console)
			break

	// Don't send messages unless we *need* the computer, and less than five minutes have passed since last time we messaged
	if(!control_computer_weakref && urgent && last_no_computer_message + 5*60*10 < world.time)
		log_admin("Cryopod in [get_area(src)] could not find control computer!")
		message_admins("Cryopod in [get_area(src)] could not find control computer!")
		last_no_computer_message = world.time

	return control_computer_weakref != null

/obj/machinery/cryopod/close_machine(mob/user)
	if(!control_computer_weakref)
		find_control_computer(TRUE)
	if((isnull(user) || istype(user)) && state_open && !panel_open)
		..(user)
		var/mob/living/mob_occupant = occupant
		if(mob_occupant && mob_occupant.stat != DEAD)
			to_chat(occupant, span_boldnotice("You feel cool air surround you. You go numb as your senses turn inward."))
		if(mob_occupant.client)
			despawn_world_time = world.time //If they are logged in and actively chose to cryo themselves, they are immediately offered
		else
			despawn_world_time = world.time + time_till_despawn
	icon_state = "cryopod"

/obj/machinery/cryopod/open_machine()
	..()
	ghost_offering = FALSE
	icon_state = "cryopod-open"
	set_density(TRUE)
	name = initial(name)

/obj/machinery/cryopod/container_resist(mob/living/user)
	visible_message(span_notice("[occupant] emerges from [src]!"),
		span_notice("You climb out of [src]!"))
	open_machine()

/obj/machinery/cryopod/relaymove(mob/user)
	container_resist(user)

/obj/machinery/cryopod/process()
	if(!occupant || ghost_offering)
		return

	var/mob/living/mob_occupant = occupant
	if(mob_occupant)
		// Eject people that are incapacitated
		if(mob_occupant.stat)
			open_machine()

		//The grace period isn't up yet
		if(!(world.time > despawn_world_time))
			return

		if (!mob_occupant.mind)
			despawn_occupant()
			return

		//Offer special roles to ghosts and pause processing while we do
		var/highest_leave = ANTAGONIST_LEAVE_DESPAWN
		for (var/datum/antagonist/antagonist_datum in mob_occupant.mind.antag_datums)
			highest_leave = max(highest_leave, antagonist_datum.leave_behaviour)
		// Determine how we should handle our leaving
		ghost_offering = TRUE
		switch (highest_leave)
			if (ANTAGONIST_LEAVE_DESPAWN)
				INVOKE_ASYNC(src, PROC_REF(leave_game), mob_occupant)
			if (ANTAGONIST_LEAVE_OFFER)
				INVOKE_ASYNC(src, PROC_REF(offering_to_ghosts), mob_occupant)
			if (ANTAGONIST_LEAVE_KEEP)
				INVOKE_ASYNC(src, PROC_REF(persistent_offer_to_ghosts), mob_occupant)

/obj/machinery/cryopod/proc/persistent_offer_to_ghosts(mob/living/target)
	if(target.client && tgui_alert(target, "Would you like to leave the game? Your character will be automatically offered to other players.", "Leave Game", list("Yes", "No")) != "Yes")
		if (target.client)
			open_machine()
			return
	target.ghostize(FALSE)
	offer_control_persistently(target)

/obj/machinery/cryopod/proc/offering_to_ghosts(mob/living/target)
	if(target.client && tgui_alert(target, "Would you like to leave the game? Your character will be automatically offered to other players.", "Leave Game", list("Yes", "No")) != "Yes")
		if (target.client)
			open_machine()
			return
	target.ghostize(FALSE)
	if(offer_control(target))
		open_machine()
	else
		despawn_occupant()

/obj/machinery/cryopod/proc/leave_game(mob/living/target)
	if(target.client && tgui_alert(target, "Would you like to leave the game? You will immediately be ghosted.", "Leave Game", list("Yes", "No")) != "Yes")
		if (target.client)
			open_machine()
			return
	despawn_occupant()

// This function can not be undone; do not call this unless you are sure
/obj/machinery/cryopod/proc/despawn_occupant()
	ghost_offering = FALSE
	//Last chance to find this computer if it exists
	if(!control_computer_weakref)
		find_control_computer(urgent = TRUE)

	var/mob/living/mob_occupant = occupant

	if(mob_occupant.mind && mob_occupant.mind.assigned_role)
		//Handle job slot/tater cleanup.
		var/job = mob_occupant.mind.assigned_role
		SSjob.FreeRole(job)

	// Delete them from manifest.

	var/announce_rank = null
	for(var/datum/record/crew/R as() in GLOB.manifest.general)
		if((R.name == mob_occupant.real_name))
			announce_rank = R.rank
			qdel(R)


	for(var/obj/machinery/computer/cloning/cloner in GLOB.machines)
		for(var/datum/record/R as() in cloner.records)
			if(R.name == mob_occupant.real_name)
				cloner.records.Remove(R)

	//Make an announcement and log the person entering storage.
	var/obj/machinery/computer/cryopod/control_computer = control_computer_weakref?.resolve()
	if(!control_computer)
		control_computer_weakref = null
	else
		control_computer.frozen_crew += "[mob_occupant.real_name]"

	if(GLOB.announcement_systems.len)
		var/obj/machinery/announcement_system/announcer = pick(GLOB.announcement_systems)
		if(mob_occupant.job == JOB_NAME_CAPTAIN)
			minor_announce("[JOB_NAME_CAPTAIN] [mob_occupant.real_name] has entered cryogenic storage.")  // for when the admins do a stupid british gimmick that makes 0 sense cough
		else
			announcer.announce("CRYOSTORAGE", mob_occupant.real_name, announce_rank, list())
		visible_message(span_notice("\The [src] hums and hisses as it moves [mob_occupant.real_name] into storage."))


	for(var/obj/item/W in mob_occupant.GetAllContents())
		if(W.loc.loc && (( W.loc.loc == loc ) || (W.loc.loc == control_computer)))
			continue//means we already moved whatever this thing was in
			//I'm a professional, okay
		for(var/T in preserve_items)
			if(istype(W, T))
				if(control_computer && control_computer.allow_items)
					control_computer.frozen_items += W
					mob_occupant.transferItemToLoc(W, control_computer, TRUE)
				else
					mob_occupant.transferItemToLoc(W, loc, TRUE)

	for(var/obj/item/W in mob_occupant.GetAllContents())
		if(istype(W, /obj/item/organ) || istype(W, /obj/item/bodypart))
			continue
		qdel(W)//because we moved all items to preserve away
		//and yes, this totally deletes their bodyparts one by one, I just couldn't bother
		//This method is shit, thanks jlsnow, but atleast mobs shouldnt fucking explode anymore

	// Suspend their bank payment
	if(mob_occupant.mind?.account_id)
		var/datum/bank_account/target_account = SSeconomy.get_bank_account_by_id(mob_occupant.mind.account_id)
		if(target_account)
			for(var/D in target_account.payment_per_department)
				target_account.payment_per_department[D] = 0
				target_account.bonus_per_department[D] = 0
			target_account.suspended = TRUE // bank account will not be deleted, just suspended

	// This should be done after item removal because it checks if your ID card still exists

	if(iscyborg(mob_occupant))
		var/mob/living/silicon/robot/R = occupant
		if(!istype(R)) return

		R.contents -= R.mmi
		QDEL_NULL(R.mmi)

	// Ghost and delete the mob.
	if(!mob_occupant.get_ghost(TRUE))
		if(world.time - SSticker.round_start_time < 15 MINUTES)//before the 15 minute mark
			mob_occupant.ghostize(FALSE,SENTIENCE_ERASE) // Players despawned too early may not re-enter the game
		else
			mob_occupant.ghostize(TRUE,SENTIENCE_ERASE)
	if(mob_occupant.mind)
		mob_occupant.mind.cryoed = TRUE
		SEND_SIGNAL(mob_occupant.mind, COMSIG_MIND_CRYOED)

	// This is stupid, I know
	var/mob/dead/observer/ghost = mob_occupant.get_ghost(TRUE)
	if (ghost)
		ghost.remove_from_current_dead_players()
		ghost.started_as_observer = TRUE
		ghost.add_to_current_dead_players()

	QDEL_NULL(occupant)
	open_machine()
	name = initial(name)

/obj/machinery/cryopod/MouseDrop_T(mob/living/target, mob/user)
	if(!istype(target) || user.incapacitated || !target.Adjacent(user) || !Adjacent(user) || !ismob(target) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return

	if(!target.mind)
		to_chat(user, span_notice("[target] is not a player controlled mob."))
		return
	if(occupant)
		to_chat(user, span_boldnotice("The cryo pod is already occupied!"))
		return

	if(target.stat == DEAD)
		to_chat(user, span_notice("Dead people can not be put into cryo."))
		return

	if(target.client && user != target)
		if(iscyborg(target))
			to_chat(user, span_danger("You can't put [target] into [src]. They're online."))
		else
			to_chat(user, span_danger("You can't put [target] into [src]. They're conscious."))
		return
	else if(target.client)
		if(alert(target,"Would you like to enter cryosleep?",,"Yes","No") != "Yes")
			return

	if(!target || user.incapacitated || !target.Adjacent(user) || !Adjacent(user) || (!ishuman(user) && !iscyborg(user)) || !istype(user.loc, /turf) || target.buckled)
		return
		//rerun the checks in case of shenanigans

	if(target == user)
		visible_message("[user] starts climbing into the cryo pod.")
	else
		visible_message("[user] starts putting [target] into the cryo pod.")

	if(occupant)
		to_chat(user, span_boldnotice("\The [src] is in use."))
		return
	close_machine(target)

	if((world.time - SSticker.round_start_time) < 5 MINUTES)
		message_admins("[span_danger("[key_name_admin(target)], the [target.job] entered a stasis pod. (<A HREF='BYOND://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>")])")
	else
		message_admins("[key_name_admin(target)], the [target.job] entered a stasis pod. (<A HREF='BYOND://?_src_=holder;[HrefToken()];adminplayerobservecoodjump=1;X=[x];Y=[y];Z=[z]'>JMP</a>)")
	log_admin(span_notice("[key_name(target)], the [target.job] entered a stasis pod."))
	add_fingerprint(target)

//Attacks/effects.
/obj/machinery/cryopod/blob_act()
	return //Sorta gamey, but we don't really want these to be destroyed.
