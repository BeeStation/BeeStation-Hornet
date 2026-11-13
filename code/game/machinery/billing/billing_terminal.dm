/*
Consider
	make the system self sustaining until unbalanced maybe
	make chargebacks only happen in that billing category is enabled, or make a seperate chareback bitflagh
	add billing to medibots and air alarms / vents

	Consider adding an extra option to agents to force disable usage of the parent

Peanut Posting
	If we make more power lower electricity costs. Or allow engineering to adjust the price, with a minimum based on how much theyre making
	Make the department upkeep equal to its last power bill
	Arrestinbg a person bills the department

TODO
	add a tool to link terminals to servers. Same tool can be used to setup agents and settings
	improve apc control for AI
*/

/obj/machinery/computer/billing
	name = "billing terminal"
	desc = "A terminal used to bill"
	icon_screen = "billing"
	icon_keyboard = "power_key"
	// req_access = list(ACCESS_HEADS) // Allowing people to fuck with it might be more interesting
	light_color = LIGHT_COLOR_GREEN
	clicksound = null
	circuit = /obj/item/circuitboard/computer/billing

	/// Reference to our internal budget card, if one is inserted
	var/obj/item/card/id/departmental_budget/budget_card
	var/datum/bank_account/department/account
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
	var/autopay_filter = BILL_TAG_POWER | BILL_TAG_UPKEEP | BILL_TAG_SENSORS | BILL_TAG_VENDING | BILL_TAG_CHARGEBACK | BILL_TAG_FEE | BILL_TAG_ACCESS
	/// Do we have a scheduled bill component
	var/bill_schedule_path
	/// Do we chargeback power bills
	var/chargeback = TRUE
	/// Our current profit, for this terminal - used for regular doom posting
	var/profit = 0
	///radio used by the console to doom post //TODO: make this the departments headset - Racc
	var/obj/item/radio/headset/radio = /obj/item/radio/headset/headset_cent/debug
	var/radio_channel = RADIO_CHANNEL_COMMON
	/// How many crew members we need in a department before we turn off chargeback
	var/chargeback_crew_limit = 3

	COOLDOWN_DECLARE(ping_notification)
	COOLDOWN_DECLARE(doom_post)

/obj/machinery/computer/billing/Initialize(mapload)
	. = ..()
	radio = new radio(src)
	// Auto insert cards
	if(mapload)
		roundstart = TRUE
		link_budget_card(locate(/obj/item/card/id/departmental_budget) in loc)
	// Add some forgiveness to the area
	var/area/A = get_area(src)
	A?.extra_overdraft += 10
	// Agent helper
	if(bill_schedule_path)
		AddComponent(bill_schedule_path, budget_card?.department_ID, TRUE)

/obj/machinery/computer/billing/LateInitialize()
	. = ..()
	if(roundstart)
		link_server(SSbilling?.roundstart_server)
		// Chargeback bewl shit
		RegisterSignal(SSjob, COMSIG_JOB_RECEIVED, PROC_REF(catch_job))

/obj/machinery/computer/billing/Destroy()
	. = ..()
	if(server)
		server?.billables -= budget_card?.department_ID
		UnregisterSignal(server, COMSIG_QDELETING, COMSIG_BILLING_NEW_BILL)
	UnregisterSignal(SSjob, COMSIG_JOB_RECEIVED)
	QDEL_NULL(radio)
	STOP_PROCESSING(SSobj, src)

/obj/machinery/computer/billing/process()
	if(COOLDOWN_FINISHED(src, doom_post) && radio)
		COOLDOWN_START(src, doom_post, BILLING_PERIOD_REPORT)
		if(floor(profit) == 0)
			return
// Message
		var/message = "The [budget_card.department_name] has [profit > 0 ? "made" : "lost"] a [profit > 0 ? "profit" : "deficit"] of [profit]cr this period.\n"
		// Autopay filters
		//TODO: add the rest or improve the code / format - racc
		if(autopay_filter != 0)
			message = "[message] [budget_card.department_name] is auto-paying for-\n"
		if(autopay_filter & BILL_TAG_POWER)
			message = "[message] power\n"
		if(autopay_filter & BILL_TAG_SENSORS)
			message = "[message] suit sensors\n"
		if(autopay_filter & BILL_TAG_VENDING)
			message = "[message] vending\n"
		if(autopay_filter & BILL_TAG_ACCESS)
			message = "[message] door access"
