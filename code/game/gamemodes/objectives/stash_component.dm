/datum/component/stash
	dupe_mode = COMPONENT_DUPE_ALLOWED
	var/atom/movable/stash_item
	var/datum/mind/stash_owner

/datum/component/stash/Initialize(datum/mind/stash_owner, atom/movable/stash_item)
	src.stash_item = stash_item
	src.stash_owner = stash_owner

	//No thing
	if(!isatom(stash_item) || !istype(stash_owner) || !isatom(parent))
		return COMPONENT_INCOMPATIBLE

	stash_item.forceMove(parent)

	RegisterSignal(stash_item, COMSIG_PARENT_QDELETING, .proc/stash_destroyed)
	RegisterSignal(stash_owner, COMSIG_PARENT_QDELETING, .proc/owner_deleted)
	RegisterSignal(parent, COMSIG_CLICK_ALT, .proc/access_stash)

/datum/component/stash/Destroy(force, silent)
	if(stash_item)
		//Drop the stash to the ground
		stash_item.forceMove(get_turf(stash_item))
		UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
	if(stash_owner)
		UnregisterSignal(stash_owner, COMSIG_PARENT_QDELETING)
	UnregisterSignal(parent, COMSIG_CLICK_ALT)
	. = ..()

/datum/component/stash/proc/access_stash(datum/source, mob/user)
	//Not the owner of this stash
	if (user.mind != stash_owner)
		return
	to_chat(user, "<span class='warning'>You begin removing your stash from [parent]...</span>")
	if(!do_after(user, 5 SECONDS, TRUE, parent))
		return
	to_chat(user, "<span class='notice'>You remove your stash from [parent].</span>")
	//Put in hand
	stash_item.forceMove(get_turf(user))
	user.put_in_hands(stash_item)
	//Remove the stash thing
	stash_item = null
	UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
	//Stash is now used up
	qdel(src)

/datum/component/stash/proc/owner_deleted(datum/source, force)
	stash_owner = null
	qdel(src)

/datum/component/stash/proc/stash_destroyed(datum/source, force)
	stash_item = null
	UnregisterSignal(stash_item, COMSIG_PARENT_QDELETING)
