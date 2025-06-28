/client/var/datum/tgui_login/tgui_login

/datum/tgui_login
	/// The user who owns the window
	var/client/client

/datum/tgui_login/New(client/client)
	src.client = client

/datum/tgui_login/proc/initialize()
	set waitfor = FALSE
	// Minimal sleep to defer initialization to after client constructor
	sleep(1)
	if(!src.client)
		return
	var/static/login_html
	if(isnull(login_html))
		login_html = rustg_file_read("html/login_handler.html")
		login_html = replacetext(login_html, "<!--- SERVER --->", CONFIG_GET(string/server) || "beestation")
	client << browse(login_html, "window=login;file=login.html;can_minimize=0;auto_format=0;titlebar=0;can_resize=0;")
	winshow(client, "login", FALSE)
	open()

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
	var/ip = user.client.address
	if(user.client.is_localhost())
		ip = "127.0.0.1"
	var/port_data = ""
	if(isnum_safe(user.client.seeker_port))
		port_data = "&seeker_port=[url_encode(user.client.seeker_port)]"
	.["decorator"] = "?ip=[url_encode(ip)][port_data]"
	.["authenticated_key"] = user.client.byond_authenticated_key

/datum/tgui_login/proc/save_session_token(token)
	if(!istext(token))
		return
	client << output("store&[token]", "login.browser:login_listener")

/datum/tgui_login/proc/clear_session_token()
	client << output("clear", "login.browser:login_listener")

/datum/tgui_login/proc/try_auth()
	if(IsAdminAdvancedProcCall())
		return
	client << output("login", "login.browser:login_listener")
