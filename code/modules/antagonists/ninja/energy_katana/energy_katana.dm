/**
 * # Energy Katana
 *
 * The space ninja's katana.
 *
 * The katana that only space ninja spawns with.  Comes with 30 force and throwforce, along with a signature special jaunting system.
 * Upon clicking on a tile when right clicking, the user will teleport to that tile, assuming their target was not dense.
 * The katana has 3 dashes stored at maximum, and upon using the dash, it will return 20 seconds after it was used.
 * It also has a special feature where if it is tossed at a space ninja who owns it (determined by the ninja suit), the ninja will catch the katana instead of being hit by it.
 *
 */
/obj/item/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	desc_controls = "Right-click to dash."
	icon_state = "energy_katana"
	inhand_icon_state = "energy_katana"
	worn_icon_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 22
	throwforce = 30
	item_flags = ISWEAPON

	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY //For purely balance reasons this one does not get unblockable

	armour_penetration = 50
	w_class = WEIGHT_CLASS_LARGE
	hitsound = 'sound/weapons/bladeslice.ogg'
	pickup_sound = 'sound/items/unsheath.ogg'
	drop_sound = 'sound/items/sheath.ogg'
	block_sound = 'sound/items/block_blade.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = SHARP
	bleed_force = BLEED_DEEP_WOUND
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE

	actions_types = list(
		/datum/action/item_action/delimbing_strike
	)

	var/datum/effect_system/spark_spread/spark_system
	var/datum/action/innate/dash/ninja/jaunt

/obj/item/energy_katana/Initialize(mapload)
	. = ..()
	jaunt = new(src)
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()

	var/list/modifiers = params2list(click_parameters)

	if(LAZYACCESS(modifiers, RIGHT_CLICK) && !target.density)
		jaunt?.teleport(user, target)
	if(proximity_flag && (isobj(target) || issilicon(target)))
		spark_system.start()
		playsound(user, "sparks", 50, 1)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
		target.use_emag(user)

/obj/item/energy_katana/equipped(mob/user, slot, initial)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Grant(user, src)

/obj/item/energy_katana/dropped(mob/user)
	. = ..()
	if(!QDELETED(jaunt))
		jaunt.Remove(user)

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(IS_SPACE_NINJA(H))
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
	QDEL_NULL(jaunt)
	return ..()

/datum/action/innate/dash/ninja
	max_charges = 0
	obj_damage = 350
	has_button = FALSE

/datum/action/innate/dash/ninja/is_available(feedback = FALSE)
	var/mob/living/carbon/human/owner_mob = owner
	if (!istype(owner_mob))
		return FALSE
	var/obj/item/mod/control/pre_equipped/ninja/ninja_suit = owner_mob.back
	if (!istype(ninja_suit))
		return FALSE
	return ninja_suit.active
