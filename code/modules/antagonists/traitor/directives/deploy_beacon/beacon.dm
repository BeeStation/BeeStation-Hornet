/obj/item/uplink_beacon
	name = "uplink beacon"
	desc = "A portable, deployable beacon used to establish long-range communications."
	icon = 'icons/obj/fulton.dmi'
	icon_state = "extraction_point"

/obj/item/uplink_beacon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/uplink_beacon, time_to_deploy = 3 SECONDS, can_deploy_check = PROC_REF(can_deploy))

/obj/item/uplink_beacon/proc/can_deploy(mob/user, atom/location)
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		to_chat(user, "<span class='warning'>The beacon doesn't work in this location.</span>")
		return FALSE
	if (beacon.deployed_beacon)
		to_chat(user, "<span class='warning'>A beacon is already active, find and interact with it to modify its tramission frequency.</span>")
		return FALSE
	return TRUE

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

/obj/structure/uplink_beacon/ui_act(action, params)
	if (..())
		return FALSE
	var/new_num = text2num(params["freq"])
	if (isnull(new_num))
		return FALSE
	new_num = round(new_num)
	if (new_num < 0 || new_num > 8)
		return FALSE
	current_frequency = new_num
	ui_update()
	return TRUE

/proc/uplink_beacon_channel_to_color(channel)
	var/static/list/colours = list(
		"green",
		"purple",
		"yellow",
		"orange",
		"red",
		"black",
		"white",
		"blue",
		"brown"
	)
	return colours[channel + 1]
