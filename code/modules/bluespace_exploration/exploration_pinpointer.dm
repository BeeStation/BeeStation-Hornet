/obj/item/pinpointer/exploration
	name = "exploration pinpointer"
	desc = "A handheld tracking device that locks onto the signal emitted by a bluespace drive. You can link it with a bluespace drive."

/obj/item/pinpointer/exploration/Initialize()
	. = ..()
	if(LAZYLEN(GLOB.bluespace_drives))
		target = GLOB.bluespace_drives[1]

/obj/item/pinpointer/exploration/attack_obj(obj/O, mob/living/user)
	. = ..()
	var/obj/machinery/bluespace_drive/bs_drive = O
	if(istype(bs_drive))
		target = bs_drive
