/obj/item/gun/ballistic/rifle
	name = "Bolt Rifle"
	desc = "Some kind of bolt action rifle. You get the feeling you shouldn't have this."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	worn_icon_state = "moistnugget"
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

/obj/item/gun/ballistic/rifle/after_live_shot_fired(mob/living/user, pointblank, atom/pbtarget, message)
	if(sawn_off == TRUE)
		if(!is_wielded)
			recoil = 5
		else
			recoil = initial(recoil) + SAWN_OFF_RECOIL
	. = ..()

///////////////////////
// BOLT ACTION RIFLE //
///////////////////////

/obj/item/gun/ballistic/rifle/boltaction
	name = "\improper Mosin Nagant"
	desc = "This piece of junk looks like something that could have been used 700 years ago. It feels slightly moist."
	icon_state = "moistnugget"
	item_state = "moistnugget"
	can_sawoff = TRUE
	sawn_name = "\improper Mosin Obrez"
	sawn_desc = "A hand cannon of a rifle, try not to break your wrists."
	sawn_item_state = "halfnugget"
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction
	can_bayonet = TRUE
	knife_x_offset = 27
	knife_y_offset = 13
	recoil = 0.5
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_HEAVY

/obj/item/gun/ballistic/rifle/boltaction/sawoff(mob/user)
	. = ..()
	//Has 25 bonus spread due to sawn-off accuracy penalties
	if (.)
		//Wild spread only applies to innate and unwielded spread
		spread = 10
		wild_spread = TRUE
		wild_factor = 0.5
		weapon_weight = WEAPON_MEDIUM

/obj/item/gun/ballistic/rifle/boltaction/enchanted
	name = "enchanted bolt action rifle"
	desc = "Careful not to lose your head."
	can_sawoff = FALSE
	equip_time = 0 SECONDS
	has_weapon_slowdown = FALSE
	recoil = 0
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

/obj/item/gun/ballistic/rifle/boltaction/enchanted/fire_shot_at(mob/living/user, atom/target, message, params, zone_override, aimed)
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
//   .38 CAL RIFLE   //
///////////////////////

/obj/item/gun/ballistic/rifle/leveraction
	name = "lever action rifle"
	desc = "Straight from the Wild West, this belongs in a museum but has found its way into your hands."
	icon_state = "leverrifle"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	item_state = "leveraction"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	rack_sound = "sound/weapons/leveractionrack.ogg"
	half_rack_sound = "sound/weapons/leveractionrack_open.ogg"
	bolt_drop_sound = "sound/weapons/leveractionrack_close.ogg"
	fire_sound = "sound/weapons/leveractionshot.ogg"
	mag_type = /obj/item/ammo_box/magazine/internal/leveraction
	w_class = WEIGHT_CLASS_BULKY
	no_pin_required = TRUE //Nothing stops frontier justice
	bolt_wording = "lever"
	cartridge_wording = "cartridge"
	recoil = 0.5
	bolt_type = BOLT_TYPE_PUMP
	fire_sound_volume = 70

///////////////////////
//  7.62 PIPE RIFLE  //
///////////////////////

/obj/item/gun/ballistic/rifle/pipe
	name = "pipe rifle"
	desc = "It's amazing what you can do with some scrap wood and spare pipes."
	can_sawoff = TRUE
	sawn_name = "pipe pistol"
	sawn_desc = "Why have more gun, when less gun can do!"
	icon_state = "piperifle"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	item_state = "shotgun_improv"
	sawn_item_state = "shotgun_improv_shorty"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	bolt_type = BOLT_TYPE_NO_BOLT
	cartridge_wording = "cartridge"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/piperifle
	no_pin_required = TRUE
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	recoil = 0.8
	var/slung = FALSE

/obj/item/gun/ballistic/rifle/pipe/examine(mob/user)
	. = ..()
	if (slung)
		. += "It has a shoulder sling fashioned from spare cable attached."
	else
		. += "You could improvise a shoulder sling from some cabling..."

/obj/item/gun/ballistic/rifle/pipe/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		if(slung)
			to_chat(user, span_warning("There is already a sling on [src]!"))
			return
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, span_notice("You tie the lengths of cable to the [src], making a sling."))
			slung = TRUE
			update_icon()
		else
			to_chat(user, span_warning("You need at least ten lengths of cable if you want to make a sling!"))

/obj/item/gun/ballistic/rifle/pipe/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = FALSE
		update_icon()
