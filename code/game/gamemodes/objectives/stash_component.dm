/datum/component/stash
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/stash_item
	var/datum/mind/stash_owner

	var/image/overlay
	var/cimg_key

/datum/component/stash/Initialize(datum/mind/stash_owner, atom/movable/stash_item)
	src.stash_item = stash_item
	src.stash_owner = stash_owner

	//No thing
	if(!isatom(stash_item) || !istype(stash_owner) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE

	stash_item.forceMove(parent)

	RegisterSignal(stash_item, COMSIG_PARENT_QDELETING, PROC_REF(stash_destroyed))
	RegisterSignal(stash_owner, COMSIG_PARENT_QDELETING, PROC_REF(owner_deleted))
	RegisterSignal(parent, COMSIG_CLICK_ALT, PROC_REF(access_stash))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(on_examine))

	create_owner_icon(parent)

/datum/component/stash/Destroy(force, silent)
	if(stash_item)
		//Drop the stash to the ground
		stash_item.forceMove(get_turf(stash_item))
		UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
	if(stash_owner)
		UnregisterSignal(stash_owner, COMSIG_PARENT_QDELETING)
		GLOB.cimg_controller.disqualify_mind(cimg_key, stash_owner)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	// Clear the stash client image
	GLOB.cimg_controller.cut_client_images(cimg_key, overlay)
	. = ..()

/datum/component/stash/proc/create_owner_icon(atom/owner)
	cimg_key = "stash_[FAST_REF(src)]"
	overlay = image(icon = 'icons/obj/storage/backpack.dmi', icon_state = "satchel-flat", loc = owner)
	overlay.appearance_flags = RESET_ALPHA
	overlay.alpha = 160
	overlay.plane = HUD_PLANE
	GLOB.cimg_controller.stack_client_images(cimg_key, overlay)
	if(stash_owner)
		GLOB.cimg_controller.validate_mind(cimg_key, stash_owner)

/datum/component/stash/proc/on_examine(datum/source, mob/viewer, list/examine_text)
	SIGNAL_HANDLER
	if (viewer?.mind == stash_owner)
		examine_text += "<span class='notice'>You have a stash hidden here! Use <b>Alt-Click</b> to access it.</span>"

/datum/component/stash/proc/access_stash(datum/source, mob/user)
	SIGNAL_HANDLER
	// Do this asynchronously
	INVOKE_ASYNC(src, PROC_REF(try_access_stash), user)

/datum/component/stash/proc/try_access_stash(mob/user)
	//Not the owner of this stash
	if (user.mind != stash_owner)
		return
	to_chat(user, "<span class='warning'>You begin removing your stash from [parent]...</span>")
	if(!do_after(user, 5 SECONDS, parent))
		return
	to_chat(user, "<span class='notice'>You remove your stash from [parent].</span>")
	//Put in hand
	stash_item.forceMove(get_turf(user))
	user.put_in_hands(stash_item)
	//Remove the stash thing
	UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
	stash_item = null
	//Stash is now used up
	qdel(src)

/datum/component/stash/proc/owner_deleted(datum/source, force)
	SIGNAL_HANDLER
	stash_owner.antag_stash = null
	stash_owner = null
	qdel(src)

/datum/component/stash/proc/stash_destroyed(datum/source, force)
	SIGNAL_HANDLER
	stash_item = null
	if (stash_owner)
		stash_owner.antag_stash = null
	UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
