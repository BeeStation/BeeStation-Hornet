SUBSYSTEM_DEF(client_vision)
	name = "Client Vision"
	flags = SS_NO_INIT | SS_NO_FIRE

	/// list of /datum/client_vision_holder datum types
	var/list/client_vision_holders = list()

	/// a quick key list for on mob login
	var/list/vision_keys_by_mob = list()
	/// a quick key list for on mob login (mob login checks mind too)
	var/list/vision_keys_by_mind = list()

/datum/controller/subsystem/client_vision/Recover()
	client_vision_holders = SSclient_vision.client_vision_holders
	vision_keys_by_mob = SSclient_vision.vision_keys_by_mob
	vision_keys_by_mind = SSclient_vision.vision_keys_by_mind

//-------------------------------------------------------------------------------
// Important 8 procs ahead
// You don't have to care other procs because most of other procs and systems are internal use only
// Coders only have to use these 8 procs

/// adds an image to a key group. You must call `cut_client_images()` for qdel.
/// * [is_shared_image]: Set this TRUE if an image is in multiple holders.
/datum/controller/subsystem/client_vision/proc/manual_stack_client_images(clivis_key, client_images, is_shared_image = FALSE)
	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		clivis_holder = new
		client_vision_holders[clivis_key] = clivis_holder

	if(is_shared_image)
		clivis_holder.shared_bound_images += client_images // list works
	else
		clivis_holder.bound_images += client_images // list works
	clivis_holder._realize_to_validated(client_images, is_shared_image = is_shared_image)

/// You don't have to call "cut_client_images()" or "nullify_client_vision_holder()" yourself
/datum/controller/subsystem/client_vision/proc/safe_stack_client_images(datum/source, vision_key, vision_image, cve_flags)
	source.AddElement(/datum/element/client_vision_element, vision_key, vision_image, cve_flags)
	/* NOTE:
			This proc is nothing different from doing AddElement(), BUT..
			Using AddElement() proc will not be consistent for how we should use 'SSclient_vision'
			This is why this proc exists even if this is 100% identical to AddElement()
	*/

/// removes added image from a key group.
/// * [is_shared_image]: Set this TRUE if an image is in multiple holders.
/datum/controller/subsystem/client_vision/proc/cut_client_images(clivis_key, client_images, is_shared_image = FALSE)
	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		return

	if(is_shared_image)
		clivis_holder.shared_bound_images -= client_images // list works
	else
		clivis_holder.bound_images -= client_images // list works
	clivis_holder._disappear_from_validated(client_images)

/// radical version of cut_client_images() - delete a group
/// usually done when an image group is dedicated for a short duration or personal.
/// Avoid using this unless a client image group is NOT common
/datum/controller/subsystem/client_vision/proc/nullify_client_vision_holder(clivis_key)
	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		return

	for(var/each_mind in clivis_holder.keyheld_minds)
		revoke_vision_key_from_mind(clivis_key, each_mind, force = TRUE)
	for(var/each_mob in clivis_holder.keyheld_mobs)
		revoke_vision_key_from_mob(clivis_key, each_mob, force = TRUE)

	// NOTE: please make sure if images are not referenced
	clivis_holder.bound_images.Cut()
	clivis_holder.shared_bound_images.Cut()
	client_vision_holders -= clivis_key
	qdel(clivis_holder)

/// Makes a mob can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call revoke_vision_key_from_mob() proc to handle this correctly.
/datum/controller/subsystem/client_vision/proc/grant_vision_key_to_mob(clivis_key, mob/seer_mob)
	if(!ismob(seer_mob))
		var/errortype
		if(!seer_mob) errortype = "- type is null"
		else if(istype(seer_mob, /datum/mind)) errortype = "(type:[seer_mob.type]) - You called a wrong proc!"
		else errortype = "(type:[seer_mob.type])"

		CRASH("grant_vision_key_to_mob() has taken non-mob type [errortype]")

	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		clivis_holder = new
		client_vision_holders[clivis_key] = clivis_holder

	if(isnull(clivis_holder.keyheld_mobs[seer_mob]))
		clivis_holder.keyheld_mobs[seer_mob] = 0

	var/already_see = clivis_holder.keyheld_mobs[seer_mob]
	clivis_holder.keyheld_mobs[seer_mob] += 1

	if(!already_see)
		LAZYINITLIST(vision_keys_by_mob[seer_mob])
		vision_keys_by_mob[seer_mob] += clivis_key

	if(already_see || (seer_mob.mind && clivis_holder.keyheld_minds[seer_mob.mind]) || !seer_mob.client)
		return
	seer_mob.client.images += clivis_holder.bound_images
	seer_mob.client.images |= clivis_holder.shared_bound_images

