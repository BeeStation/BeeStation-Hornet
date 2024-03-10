/obj/item/gun/ballistic/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	damage_multiplier = 1.5
	mag_type = /obj/item/ammo_box/magazine/m9mm
	can_suppress = TRUE
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	laser_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	fire_rate = 3
	automatic = 0
	weapon_weight = WEAPON_LIGHT
	equip_time = 1 SECONDS

/obj/item/gun/ballistic/automatic/pistol/fire_sounds()
	. = ..()
	if(istype(chambered, /obj/item/ammo_casing/c9mm/laser)) // This needs to exist to ensure that the laser sound plays with the normal shot sound
		playsound(src, laser_fire_sound, laser_sound_volume, vary_fire_sound)
	if(istype(chambered, /obj/item/ammo_casing/c9mm/disabler))
		playsound(src, disabler_fire_sound, laser_sound_volume, vary_fire_sound)

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE
	caliber = "10mm"

/obj/item/gun/ballistic/automatic/pistol/locker
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors. This one is rusted from being inside of a locker for so long."

/obj/item/gun/ballistic/automatic/pistol/suppressed/Initialize(mapload)
	. = ..()
	var/obj/item/suppressor/S = new(src)
	install_suppressor(S)

/obj/item/gun/ballistic/automatic/pistol/der38
	name = "palm pistol"
	desc = "An 'Infiltrator' double-barreled derringer, chambered in .38-special. Not the best for head-on engagements."
	icon_state = "derringer"
	w_class = WEIGHT_CLASS_SMALL
	item_state = null //Too small to show in hand, unless examined
	throwforce = 0 //Derringers are light and tiny, no hurtie
	damage_multiplier = 1
	mag_type = /obj/item/ammo_box/magazine/internal/der38
	load_sound = 'sound/weapons/revolverload.ogg'
	eject_sound = 'sound/weapons/revolverempty.ogg'
	can_suppress = FALSE
	casing_ejector = FALSE
	internal_magazine = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT //Functionally a double-barrel shotgun
	tac_reloads = FALSE
	fire_sound_volume = 60
	spread = 18 //Innate spread of 18 degrees, unwielded spread of 48; Stechkin is unwielded 40
	weapon_weight = WEAPON_LIGHT * 0.5 //Equivelant weight to 0.5 (Stechkin has weight 1)
	wild_spread = TRUE
	wild_factor = 0.70 //Minimum spread is 70% of spread value
	equip_time = 0

/obj/item/gun/ballistic/automatic/pistol/der38/twelveshooter //For debugging only, or meme shit
	name = "palm pistol devastator"
	desc = "By the locker of Davy Jones, it be a fuhckin' twelve barreled derringer!"
	mag_type = /obj/item/ammo_box/magazine/internal/der38/twelveshooter

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
	damage_multiplier = 1
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE
	caliber = ".45"

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
	damage_multiplier = 1
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	equip_time = 2 SECONDS

/obj/item/gun/ballistic/automatic/pistol/deagle/gold
	desc = "A gold plated Desert Eagle folded over a million times by superior martian gunsmiths. Uses .50 AE ammo."
	icon_state = "deagleg"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/deagle/camo
	desc = "A Deagle brand Deagle for operators operating operationally. Uses .50 AE ammo."
	icon_state = "deaglecamo"
	item_state = "deagleg"

/obj/item/gun/ballistic/automatic/pistol/APS
	name = "stechkin APS pistol"
	desc = "The original Russian version of a widely used Syndicate sidearm. Uses 9mm ammo."
	icon_state = "aps"
	w_class = WEIGHT_CLASS_SMALL
	damage_multiplier = 1
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

/obj/item/gun/ballistic/automatic/pistol/pipe
	name = "pipe pistol"
	desc = "A lousy mechanism held together by hopes, dreams and wrapping paper. Chambered for 9mm ammunition."
	icon_state = "pipepistol"
	item_state = "arg"
	damage_multiplier = 1
	mag_type = /obj/item/ammo_box/magazine/pipem9mm
	special_mags = TRUE
	caliber = "9mm"
	no_pin_required = TRUE
	spawnwithmagazine = TRUE
	slot_flags = ITEM_SLOT_BELT
	fire_rate = 2
	spread = 5

/obj/item/gun/ballistic/automatic/pistol/pipe/update_icon()
	..()
	add_overlay("[icon_state]_bolt[bolt_locked ? "_locked" : ""]") //This is here to ensure that the bolt overlay appears over the mag

/obj/item/gun/ballistic/automatic/pistol/stickman
	name = "flat gun"
	desc = "A 2 dimensional gun.. what?"
	icon_state = "flatgun"

/obj/item/gun/ballistic/automatic/pistol/stickman/equipped(mob/user, slot)
	..()
	to_chat(user, "<span class='notice'>As you try to manipulate [src], it slips out of your possession..</span>")
	if(prob(50))
		to_chat(user, "<span class='notice'>..and vanishes from your vision! Where the hell did it go?</span>")
		qdel(src)
		user.update_icons()
	else
		to_chat(user, "<span class='notice'>..and falls into view. Whew, that was a close one.</span>")
		user.dropItemToGround(src)

