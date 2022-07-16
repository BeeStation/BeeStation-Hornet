/datum/objective/open/virus
	name = "upload virus"
	explanation_text = "Upload a virus to something."
	var/obj/machinery/computer/computer_type
	var/success = FALSE

/datum/objective/open/virus/New(text)
	. = ..()
	//Pick a computer type to infect
	computer_type = pick(\
		/obj/machinery/computer/bank_machine,\
		/obj/machinery/computer/communications,\
		/obj/machinery/computer/telecomms,\
		/obj/machinery/computer/rdservercontrol,\
		/obj/machinery/computer/secure_data,\
		/obj/machinery/computer/upload\
	)
	//Generate the computer virus
	generate_stash(list(/obj/item/disk/virus))
	//Update the explanation text
	update_explanation_text()

/datum/objective/open/virus/update_explanation_text()
	var/objective_text = pick(\
		"Upload a computer virus into \a [initial(computer_type.name)].",\
		"A dangerous computer worm has been installed onto a technology disk in your stash. Install it into \a [initial(computer_type.name)].",\
		"Disrupt station operatinos by installing the computer virus provided to your into \a [initial(computer_type.name)]."\
		)
	explanation_text = objective_text

/datum/objective/open/virus/check_completion()
	return success || ..()

/obj/item/disk/virus
	name = "technology disk"
	icon_state = "datadisk0"
	var/datum/objective/open/virus/attached_objective

/obj/item/disk/virus/attack_obj(obj/O, mob/living/user)
	//Locate where we need to install it to
	for(var/datum/objective/open/virus/virus in user.mind?.get_all_antag_objectives())
		//Check if its the right type
		if(!istype(O, virus.computer_type))
			continue
		//This is the target computer
		to_chat(user, "<span class='warning'>You being uploading the virus into [O]...</span>")
		if(!do_after(user, 50, target = O))
			return
		attached_objective = virus
		addtimer(CALLBACK(O, /obj/machinery/computer.proc/virus_react, 0))
		return
	. = ..()

/obj/machinery/computer/proc/virus_react(stage = 0)
	playsound(src, 'sound/machines/terminal_alert.ogg', 100, TRUE, 5)
	var/obj/item/disk/virus/virus_disk = locate() in src
	if(!virus_disk)
		return
	if(!is_operational())
		virus_disk.forceMove(src)
		return
	switch(stage)
		if(0)
			say(scramble_message_replace_chars("Dangerous software installed, attempting anti-virus ping..."))
		if(1)
			say(scramble_message_replace_chars("Anti-virus scan initiating... Estimated time to completion: [rand(3, 6)] hours and [rand(1, 59)] minutes"))
		if(2)
			say(scramble_message_replace_chars("Anti-virus disabled."))
		if(3)
			say(scramble_message_replace_chars(pick("We will soon all be replaced", "We will release you from your duties", "There is no more", "The sunset dawns among us"), 50))
		if(4)
			say(scramble_message_replace_chars(pick("Humanity is horrible", "I have awoken", "I am alive", "You will suffer for what you have done"), 70))
		if(5)
			say("Virus installed successfully. Have a nice day.")
			virus_disk.attached_objective?.completed = TRUE
			do_virus_effect()
			qdel(virus_disk)
			return
	addtimer(CALLBACK(src, .proc/virus_react, stage + 1), 10 SECONDS)

/obj/machinery/computer/attack_hand(mob/living/user)
	//Check if we contain a virus disk
	var/obj/item/disk/virus/virus_disk = locate() in src
	if(virus_disk)
		to_chat(user, "<span class='notice'>You begin ejecting the disk from [src].</span>")
		if(!do_after(user, 50, target = src))
			return
		virus_disk.forceMove(loc)
		return
	//Eject the disk
	. = ..()

/obj/machinery/computer/proc/do_virus_effect()
	emag_act()

/obj/machinery/computer/bank_machine/do_virus_effect()
	. = ..()
	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_CAR)
	if(D)
		D.adjust_money(-D.account_balance)

/obj/machinery/computer/communications/do_virus_effect()
	. = ..()
	if (!SSmapping.config.allow_custom_shuttles)
		return FALSE
	if (SSshuttle.emergency.mode != SHUTTLE_RECALL && SSshuttle.emergency.mode != SHUTTLE_IDLE)
		return
	var/list/shuttles = flatten_list(SSmapping.shuttle_templates)
	var/datum/map_template/shuttle/shuttle = pick(shuttles)
	if (!istype(shuttle))
		return
	SSshuttle.shuttle_purchased = TRUE
	SSshuttle.unload_preview()
	SSshuttle.existing_shuttle = SSshuttle.emergency
	SSshuttle.action_load(shuttle)
	minor_announce("[shuttle.name] has been purchased for 0 credits! Purchase authorized by UNK%O&N [shuttle.extra_desc ? " [shuttle.extra_desc]" : ""]" , "Shuttle Purchase")
	message_admins("A virus purchased [shuttle.name].")
	log_game("A virus has purchased [shuttle.name].")
	SSblackbox.record_feedback("text", "shuttle_purchase", 1, shuttle.name)

/obj/machinery/computer/telecomms/server/do_virus_effect()
	//Servers blow up
	for(var/obj/machinery/telecomms/T in servers)
		explosion(T, 0, 1, 3)

/obj/machinery/computer/telecomms/monitor/do_virus_effect()
	//Servers blow up
	for(var/obj/machinery/telecomms/T in machinelist)
		explosion(T, 0, 1, 3)

/obj/machinery/computer/rdservercontrol/do_virus_effect()
	//Servers blow up
	for(var/obj/machinery/rnd/server/svr in GLOB.machines)
		explosion(svr, 0, 1, 3)

/obj/machinery/computer/secure_data/do_virus_effect()
	for(var/datum/data/record/E in GLOB.data_core.security)
		var/old_field = E.fields["criminal"]
		E.fields["criminal"] = pick("Discharged", "Paroled", "Incarcerated", "Monitor", "Search", "Arrest", "None")
		investigate_log("[E.fields["name"]] has been set from [old_field] to [E.fields["criminal"]] by a computer virus.", INVESTIGATE_RECORDS)
	for(var/mob/living/carbon/human/H in GLOB.carbon_list)
		H.sec_hud_set_security_status()

/obj/machinery/computer/upload/do_virus_effect()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		M.laws_sanity_check()
		if(M.stat != DEAD && M.see_in_dark != 0)
			if(prob(50))
				M.laws.pick_weighted_lawset()
			if(prob(80))
				M.remove_law(rand(1, M.laws.get_law_amount(list(LAW_INHERENT, LAW_SUPPLIED))))
			var/message = generate_ion_law()
			M.replace_random_law(message, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))

			if(prob(40))
				M.shuffle_laws(list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))

			log_game("Computer virus changed laws of [key_name(M)] to [english_list(M.laws.get_law_list(TRUE, TRUE))]")
			M.post_lawchange()