/// Makes a mind can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call revoke_vision_key_from_mind() proc to handle this correctly.
/datum/controller/subsystem/client_vision/proc/grant_vision_key_to_mind(clivis_key, datum/mind/seer_mind)
	if(!istype(seer_mind, /datum/mind))
		var/errortype
		if(!seer_mind) errortype = "- type is null"
		else if(ismob(seer_mind)) errortype = "(type:[seer_mind.type]) - You called a wrong proc!"
		else errortype = "(type:[seer_mind.type])"

		CRASH("grant_vision_key_to_mind() has taken non-mind type [errortype]")

	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		clivis_holder = new
		client_vision_holders[clivis_key] = clivis_holder

	if(isnull(clivis_holder.keyheld_minds[seer_mind]))
		clivis_holder.keyheld_minds[seer_mind] = 0

	var/already_see = clivis_holder.keyheld_minds[seer_mind]
	clivis_holder.keyheld_minds[seer_mind] += 1

	if(!already_see)
		LAZYINITLIST(vision_keys_by_mind[seer_mind])
		vision_keys_by_mind[seer_mind] += clivis_key

	if(already_see || (seer_mind.current && clivis_holder.keyheld_mobs[seer_mind.current]) || !seer_mind?.current?.client)
		return
	seer_mind.current.client.images += clivis_holder.bound_images
	seer_mind.current.client.images |= clivis_holder.shared_bound_images

/// disqualify a mob against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/controller/subsystem/client_vision/proc/revoke_vision_key_from_mob(clivis_key, mob/seer_mob, force = FALSE)
	if(!ismob(seer_mob))
		var/errortype
		if(!seer_mob) errortype = "- type is null"
		else if(istype(seer_mob, /datum/mind)) errortype = "(type:[seer_mob.type]) - You called a wrong proc!"
		else errortype = "(type:[seer_mob.type])"

		CRASH("revoke_vision_key_from_mob() has taken non-mob type [errortype]")

	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		return

	if(!clivis_holder.keyheld_mobs[seer_mob])
		// CRASH("Called revoke_vision_key_from_mob([clivis_key], [seer_mob]), but they don't have it already.")
		// do not call this proc multiple times. If you should, you're doing something wrong.
		return // currently CRASH() disabled because dropped() is broken
	if(!force)
		clivis_holder.keyheld_mobs[seer_mob] -= 1
		if(clivis_holder.keyheld_mobs[seer_mob])
			return

	clivis_holder.keyheld_mobs -= seer_mob
	vision_keys_by_mob[seer_mob] -= clivis_key
	if(!length(vision_keys_by_mob[seer_mob]))
		vision_keys_by_mob -= seer_mob
	if(clivis_holder.keyheld_minds[seer_mob.mind])
		return

	if(!seer_mob.client)
		return
	seer_mob.client.images -= clivis_holder.bound_images
	if(length(clivis_holder.shared_bound_images))
		seer_mob.client.images -= clivis_holder.shared_bound_images
		_refresh_shared_client_images(seer_mob)

/// disqualify a mind against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/controller/subsystem/client_vision/proc/revoke_vision_key_from_mind(clivis_key, datum/mind/seer_mind, force = FALSE)
	if(!istype(seer_mind, /datum/mind))
		var/errortype
		if(!seer_mind) errortype = "- type is null"
		else if(ismob(seer_mind)) errortype = "(type:[seer_mind.type]) - You called a wrong proc!"
		else errortype = "(type:[seer_mind.type])"

		CRASH("revoke_vision_key_from_mind() has taken non-mind type [errortype]")

	var/datum/client_vision_holder/clivis_holder = client_vision_holders[clivis_key]
	if(!clivis_holder)
		return

	if(!clivis_holder.keyheld_minds[seer_mind])
		// CRASH("Called revoke_vision_key_from_mind([clivis_key], [seer_mind.name]), but they don't have it already.")
		// do not call this proc multiple times. If you should, you're doing something wrong.
		return // currently CRASH() disabled because dropped() is broken

	if(!force)
		clivis_holder.keyheld_minds[seer_mind] -= 1
		if(clivis_holder.keyheld_minds[seer_mind])
			return

	clivis_holder.keyheld_minds -= seer_mind
	vision_keys_by_mind[seer_mind] -= clivis_key
	if(!length(vision_keys_by_mind[seer_mind]))
		vision_keys_by_mind -= seer_mind
	if(seer_mind.current && clivis_holder.keyheld_mobs[seer_mind.current])
		return

	if(!seer_mind.current.client)
		return
	seer_mind.current.client.images -= clivis_holder.bound_images
	if(length(clivis_holder.shared_bound_images))
		seer_mind.current.client.images -= clivis_holder.shared_bound_images
		_refresh_shared_client_images(seer_mind.current)

