/obj/item/pushbroom
	name = "broom"
	desc = "This is my BROOMSTICK! It can be used manually or braced with two hands to sweep items as you move. It has a telescopic handle for compact storage."
	icon = 'icons/obj/janitor.dmi'
	icon_state = "broom0"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 8
	throwforce = 10
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_LARGE
	attack_verb_continuous = list("sweeps", "brushes off", "bludgeons", "whacks")
	attack_verb_simple = list("sweep", "brush off", "bludgeon", "whack")
	resistance_flags = FLAMMABLE

/obj/item/pushbroom/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_TWOHANDED_WIELD, PROC_REF(on_wield))
	RegisterSignal(src, COMSIG_TWOHANDED_UNWIELD, PROC_REF(on_unwield))
	AddComponent(/datum/component/two_handed, force_unwielded=8, force_wielded=12, icon_wielded="broom1")

/obj/item/pushbroom/update_icon_state()
	icon_state = "broom0"
	..()

/// triggered on wield of two handed item
/obj/item/pushbroom/proc/on_wield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	to_chat(user, span_notice("You brace the [src] against the ground in a firm sweeping stance."))
	RegisterSignal(user, COMSIG_MOVABLE_MOVED, PROC_REF(sweep))

/// triggered on unwield of two handed item
/obj/item/pushbroom/proc/on_unwield(obj/item/source, mob/user)
	SIGNAL_HANDLER

	UnregisterSignal(user, COMSIG_MOVABLE_MOVED)

/obj/item/pushbroom/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(ISWIELDED(src))
		sweep(user, A, FALSE)
	else
		to_chat(user, span_warning("You need to wield \the [src] in both hands to sweep!"))

/obj/item/pushbroom/proc/sweep(mob/user, atom/A, moving = TRUE)
	SIGNAL_HANDLER

	var/turf/target
	if (!moving)
		if (isturf(A))
			target = A
		else
			target = get_turf(A)
	else
		target = get_turf(user)
	if (locate(/obj/structure/table) in target.contents)
		return
	var/i = 0
	var/turf/target_turf = get_step(target, user.dir)
	var/obj/machinery/disposal/bin/target_bin = locate(/obj/machinery/disposal/bin) in target_turf.contents
	for(var/obj/item/garbage in target.contents)
		if(!garbage.anchored)
			if (target_bin)
				garbage.forceMove(target_bin)
			else
				garbage.Move(target_turf, user.dir)
			i++
		if(i > 19)
			break
	if(i > 0)
		if (target_bin)
			target_bin.update_icon()
			to_chat(user, span_notice("You sweep the pile of garbage into [target_bin]."))
		playsound(loc, 'sound/weapons/thudswoosh.ogg', 30, TRUE, -1)

/obj/item/pushbroom/proc/janicart_insert(mob/user, obj/structure/janitorialcart/J) //bless you whoever fixes this copypasta
	J.put_in_cart(src, user)
	J.mybroom=src
	J.update_icon()
