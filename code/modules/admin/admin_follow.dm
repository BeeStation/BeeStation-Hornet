/datum/admins/proc/admin_follow(atom/movable/AM)
	if(!isobserver(usr) && !check_rights(R_ADMIN))
		return

	var/client/C = usr.client
	var/can_ghost = TRUE
	if(!isobserver(usr))
		can_ghost = C.admin_ghost()

	if(!can_ghost)
		return
	var/mob/dead/observer/A = C.mob
	A.ManualFollow(AM)
