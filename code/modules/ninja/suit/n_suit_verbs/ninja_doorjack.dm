/datum/action/item_action/ninja_hack
	name = "Security Bypass"
	desc = "Allows bypassing the security of airlocks to force them to open."
	button_icon_state = "knock"
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	requires_target = TRUE
	cooldown_time = 3 SECONDS

/datum/action/item_action/ninja_hack/is_available()
	if (!..())
		return FALSE
	var/obj/item/clothing/suit/space/space_ninja/ninja = master
	return ninja.s_initialized

/datum/action/item_action/ninja_hack/on_activate(mob/user, obj/machinery/door/airlock/target)
	if (!istype(target))
		return
	var/datum/netdata/open_packet = new(list(
		"data" = "open",
		"data_secondary" = "on"
	))
	target.ntnet_receive(user, open_packet)
	to_chat(user, span_warning("Uploading packet, requires the target to have a wireless connection and be powered..."))
	start_cooldown()
	return TRUE
