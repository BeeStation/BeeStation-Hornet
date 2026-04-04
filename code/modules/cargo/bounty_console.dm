#define PRINTER_TIMEOUT 10

/obj/machinery/computer/bounty
	name = "\improper Nanotrasen export console"
	desc = "Used to check and claim bounties offered by Nanotrasen, and to view current export prices."
	icon_screen = "bounty"
	circuit = /obj/item/circuitboard/computer/bounty
	light_color = "#E2853D"//orange
	var/printer_ready = 0 //cooldown var
	var/static/datum/bank_account/cargocash

/obj/machinery/computer/bounty/Initialize(mapload)
	. = ..()
	printer_ready = world.time + PRINTER_TIMEOUT
	cargocash = SSeconomy.get_budget_account(ACCOUNT_CAR_ID)

/obj/machinery/computer/bounty/proc/print_paper()
	new /obj/item/paper/bounty_printout(loc)

/obj/machinery/computer/bounty/proc/print_export_paper()
	new /obj/item/paper/export_printout(loc)

/obj/item/paper/bounty_printout
	name = "paper - Bounties"

/obj/item/paper/bounty_printout/Initialize(mapload)
	. = ..()
	var/final_paper_text = "<h2>Nanotrasen Cargo Bounties</h2></br>"

	for(var/datum/bounty/B in GLOB.bounties_list)
		if(B.claimed)
			continue
		final_paper_text += "<h3>[B.name]</h3>"
		final_paper_text += "<ul><li>Reward: [B.reward_string()]</li>"
		final_paper_text += "<li>Completed: [B.completion_string()]</li></ul>"

	add_raw_text(final_paper_text)
	update_appearance()

/obj/item/paper/export_printout
	name = "paper - Export Prices"

/obj/item/paper/export_printout/Initialize(mapload)
	. = ..()
	var/final_paper_text = "<h2>Nanotrasen Export Price Report</h2></br>"

	// Item exports
	final_paper_text += "<h3>Material & Item Exports</h3>"
	for(var/datum/export/E in GLOB.exports_list)
		if(E.catchall)
			continue
		if(!length(E.export_types))
			continue
		for(var/typepath in E.export_types)
			if(!ispath(typepath, /obj))
				continue
			var/datum/demand_state/state = SSdemand.get_demand_state(typepath)
			var/obj/typed = typepath
			var/item_name = initial(typed.name)
			if(!item_name)
				continue
			var/stock_remaining = max(state.max_demand - state.current_demand, 0)
			var/demand_pct = state.max_demand > 0 ? round((state.current_demand / state.max_demand) * 100) : 0
			var/price = state.generated_price || E.cost
			final_paper_text += "<b>[item_name]</b>: [price] cr/unit | Demand: [demand_pct]% | Stock: [stock_remaining]/[state.max_demand]<br>"

	// Gas exports
	final_paper_text += "<h3>Gas Exports</h3>"
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/G = gas_path
		if(!initial(G.name) || initial(G.base_value) <= 0)
			continue
		var/datum/demand_state/gas_state = SSdemand.get_demand_state(gas_path)
		var/gas_stock = max(gas_state.max_demand - gas_state.current_demand, 0)
		var/gas_demand_pct = gas_state.max_demand > 0 ? round((gas_state.current_demand / gas_state.max_demand) * 100) : 0
		final_paper_text += "<b>[initial(G.name)]</b>: [initial(G.base_value)] cr/mol | Demand: [gas_demand_pct]% | Stock: [gas_stock]/[gas_state.max_demand] mol<br>"

	add_raw_text(final_paper_text)
	update_appearance()

/obj/machinery/computer/bounty/ui_interact(mob/user, datum/tgui/ui)
	if(!GLOB.bounties_list.len)
		setup_bounties()

	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CargoExportConsole")
		ui.set_autoupdate(FALSE)
		ui.open()

/obj/machinery/computer/bounty/ui_data(mob/user)
	var/list/data = list()

	// Bounty data
	var/list/bountyinfo = list()
	for(var/datum/bounty/B in GLOB.bounties_list)
		bountyinfo += list(list("name" = B.name, "description" = B.description, "reward_string" = B.reward_string(), "completion_string" = B.completion_string() , "claimed" = B.claimed, "can_claim" = B.can_claim(), "priority" = B.high_priority, "bounty_ref" = REF(B)))
	data["stored_cash"] = cargocash.account_balance
	data["bountydata"] = bountyinfo

	// Item export data
	var/list/item_exports = list()
	for(var/datum/export/E in GLOB.exports_list)
		if(E.catchall)
			continue
		if(!length(E.export_types))
			continue
		for(var/typepath in E.export_types)
			if(!ispath(typepath, /obj))
				continue
			var/datum/demand_state/state = SSdemand.get_demand_state(typepath)
			var/obj/typed = typepath
			var/item_name = initial(typed.name)
			if(!item_name)
				continue
			var/price = state.generated_price || E.cost
			if(price <= 0)
				continue
			var/demand_ratio = state.max_demand > 0 ? (state.current_demand / state.max_demand) : 0
			var/effective_price = round(price * max(demand_ratio, state.min_price_factor))
			item_exports += list(list(
				"name" = item_name,
				"base_price" = price,
				"effective_price" = effective_price,
				"current_demand" = state.current_demand,
				"max_demand" = state.max_demand,
				"demand_ratio" = round(demand_ratio * 100),
			))
	data["item_exports"] = item_exports

	// Gas export data
	var/list/gas_exports = list()
	for(var/gas_path in subtypesof(/datum/gas))
		var/datum/gas/G = gas_path
		if(!initial(G.name) || initial(G.base_value) <= 0)
			continue
		var/datum/demand_state/gas_state = SSdemand.get_demand_state(gas_path)
		var/demand_ratio = gas_state.max_demand > 0 ? (gas_state.current_demand / gas_state.max_demand) : 0
		var/effective_value = round(initial(G.base_value) * max(demand_ratio, gas_state.min_price_factor) * 100) / 100
		gas_exports += list(list(
			"name" = initial(G.name),
			"base_value" = initial(G.base_value),
			"effective_value" = effective_value,
			"current_demand" = gas_state.current_demand,
			"max_demand" = gas_state.max_demand,
			"demand_ratio" = round(demand_ratio * 100),
			"color" = initial(G.primary_color),
		))
	data["gas_exports"] = gas_exports

	return data

/obj/machinery/computer/bounty/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("ClaimBounty")
			var/datum/bounty/cashmoney = locate(params["bounty"]) in GLOB.bounties_list
			if(cashmoney)
				cashmoney.claim()
			return TRUE
		if("Print")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_paper()
				return
		if("PrintExports")
			if(printer_ready < world.time)
				printer_ready = world.time + PRINTER_TIMEOUT
				print_export_paper()
				return

#undef PRINTER_TIMEOUT
