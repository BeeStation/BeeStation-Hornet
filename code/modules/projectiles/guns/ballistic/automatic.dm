/obj/item/gun/ballistic/automatic
	w_class = WEIGHT_CLASS_LARGE
	var/select = 1
	can_suppress = TRUE
	actions_types = list(/datum/action/item_action/toggle_firemode)
	semi_auto = TRUE
	fire_sound = "sound/weapons/smgshot.ogg"
	fire_sound_volume = 80
	automatic = 1
	rack_sound = "sound/weapons/smgrack.ogg"
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/automatic/proto
	name = "\improper Nanotrasen Saber SMG"
	desc = "A prototype three-round burst 9mm submachine gun, designated 'SABR'. Has a threaded barrel for suppressors."
	icon_state = "saber"
	mag_type = /obj/item/ammo_box/magazine/smgm9mm
	pin = null
	fire_rate = 5
	fire_delay = 2
	bolt_type = BOLT_TYPE_LOCKING
	mag_display = TRUE
	weapon_weight = WEAPON_LIGHT
	burst_size = 3

/obj/item/gun/ballistic/automatic/proto/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/update_icon()
	..()
	if(!select)
		add_overlay("[initial(icon_state)]_semi")
	if(select == 1)
		add_overlay("[initial(icon_state)]_burst")

/obj/item/gun/ballistic/automatic/ui_action_click(mob/user, actiontype)
	if(istype(actiontype, /datum/action/item_action/toggle_firemode))
		burst_select()
	else
		..()

/obj/item/gun/ballistic/automatic/proc/burst_select()
	var/mob/living/carbon/human/user = usr
	select = !select
	if(!select)
		burst_size = 1
		fire_delay = 0
		to_chat(user, span_notice("You switch to [full_auto ? "full-auto": "semi-automatic."]"))
	else
		burst_size = initial(burst_size)
		fire_delay = initial(fire_delay)
		to_chat(user, span_notice("You switch to [burst_size]-rnd burst."))

	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	update_action_buttons()
	autofire_target = null

/obj/item/gun/ballistic/automatic/c20r
	name = "\improper C-20r SMG"
	desc = "A bullpup two-round burst .45 SMG, designated 'C-20r'. Has a 'Scarborough Arms - Per falcis, per pravitas' buttstamp."
	icon_state = "c20r"
	item_state = "c20r"
	mag_type = /obj/item/ammo_box/magazine/smgm45
	fire_delay = 2
	burst_size = 2
	pin = /obj/item/firing_pin/implant/pindicate
	spread_unwielded = 8
	can_bayonet = TRUE
	knife_x_offset = 26
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/c20r/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/c20r/Initialize(mapload)
	. = ..()
	update_icon()

/obj/item/gun/ballistic/automatic/wt550
	name = "security auto rifle"
	desc = "An outdated personal defence weapon. Uses 4.6x30mm rounds and is designated the WT-550 Automatic Rifle."
	icon_state = "wt550"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/wt550m9
	can_suppress = FALSE
	actions_types = list()
	can_bayonet = TRUE
	knife_x_offset = 25
	knife_y_offset = 12
	mag_display = TRUE
	mag_display_ammo = TRUE
	empty_indicator = TRUE
	fire_rate = 3
	w_class = WEIGHT_CLASS_BULKY
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/wt550/rubber_loaded/Initialize(mapload)
	magazine = new /obj/item/ammo_box/magazine/wt550m9/rubber(src)
	. = ..()

/obj/item/gun/ballistic/automatic/mini_uzi
	name = "\improper Type U3 Uzi"
	desc = "A lightweight submachine gun, for when you really want someone dead. Uses 9mm rounds."
	icon_state = "miniuzi"
	mag_type = /obj/item/ammo_box/magazine/uzim9mm
	bolt_type = BOLT_TYPE_OPEN
	mag_display = TRUE
	fire_rate = 4
	rack_sound = "sound/weapons/pistollock.ogg"

