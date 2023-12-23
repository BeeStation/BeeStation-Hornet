/obj/item/gun/ballistic/shotgun
	name = "shotgun"
	desc = "A traditional shotgun with wood furniture and a four-shell capacity underneath."
	icon_state = "shotgun"
	lefthand_file = 'icons/mob/inhands/weapons/64x_guns_left.dmi'
	righthand_file = 'icons/mob/inhands/weapons/64x_guns_right.dmi'
	item_state = "shotgun"
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	fire_sound = "sound/weapons/shotgunshot.ogg"
	vary_fire_sound = FALSE
	fire_sound_volume = 90
	rack_sound = "sound/weapons/shotgunpump.ogg"
	half_rack_sound = "sound/weapons/shotgunpump_open.ogg"
	bolt_drop_sound = "sound/weapons/shotgunpump_close.ogg"
	load_sound = "sound/weapons/shotguninsert.ogg"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot
	weapon_weight = WEAPON_MEDIUM
	semi_auto = FALSE
	internal_magazine = TRUE
	casing_ejector = FALSE
	bolt_wording = "pump"
	bolt_type = BOLT_TYPE_PUMP
	cartridge_wording = "shell"
	tac_reloads = FALSE
	fire_rate = 1 //reee
	recoil = 1
	pb_knockback = 2

/obj/item/gun/ballistic/shotgun/lethal
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lethal

// RIOT SHOTGUN //

/obj/item/gun/ballistic/shotgun/riot //for spawn in the armory
	name = "riot shotgun"
	desc = "A sturdy shotgun with a longer magazine and a fixed tactical stock designed for non-lethal riot control."
	icon_state = "riotshotgun"
	item_state = "shotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/riot
	can_sawoff = TRUE
	sawn_desc = "Come with me if you want to live."

// Automatic Shotguns//

/obj/item/gun/ballistic/shotgun/automatic
	weapon_weight = WEAPON_HEAVY
	semi_auto = TRUE
	casing_ejector = TRUE

/obj/item/gun/ballistic/shotgun/automatic/combat
	name = "combat shotgun"
	desc = "A semi automatic shotgun with tactical furniture and a six-shell capacity underneath."
	icon_state = "cshotgun"
	item_state = "shotgun_combat"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com
	w_class = WEIGHT_CLASS_HUGE

/obj/item/gun/ballistic/shotgun/automatic/combat/AltClick(mob/user)
	if(loc == user)
		if(!user.is_holding(src))
			return
		semi_auto = !semi_auto
		playsound(src, 'sound/weapons/effects/ballistic_click.ogg', 20, FALSE)
		to_chat(user, "<span class='notice'>You toggle \the [src] to [semi_auto ? "automatic" : "manual"] operation.</span>")

/obj/item/gun/ballistic/shotgun/automatic/combat/examine(mob/user)
	. = ..()
	. += "You can select the firing mode with <b>alt+click</b>"
	. += "It is operating in [semi_auto ? "automatic" : "manual"] mode."

/obj/item/gun/ballistic/shotgun/automatic/combat/compact
	name = "compact combat shotgun"
	desc = "A compact version of the semi automatic combat shotgun. For close encounters."
	icon_state = "cshotgunc"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/com/compact
	weapon_weight = WEAPON_MEDIUM
	w_class = WEIGHT_CLASS_BULKY

/obj/item/gun/ballistic/shotgun/automatic/combat/compact/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
	if(!is_wielded)
		recoil = 6
	else
		recoil = initial(recoil)
	. = ..()

// Breaching Shotgun //

/obj/item/gun/ballistic/shotgun/automatic/breaching
	name = "tactical breaching shotgun"
	desc = "A compact semi-auto shotgun designed to fire breaching slugs and create rapid entry points."
	icon_state = "breachingshotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/breaching
	w_class = WEIGHT_CLASS_LARGE

//Dual Feed Shotgun

/obj/item/gun/ballistic/shotgun/automatic/dual_tube
	name = "cycler shotgun"
	desc = "An advanced shotgun with two separate magazine tubes, allowing you to quickly toggle between ammo types."
	icon_state = "cycler"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/tube
	w_class = WEIGHT_CLASS_HUGE
	var/toggled = FALSE
	var/obj/item/ammo_box/magazine/internal/shot/alternate_magazine
	//semi_auto = TRUE

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to pump it.</span>"

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/Initialize(mapload)
	. = ..()
	if (!alternate_magazine)
		alternate_magazine = new mag_type(src)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/attack_self(mob/living/user)
	if(!chambered && magazine.contents.len)
		rack()
	else
		toggle_tube(user)

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/proc/toggle_tube(mob/living/user)
	var/current_mag = magazine
	var/alt_mag = alternate_magazine
	magazine = alt_mag
	alternate_magazine = current_mag
	toggled = !toggled
	if(toggled)
		to_chat(user, "You switch to tube B.")
	else
		to_chat(user, "You switch to tube A.")

