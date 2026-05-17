/datum/component/stash
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/stash_item
	var/list/stash_minds

/datum/component/stash/Initialize(list/stash_minds, atom/movable/stash_item)
	src.stash_item = stash_item
	src.stash_minds = islist(stash_minds) ? stash_minds : list(stash_minds)

	//No thing
	if(!isatom(stash_item) || !length(stash_minds) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE

	stash_item.forceMove(parent)

	RegisterSignal(stash_item, COMSIG_QDELETING, PROC_REF(stash_destroyed))
	RegisterSignal(stash_item, COMSIG_MOVABLE_MOVED, PROC_REF(stash_item_moved))
	for (var/datum/mind/mind in stash_minds)
		RegisterSignal(mind, COMSIG_QDELETING, PROC_REF(owner_deleted))
		RegisterSignal(mind, COMSIG_MIND_TRANSFER_TO, PROC_REF(transfer_mind))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(access_stash))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

	create_owner_icon(parent)

/datum/component/stash/Destroy(force, silent)
	if(!QDELETED(stash_item))
		UnregisterSignal(stash_item, COMSIG_QDELETING)
		UnregisterSignal(stash_item, COMSIG_MOVABLE_MOVED)
		//Drop the stash to the ground
		stash_item.forceMove(get_turf(stash_item))
	stash_item = null
	for (var/datum/mind/mind in stash_minds)
		mind.antag_stashes -= src
		UnregisterSignal(mind, COMSIG_QDELETING)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	// Clear the alt appearance
	var/atom/owner = parent
	owner.remove_alt_appearance("stash_overlay")
	. = ..()

/datum/component/stash/proc/create_owner_icon(atom/owner)
	var/image/overlay = image(icon = 'icons/obj/storage/backpack.dmi', icon_state = "satchel-flat", loc = owner)
	overlay.appearance_flags = RESET_ALPHA
	overlay.alpha = 160
	overlay.plane = HUD_PLANE
	owner.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/minds, "stash_overlay", overlay, stash_minds)

/datum/component/stash/proc/transfer_mind(datum/source, mob/old_mob, mob/new_mob)
	SIGNAL_HANDLER
	// Regenerate the stash icons when a mind changes mobs, to fix the alt appearances
	var/atom/owner = parent
	owner.remove_alt_appearance("stash_overlay")
	create_owner_icon(owner)

/datum/component/stash/proc/on_examine(datum/source, mob/viewer, list/examine_text)
	SIGNAL_HANDLER
	if (viewer?.mind in stash_minds)
		examine_text += span_notice("You have a stash hidden here! Use <b>Alt-Click</b> to access it.")

/datum/component/stash/proc/access_stash(datum/source, mob/user)
	SIGNAL_HANDLER
	// Do this asynchronously
	INVOKE_ASYNC(src, PROC_REF(try_access_stash), user)

/datum/component/stash/proc/try_access_stash(mob/user)
	//Not the owner of this stash
	if (!(user.mind in stash_minds))
		return
	to_chat(user, span_warning("You begin removing your stash from [parent]..."))
	if(!do_after(user, 5 SECONDS, parent))
		return
	to_chat(user, span_notice("You remove your stash from [parent]."))
	// Unregister this before moving the stash item
	UnregisterSignal(stash_item, COMSIG_MOVABLE_MOVED)
	//Put in hand
	stash_item.forceMove(get_turf(user))
	user.put_in_hands(stash_item)
	//Remove the stash thing
	UnregisterSignal(stash_item, COMSIG_QDELETING)
	stash_item = null
	//Stash is now used up
	qdel(src)

/datum/component/stash/proc/owner_deleted(datum/mind/source, force)
	SIGNAL_HANDLER
	var/atom/owner = parent
	source.antag_stashes -= src
	stash_minds -= source
	if (!length(stash_minds))
		qdel(src)
	else
		owner.remove_alt_appearance("stash_overlay")
		create_owner_icon(owner)

/datum/component/stash/proc/stash_destroyed(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/stash/proc/stash_item_moved(datum/source, atom/newLoc, dir)
	SIGNAL_HANDLER
	if (newLoc != parent)
		qdel(src)
