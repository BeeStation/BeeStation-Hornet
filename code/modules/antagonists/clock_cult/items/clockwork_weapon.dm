/obj/item/clockwork/weapon
	name = "Clockwork Weapon"
	desc = "Something"
	icon = 'icons/obj/clockwork_objects.dmi'
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi';
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	worn_icon_state = "baguette"
	item_flags = ABSTRACT | ISWEAPON
	block_flags = BLOCKING_NASTY | BLOCKING_ACTIVE
	canblock = TRUE	//God blocking is actual aids to deal with, I am sorry for putting this here

	w_class = WEIGHT_CLASS_BULKY
	slot_flags = ITEM_SLOT_BACK
	throwforce = 20
	throw_speed = 4
	armour_penetration = 10
	custom_materials = list(/datum/material/iron=1150, /datum/material/gold=2750)
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	sharpness = SHARP
	bleed_force = BLEED_CUT
	max_integrity = 200

	/// Clock cultists can examine this weapon for a hint on how to use it
	var/clockwork_hint = ""
	/// Action to summon the spear
	var/datum/action/spell/summon_weapon/summon_weapon

/obj/item/clockwork/weapon/Destroy()
	summon_weapon?.Remove(summon_weapon.owner)
	return ..()

/obj/item/clockwork/weapon/pickup(mob/user)
	. = ..()
	if(!user.mind)
		return

	if(IS_SERVANT_OF_RATVAR(user) && !summon_weapon)
		summon_weapon = new()
		summon_weapon.marked_item = WEAKREF(src)
		summon_weapon.Grant(user)

/obj/item/clockwork/weapon/examine(mob/user)
	. = ..()
	if(IS_SERVANT_OF_RATVAR(user) && clockwork_hint)
		. += span_brass(clockwork_hint)

/**
 * While on Reebe the weapon will gain a buff to its damage based off how far it is from the gateway
 * Additionally, if target is not a clock cultist, not dead, and not holy, hit_effect() is called
 */
/obj/item/clockwork/weapon/attack(mob/living/target, mob/living/user)
	if(!is_reebe(user.z))
		return ..()

	// Special hit effect
	if(target.stat != DEAD && !IS_SERVANT_OF_RATVAR(target) && !target.can_block_magic(MAGIC_RESISTANCE_HOLY))
		hit_effect(target, user)

	// Buff the weapon's force based off how far it is from the gateway
	var/force_buff = 0
	if(GLOB.celestial_gateway)
		var/distance = get_dist(GLOB.celestial_gateway, user)
		if(distance < 15)
			switch(distance)
				if(0 to 6)
					force_buff = 8
				if(6 to 10)
					force_buff = 5
				if(10 to 15)
					force_buff = 3

			playsound(src, 'sound/effects/clockcult_gateway_disrupted.ogg', 40)

	force += force_buff
	. = ..()
	force = initial(force)

/**
 * While on Reebe the weapon will call hit_effect() if thrown at a non-holy and non clock-cultist person
 */
/obj/item/clockwork/weapon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	. = ..()
	if(!is_reebe(z))
		return

	if(isliving(hit_atom))
		var/mob/living/living_target = hit_atom
		if(!living_target.can_block_magic(MAGIC_RESISTANCE_HOLY) && !IS_SERVANT_OF_RATVAR(living_target))
			hit_effect(living_target, throwingdatum?.thrower, thrown = TRUE)

/**
 * The special effect applied when hitting a living creature
 */
/obj/item/clockwork/weapon/proc/hit_effect(mob/living/target, mob/living/user, thrown = FALSE)
	return

/obj/item/clockwork/weapon/brass_spear
	name = "brass spear"
	desc = "A razor-sharp spear made of brass. It thrums with barely-contained energy."
	clockwork_desc = span_brass("A razor-sharp spear made of a magnetic brass allow. It accelerates towards targets while on Reebe dealing increased damage.")
	icon_state = "ratvarian_spear"
	embedding = list("max_damage_mult" = 7.5, "armour_block" = 80)
	throwforce = 36
	force = 25
	armour_penetration = 24
	clockwork_hint = "Throwing the spear will deal bonus damage while on Reebe."

/obj/item/clockwork/weapon/brass_battlehammer
	name = "brass battle-hammer"
	desc = "A brass hammer glowing with energy."
	clockwork_desc = span_brass("A brass hammer enfused with an ancient power allowing it to strike foes with incredible force.")
	icon_state = "ratvarian_hammer"
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "mining_hammer1"
	throwforce = 25
	armour_penetration = 6
	sharpness = BLUNT
	attack_verb_continuous = list("bashes", "bludgeons", "thrashes", "whacks")
	attack_verb_simple = list("bash", "bludgeon", "thrash", "whack")
	clockwork_hint = "Enemies hit by this will be flung back while on Reebe."

/obj/item/clockwork/weapon/brass_battlehammer/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded = 15, force_wielded = 28, block_power_wielded = 25)