/obj/item/gun/ballistic/shotgun/automatic/dual_tube/AltClick(mob/living/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	rack()

// Bulldog shotgun //

/obj/item/gun/ballistic/shotgun/automatic/bulldog
	name = "\improper Bulldog Shotgun"
	desc = "A semi-auto, mag-fed shotgun for combat in narrow corridors with a built in recoil dampening system, nicknamed 'Bulldog' by boarding parties. Compatible only with specialized 8-round drum magazines."
	icon_state = "bulldog"
	item_state = "bulldog"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	inhand_x_dimension = 32
	inhand_y_dimension = 32
	w_class = WEIGHT_CLASS_LARGE
	weapon_weight = WEAPON_MEDIUM
	mag_type = /obj/item/ammo_box/magazine/m12g
	fire_delay = 0
	pin = /obj/item/firing_pin/implant/pindicate
	spread_unwielded = 8
	actions_types = list()
	mag_display = TRUE
	empty_indicator = TRUE
	empty_alarm = TRUE
	special_mags = TRUE
	internal_magazine = FALSE
	tac_reloads = TRUE
	fire_rate = 2
	automatic = 1
	recoil = 0
	bolt_type = BOLT_TYPE_STANDARD	//Not using a pump
	full_auto = TRUE

/obj/item/gun/ballistic/shotgun/automatic/bulldog/unrestricted
	pin = /obj/item/firing_pin
/////////////////////////////
// DOUBLE BARRELED SHOTGUN //
/////////////////////////////

/obj/item/gun/ballistic/shotgun/doublebarrel
	name = "double-barreled shotgun"
	desc = "A true classic."
	icon_state = "dshotgun"
	item_state = "shotgun_db"
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	force = 10
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BACK
	mag_type = /obj/item/ammo_box/magazine/internal/shot/dual
	can_sawoff = TRUE
	sawn_desc = "Omar's coming!"
	obj_flags = UNIQUE_RENAME
	rack_sound_volume = 0
	unique_reskin_icon = list("Default" = "dshotgun",
						"Dark Red Finish" = "dshotgun_d",
						"Ash" = "dshotgun_f",
						"Faded Grey" = "dshotgun_g",
						"Maple" = "dshotgun_l",
						"Rosewood" = "dshotgun_p"
						)
	semi_auto = TRUE
	bolt_type = BOLT_TYPE_NO_BOLT
	fire_rate = 2 //being double barrelled, you don't rely on internal mechanisms.
	pb_knockback = 3

/obj/item/gun/ballistic/shotgun/doublebarrel/reskin_obj(mob/M)
	if(sawn_off == FALSE)
		unique_reskin = list(
			"Default" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun"),
			"Dark Red Finish" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_d"),
			"Ash" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_f"),
			"Faded Grey" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_g"),
			"Maple" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_l"),
			"Rosewood" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_p")
		)
	else
		unique_reskin = list(
			"Default" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_sawn"),
			"Dark Red Finish" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_d_sawn"),
			"Ash" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_f_sawn"),
			"Faded Grey" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_g_sawn"),
			"Maple" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_l_sawn"),
			"Rosewood" = image(icon = 'icons/obj/guns/projectile.dmi', icon_state = "dshotgun_p_sawn")
		)
	. = ..()

// IMPROVISED SHOTGUN //

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised
	name = "improvised shotgun"
	desc = "Essentially a tube that aims shotgun shells."
	icon_state = "ishotgun"
	item_state = "shotgun_improv"
	sawn_item_state = "shotgun_improv_shorty"
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/shot/improvised
	sawn_desc = "I'm just here for the gasoline."
	no_pin_required = TRUE
	unique_reskin_icon = null
	recoil = 1.5
	var/slung = FALSE
	var/reinforced = FALSE
	var/barrel_stress = 0

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/process_fire(atom/target, mob/living/user, message = TRUE, params = null, zone_override = "", bonus_spread = 0)
	if(chambered.BB && !reinforced)
		var/obj/item/ammo_casing/shotgun/S = chambered
		if(prob(10 + barrel_stress) && S.high_power)	//Base 10% chance of misfiring. Goes up with each shot of high_power ammo
			backfire(user)
			return 0

		else if (S.high_power)
			barrel_stress += 5
			if (barrel_stress == 10)
				to_chat(user, "<span class='warning'>[src]'s barrel is left warped from the force of the shot!</span>")
			else if (barrel_stress == 25)
				to_chat(user, "<span class='danger'>[src]'s barrel cracks from the repeated strain!</span>")

		else if (prob(5) && barrel_stress >= 30) // If the barrel is damaged enough to be cracked, flat 5% chance to detonate on low-power ammo as well.
			backfire(user)
			return 0
	..()

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/proc/backfire(mob/living/user)
	playsound(user, fire_sound, fire_sound_volume, vary_fire_sound)
	to_chat(user, "<span class='userdanger'>[src] blows up in your face!</span>")

	user.take_bodypart_damage(0,15) //The explosion already does enough damage.
	explosion(src, 0, 0, 1, 1)

	barrel_stress += 10 //Big damage to barrel, two explosions/misfires will destroy the gun entirely
	qdel(chambered.BB)
	chambered.BB = null //Spend the bullet when you misfire and it explodes. What's blowing up otherwise?

	user.dropItemToGround(src)

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/attackby(obj/item/A, mob/user, params)
	..()
	if(istype(A, /obj/item/stack/cable_coil) && !sawn_off)
		if(slung)
			to_chat(user, "<span class='warning'>There is already a sling on [src]!</span>")
			return
		var/obj/item/stack/cable_coil/C = A
		if(C.use(10))
			slot_flags = ITEM_SLOT_BACK
			to_chat(user, "<span class='notice'>You tie the lengths of cable to the shotgun, making a sling.</span>")
			slung = TRUE
			update_icon()
		else
			to_chat(user, "<span class='warning'>You need at least ten lengths of cable if you want to make a sling!</span>")

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/update_icon()
	..()
	if(slung)
		add_overlay("improvised_sling")

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawoff(mob/user)
	. = ..()
	if(. && slung) //sawing off the gun removes the sling
		new /obj/item/stack/cable_coil(get_turf(src), 10)
		slung = FALSE
		update_icon()

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/examine(mob/user)
	. = ..()
	if (slung)
		. += "It has a shoulder sling fashioned from spare cable attached."
	else
		. += "You could improvise a shoulder sling from some cabling..."

	if (reinforced)
		. += "The barrel has been reinforced for use with high-power ammunition."
	else if (barrel_stress < 10)
		. += "The barrel is in pristine condition."
	else if (barrel_stress < 20)
		. += "The barrel seems to be warped mildly..."
	else
		. += "The barrel is warped and cracked!"

/obj/item/gun/ballistic/shotgun/doublebarrel/improvised/sawn
	name = "sawn-off improvised shotgun"
	desc = "A single-shot shotgun. Better not miss."
	icon_state = "ishotgun"
	item_state = "shotgun_improv_shorty"
	w_class = WEIGHT_CLASS_LARGE
	sawn_off = TRUE
	slot_flags = ITEM_SLOT_BELT
	recoil = SAWN_OFF_RECOIL

/obj/item/gun/ballistic/shotgun/doublebarrel/hook
	name = "hook modified sawn-off shotgun"
	desc = "Range isn't an issue when you can bring your victim to you."
	icon_state = "hookshotgun"
	item_state = "shotgun"
	mag_type = /obj/item/ammo_box/magazine/internal/shot/bounty
	w_class = WEIGHT_CLASS_BULKY
	weapon_weight = WEAPON_MEDIUM
	can_sawoff = FALSE
	force = 10 //it has a hook on it
	attack_verb = list("slashed", "hooked", "stabbed")
	hitsound = 'sound/weapons/bladeslice.ogg'
	//our hook gun!
	var/obj/item/gun/magic/hook/bounty/hook
	var/toggled = FALSE

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/Initialize(mapload)
	. = ..()
	hook = new /obj/item/gun/magic/hook/bounty(src)

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/AltClick(mob/user)
	if(!istype(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(toggled)
		to_chat(user,"<span class='notice'>You switch to the shotgun.</span>")
		fire_sound = initial(fire_sound)
	else
		to_chat(user,"<span class='notice'>You switch to the hook.</span>")
		fire_sound = 'sound/weapons/batonextend.ogg'
	toggled = !toggled

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/examine(mob/user)
	. = ..()
	if(toggled)
		. += "<span class='notice'>Alt-click to switch to the shotgun.</span>"
	else
		. += "<span class='notice'>Alt-click to switch to the hook.</span>"

/obj/item/gun/ballistic/shotgun/doublebarrel/hook/afterattack(atom/target, mob/living/user, flag, params)
	if(toggled)
		hook.afterattack(target, user, flag, params)
	else
		return ..()

