/obj/item/gun/ballistic/rifle
	name = "Bolt Rifle"
	desc = "Some kind of bolt action rifle. You get the feeling you shouldn't have this."
	icon_state = "moistnugget"
	icon_state = "moistnugget"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	bolt_wording = "bolt"
	bolt_type = BOLT_TYPE_TWO_STEP
	semi_auto = FALSE
	internal_magazine = TRUE
	fire_sound = "sound/weapons/rifleshot.ogg"
	fire_sound_volume = 80
	rack_sound = "sound/weapons/mosinboltout.ogg"
	bolt_drop_sound = "sound/weapons/mosinboltin.ogg"
	tac_reloads = FALSE
	weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/rifle/update_icon()
	..()
	add_overlay("[icon_state]_bolt[bolt_locked ? "_locked" : ""]")

/*
/obj/item/gun/ballistic/rifle/rack(mob/user = null)
	if(bolt_locked == FALSE)
		to_chat(user, "<span class='notice'>You open the bolt of \the [src].</span>")
		playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
		process_chamber(FALSE, FALSE, FALSE)
		bolt_locked = TRUE
		update_icon()
		return
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/attackby(obj/item/A, mob/user, params)
	if (!bolt_locked)
		to_chat(user, "<span class='notice'>The bolt is closed!</span>")
		return
	return ..()

/obj/item/gun/ballistic/rifle/examine(mob/user)
	. = ..()
	. += "The bolt is [bolt_locked ? "open" : "closed"]."
*/

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. It feels slightly moist."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/rifle/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	var/guns_left = 30
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted

/obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage
	name = "arcane barrage"
	desc = "Pew Pew Pew."
	fire_sound = 'sound/weapons/emitter.ogg'
	pin = /obj/item/firing_pin/magic
	icon_state = "arcane_barrage"
	item_state = "arcane_barrage"
	slot_flags = null
	can_bayonet = FALSE
	item_flags = NEEDS_PERMIT | DROPDEL | ABSTRACT | NOBLUDGEON
	flags_1 = NONE
	trigger_guard = TRIGGER_GUARD_ALLOW_ALL

	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/enchanted/arcane_barrage

/obj/item/gun/ballistic/rifle/boltaction/enchanted/dropped()
	guns_left = 0
	..()

/obj/item/gun/ballistic/rifle/boltaction/enchanted/proc/discard_gun(mob/living/user)
	user.throw_item(pick(oview(7,get_turf(user))))

/obj/item/gun/ballistic/rifle/boltaction/enchanted/arcane_barrage/discard_gun(mob/living/user)
	qdel(src)

/obj/item/gun/ballistic/rifle/boltaction/enchanted/attack_self()
	return

/obj/item/gun/ballistic/rifle/boltaction/enchanted/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	. = ..()
	if(!.)
		return
	if(guns_left)
		var/obj/item/gun/ballistic/rifle/boltaction/enchanted/gun = new type
		gun.guns_left = guns_left - 1
		discard_gun(user)
		user.swap_hand()
		user.put_in_hands(gun)
	else
		user.dropItemToGround(src, TRUE)

///////////////////////
//   .41 CAL RIFLE   //
///////////////////////

/obj/item/gun/ballistic/rifle/leveraction
	name = "lever action rifle"
	desc = "Straight from the Wild West, this belongs in a museum but has found its way into your hands."
	icon_state = "leveraction"
	item_state = "moistnugget"
	slot_flags = ITEM_SLOT_BACK
	rack_sound = "sound/weapons/leveractionrack.ogg"
	fire_sound = "sound/weapons/leveractionshot.ogg"
	mag_type = /obj/item/ammo_box/magazine/internal/leveraction
	w_class = WEIGHT_CLASS_BULKY
	bolt_wording = "lever"
	cartridge_wording = "cartridge"
	recoil = 0.5
	bolt_type = BOLT_TYPE_PUMP
	fire_sound_volume = 80
	tac_reloads = FALSE

/obj/item/gun/ballistic/rifle/pipe
	name = "pipe rifle"
	desc = "It's amazing what you can do with some scrap wood and spare pipes."
	sawn_desc = "Just looking at this thing makes your wrists hurt."
	icon_state = "ishotgun"
	item_state = "moistnugget"
	bolt_wording = "breech"
	cartridge_wording = "cartridge"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/pipegun
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	recoil = 0.8
	var/slung = FALSE

/obj/item/gun/ballistic/rifle/pipe/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/melee/transforming/energy))
		var/obj/item/melee/transforming/energy/W = A
		if(W.active)
			sawoff(user)
	if(istype(A, /obj/item/circular_saw) || istype(A, /obj/item/gun/energy/plasmacutter))
		sawoff(user)

/*
/obj/item/gun/ballistic/rifle/pipe/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil))
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the rifle, making a sling.</span>")
			slung = TRUE
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")
*/
