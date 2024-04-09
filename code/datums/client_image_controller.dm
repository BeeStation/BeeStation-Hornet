GLOBAL_DATUM_INIT(cimg_controller, /datum/cimg_controller, new)

/* < Quick documentation about how to use GLOB.cimg_controller >
		You only care 6 procs.
			* GLOB.cimg_controller.stack_client_images(cimg_key, client_images, is_unique_image = FALSE)
			* GLOB.cimg_controller.cut_client_images(cimg_key, client_images, is_shared_image = FALSE)
			* GLOB.cimg_controller.validate_mob(cimg_key, mob/cimg_mob)
			* GLOB.cimg_controller.validate_mind(cimg_key, datum/mind/cimg_mind)
			* GLOB.cimg_controller.disqualify_mob(cimg_key, mob/cimg_mob)
			* GLOB.cimg_controller.disqualify_mind(cimg_key, datum/mind/cimg_mind)
		You don't have to care other procs.


	[To stuff that will hold client images]
	* GLOB.cimg_controller.stack_client_images(cimg_key, client_images, is_unique_image = FALSE)
		Adds a client image to the system
		"is_unique_image = TRUE" is necessary when an image is going to be stored in multiple key groups.

		i.e.)
			GLOB.cimg_controller.stack_client_images(KEY_CULT, a_cult_image, is_shared_image = TRUE)
			GLOB.cimg_controller.stack_client_images(KEY_CLICK_CULT, a_cult_image, is_shared_image = TRUE)
			GLOB.cimg_controller.stack_client_images(KEY_CHAPLAIN, a_cult_image, is_shared_image = TRUE)

		a_cult_image will be given to a client multiple times when they have KEY_CULT, KEY_CLICK_CULT, KEY_CHAPLAIN at the same time
		This is why "is_shared_image = TRUE" is necessary

	* GLOB.cimg_controller.cut_client_images(cimg_key, client_images, is_shared_image = FALSE)
		Removes a client image from the system
		! Do not forget "var/image/image = null"
		! Do not forget to set "is_shared_image = TRUE" if the image was given with "is_shared_image = TRUE"


	[To mobs/mind that need to see client images]
	* GLOB.cimg_controller.validate_mob(cimg_key, mob/cimg_mob)
	* GLOB.cimg_controller.validate_mind(cimg_key, datum/mind/cimg_mind)
		Give a mob/mind an ability to see images in "cimg_key" group
		Validation is stackable, so be careful if you're going to grant it multiple times
		Both(mob/mind) does the same thing, but mob/mind difference.

	* GLOB.cimg_controller.disqualify_mob(cimg_key, mob/cimg_mob)
	* GLOB.cimg_controller.disqualify_mind(cimg_key, datum/mind/cimg_mind)
		Removes a mob/mind's ability to see images in "cimg_key" group
		Validation is stackable, so they'll be still capable of seeing stuff when validation is given multiple times.
		Both(mob/mind) does the same thing, but mob/mind difference.


		< What's best to use between mob and mind? >
			GLOB.cimg_controller.validate_mind("heretic_pierces", heretic_mind)
		You want heretics have this always even if their body is changed (likely brain transplant)
		aghost will still be capable of seeing stuff, because their mind is validated and ghost has that mind.

			GLOB.cimg_controller.validate_mob("heretic_pierces", target_mob)
		If a curator wears goggles that can see "heretic_pierces", we want to use this proc instead of mind.
		aghost will rip off the images because they become a ghost, but their aghost is not validated.
		once aghost goes back to their mob, they'll see the stuff again.
*/

/datum/cimg_controller
	/// list of /datum/cimg_holder datum types
	var/list/cimg_holders = list()

	/// a quick key list for on mob login
	var/list/cimgkey_by_mob = list()
	/// a quick key list for on mob login (mob login checks mind too)
	var/list/cimgkey_by_mind = list()

/datum/cimg_holder
	/// list of images for a group
	var/list/bound_images = list()
	/// identical to 'bound_images' but we do this |= instead of += because it can exist in multiple groups
	var/list/shared_bound_images = list()

	/// mobs who can see that
	var/list/valid_mobs = list()
	/// minds who can see that
	var/list/valid_minds = list()

/// adds an image to a key group. You must call `cut_client_images()` for qdel.
/// * [is_shared_image]: Set this TRUE if an image is in multiple holders.
/datum/cimg_controller/proc/stack_client_images(cimg_key, client_images, is_shared_image = FALSE)
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		cimg_holder = new
		cimg_holders[cimg_key] = cimg_holder

	if(is_shared_image)
		cimg_holder.shared_bound_images += client_images // list works
	else
		cimg_holder.bound_images += client_images // list works
	cimg_holder._realize_to_validated(client_images, is_shared_image = is_shared_image)

