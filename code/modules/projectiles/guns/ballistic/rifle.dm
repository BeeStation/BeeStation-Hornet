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

/obj/item/gun/ballistic/rifle/shoot_live_shot(mob/living/user, pointblank, atom/pbtarget, message)
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
	icon_state = "leverrifle"
	item_state = "moistnugget"
	slot_flags = ITEM_SLOT_BACK
	rack_sound = "sound/weapons/leveractionrack.ogg"
	fire_sound = "sound/weapons/leveractionshot.ogg"
	mag_type = /obj/item/ammo_box/magazine/internal/leveraction
	w_class = WEIGHT_CLASS_BULKY
	no_pin_required = TRUE //Nothing stops frontier justice
	bolt_wording = "lever"
	cartridge_wording = "cartridge"
	recoil = 0.5
	bolt_type = BOLT_TYPE_PUMP
	fire_sound_volume = 80
	tac_reloads = FALSE

/obj/item/gun/ballistic/rifle/pipe
	name = "pipe rifle"
	desc = "It's amazing what you can do with some scrap wood and spare pipes."
	can_sawoff = TRUE
	sawn_name = "pipe pistol"
	sawn_desc = "Why have more gun, when less gun can do!"
	icon_state = "piperifle"
	item_state = "moistnugget"
	bolt_type = BOLT_TYPE_NB_BREAK
	cartridge_wording = "cartridge"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/piperifle
	no_pin_required = TRUE
	w_class = WEIGHT_CLASS_BULKY
	force = 8
	recoil = 0.8
	var/slung = FALSE

///////////////////////
//    The  Musket    //
///////////////////////

/obj/item/gun/ballistic/rifle/musket
	name = "maintenance musket"
	desc = "Just as the Space Founding Fathers intended, this will blow a golf ball sized hole in just about anyone."
	icon_state = "piperifle"
	item_state = "moistnugget"
	bolt_type = BOLT_TYPE_NO_BOLT
	bolt_wording = "striker"
	cartridge_wording = "shot"
	slot_flags = null
	mag_type = /obj/item/ammo_box/magazine/internal/musket
	no_pin_required = TRUE
	w_class = WEIGHT_CLASS_HUGE
	weapon_weight = WEAPON_HEAVY
	item_flags = NEEDS_PERMIT | SLOWS_WHILE_IN_HAND
	slowdown = 0
	force = 10
	recoil = 1
	//Load stage 0 = Loading powder | Load stage 1 = Powder has been tamped, loading projectile | Load stage 2 = Projectile has been tamped, ready to fire
	var/load_stage = 0
	var/firing_stance = FALSE
	var/obj/item/reagent_containers/musket/powder_holder

/obj/item/gun/ballistic/rifle/musket/Initialize()
	. = ..()
	powder_holder = new /obj/item/reagent_containers/musket(src)

/obj/item/gun/ballistic/rifle/musket/examine(mob/user)
	. = ..()
	if(firing_stance)
		. += "<b>Ctrl+click</b> to return to rest, and enter a marching stance."
	else
		. += "<b>Ctrl+click</b> to present arms, and drop into a firing stance."
	. += "You can empty the loaded powder and projectile with <b>alt+click</b>"
	if(load_stage == 1 && get_ammo())
		. += "There is a projectile seated on \the [src]'s muzzle."
	if(load_stage >= 2)
		. += "\The [src] looks like it's ready to fire."

/obj/item/gun/ballistic/rifle/musket/AltClick(mob/user)
	if(loc == user)
		if(!user.is_holding(src))
			return
		user.visible_message("<span class='notice'>[user] aims at the ground and begins to vigoriously shake \the [src] in [user.p_their()] hands.</span>",
							 "<span class='notice'>You aim \the [src] at the ground and begin to vigoriously shake and smack it.</span>")
		if(do_after(user, 30, target = src))
			to_chat(user, "<span class='notice'>You manage to empty \the [src]'s load onto the floor.</span>")

			powder_holder.reagent_flags = OPENCONTAINER
			var/T = src.get_turf
			powder_holder.SplashReagents(T, FALSE)
			process_chamber(TRUE, FALSE, FALSE)