// Transmission
		radio.talk_into(src, message, radio_channel)

		profit = 0

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
	if(!budget_card)
		return
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
	data["billables"] = server?.billables-budget_card?.department_ID
	// Filters
	data["bill_filter"] = bill_tag_filter
	data["autopay_filter"] = autopay_filter
	// Ignored
	data["ignored_bills"] = ignored_bills
	data["show_ignored"] = show_ignored
	// Load in our agents
	if(server && budget_card)
		var/list/parsed_agents = list()
		for(var/datum/component/bill_agent/agent as anything in server.get_agents(budget_card.department_ID))
			/// Load in bills generated by this agent
			var/list/parsed_bills = list()
			for(var/datum/bill/bill as anything in agent.local_bills)
				parsed_bills += list(list("title" = bill.title, "body" = bill.body, "from" = bill.from,
				"to_whom" = bill.to_whom, "amount" = bill.amount, "paid" = bill.paid, "sent_when" = bill.sent_when,
				"ref" = REF(bill), "can_delete" = bill.can_delete, "tags" = bill.bill_tags))
			parsed_agents += list(list("agent_name" = agent.name, "name" = agent.parent, "disabled" = agent.disabled, "ref" = REF(agent), "total_bills" = length(agent.local_bills), "income" = agent.income,
			"bills" = parsed_bills, "tags" = agent.tags, "desc" = agent.desc))
		data["agents"] = parsed_agents
	// Load in OUR settings
	if(server && budget_card)
		var/list/settings = list()
		for(var/datum/billing_setting/setting in server.get_settings(budget_card.department_ID))
			settings += list(setting.get_data())
		data["settings"] = settings
	return data

/obj/machinery/computer/billing/ui_act(action, params)
	if(..())
		return
	switch(action)
	// Manage agents
		if("toggle_agent")
			if(!server || !budget_card)
				return
			var/datum/component/bill_agent/agent= locate(params["ref"])
			agent?.toggle_disabled(!agent?.disabled)
			. = TRUE
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
		if("toggle_ignore_filter")
			show_ignored = !show_ignored
			. = TRUE
		if("toggle_ignore")
			if(!server)
				return
			ignored_bills ^= params["ref"]
			. = TRUE
		if("toggle_autopay")
			autopay_filter ^= params["filter"]
			. = TRUE
			// Auto pay the existing bills
			for(var/datum/bill/bill as anything in server.get_bills(budget_card.department_ID))
				if(bill.bill_tags & autopay_filter)
					pay_bill(bill)
	// Draft stuff
		if("new_draft")
			if(!server)
				to_chat(usr, span_warning("ERROR: No linked server to draft to!"))
				return
			if(!budget_card)
				to_chat(usr, span_warning("ERROR: No Department ID to draft from!"))
				return
			var/datum/bill/bill = server.create_new_bill(null, budget_card.department_ID, null, TRUE, TRUE, BILL_TAG_CUSTOM)
			RegisterSignal(bill, COMSIG_BILLING_BILL_PAID, PROC_REF(catch_bill_paid))
			RegisterSignal(bill, COMSIG_QDELETING, PROC_REF(catch_bill_del))
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
			if(!bill?.to_whom)
				return
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
	// Settings
		// Number setting
		if("set_setting_number")
			var/datum/billing_setting/number/setting = locate(params["ref"])
			var/value = params["amount"]
			setting?.set_number(value)
			. = TRUE

/// If a head joins, disable autopay, make them set it up again
// TODO: testing just chargeback for now - Racc
/obj/machinery/computer/billing/proc/catch_job(datum/source, datum/job/job)
	SIGNAL_HANDLER

	if(!budget_card || !account)
		return
// Disable chargeback
	var/account_bit = job.bank_account_department
	var/our_bit = account.department_bitflag
	// Command
	if(account_bit & ACCOUNT_COM_BITFLAG && our_bit & ACCOUNT_COM_BITFLAG)
		chargeback_crew_limit -= 1
	// Engineering
	if(account_bit & ACCOUNT_ENG_BITFLAG && our_bit & ACCOUNT_ENG_BITFLAG)
		chargeback_crew_limit -= 1
	// Service
	if(account_bit & ACCOUNT_SRV_BITFLAG && our_bit & ACCOUNT_SRV_BITFLAG)
		chargeback_crew_limit -= 1
	// Security
	if(account_bit & ACCOUNT_SEC_BITFLAG && our_bit & ACCOUNT_SEC_BITFLAG)
		chargeback_crew_limit -= 1
	// Civilian
	if(account_bit & ACCOUNT_CIV_BITFLAG && our_bit & ACCOUNT_CIV_BITFLAG)
		chargeback_crew_limit -= 1
	// Medical
	if(account_bit & ACCOUNT_MED_BITFLAG && our_bit & ACCOUNT_MED_BITFLAG)
		chargeback_crew_limit -= 1
	// Cargo
	if(account_bit & ACCOUNT_CAR_BITFLAG && our_bit & ACCOUNT_CAR_BITFLAG)
		chargeback_crew_limit -= 1
	// Cargo
	if(account_bit & ACCOUNT_SCI_BITFLAG && our_bit & ACCOUNT_SCI_BITFLAG)
		chargeback_crew_limit -= 1

	if(chargeback_crew_limit <= 0)
		chargeback = FALSE

/// Set this terminal to manage a new budget card
/obj/machinery/computer/billing/proc/link_budget_card(obj/new_card)
	if(!new_card)
		server?.billables -= budget_card.department_ID
		name = "[src::name]"
		budget_card = null
		account = null
		COOLDOWN_RESET(src, doom_post)
		STOP_PROCESSING(SSobj, src)
		return
	budget_card = new_card
	budget_card.forceMove(src)
	account = SSeconomy.get_budget_account(budget_card.department_ID)
	START_PROCESSING(SSobj, src)
	// Update our identity
	name = "[src::name] ([budget_card.department_name])"
	// update the server
	server?.billables |= budget_card.department_ID

