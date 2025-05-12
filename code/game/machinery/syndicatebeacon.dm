/obj/machinery/power/singularity_beacon
	name = "ominous beacon"
	desc = "This looks suspicious..."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "beacon0"
	anchored = FALSE
	density = TRUE
	layer = BELOW_MOB_LAYER
	verb_say = "states"

	/// Whether or not the beacon is enabled
	var/active = FALSE
	/// How much power the beacon draws from the grid
	var/power_draw = 1500
	/// The icon_state of the beacon. 1 is added to the end of the icon_state if it is active, and 0 is added if it is not.
	var/icontype = "beacon"
	/// Cooldown time inbetween notifying the user of the singularity's distance
	var/cooldown = 10 SECONDS

	COOLDOWN_DECLARE(notify_cooldown)

/obj/machinery/power/singularity_beacon/Destroy()
	STOP_PROCESSING(SSmachines, src)

	if(active)
		deactivate()
	. = ..()

/obj/machinery/power/singularity_beacon/attack_silicon(mob/user)
	return

/obj/machinery/power/singularity_beacon/attack_hand(mob/user, list/modifiers)
	if(!anchored)
		balloon_alert(user, "not anchored!")
		return

	if(active)
		deactivate(user)
	else
		activate(user)

/obj/machinery/power/singularity_beacon/attackby(obj/item/attacking_item, mob/user, params)
	if(attacking_item.tool_behaviour != TOOL_WRENCH)
		return ..()

	if(!anchored)
		if(!connect_to_network())
			balloon_alert(user, "not connected to cable!")
			return

		set_anchored(TRUE)

		attacking_item.play_tool_sound(src)
		balloon_alert(user, "anchored!")
	else
		set_anchored(FALSE)
		disconnect_from_network()

		attacking_item.play_tool_sound(src)
		balloon_alert(user, "unanchored!")

// We start processing on Init
/obj/machinery/power/singularity_beacon/process()
	if(!active)
		return

	if(surplus() >= power_draw)
		add_load(power_draw)

		if(!COOLDOWN_FINISHED(src, notify_cooldown))
			return

		for(var/datum/component/singularity/singulo_component in GLOB.singularities)
			var/atom/singulo = singulo_component.parent
			if(singulo.get_virtual_z_level() == get_virtual_z_level())
				say("[singulo] is now [get_dist(src, singulo)] standard lengths away to the [dir2text(get_dir(src, singulo))]")

		COOLDOWN_START(src, notify_cooldown, cooldown)
	else
		deactivate()
		say("Insufficient power, shutting down")

/obj/machinery/power/singularity_beacon/proc/activate(mob/user)
	if(surplus() < power_draw)
		balloon_alert(user, "not enough power!")
		return

	// Set all singularities on our zlevel to target this beacon
	for(var/datum/component/singularity/singulo in GLOB.singularities)
		var/atom/singulo_atom = singulo.parent
		if(singulo_atom.get_virtual_z_level() == get_virtual_z_level())
			singulo.target = src

	icon_state = "[icontype]1"

	active = TRUE
	balloon_alert(user, "enabled!")

/obj/machinery/power/singularity_beacon/proc/deactivate(mob/user)
	// Unlink singularities that are targetting this beacon
	for(var/datum/component/singularity/singulo in GLOB.singularities)
		if(singulo.target == src)
			singulo.target = null

	icon_state = "[icontype]0"

	active = FALSE
	balloon_alert(user, "disabled!")

/obj/machinery/power/singularity_beacon/syndicate
	icon_state = "beaconsynd0"
	icontype = "beaconsynd"

// SINGULO BEACON SPAWNER
/obj/item/sbeacondrop
	name = "suspicious beacon"
	desc = "A label on it reads: <i>Warning: Activating this device will send a singularity beacon to your location</i>."
	icon = 'icons/obj/device.dmi'
	icon_state = "beacon"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL

	/// The item to spawn
	var/droptype = /obj/machinery/power/singularity_beacon/syndicate

/obj/item/sbeacondrop/attack_self(mob/user)
	if(user)
		to_chat(user, span_notice("Locked In."))
		new droptype(user.loc)
		playsound(src, 'sound/effects/pop.ogg', 100, 1, 1)
		qdel(src)

/obj/item/sbeacondrop/bomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a high-ordinance explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb

/obj/item/sbeacondrop/powersink
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/item/powersink

/obj/item/sbeacondrop/clownbomb
	desc = "A label on it reads: <i>Warning: Activating this device will send a silly explosive to your location</i>."
	droptype = /obj/machinery/syndicatebomb/badmin/clown

/obj/item/sbeacondrop/constructshell
	desc = "A label on it reads: <i>Warning: Activating this device will send a Nar'sian construct shell to your location</i>."
	droptype = /obj/structure/constructshell

/obj/item/sbeacondrop/semiautoturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a semi-auto turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/pod

/obj/item/sbeacondrop/heavylaserturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a heavy laser turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/energy/heavy

/obj/item/sbeacondrop/penetratorturret
	desc = "A label on it reads: <i>Warning: Activating this device will send a penetrator turret to your location</i>."
	droptype = /obj/machinery/porta_turret/syndicate/shuttle
