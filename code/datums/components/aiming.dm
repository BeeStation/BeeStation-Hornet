// Aiming component, ported from NSV
// Modified to make the radial menu less of a powergamer tool.

/datum/component/aiming
	can_transfer = FALSE
	var/mob/living/user = null
	var/mob/living/target = null
	COOLDOWN_DECLARE(aiming_cooldown) // 5 second cooldown so you can't spam aiming for faster bullets
	COOLDOWN_DECLARE(notification_cooldown) // 5 seconds, prevents spamming the equip notification/sound

/datum/component/aiming/Initialize(source)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_parent_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_parent_unequip)

/datum/component/aiming/proc/aim(mob/user, mob/target)
	if(QDELETED(user) || QDELETED(target)) // We lost the user or target somehow
		return
	if(!COOLDOWN_FINISHED(src, aiming_cooldown) || src.target || user == target) // No double-aiming
		return
	COOLDOWN_START(src, aiming_cooldown, 5 SECONDS)
	src.user = user
	src.target = target
	user.visible_message("<span class='warning'>[user] points [parent] at [target]!</span>")
	to_chat(target, "<span class='userdanger'>[user] is pointing [parent] at you! If you equip or drop anything they will be notified! \n<b>You can use *surrender to give yourself up</b>.</span>")
	to_chat(user, "<span class='notice'>You're now aiming at [target]. If they attempt to equip anything you'll be notified by a loud sound.</span>")
	user.balloon_alert_to_viewers("[user] points [parent] at [target]!", ignored_mobs = list(user, target))
	user.balloon_alert(target, "[user] points [parent] at you!")
	playsound(target, 'sound/weapons/autoguninsert.ogg', 100, TRUE)
	new /obj/effect/temp_visual/aiming(get_turf(target))

	// Register signals to alert our user if the target does something shifty.
	RegisterSignal(target, COMSIG_MOB_EQUIPPED_ITEM, .proc/on_equip)
	RegisterSignal(target, COMSIG_MOB_DROPPED_ITEM, .proc/on_drop)
	RegisterSignal(src.target, COMSIG_LIVING_STATUS_PARALYZE, .proc/on_paralyze)

	// Registers movement signals
	RegisterSignal(src.user, COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(src.target, COMSIG_MOVABLE_MOVED, .proc/on_move)

	addtimer(CALLBACK(src, .proc/stop_aiming), 10 SECONDS) //Ten seconds is enough to either have the situation be resolved, or calm enough


/*

Handles equipping/unequipping and pointing with the parent weapon.

*/

/// Registers pointing signal and sets up our user. Used for picking up/unstowing a weapon.
/datum/component/aiming/proc/on_parent_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot == ITEM_SLOT_HANDS)
		RegisterSignal(equipper, COMSIG_MOB_POINTED, .proc/do_aim)
		user = equipper
	else // Putting a weapon into storage/direct storage equip by loadout
		on_parent_unequip()

/// Called when the holder of our parent points at something. Triggers aiming.
/datum/component/aiming/proc/do_aim(mob/living/user, mob/living/target)
	SIGNAL_HANDLER
	if(!istype(target)) // Target isn't valid, abort
		return
	if(user.get_active_held_item() != parent) // We don't have the gun selected, abort
		return
	INVOKE_ASYNC(src, .proc/aim, user, target) // Start aiming

// Cleans up the user and stops aiming if we're aiming. Used for stowing/dropping a weapon
/datum/component/aiming/proc/on_parent_unequip()
	SIGNAL_HANDLER
	if(user)
		UnregisterSignal(user, COMSIG_MOB_POINTED)
	stop_aiming()
	user = null

/*

Methods to alert the aimer about events (Surrendering/equipping an item/dropping an item)

*/

// Called when the target mob equips something
/datum/component/aiming/proc/on_equip(mob/M, obj/item/I, slot)
	SIGNAL_HANDLER
	if(I != target.get_active_held_item() || !COOLDOWN_FINISHED(src, notification_cooldown)) // Checks to make sure the item was actually equipped to the target's hands
		return
	if(istype(I, /obj/item/gun))
		target.balloon_alert(user, "[target] equipped a gun!")
	else
		target.balloon_alert(user, "[target] equipped something!")
	SEND_SOUND(user, 'sound/machines/chime.ogg')
	new /obj/effect/temp_visual/aiming/suspect_alert(get_turf(target))
	COOLDOWN_START(src, notification_cooldown, 5 SECONDS)

// Called when the target mob drops something
/datum/component/aiming/proc/on_drop(mob/M, obj/item/I, loc)
	SIGNAL_HANDLER
	if(!istype(loc, /turf)) // Checks to make sure the item was actually dropped to the ground
		return
	target.balloon_alert(user, "[target] dropped what they were holding!")

// Called when the target mob gets paralyzed (happens if they surrender or are otherwise disabled)
/datum/component/aiming/proc/on_paralyze()
	SIGNAL_HANDLER
	to_chat(user, "<span class='nicegreen'>[target] appears to be surrendering!</span>")
	target.balloon_alert(user, "[target] surrenders!")

// Cancels aiming if we can't see the target
/datum/component/aiming/proc/on_move()
	SIGNAL_HANDLER
	if(QDELETED(target) || QDELETED(user))
		stop_aiming()
		return
	if(target in view(user))
		return
	user.balloon_alert(user, "You can't see [target] anymore!")
	stop_aiming()



/datum/component/aiming/proc/stop_aiming()
	// Clean up our signals
	if(target)
		UnregisterSignal(target, COMSIG_MOB_EQUIPPED_ITEM)
		UnregisterSignal(target, COMSIG_MOB_DROPPED_ITEM)
		UnregisterSignal(target, COMSIG_LIVING_STATUS_PARALYZE)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	target = null

// Shows a crosshair effect when aiming at a target
/obj/effect/temp_visual/aiming
	icon = 'icons/effects/aiming.dmi'
	icon_state = "aiming"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

/// Shows a big flashy exclamation mark above the target to warn the aimer that they're trying something stupid.
/obj/effect/temp_visual/aiming/suspect_alert
	icon_state = "perp_alert"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER

// Initializes aiming component in bananas
/obj/item/food/grown/banana/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/aiming)
