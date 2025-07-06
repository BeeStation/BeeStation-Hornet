/client/var/datum/tgui_login/tgui_login

/datum/tgui_login
	/// The user who owns the window
	var/client/client

/datum/tgui_login/New(client/client)
	src.client = client

/datum/tgui_login/proc/open()
	if(client?.mob)
		ui_interact(client.mob)

/datum/tgui_login/Destroy(force, ...)
	SStgui.close_uis(src)
	. = ..()

/datum/tgui_login/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "GameLogin")
		ui.open()
		ui.set_autoupdate(FALSE)

/datum/tgui_login/ui_state(mob/user)
	return GLOB.pre_auth_state

/datum/tgui_login/ui_static_data(mob/user)
	. = list()
	.["methods"] = CONFIG_GET(keyed_list/external_auth_method)
#ifdef DISABLE_BYOND_AUTH
	.["byond_enabled"] = FALSE
#else
	.["byond_enabled"] = TRUE
#endif

/datum/tgui_login/ui_data(mob/user)
	. = list()
	if(!user.client)
		return
	.["authenticated_key"] = user.client.byond_authenticated_key

/datum/tgui_login/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || !usr?.client || usr.client.logged_in || ui.user != usr)
		return
	if(action == "login")
		var/method_id = params["method"]
		if(istext(method_id) && length(method_id))
			usr.client.login_with_method_id(method_id)