/// removes added image from a key group.
/// * [is_shared_image]: Set this TRUE if an image is in multiple holders.
/datum/cimg_controller/proc/cut_client_images(cimg_key, client_images, is_shared_image = FALSE)
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	if(is_shared_image)
		cimg_holder.shared_bound_images -= client_images // list works
	else
		cimg_holder.bound_images -= client_images // list works
	cimg_holder._disappear_from_validated(client_images)

/// this actually refreshes every client images - aghost or getting a new mob will call this
/datum/cimg_controller/proc/on_mob_log_on(mob/cimg_mob)
	var/list/already_injected = list()
	for(var/each_cimgkey in cimgkey_by_mob[cimg_mob])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_mob.client.images += cimg_holder.bound_images
		cimg_mob.client.images |= cimg_holder.shared_bound_images
		already_injected[each_cimgkey] = TRUE
	if(!cimg_mob.mind)
		return
	for(var/each_cimgkey in cimgkey_by_mind[cimg_mob.mind])
		if(already_injected[each_cimgkey])
			continue
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_mob.client.images += cimg_holder.bound_images
		cimg_mob.client.images |= cimg_holder.shared_bound_images

/// something was removed, and we check full shared images
/datum/cimg_controller/proc/_refresh_shared_client_images(mob/cimg_mob)
	var/list/already_injected = list()
	for(var/each_cimgkey in cimgkey_by_mob[cimg_mob])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_mob.client.images |= cimg_holder.shared_bound_images
		already_injected[each_cimgkey] = TRUE
	if(!cimg_mob.mind)
		return
	for(var/each_cimgkey in cimgkey_by_mind[cimg_mob.mind])
		if(already_injected[each_cimgkey])
			continue
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_mob.client.images |= cimg_holder.shared_bound_images

/datum/cimg_controller/proc/on_mob_destroy(mob/cimg_mob)
	for(var/each_cimgkey in cimgkey_by_mob[cimg_mob])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_holder.valid_mobs -= cimg_mob
		if(cimg_mob.client)
			cimg_mob.client.images -= cimg_holder.bound_images
			cimg_mob.client.images -= cimg_holder.shared_bound_images
	cimgkey_by_mob -= cimg_mob

/datum/cimg_controller/proc/on_mind_destroy(datum/mind/cimg_mind)
	if(!istype(cimg_mind, /datum/mind))
		CRASH("proc 'on_mind_destroy' has taken non-mind")
	for(var/each_cimgkey in cimgkey_by_mind[cimg_mind])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_holder.valid_minds -= cimg_mind
		// there's no way to track a mind's client.
	cimgkey_by_mind -= cimg_mind

/// Makes a mob can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call disqualify_mob() proc to handle this correctly.
/datum/cimg_controller/proc/validate_mob(cimg_key, mob/cimg_mob)
	if(!cimg_mob)
		return
	if(!ismob(cimg_mob))
		if(istype(cimg_mob, /datum/mind))
			CRASH("validate_mob() has taken a mind. You called a wrong proc.")
		CRASH("validate_mob() has taken non-mob")

	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		cimg_holder = new
		cimg_holders[cimg_key] = cimg_holder

	if(isnull(cimg_holder.valid_mobs[cimg_mob]))
		cimg_holder.valid_mobs[cimg_mob] = 0

	var/already_see = cimg_holder.valid_mobs[cimg_mob]
	cimg_holder.valid_mobs[cimg_mob] += 1

	if(!already_see)
		LAZYINITLIST(cimgkey_by_mob[cimg_mob])
		cimgkey_by_mob[cimg_mob] += cimg_key

	if(already_see || (cimg_mob.mind && cimg_holder.valid_minds[cimg_mob.mind]) || !cimg_mob.client)
		return
	cimg_mob.client.images += cimg_holder.bound_images
	cimg_mob.client.images |= cimg_holder.shared_bound_images

/// Makes a mind can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call disqualify_mind() proc to handle this correctly.
/datum/cimg_controller/proc/validate_mind(cimg_key, datum/mind/cimg_mind)
	if(!cimg_mind)
		return
	if(!istype(cimg_mind, /datum/mind))
		if(ismob(cimg_mind))
			CRASH("validate_mind() has taken a mob. You called a wrong proc.")
		CRASH("validate_mind() has taken non-mind")

	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		cimg_holder = new
		cimg_holders[cimg_key] = cimg_holder

	if(isnull(cimg_holder.valid_minds[cimg_mind]))
		cimg_holder.valid_minds[cimg_mind] = 0

	var/already_see = cimg_holder.valid_minds[cimg_mind]
	cimg_holder.valid_minds[cimg_mind] += 1

	if(!already_see)
		LAZYINITLIST(cimgkey_by_mind[cimg_mind])
		cimgkey_by_mind[cimg_mind] += cimg_key

	if(already_see || (cimg_mind.current && cimg_holder.valid_mobs[cimg_mind.current]) || !cimg_mind?.current?.client)
		return
	cimg_mind.current.client.images += cimg_holder.bound_images
	cimg_mind.current.client.images |= cimg_holder.shared_bound_images

