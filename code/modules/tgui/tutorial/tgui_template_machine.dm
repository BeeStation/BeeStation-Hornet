/obj/machinery/tgui_template
	name = "tgui template machine"
	desc = "Coders' helper."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor_open"

	var/list/options
	var/ui_message
	var/current_option

/obj/machinery/tgui_template/Initialize(mapload)
	. = ..()

	options = list("Button A", "Button B", "Button C")
	ui_message = "Hello, world!"
	current_option = "Button A"

/obj/machinery/tgui_template/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TGUITemplate")
		ui.open()


/obj/machinery/tgui_template/ui_data(mob/user)
	var/list/data = list()
	. = data

	data["options"] = options
	data["ui_message"] = ui_message
	data["current_option"] = current_option

/obj/machinery/tgui_template/ui_static_data(mob/user)
	var/list/data = list()
	. = data

	data["something_static"] = "This is static string. This is never changed."


/obj/machinery/tgui_template/ui_assets(mob/user)
	return list(/datum/asset/spritesheet/research_designs) // sample


/obj/machinery/tgui_template/ui_act(action, params)
	if(..())
		return
	if(action)
		to_chat(usr, "<span class='notice'>You took action: [action]</span>")
		event_checker(params["event_check"])
	switch(action)
		if("button_clicked")
			var/new_button = params["my_button"]
			for(var/each_button in options)
				if(new_button == each_button)
					to_chat(usr, "<span class='notice'>Your clicked button is [each_button]</span>")
					current_option = each_button
		if("change_message")
			var/new_message = params["new_message"]
			if(!new_message)
				return
			to_chat(usr, "<span class='notice'>You changed the message: [new_message]</span>")
			ui_message = new_message

/obj/machinery/tgui_template/proc/event_checker(list/e)
	to_chat(usr, "<span class='notice'>Used event:</span>")
	for(var/each in e)
		to_chat(usr, "\t<span class='notice'>[each]</span>")
