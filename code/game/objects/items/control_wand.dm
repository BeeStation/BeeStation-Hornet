#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "gangtool-white"
	inhand_icon_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	/// based on the given bitflag, gets the full access list of a relevant department
	var/department_bitflag = DEPT_BITFLAG_SRV //See department.dm
	/// a list of access that the door remote can control
	var/list/access_list

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	if(department_bitflag)
		for(var/datum/department_group/dept_datum as anything in SSdepartment.get_department_by_bitflag(department_bitflag))
			LAZYADD(access_list, dept_datum.access_list)
	else
		CRASH("the item [src.type] has no department_bitflag - cannot grant access!")

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	balloon_alert(user, "mode: [desc[mode]].")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/target, mob/user)
	. = ..()

	var/obj/machinery/door/door

	if (istype(target, /obj/machinery/door))
		door = target

		if (!door.opens_with_door_remote)
			return
	else
		for (var/obj/machinery/door/door_on_turf in get_turf(target))
			if (door_on_turf.opens_with_door_remote)
				door = door_on_turf
				break

		if (isnull(door))
			return

	if (!door.check_access_list(access_list) || door.id_scan_hacked())
		target.balloon_alert(user, "can't access!")
		return

	var/obj/machinery/door/airlock/airlock = door

	if (!door.hasPower() || (istype(airlock) && !airlock.canAIControl()))
		target.balloon_alert(user, mode == WAND_OPEN ? "it won't budge!" : "nothing happens!")
		return

	switch (mode)
		if (WAND_OPEN)
			if (door.density)
				door.open()
			else
				door.close()
		if (WAND_BOLT)
			if (!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			if (airlock.locked)
				airlock.unbolt()
			else
				airlock.bolt()
		if (WAND_EMERGENCY)
			if (!istype(airlock))
				target.balloon_alert(user, "only airlocks!")
				return

			airlock.emergency = !airlock.emergency
			airlock.update_appearance(UPDATE_ICON)

/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	department_bitflag = DEPT_BITFLAG_STATIONS

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	department_bitflag = DEPT_BITFLAG_STATIONS

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	department_bitflag = DEPT_BITFLAG_ENG

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	department_bitflag = DEPT_BITFLAG_SCI

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	department_bitflag = DEPT_BITFLAG_SEC

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	icon_state = "gangtool-green"
	department_bitflag = DEPT_BITFLAG_CAR

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	department_bitflag = DEPT_BITFLAG_MED

/obj/item/door_remote/civillian
	name = "civilian door remote"
	icon_state = "gangtool-white"
	department_bitflag = DEPT_BITFLAG_SRV | DEPT_BITFLAG_CAR

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
