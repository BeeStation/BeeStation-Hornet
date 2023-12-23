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
	equip_time = 1 SECONDS

/obj/item/gun/ballistic/automatic/pistol/no_mag
	spawnwithmagazine = FALSE

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
	spread_unwielded = 30 //Manually set unwielded spread to 30; Equivelant weight to 0.5 (Stechkin has weight 1)
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
	mag_type = /obj/item/ammo_box/magazine/m45
	can_suppress = FALSE

/obj/item/gun/ballistic/automatic/pistol/m1911/no_mag
	spawnwithmagazine = FALSE

/obj/item/gun/ballistic/automatic/pistol/deagle
	name = "\improper Desert Eagle"
	desc = "A robust .50 AE handgun."
	icon_state = "deagle"
	force = 14
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
	mag_type = /obj/item/ammo_box/magazine/pistolm9mm
	can_suppress = FALSE
	burst_size = 3
	fire_delay = 2
	actions_types = list(/datum/action/item_action/toggle_firemode)

//Pepperball Pistol, the ballistic green-shift sec alternative to the disabler; slighly higher damage, less ammo, EMP-proof, and able to be reloaded on the go.
/obj/item/gun/ballistic/automatic/pistol/pepperball
	name = "pepperball pistol"
	desc = "An older gas-operated non-lethal sidearm. Its use on NanoTrasen stations has declined with the introduction of energy-based weaponary."
	icon_state = "pepperpistol"
	w_class = WEIGHT_CLASS_SMALL
	can_suppress = FALSE
	tac_reloads = FALSE
	flight_x_offset = 13
	flight_y_offset = 12
	mag_type = /obj/item/ammo_box/magazine/pepperball
	var/obj/item/tank/internals/emergency_oxygen/air_tank
	var/air_usage = 0.025
	fire_sound = 'sound/items/syringeproj.ogg'
	fire_sound_volume = 60
	equip_time = 2 SECONDS

/obj/item/gun/ballistic/automatic/pistol/pepperball/Initialize(mapload)
	install_tank(new /obj/item/tank/internals/emergency_oxygen/cold_air(src))
	return ..()

/obj/item/gun/ballistic/automatic/pistol/pepperball/update_icon()
	..()

	if (air_tank)
		add_overlay("[icon_state]_[air_tank.icon_state]")

/obj/item/gun/ballistic/automatic/pistol/pepperball/examine(mob/user)
	. = ..()
	if (air_tank)
		var/D = "It has \a [air_tank] installed."
		if(in_range(src, user) || isobserver(user))
			D += " Its gauge reports \"[round(air_tank.air_contents.total_moles(), 0.01)] mol at [round(air_tank.air_contents.return_pressure(),0.01)] kPa.\""
		. += D
	else
		. += "It requires an air tank to fire."

/obj/item/gun/ballistic/automatic/pistol/pepperball/proc/install_tank(obj/item/tank/internals/emergency_oxygen/T) //Similar to installing a suppressor.
	air_tank = T
	weight_class_up()
	update_icon()

/obj/item/gun/ballistic/automatic/pistol/pepperball/attackby(obj/item/A, mob/user, params)
	if (istype(A, /obj/item/tank/internals/emergency_oxygen))
		if (!user.is_holding(src))
			to_chat(user, "<span class='notice'>You need be holding \the [src] to fit \the [A] to it!</span>")
			return
		if (air_tank)
			to_chat(user, "<span class='warning'>[src] already has an air tank installed!</span>")
			return
		if (user.transferItemToLoc(A, src))
			to_chat(user, "<span class='notice'>You attach \the [A] onto \the [src].</span>")
			playsound(src, 'sound/items/screwdriver.ogg', 25)
			install_tank(A)
			return
	..()


/obj/item/gun/ballistic/automatic/pistol/pepperball/AltClick(mob/user)
	if (!air_tank)
		to_chat(user, "<span class='warning'>There is no air tank installed on \the [src]!</span>")
		return
	if(!user.is_holding(src))
		to_chat(user, "<span class='notice'>You need be holding \the [src] to remove \the [air_tank]!</span>")
		return
	to_chat(user, "<span class='notice'>You detach \the [air_tank] from \the [src].</span>")
	playsound(src, 'sound/items/screwdriver.ogg', 25)
	user.put_in_hands(air_tank)
	weight_class_down()
	air_tank = null
	update_icon()

/obj/item/gun/ballistic/automatic/pistol/pepperball/can_shoot()
	if (!air_tank)
		return FALSE
	else
		return chambered

/obj/item/gun/ballistic/automatic/pistol/pepperball/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if (air_tank)
		if (!air_tank.air_contents.total_moles()) //If the tank's completetly empty, can't fire it.
			playsound(src, 'sound/items/cig_snuff.ogg', 25, 1)
			to_chat(user, "<span class='warning'>\The [src] lets out a weak hiss as it fails to fire!</span>")
			return
		air_tank.air_contents.remove(air_usage)
	. = ..()

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

