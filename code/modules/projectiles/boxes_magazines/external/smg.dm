/obj/item/ammo_box/magazine/wt550m9
	name = "wT-550 magazine (9mm)"
	icon_state = "46x30mmt-25"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 25

/obj/item/ammo_box/magazine/wt550m9/update_icon()
	..()
	icon_state = "46x30mmt-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/wt550m9/wtap
	name = "WT-550 magazine (Armour Piercing 9mm)"
	icon_state = "46x30mmtA-25"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/wt550m9/wtap/update_icon()
	..()
	icon_state = "46x30mmtA-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/wt550m9/wtic
	name = "WT-550 magazine (Incendiary 9mm)"
	icon_state = "46x30mmtI-25"
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/wt550m9/wtic/update_icon()
	..()
	icon_state = "46x30mmtI-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/wt550m9/rubber
	name = "WT-550 rubber magazine (Rubber 9mm)"
	icon_state = "46x30mmtT-25"
	ammo_type = /obj/item/ammo_casing/c9mm/rubber

/obj/item/ammo_box/magazine/wt550m9/rubber/update_icon()
	..()
	icon_state = "46x30mmtT-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/wt550m9/laser
	name = "WT-550 NT-LC magazine (9mm Laser Casing)"
	icon_state = "46x30mmtT-25"
	ammo_type = /obj/item/ammo_casing/c9mm/laser

/obj/item/ammo_box/magazine/wt550m9/laser/update_icon()
	..()
	icon_state = "46x30mmtT-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/wt550m9/disabler
	name = "WT-550 NT-DLC magazine (9mm Disabler Laser Casing)"
	icon_state = "46x30mmtT-25"
	ammo_type = /obj/item/ammo_casing/c9mm/disabler

/obj/item/ammo_box/magazine/wt550m9/disabler/update_icon()
	..()
	icon_state = "46x30mmtT-[round(ammo_count(),5)]"

/obj/item/ammo_box/magazine/uzim9mm
	name = "uzi magazine (9mm)"
	icon_state = "uzi9mm-32"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 32

/obj/item/ammo_box/magazine/uzim9mm/update_icon()
	..()
	icon_state = "uzi9mm-[round(ammo_count(),4)]"

/obj/item/ammo_box/magazine/smgm9mm
	name = "SMG magazine (9mm)"
	icon_state = "smg9mm-42"
	ammo_type = /obj/item/ammo_casing/c9mm
	caliber = "9mm"
	max_ammo = 21

/obj/item/ammo_box/magazine/smgm9mm/update_icon()
	..()
	icon_state = "smg9mm-[ammo_count() ? "42" : "0"]"

/obj/item/ammo_box/magazine/smgm9mm/ap
	name = "SMG magazine (Armour Piercing 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/ap

/obj/item/ammo_box/magazine/smgm9mm/fire
	name = "SMG Magazine (Incendiary 9mm)"
	ammo_type = /obj/item/ammo_casing/c9mm/inc

/obj/item/ammo_box/magazine/smgm45
	name = "SMG magazine (.45)"
	icon_state = "c20r45-24"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 24

/obj/item/ammo_box/magazine/smgm45/update_icon()
	..()
	icon_state = "c20r45-[round(ammo_count(),2)]"

/obj/item/ammo_box/magazine/tommygunm45
	name = "drum magazine (.45)"
	icon_state = "drum45"
	ammo_type = /obj/item/ammo_casing/c45
	caliber = ".45"
	max_ammo = 50

/obj/item/ammo_box/magazine/pipem9mm
	name = "pipe repeater magazine (9mm)"
	icon_state = "pipemag1"
	start_empty = TRUE
	ammo_type = /obj/item/ammo_casing/c9mm/improv
	caliber = "9mm"
	max_ammo = 6
	var/obj/item/stock_parts/matter_bin/installed_bin

/obj/item/ammo_box/magazine/pipem9mm/proc/update_capacity()
	max_ammo = initial(max_ammo) + (installed_bin.rating * 3)
	var/I = installed_bin.rating
	if(I > 4)
		I = 5
	icon_state = "pipemag[I]"
	update_icon()

/obj/item/ammo_box/magazine/pipem9mm/Initialize(mapload)
	. = ..()
	//Initialize with a basic/T1 matter bin installed
	installed_bin = new /obj/item/stock_parts/matter_bin(src)
	update_capacity()

/obj/item/ammo_box/magazine/pipem9mm/examine(mob/user)
	. = ..()
	. += "This one has a tier [installed_bin.rating] matter bin, and can hold [max_ammo] shells."
	if(installed_bin.rating < 4)
		. += "You could increase the capacity with a better matter bin..."

/obj/item/ammo_box/magazine/pipem9mm/attackby(obj/item/A, mob/user, params, silent = FALSE)
	if(istype(A, /obj/item/stock_parts/matter_bin))
		var/obj/item/stock_parts/B = A
		if(B.rating <= installed_bin.rating)
			to_chat(user, "<span class='warning'>\The [B] isn't better than the matter bin that's already installed!</span>")
			return
		to_chat(user, "<span class='notice'>You begin to rebuild \the [src] with the [B]</span>")
		if(do_after(user, 50, target = src))
			installed_bin.forceMove(drop_location())
			user.transferItemToLoc(B, src)
			installed_bin = B
			update_capacity()
			to_chat(user, "<span class='notice'>\The [src] can now hold [max_ammo] bullets!</span>")
			if(B.rating > 4)
				addtimer(CALLBACK(GLOBAL_PROC, GLOBAL_PROC_REF(to_chat), user, "<span class='notice'><i>Where'd you find that matter bin anyway..?</i></span>"), 50)
		return
	..()
