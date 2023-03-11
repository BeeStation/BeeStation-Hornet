/datum/computer_file/program/bounty
	filename = "bounty"
	filedesc = "Nanotrasen Bounty Hunter"
	category = PROGRAM_CATEGORY_SUPL
	program_icon_state = "bounty"
	extended_desc = "A basic interface for supply personnel to check and claim bounties."
	requires_ntnet = TRUE
	transfer_access = list(ACCESS_CARGO)
	network_destination = "cargo claims interface"
	size = 10
	tgui_id = "NtosBountyConsole"
	program_icon = "tags"

	/// Cooldown var for printing paper sheets.
	COOLDOWN_DECLARE(printer_ready)
	/// The cargo account for grabbing the cargo account's credits.
	var/static/datum/bank_account/cargocash

/datum/computer_file/program/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(get_turf(computer))

/datum/computer_file/program/bounty/on_ui_create(mob/user, datum/tgui/ui)
	COOLDOWN_START(src, printer_ready, PRINTER_TIMEOUT)

/datum/computer_file/program/bounty/ui_data(mob/user)
	var/list/data = list()

	if(!GLOB.bounties_list.len)
		setup_bounties()
	cargocash = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)

	var/obj/item/computer_hardware/printer/printer
	if(computer)
		printer = computer.all_components[MC_PRINT]

	var/list/bountyinfo = list()
	for(var/datum/bounty/B in GLOB.bounties_list)
		bountyinfo += list(list(
			"name" = B.name,
			"description" = B.description,
			"reward_string" = B.reward_string(),
			"completion_string" = B.completion_string(),
			"claimed" = B.claimed,
			"can_claim" = B.can_claim(),
			"priority" = B.high_priority,
			"bounty_ref" = REF(B)
		))

	data["has_printer"] = printer ? TRUE : FALSE

	data["stored_cash"] = cargocash ? cargocash.account_balance : 0
	data["bountydata"] = bountyinfo

	return data

/datum/computer_file/program/bounty/ui_act(action,params)
	if(..())
		return
	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.bounties_list
			if(cashmoney)
				cashmoney.claim()
			return TRUE
		if("Print")
			if(!COOLDOWN_FINISHED(src, printer_ready))
				to_chat(usr, "<span class='warning'>The printer is not ready to print yet!</span>")
				return
			var/obj/item/computer_hardware/printer/printer
			if(computer)
				printer = computer.all_components[MC_PRINT]

			if(printer)
				if(!printer.print_type(/obj/item/paper/bounty_printout))
					to_chat(usr, "<span class='notice'>Hardware error: Printer was unable to print the file. It may be out of paper.</span>")
					return
				else
					COOLDOWN_START(src, printer_ready, PRINTER_TIMEOUT)
					computer.visible_message("<span class='notice'>\The [computer] prints out a paper.</span>")
