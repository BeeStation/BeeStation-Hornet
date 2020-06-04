//===============Camera Eye================
/mob/camera/aiEye/remote/shuttle_creation
	name = "shuttle holo-drone"
	icon = 'icons/obj/mining.dmi'
	icon_state = "construction_drone"
	visible_icon =  FALSE
	acceleration = 0
	var/turf/source_turf
	var/max_range = 12

/mob/camera/aiEye/remote/shuttle_creation/Initialize()
	. = ..()
	setLoc(get_turf(source_turf))

/mob/camera/aiEye/remote/shuttle_creation/update_remote_sight(mob/living/user)
	user.sight = BLIND|SEE_TURFS
	user.lighting_alpha = LIGHTING_PLANE_ALPHA_INVISIBLE
	user.sync_lighting_plane_alpha()
	return TRUE

/mob/camera/aiEye/remote/shuttle_creation/relaymove(mob/user, direct)
	dir = direct //This camera eye is visible as a drone, and needs to keep the dir updated
	var/initial = initial(sprint)
	var/max_sprint = 50

	if(cooldown && cooldown < world.timeofday) // 3 seconds
		sprint = initial

	for(var/i = 0; i < max(sprint, initial); i += 20)
		var/turf/step = get_turf(get_step(src, direct))
		if(step && can_move_to(step))
			setLoc(step)

	cooldown = world.timeofday + 5
	if(acceleration)
		sprint = min(sprint + 0.5, max_sprint)
	else
		sprint = initial

/mob/camera/aiEye/remote/shuttle_creation/proc/can_move_to(var/turf/T)
	var/origin_x = source_turf.x
	var/origin_y = source_turf.y
	var/change_X = abs(origin_x - T.x)
	var/change_Y = abs(origin_y - T.y)
	return (change_X < max_range && change_Y < max_range)

/mob/camera/aiEye/remote/shuttle_creation/setLoc(T)
	..()
	if(eye_user?.client)
		eye_user.client.images -= user_image
		var/image/I = image(icon, loc, icon_state, FLY_LAYER, dir)
		I.plane = MASSIVE_OBJ_LAYER
		user_image = I
		eye_user.client.images += user_image
