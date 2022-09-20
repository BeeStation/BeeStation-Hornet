/mob/camera/ai_eye/remote/ratvar
	visible_icon = TRUE
	icon = 'icons/mob/cameramob.dmi'
	icon_state = "generic_camera"

/obj/machinery/computer/camera_advanced/ratvar
	name = "ratvarian observation console"
	desc = "Used by the servants of Ratvar to conduct operations on Nanotrasen property."
	icon_screen = "ratvar1"
	icon_keyboard = "ratvar_key1"
	icon_state = "ratvarcomputer"
	clockwork = TRUE
	lock_override = CAMERA_LOCK_STATION
	broken_overlay_emissive = TRUE

/obj/machinery/computer/camera_advanced/ratvar/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/machinery/computer/camera_advanced/ratvar/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/machinery/computer/camera_advanced/ratvar/process(delta_time)
	if(DT_PROB(3, delta_time))
		new /obj/effect/temp_visual/steam_release(get_turf(src))
	if(DT_PROB(7, delta_time))
		playsound(get_turf(src), 'sound/machines/beep.ogg', 20, TRUE)

/obj/machinery/computer/camera_advanced/ratvar/can_use(mob/living/user)
	. = ..()
	if(!is_servant_of_ratvar(user))
		return FALSE

/obj/machinery/computer/camera_advanced/ratvar/CreateEye()
	eyeobj = new /mob/camera/ai_eye/remote/ratvar(get_turf(SSmapping.get_station_center()))
	eyeobj.origin = src
	eyeobj.visible_icon = TRUE
	eyeobj.icon = 'icons/mob/cameramob.dmi'
	eyeobj.icon_state = "ratvar_camera"
