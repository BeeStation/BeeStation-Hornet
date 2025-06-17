/obj/structure/closet/crate/large
	name = "large crate"
	desc = "A hefty wooden crate. You'll need a crowbar to get it open."
	icon_state = "large_crate"
	density = TRUE
	material_drop = /obj/item/stack/sheet/wood
	material_drop_amount = 4
	delivery_icon = "deliverybox"
	integrity_failure = 0 //Makes the crate break when integrity reaches 0, instead of opening and becoming an invisible sprite.
	open_sound = 'sound/machines/wooden_closet_open.ogg'
	close_sound = 'sound/machines/wooden_closet_close.ogg'
	open_sound_volume = 25
	close_sound_volume = 50
	door_anim_time = 0

/obj/structure/closet/crate/large/attack_hand(mob/user, list/modifiers)
	add_fingerprint(user)
	if(manifest)
		tear_manifest(user)
	else
		to_chat(user, span_warning("You need a crowbar to pry this open!"))

/obj/structure/closet/crate/large/attackby(obj/item/W, mob/living/user, params)
	if(W.tool_behaviour == TOOL_CROWBAR)
		if(manifest)
			tear_manifest(user)

		user.visible_message("[user] pries \the [src] open.", \
							span_notice("You pry open \the [src]."), \
							span_italics("You hear splitting wood."))
		playsound(src.loc, 'sound/weapons/slashmiss.ogg', 75, 1)

		var/turf/T = get_turf(src)
		for(var/i in 1 to material_drop_amount)
			new material_drop(src)
		for(var/atom/movable/AM in contents)
			AM.forceMove(T)

		qdel(src)

	else
		if(user.combat_mode) //Only return  ..() if intent is harm, otherwise return 0 or just end it.
			return ..() //Stops it from opening and turning invisible when items are used on it.

		else
			to_chat(user, span_warning("You need a crowbar to pry this open!"))
			return FALSE //Just stop. Do nothing. Don't turn into an invisible sprite. Don't open like a locker.
					//The large crate has no non-attack interactions other than the crowbar, anyway.
