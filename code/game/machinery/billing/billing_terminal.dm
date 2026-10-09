/*
	Suit sensor bills for each department
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

	COOLDOWN_DECLARE(ping_notification)

/obj/machinery/computer/billing/Initialize(mapload)
	. = ..()
	// quick_link()
	// Auto insert cards
	if(mapload)
		roundstart = TRUE
		link_budget_card(locate(/obj/item/card/id/departmental_budget) in loc)

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
	if(istype(attacking_item, /obj/item/card/id/departmental_budget) && !budget_card)
		link_budget_card(attacking_item)
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

/obj/machinery/computer/billing/ui_data(mob/user)
	var/list/data = list()
	// Load in our bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(budget_card.department_ID))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete))
		data["incoming_bills"] = parsed_bills
	// Load in paid bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(budget_card.department_ID, paid = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete))
		data["paid_bills"] = parsed_bills
	// Load in our drafts
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(from_department_id = budget_card.department_ID, drafts = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete))
		data["drafted_bills"] = parsed_bills
	// Load in sent bills
	if(server && budget_card)
		var/list/parsed_bills = list()
		for(var/datum/bill/bill as anything in server.get_bills(from_department_id = budget_card.department_ID)|server.get_bills(from_department_id = budget_card.department_ID, paid = TRUE))
			parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
			"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
			"ref" = REF(bill), "can_delete" = bill.can_delete))
		data["sent_bills"] = parsed_bills
	// Who's money is this?
	data["account_id"] = budget_card?.department_ID
	data["account_amount"] = account?.account_balance
	// Which server are we linked to?
	data["server_id"] = server?.name
	// Active budgets we can bill
	data["billables"] = SSbilling?.billables-budget_card?.department_ID
	return data

/obj/machinery/computer/billing/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("pay_bill")
			if(!server || !budget_card)
				return
			var/datum/bill/bill= locate(params["ref"])
			if(bill.paid)
				return
			// Can we afford this?
			if(bill.amount > account.account_balance)
				to_chat(usr, span_warning("ERROR: Insufficient funds!"))
				return
			account.adjust_money(-bill.amount)
			bill.paid = TRUE
			var/datum/bank_account/winner = SSeconomy.get_budget_account(bill.from)
			winner.adjust_money(bill.amount)
			//TODO: Signals and other shit in here - Racc
			. = TRUE
	// Draft stuff
		if("new_draft")
			if(!server)
				to_chat(usr, span_warning("ERROR: No linked server to draft to!"))
				return
			if(!budget_card)
				to_chat(usr, span_warning("ERROR: No Department ID to draft from!"))
				return
			server.create_new_bill(null, budget_card.department_ID, null, TRUE)
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

/// Make a new bill from our budget to someone else's
//TODO: Remove this - Racc
/obj/machinery/computer/billing/proc/make_bill(mob/user, draft)
	// Flight checks
	if(!budget_card)
		to_chat(user, span_warning("No budget card inserted!"))
		return
	if(!server)
		to_chat(user, span_warning("No linked server!"))
		return
	// TODO: temp - Racc
	var/obj/machinery/computer/billing/billing_victim = tgui_input_list(user, "Which budget are you billing?", "New Bill", server.get_valid_terminals()-src)
	if(!billing_victim)
		return
	server.create_new_bill(billing_victim.budget_card.department_ID, budget_card.department_ID, rand(100, 1000))

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
	RegisterSignal(server, COMSIG_BILLING_NEW_BILL, PROC_REF(catch_new_bill))

/obj/machinery/computer/billing/proc/catch_new_bill(datum/source, datum/bill/new_bill)
	SIGNAL_HANDLER

	if(new_bill.to_whom == budget_card?.department_ID)
		if(COOLDOWN_FINISHED(src, ping_notification)) // This used to rupture my eardrums during testing
			playsound(src, 'sound/machines/terminal_success.ogg', 60, TRUE, 3)
			COOLDOWN_START(src, ping_notification, 5 SECONDS)
		say("Invoices received")
		ui_update()

//TODO: remove this - Racc
/obj/machinery/computer/billing/proc/quick_link()
	server = locate(/obj/machinery/billing_server) in range(5, get_turf(src))
	server?.link_terminal(src)
