

/obj/item/stack/sticky_tape
	name = "sticky tape"
	singular_name = "sticky tape"
	desc = "Used for sticking to things for sticking said things to people."
	icon = 'icons/obj/tapes.dmi'
	icon_state = "tape_w"
	var/prefix = "sticky"
	item_flags = NOBLUDGEON
	amount = 5
	max_amount = 5
	merge_type = /obj/item/stack/sticky_tape

	var/list/conferred_embed = EMBED_HARMLESS
	var/overwrite_existing = FALSE

/obj/item/stack/sticky_tape/afterattack(obj/item/I, mob/living/user, proximity_flag)
	if (proximity_flag != 1)
		return

	if(!istype(I))
		return

	if(I.embedding == conferred_embed)
		to_chat(user, span_warning("[I] is already coated in [src]!"))
		return

	user.visible_message(span_notice("[user] begins wrapping [I] with [src]."), span_notice("You begin wrapping [I] with [src]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if(do_after(user, 30, target=I))
		playsound(user, 'sound/items/duct_tape/duct_tape_snap.ogg', 50, TRUE)
		use(1)
		if(istype(I, /obj/item/clothing/gloves/fingerless))
			var/obj/item/clothing/gloves/tackler/offbrand/O = new /obj/item/clothing/gloves/tackler/offbrand
			to_chat(user, span_notice("You turn [I] into [O] with [src]."))
			use(1)
			QDEL_NULL(I)
			user.put_in_hands(O)
			return

		I.embedding = conferred_embed
		I.updateEmbedding()
		to_chat(user, span_notice("You finish wrapping [I] with [src]."))
		use(1)
		I.name = "[prefix] [I.name]"

		if(istype(I, /obj/item/grenade))
			var/obj/item/grenade/sticky_bomb = I
			sticky_bomb.sticky = TRUE

/obj/item/stack/sticky_tape/super
	name = "super sticky tape"
	singular_name = "super sticky tape"
	desc = "Quite possibly the most mischevious substance in the galaxy. Use with extreme lack of caution."
	icon_state = "tape_y"
	prefix = "super sticky"
	conferred_embed = EMBED_HARMLESS_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape

/obj/item/stack/sticky_tape/pointy
	name = "pointy tape"
	singular_name = "pointy tape"
	desc = "Used for sticking to things for sticking said things inside people."
	icon_state = "tape_evil"
	prefix = "pointy"
	conferred_embed = EMBED_POINTY
	merge_type = /obj/item/stack/sticky_tape/pointy

/obj/item/stack/sticky_tape/pointy/super
	name = "super pointy tape"
	singular_name = "super pointy tape"
	desc = "You didn't know tape could look so sinister. Welcome to Space Station 13."
	icon_state = "tape_spikes"
	prefix = "super pointy"
	conferred_embed = EMBED_POINTY_SUPERIOR
	merge_type = /obj/item/stack/sticky_tape/pointy/super

/obj/item/stack/sticky_tape/duct
	name = "duct tape"
	singular_name = "duct tape"
	desc = "Tape designed for sealing punctures, holes and breakages in objects. Engineers swear by this stuff for practically all kinds of repairs. Maybe a little TOO much..."
	prefix = "duct taped"
	conferred_embed = EMBED_IMPOSSIBLE
	merge_type = /obj/item/stack/sticky_tape/duct
	var/object_repair_value = 30
	amount = 10
	max_amount = 10

/obj/item/stack/sticky_tape/duct/afterattack_secondary(atom/interacting_with, mob/living/user, proximity_flag)
	. = SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

	if (proximity_flag != 1)
		return

	if(!object_repair_value)
		return

	if(issilicon(interacting_with))
		var/mob/living/silicon/robotic_pal = interacting_with
		var/robot_is_damaged = robotic_pal.getBruteLoss()

		if(!robot_is_damaged)
			user.balloon_alert(user, "[robotic_pal] is not damaged!")
			return

		user.visible_message(span_notice("[user] begins repairing [robotic_pal] with [src]."), span_notice("You begin repairing [robotic_pal] with [src]."))
		playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

		if(!do_after(user, 3 SECONDS, target = robotic_pal))
			return

		robotic_pal.adjustBruteLoss(-object_repair_value)
		use(1)
		to_chat(user, span_notice("You finish repairing [interacting_with] with [src]."))
		return

	if(!isobj(interacting_with) || iseffect(interacting_with))
		return

	// clock cult should be using power through their fabricators
	// the ark also seems to be the only thing in the game that should never be repairable
	if(istype(target, /obj/structure/destructible/clockwork))
		return

	var/obj/item/object_to_repair = interacting_with
	var/object_is_damaged = object_to_repair.get_integrity() < object_to_repair.max_integrity

	if(!object_is_damaged)
		user.balloon_alert(user, "[object_to_repair] is not damaged!")
		return

	user.visible_message(span_notice("[user] begins repairing [object_to_repair] with [src]."), span_notice("You begin repairing [object_to_repair] with [src]."))
	playsound(user, 'sound/items/duct_tape/duct_tape_rip.ogg', 50, TRUE)

	if(!do_after(user, 3 SECONDS, target = object_to_repair))
		return

	object_to_repair.repair_damage(object_repair_value)
	use(1)
	to_chat(user, span_notice("You finish repairing [interacting_with] with [src]."))
	return
