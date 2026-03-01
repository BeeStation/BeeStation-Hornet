/datum/component/deployable
	/// The object that we will be deploying. May also be a typepath
	var/deployed_object
	///	Should be true if the item is deploying itself when set up, should be false if it's deploying other objects
	var/consumed
	///	The amount of time it takes to deploy
	var/time_to_deploy
	///	Set to true to allow deployment on top of dense objects
	var/dense_deployment
	/// Even if 'dense_deployment' is FALSE, if this is TRUE, it can be deployed onto your position
	var/ignores_mob_density
	/// The icon to use if we are consumed and empty
	var/empty_icon
	/// The type that we can use to reload this deployable
	var/reload_type
	/// The can deploy check. Parameters are user and location, a nullable atom and a turf.
	var/datum/callback/can_deploy_check = null
	/// Called after deployment. Parameters are atom/deployed_item, mob/living/user
	var/datum/callback/on_after_deploy = null
	///	For when consumed is false, is the carrier object currently loaded and ready to deploy its payload item?
	/// Private as we don't want external modifications to this
	VAR_PRIVATE/loaded = FALSE
	/// The atom parent of this
	VAR_PRIVATE/obj/item/item_parent

/datum/component/deployable/Initialize(deployed_object, consumed = TRUE, time_to_deploy = 0 SECONDS, ignores_mob_density = TRUE, dense_deployment = FALSE, empty_icon = null, loaded = FALSE, reload_type = null, datum/callback/can_deploy_check = null, datum/callback/on_after_deploy = null)
	. = ..()
	if (!isitem(parent))
		return COMPONENT_INCOMPATIBLE
	item_parent = parent

	// Set it as a typepath for now
	src.deployed_object = deployed_object
	src.consumed = consumed
	src.time_to_deploy = time_to_deploy
	src.ignores_mob_density = ignores_mob_density
	src.dense_deployment = dense_deployment
	src.empty_icon = empty_icon
	src.loaded = loaded
	src.reload_type = reload_type
	src.can_deploy_check = can_deploy_check
	src.on_after_deploy = on_after_deploy

	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(on_attack_self))
	RegisterSignal(parent, COMSIG_ITEM_AFTERATTACK, PROC_REF(on_afterattack))
	RegisterSignal(parent, COMSIG_DEPLOYABLE_FORCE_DEPLOY, PROC_REF(force_deploy))
	RegisterSignal(parent, COMSIG_ATOM_UPDATE_ICON_STATE, PROC_REF(on_update_icon_state))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(on_examine))

/datum/component/deployable/Destroy(force, silent)
	item_parent = null
	return ..()

/datum/component/deployable/proc/on_examine(datum/source, mob/mob, list/examine_text)
	if (consumed)
		examine_text += "\The [item_parent] is [loaded ? "loaded" : "empty"]."

/datum/component/deployable/proc/on_update_icon_state(datum/source)
	SIGNAL_HANDLER
	if (!consumed && !loaded && empty_icon)
		item_parent.icon_state = empty_icon
	return TRUE

/datum/component/deployable/proc/on_attack_self(datum/source, mob/user)
	SIGNAL_HANDLER
	INVOKE_ASYNC(src, PROC_REF(try_deploy), user, user.loc)
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/deployable/proc/on_afterattack(datum/source, atom/movable/target, mob/user, proximity_flag, params)
	SIGNAL_HANDLER
	if(!proximity_flag)
		return
	if (!consumed && reload_type && istype(target, reload_type))
		if (loaded)
			to_chat(user, span_warning("You already have a target docked!"))
			return
		if(target.has_buckled_mobs())
			if(target.buckled_mobs.len > 1)
				target.unbuckle_all_mobs()
				user.visible_message(span_notice("[user] unbuckles all creatures from [target]."))
			else
				target.user_unbuckle_mob(target.buckled_mobs[1], user)
		else
			user.visible_message("[user] collects [target].", span_notice("You collect [target]."))
			loaded = TRUE
			item_parent.update_icon()
			qdel(target)
		return
	if (consumed || loaded)
		INVOKE_ASYNC(src, PROC_REF(try_deploy), user, target)

/datum/component/deployable/proc/force_deploy(datum/source, atom/location)
	SIGNAL_HANDLER
	if(!consumed && !loaded)
		return
	if(!location) //if no location was passed we use the current location.
		location = item_parent.loc
	if(isopenturf(location))
		if(dense_deployment)
			deploy(null, location)
			return DEPLOYMENT_SUCCESS
		else
			var/dense_location
			for(var/atom/movable/AM in location)
				if(!AM.density || (ignores_mob_density && ismob(AM)))
					continue
				dense_location = TRUE
				break
			if(!dense_location)
				deploy(null, location)
				return DEPLOYMENT_SUCCESS
	item_parent.visible_message(span_warning("[item_parent] fails to deploy!"))

///Checks to see if object can deploy, either in a passed location or within its own location if none was passed and deploys if it can be.
/datum/component/deployable/proc/try_deploy(mob/user, atom/location)
	if(!consumed && !loaded)
		if (user)
			to_chat(user, span_warning("[item_parent] has nothing to deploy!"))
		return
	if (can_deploy_check && !can_deploy_check.Invoke(user, location))
		return
	if(!location) //if no location was passed we use the current location.
		location = item_parent.loc
	if(isopenturf(location))
		if(dense_deployment)
			deploy_after(user, location)
			return
		else
			var/dense_location
			for(var/atom/movable/AM in location)
				if(!AM.density || (ignores_mob_density && ismob(AM)))
					continue
				dense_location = TRUE
				break
			if(!dense_location)
				deploy_after(user, location)
				return
	if(user)
		if(ignores_mob_density)
			to_chat(user, span_warning("[item_parent] can only be deployed in an open area!"))
		else
			to_chat(user, span_warning("[item_parent] can only be deployed in an open area! Click an open area where has no dense object."))
	item_parent.visible_message(span_warning("[item_parent] fails to deploy!"))

///Delays deployment for things which take time to set up
/datum/component/deployable/proc/deploy_after(mob/user, atom/location)
	if(!time_to_deploy || !user)
		deploy(user, location)
		return

	user?.visible_message(span_notice("[user] begins to deploy [item_parent]..."))
	if(do_after(user, time_to_deploy, item_parent))
		deploy(user, location)

///Do not call this directly, use try_deploy instead or else deployed items may end up in invalid locations
/datum/component/deployable/proc/deploy(mob/user, atom/location)
	if (can_deploy_check && !can_deploy_check.Invoke(user, location))
		return
	if (user)
		item_parent.add_fingerprint(user)
	if(isnull(deployed_object)) //then this must have saved contents to dump directly instead
		for(var/atom/movable/A in item_parent.contents)
			A.forceMove(location)
			if (!QDELETED(item_parent))
				item_parent.transfer_fingerprints_to(A)
	else
		var/atom/R = new deployed_object(location, user)
		for(var/atom/movable/A in item_parent.contents)
			A.forceMove(R)
			if (!QDELETED(item_parent))
				item_parent?.transfer_fingerprints_to(A)
		if (!QDELETED(item_parent))
			item_parent?.transfer_fingerprints_to(R)
		if(istype(R, /obj/structure/closet))
			var/obj/structure/closet/sesame = R
			sesame.open()
		on_after_deploy?.InvokeAsync(R, user)
	if(consumed)
		if (!QDELETED(item_parent))
			qdel(item_parent)
	else
		loaded = FALSE
		if (!QDELETED(item_parent))
			item_parent.update_icon()