/obj/item/gun/ballistic/automatic/m90
	name = "\improper M-90gl Carbine"
	desc = "A three-round burst 5.56 toploading carbine, designated 'M-90gl'. Has an attached underbarrel grenade launcher."
	desc_controls = "Right-click to use grenade launcher."
	icon_state = "m90"
	item_state = "m90"
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = FALSE
	var/obj/item/gun/ballistic/revolver/grenadelauncher/underbarrel
	burst_size = 3
	fire_delay = 2
	pin = /obj/item/firing_pin/implant/pindicate
	spread_unwielded = 8
	mag_display = TRUE
	empty_indicator = TRUE

/obj/item/gun/ballistic/automatic/m90/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher(src)
	update_icon()

/obj/item/gun/ballistic/automatic/m90/unrestricted
	pin = /obj/item/firing_pin

/obj/item/gun/ballistic/automatic/m90/unrestricted/Initialize(mapload)
	. = ..()
	underbarrel = new /obj/item/gun/ballistic/revolver/grenadelauncher/unrestricted(src)
	update_icon()

/obj/item/gun/ballistic/automatic/m90/afterattack_secondary(atom/target, mob/living/user, flag, params)
	underbarrel.afterattack(target, user, flag, params)
	return SECONDARY_ATTACK_CONTINUE_CHAIN

/obj/item/gun/ballistic/automatic/m90/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/ammo_casing))
		if(istype(A, underbarrel.magazine.ammo_type))
			underbarrel.attack_self()
			underbarrel.attackby(A, user, params)
	else
		..()

/obj/item/gun/ballistic/automatic/m90/update_icon()
	..()
	switch(select)
		if(0)
			add_overlay("[initial(icon_state)]_semi")
		if(1)
			add_overlay("[initial(icon_state)]_burst")
	return

/obj/item/gun/ballistic/automatic/m90/burst_select()
	var/mob/living/carbon/human/user = usr
	switch(select)
		if(0)
			select = 1
			burst_size = initial(burst_size)
			fire_delay = initial(fire_delay)
			to_chat(user, span_notice("You switch to [burst_size]-rnd burst."))
		if(1)
			select = 0
			burst_size = 1
			fire_delay = 0
			to_chat(user, span_notice("You switch to semi-auto."))
	playsound(user, 'sound/weapons/empty.ogg', 100, 1)
	update_icon()
	return

/obj/item/gun/ballistic/automatic/tommygun
	name = "\improper Thompson SMG"
	desc = "Based on the classic 'Chicago Typewriter'."
	icon_state = "tommygun"
	item_state = "shotgun"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/tommygunm45
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	fire_rate = 5
	can_suppress = FALSE
	bolt_type = BOLT_TYPE_OPEN

/obj/item/gun/ballistic/automatic/ar
	name = "\improper NT-ARG 'Boarder'"
	desc = "A robust assault rifle used by Nanotrasen fighting forces."
	icon_state = "arg"
	item_state = "arg"
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/m556
	fire_sound = 'sound/weapons/gunshot_smg.ogg'
	can_suppress = FALSE
	fire_rate = 4


// L6 SAW //

/obj/item/gun/ballistic/automatic/l6_saw
	name = "\improper L6 SAW"
	desc = "A heavily modified 7.12x82mm light machine gun, designated 'L6 SAW'. Has 'Aussec Armoury - 2531' engraved on the receiver below the designation."
	icon_state = "l6"
	item_state = "l6closedmag"
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = 0
	mag_type = /obj/item/ammo_box/magazine/mm712x82
	weapon_weight = WEAPON_HEAVY
	var/cover_open = FALSE
	can_suppress = FALSE
	fire_rate = 6
	spread = 7
	pin = /obj/item/firing_pin/implant/pindicate
	bolt_type = BOLT_TYPE_OPEN
	mag_display = TRUE
	mag_display_ammo = TRUE
	tac_reloads = FALSE
	fire_sound = 'sound/weapons/rifleshot.ogg'
	rack_sound = 'sound/weapons/chunkyrack.ogg'
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/l6_saw/unrestricted
	pin = /obj/item/firing_pin


