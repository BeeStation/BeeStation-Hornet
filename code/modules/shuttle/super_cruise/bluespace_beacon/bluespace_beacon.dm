
/obj/structure/bluespace_beacon
    name = "bluespace giga-beacon"
    desc = "Locks a location on the navigational map, allowing for it to be returned to at any time."

/obj/structure/bluespace_beacon/Initialize()
	. = ..()
	GLOB.zclear_blockers += src

/obj/structure/bluespace_beacon/Destroy()
	GLOB.zclear_blockers -= src
	. = ..()
