/*
	Suit sensor bills for each department
	If we make more power lower electricity costs. Or allow engineering to adjust the price, with a minimum based on how much theyre making
	Make the department upkeep equal to its last power bill
	add tags for paid and unpaid
*/

/obj/machinery/computer/billing
	name = "billing terminal"
	desc = "A terminal used to bill"
	icon_screen = "billing"
	icon_keyboard = "power_key"
	// req_access = list(ACCESS_HEADS)
	light_color = LIGHT_COLOR_BLUE
	clicksound = null

	/// Reference to our internal budget card, if one is inserted
	var/obj/item/card/id/departmental_budget/budget_card
	var/datum/bank_account/account
	/// What billing network server we're connected to
	var/obj/machinery/billing_server/server
	/// Are we made by mappers?
	var/roundstart = FALSE
	/// Our current billing filter
	var/bill_tag_filter = 0
	/// List of ignored bills
	var/list/ignored_bills = list()
	var/show_ignored = FALSE
	/// Autopay filter
	var/autopay_filter = BILL_TAG_POWER

	COOLDOWN_DECLARE(ping_notification)

/obj/machinery/computer/billing/Initialize(mapload)
	. = ..()
	// Auto insert cards
	if(mapload)
		roundstart = TRUE
		link_budget_card(locate(/obj/item/card/id/departmental_budget) in loc)
	RegisterSignal(SSjob, COMSIG_JOB_RECEIVED, PROC_REF(catch_job))

/obj/machinery/computer/billing/LateInitialize()
	. = ..()
	if(roundstart)
		SSbilling?.roundstart_server?.link_terminal(src)
		link_server(SSbilling?.roundstart_server)

/obj/machinery/computer/billing/examine(mob/user)
	. = ..()
	. += span_notice("Insert a department budget card to access bills. Alt-Click to remove it.")

/obj/machinery/computer/billing/attackby(obj/item/attacking_item, mob/user, list/modifiers)
	. = ..()
	// Insert bduget card
	if(istype(attacking_item, /obj/item/card/id/departmental_budget) && !budget_card)
		link_budget_card(attacking_item)
		ui_update()
	// Insert credits into budget card, if present
	if(istype(attacking_item, /obj/item/holochip))
		budget_card?.attackby(attacking_item, user, modifiers)
		ui_update()

/obj/machinery/computer/billing/AltClick(mob/user)
	. = ..()
	budget_card.forceMove(get_turf(src))
	link_budget_card(null)
	ui_update()

/obj/machinery/computer/billing/ui_interact(mob/user, datum/tgui/ui)
	. = ..()
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BillingTerminal", name)
		ui.open()
		//ui.set_autoupdate(TRUE)

/obj/machinery/computer/billing/ui_static_data(mob/user)
	var/list/data = list()
	/// Possible Filters
	data["bill_filters"] = SSbilling.bill_tags
	return data

/obj/machinery/computer/billing/ui_data(mob/user)
	var/list/data = list()
	// Load in our bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(budget_card.department_ID))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete, "tags" = bill.bill_tags))
		data["incoming_bills"] = parsed_bills
	// Load in paid bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(budget_card.department_ID, paid = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete, "tags" = bill.bill_tags))
		data["paid_bills"] = parsed_bills
	// Load in our drafts
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(from_department_id = budget_card.department_ID, drafts = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete, "tags" = bill.bill_tags))
		data["drafted_bills"] = parsed_bills
	// Load in sent bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(from_department_id = budget_card.department_ID)|server.get_bills(from_department_id = budget_card.department_ID, paid = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete, "tags" = bill.bill_tags))
		data["sent_bills"] = parsed_bills
	// Who's money is this?
	data["account_id"] = budget_card?.department_ID
	data["account_amount"] = account?.account_balance
	// Which server are we linked to?
	data["server_id"] = server?.name
	// Active budgets we can bill
	data["billables"] = SSbilling?.billables-budget_card?.department_ID
	/// Filters
	data["bill_filter"] = bill_tag_filter
	data["autopay_filter"] = autopay_filter
	/// Ignored
	data["ignored_bills"] = ignored_bills
	data["show_ignored"] = show_ignored
	/// Mode
	return data

