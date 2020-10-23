// --- THE BULLETS --- 

/obj/item/ammo_casing/energy/railgun_rod
	name = "Railgun"
	desc = "Why are you seeing this?!"
	projectile_type = /obj/item/projectile/bullet/reusable/railgun_rod
	icon_state = "retro"
	e_cost = 100
	fire_sound = 'sound/weapons/grenadelaunch.ogg'
	heavy_metal = FALSE

/obj/item/projectile/bullet/reusable/railgun_rod
	name = "flying rod"
	desc = "It's heading fast towards your face!"
	icon_state = "chronobolt"	//that is, till sprites make one better
	ammo_type = /obj/item/stack/rods
	nodamage = TRUE
	damage = 3

/obj/item/projectile/bullet/reusable/railgun_rod/Initialize()
	. = ..()
	var/obj/item/stack/rods/S = new ammo_type(src)
	

/obj/item/projectile/bullet/reusable/railgun_rod/on_hit(atom/target, blocked)
	. = ..()	
	var/mob/living/carbon/human/human_target = target
	if(!istype(human_target))
		if (proc(20))
			var/obj/item/stack/rods/embed_rod = new ammo_type(T)
			embed_rod.ammount = RAILGUN_RODS_FIRED
			embed_rod.embedding = new datum/embedding_behavior(
				embed_chance = 100,
                embedded_fall_chance = 10,
                embedded_ignore_throwspeed_threshold = TRUE
			)
			human_target.hitby(embed_rod, skipcatch = TRUE, hitpush = FALSE, blocked = FALSE)
			embed_rod.embedding.embed_chance = 0
			dropped = TRUE

/obj/item/projectile/bullet/reusable/railgun_rod/handle_drop()
	if(!dropped)
		var/turf/T = get_turf(src)
		var/obj/item/stack/rods/S = new ammo_type(T)
		S.ammount = RAILGUN_RODS_FIRED
		dropped = TRUE

/obj/item/projectile/energy/duel/on_hit(atom/target, blocked)
	. = ..()
	var/turf/T = get_turf(target)
	var/obj/effect/temp_visual/dueling_chaff/C = locate() in T
	if(C)
		var/counter_setting
		switch(setting)
			if(DUEL_SETTING_A)
				counter_setting = DUEL_SETTING_B
			if(DUEL_SETTING_B)
				counter_setting = DUEL_SETTING_C
			if(DUEL_SETTING_C)
				counter_setting = DUEL_SETTING_A
		if(C.setting == counter_setting)
			return BULLET_ACT_BLOCK

	var/mob/living/L = target
	if(!istype(target))
		return BULLET_ACT_BLOCK
	
	var/obj/item/bodypart/B = L.get_bodypart(BODY_ZONE_HEAD)
	B.dismember()
	qdel(B)

		
// --- THE GUN ---

#define RAILGUN_MAX_AMMO = 60
#define RAILGUN_RODS_FIRED = 3

/obj/item/gun/energy/railgun
	icon_state = "meteor_gun"
	name = "rail gun"
	desc = "A unique energy gun that uses magnetic induction to launch iron rods at high velocity."
	icon = 'icons/obj/guns/energy.dmi'
	ammo_type = list(/obj/item/ammo_casing/energy/railgun_rod)
	can_charge = TRUE	
	dead_cell = FALSE
	var/loaded_rods = RAILGUN_MAX_AMMO

/obj/item/gun/energy/railgun/update_icon(force_update)
	return

/obj/item/gun/energy/railgun/attack_self(mob/living/user as mob)
	if(loaded_rods > 0)
		var/obj/item/stack/rods/mylongrod = new /obj/item/stack/rods(get_turf(src))
		mylongrod.amount = loaded_rods
		loaded_rods = 0
		to_chat(user, "<span class='warning'>You unload the iron rods from the [src]!</span>")

/obj/item/gun/energy/railgun/attackby(obj/item/item, mob/user, params)
	if (istype(item,/obj/item/stack/rods))
		playsound(src.loc, 'sound/machines/click.ogg', 50, 1)
		to_chat(user, "<span class='warning'>You load the [item] into the [src]!</span>")
		var/obj/item/stack/rods/payload = item
		if (payload.amount + loaded_rods < RAILGUN_MAX_AMMO)
			loaded_rods += payload.amount
			QDEL(payload)
			update_icon(FALSE)
		else
			var/delta = RAILGUN_MAX_AMMO-loaded_rods
			payload.amount -= delta
			payload.update_icon()
			loaded_rods += delta
			update_icon(FALSE)
		to_chat(user, "<span class='warning'>It now has [loaded_rods] ammo.</span>")
	
/obj/item/gun/energy/railgun/recharge_newshot(no_cyborg_drain)
	if (loaded_rods<RAILGUN_RODS_FIRED)
		return FALSE
	return ..()

/obj/item/gun/energy/railgun/examine(mob/user)
	. = ..()
	. += "\It currently has [loaded_rods] ammo."

/obj/item/gun/energy/railgun/can_shoot()
	return ..() && loaded_rods>0	

/obj/item/gun/energy/ignition_effect(atom/A, mob/living/user)
	return //you try to ignite your cigar with a railgun and you shot a fucking rod through your dumb ugly face

		
// --- DISGUISED TRAITOR GUN ---	

/obj/item/gun/energy/railgun/fakeinducer
	icon_state = "inducer-engi"
	item_state = "inducer-engi"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	name = "inducer"
	desc = "An inducer modified to recieve and launch iron rods at high velocity."
	loaded_rods = 0