/obj/item/gun/ballistic/automatic/l6_saw/examine(mob/user)
	. = ..()
	. += "<b>alt + click</b> to [cover_open ? "close" : "open"] the dust cover."
	if(cover_open && magazine)
		. += span_notice("It seems like you could use an <b>empty hand</b> to remove the magazine.")


/obj/item/gun/ballistic/automatic/l6_saw/AltClick(mob/user)
	if(!user.canUseTopic(src, BE_CLOSE))
		return
	cover_open = !cover_open
	to_chat(user, span_notice("You [cover_open ? "open" : "close"] [src]'s cover."))
	if(cover_open)
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	else
		playsound(user, 'sound/weapons/sawopen.ogg', 60, 1)
	update_appearance()

/obj/item/gun/ballistic/automatic/l6_saw/update_overlays()
	. = ..()
	. += "l6_door_[cover_open ? "open" : "closed"]"


/obj/item/gun/ballistic/automatic/l6_saw/afterattack(atom/target as mob|obj|turf, mob/living/user as mob|obj, flag, params)
	if(cover_open)
		to_chat(user, span_warning("[src]'s cover is open! Close it before firing!"))
		return
	else
		. = ..()
		update_icon()

//ATTACK HAND IGNORING PARENT RETURN VALUE
/obj/item/gun/ballistic/automatic/l6_saw/attack_hand(mob/user, list/modifiers)
	if (loc != user)
		..()
		return
	if (!cover_open && user.is_holding(src))
		to_chat(user, span_warning("[src]'s cover is closed! Open it before trying to remove the magazine!"))
		return
	..()

/obj/item/gun/ballistic/automatic/l6_saw/attackby(obj/item/A, mob/user, params)
	if(!cover_open && istype(A, mag_type))
		to_chat(user, span_warning("[src]'s dust cover prevents a magazine from being fit."))
		return
	..()


// Old Semi-Auto Rifle //

/obj/item/gun/ballistic/automatic/surplus
	name = "Surplus Rifle"
	desc = "One of countless obsolete ballistic rifles that still sees use as a cheap deterrent. Uses 10mm ammo and its bulky frame prevents one-hand firing."
	icon_state = "surplus"
	item_state = "moistnugget"
	worn_icon_state = null
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/m10mm/rifle
	can_unsuppress = TRUE
	can_suppress = TRUE
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE
	automatic = 0
	fire_rate = 1.5

// Improv Pipe Sub-Machinegun //

/obj/item/gun/ballistic/automatic/pipe_smg
	name = "pipe carbine"
	desc = "A much more sophisticated improvised firearm, loaded from a removable magazine and automatically cycling cartridges. It's a shame it only takes 9mm ammo."
	icon_state = "pipesmg"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/pipem9mm
	special_mags = TRUE
	caliber = "9mm"
	tac_reloads = FALSE
	bolt_type = BOLT_TYPE_OPEN
	no_pin_required = TRUE
	spawnwithmagazine = FALSE
	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BELT
	actions_types = null
	fire_rate = 2
	spread = 10

// Laser rifle (rechargeable magazine) //

/obj/item/gun/ballistic/automatic/laser
	name = "laser rifle"
	desc = "Though sometimes mocked for the relatively weak firepower of their energy weapons, the logistic miracle of rechargeable ammunition has given Nanotrasen a decisive edge over many a foe."
	icon_state = "oldrifle"
	item_state = "arg"
	mag_type = /obj/item/ammo_box/magazine/recharge
	can_suppress = FALSE
	actions_types = list()
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE
	fire_rate = 2

