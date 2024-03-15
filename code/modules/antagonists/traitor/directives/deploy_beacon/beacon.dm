/obj/item/uplink_beacon
	name = "uplink beacon"
	desc = "A portable, deployable beacon used to establish long-range communications."

/obj/item/uplink_beacon/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/deployable, /obj/structure/uplink_beacon, time_to_deploy = 3 SECONDS)

/obj/structure/uplink_beacon
	name = "uplink beacon"
	desc = "A small beacon attempting to establish communication with an unknown source."
