/obj/item/gun/ballistic/rifle/rebarxbow
	name = "heated rebar crossbow"
	desc = "A handcrafted crossbow. \
		   Aside from conventional sharpened iron rods, it can also fire specialty ammo made from the atmos crystalizer - zaukerite, metallic hydrogen, and healium rods all work. \
		   Very slow to reload - you can craft the crossbow with a crowbar to loosen the crossbar, but risk a misfire, or worse..."
	icon_state = "rebarxbow"
	item_state = "rebarxbow"
	worn_icon_state = "rebarxbow"
	rack_sound = 'sound/weapons/sniper_rack.ogg'
	mag_display = FALSE
	empty_indicator = TRUE
	bolt_type = BOLT_TYPE_OPEN
	semi_auto = FALSE
	internal_magazine = TRUE
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_SUITSTORE
	bolt_wording = "bowstring"
	magazine_wording = "rod"
	cartridge_wording = "rod"
	weapon_weight = WEAPON_HEAVY
	caliber = "sharpened rod"
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/normal
	fire_sound = 'sound/weapons/xbow_lock.ogg'
	can_sawoff = FALSE
	tac_reloads = FALSE

	/// How long it takes to rack the bolt
	var/draw_time = 3 SECONDS

	SET_BASE_PIXEL(0, 0)

/obj/item/gun/ballistic/rifle/rebarxbow/rack(mob/user)
	if(bolt_locked)
		drop_bolt(user)
		return

	balloon_alert(user, "bowstring loosened")
	playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	//handle_chamber(empty_chamber =  FALSE, from_firing = FALSE, chamber_next_round = FALSE)
	bolt_locked = TRUE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/drop_bolt(mob/user)
	if(!do_after(user, draw_time, target = src))
		return
	playsound(src, bolt_drop_sound, bolt_drop_sound_volume, FALSE)
	balloon_alert(user, "bowstring drawn")
	chamber_round()
	bolt_locked = FALSE
	update_appearance()

/obj/item/gun/ballistic/rifle/rebarxbow/after_live_shot_fired(mob/living/user, pointblank = 0, atom/pbtarget, message = TRUE)
	. = ..()
	rack()

/obj/item/gun/ballistic/rifle/rebarxbow/can_shoot()
	if (bolt_locked)
		return FALSE
	return ..()

/obj/item/gun/ballistic/rifle/rebarxbow/shoot_with_empty_chamber(mob/living/user)
	if(chambered || !magazine || !length(magazine.contents))
		return ..()
	drop_bolt(user)

/obj/item/gun/ballistic/rifle/rebarxbow/examine(mob/user)
	. = ..()
	. += "The crossbow is [bolt_locked ? "not ready" : "ready"] to fire."

/obj/item/gun/ballistic/rifle/rebarxbow/update_overlays()
	. = ..()
	if(!magazine)
		. += "[initial(icon_state)]_empty"
	if(!bolt_locked)
		. += "[initial(icon_state)]_bolt_locked"

/obj/item/gun/ballistic/rifle/rebarxbow/forced
	name = "stressed rebar crossbow"
	desc = "Some idiot decided that they would risk shooting themselves in the face if it meant they could have a draw this crossbow a bit faster. Hopefully, it was worth it."
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/force
	draw_time = 1.5
	misfire_probability = 25

/obj/item/gun/ballistic/rifle/rebarxbow/syndie
	name = "syndicate rebar crossbow"
	desc = "The syndicate liked the bootleg rebar crossbow NT engineers made, so they showed what it could be if properly developed. \
			Holds three shots without a chance of exploding, and features a built in scope. Compatible with all known crossbow ammunition."
	icon_state = "rebarxbowsyndie"
	item_state = "rebarxbowsyndie"
	worn_icon_state = "rebarxbowsyndie"
	w_class = WEIGHT_CLASS_NORMAL
	draw_time = 1
	mag_type = /obj/item/ammo_box/magazine/internal/boltaction/rebarxbow/syndie
	zoomable = TRUE
	zoom_amt = 2
