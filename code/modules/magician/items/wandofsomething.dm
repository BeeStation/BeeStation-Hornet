/obj/item/magician/wand
	name = "Wand of Something"
	desc = "The core of stage magic, has the power to harvest natural magic."
	icon_state = "wand_something"
	item_state = "wand"
	w_class = WEIGHT_CLASS_NORMAL
	light_system = MOVABLE_LIGHT
	light_range = 2
	light_power = 0.6
	light_on = FALSE
	item_flags = ISWEAPON
	var/lit = 0
	heat = 1500
	resistance_flags = FIRE_PROOF
	light_color = LIGHT_COLOR_BABY_BLUE
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'

	/// Time in world time units until the wand can be toggled again
	var/next_toggle_time = 0

	/// Cooldown duration (1 second = 10)
	var/toggle_cooldown = 20


/obj/item/magician/wand/update_icon_state()
	icon_state = "[initial(icon_state)][lit ? "-on" : ""]"
	item_state = "[initial(item_state)][lit ? "-on" : ""]"
	return ..()

/obj/item/magician/wand/proc/create_lighter_overlay()
	return mutable_appearance(icon, "lighter_overlay[lit ? "-on" : ""]")

/obj/item/magician/wand/ignition_effect(atom/A, mob/user)
	if(is_hot())
		. = span_rose("With a single flick of [user.p_their()] wrist, [user] smoothly lights [A] with [src]. Damn [user.p_theyre()] cool.")

/obj/item/magician/wand/proc/set_lit(new_lit)
	if(lit == new_lit)
		return
	lit = new_lit
	if(lit)
		force = 5
		damtype = BURN
		hitsound = 'sound/items/welder.ogg'
		attack_verb_continuous = list("burns", "singes")
		attack_verb_simple = list("burn", "singe")
		START_PROCESSING(SSobj, src)
	else
		hitsound = "swing_hit"
		force = 0
		attack_verb_continuous = null //human_defense.dm takes care of it
		attack_verb_simple = null
		STOP_PROCESSING(SSobj, src)
	set_light_on(lit)
	update_icon()

/obj/item/magician/wand/extinguish()
	set_lit(FALSE)

/obj/item/magician/wand/attack_self(mob/living/user)
	if(user.is_holding(src))
		if(world.time < next_toggle_time)
			to_chat(user, span_warning("The wand is still settling. Wait a moment before toggling it again."))
			return

		next_toggle_time = world.time + toggle_cooldown

		if(!lit)
			set_lit(TRUE)
			user.visible_message("In a split second, [user] ignites the [src] in one smooth movement.", span_notice("In a split second, you ignite the [src] in one smooth movement."))
			playsound(src, 'sound/weapons/emitter.ogg', 30, 1, -1)
		else
			set_lit(FALSE)
			user.visible_message("You see the blue flame vanish, as [user] extinguishes the [src] without even looking at what [user.p_theyre()] doing. Wow.", span_notice("You extinguish the [src] without even looking at what you're doing. Wow."))
			playsound(src, 'sound/weapons/emitter.ogg', 10, 1, -1, extrarange = SILENCED_SOUND_EXTRARANGE, falloff_distance = 1)
	else
		. = ..()


/obj/item/magician/wand/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(lit && M.IgniteMob())
		message_admins("[ADMIN_LOOKUPFLW(user)] set [key_name_admin(M)] on fire with [src] at [AREACOORD(user)]")
		log_game("[key_name(user)] set [key_name(M)] on fire with [src] at [AREACOORD(user)]")
	var/obj/item/clothing/mask/cigarette/cig = help_light_cig(M)
	if(lit && cig && !user.combat_mode)
		if(cig.lit)
			to_chat(user, span_notice("The [cig.name] is already lit."))
		if(M == user)
			cig.attackby(src, user)
		else
			if(cig.reagents.get_reagent_amount(/datum/reagent/toxin/plasma))
				message_admins("[cig.name] that contains plasma was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig.name] that contains plasma was lit by [key_name(user)] for [key_name(M)]!")
			if(cig.reagents.get_reagent_amount(/datum/reagent/fuel))
				message_admins("[cig.name] that contains fuel was lit by [ADMIN_LOOKUPFLW(user)] for [key_name_admin(M)]!")
				log_game("[cig.name] that contains fuel was lit by [key_name(user)] for [key_name(M)]!")
			cig.light(span_rose("[user] whips the [name] out and holds it for [M]. [user.p_their(TRUE)] arm is as steady as the unflickering flame [user.p_they()] light[user.p_s()] \the [cig] with."))
	else
		..()

/obj/item/magician/wand/process()
	open_flame()

/obj/item/magician/wand/is_hot()
	return lit * heat

/obj/item/magician/wand/afterattack(atom/target, mob/user, flag)
	. = ..()

	if(!lit)
		return

	if(istype(target, /obj/item/food/deadmouse))
		var/obj/item/food/deadmouse/mouse = target
		var/obj/item/magician/book/book = null

		for (var/obj/item/I in user.get_contents())
			if (istype(I, /obj/item/magician/book))
				var/obj/item/magician/book/B = I
				book = B
				break

		if (book)
			book.magic_knowledge += 1
			user.visible_message("<span class='notice'>[user] waves the wand and the dead mouse vanishes into thin air!</span>")
			user.show_message("<span class='notice'>Using your book, you harvest the magic from the mouse.</span>")
			playsound(loc, 'sound/magic/magic_missile.ogg', 50, 1)
			qdel(mouse)
		else
			user.show_message("<span class='warning'>You need your book to learn and harvest something from this!</span>")

