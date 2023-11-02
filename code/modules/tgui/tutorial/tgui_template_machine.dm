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
		// ui.set_autoupdate(TRUE)
		// explanation exists: search "TIP_001"

/obj/machinery/tgui_template/ui_data(mob/user)
	var/list/data = list()
	/* . = data */
	// Don't use implicit return(the dot one). You should use explicit return.

	data["options"] = options
	data["ui_message"] = ui_message
	data["current_option"] = current_option

	return data //! this is explicit return.

/obj/machinery/tgui_template/ui_static_data(mob/user)
	var/list/data = list()
	/* . = data */
	// I told you.

	data["something_static"] = "This is static string. This is never changed."
	// if you really need update, use update_static_data() or update_static_data_for_all_viewers() procs

	return data

/obj/machinery/tgui_template/ui_assets(mob/user)
	return list(
		get_asset_datum(/datum/asset/spritesheet/research_designs)
	) // sample code to explain how asset works.

/obj/machinery/tgui_template/ui_act(action, params)
	. = ..() // It's important to catch implicit return value first from parent.
	if(.)	 // Thus, `if(..())` is not recommended. You need to store a value into the dot.
		return

	if(action) // helpful debug lines
		to_chat(usr, "<span class='notice'>You took action: [action]</span>")
		to_chat(usr, "<span class='notice'>[investigate_list(params)]</span>")

	switch(action)
		if("button_clicked_bad_version") // "TIP_002"
			var/new_button = sanitize(params["chosen_option"])
			if(new_button in options) // "TIP_004": This is important. You can hack TGUI. validation check is important.
				to_chat(usr, "<span class='notice'>Your clicked button is [new_button]</span>")
				current_option = new_button
				// ui_update() // "TIP_001": Don't use this
				SStgui.update_uis(src) // "TIP_001"
			else
				to_chat(usr, "<span class='notice'>[new_button] is not a valid option. How did you do that?</span>")
	/************************************************************ TIP_001
	*	<-- why SStgui.update_uis(src) over ui_update() ?? -->
	*		SStgui.update_uis(src)
	*			This has an internal code to prevent spamming
	*		ui_update()
	*			This does force-update your TGUI window regardless of server status.
	*			This can cause lags if a user can spam this. Avoid using this if user can spam this.
	*
	*		If you want to make it live-auto-update, setting `ui.set_autoupdate(TRUE)` works.
	*		But if you want to make it manual update, using those procs works, but be warned.
	***************************************************************/

		if("button_clicked_good_version")
			var/new_button = sanitize(params["chosen_option"])
			if(new_button in options) // "TIP_004": again, you can hack TGUI. validation check is important.
				to_chat(usr, "<span class='notice'>Your clicked button is [new_button]</span>")
			else
				to_chat(usr, "<span class='notice'>[new_button] is not a valid option. How did you do that?</span>")
	/************************************************************ TIP_002
	*	<-- What's bad and good for "button_clicked" ?? -->
	*		Bad version stores your chosen option to the server side, and it has a lot of delay to update.
	*			1. Click an option
	*			2. Store it to the server
	*			3. Update it to TGUI
	*			4. Wait for the update... (can be too slow to resend it to your TGUI.)
	*		because it takes a lot of processes to update your choice.
	*
	*		Good version stores your chosen option to your TGUI, and it doesn't need to store the date into the code.
	*			1. Click an option
	*			2. Store it to TGUI (it's also updated at this point)
	*		Storing a chosen value to TGUI side needs to be in tgui code (js, tsx)
	*
	*
	*		Unless outside from "ui_act()" needs "var/current_option",
	*		storing it to DM code side isn't proper.
	*			example)
	*				the atmos temperature machine (/obj/machinery/atmospherics/components/unary/thermomachine)
	*				This takes temperature value from TGUI, and it stores it to "var/target_temperature"
	*			in this sample code, there's no reason to store the chosen option to "current_option"
	***************************************************************/

		if("change_message")
			var/new_message = sanitize(params["new_message"]) // sanitizing user input is important: you don't want the server is hacked through this.
			if(!new_message)
				return
			to_chat(usr, "<span class='notice'>You changed the message: [new_message]</span>")
			ui_message = new_message
	/************************************************************ TIP_003
	*	<-- sanitize() is important -->
	*		Parameter data needs to be heavilly sanitsed and stay to the rules-
	*		that we generally would want relatively safe UIs to follow:
	*			1.
	*				Sanitise variables before passing them into functions.
	*				(We don't know what the function does inside of ui_act-
	*				 since it acts like a bit of a blackbox and we can't ensure-
	*				 that the function we are sending the data to will handle it safely)
	*			2.
	*				Sanitise variables before storing them in a non-local variable.
	*				(Again, storing unsanitised variables in non-local variables-
	*				 obscures the control flow and makes it hard to know where that-
	*				 unsanitised input is being passed to)
	***************************************************************/

	/************************************************************ TIP_004
	*	<-- You can hack TGUI -->
	*		You know you can hack TGUI?
	*		It's possible to send improper "action" and "params" data to DM server
	*
	*		Let's say you're a HoP, and going to hack your card manipulation TGUI.
	*		and you have sent "give_access" action with "access:150" (This is syndicate access)
	*		Great, your card got syndicate access even if it shouldn't be given to you.
	*
	*		In this sample code, choosing an invalid option is possible,
	*		Imagine you can send "Death" option among list("Love", "Bravery", "Honor")
	***************************************************************/

/proc/investigate_list(list/my_list)
	var/param_investigate = "List[length(mylist)]/"
	for(var/idx in 1 to length(my_list))
		var/key = my_list[idx]
		var/value = my_list[key]
		if(islist(value))
			param_investigate += "[key]:([investigate_list(value)])"
		else
			param_investigate += "[key]:[value]"
		if(idx != length(my_list))
			param_investigate += " // "
	return param_investigate
