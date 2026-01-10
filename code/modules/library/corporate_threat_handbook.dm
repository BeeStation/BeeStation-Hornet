/obj/item/book/manual/tgui_handbook
	name = "Nanotrasen Incident Awareness Handbook"
	desc = "An official-looking, faintly mildewed handbook full of mandatory reading. The cover is stamped 'FOR INTERNAL DISTRIBUTION' and smells like recycled paper and burnt coffee."
	icon = 'icons/obj/library.dmi'
	icon_state = "security_briefing"
	author = "Nanotrasen Compliance & Workplace Readiness"
	title = "Incident Awareness & Threat Recognition (Crew Issue)"
	unique = TRUE

/obj/item/book/manual/tgui_handbook/attack_self(mob/user)
	ui_interact(user)

/obj/item/book/manual/tgui_handbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "CorporateThreatHandbook", name)
		ui.open()

/obj/item/book/manual/tgui_handbook/ui_state(mob/user)
	return GLOB.always_state

/obj/item/book/manual/tgui_handbook/ui_static_data(mob/user)
	var/list/data = list()
	// Boilerplate - data will be populated when TGUI interface is expanded
	data["handbook_title"] = "Incident Awareness & Threat Recognition"
	data["handbook_author"] = "Nanotrasen Compliance & Workplace Readiness"
	return data

/obj/item/book/manual/tgui_handbook/ui_data(mob/user)
	var/list/data = list()
	// Boilerplate - dynamic data will be populated when TGUI interface is expanded
	return data
