/obj/item/energy_katana
	name = "energy katana"
	desc = "A katana infused with strong energy."
	icon_state = "energy_katana"
	item_state = "energy_katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 40
	throwforce = 20
	block_power = 50
	block_level = 1
	block_upgrade_walk = 1
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_PROJECTILE
	armour_penetration = 50
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	slot_flags = ITEM_SLOT_BACK|ITEM_SLOT_BELT
	sharpness = IS_SHARP
	max_integrity = 200
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/datum/effect_system/spark_spread/spark_system

/obj/item/energy_katana/Initialize()
	. = ..()
	spark_system = new /datum/effect_system/spark_spread()
	spark_system.set_up(5, 0, src)
	spark_system.attach(src)

/obj/item/energy_katana/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(proximity_flag && (isobj(target) || issilicon(target)))
		spark_system.start()
		playsound(user, "sparks", 50, 1)
		playsound(user, 'sound/weapons/blade1.ogg', 50, 1)
		target.emag_act(user)

//If we hit the Ninja who owns this Katana, they catch it.
//Works for if the Ninja throws it or it throws itself or someone tries
//To throw it at the ninja
/obj/item/energy_katana/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(ishuman(hit_atom))
		var/mob/living/carbon/human/H = hit_atom
		if(istype(H.gloves, /obj/item/clothing/gloves/space_ninja))
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
	else if(user.equip_to_slot_if_possible(src, SLOT_BELT, 0, 1, 1))
		msg = "Your Energy Katana teleports back to you, sheathing itself as it does so!</span>"
	else
		msg = "Your Energy Katana teleports to your location!"

	if(caught)
		if(loc == user)
			msg = "You catch your Energy Katana!"
		else
			msg = "Your Energy Katana lands at your feet!"

	if(msg)
		to_chat(user, "<span class='notice'>[msg]</span>")


/obj/item/energy_katana/Destroy()
	QDEL_NULL(spark_system)
	return ..()

/obj/item/energy_katana/might
	name = "mighty katana"
	desc = "An energy katana so powerful, it is capable of batting bullets out of the air."
	block_power = 75
	block_level = 2

/obj/item/energy_katana/dash
	name = "dash katana"
	desc = "A katana infused with strong energy and the power to dash, wielded by the fastest of spider clan operatives."
	var/datum/action/innate/dash/ninja/jaunt
	var/dash_toggled = TRUE

/obj/item/energy_katana/dash/Initialize()
	. = ..()
	jaunt = new(src)

/obj/item/energy_katana/dash/attack_self(mob/user)
	dash_toggled = !dash_toggled
	to_chat(user, "<span class='notice'>You [dash_toggled ? "enable" : "disable"] the dash function on [src].</span>")

/obj/item/energy_katana/dash/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(dash_toggled)
		jaunt.Teleport(user, target)

/obj/item/energy_katana/dash/pickup(mob/living/user)
	. = ..()
	jaunt.Grant(user, src)
	user.update_icons()
	playsound(src, 'sound/items/unsheath.ogg', 25, 1)

/obj/item/energy_katana/dash/dropped(mob/user)
	. = ..()
	jaunt.Remove(user)
	user.update_icons()

/datum/action/innate/dash/ninja
	current_charges = 2
	max_charges = 2
	charge_rate = 60
	recharge_sound = null
