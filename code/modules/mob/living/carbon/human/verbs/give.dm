/mob/living/verb/give()
	set category = "IC"
	set name = "Give"
	set desc = "Give something to someone!"
	set src in oview(1)

	give_item(usr)

/mob/living/proc/give_item(mob/living/carbon/user)


/mob/living/carbon/give_item(mob/living/carbon/user)
	if(!istype(user))
		to_chat(usr, "<span class='warning'>There's noone around to give this!</span>")
		return
	if(src.stat == 2 || user.stat == 2 || src.client == null)
		to_chat(usr, "<span class='notice'>Doesn't look like they are taking it any sooner.</span>")
		return
	if(src.handcuffed)
		to_chat(usr, "<span class='warning'>Those hands are cuffed right now.</span>")
		return //Can't receive items while cuffed
	var/obj/item/I
	if(user.get_active_held_item() == null)
		to_chat(usr, "You don't have anything in your [get_held_index_name(get_held_index_of_item(I))] to give to [src].")
		return
	I = user.get_active_held_item()
	if(!I)
		to_chat(usr, "<span class='warning'>You don't have anything to give!</span>")
		return
	if(src == user) //Shouldn't happen
		to_chat(usr, "<span class='warning'>You tried to give yourself \the [I], but you didn't want it.</span>")
		return
	if(get_empty_held_index_for_side())
		to_chat(usr, "<span class='notice'>You offer \the [I] to [src].</span>")
		switch(alert(src, "[user] wants to give you \a [I], do you accept it?", , "Yes", "No"))
			if("Yes")
				if(!I)
					to_chat(usr, "<span class='warning'>You need the item with you to give it!")
					return
				if(HAS_TRAIT(I, TRAIT_NODROP) || HAS_TRAIT(I, ABSTRACT_ITEM_TRAIT))
					to_chat(usr, "<span class='notice'>That's not something you can give.</span>")
					return
				if(src.stat != CONSCIOUS | src.client == null)
					to_chat(usr, "<span class='notice'>They are not awake!")
					return
				if(!Adjacent(user))
					to_chat(usr, "<span class='warning'>You need to stay still while giving an object.</span>")
					to_chat(src, "<span class='warning'>[user] moved away.</span>")//What an asshole
					return
				if(user.get_active_held_item() != I)
					to_chat(usr, "<span class='warning'>You need to keep the item in your hand.</span>")
					to_chat(src, "<span class='warning'>[user] has put \the [I] away!</span>")
					return
				if(!get_empty_held_index_for_side())
					to_chat(usr, "<span class='warning'>Your hands are full.</span>")
					to_chat(src, "<span class='warning'>Their hands are full.</span>")
					return
				if(!user.dropItemToGround(I))
					to_chat(src, "<span class='warning'>[user] can't let go of \the [I]!</span>")
					to_chat(usr, "<span class='warning'>You can't seem to let go of \the [I].</span>")
					return

				src.put_in_hands(I)
				update_inv_hands()
				src.visible_message("<span class='notice'>[user] handed \the [I] to [src].</span>")
				log_game("[user] gave \the [I] to [src].")
			if("No")
				src.visible_message("<span class='warning'>[user] tried to hand \the [I] to [src] but \he didn't want it.</span>")
				log_game("[src] declined [user]'s item, the item: [I]")
	else
		to_chat(usr, "<span class='warning'>[src]'s hands are full.</span>")
