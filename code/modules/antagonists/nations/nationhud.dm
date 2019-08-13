/datum/atom_hud/antag/nation
	var/color = null

/datum/atom_hud/antag/nation/add_to_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/nation/remove_from_hud(atom/A)
	if(!A)
		return
	var/image/holder = A.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()

/datum/atom_hud/antag/nation/join_hud(mob/M)
	if(!istype(M))
		CRASH("join_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = color
	..()

/datum/atom_hud/antag/nation/leave_hud(mob/M)
	if(!istype(M))
		CRASH("leave_hud(): [M] ([M.type]) is not a mob!")
	var/image/holder = M.hud_list[ANTAG_HUD]
	if(holder)
		holder.color = null
	..()