//-------------------------------------------------------------------------------
// internal use procs only
/// this actually refreshes every client images - aghost or getting a new mob will call this
/datum/controller/subsystem/client_vision/proc/on_mob_log_on(mob/seer_mob)
	var/list/already_injected = list()
	for(var/each_clivis_key in vision_keys_by_mob[seer_mob])
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		seer_mob.client.images += clivis_holder.bound_images
		seer_mob.client.images |= clivis_holder.shared_bound_images
		already_injected[each_clivis_key] = TRUE
	if(!seer_mob.mind)
		return
	for(var/each_clivis_key in vision_keys_by_mind[seer_mob.mind])
		if(already_injected[each_clivis_key])
			continue
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		seer_mob.client.images += clivis_holder.bound_images
		seer_mob.client.images |= clivis_holder.shared_bound_images

/datum/controller/subsystem/client_vision/proc/on_mob_destroy(mob/seer_mob)
	for(var/each_clivis_key in vision_keys_by_mob[seer_mob])
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		clivis_holder.keyheld_mobs -= seer_mob
	vision_keys_by_mob -= seer_mob

/datum/controller/subsystem/client_vision/proc/on_mind_destroy(datum/mind/seer_mind)
	if(!istype(seer_mind, /datum/mind))
		CRASH("proc 'on_mind_destroy' has taken non-mind")
	for(var/each_clivis_key in vision_keys_by_mind[seer_mind])
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		clivis_holder.keyheld_minds -= seer_mind
		// there's no way to track a mind's client.
	vision_keys_by_mind -= seer_mind

/// something was removed, and we check full shared images
/datum/controller/subsystem/client_vision/proc/_refresh_shared_client_images(mob/seer_mob)
	PRIVATE_PROC(TRUE)
	var/list/already_injected = list()
	for(var/each_clivis_key in vision_keys_by_mob[seer_mob])
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		seer_mob.client.images |= clivis_holder.shared_bound_images
		already_injected[each_clivis_key] = TRUE
	if(!seer_mob.mind)
		return
	for(var/each_clivis_key in vision_keys_by_mind[seer_mob.mind])
		if(already_injected[each_clivis_key])
			continue
		var/datum/client_vision_holder/clivis_holder = client_vision_holders[each_clivis_key]
		seer_mob.client.images |= clivis_holder.shared_bound_images

//-------------------------------------------------------------------------------

//-------------------------------------------------------------------------------
// important datum to handle this system
/datum/client_vision_holder
	/// list of images for a group
	var/list/bound_images = list()
	/// identical to 'bound_images' but we do this |= instead of += because it can exist in multiple groups
	var/list/shared_bound_images = list()

	/// mobs who can see that
	var/list/keyheld_mobs = list()
	/// minds who can see that
	var/list/keyheld_minds = list()


/// newly created images should be automatically injected to those one who can see that already.
/// Typically, you don't call this proc directly. Use `SSclient_vision.manual_stack_client_images()`
/datum/client_vision_holder/proc/_realize_to_validated(client_images, is_shared_image = FALSE)
	var/list/applied_clients = list()
	for(var/mob/each_mob as anything in keyheld_mobs)
		if(!each_mob.client)
			continue
		if(is_shared_image)
			each_mob.client.images |= client_images
		else
			each_mob.client.images += client_images
		applied_clients[each_mob.client] = TRUE

	for(var/datum/mind/each_mind as anything in keyheld_minds)
		var/client/cli = each_mind.current?.client
		if(!cli || applied_clients[cli])
			continue
		if(is_shared_image)
			cli.images |= client_images
		else
			cli.images += client_images

