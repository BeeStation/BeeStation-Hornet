/datum/action/innate/clockcult/summon_spear
	name = "Summon Weapon"
	icon_icon = 'icons/mob/actions/actions_clockcult.dmi'
	button_icon_state = "ratvarian_spear"
	background_icon_state = "bg_clock"
	buttontooltipstyle = "brass"
	check_flags = AB_CHECK_RESTRAINED|AB_CHECK_STUN|AB_CHECK_CONSCIOUS
	var/obj/item/marked_item
	var/recall_cooldown = 0

/datum/action/innate/clockcult/summon_spear/Activate()
	if(QDELETED(marked_item))
		qdel(src)

	if(!is_servant_of_ratvar(owner))
		return

	if(recall_cooldown > world.time)
		to_chat(owner, "<span class='brass'>You cannot recall [marked_item] yet.</span>")
		return

	var/obj/item_to_retrieve = marked_item
	var/infinite_recursion = 0

	if(!item_to_retrieve.loc)
		if(isorgan(item_to_retrieve)) // Organs are usually stored in nullspace
			var/obj/item/organ/organ = item_to_retrieve
			if(organ.owner)
				// If this code ever runs I will be happy
				log_combat(owner, organ.owner, "magically removed [organ.name] from", addition="INTENT: [uppertext(owner.a_intent)]")
				organ.Remove(organ.owner)
	else
		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
			if(isitem(item_to_retrieve.loc))
				var/obj/item/I = item_to_retrieve.loc
				if(I.item_flags & ABSTRACT) //Being able to summon abstract things because your item happened to get placed there is a no-no
					break
			if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
				var/mob/M = item_to_retrieve.loc

				if(issilicon(M)) //Items in silicons warp the whole silicon
					M.loc.visible_message("<span class='warning'>[owner] suddenly disappears!</span>")
					M.forceMove(owner.loc)
					M.loc.visible_message("<span class='caution'>[owner] suddenly appears!</span>")
					item_to_retrieve = null
					break
				M.dropItemToGround(item_to_retrieve)

				if(iscarbon(M)) //Edge case housekeeping
					var/mob/living/carbon/C = M
					for(var/X in C.bodyparts)
						var/obj/item/bodypart/part = X
						if(item_to_retrieve in part.embedded_objects)
							part.embedded_objects -= item_to_retrieve
							to_chat(C, "<span class='warning'>The [item_to_retrieve] that was embedded in your [owner] has mysteriously vanished. How fortunate!</span>")
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

	recall_cooldown = world.time + 60
	button_icon_state = "ratvarian_spear_cooldown"
	UpdateButtonIcon()
	addtimer(CALLBACK(src, .proc/reset_icon_state), 60)

	if(item_to_retrieve.loc)
		item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly disappears!</span>")
	if(!owner.put_in_hands(item_to_retrieve))
		item_to_retrieve.forceMove(owner.drop_location())
		item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears!</span>")
		playsound(get_turf(owner), 'sound/magic/summonitems_generic.ogg', 50, 1)
	else
		item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears in [owner]'s hand!</span>")
		playsound(get_turf(owner), 'sound/magic/summonitems_generic.ogg', 50, 1)

/datum/action/innate/clockcult/summon_spear/proc/reset_icon_state()
	button_icon_state = "ratvarian_spear"
	UpdateButtonIcon()
