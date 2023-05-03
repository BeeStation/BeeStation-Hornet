/obj/item/deployable
	name = "Capsule" //This is intended to be an unused subtype, but you do you.
	desc = "Tell admins they forgot to edit the description when spawning this in."
	icon = 'icons/obj/mining.dmi'
	icon_state = "capsule"
	w_class = WEIGHT_CLASS_TINY
	///This is what the item will deploy as. This will be a one-way conversion unless the deployed item has its own code for converting back
	var/released_object

/obj/item/deployable/attack_self(mob/user)
	if(isopenturf(user.loc))
		deploy(user, user.loc)
	else
		to_chat(user, "<span class='warning'>You cannot deploy [src] inside of something!</span>")

/obj/item/deployable/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(proximity)
		if(isopenturf(target))
			deploy(user, target)

/obj/item/deployable/proc/deploy(mob/user, atom/location)
	var/atom/R = new released_object(location)
	for(var/atom/movable/A in contents)
		A.forceMove(R)
	R.add_fingerprint(user)
	qdel(src)

/obj/item/deployable/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't get out while you're restrained like this!</span>")
		return
	//If container locked
	//	to_chat(user, "<span class='warning'>The [src] is locked, you can't open it from inside!</span>")
	// 	return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You try to force your way out of [src]...</span>")
	to_chat(loc, "<span class='warning'>Someone starts trying to break free of [src]!</span>")
	if(!do_after(user, 200, target = src))
		to_chat(loc, "<span class='warning'>It seems that they've stopped resisting...</span>")
		return
	loc.visible_message("<span class='warning'>[user] breaks free from the [src]!</span>", "<span class='userdanger'>You manage to break free from the [src]!</span>")
	qdel(src)


