/obj/item/uplink_beacon
	name = "uplink beacon"
	desc = "A portable, deployable beacon used to establish long-range communications."
	icon = 'icons/obj/traitor_beacon.dmi'
	icon_state = "base"
	var/datum/priority_directive/deploy_beacon/parent_directive

/obj/item/uplink_beacon/Initialize(mapload, datum/priority_directive/deploy_beacon/parent_directive)
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/uplink_beacon, time_to_deploy = 3 SECONDS, can_deploy_check = CALLBACK(src, PROC_REF(can_deploy)), on_after_deploy = CALLBACK(src, PROC_REF(after_deploy)))
	if (parent_directive)
		src.parent_directive = parent_directive
		RegisterSignal(parent_directive, COMSIG_QDELETING, PROC_REF(directive_ended))

/obj/item/uplink_beacon/proc/directive_ended()
	SIGNAL_HANDLER
	parent_directive = null

/obj/item/uplink_beacon/proc/can_deploy(mob/user, atom/location)
	if (!user || !location)
		return FALSE
	if (!user.mind.has_antag_datum(/datum/antagonist))
		to_chat(user, "<span class='warning'>You aren't sure what to do with this.</span>")
		return FALSE
	if (!istype(parent_directive))
		to_chat(user, "<span class='warning'>This beacon cannot be used anymore!</span>")
		return FALSE
	if (parent_directive.deployed_beacon)
		to_chat(user, "<span class='warning'>A beacon is already active, find and interact with it to modify its tramission frequency.</span>")
		return FALSE
	if (get_dist(src, parent_directive.center_turf) > 5)
		to_chat(user, "<span class='warning'>You are too far away from the deployment location, check your uplink for the deployment site.</span>")
		return FALSE
	return TRUE

/obj/item/uplink_beacon/proc/after_deploy(obj/structure/uplink_beacon/deployed, mob/living/user)
	deployed.on_deployed(parent_directive, user)

/obj/structure/uplink_beacon
	name = "uplink beacon"
	desc = "A small beacon attempting to establish communication with an unknown source."
	icon = 'icons/obj/traitor_beacon.dmi'
	icon_state = "base"
	light_system = MOVABLE_LIGHT
	light_power = 0.7
	light_range = 1.4
	anchored = TRUE
	var/current_frequency = 0
	var/time_left = 4 MINUTES
	var/spam_cooldown = 0
	var/datum/priority_directive/deploy_beacon/parent_directive

/obj/structure/uplink_beacon/Destroy()
	if (istype(parent_directive))
		parent_directive.beacon_broken()
		parent_directive = null
	return ..()

/obj/structure/uplink_beacon/proc/on_deployed(datum/priority_directive/deploy_beacon/beacon, mob/user)
	if (!istype(beacon))
		log_runtime("A traitor beacon was initialised but there is no directive for it to complete. It has been deleted.")
		qdel(src)
		return
	parent_directive = beacon
	if (user != null)
		// Try to find the team colour of the user
		var/datum/component/uplink/uplink = user.mind.find_syndicate_uplink()
		if (uplink)
			var/code = beacon.get_team(uplink).data["code"]
			current_frequency = code
		else
			current_frequency = rand(0, 8)
	else
		current_frequency = rand(0, 8)
	beacon.deployed_beacon = src
	beacon.on_beacon_planted(current_frequency)
	update_appearance(UPDATE_OVERLAYS)
	START_PROCESSING(SSobj, src)

/obj/structure/uplink_beacon/process(delta_time)
	if (!istype(parent_directive))
		log_runtime("A traitor beacon was processed but there is no directive for it to complete. It has been deleted.")
		qdel(src)
		return PROCESS_KILL
	if (time_left <= 0)
		// Complete the mission
		establish_connection()
		parent_directive.complete(current_frequency)
		return PROCESS_KILL
	time_left -= delta_time * 1 SECONDS
	parent_directive.update_time(time_left)

