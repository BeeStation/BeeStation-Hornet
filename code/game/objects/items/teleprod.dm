/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	item_state = "teleprod"
	slot_flags = null

/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/carbon/M, mob/living/carbon/user)//handles making things teleport when hit
	..()
	if(turned_on && HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
		user.visible_message(span_danger("[user] accidentally hits [user.p_them()]self with [src]!"), \
							span_userdanger("You accidentally hit yourself with [src]!"))
		if(do_teleport(user, get_turf(user), 50, channel = TELEPORT_CHANNEL_BLUESPACE))//honk honk
			SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
			user.Paralyze(stun_time*3)
			deductcharge(cell_hit_cost)
		else
			SEND_SIGNAL(user, COMSIG_LIVING_MINOR_SHOCK)
			user.Paralyze(stun_time*3)
			deductcharge(cell_hit_cost/4)
		return
	else
		if(turned_on)
			if(!istype(M) && M.anchored)
				return .
			else
				SEND_SIGNAL(M, COMSIG_LIVING_MINOR_SHOCK)
				do_teleport(M, get_turf(M), 15, channel = TELEPORT_CHANNEL_BLUESPACE)

/obj/item/melee/baton/cattleprod/attackby(obj/item/I, mob/user, params)//handles sticking a crystal onto a stunprod to make a teleprod
	if(istype(I, /obj/item/stack/ore/bluespace_crystal))
		if(!cell)
			var/obj/item/stack/ore/bluespace_crystal/BSC = I
			var/obj/item/melee/baton/cattleprod/teleprod/S = new /obj/item/melee/baton/cattleprod/teleprod
			remove_item_from_storage(user)
			qdel(src)
			BSC.use(1)
			user.put_in_hands(S)
			to_chat(user, span_notice("You place the bluespace crystal firmly into the igniter."))
			log_crafting(user, S, TRUE)
		else
			user.visible_message(span_warning("You can't put the crystal onto the stunprod while it has a power cell installed!"))
	else
		return ..()
