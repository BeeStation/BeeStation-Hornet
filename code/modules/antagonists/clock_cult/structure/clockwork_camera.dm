/mob/camera/aiEye/remote/ratvar
	visible_icon = TRUE
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "generic_camera"

/datum/action/innate/clockcult/warp
	button_icon_state = "warp_down"

/datum/action/innate/clockcult/warp/IsAvailable()
	if(!is_servant_of_ratvar(owner) || owner.incapacitated())
		return FALSE
	return ..()

/datum/action/innate/clockcult/warp/Activate()
	if(!isliving(owner))
		return
	var/mob/living/M = owner
	var/mob/camera/aiEye/remote/ratvar/cam = M.remote_control
	var/target_loc = get_turf(cam)
	if(!get_area(target_loc).clockwork_warp_allowed)
		to_chat(owner, "<span class='brass'>[get_area(target_loc).clockwork_warp_fail]</span>")
		return
	do_sparks(5, TRUE, get_turf(cam))
	if(do_after(M, 50, target=target_loc))
		try_warp_servant(M, target_loc, 50, FALSE)

/obj/machinery/computer/camera_advanced/ratvar
	name = "ratvarian observation console"
	desc = "Used by the servants of Ratvar to conduct operations on Nanotrasen property."
	icon_screen = "cameras"
	icon_keyboard = "security_key"
	icon_state = "ratvarcomputer"
	clockwork = TRUE
	lock_override = CAMERA_LOCK_STATION
	var/datum/action/innate/clockcult/warp/warp_action

/obj/machinery/computer/camera_advanced/ratvar/Initialize()
	. = ..()
	warp_action = new

/obj/machinery/computer/camera_advanced/ratvar/GrantActions(mob/living/user)
	. = ..()
	if(warp_action)
		warp_action.target = src
		warp_action.Grant(user)
		actions += warp_action

/obj/machinery/computer/camera_advanced/ratvar/CreateEye()
	eyeobj = new /mob/camera/aiEye/remote/ratvar(get_turf(SSmapping.get_station_center()))
	eyeobj.origin = src
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "ratvar_camera"
