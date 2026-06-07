/datum/action/spell/conjure_item/invisible_box
	name = "Invisible Box"
	desc = "The mime's performance transmutates a box into physical reality."
	background_icon_state = "bg_mime"
	button_icon = 'icons/hud/actions/actions_mime.dmi'
	button_icon_state = "invisible_box"
	check_flags = AB_CHECK_CONSCIOUS|AB_CHECK_HANDS_BLOCKED
	sound = null

	school = SCHOOL_MIME
	cooldown_time = 30 SECONDS
	invocation = "Someone does a weird gesture." // Overriden in before cast
	invocation_self_message = ("<span class='notice'>You conjure up an invisible box, large enough to store a few things.</span>")
	invocation_type = INVOCATION_EMOTE

	spell_requirements = SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_MIME_VOW
	antimagic_flags = NONE
	spell_max_level = 1

	delete_old = FALSE
	item_type = /obj/item/storage/box/mime
	/// How long boxes last before going away
	var/box_lifespan = 50 SECONDS

/datum/action/spell/conjure_item/invisible_box/pre_cast(mob/user, atom/target)
	. = ..()
	invocation = ("<span class='notice'><b>[user]</b> moves [user.p_their()] hands in the shape of a cube, pressing a box out of the air.</span>")

/datum/action/spell/conjure_item/invisible_box/make_item()
	. = ..()
	var/obj/item/made_box = .
	made_box.alpha = 255
	addtimer(CALLBACK(src, PROC_REF(cleanup_box), made_box), box_lifespan)

/// Callback that gets rid out of box and removes the weakref from our list
/datum/action/spell/conjure_item/invisible_box/proc/cleanup_box(obj/item/storage/box/box)
	if(QDELETED(box) || !istype(box))
		return

	box.emptyStorage()
	LAZYREMOVE(item_refs, WEAKREF(box))
	qdel(box)