/// disqualify a mob against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/cimg_controller/proc/disqualify_mob(cimg_key, mob/cimg_mob)
	if(!cimg_mob)
		return
	if(!ismob(cimg_mob))
		if(istype(cimg_mob, /datum/mind))
			CRASH("disqualify_mob() has taken a mind. You called a wrong proc.")
		CRASH("disqualify_mob() has taken non-mob")
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	if(!cimg_holder.valid_mobs[cimg_mob])
		// CRASH("Called disqualify_mob([cimg_key], [cimg_mob]), but they don't have it already.")
		// do not call this proc multiple times. If you should, you're doing something wrong.
		return // currently CRASH() disabled because dropped() is broken
	cimg_holder.valid_mobs[cimg_mob] -= 1
	if(cimg_holder.valid_mobs[cimg_mob])
		return
	cimg_holder.valid_mobs -= cimg_mob
	cimgkey_by_mob[cimg_mob] -= cimg_key
	if(!length(cimgkey_by_mob[cimg_mob]))
		cimgkey_by_mob -= cimg_mob
	if(cimg_holder.valid_minds[cimg_mob.mind])
		return

	if(!cimg_mob.client)
		return
	cimg_mob.client.images -= cimg_holder.bound_images
	if(length(cimg_holder.shared_bound_images))
		cimg_mob.client.images -= cimg_holder.shared_bound_images
		_refresh_shared_client_images(cimg_mob)

/// disqualify a mind against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/cimg_controller/proc/disqualify_mind(cimg_key, datum/mind/cimg_mind)
	if(!cimg_mind)
		return
	if(!istype(cimg_mind, /datum/mind))
		if(ismob(cimg_mind))
			CRASH("disqualify_mind() has taken a mob. You called a wrong proc.")
		CRASH("disqualify_mind() has taken non-mind")

	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	if(!cimg_holder.valid_minds[cimg_mind])
		// CRASH("Called disqualify_mind([cimg_key], [cimg_mind.name]), but they don't have it already.")
		// do not call this proc multiple times. If you should, you're doing something wrong.
		return // currently CRASH() disabled because dropped() is broken
	cimg_holder.valid_minds[cimg_mind] -= 1
	if(cimg_holder.valid_minds[cimg_mind])
		return
	cimg_holder.valid_minds -= cimg_mind
	cimgkey_by_mind[cimg_mind] -= cimg_key
	if(!length(cimgkey_by_mind[cimg_mind]))
		cimgkey_by_mind -= cimg_mind
	if(cimg_mind.current && cimg_holder.valid_mobs[cimg_mind.current])
		return

	if(!cimg_mind.current.client)
		return
	cimg_mind.current.client.images -= cimg_holder.bound_images
	if(length(cimg_holder.shared_bound_images))
		cimg_mind.current.client.images -= cimg_holder.shared_bound_images
		_refresh_shared_client_images(cimg_mind.current)

/// newly created images should be automatically injected to those one who can see that already.
/// Typically, you don't call this proc directly. Use `GLOB.cimg_controller.stack_client_images()`
/datum/cimg_holder/proc/_realize_to_validated(client_images, is_shared_image = FALSE)
	var/list/applied_clients = list()
	for(var/mob/each_mob as anything in valid_mobs)
		if(!each_mob.client)
			continue
		if(is_shared_image)
			each_mob.client.images |= client_images
		else
			each_mob.client.images += client_images
		applied_clients[each_mob.client] = TRUE

	for(var/datum/mind/each_mind as anything in valid_minds)
		var/client/cli = each_mind.current?.client
		if(!cli || applied_clients[cli])
			continue
		if(is_shared_image)
			cli.images |= client_images
		else
			cli.images += client_images

/// a thing is destroyed or no longer has its own special image
/// Typically, you don't call this proc directly. Use `GLOB.cimg_controller.cut_client_images()`
/datum/cimg_holder/proc/_disappear_from_validated(client_images)
	var/list/applied_clients = list()
	for(var/mob/each_mob as anything in valid_mobs)
		if(!each_mob.client)
			continue
		each_mob.client.images -= client_images
		applied_clients[each_mob.client] = TRUE

	for(var/datum/mind/each_mind as anything in valid_minds)
		var/client/cli = each_mind.current?.client
		if(!cli || applied_clients[cli])
			continue
		cli.images -= client_images
