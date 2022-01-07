/obj/machinery/computer/ai_server_console
	name = "\improper AI server overview console"
	desc = "Used for monitoring the various servers assigned to the AI network."
	req_access = list(ACCESS_RD)
	circuit = /obj/item/circuitboard/computer/aifixer
	icon_keyboard = "tech_key"
	icon_screen = "ai-fixer"
	light_color = LIGHT_COLOR_PINK

	circuit = /obj/item/circuitboard/computer/ai_server_overview

/obj/machinery/computer/ai_server_console/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "AiServerConsole", name)
		ui.open()

/obj/machinery/computer/ai_server_console/ui_data(mob/living/carbon/human/user)
	var/list/data = list()

	data["servers"] = list()
	for(var/obj/machinery/ai/expansion_card_holder/holder in GLOB.expansion_card_holders)
		var/turf/current_turf = get_turf(holder)
		var/datum/gas_mixture/env = current_turf.return_air()
		data["servers"] += list(list("area" = get_area(holder), "working" = holder.valid_holder(), "total_cpu" = holder.total_cpu, "ram" = holder.total_ram, "card_capacity" = "[holder.installed_cards.len]/[holder.max_cards]", "temp" = env.return_temperature()))

	return data
