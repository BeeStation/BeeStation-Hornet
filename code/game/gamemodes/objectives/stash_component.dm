/datum/component/stash
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/stash_item
	var/list/stash_minds

	var/image/overlay
	var/cimg_key

/datum/component/stash/Initialize(list/stash_minds, atom/movable/stash_item)
	src.stash_item = stash_item
	if(!islist(stash_minds))
		stash_minds = list(stash_minds) // list-ify

	//No thing
	if(!isatom(stash_item) || !length(stash_minds) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE

	stash_item.forceMove(parent)

	RegisterSignal(stash_item, COMSIG_PARENT_QDELETING, PROC_REF(stash_destroyed))
	RegisterSignal(stash_item, COMSIG_MOVABLE_MOVED, PROC_REF(stash_item_moved))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(access_stash))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	create_owner_icon(parent)
	for (var/datum/mind/mind in stash_minds)
		add_membership(mind)

/datum/component/stash/Destroy(force, silent)
	if(!QDELETED(stash_item))
		UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
		UnregisterSignal(stash_item, COMSIG_MOVABLE_MOVED)
		//Drop the stash to the ground
		stash_item.forceMove(get_turf(stash_item))
	stash_item = null
	for (var/datum/mind/mind in stash_minds)
		remove_membership(mind)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	// Clear the alt appearance
	GLOB.cimg_controller.cut_client_images(cimg_key, overlay)
	overlay = null
	. = ..()

/datum/component/stash/proc/create_owner_icon(atom/owner)
	if(overlay)
		CRASH("stash owner icon is already created")
	cimg_key = "stash_[FAST_REF(src)]"
	overlay = image(icon = 'icons/obj/storage/backpack.dmi', icon_state = "satchel-flat", loc = owner)
	overlay.appearance_flags = RESET_ALPHA
	overlay.alpha = 160
	overlay.plane = HUD_PLANE
	GLOB.cimg_controller.stack_client_images(cimg_key, overlay)

/datum/component/stash/proc/on_examine(datum/source, mob/viewer, list/examine_text)
	SIGNAL_HANDLER
	if (viewer?.mind in stash_minds)
		examine_text += "<span class='notice'>You have a stash hidden here! Use <b>Alt-Click</b> to access it.</span>"

/datum/component/stash/proc/access_stash(datum/source, mob/user)
	SIGNAL_HANDLER
	// Do this asynchronously
	INVOKE_ASYNC(src, PROC_REF(try_access_stash), user)

/datum/component/stash/proc/try_access_stash(mob/user)
	//Not the owner of this stash
	if (!(user.mind in stash_minds))
		return
	to_chat(user, "<span class='warning'>You begin removing your stash from [parent]...</span>")
	if(!do_after(user, 5 SECONDS, parent))
		return
	to_chat(user, "<span class='notice'>You remove your stash from [parent].</span>")
	// Unregister this before moving the stash item
	UnregisterSignal(stash_item, COMSIG_MOVABLE_MOVED)
	//Put in hand
	stash_item.forceMove(get_turf(user))
	user.put_in_hands(stash_item)
	//Remove the stash thing
	UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
	stash_item = null
	//Stash is now used up
	qdel(src)

/datum/component/stash/proc/owner_deleted(datum/mind/source, force)
	SIGNAL_HANDLER
	remove_membership(source)
	if (!length(stash_minds))
		qdel(src)

/datum/component/stash/proc/add_membership(datum/mind/mind)
	if(src in mind.antag_stashes)
		CRASH("Already a member of the stash")
	LAZYINITLIST(stash_minds)
	GLOB.cimg_controller.validate_mind(cimg_key, stash_owner)
	mind.antag_stashes += src
	stash_minds += mind
	RegisterSignal(mind, COMSIG_PARENT_QDELETING, PROC_REF(owner_deleted))

/datum/component/stash/proc/remove_membership(datum/mind/mind)
	GLOB.cimg_controller.disqualify_mind(cimg_key, mind)
	mind.antag_stashes -= src
	stash_minds -= mind
	UnregisterSignal(mind, COMSIG_PARENT_QDELETING)

/datum/component/stash/proc/stash_destroyed(datum/source, force)
	SIGNAL_HANDLER
	qdel(src)

/datum/component/stash/proc/stash_item_moved(datum/source, atom/newLoc, dir)
	SIGNAL_HANDLER
	if (newLoc != parent)
		qdel(src)
