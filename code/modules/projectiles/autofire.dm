/**
Full-auto firing by Kmc2000 (Version 2)
So it turns out the way I wrote this before was absolutely abysmal (who would've guessed!) this should be a little bit more clean and less buggy <3
Fields:
full_auto - Set this if you want a full auto setting on your gun. This REPLACES semi-auto, but don't fret! You can still use semi auto mode when on full auto, just don't hold your mouse down :)
It's highly recommended that you DO NOT use this for special case guns like the beam rifle, or guns that override mouseDown, as this will cause issues.
Everything else should be handled for you. Good luck soldier.
*/

#define COMSIG_AUTOFIRE_END "stop_autofiring"

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
					autofire_component.ClearFromParent()
					qdel(autofire_component)
					return ..()
		if(NAMEOF(src, fire_rate))
			autofire_component?.default_fire_delay = (10 / var_value)
			return

/obj/item/gun/Initialize(mapload)
	. = ..()
	if(full_auto)
		canMouseDown = TRUE
		autofire_component = AddComponent(/datum/component/full_auto)
		if(fire_rate)
			autofire_component.default_fire_delay = (10 / fire_rate) //Higher fire rate go brr

/datum/component/full_auto
	var/atom/autofire_target = null
	var/default_fire_delay = 0.03 SECONDS //This is just a default value in case you didn't set the fire_rate var.
	var/next_process = 0

/datum/component/full_auto/Initialize()
	. = ..()
	if(!istype(parent, /obj/item/gun)) //Needs at least this base prototype.
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_AUTOFIRE_END, PROC_REF(unset_target)) //Called when they mouse up on their gun.
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(unset_target)) //If you unequip your weapon

/datum/component/full_auto/proc/set_target(atom/target)
	//Preconditions: Parent has prototype "gun", the gun stand user is a living mob.
	var/obj/item/gun/G = parent
	// Target checking - we don't want to shoot at screen objects, objects in our inventory, or turfs on the same tile as us
	if(istype(target, /atom/movable/screen) && !istype(target, /atom/movable/screen/click_catcher))
		return
	if((!isturf(target) && !isturf(target.loc)) || get_turf(G) == target)
		return
	if(!istype(G)) //This should never happen. But let's just be safe.
		ClearFromParent()
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
	next_process = world.time + CLICK_CD_MELEE //So you can't abuse this to magdump.

/datum/component/full_auto/process()
	if(!autofire_target)
		return PROCESS_KILL //They've stopped firing. Don't hog my resources, K?
	if(world.time < next_process)
		return FALSE //Cooldown. Prevents the infinite SLAP mechanic.
	//Preconditions: Parent has prototype "gun", the gun stand user is a living mob.
	var/obj/item/gun/G = parent
	if(!istype(G)) //This should never happen. But let's just be safe.
		ClearFromParent()
		return PROCESS_KILL
	var/mob/living/L = G.loc
	if(!istype(L))
		return PROCESS_KILL //They've dropped the weapon.
	if(L.stat)
		return
	next_process = world.time + default_fire_delay
	if(L.Adjacent(autofire_target)) //Melee attack? Or ranged attack?
		if(isobj(autofire_target))
			next_process = world.time + CLICK_CD_MELEE
			G.attack_atom(autofire_target, L)
			return
		else if(isliving(autofire_target) && L.combat_mode) // Prevents trying to attack turfs next to the shooter
			G.attack(autofire_target, L)
			next_process = world.time + CLICK_CD_MELEE
			return
	G.pull_trigger(autofire_target,L)

/datum/component/full_auto/ClearFromParent()
	. = ..()
	STOP_PROCESSING(SSfastprocess, src) //Just in case.

/obj/item/gun/onMouseUp(object, location, params, mob)
	. = ..()
	SEND_SIGNAL(src, COMSIG_AUTOFIRE_END)

/obj/item/gun/onMouseDown(object, location, params)
	. = ..()
	var/modifiers = params2list(params)
	if(LAZYACCESS(modifiers, MIDDLE_CLICK) || LAZYACCESS(modifiers, SHIFT_CLICK) || LAZYACCESS(modifiers, CTRL_CLICK) || LAZYACCESS(modifiers, ALT_CLICK)) // Only shoot if we're not trying to do something else
		return FALSE
	if(burst_size <= 1) //Don't let them autofire with bursts. That would just be awful.
		autofire_component?.set_target(object)

/obj/item/gun/onMouseDrag(src_object, over_object, src_location, over_location, params, mob/M)
	. = ..()
	if(burst_size <= 1) //Don't let them autofire with bursts. That would just be awful.
		autofire_component?.set_target(over_object)

#undef COMSIG_AUTOFIRE_END
