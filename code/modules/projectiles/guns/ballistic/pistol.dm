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
	caliber = list("10mm")

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
	caliber = list(".45")

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
	to_chat(user, span_notice("As you try to manipulate [src], it slips out of your possession.."))
	if(prob(50))
		to_chat(user, span_notice("..and vanishes from your vision! Where the hell did it go?"))
		qdel(src)
		user.update_icons()
	else
		to_chat(user, span_notice("..and falls into view. Whew, that was a close one."))
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

// Security
/obj/item/gun/ballistic/automatic/pistol/security
	name = "NPS-10"
	desc = "Standard APS smart-firearm for on-station law enforcement. Low-velocity and unlikely to breach the hull. Uses x200 LAW ammo cartridges."
	icon_state = "sec"
	w_class = WEIGHT_CLASS_LARGE
	mag_type = /obj/item/ammo_box/magazine/x200law
	can_suppress = FALSE
	worn_icon_state = "officer_pistol"
	empty_alarm = TRUE
	rack_sound = 'sound/weapons/nps10/NPS-rack.ogg'
	load_empty_sound = 'sound/weapons/nps10/NPS-load.ogg'
	bolt_drop_sound = 'sound/weapons/nps10/NPS-boltdrop.ogg'
	lock_back_sound = 'sound/weapons/nps10/NPS-lockback.ogg'
	fire_sound = 'sound/weapons/nps10/NPS-fire.ogg'
	recoil = 0.1

	pin = /obj/item/firing_pin/dna
	var/special_ammo_mag_max = 4 // Max amount we can carry
	var/special_ammo_reserve = 4 // How many special shots we have left
	var/special_authorized = FALSE

/obj/item/gun/ballistic/automatic/pistol/security/Initialize()
	. = ..()
	RegisterSignal(SSdcs, COMSIG_SECURITY_LEVEL_CHANGED, .proc/security_level)

/obj/item/gun/ballistic/automatic/pistol/security/proc/security_level()
	SIGNAL_HANDLER
	if(SSsecurity_level.get_current_level_as_number() >= SEC_LEVEL_RED && !special_authorized)
		audible_message("<span class='italics'>You hear a beep from \the [name].</span>", null,  1)
		special_authorized = TRUE
		// TODO, PUT THE ACTION ENABLEMENT STUFF HERE
	else if(SSsecurity_level.get_current_level_as_number() < SEC_LEVEL_RED && special_authorized)
		audible_message("<span class='italics'>You hear a beep from \the [name].</span>", null,  1)
		special_authorized = FALSE
		// TODO, PUT THE ACTION DISABLEMENT STUFF HERE

/obj/item/gun/ballistic/automatic/pistol/security/proc/get_dna()
	var/obj/item/firing_pin/dna/D = pin
	return D.unique_enzymes ? D.unique_enzymes : null

/obj/item/gun/ballistic/automatic/pistol/security/attackby(obj/item/O, mob/user, params)
	if(get_dna() && (ACCESS_ARMORY in O.GetAccess()))
		to_chat(user, "<span class='notice'>You reset the DNA lock.</span>")
		var/obj/item/firing_pin/dna/D = pin
		D.unique_enzymes = null
		if(D.obj_flags & EMAGGED)
			D.obj_flags &= ~EMAGGED
		investigate_log("dna lock reset by [key_name(user)]", INVESTIGATE_RECORDS)
	..()

/obj/item/gun/ballistic/automatic/pistol/security/emp_act(severity)
	audible_message("<span class='italics'>You hear erratic beeping from \the [name].</span>", null,  1)
	var/obj/item/firing_pin/dna/D = pin
	D.unique_enzymes = null
	investigate_log("dna lock reset by EMP", INVESTIGATE_RECORDS)
	..()

/obj/item/gun/ballistic/automatic/pistol/security/add_seclight_point()
	AddComponent(/datum/component/seclite_attachable, \
		light_overlay_icon = 'icons/obj/guns/flashlights.dmi', \
		light_overlay = "flight", \
		overlay_x = 16, \
		overlay_y = 12)

/obj/item/gun/ballistic/automatic/pistol/security/examine(mob/user)
	. = ..()

	. += span_notice("<i>Features a Warden-resettable DNA lock, as well as a Red-Alert locked smart ammunition mode.</i>")
	. += span_notice("<b>There are [special_ammo_reserve] special rounds left!</b>")

	var/dna = get_dna()
	if(pin.obj_flags & EMAGGED)
		. += "<span class='warning'>The DNA lock flashes erratically! Use an ID with armory access to reset.</span>"
	else if(dna)
		. += "<span class='notice'>It is currently registered to: [dna]. Use an ID with armory access to reset.</span>"
	else
		. += "<span class='notice'>It is unregistered.</span>"

	. += span_warning("Smart-Ammo is <b>[special_authorized ? "authorized" : "disabled"]</b>.")
	. += span_notice("<i>You could examine it more thoroughly...</i>")

/obj/item/gun/ballistic/automatic/pistol/security/examine_more(mob/user)
	. = ..()
	. += "<i>The corporate-issue NPS-10 is a slim, nondescript sidearm built for reliability on a budget. \
			Its brushed-gray slide and ergonomic polymer grip keep it unflashy, while the semi-auto action with \
			optional two-round burst and 12-round magazine ensure effective self defense when called upon. \
			Designed to blend into any uniform yet hold its own in close quarters, it’s the pragmatic choice for \
			private security operators.</i>"
