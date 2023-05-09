// SNIPER //

/obj/item/gun/ballistic/sniper_rifle
	name = "sniper rifle"
	desc = "A long ranged weapon that does significant damage. No, you can't quickscope."
	icon_state = "sniper"
	item_state = "sniper"
	fire_sound = "sound/weapons/sniper_shot.ogg"
	fire_sound_volume = 90
	load_sound = "sound/weapons/sniper_mag_insert.ogg"
	rack_sound = "sound/weapons/sniper_rack.ogg"
	recoil = 2
	weapon_weight = WEAPON_HEAVY
	mag_type = /obj/item/ammo_box/magazine/sniper_rounds
	automatic = 0
	semi_auto = FALSE
	fire_rate = 1.5
	burst_size = 1
	w_class = WEIGHT_CLASS_NORMAL
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
