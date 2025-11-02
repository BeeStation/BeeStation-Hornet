/obj/item/uplink_beacon
	name = "uplink beacon"
	desc = "A portable, deployable beacon used to establish long-range communications."
	icon = 'icons/obj/traitor_beacon.dmi'
	icon_state = "base"

/obj/item/uplink_beacon/Initialize()
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/uplink_beacon, time_to_deploy = 3 SECONDS, can_deploy_check = CALLBACK(src, PROC_REF(can_deploy)))

/obj/item/uplink_beacon/proc/can_deploy(mob/user, atom/location)
	if (!user || !location)
		return FALSE
	if (!user.mind.has_antag_datum(/datum/antagonist))
		to_chat(user, "<span class='warning'>You aren't sure what to do with this.</span>")
		return FALSE
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		to_chat(user, "<span class='warning'>This beacon cannot be used anymore!</span>")
		return FALSE
	if (beacon.deployed_beacon)
		to_chat(user, "<span class='warning'>A beacon is already active, find and interact with it to modify its tramission frequency.</span>")
		return FALSE
	if (get_dist(src, beacon.center_turf) > 5)
		to_chat(user, "<span class='warning'>You are too far away from the deployment location, check your uplink for the deployment site.</span>")
		return FALSE
	return TRUE

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

/obj/structure/uplink_beacon/Initialize(mapload, mob/living/user)
	. = ..()
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		log_runtime("A traitor beacon was initialised but there is no directive for it to complete. It has been deleted.")
		return INITIALIZE_HINT_QDEL
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
	START_PROCESSING(SSprocessing, src)

/obj/structure/uplink_beacon/Destroy()
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (istype(beacon))
		beacon.beacon_broken()
	return ..()

/obj/structure/uplink_beacon/process(delta_time)
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		log_runtime("A traitor beacon was processed but there is no directive for it to complete. It has been deleted.")
		qdel(src)
		return PROCESS_KILL
	if (time_left <= 0)
		// Complete the mission
		establish_connection()
		beacon.complete(current_frequency)
		return PROCESS_KILL
	time_left -= delta_time * 1 SECONDS
	beacon.update_time(time_left)

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
		to_chat(usr, "<span class='warning'>[src] needs another [DisplayTimeText(spam_cooldown - world.time)] before it can change frequency!</span>")
		return FALSE
	spam_cooldown = world.time + 10 SECONDS
	update_frequency(new_num)
	return TRUE

/obj/structure/uplink_beacon/proc/update_frequency(new_frequency)
	var/old_freq = current_frequency
	current_frequency = new_frequency
	update_appearance(UPDATE_OVERLAYS)
	ui_update()
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		return
	// If there is less than 30 seconds less on the timer, reset the timer to 30 seconds
	if (time_left < 30 SECONDS)
		time_left = 30 SECONDS
	beacon.beacon_colour_update(old_freq, current_frequency, time_left)

/// Establish connection with the syndicate base.
/// Grants everyone who was on the established frequency with their prize TC
/// and spews out some additional TC for people near the beacon to squabble over.
/obj/structure/uplink_beacon/proc/establish_connection()
	DECLARE_ASYNC
	var/datum/priority_directive/deploy_beacon/beacon = SSdirectives.active_directive
	if (!istype(beacon))
		log_runtime("A traitor beacon was processed but there is no directive for it to complete. It has been deleted.")
		qdel(src)
		return
	var/turf/origin = get_turf(src)
	var/list/throw_target_turfs = view(6, origin)
	for (var/i in 1 to rand(3, 6))
		var/turf/tc_turf = pick(throw_target_turfs)
		var/obj/item/stack/sheet/telecrystal/telecrystal = new(tc_turf, 1)
		telecrystal.pixel_x = 32 * (origin.x - tc_turf.x)
		telecrystal.pixel_y = 32 * (origin.y - tc_turf.y)
		animate(telecrystal, time = 5, pixel_x = 0, pixel_y = 0)
	self_destruct()
	ASYNC_FINISH

/obj/structure/uplink_beacon/proc/self_destruct()
	balloon_alert_to_viewers("[src] establishes a connection, and engages its self-destruct mechanism!")
	playsound(src, 'sound/items/timer.ogg', 20)
	sleep(50)
	playsound(src, 'sound/items/timer.ogg', 40)
	sleep(30)
	playsound(src, 'sound/items/timer.ogg', 60)
	sleep(20)
	playsound(src, 'sound/items/timer.ogg', 80)
	sleep(10)
	playsound(src, 'sound/items/timer.ogg', 80)
	sleep(5)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(4)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(3)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(2)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(2)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(2)
	playsound(src, 'sound/items/timer.ogg', 100)
	sleep(2)
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

