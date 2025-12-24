/obj/item/melee/baton/cattleprod/teleprod
	name = "teleprod"
	desc = "A prod with a bluespace crystal on the end. The crystal doesn't look too fun to touch."
	w_class = WEIGHT_CLASS_NORMAL
	icon_state = "teleprod"
	inhand_icon_state = "teleprod"

	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
	block_power = 50

/obj/item/melee/baton/cattleprod/teleprod/attack(mob/living/target_mob, mob/living/user, params)
	. = ..()
	if(damtype == STAMINA)
		do_teleport(target_mob, target_mob, 15, channel = TELEPORT_CHANNEL_BLUESPACE)

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
