#define WAND_OPEN "open"
#define WAND_BOLT "bolt"
#define WAND_EMERGENCY "emergency"

/obj/item/door_remote
	icon_state = "gangtool-white"
	item_state = "electronic"
	lefthand_file = 'icons/mob/inhands/misc/devices_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/devices_righthand.dmi'
	icon = 'icons/obj/device.dmi'
	name = "control wand"
	desc = "Remotely controls airlocks."
	w_class = WEIGHT_CLASS_TINY
	var/mode = WAND_OPEN
	var/region_access = 1 //See access.dm
	var/list/access_list
	network_id = NETWORK_DOOR_REMOTES

/obj/item/door_remote/Initialize(mapload)
	. = ..()
	access_list = get_region_accesses(region_access)
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_NAK, PROC_REF(bad_signal))
	RegisterSignal(src, COMSIG_COMPONENT_NTNET_ACK, PROC_REF(good_signal))

/obj/item/door_remote/proc/bad_signal(datum/source, datum/netdata/data, error_code)
	if(QDELETED(data.user))
		return // can't send a message to a missing user
	if(error_code == NETWORK_ERROR_UNAUTHORIZED)
		to_chat(data.user, "<span class='notice'>This remote is not authorized to modify this door.</span>")
	else
		to_chat(data.user, "<span class='notice'>Error: [error_code]</span>")


/obj/item/door_remote/proc/good_signal(datum/source, datum/netdata/data, error_code)
	if(QDELETED(data.user))
		return
	var/toggled = data.data["data"]
	to_chat(data.user, "<span class='notice'>Door [toggled] toggled</span>")

/obj/item/door_remote/attack_self(mob/user)
	var/static/list/desc = list(WAND_OPEN = "Open Door", WAND_BOLT = "Toggle Bolts", WAND_EMERGENCY = "Toggle Emergency Access")
	switch(mode)
		if(WAND_OPEN)
			mode = WAND_BOLT
		if(WAND_BOLT)
			mode = WAND_EMERGENCY
		if(WAND_EMERGENCY)
			mode = WAND_OPEN
	balloon_alert(user, "You set the mode to [desc[mode]].")

// Airlock remote works by sending NTNet packets to whatever it's pointed at.
/obj/item/door_remote/afterattack(atom/A, mob/user)
	. = ..()
	var/datum/component/ntnet_interface/target_interface = A.GetComponent(/datum/component/ntnet_interface)

	if(!target_interface)
		return
	if(!SSnetworks.station_network.check_function(NTNET_SYSTEMCONTROL, get_virtual_z_level()))
		to_chat(user, "<span class='warning'>red light flashes on the remote! Looks like NTNET is down!</span>")
		return
	user.set_machine(src)
	// Generate a control packet.
	var/datum/netdata/data = new(list("data" = mode,"data_secondary" = "toggle"))
	data.receiver_id = target_interface.hardware_id
	data.passkey = access_list
	data.user = user // for responce message

	ntnet_send(data)


/obj/item/door_remote/omni
	name = "omni door remote"
	desc = "This control wand can access any door on the station."
	icon_state = "gangtool-yellow"
	region_access = 0

/obj/item/door_remote/captain
	name = "command door remote"
	icon_state = "gangtool-yellow"
	region_access = 7

/obj/item/door_remote/chief_engineer
	name = "engineering door remote"
	icon_state = "gangtool-orange"
	region_access = 5

/obj/item/door_remote/research_director
	name = "research door remote"
	icon_state = "gangtool-purple"
	region_access = 4

/obj/item/door_remote/head_of_security
	name = "security door remote"
	icon_state = "gangtool-red"
	region_access = 2

/obj/item/door_remote/quartermaster
	name = "supply door remote"
	desc = "Remotely controls airlocks. This remote has additional Vault access."
	icon_state = "gangtool-green"
	region_access = 6

/obj/item/door_remote/chief_medical_officer
	name = "medical door remote"
	icon_state = "gangtool-blue"
	region_access = 3

/obj/item/door_remote/civillian
	name = "civilian door remote"
	icon_state = "gangtool-white"
	region_access = 1

#undef WAND_OPEN
#undef WAND_BOLT
#undef WAND_EMERGENCY