/obj/item/clockwork/weapon/brass_battlehammer/hit_effect(mob/living/target, mob/living/user, thrown = FALSE)
	if(!ISWIELDED(src))
		return
	var/atom/throw_target = get_edge_target_turf(target, get_dir(src, get_step_away(target, src)))
	target.throw_at(throw_target, thrown ? 2 : 1, 4)

/obj/item/clockwork/weapon/brass_sword
	name = "brass longsword"
	desc = "A large sword made of brass."
	clockwork_desc = span_brass("A large sword made of brass. It contains an aurora of energetic power designed to disrupt electronics.")
	icon_state = "ratvarian_sword"
	worn_icon = 'icons/mob/clothing/back.dmi'
	worn_icon_state = "claymore"
	force = 26
	throwforce = 20
	armour_penetration = 12
	attack_verb_continuous = list("attacks", "pokes", "jabs", "tears", "lacerates", "gores")
	attack_verb_simple = list("attack", "poke", "jab", "tear", "lacerate", "gore")
	clockwork_hint = "Targets will be struck with a powerful electromagnetic pulse while on Reebe."

	COOLDOWN_DECLARE(emp_cooldown)

/obj/item/clockwork/weapon/brass_sword/hit_effect(mob/living/target, mob/living/user, thrown)
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		return
	COOLDOWN_START(src, emp_cooldown, 30 SECONDS)

	target.emp_act(EMP_LIGHT)
	new /obj/effect/temp_visual/emp/pulse(target.loc)
	addtimer(CALLBACK(src, PROC_REF(send_message), user), 30 SECONDS)
	to_chat(user, span_brass("You strike [target] with an electromagnetic pulse!"))
	playsound(user, 'sound/magic/lightningshock.ogg', 40)

/obj/item/clockwork/weapon/brass_sword/attack_atom(obj/O, mob/living/user)
	..()
	if(!(istype(O, /obj/vehicle/sealed/mecha) && is_reebe(user.z)))
		return
	if(!COOLDOWN_FINISHED(src, emp_cooldown))
		return
	COOLDOWN_START(src, emp_cooldown, 20 SECONDS)

	var/obj/vehicle/sealed/mecha/target = O
	target.emp_act(EMP_HEAVY)
	new /obj/effect/temp_visual/emp/pulse(target.loc)
	addtimer(CALLBACK(src, PROC_REF(send_message), user), 20 SECONDS)
	to_chat(user, span_brass("You strike [target] with an electromagnetic pulse!"))
	playsound(user, 'sound/magic/lightningshock.ogg', 40)

/obj/item/clockwork/weapon/brass_sword/proc/send_message(mob/living/target)
	to_chat(target, span_brass("[src] glows, indicating the next attack will disrupt electronics of the target."))

//Clockbow, different pathing

/obj/item/gun/ballistic/bow/clockwork
	name = "Brass Bow"
	desc = "A bow made from brass and other components that you can't quite understand. It glows with a deep energy and frabricates arrows by itself."
	icon_state = "bow_clockwork"
	force = 10
	mag_type = /obj/item/ammo_box/magazine/internal/bow/clockcult
	var/recharge_time = 15

/obj/item/gun/ballistic/bow/clockwork/after_live_shot_fired(mob/living/user, pointblank, atom/pbtarget, message)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(recharge_bolt)), recharge_time)

/obj/item/gun/ballistic/bow/clockwork/attack_self(mob/living/user)
	if (chambered)
		chambered = null
		to_chat(user, span_notice("You dispell the arrow."))
	else if (get_ammo())
		var/obj/item/I = user.get_active_held_item()
		if (do_after(user, 0.5 SECONDS, I))
			to_chat(user, span_notice("You draw back the bowstring."))
			playsound(src, 'sound/weapons/bowdraw.ogg', 75, 0) //gets way too high pitched if the freq varies
			chamber_round()
	update_icon()

/obj/item/gun/ballistic/bow/clockwork/proc/recharge_bolt()
	if(magazine.get_round(TRUE))
		return
	var/obj/item/ammo_casing/caseless/arrow/clockbolt/CB = new
	magazine.give_round(CB)
	update_icon()

/obj/item/gun/ballistic/bow/clockbolt/attackby(obj/item/I, mob/user, params)
	return

/obj/item/ammo_box/magazine/internal/bow/clockcult
	ammo_type = /obj/item/ammo_casing/caseless/arrow/clockbolt
	start_empty = FALSE

/obj/item/ammo_casing/caseless/arrow/clockbolt
	name = "energy bolt"
	desc = "An arrow made from a strange energy."
	icon_state = "arrow_redlight"
	projectile_type = /obj/projectile/energy/clockbolt

/obj/projectile/energy/clockbolt
	name = "energy bolt"
	icon_state = "arrow_energy"
	damage = 24
	damage_type = BURN
	nodamage = FALSE
