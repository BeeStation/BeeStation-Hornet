/obj/item/mod/module/tracking_beacon
	name = "\improper MOD tracking beacon module"
	desc = "A module which adds a tracking beacon to the suit, \
		along with the associated software needed to project the real-time locations \
		of such beacons as a heads up display in the helmet. Perfect to not lose track of your friends."
	icon_state = "tracking_beacon"
	removable = FALSE
	module_type = MODULE_USABLE
	incompatible_modules = list(/obj/item/mod/module/tracking_beacon)
	required_slots = list(ITEM_SLOT_HEAD)
	///weakref of our beacon
	var/datum/weakref/beacon_ref
	///weakref of our monitor
	var/datum/weakref/monitor_ref
	///optional, used for secure frequencies like syndicate or ert, can't be changed normally
	var/frequency_key
	///frequency we start on, can be null, will then only show global beacons until manually changed (ERTs set theirs when spawning)
	var/frequency
	///the color of the tracking beacon
	var/beacon_color =  COLOR_WHITE
	///the color of the tracking beacon if it is on a different z level
	var/beacon_zdiff_color = COLOR_WHITE
	///is the hud visible? stored so it doesn't activate with the helmet if it was previously disabled
	var/hud_visible = TRUE

/obj/item/mod/module/tracking_beacon/on_install()
	//the beacon goes into the MOD itself
	var/datum/component/tracking_beacon/beacon = mod.AddComponent(/datum/component/tracking_beacon, frequency_key, frequency, null, TRUE, beacon_color, FALSE, FALSE, beacon_zdiff_color)
	beacon_ref = WEAKREF(beacon)

	//monitor/HUD goes into the helmet of the mod
	var/obj/item/clothing/helmet = mod.get_part_from_slot(ITEM_SLOT_HEAD)
	if(!istype(helmet))
		return
	var/datum/component/team_monitor/worn/monitor = helmet.AddComponent(/datum/component/team_monitor/worn, frequency_key, frequency, beacon)
	monitor_ref = WEAKREF(monitor)
	beacon.attached_monitor = monitor
	//hud has to start off, otherwise can be seen even if the MOD is not active
	monitor.toggle_hud(FALSE)

/obj/item/mod/module/tracking_beacon/on_uninstall(deleting = FALSE)
	var/datum/component/tracking_beacon/beacon = beacon_ref?.resolve()
	if(beacon)
		qdel(beacon)
	var/datum/component/team_monitor/worn/monitor = monitor_ref?.resolve()
	if(monitor)
		qdel(monitor)

/obj/item/mod/module/tracking_beacon/on_part_activation()
	//was the hud enabled before the helmet was deactivated? if yes, enable it
	if(hud_visible)
		var/datum/component/team_monitor/worn/monitor = monitor_ref?.resolve()
		if(!monitor)
			return
		monitor.toggle_hud(TRUE, mod.wearer)

/obj/item/mod/module/tracking_beacon/on_part_deactivation(deleting = FALSE)
	var/datum/component/team_monitor/worn/monitor = monitor_ref?.resolve()
	if(!monitor)
		return
	//store the visibility of the HUD for when the helmet gets activated again
	hud_visible = monitor.hud_visible
	monitor.toggle_hud(FALSE, mod.wearer)

/obj/item/mod/module/tracking_beacon/on_use()
	var/list/radial_choices = generate_choices()
	if(!length(radial_choices))
		stack_trace("[src] generated no radial choices")
		return
	var/selection = show_radial_menu(mod.wearer, mod, radial_choices, radius = 36, custom_check = CALLBACK(src, PROC_REF(check_menu)), require_near = TRUE, tooltips = TRUE)
	//was there a selection? was the suit still on when we made it? (need to check again since the radial takes a bit to close when the suit deactivates)
	if(!selection || !check_menu())
		return
	switch(selection)
		if("Toggle Beacon")
			toggle_beacon(mod.wearer)
		if("Toggle HUD")
			toggle_hud(mod.wearer)
		if("Change Frequency")
			change_frequency(mod.wearer)