/obj/machinery/computer/billing/proc/link_server(obj/machinery/billing_server/new_server)
	if(server)
		UnregisterSignal(server, COMSIG_BILLING_NEW_BILL, COMSIG_QDELETING)
	server = new_server
	server.link_terminal(src)
	server.billables |= budget_card.department_ID
	RegisterSignal(server, COMSIG_QDELETING, PROC_REF(catch_server))
	RegisterSignal(server, COMSIG_BILLING_NEW_BILL, PROC_REF(catch_new_bill))

/obj/machinery/computer/billing/proc/catch_server(datum/source)
	SIGNAL_HANDLER

	server = null

/obj/machinery/computer/billing/proc/catch_new_bill(datum/source, datum/bill/new_bill)
	SIGNAL_HANDLER

	if(new_bill.to_whom == budget_card?.department_ID)
		if(COOLDOWN_FINISHED(src, ping_notification)) // This used to rupture my eardrums during testing
			playsound(src, 'sound/machines/terminal_prompt.ogg', 30, TRUE, 3)
			COOLDOWN_START(src, ping_notification, 1 SECONDS)
			say("Invoices received")
			ui_update()
		if(new_bill.bill_tags & autopay_filter)
			pay_bill(new_bill)
		// If we have no / low staff, make a chargeback
		if(!chargeback || new_bill.bill_tags & BILL_TAG_CUSTOM || new_bill.bill_tags & BILL_TAG_CHARGEBACK)
			return
		var/chargeback_amount = (chargeback_crew_limit/initial(chargeback_crew_limit)) * new_bill.amount
		var/datum/bill/back_bill = server.create_new_bill(new_bill.from, budget_card.department_ID, chargeback_amount, TRUE, TRUE, BILL_TAG_CHARGEBACK)
		back_bill.title = "(Chargeback) [new_bill.title]"
		back_bill.body = "Chargeback from [budget_card.department_ID], under the circumstance of none or insufficient present [budget_card.department_ID] staff."
		RegisterSignal(back_bill, COMSIG_BILLING_BILL_PAID, PROC_REF(catch_bill_paid))
		RegisterSignal(back_bill, COMSIG_QDELETING, PROC_REF(catch_bill_del))
		back_bill.undraft() // Undraft it after we've setup signals

/obj/machinery/computer/billing/proc/pay_bill(datum/bill/pay_bill)
	if(pay_bill?.pay())
		ignored_bills -= REF(pay_bill)
		profit -= pay_bill.amount
	//TODO: Signals and other shit in here - Racc

/obj/machinery/computer/billing/proc/catch_bill_paid(datum/source, amount)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_BILLING_BILL_PAID)
	profit += amount

/obj/machinery/computer/billing/proc/catch_bill_del(datum/source)
	SIGNAL_HANDLER

	UnregisterSignal(source, COMSIG_BILLING_BILL_PAID)
	UnregisterSignal(source, COMSIG_QDELETING)

/obj/item/circuitboard/computer/billing
	name = "Billing Terminal"
	icon_state = "generic"
	build_path = /obj/machinery/computer/billing

/obj/machinery/computer/billing/engineering
	radio_channel = RADIO_CHANNEL_ENGINEERING
	chargeback = FALSE

/obj/machinery/computer/billing/medical
	bill_schedule_path = /datum/component/bill_agent/scheduled/bill_all/medical
	radio_channel = RADIO_CHANNEL_MEDICAL

/obj/machinery/computer/billing/secuirty
	bill_schedule_path = /datum/component/bill_agent/scheduled/bill_all/security
	radio_channel = RADIO_CHANNEL_SECURITY

/obj/machinery/computer/billing/service
	bill_schedule_path = /datum/component/bill_agent/scheduled/bill_all/service
	radio_channel = RADIO_CHANNEL_SERVICE

/obj/machinery/computer/billing/cargo
	radio_channel = RADIO_CHANNEL_SUPPLY

/obj/machinery/computer/billing/science
	radio_channel = RADIO_CHANNEL_SCIENCE
	chargeback_crew_limit = 2 // Fuck 'em

/obj/machinery/computer/billing/civ
	radio_channel = RADIO_CHANNEL_COMMON
	chargeback = FALSE

/obj/machinery/computer/billing/command
	chargeback = FALSE
	//TODO: This is mostly a testing feature, paying custom out the box - Racc
	autopay_filter = BILL_TAG_POWER | BILL_TAG_UPKEEP | BILL_TAG_FEE | BILL_TAG_CUSTOM | BILL_TAG_VENDING | BILL_TAG_SENSORS | BILL_TAG_CHARGEBACK | BILL_TAG_ACCESS
	radio_channel = RADIO_CHANNEL_COMMAND
	chargeback = FALSE
