/obj/item/uplink_beacon
	name = "uplink beacon"
	desc = "A portable, deployable beacon used to establish long-range communications."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"

/obj/item/uplink_beacon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/uplink_beacon, time_to_deploy = 3 SECONDS)

/obj/structure/uplink_beacon
	name = "uplink beacon"
	desc = "A small beacon attempting to establish communication with an unknown source."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"
	var/current_frequency = 0

/obj/structure/uplink_beacon/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "UplinkBeacon")
		ui.open()

/obj/structure/uplink_beacon/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = current_frequency
	return data
