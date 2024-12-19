/obj/item/gun/ballistic/automatic/pistol
	name = "stechkin pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	icon_state = "pistol"
	w_class = WEIGHT_CLASS_SMALL
	mag_type = /obj/item/ammo_box/magazine/m10mm
	can_suppress = TRUE
	actions_types = list()
	bolt_type = BOLT_TYPE_LOCKING
	fire_sound = "sound/weapons/gunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 80
	rack_sound = "sound/weapons/pistolrack.ogg"
	bolt_drop_sound = "sound/weapons/pistolslidedrop.ogg"
	bolt_wording = "slide"
	fire_rate = 3
	automatic = 0
	weapon_weight = WEAPON_LIGHT

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
	desc = "An 'Infiltrator' double-barreled derringer, chambered in the powerful .357. Useful in a pinch but inadequate for longer engagements."
	icon_state = "derringer"
	w_class = WEIGHT_CLASS_SMALL
	item_state = null //Too small to show in hand, unless examined
	throwforce = 0 //Derringers are light and tiny, no hurtie
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
	equip_time = 0
	has_weapon_slowdown = FALSE

/obj/item/gun/ballistic/automatic/pistol/der38/twelveshooter //For debugging only, or meme shit
	name = "palm pistol devastator"
	desc = "By the locker of Davy Jones, it be a fuhckin' twelve barreled derringer!"
	mag_type = /obj/item/ammo_box/magazine/internal/der38/twelveshooter

/obj/item/gun/ballistic/automatic/pistol/m1911
	name = "\improper M1911"
	desc = "A classic .45 handgun with a small magazine capacity."
	icon_state = "m1911"
	w_class = WEIGHT_CLASS_NORMAL
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
	mag_type = /obj/item/ammo_box/magazine/m50
	can_suppress = FALSE
	mag_display = TRUE
	rack_sound = "sound/weapons/deaglerack.ogg"
	bolt_drop_sound = "sound/weapons/deagleslidedrop.ogg"
	lock_back_sound = "sound/weapons/deaglelock.ogg"
	fire_sound = "sound/weapons/deagleshot.ogg"

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
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

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


// ==================================
// Officer's Pistol
// ==================================

/obj/item/gun/ballistic/automatic/pistol/service
	name = "service pistol"
	desc = "A commemorative pistol given to Nanotrasen officers designed to use higher densities of energy to emulate the ballistic service pistols that they replaced. \
	It primarilly serves as a symbol of power, but has proven to be an effective tool at enforcing the power that is portrays. \
	It fires less-lethal rounds which stun the area of the body that they burn."
	icon_state = "officer"
	w_class = WEIGHT_CLASS_NORMAL
	mag_type = /obj/item/ammo_box/magazine/recharge/service
	can_suppress = FALSE
	fire_sound = 'sound/weapons/laser.ogg'
	casing_ejector = FALSE
	fire_rate = 4
	can_suppress = FALSE
	worn_icon_state = "officer_pistol"
	var/stripe_state = "officer_com"

/obj/item/gun/ballistic/automatic/pistol/service/update_icon()
	. = ..()
	var/mutable_appearance/stripe = mutable_appearance(icon, stripe_state)
	if (bolt_locked)
		stripe.pixel_x = -5
	add_overlay(stripe)

/obj/item/gun/ballistic/automatic/pistol/service/captain
	stripe_state = "officer_com"

/obj/item/gun/ballistic/automatic/pistol/service/hop
	stripe_state = "officer_srv"

/obj/item/gun/ballistic/automatic/pistol/service/hos
	stripe_state = "officer_sec"

/obj/item/gun/ballistic/automatic/pistol/service/ce
	stripe_state = "officer_eng"

/obj/item/gun/ballistic/automatic/pistol/service/rd
	stripe_state = "officer_sci"

/obj/item/gun/ballistic/automatic/pistol/service/cmo
	stripe_state = "officer_med"
