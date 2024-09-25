/obj/effect/proc_holder/spell/targeted/summon_spear
	name = "Summon Weapon"
	desc = "Summons your weapon from across time and space."

	charge_max = 20
	invocation = "none"
	invocation_type = INVOCATION_NONE
	action_icon = 'icons/mob/actions/actions_clockcult.dmi'
	action_icon_state = "ratvarian_spear"
	action_background_icon_state = "bg_clock"
	clothes_req = FALSE
	range = -1
	include_user = TRUE

	var/obj/item/marked_item

/obj/effect/proc_holder/spell/targeted/summon_spear/cast(list/targets, mob/user)
	if(QDELETED(marked_item))
		qdel(src)

	if(!is_servant_of_ratvar(user))
		return

	var/obj/item_to_retrieve = marked_item
	var/infinite_recursion = 0

	if(item_to_retrieve.loc)
		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
			if(isitem(item_to_retrieve.loc))
				var/obj/item/I = item_to_retrieve.loc
				if(I.item_flags & ABSTRACT) //Being able to summon abstract things because your item happened to get placed there is a no-no
					break
			if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
				var/mob/M = item_to_retrieve.loc

				if(issilicon(M)) //Items in silicons warp the whole silicon
					M.loc.visible_message("<span class='warning'>[user] suddenly disappears!</span>")
					M.forceMove(user.loc)
					M.loc.visible_message("<span class='warning'>[user] suddenly appears!</span>")
					item_to_retrieve = null
					break
				M.dropItemToGround(item_to_retrieve)

				if(iscarbon(M)) //Edge case housekeeping
					var/mob/living/carbon/C = M
					for(var/X in C.bodyparts)
						var/obj/item/bodypart/part = X
						if(item_to_retrieve in part.embedded_objects)
							part.embedded_objects -= item_to_retrieve
							to_chat(C, "<span class='warning'>The [item_to_retrieve] that was embedded in your [user] has mysteriously vanished. How fortunate!</span>")
							if(!C.has_embedded_objects())
								C.clear_alert("embeddedobject")
								SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "embedded")
							break

			else
				if(istype(item_to_retrieve.loc, /obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
					var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
					P.disconnect()
					P.update_icon()

				item_to_retrieve = item_to_retrieve.loc

			infinite_recursion += 1

	if(!item_to_retrieve)
		return

	if(item_to_retrieve.loc)
		item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly disappears!</span>")
	if(!user.put_in_hands(item_to_retrieve))
		item_to_retrieve.forceMove(user.drop_location())
		item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly appears!</span>")
		playsound(get_turf(user), 'sound/magic/summonitems_generic.ogg', 50, 1)
	else
		item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly appears in [user]'s hand!</span>")
		playsound(get_turf(user), 'sound/magic/summonitems_generic.ogg', 50, 1)
