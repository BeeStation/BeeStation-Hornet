GLOBAL_DATUM_INIT(cimg_controller, /datum/cimg_controller, new)

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

	/// mobs who can see that
	var/list/valid_mobs = list()
	/// minds who can see that
	var/list/valid_minds = list()

/// adds an image to a key group. You must call `cut_client_images()` for qdel.
/datum/cimg_controller/proc/stack_client_images(cimg_key, client_images)
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		cimg_holder = new
		cimg_holders[cimg_key] = cimg_holder

	cimg_holder.bound_images += client_images // list works
	cimg_holder.realize_to_validated(client_images)

/// removes added image from a key group.
/datum/cimg_controller/proc/cut_client_images(cimg_key, client_images)
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	cimg_holder.bound_images -= client_images // list works
	cimg_holder.disappear_from_validated(client_images)

/// this actually refreshes every client images - aghost or getting a new mob will call this
/datum/cimg_controller/proc/on_mob_log_on(mob/cimg_mob)
	var/list/already_injected = list()
	for(var/each_cimgkey in cimgkey_by_mob[cimg_mob])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_mob.client.images += cimg_holder.bound_images
		already_injected[cimg_holder] = TRUE
	if(!cimg_mob.mind)
		return
	for(var/each_cimgkey in cimgkey_by_mind[cimg_mob.mind])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		if(already_injected[cimg_holder])
			continue
		cimg_mob.client.images += cimg_holder.bound_images

/datum/cimg_controller/proc/on_mob_destroy(mob/cimg_mob)
	for(var/each_cimgkey in cimgkey_by_mob[cimg_mob])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_holder.valid_mobs -= cimg_mob
		if(cimg_mob.client)
			cimg_mob.client.images -= cimg_holder.bound_images
	cimgkey_by_mob -= cimg_mob

/datum/cimg_controller/proc/on_mind_destroy(datum/mind/cimg_mind)
	for(var/each_cimgkey in cimgkey_by_mind[cimg_mind])
		var/datum/cimg_holder/cimg_holder = cimg_holders[each_cimgkey]
		cimg_holder.valid_minds -= cimg_mind
		// there's no way to track a mind's client.
	cimgkey_by_mind -= cimg_mind

/// Makes a mob can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call disqualify_mob() proc to handle this correctly.
/datum/cimg_controller/proc/validate_mob(cimg_key, mob/cimg_mob)
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

/// Makes a mind can see images that are bound to a key group.
/// NOTE: calling this again adds up +1 count the validation. call disqualify_mind() proc to handle this correctly.
/datum/cimg_controller/proc/validate_mind(cimg_key, datum/mind/cimg_mind)
	if(!cimg_mind)
		return
	if(!istype(cimg_mind, /datum/mind))
		CRASH("non-mind has been given")

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

/// disqualify a mob against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/cimg_controller/proc/disqualify_mob(cimg_key, mob/cimg_mob)
	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	if(!cimg_holder.valid_mobs[cimg_mob])
		return
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

/// disqualify a mind against a key group so that they can't see.
/// NOTE: if count still exists because validate() proc is called multiple times, they'll still see stuff.
/datum/cimg_controller/proc/disqualify_mind(cimg_key, datum/mind/cimg_mind)
	if(!cimg_mind)
		return
	if(!istype(cimg_mind, /datum/mind))
		CRASH("non-mind has been given")

	var/datum/cimg_holder/cimg_holder = cimg_holders[cimg_key]
	if(!cimg_holder)
		return

	if(!cimg_holder.valid_minds[cimg_mind])
		return
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

/// newly created images should be automatically injected to those one who can see that already.
/// Typically, you don't call this proc directly. Use `GLOB.cimg_controller.stack_client_images()`
/datum/cimg_holder/proc/realize_to_validated(client_images)
	var/list/applied_clients = list()
	for(var/mob/each_mob as anything in valid_mobs)
		if(!each_mob.client)
			continue
		each_mob.client.images += client_images
		applied_clients[each_mob.client] = TRUE

	for(var/datum/mind/each_mind as anything in valid_minds)
		var/client/cli = each_mind.current?.client
		if(!cli || applied_clients[cli])
			continue
		cli.images += client_images

/// a thing is destroyed or no longer has its own special image
/// Typically, you don't call this proc directly. Use `GLOB.cimg_controller.cut_client_images()`
/datum/cimg_holder/proc/disappear_from_validated(client_images)
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
