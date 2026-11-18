/datum/action/spell/summonitem
	name = "Instant Summons"
	desc = "This spell can be used to recall a previously marked item to your hand from anywhere in the universe."
	button_icon_state = "summons"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 10 SECONDS

	invocation = "GAR YOK"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	spell_max_level = 1 //cannot be improved

	///The obj marked for recall
	var/obj/marked_item

/datum/action/spell/summonitem/is_valid_spell(mob/user, atom/target)
	return isliving(user)

/// Set the passed object as our marked item
/datum/action/spell/summonitem/proc/mark_item(obj/to_mark)
	name = "Recall [to_mark]"
	marked_item = to_mark
	RegisterSignal(marked_item, COMSIG_QDELETING, PROC_REF(on_marked_item_deleted))

/// Unset our current marked item
/datum/action/spell/summonitem/proc/unmark_item()
	name = initial(name)
	UnregisterSignal(marked_item, COMSIG_QDELETING)
	marked_item = null

/// Signal proc for COMSIG_QDELETING on our marked item, unmarks our item if it's deleted
/datum/action/spell/summonitem/proc/on_marked_item_deleted(datum/source)
	SIGNAL_HANDLER

	if(owner)
		to_chat(owner, ("<span class='boldwarning'>You sense your marked item has been destroyed!</span>"))
	unmark_item()

/datum/action/spell/summonitem/on_cast(mob/living/user, atom/target)
	. = ..()
	if(QDELETED(marked_item))
		try_link_item(user)
		return

	if(marked_item == user.get_active_held_item())
		try_unlink_item(user)
		return

	try_recall_item(user)

/// If we don't have a marked item, attempts to mark the caster's held item.
/datum/action/spell/summonitem/proc/try_link_item(mob/living/caster)
	var/obj/item/potential_mark = caster.get_active_held_item()
	if(!potential_mark)
		if(caster.get_inactive_held_item())
			to_chat(caster, ("<span class='warning'>You must hold the desired item in your hands to mark it for recall!</span>"))
		else
			to_chat(caster, ("<span class='warning'>You aren't holding anything that can be marked for recall!</span>"))
		return FALSE

	var/link_message = ""
	if(potential_mark.item_flags & ABSTRACT)
		return FALSE
	if(SEND_SIGNAL(potential_mark, COMSIG_ITEM_MARK_RETRIEVAL, src, caster) & COMPONENT_BLOCK_MARK_RETRIEVAL)
		return FALSE
	if(HAS_TRAIT(potential_mark, TRAIT_NODROP))
		link_message += "Though it feels redundant... "

	link_message += "You mark [potential_mark] for recall."
	to_chat(caster, "<span class='notice'>[link_message]</span>")
	mark_item(potential_mark)
	return TRUE

/// If we have a marked item and it's in our hand, we will try to unlink it
/datum/action/spell/summonitem/proc/try_unlink_item(mob/living/caster)
	to_chat(caster, ("<span class='notice'>You begin removing the mark on [marked_item]...</span>"))
	if(!do_after(caster, 5 SECONDS, marked_item))
		to_chat(caster, ("<span class='notice'>You decide to keep [marked_item] marked.</span>"))
		return FALSE

	to_chat(caster, ("<span class='notice'>You remove the mark on [marked_item] to use elsewhere.</span>"))
	unmark_item()
	return TRUE

/// Recalls our marked item to the caster. May bring some unexpected things along.
/datum/action/spell/summonitem/proc/try_recall_item(mob/living/caster)
	var/obj/item_to_retrieve = marked_item

	if(item_to_retrieve.loc)
		// I don't want to know how someone could put something
		// inside itself but these are wizards so let's be safe
		var/infinite_recursion = 0

		// if it's in something, you get the whole thing.
		while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10)
			if(isitem(item_to_retrieve.loc))
				var/obj/item/mark_loc = item_to_retrieve.loc
				// Being able to summon abstract things because
				// your item happened to get placed there is a no-no
				if(mark_loc.item_flags & ABSTRACT)
					break

			//mjolnir is funky so it gets a bypass
			if(istype(item_to_retrieve.loc, /obj/structure/anchored_mjolnir))
				break

			// If its on someone, properly drop it
			if(ismob(item_to_retrieve.loc))
				var/mob/holding_mark = item_to_retrieve.loc

				// Items in silicons warp the whole silicon
				if(issilicon(holding_mark))
					holding_mark.loc.visible_message(("<span class='warning'>[holding_mark] suddenly disappears!</span>"))
					holding_mark.forceMove(caster.loc)
					holding_mark.loc.visible_message(("<span class='warning'>[holding_mark] suddenly appears!</span>"))
					item_to_retrieve = null
					break

				holding_mark.dropItemToGround(item_to_retrieve)

			else if(isobj(item_to_retrieve.loc))
				var/obj/retrieved_item = item_to_retrieve.loc
				// Can't bring anchored things
				if(retrieved_item.anchored)
					return
				// Edge cases for moving certain machinery...
				if(istype(retrieved_item, /obj/machinery/portable_atmospherics))
					var/obj/machinery/portable_atmospherics/atmos_item = retrieved_item
					atmos_item.disconnect()
					atmos_item.update_appearance()

				// Otherwise bring the whole thing with us
				item_to_retrieve = retrieved_item

			infinite_recursion += 1

	if(!item_to_retrieve)
		return

	item_to_retrieve.loc?.visible_message(("<span class='warning'>[item_to_retrieve] suddenly disappears!</span>"))

	if(isitem(item_to_retrieve) && caster.put_in_hands(item_to_retrieve))
		item_to_retrieve.loc.visible_message(("<span class='warning'>[item_to_retrieve] suddenly appears in [caster]'s hand!</span>"))
	else
		item_to_retrieve.forceMove(caster.drop_location())
		item_to_retrieve.loc.visible_message(("<span class='warning'>[item_to_retrieve] suddenly appears!</span>"))
	playsound(get_turf(item_to_retrieve), 'sound/magic/summonitems_generic.ogg', 50, TRUE)