/// a thing is destroyed or no longer has its own special image
/// Typically, you don't call this proc directly. Use `SSclient_vision.cut_client_images()`
/datum/client_vision_holder/proc/_disappear_from_validated(client_images)
	var/list/applied_clients = list()
	for(var/mob/each_mob as anything in keyheld_mobs)
		if(!each_mob.client)
			continue
		each_mob.client.images -= client_images
		applied_clients[each_mob.client] = TRUE

	for(var/datum/mind/each_mind as anything in keyheld_minds)
		var/client/cli = each_mind.current?.client
		if(!cli || applied_clients[cli])
			continue
		cli.images -= client_images

/* < Quick documentation about how to use GLOB.cimg_controller >
		You only care 7 procs.
			* SSclient_vision.manual_stack_client_images(cimg_key, client_images, is_unique_image = FALSE)
			* SSclient_vision.cut_client_images(cimg_key, client_images, is_shared_image = FALSE)
			* SSclient_vision.nullify_client_vision_holder(cimg_key)
			* SSclient_vision.grant_vision_key_to_mob(cimg_key, mob/cimg_mob)
			* SSclient_vision.grant_vision_key_to_mind(cimg_key, datum/mind/cimg_mind)
			* SSclient_vision.revoke_vision_key_from_mob(cimg_key, mob/cimg_mob)
			* SSclient_vision.revoke_vision_key_from_mind(cimg_key, datum/mind/cimg_mind)
		You don't have to care other procs.

	------------------------
	[To stuff that will hold client images]
	* SSclient_vision.manual_stack_client_images(cimg_key, client_images, is_unique_image = FALSE)
		Adds a client image to the system
		"is_unique_image = TRUE" is necessary when an image is going to be stored in multiple key groups.

		i.e.)
			SSclient_vision.manual_stack_client_images(KEY_CULT, a_cult_image, is_shared_image = TRUE)
			SSclient_vision.manual_stack_client_images(KEY_CLICK_CULT, a_cult_image, is_shared_image = TRUE)
			SSclient_vision.manual_stack_client_images(KEY_CHAPLAIN, a_cult_image, is_shared_image = TRUE)

		a_cult_image will be given to a client multiple times when they have KEY_CULT, KEY_CLICK_CULT, KEY_CHAPLAIN at the same time
		This is why "is_shared_image = TRUE" is necessary

	* SSclient_vision.cut_client_images(cimg_key, client_images, is_shared_image = FALSE)
		Removes a client image from the system
		! Do not forget "var/image/image = null"
		! Do not forget to set "is_shared_image = TRUE" if the image was given with "is_shared_image = TRUE"

	* SSclient_vision.nullify_client_vision_holder(cimg_key)
		Removes a cimg holder entirely from the system.
		If things are common (like holy tiles), this should be avoided
		If things are only dedicated to a single person, you may use this

	------------------------
	[To mobs/mind that need to see client images]
	* SSclient_vision.grant_vision_key_to_mob(cimg_key, mob/cimg_mob)
	* SSclient_vision.grant_vision_key_to_mind(cimg_key, datum/mind/cimg_mind)
		Give a mob/mind an ability to see images in "cimg_key" group
		Validation is stackable, so be careful if you're going to grant it multiple times
		Both(mob/mind) does the same thing, but mob/mind difference.

	* SSclient_vision.revoke_vision_key_from_mob(cimg_key, mob/cimg_mob)
	* SSclient_vision.revoke_vision_key_from_mind(cimg_key, datum/mind/cimg_mind)
		Removes a mob/mind's ability to see images in "cimg_key" group
		Validation is stackable, so they'll be still capable of seeing stuff when validation is given multiple times.
		Both(mob/mind) does the same thing, but mob/mind difference.


		< What's best to use between mob and mind? >
			SSclient_vision.grant_vision_key_to_mind("heretic_pierces", heretic_mind)
		You want heretics have this always even if their body is changed (likely brain transplant)
		aghost will still be capable of seeing stuff, because their mind is validated and ghost has that mind.

			SSclient_vision.grant_vision_key_to_mob("heretic_pierces", target_mob)
		If a curator wears goggles that can see "heretic_pierces", we want to use this proc instead of mind.
		aghost will rip off the images because they become a ghost, but their aghost is not validated.
		once aghost goes back to their mob, they'll see the stuff again.
*/
