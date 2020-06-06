GLOBAL_LIST_INIT(bluespace_drives, list())

/obj/machinery/bluespace_drive
	name = "bluespace drive"

/obj/machinery/bluespace_drive/Initialize()
	. = ..()
	GLOB.bluespace_drives += src
