/**
Full-auto firing by Kmc2000 (Version 2)
So it turns out the way I wrote this before was absolutely abysmal (who would've guessed!) this should be a little bit more clean and less buggy <3
Fields:
full_auto - Set this if you want a full auto setting on your gun. This REPLACES semi-auto, but don't fret! You can still use semi auto mode when on full auto, just don't hold your mouse down :)
It's highly recommended that you DO NOT use this for special case guns like the beam rifle, or guns that override mouseDown, as this will cause issues.
Everything else should be handled for you. Good luck soldier.
*/

#define COMSIG_AUTOFIRE_END "stop_autofiring"

/obj/item/gun
	var/full_auto = FALSE //Set this if your gun uses full auto. ONLY guns that go brr should use this. Not pistols!
	var/datum/component/full_auto/autofire_component = null //Repeated calls to getComponent aren't really ideal. So we'll take the memory hit instead.

/obj/item/gun/vv_edit_var(var_name, var_value)
	. = ..()
	switch(var_name)
		if(NAMEOF(src, full_auto))
			canMouseDown = var_value //Necessary to fully apply the component.
			if(var_value) //Admin editing the autofire to true on a gun, let's help them out.
				if(!autofire_component)
					autofire_component = AddComponent(/datum/component/full_auto)
					if(fire_rate)
						autofire_component.default_fire_delay = (10 / fire_rate)
					return
			else //They're trying to disable the full auto of a gun. Remove the relevent component
				if(autofire_component)
					autofire_component.RemoveComponent()
					qdel(autofire_component)
					return ..()
		if(NAMEOF(src, fire_rate))
			autofire_component?.default_fire_delay = (10 / var_value)
			return

//Place any guns that you want to be fully automatic here (for record-keeping and so NSV can avoid conflicts please and thank.)
/obj/item/gun/ballistic/automatic/l6_saw
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/c20r
	full_auto = TRUE

/obj/item/gun/energy/minigun
	full_auto = TRUE

/obj/item/gun/ballistic/automatic/laser/ctf
	full_auto = TRUE //Rule of cool.

/obj/item/gun/ballistic/automatic/wt550
	full_auto = TRUE

/obj/item/gun/ballistic/shotgun/bulldog
	full_auto = TRUE

/obj/item/gun/Initialize()
	. = ..()
	if(full_auto)
		canMouseDown = TRUE
		autofire_component = AddComponent(/datum/component/full_auto)
		if(fire_rate)
			autofire_component.default_fire_delay = (10 / fire_rate) //Higher fire rate go brr

/datum/component/full_auto
	var/atom/autofire_target = null
	var/default_fire_delay = 0.03 SECONDS //This is just a default value in case you didn't set the fire_rate var.
	var/melee_attack_delay = 0.3 SECONDS //Time delay after you melee attack something at which you'll be allowed to start autofiring again. Also used as a cooldown to avoid magdumps.
	var/next_process = 0

/datum/component/full_auto/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun)) //Needs at least this base prototype.
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_AUTOFIRE_END, .proc/unset_target) //Called when they mouse up on their gun.
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/unset_target) //If you unequip your weapon

/datum/component/full_auto/proc/set_target(atom/target)
	//Preconditions: Parent has prototype "gun", the gun stand user is a living mob.
	var/obj/item/gun/G = parent
	if(!istype(G)) //This should never happen. But let's just be safe.
		RemoveComponent()
		return FALSE
	var/mob/living/L = G.loc
	if(!istype(L))
		unset_target() //If it was dropped while they still held down. This is an extreme edge case, but still POSSIBLE.
		return FALSE
	autofire_target = target
	START_PROCESSING(SSfastprocess, src) //Target acquired. Begin the spam. If we're already processing this is just ignored (see _DEFINES/MC.dm)

/datum/component/full_auto/proc/unset_target()
	SIGNAL_HANDLER

	autofire_target = null
	next_process = world.time + melee_attack_delay //So you can't abuse this to magdump.

/datum/component/full_auto/process()
	if(!autofire_target)
		return PROCESS_KILL //They've stopped firing. Don't hog my resources, K?
	if(world.time < next_process)
		return FALSE //Cooldown. Prevents the infinite SLAP mechanic.
	//Preconditions: Parent has prototype "gun", the gun stand user is a living mob.
	var/obj/item/gun/G = parent
	if(!istype(G)) //This should never happen. But let's just be safe.
		RemoveComponent()
		return PROCESS_KILL
	var/mob/living/L = G.loc
	if(!istype(L))
		return PROCESS_KILL //They've dropped the weapon.
	next_process = world.time + default_fire_delay
	if(L.Adjacent(autofire_target)) //Melee attack? Or ranged attack?
		next_process = world.time + melee_attack_delay
		if(isobj(autofire_target))
			G.attack_obj(autofire_target, L)
		else
			G.attack(autofire_target, L)
	else
		G.afterattack(autofire_target,L)

/datum/component/full_auto/RemoveComponent()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src) //Just in case.

/obj/item/gun/onMouseUp(object, location, params, mob)
	. = ..()
	SEND_SIGNAL(src, COMSIG_AUTOFIRE_END)

/obj/item/gun/onMouseDown(object, location, params)
	. = ..()
	if(burst_size <= 1) //Don't let them autofire with bursts. That would just be awful.
		autofire_component?.set_target(object)

/obj/item/gun/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	. = ..()
	if(burst_size <= 1) //Don't let them autofire with bursts. That would just be awful.
		autofire_component?.set_target(over_object)
