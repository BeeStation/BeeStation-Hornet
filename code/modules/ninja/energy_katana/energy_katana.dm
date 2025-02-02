/obj/item/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	worn_icon_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	item_flags = ISWEAPON
	force = 25
	throwforce = 40
	armour_penetration = 60
	w_class = WEIGHT_CLASS_LARGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	// Dismembering is actually based on the unique action abillities that the katana has
	// rather than just simply hitting the target
	sharpness = SHARP
	bleed_force = BLEED_DEEP_WOUND
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	actions_types = list(
		/datum/action/item_action/delimbing_strike
	)
	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/ninja/jaunt
	var/dash_toggled = TRUE

/obj/item/energy_katana/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_katana/ComponentInitialize()
	. = ..()
	// Not very strong shield, but will protect you from a few shots that lets the ninja be in control of conversations
	AddComponent(/datum/component/shielded, max_integrity = 30, charge_recovery = 10, shield_inhand = TRUE, shield_flags = ENERGY_SHIELD_BLOCK_PROJECTILES | ENERGY_SHIELD_INVISIBLE, on_active_effects = CALLBACK(src, PROC_REF(add_shield_effects)), on_deactive_effects = CALLBACK(src, PROC_REF(remove_shield_effects)))

/obj/item/energy_katana/proc/add_shield_effects(mob/living/wearer, current_integrity)
	RegisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN, PROC_REF(intercept_gun_fire))

/obj/item/energy_katana/proc/remove_shield_effects(mob/living/wearer, current_integrity)
	UnregisterSignal(wearer, COMSIG_MOB_BEFORE_FIRE_GUN)

/// Intercept outgoing gunfire
/obj/item/energy_katana/proc/intercept_gun_fire(mob/source, obj/item/gun, atom/target, aimed)
	SIGNAL_HANDLER
	return GUN_HIT_SELF

/obj/item/energy_katana/attack_self(mob/user)
	dash_toggled = !dash_toggled
	to_chat(user, span_notice("You [dash_toggled ? "enable" : "disable"] the dash function on [src]."))

/obj/item/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(dash_toggled && get_dist(target, user) > 1)
		jaunt.Teleport(user, target)
	if(proximity_flag)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)

/obj/item/energy_katana/pickup(mob/living/user)
	..()
	if(jaunt)
		jaunt.Grant(user, src)
	if(user.client)
		playsound(src, 'sound/items/unsheath.ogg', 25, 1)
	user.update_icons()

/obj/item/energy_katana/dropped(mob/user)
	..()
	if(jaunt)
		jaunt.Remove(user)
	user.update_icons()

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H.wear_suit, /obj/item/clothing/suit/space/space_ninja))
			var/obj/item/clothing/suit/space/space_ninja/SN = H.wear_suit
			if(SN.energyKatana == src)
				returnToOwner(H, 0, 1)
				return

	..()

/obj/item/energy_katana/proc/returnToOwner(mob/living/carbon/human/user, doSpark = 1, caught = 0)
	if(!istype(user))
		return
	forceMove(get_turf(user))

	if(doSpark)
		spark_system.start()
		playsound(get_turf(src), "sparks", 50, 1)

	var/msg = ""

	if(user.put_in_hands(src))
		msg = "Your Energy Katana teleports into your hand!"
	else if(user.equip_to_slot_if_possible(src, ITEM_SLOT_BELT, 0, 1, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, span_notice("[msg]"))


/obj/item/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/datum/action/innate/dash/ninja
	max_charges = 0
	obj_damage = 350

/datum/action/innate/dash/ninja/is_available()
	var/mob/living/carbon/human/owner_mob = owner
	if (!istype(owner_mob))
		return FALSE
	var/obj/item/clothing/suit/space/space_ninja/ninja_suit = owner_mob.wear_suit
	if (!istype(ninja_suit))
		return FALSE
	return ninja_suit.s_initialized
