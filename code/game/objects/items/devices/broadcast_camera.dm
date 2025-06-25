// Port from /TG/, please remove any shitcode if I missed any.
// Camera given to the Curator
// Broadcasts its surroundings to entertainment monitors and its audio to entertainment radio channel

/obj/item/broadcast_camera
	name = "broadcast camera"
	desc = "A large camera that streams its live feed and audio to entertainment monitors across the station, allowing everyone to watch the broadcast."
	desc_controls = "Right-click to change the broadcast name."
	icon = 'icons/obj/service/broadcast.dmi'
	base_icon_state = "broadcast_cam"
	icon_state = "broadcast_cam0"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 8
	throwforce = 12
	w_class = WEIGHT_CLASS_NORMAL
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	slot_flags = NONE
	light_system = MOVABLE_LIGHT
	light_color = COLOR_SOFT_RED
	light_range = 1
	light_power = 0.3
	light_on = FALSE
	// Is camera streaming
	var/active = FALSE
	// The name of the broadcast
	var/broadcast_name = "Curator News"
	// The networks it broadcasts to, default is CAMERANET_NETWORK_CURATOR
	var/list/camera_networks = list(CAMERA_NETWORK_CURATOR)
	// The "virtual" security camera inside of the physical camera
	var/obj/machinery/camera/active_camera
	// The "virtual" radio inside of the the physical camera, a la microphone
	var/obj/item/radio/entertainment/microphone/internal_radio
	// Whether the camera is currently updating its location
	var/updating = FALSE

/obj/item/broadcast_camera/Initialize(mapload)
	. = ..()

	AddElement(/datum/element/empprotection, EMP_PROTECT_SELF)

/obj/item/broadcast_camera/Destroy(force)
	QDEL_NULL(internal_radio)
	QDEL_NULL(active_camera)
	return ..()

/obj/item/broadcast_camera/update_icon_state()
	icon_state = "[base_icon_state][active]"
	return ..()

/obj/item/broadcast_camera/attack_self(mob/user, modifiers)
	. = ..()
	active = !active
	if(active)
		on_activating()
	else
		on_deactivating()

/obj/item/broadcast_camera/attack_self_secondary(mob/user, modifiers)
	. = ..()
	broadcast_name = tgui_input_text(user = user, title = "Broadcast Name", message = "What will be the name of your broadcast?", default = "[broadcast_name]", max_length = MAX_CHARTER_LEN)

/obj/item/broadcast_camera/examine(mob/user)
	. = ..()
	. += span_notice("Broadcast name is <b>[broadcast_name]</b>")

/obj/item/broadcast_camera/on_enter_storage(datum/storage/master_storage)
	. = ..()
	if(active)
		on_deactivating()

/obj/item/broadcast_camera/dropped(mob/user, silent)
	. = ..()
	if(active)
		on_deactivating()

/obj/item/broadcast_camera/proc/on_activating()
	if(!isliving(loc))
		return
	/// The mob who wielded the camera, allegedly
	var/mob/living/wielder = loc
	if(!wielder.is_holding(src))
		return
	active = TRUE
	update_icon_state()
	// INTERNAL CAMERA
	active_camera = new(wielder) // Cameras do not work inside of obj's
	active_camera.internal_light = FALSE
	active_camera.network = camera_networks
	active_camera.c_tag = "LIVE: [broadcast_name]"
	start_broadcasting_network(camera_networks, "[broadcast_name] is now LIVE!")

	// INTERNAL RADIO
	internal_radio = new(src)

	set_light_on(TRUE)
	playsound(source = src, soundin = 'sound/machines/terminal_processing.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("live!")

/// When deactivating the camera
/obj/item/broadcast_camera/proc/on_deactivating()
	active = FALSE
	update_icon_state()
	QDEL_NULL(active_camera)
	QDEL_NULL(internal_radio)

	stop_broadcasting_network(camera_networks)

	set_light_on(FALSE)
	playsound(source = src, soundin = 'sound/machines/terminal_prompt_deny.ogg', vol = 20, vary = FALSE, ignore_walls = FALSE)
	balloon_alert_to_viewers("offline")

/obj/item/broadcast_camera/proc/ensure_still_active()
	if(!active)
		return FALSE
	if(!isliving(loc))
		return FALSE
	var/mob/living/wielder = loc
	if(!wielder.is_holding(src))
		return FALSE
	return TRUE

/mob/living/wielder/Moved(oldLoc, dir)
	. = ..()
	var/obj/item/broadcast_camera/camera = src.get_active_held_item()
	if(istype(camera, /obj/item/broadcast_camera))
		camera.update_camera_location(oldLoc)

/mob/living/wielder/forceMove(atom/destination)
	. = ..()
	//Only bother updating the camera if we actually managed to move
	if(.)
		var/obj/item/broadcast_camera/camera = src.get_active_held_item()
		if(istype(camera, /obj/item/broadcast_camera))
			camera.update_camera_location(destination)

/obj/item/broadcast_camera/proc/do_camera_update(oldLoc)
	if(!QDELETED(active_camera) && oldLoc != get_turf(src))
		GLOB.cameranet.updatePortableCamera(active_camera)
	updating = FALSE

#define BROADCAST_CAMERA_BUFFER 10
/obj/item/broadcast_camera/proc/update_camera_location(oldLoc)
	oldLoc = get_turf(oldLoc)
	if(!QDELETED(active_camera) && !updating && oldLoc != get_turf(src))
		updating = TRUE
		addtimer(CALLBACK(src, PROC_REF(do_camera_update), oldLoc), BROADCAST_CAMERA_BUFFER)
#undef BROADCAST_CAMERA_BUFFER
