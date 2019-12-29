/obj/machinery/scav_selling
	name = "Export scav_selling"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "lpad-idle-o"
	var/idle_state 	= "lpad-idle-o"
	var/warmup_state = "lpad-idle"
	var/sending_state = "lpad-beam"
	var/cargo_hold_id

/obj/machinery/scav_selling/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I))
		to_chat(user, "<span class='notice'>You register \the [src] in [I]'s buffer.</span>")
		I.buffer = src
		return TRUE

/obj/machinery/computer/scav_selling_control
	name = "Export controll console"
	var/status_report = "Idle"
	var/datum/weakref/scav_selling
	var/warmup_time = 100
	var/sending = FALSE
	var/points = 0
	var/datum/export_report/total_report
	var/sending_timer
	var/cargo_hold_id

/obj/machinery/computer/scav_selling_control/Initialize()
	..()
	return INITIALIZE_HINT_LATELOAD

/obj/machinery/computer/scav_selling_control/multitool_act(mob/living/user, obj/item/multitool/I)
	if (istype(I) && istype(I.buffer,/obj/machinery/scav_selling))
		to_chat(user, "<span class='notice'>You link [src] with [I.buffer] in [I] buffer.</span>")
		scav_selling = I.buffer
		updateDialog()
		return TRUE

/obj/machinery/computer/scav_selling_control/LateInitialize()
	. = ..()
	if(cargo_hold_id)
		for(var/obj/machinery/scav_selling/P in GLOB.machines)
			if(P.cargo_hold_id == cargo_hold_id)
				scav_selling = WEAKREF(P)
				return

/obj/machinery/computer/scav_selling_control/ui_interact(mob/user)
	. = ..()
	var/list/t = list()
	t += "<div class='statusDisplay'>Cargo Hold Control<br>"
	t += "Current cargo value : [points]"
	t += "</div>"
	if(!scav_selling)
		t += "<div class='statusDisplay'>No scav_selling located.</div><BR>"
	else
		t += "<br>[status_report]<br>"
		if(!sending)
			t += "<a href='?src=[REF(src)];recalc=1;'>Recalculate Value</a><a href='?src=[REF(src)];send=1'>Send</a>"
		else
			t += "<a href='?src=[REF(src)];stop=1'>Stop sending</a>"

	var/datum/browser/popup = new(user, "scav_selling", name, 300, 500)
	popup.set_content(t.Join())
	popup.open()

/obj/machinery/computer/scav_selling_control/proc/recalc()
	if(sending)
		return
	status_report = "Predicted value:<br>"
	var/datum/export_report/ex = new
	for(var/atom/movable/AM in get_turf(scav_selling))
		if(AM == scav_selling)
			continue
		export_item_and_contents(AM, EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, dry_run = TRUE, external_report = ex)

	for(var/datum/export/E in ex.total_amount)
		status_report += E.total_printout(ex,notes = FALSE) + "<br>"

/obj/machinery/computer/scav_selling_control/proc/send()
	if(!sending)
		return

	var/datum/bank_account/D = SSeconomy.get_dep_account(ACCOUNT_SCA)

	var/datum/export_report/ex = new

	for(var/atom/movable/AM in get_turf(scav_selling))
		if(AM == scav_selling)
			continue
		export_item_and_contents(AM, EXPORT_CARGO | EXPORT_CONTRABAND | EXPORT_EMAG, apply_elastic = FALSE, delete_unsold = FALSE, external_report = ex)

	status_report = "Sold:<br>"
	var/value = 0
	for(var/datum/export/E in ex.total_amount)
		var/export_text = E.total_printout(ex,notes = FALSE) //Don't want nanotrasen messages, makes no sense here.
		if(!export_text)
			continue

		status_report += export_text + "<br>"
		value += ex.total_value[E]
		D.adjust_money(ex.total_value[E])
	if(!total_report)
		total_report = ex
	else
		total_report.exported_atoms += ex.exported_atoms
		for(var/datum/export/E in ex.total_amount)
			total_report.total_amount[E] += ex.total_amount[E]
			total_report.total_value[E] += ex.total_value[E]

	points += value

	scav_selling.visible_message("<span class='notice'>[scav_selling] activates!</span>")
	flick(scav_selling.sending_state,scav_selling)
	scav_selling.icon_state = scav_selling.idle_state
	sending = FALSE
	updateDialog()

/obj/machinery/computer/scav_selling_control/proc/start_sending()
	if(sending)
		return
	sending = TRUE
	status_report = "Sending..."
	scav_selling.visible_message("<span class='notice'>[scav_selling] starts charging up.</span>")
	scav_selling.icon_state = scav_selling.warmup_state
	sending_timer = addtimer(CALLBACK(src,.proc/send),warmup_time, TIMER_STOPPABLE)

/obj/machinery/computer/scav_selling_control/proc/stop_sending()
	if(!sending)
		return
	sending = FALSE
	status_report = "Idle"
	scav_selling.icon_state = scav_selling.idle_state
	deltimer(sending_timer)

/obj/machinery/computer/scav_selling_control/Topic(href, href_list)
	if(..())
		return
	if(scav_selling)
		if(href_list["recalc"])
			recalc()
		if(href_list["send"])
			start_sending()
		if(href_list["stop"])
			stop_sending()
		updateDialog()
	else
		updateDialog()
