/obj/machinery/tgui_template
	name = "tgui template machine"
	desc = "Coders' helper."
	icon = 'icons/obj/hydroponics/equipment.dmi'
	icon_state = "sextractor_open"

	var/list/options
	var/current_option
	var/ui_message

/obj/machinery/tgui_template/Initialize(mapload)
	. = ..()

	options = list("Love", "Bravery", "Honor")
	current_option = options[1]
	ui_message = "Hello, world!"

/obj/machinery/tgui_template/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "TGUITemplate")
		ui.open()
		/* ui.set_autoupdate(TRUE) */
		//! It does literally auto-update. Uncomment this if you need auto-update for your UI.

/obj/machinery/tgui_template/ui_data(mob/user)
	var/list/data = list()
	/* . = data */ //! Don't use implicit return(the dot one). You should use explicit return.

	data["options"] = options
	data["ui_message"] = ui_message
	data["current_option"] = current_option

	return data //! this is explicit return.

/obj/machinery/tgui_template/ui_static_data(mob/user)
	var/list/data = list()
	/* . = data */

	data["something_static"] = "This is static string. This is never changed."
	//! if you really need update, use update_static_data() or update_static_data_for_all_viewers() procs

	return data

/obj/machinery/tgui_template/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	) //! sample code to explain how asset works.

/obj/machinery/tgui_template/ui_act(action, params)
	. = ..() //! It's important to catch implicit return value first from parent.
	if(.)	 //! Thus, `if(..())` is not recommended. You need to store a value into the dot.
		return
	if(action)
		to_chat(usr, "<span class='notice'>You took action: [action]</span>")
	switch(action)
		if("button_clicked")
			var/new_button = sanitize(params["chosen_option"])
			if(new_button in options) //! This is important. This is checking if the chosen option is really available.
				to_chat(usr, "<span class='notice'>Your clicked button is [each_button]</span>")
				current_option = each_button
				/* ui_update() */
				SStgui.update_uis(src)
			/*	<-- why SStgui.update_uis(src) over ui_update() ?? -->
					> ui_update()
						This does force-update your TGUI window regardless of server status.
						This can cause lags if a user can spam this. Avoid using this if user can spam this.
					> SStgui.update_uis(src)
						This is used to prevent spamming

					But, setting `ui.set_autoupdate(TRUE)` works at most times.         */

		if("change_message")
			var/new_message = params["new_message"]
			if(!new_message)
				return
			to_chat(usr, "<span class='notice'>You changed the message: [new_message]</span>")
			ui_message = new_message
