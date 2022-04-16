/obj/item/gun/ballistic/SRN_rocketlauncher
	desc = "A rocket designed with the power of bluespace to send a singularity or tesla back to the shadow realm"
	name = "Spatial Rift Nullifier"
	icon = 'monkestation/icons/obj/guns/guns.dmi'
	icon_state = "srnlauncher"
	lefthand_file = 'monkestation/icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'monkestation/icons/mob/inhands/weapons/guns_righthand.dmi'
	item_state = "srnlauncher"
	mag_type = /obj/item/ammo_box/magazine/internal/SRN_rocket
	fire_sound = 'sound/weapons/rocketlaunch.ogg'
	fire_sound_volume = 80
	w_class = WEIGHT_CLASS_BULKY
	can_suppress = FALSE
	pin = /obj/item/firing_pin
	flags_1 = TESLA_IGNORE_1
	fire_delay = 0
	fire_rate = 1.5
	recoil = 1
	casing_ejector = FALSE
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_NO_BOLT
	internal_magazine = TRUE
	cartridge_wording = "rocket"
	empty_indicator = TRUE
	empty_alarm = TRUE
	tac_reloads = FALSE

/obj/item/gun/ballistic/SRN_rocketlauncher/afterattack()
	. = ..()
	magazine.get_round(FALSE) //Hack to clear the mag after it's fired //This does not like more than one shot in the internal mag

/obj/item/gun/ballistic/SRN_rocketlauncher/attack_self(mob/user)
	return //too difficult to remove the rocket with TK