/obj/item/gun/ballistic/rifle/musket/CtrlClick(mob/user)
	if(loc == user && user.is_holding(src))
		if(firing_stance)
			user.visible_message("<span class='notice'>[user] returns to a marching stance, holding \the [src] against [user.p_their()] shoulder.</span>",
								 "<span class='notice'>You relax your aim, and return to marching order</span>")
			firing_stance = FALSE
			slowdown = 0
			return
		user.visible_message("<span class='warning'>[user] lowers \the [src] and begins to take aim!</span>",
							 "<span class='notice'>You lower \the [src] into both hands and begin to take aim.</span>")
		if(do_after(user, 20, target = src))
			firing_stance = TRUE
			slowdown = 0.1
			return
	. = ..()

/obj/item/gun/ballistic/rifle/musket/rack(mob/user = null)
	if(!is_wielded)
		to_chat(user, "<span class='warning'>You require your other hand to be free to manipulate \the [src]'s [bolt_wording]!</span>")
		return
	bolt_locked = !bolt_locked
	playsound(src, 'sound/weapons/effects/ballistic_click.ogg', 20, FALSE)
	to_chat(user, "<span class='notice'>You [bolt_locked ? "carefully lower" : "bring back"] the [bolt_wording] of \the [src].</span>")

/obj/item/gun/ballistic/rifle/musket/proc/loading()
	switch(load_stage)
		if(0) //Tamping down the loaded powder charge
			load_stage++
			return

		if(1) //Tamping down the loaded projectile
			chamber_round()
			load_stage++
			return

	//Anything else, just return to a stable state (ready to fire)
	load_stage = 2
	return


/obj/item/gun/ballistic/rifle/musket/attackby(obj/item/A, mob/user, params)
	if(istype(A, /obj/item/reagent_containers))
		if(!powder_holder.reagent_flags)
			to_chat(user, "<span class='warning'>You can't load more powder into \the [src] now!</span>")
			return
		var/V = powder_holder.total_volume
		A.attack(mob/M, user, powder_holder)
		if(V != powder_holder.total_volume)
			load_stage = 0 //If you add more powder, you gotta re-tamp it down.
		return

	if(istype(A, /obj/item/ammo_casing))
		var/loaded = magazine.attackby(A, user, params, TRUE, FALSE)
		if (loaded)
			to_chat(user, "<span class='notice'>You seat \the [A.name] on the muzzle of \the [src].</span>")
			powder_holder.reagent_flags = null
			if(load_stage == 0) //You fucked up, and loaded your projectile before loading your powder charge. Start from the beginning.
				load_stage++
		return

	if(istype(A, /obj/item/musket_rod))
		if(load_stage >= 2)
			to_chat(user, "<span class='warning'>\The [src] is loaded and ready to fire!</span>")
			return

		user.visible_message("<span class='notice'>[user] repeatedly rams \the [A.name] down \the [src]'s barrel.</span>",
							 "<span class='notice'>You begin to tamp down the loaded [load_stage ? "projectile" : "powder charge"].</span>")
		if(do_after(user, 10, target = src))
			to_chat(user, "<span class='notice'>You finish tamping down the loaded [load_stage ? "projectile" : "powder charge"].</span>")
			if(load_stage == 0 && (!powder_holder.reagents ||!powder_holder.total_volume))
				to_chat(user, "<span class='warning'>There's nothing loaded to ram down the barrel!</span>")
				return
			if(load_stage == 1) //Tamping down the loaded projectile
				chamber_round()
			load_stage++
		return

	..()

/obj/item/musket_rod
	name = "musket rod"
	desc = "A long metal rod with a flattened end, used for tamping down the powder charge and projectile in a musket."
	w_class = WEIGHT_CLASS_NORMAL
	icon = 'icons/obj/stacks/minerals.dmi'
	icon_state = "rods"
	item_state = "rods"

/obj/item/reagent_containers/musket
	name = "musket powder pan"
	volume = 10
	reagent_flags = INJECTABLE | REFILLABLE