/obj/machinery/computer/billing/ui_act(action, params)
	if(..())
		return
	switch(action)
	// Pay the bills
		if("pay_bill")
			if(!server || !budget_card)
				return
			var/datum/bill/bill= locate(params["ref"])
			pay_bill(bill)
			. = TRUE
	//Filters
		if("toggle_filter")
			bill_tag_filter ^= params["filter"]
			. = TRUE
		if("toggle_autopay")
			autopay_filter ^= params["filter"]
			. = TRUE
		if("toggle_ignore_filter")
			show_ignored = !show_ignored
			. = TRUE
		if("toggle_ignore")
			if(!server)
				return
			ignored_bills ^= params["ref"]
			. = TRUE
	// Draft stuff
		if("new_draft")
			if(!server)
				to_chat(usr, span_warning("ERROR: No linked server to draft to!"))
				return
			if(!budget_card)
				to_chat(usr, span_warning("ERROR: No Department ID to draft from!"))
				return
			server.create_new_bill(null, budget_card.department_ID, null, TRUE, TRUE, BILL_TAG_CUSTOM)
			. = TRUE
		if("set_draft_whom")
			var/datum/bill/bill= locate(params["ref"])
			bill.to_whom = params["target"]
			. = TRUE
		if("set_draft_amount")
			var/datum/bill/bill= locate(params["ref"])
			bill.amount = params["amount"]
			. = TRUE
		if("set_draft_body")
			var/datum/bill/bill= locate(params["ref"])
			bill.body = params["body"]
			. = TRUE
		if("set_draft_title")
			var/datum/bill/bill= locate(params["ref"])
			bill.title = params["title"]
			. = TRUE
		if("send_draft")
			var/datum/bill/bill= locate(params["ref"])
			bill.undraft()
			//TODO: Signals and other shit in here - Racc
			. = TRUE
		if("delete_draft")
			if(!server)
				return
			var/datum/bill/bill= locate(params["ref"])
			server.bills -= bill
			qdel(bill)
			//TODO: Signals and other shit in here - Racc
			. = TRUE

/// If a head joins, disable autopay, make them set it up again
/obj/machinery/computer/billing/proc/catch_job(datum/source, datum/job/job)
	SIGNAL_HANDLER

	var/filter_before = autopay_filter
	switch(job.department_for_prefs)
		if(DEPARTMENT_NAME_MEDICAL) // Medical, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_MED_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_SERVICE) // Service, can be anyone
			if(budget_card?.department_ID == ACCOUNT_SRV_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_SCIENCE) // Science, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_SCI_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_SECURITY) // Security, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_SEC_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_CARGO) // Cargo, needs to be a QM
			if(job.title == JOB_NAME_QUARTERMASTER && budget_card?.department_ID == ACCOUNT_CAR_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_ENGINEERING) // Engineering, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_ENG_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_COMMAND) // Command, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_COM_ID)
				autopay_filter = 0
		if(DEPARTMENT_NAME_CIVILIAN) // Civ, needs to be a head
			if(job.auto_deadmin_role_flags == DEADMIN_POSITION_HEAD && budget_card?.department_ID == ACCOUNT_CIV_ID)
				autopay_filter = 0
	if(filter_before != autopay_filter)
		say("Disabling autopay filters")


/// Set this terminal to manage a new budget card
/obj/machinery/computer/billing/proc/link_budget_card(obj/new_card)
	if(!new_card)
		name = "[src::name]"
		budget_card = null
		account = null
		return
	budget_card = new_card
	budget_card.forceMove(src)
	account = SSeconomy.get_budget_account(budget_card.department_ID)
	// Update our identity
	name = "[src::name] ([budget_card.department_name])"

/obj/machinery/computer/billing/proc/link_server(obj/machinery/billing_server/new_server)
	if(server)
		UnregisterSignal(server, COMSIG_BILLING_NEW_BILL)
	server = new_server
	RegisterSignal(server, COMSIG_QDELETING, PROC_REF(catch_server))
	RegisterSignal(server, COMSIG_BILLING_NEW_BILL, PROC_REF(catch_new_bill))

/obj/machinery/computer/billing/proc/catch_server(datum/source)
	SIGNAL_HANDLER

	server = null

/obj/machinery/computer/billing/proc/catch_new_bill(datum/source, datum/bill/new_bill)
	SIGNAL_HANDLER

	if(new_bill.to_whom == budget_card?.department_ID)
		if(COOLDOWN_FINISHED(src, ping_notification)) // This used to rupture my eardrums during testing
			playsound(src, 'sound/machines/terminal_success.ogg', 60, TRUE, 3)
			COOLDOWN_START(src, ping_notification, 1 SECONDS)
			say("Invoices received")
			ui_update()
		if(new_bill.bill_tags & autopay_filter)
			pay_bill(new_bill)

/obj/machinery/computer/billing/proc/pay_bill(datum/bill/pay_bill)
	if(pay_bill.paid)
		return
	// Can we afford this?
	if(pay_bill.amount > account.account_balance)
		to_chat(usr, span_warning("ERROR: Insufficient funds!"))
		return
	ignored_bills -= REF(pay_bill)
	account.adjust_money(-pay_bill.amount)
	pay_bill.paid = TRUE
	var/datum/bank_account/winner = SSeconomy.get_budget_account(pay_bill.from)
	winner.adjust_money(pay_bill.amount)
	//TODO: Signals and other shit in here - Racc

/obj/machinery/computer/billing/engineering
	autopay_filter = BILL_TAG_POWER | BILL_TAG_UPKEEP
