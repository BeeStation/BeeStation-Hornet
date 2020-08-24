/**

Full-auto firing by Kmc2000
This system lets you spray and pray with guns when dragging the mouse.

*/

/obj/item/gun/proc/can_fire_at(atom/target, mob/user)
	if(!target)
		return FALSE

	if(target == user) //so we can't shoot ourselves with autofire
		return FALSE

	if(user.stat != CONSCIOUS) //No firing in softcrit
		return FALSE

	if(user.get_active_held_item() != src)
		return FALSE

	if(istype(target, /obj/screen))
		return FALSE

	if(target in user.contents) //can't shoot stuff inside us.
		return FALSE

	if(user.a_intent == INTENT_HARM) //melee attacks are handled by attackby, not autofire
		return FALSE

	if(isliving(user))//Check if the user can use the gun, if the user isn't alive(turrets) assume it can.
		var/mob/living/L = user
		if(!can_trigger_gun(L))
			return FALSE
		if(clumsy_check)//If theyre a clown, they can't autofire.
			if (HAS_TRAIT(user, TRAIT_CLUMSY))
				return FALSE

	if(!can_shoot()) //Just because you can pull the trigger doesn't mean it can shoot. (*CLICK*)
		return FALSE

	if(weapon_weight == WEAPON_HEAVY && user.get_inactive_held_item()) //If you can't fire it fully, you can't autofire it.
		return FALSE

	return TRUE //If we passed all those other checks. Yay, we get to fire. Hoorah.

/obj/item/gun/onMouseUp(object, location, params, mob)
	autofire_target = null
	return ..()

/obj/item/gun/onMouseDown(object, location, params)
	set waitfor = FALSE //Asynchronous processing is required here due to the while loop. In other words. Don't hold up the client's clicking while we run a loop that can go on for ages (potentially!)
	if(world.time < next_autofire)
		autofire_target = null
		return FALSE
	next_autofire = world.time + 0.25 SECONDS //Get out of here with your stupid autoclicker...
	var/mob/user = src.loc
	autofire_target = object //When we start firing, we start firing at whatever you clicked on initially. When the user drags their mouse, this shall change.
	while(autofire_target)  //While will only run while we have a user (loc) that is a mob, and we are being actively held by this mob, they have a client (as to prevent disconnecting mid-fight causing you to perma-fire) and of course, if we passed the previous check about autofiring.
		if(can_fire_at(autofire_target, user))
			afterattack(autofire_target, user)
		else
			autofire_target = null
			return FALSE
		stoplag(max((10 / (fire_rate ? fire_rate : 1 )), 0.15 SECONDS)) //Default fire delay to prevent you from instantly dumping an entire mag out. This is at the end so that you can at least get a shot off

/obj/item/gun/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	autofire_target = over_object
	if(!automatic)
		autofire_target = null
		return FALSE
