#define MENU_OPERATION 1
#define MENU_SURGERIES 2

/obj/machinery/computer/operating
	name = "operating computer"
	desc = "Monitors patient vitals and displays surgery steps. Can be loaded with surgery disks to perform experimental procedures. Automatically syncs to stasis beds within its line of sight for surgical tech advancement."
	icon_screen = "crew"
	icon_keyboard = "med_key"
	circuit = /obj/item/circuitboard/computer/operating

	var/obj/structure/table/optable/table
	var/obj/machinery/stasis/sbed
	var/list/advanced_surgeries = list()
	var/datum/techweb/linked_techweb
	light_color = LIGHT_COLOR_BLUE

/obj/machinery/computer/operating/Initialize(mapload)
	. = ..()
	linked_techweb = SSresearch.science_tech
	link_with_table()

/obj/machinery/computer/operating/Destroy()
	if(table?.computer == src)
		table.computer = null
	if(sbed?.op_computer == src)
		sbed.op_computer = null
	. = ..()

/obj/machinery/computer/operating/attackby(obj/item/O, mob/user, params)
	if(istype(O, /obj/item/disk/surgery))
		user.visible_message(span_notice("[user] begins to load \the [O] in \the [src]..."), \
			span_notice("You begin to load a surgery protocol from \the [O]..."), \
			span_hear("You hear the chatter of a floppy drive."))
		var/obj/item/disk/surgery/D = O
		if(do_after(user, 10, target = src))
			advanced_surgeries |= D.surgeries
		return TRUE
	return ..()

/obj/machinery/computer/operating/proc/sync_surgeries()
	if(!linked_techweb)
		return
	for(var/i in linked_techweb.researched_designs)
		var/datum/design/surgery/D = SSresearch.techweb_design_by_id(i)
		if(!istype(D))
			continue
		advanced_surgeries |= D.surgery

/obj/machinery/computer/operating/proc/find_op_table()
	for(var/direction in GLOB.alldirs)
		var/obj/structure/table/optable/found_table = locate(/obj/structure/table/optable) in get_step(src, direction)
		if(found_table && (!found_table.computer || found_table.computer == src))
			return found_table

/obj/machinery/computer/operating/proc/find_sbed()
	for(var/direction in GLOB.alldirs)
		var/obj/machinery/stasis/found_sbed = locate(/obj/machinery/stasis) in get_step(src, direction)
		if(found_sbed && (!found_sbed.op_computer || found_sbed.op_computer == src))
			return found_sbed

/obj/machinery/computer/operating/proc/link_with_table(obj/structure/table/optable/new_table, obj/machinery/stasis/new_sbed)
	if(!new_table && !table)
		new_table = find_op_table()
	if(!new_sbed && !sbed)
		new_sbed = find_sbed()
	if(new_table)
		new_table.computer = src
		table = new_table
	if(new_sbed)
		new_sbed.op_computer = src
		sbed = new_sbed

/obj/machinery/computer/operating/ui_state(mob/user)
	return GLOB.not_incapacitated_state

/obj/machinery/computer/operating/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "OperatingComputer")
		ui.open()
		ui.set_autoupdate(TRUE)

/obj/machinery/computer/operating/ui_data(mob/user)
	var/list/data = list()
	var/list/all_surgeries = list()
	for(var/datum/surgery/surgeries as anything in advanced_surgeries)
		var/list/surgery = list()
		surgery["name"] = initial(surgeries.name)
		surgery["desc"] = initial(surgeries.desc)
		all_surgeries += list(surgery)
	data["surgeries"] = all_surgeries

	//If there's no patient just hop to it yeah?
	if(!table && !sbed)
		data["patient"] = null
		return data

	var/mob/living/carbon/human/patient

	if(table)
		data["table"] = table
		if(!table.check_eligible_patient())
			return data
		data["patient"] = list()
		patient = table.patient
	else if(sbed)
		data["table"] = sbed
		if(!ishuman(sbed.occupant) &&  !ismonkey(sbed.occupant))
			return data
		data["patient"] = list()
		if(isliving(sbed.occupant))
			var/mob/living/live = sbed.occupant
			patient = live
	else
		data["patient"] = null
		return data

	switch(patient.stat)
		if(CONSCIOUS)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "good"
		if(SOFT_CRIT)
			data["patient"]["stat"] = "Conscious"
			data["patient"]["statstate"] = "average"
		if(UNCONSCIOUS, HARD_CRIT)
			data["patient"]["stat"] = "Unconscious"
			data["patient"]["statstate"] = "average"
		if(DEAD)
			data["patient"]["stat"] = "Dead"
			data["patient"]["statstate"] = "bad"
	data["patient"]["health"] = patient.health

	data["patient"]["blood_type"] = patient.dna.blood_type.name

	data["patient"]["maxHealth"] = patient.maxHealth
	data["patient"]["minHealth"] = HEALTH_THRESHOLD_DEAD
	data["patient"]["bruteLoss"] = patient.getBruteLoss()
	data["patient"]["fireLoss"] = patient.getFireLoss()
	data["patient"]["toxLoss"] = patient.getToxLoss()
	data["patient"]["oxyLoss"] = patient.getOxyLoss()
	data["procedures"] = list()
	if(patient.surgeries.len)
		for(var/datum/surgery/procedure in patient.surgeries)
			var/datum/surgery_step/surgery_step = GLOB.surgery_steps[procedure.steps[procedure.status]]
			var/chems_needed = surgery_step.get_chem_list()
			var/alternative_step
			var/alt_chems_needed = ""
			if(surgery_step.repeatable)
				var/datum/surgery_step/next_step = procedure.get_surgery_next_step()
				if(next_step)
					alternative_step = capitalize(next_step.name)
					alt_chems_needed = next_step.get_chem_list()
				else
					alternative_step = "Finish operation"
			data["procedures"] += list(list(
				"name" = capitalize("[parse_zone(procedure.location)] [procedure.name]"),
				"next_step" = capitalize(surgery_step.name),
				"chems_needed" = chems_needed,
				"alternative_step" = alternative_step,
				"alt_chems_needed" = alt_chems_needed
			))
	return data

/obj/machinery/computer/operating/ui_act(action, params)
	. = ..()
	if(.)
		return
	switch(action)
		if("sync")
			sync_surgeries()
			. = TRUE
	. = TRUE

REGISTER_BUFFER_HANDLER(/obj/machinery/computer/operating)
DEFINE_BUFFER_HANDLER(/obj/machinery/computer/operating)
	if(!istype(buffer, /obj/machinery/stasis))
		to_chat(user, span_warning("You cannot link \the [buffer] to \the [src]."))
		return NONE
	var/obj/machinery/stasis/new_stasis_bed = buffer
	if(get_dist(src, new_stasis_bed) > 3)
		to_chat(user, span_warning("\The [src] is too far away from \the [new_stasis_bed] to link!"))
		return NONE
	balloon_alert(user, "linked to \the [new_stasis_bed]")
	if(sbed)
		sbed.op_computer = null
	new_stasis_bed.op_computer = src
	sbed = new_stasis_bed
	to_chat(user, span_notice("You link \the [src] with \the [new_stasis_bed] to its [dir2text(get_dir(src, new_stasis_bed))]."))
	return COMPONENT_BUFFER_RECEIVED

#undef MENU_OPERATION
#undef MENU_SURGERIES
