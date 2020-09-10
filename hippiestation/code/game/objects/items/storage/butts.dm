/mob/living/carbon/human/proc/checkbuttinspect(mob/living/carbon/user)
	if(user.zone_selected == "groin")
		var/obj/item/organ/butt/B = getorgan(/obj/item/organ/butt)
		if(!w_uniform)
			var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
			if(B && STR)
				user.visible_message("<span class='warning'>[user] starts inspecting [user == src ? "his own" : "[src]'s"] ass!</span>", "<span class='warning'>You start inspecting [user == src ? "your" : "[src]'s"] ass!</span>")
				if(do_mob(user, src, 40))
					user.visible_message("<span class='warning'>[user] inspects [user == src ? "his own" : "[src]'s"] ass!</span>", "<span class='warning'>You inspect [user == src ? "your" : "[src]'s"] ass!</span>")
					if (user.active_storage)
						user.active_storage.close(user)
					STR.orient2hud(user)
					STR.show_to(user)
					return TRUE
				else
					user.visible_message("<span class='warning'>[user] fails to inspect [user == src ? "his own" : "[src]'s"] ass!</span>", "<span class='warning'>You fail to inspect [user == src ? "your" : "[src]'s"] ass!</span>")
					return TRUE
			else
				to_chat(user, "<span class='warning'>There's nothing to inspect!</span>")
				return TRUE
		else
			if(user == src)
				user.visible_message("<span class='warning'>[user] grabs his own butt!</span>", "<span class='warning'>You grab your own butt!</span>")
				to_chat(user,  "<span class='warning'>You'll need to remove your jumpsuit first!</span>")
			else
				user.visible_message("<span class='warning'>[user] grabs [src]'s butt!</span>", "<span class='warning'>You grab [src]'s butt!</span>")
				to_chat(user, "<span class='warning'>You'll need to remove [src]'s jumpsuit first!</span>")
				to_chat(src, "<span class='userdanger'>You feel your butt being grabbed!</span>")
			return TRUE

/mob/living/carbon/proc/checkbuttinsert(obj/item/I, mob/living/carbon/user)
	if(user.zone_selected == "groin")
		if(user.a_intent == INTENT_GRAB)
			var/mob/living/carbon/human/buttowner = src
			if(!istype(buttowner))
				return FALSE
			if(buttowner.w_uniform)
				to_chat(user, "<span class='danger'>Remove the jumpsuit first!</span>")
				return FALSE
			var/obj/item/organ/butt/B = buttowner.getorgan(/obj/item/organ/butt)
			if(B)
				var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
				if(!STR)
					return FALSE
				user.visible_message("<span class='warning'>[user] starts hiding [I] inside [src == user ? "his own" : "[user]'s"] butt.</span>", "<span class='warning'>You start hiding [I] inside [user == src ? "your" : "[user]'s"] butt.</span>")
				if(do_mob(user, src, 20) && STR.can_be_inserted(I, 0, user))
					STR.handle_item_insertion(I, 0, user)
					user.visible_message("<span class='warning'>[user] hides [I] inside [src == user ? "his own" : "[user]'s"] butt.</span>", "<span class='warning'>You hide [I] inside [user == src ? "your" : "[user]'s"] butt.</span>")
				return TRUE
	return FALSE

/obj/item/clothing/proc/checkbuttuniform(mob/user)
	var/obj/item/organ/butt/B = user.getorgan(/obj/item/organ/butt)
	if(B)
		var/datum/component/storage/STR = B.GetComponent(/datum/component/storage)
		if(STR)
			STR.close_all()
