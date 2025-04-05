// SNIPER //

/obj/item/gun/ballistic/sniper_rifle
	name = "sniper rifle"
	desc = "A long ranged weapon that does significant damage. No, you can't quickscope."
	icon_state = "sniper"
	inhand_icon_state = "sniper"
	worn_icon_state = "sniper"
	fire_sound = "sound/weapons/sniper_shot.ogg"
	fire_sound_volume = 90
	load_sound = "sound/weapons/sniper_mag_insert.ogg"
	rack_sound = "sound/weapons/sniper_rack_open.ogg"
	bolt_drop_sound = 'sound/weapons/sniper_rack_close.ogg'
	recoil = 1.5
	weapon_weight = WEAPON_HEAVY
	bolt_type = BOLT_TYPE_TWO_STEP
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	direct_loading = TRUE
	semi_auto = FALSE
	rack_delay = 4
	w_class = WEIGHT_CLASS_LARGE
	zoomable = TRUE
	zoom_amt = 10 //Long range, enough to see in front of you, but no tiles behind you.
	zoom_out_amt = 5
	slot_flags = ITEM_SLOT_BACK
	actions_types = list()
	mag_display = TRUE

/obj/item/gun/ballistic/sniper_rifle/syndicate
	name = "syndicate sniper rifle"
	desc = "An illegally modified .50 cal sniper rifle with suppression compatibility. Quickscoping still doesn't work."
	can_suppress = TRUE
	can_unsuppress = TRUE
	pin = /obj/item/firing_pin/implant/pindicate