/obj/item/mod/module/tracking_beacon/proc/generate_choices()
	var/static/list/choices
	if(!choices)
		choices = list()
		//toggle beacon
		var/image/beacon_image = image('icons/hud/actions/action_generic.dmi', "toggle-transmission")
		var/datum/radial_menu_choice/toggle_beacon = new
		toggle_beacon.name = "Toggle Tracking Beacon"
		toggle_beacon.image = beacon_image
		choices["Toggle Beacon"] = toggle_beacon

		//toggle hud
		var/image/hud_image = image('icons/hud/actions/action_generic.dmi', "toggle-hud")
		var/datum/radial_menu_choice/toggle_hud = new
		toggle_hud.name = "Toggle Tracking HUD"
		toggle_hud.image = hud_image
		choices["Toggle HUD"] = toggle_hud

		//change frequency
		var/image/frequency_image = image('icons/hud/actions/action_generic.dmi', "change-code")
		var/datum/radial_menu_choice/change_frequency = new
		change_frequency.name = "Change Tracking Frequency"
		change_frequency.image = frequency_image
		choices["Change Frequency"] = change_frequency
	return choices

/// Callback for the radial to ensure it's closed when not allowed.
/obj/item/mod/module/tracking_beacon/proc/check_menu()
	if(QDELETED(src))
		return FALSE
	if(!part_activated)
		return FALSE
	return TRUE

/obj/item/mod/module/tracking_beacon/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = beacon_ref?.resolve()
	if(!beacon)
		stack_trace("Trying to toggle a tracking beacon which doesn't exist anymore")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, span_notice("You enable the tracking beacon on [mod]. Anybody on the same frequency will now be able to track your location."))
	else
		to_chat(user, span_warning("You disable the tracking beacon on [mod]."))

/obj/item/mod/module/tracking_beacon/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/worn/monitor = monitor_ref?.resolve()
	if(!monitor)
		stack_trace("Trying to toggle the hud of a tracking beacon which doesn't exist anymore")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, span_notice("You toggle the heads up display of your MOD."))
	else
		to_chat(user, span_warning("You disable the heads up display of your MOD."))

/obj/item/mod/module/tracking_beacon/proc/change_frequency(mob/user)
	var/datum/component/tracking_beacon/beacon = beacon_ref?.resolve()
	if(!beacon)
		stack_trace("Trying to change the frequency of a tracking beacon which doesn't exist anymore")
		return
	beacon.change_frequency(user)

/obj/item/mod/module/tracking_beacon/syndicate
	frequency_key = "synd"
	beacon_color = "#8f4a4b"
	beacon_zdiff_color = "#573d3d"

/obj/item/mod/module/tracking_beacon/centcom
	frequency_key = "cent"
	beacon_color = "#4b48ec"
	beacon_zdiff_color = "#0b0a47"

/obj/item/mod/module/tracking_beacon/centcom/security
	beacon_color = "#ec4848"
	beacon_zdiff_color = "#ca7878"

/obj/item/mod/module/tracking_beacon/centcom/engineer
	beacon_color = "#ecaa48"
	beacon_zdiff_color = "#daa960"

/obj/item/mod/module/tracking_beacon/centcom/medic
	beacon_color = "#88ecec"
	beacon_zdiff_color = "#4f8888"

/obj/item/mod/module/tracking_beacon/centcom/janitor
	beacon_color = "#be43ce"
	beacon_zdiff_color = "#895d8f"

/obj/item/mod/module/tracking_beacon/centcom/inquisitor
	beacon_color = "#9ddb56"
	beacon_zdiff_color = "#6a9e2f"

/obj/item/mod/module/tracking_beacon/centcom/deathsquad
	beacon_color = COLOR_BLACK
	beacon_zdiff_color = "#292828"

/obj/item/mod/module/tracking_beacon/centcom/clown
	beacon_color = "#f508e1"
	beacon_zdiff_color = "#a10587"