/obj/structure/uplink_beacon/update_overlays()
	. = ..()
	var/mutable_appearance/overlay_image = mutable_appearance(icon, "overlay", layer, plane)
	var/colour = uplink_beacon_channel_to_color_code(current_frequency)
	overlay_image.color = colour
	. += overlay_image
	. += emissive_appearance(icon, "overlay", layer, alpha = 120)
	set_light_color(colour)
	// So that we glow in the dark correctly
	ADD_LUM_SOURCE(src, LUM_SOURCE_MANAGED_OVERLAY)

/obj/structure/uplink_beacon/ui_interact(mob/user, datum/tgui/ui)
	// You must be something to interact with this
	if (!user || !user.mind || !user.mind.has_antag_datum(/datum/antagonist))
		return
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "UplinkBeacon")
		ui.open()

/obj/structure/uplink_beacon/ui_data(mob/user)
	var/list/data = list()
	data["frequency"] = current_frequency
	return data

/obj/structure/uplink_beacon/ui_act(action, params)
	if (..() || time_left <= 0)
		return FALSE
	var/new_num = text2num(params["freq"])
	if (isnull(new_num))
		return FALSE
	new_num = round(new_num)
	if (new_num < 0 || new_num > 8)
		return FALSE
	if (spam_cooldown > world.time)
		to_chat(usr, span_warning("[src] needs another [DisplayTimeText(spam_cooldown - world.time)] before it can change frequency!"))
		return FALSE
	spam_cooldown = world.time + 10 SECONDS
	update_frequency(new_num)
	return TRUE

/obj/structure/uplink_beacon/proc/update_frequency(new_frequency)
	var/old_freq = current_frequency
	current_frequency = new_frequency
	update_appearance(UPDATE_OVERLAYS)
	ui_update()
	if (!istype(parent_directive))
		return
	// If there is less than 30 seconds less on the timer, reset the timer to 30 seconds
	if (time_left < 30 SECONDS)
		time_left = 30 SECONDS
	parent_directive.beacon_colour_update(old_freq, current_frequency, time_left)

/// Establish connection with the syndicate base.
/// Grants everyone who was on the established frequency with their prize TC
/// and spews out some additional TC for people near the beacon to squabble over.
/obj/structure/uplink_beacon/proc/establish_connection()
	DECLARE_ASYNC
	if (!istype(parent_directive))
		log_runtime("A traitor beacon was processed but there is no directive for it to complete. It has been deleted.")
		qdel(src)
		return
	var/turf/origin = get_turf(src)
	var/list/throw_target_turfs = view(6, origin)
	for (var/i in 1 to rand(3, 6))
		var/turf/tc_turf = pick(throw_target_turfs)
		var/sanity = 500
		// Find another turf
		while (isclosedturf(tc_turf) && sanity-- > 0)
			tc_turf = pick(throw_target_turfs)
		var/obj/item/stack/sheet/telecrystal/telecrystal = new(tc_turf, 1)
		telecrystal.pixel_x = 32 * (origin.x - tc_turf.x)
		telecrystal.pixel_y = 32 * (origin.y - tc_turf.y)
		animate(telecrystal, time = 5, pixel_x = 0, pixel_y = 0)
	self_destruct()
	ASYNC_FINISH

/obj/structure/uplink_beacon/proc/self_destruct()
	balloon_alert_to_viewers("[src] establishes a connection, and engages its self-destruct mechanism!")
	playsound(src, 'sound/items/timer.ogg', 20)
	sleep(5 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 40)
	sleep(3 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 60)
	sleep(2 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 80)
	sleep(1 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 80)
	sleep(0.5 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.4 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.3 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.2 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.2 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.2 SECONDS)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(0.2 SECONDS)
	explosion(src, 0, 0, 4, 6)
	qdel(src)

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

/proc/uplink_beacon_channel_to_color_code(channel)
	var/static/list/colours = list(
		"#4bad4b",
		"#c179d9",
		"#e0da84",
		"#e38e3f",
		"#f65f5f",
		"#4c4c4c",
		"#d5d5d4",
		"#5960e9",
		"#744d23"
	)
	return colours[channel + 1]

