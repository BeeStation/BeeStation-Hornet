/obj/machinery/billing_server
	name = "billing server"
	icon = 'icons/obj/stationobjs.dmi'
	icon_state = "blackbox"
	density = TRUE
	/// List of server's connected to us
	var/list/linked_terminals = list()
	/// List of ongoing bills
	var/list/bills = list()
	/// List of existing agents
	var/list/agents = list()
	/// List of billing settings - Used to configure things like power cost
	var/list/settings = list(/datum/billing_setting/number/power, /datum/billing_setting/number/upkeep/medical,
	/datum/billing_setting/number/upkeep/security, /datum/billing_setting/number/upkeep/service, /datum/billing_setting/number/techfab_design,
	/datum/billing_setting/number/techfab_material, /datum/billing_setting/number/suit_sensor_upkeep)

/obj/machinery/billing_server/Initialize(mapload)
	. = ..()
	SSbilling.set_default_server(src)
	// Build settings
	for(var/setting_path as anything in settings)
		var/datum/billing_setting/new_setting = new setting_path()
		settings += new_setting
		settings -= setting_path

/obj/machinery/billing_server/Destroy()
	. = ..()
	for(var/atom/terminal as anything in linked_terminals)
		UnregisterSignal(terminal, COMSIG_QDELETING)
	for(var/atom/bill as anything in bills)
		UnregisterSignal(bill, COMSIG_BILLING_BILL_UNDRAFT)
		UnregisterSignal(bill, COMSIG_QDELETING)
	for(var/atom/agent as anything in agents)
		UnregisterSignal(agent, COMSIG_QDELETING)

/obj/machinery/billing_server/proc/link_terminal(obj/console)
	linked_terminals += console
	RegisterSignal(console, COMSIG_QDELETING, PROC_REF(catch_terminal))

/obj/machinery/billing_server/proc/catch_terminal(datum/source)
	SIGNAL_HANDLER

	linked_terminals -= source

/// Return a list of our linked terminals that have inserted budget cards
/obj/machinery/billing_server/proc/get_valid_terminals()
	var/list/working_terminals = list()
	for(var/obj/machinery/computer/billing/terminal as anything in linked_terminals)
		if(terminal.budget_card)
			working_terminals += terminal
	return working_terminals

/// Create a new bill
/obj/machinery/billing_server/proc/create_new_bill(to_whom, from, amount, draft, can_delete = TRUE, tags)
	var/datum/bill/new_bill = new /datum/bill("", "", from, to_whom, amount, draft, can_delete, tags)
	bills.Insert(1, new_bill)
	if(!new_bill.draft)
		SEND_SIGNAL(src, COMSIG_BILLING_NEW_BILL, new_bill)
	else
		RegisterSignal(new_bill, COMSIG_BILLING_BILL_UNDRAFT, PROC_REF(catch_undraft))
	RegisterSignal(new_bill, COMSIG_QDELETING, PROC_REF(catch_bill))

	return new_bill

/obj/machinery/billing_server/proc/catch_bill(datum/source)
	SIGNAL_HANDLER

	bills -= source

/obj/machinery/billing_server/proc/catch_undraft(datum/source)
	SIGNAL_HANDLER

	SEND_SIGNAL(src, COMSIG_BILLING_NEW_BILL, source)

/// Get a list of bills filtered by a specific department id
// TODO: Chenge this and get agents / settings to use signals - Racc
/obj/machinery/billing_server/proc/get_bills(to_department_id, from_department_id, drafts = FALSE, paid = FALSE)
	var/list/filtered_bills = list()
	for(var/datum/bill/bill as anything in bills)
		if(QDELETED(bill))
			bills -= bill
			continue
		if(bill?.draft != drafts)
			continue
		if(bill.paid != paid)
			continue
		if((bill.to_whom == to_department_id && to_department_id) || (bill.from == from_department_id && from_department_id))
			filtered_bills += bill
	return filtered_bills

/obj/machinery/billing_server/proc/get_agents(owner_id)
	var/list/filtered_agents = list()
	for(var/datum/component/bill_agent/agent as anything in agents)
		if(agent.department_ID != owner_id)
			continue
		filtered_agents += agent
	return filtered_agents

/obj/machinery/billing_server/proc/get_settings(owner_id)
	var/list/filtered_settings = list()
	for(var/datum/billing_setting/setting as anything in settings)
		if(!(owner_id in setting.department_ID))
			continue
		filtered_settings += setting
	return filtered_settings

/obj/machinery/billing_server/proc/add_agent(datum/component/bill_agent/_agent)
	agents += _agent
	RegisterSignal(_agent, COMSIG_QDELETING, PROC_REF(catch_agent))

/obj/machinery/billing_server/proc/catch_agent(datum/source)
	agents -= source
