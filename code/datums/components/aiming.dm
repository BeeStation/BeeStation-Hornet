// Aiming component, ported from NSV

// Defines for aiming "levels"
#define GUN_NOT_AIMED 0
#define GUN_AIMED 1
#define GUN_AIMED_POINTBLANK 2

// Defines for stages and radial choices
#define START "start"
#define RAISE_HANDS "raise_hands"
#define CANCEL "cancel"
#define SHOOT "shoot"
#define SURRENDER "surrender"
#define IGNORE "ignore"
#define POINTBLANK "pointblank"
#define LET_GO "let_go"
#define ENABLE_AUTO "enable_auto"
#define DISABLE_AUTO "disable_auto"

/datum/component/aiming
	can_transfer = FALSE
	var/mob/living/user = null
	var/mob/living/target = null
	var/obj/item/target_held = null
	var/datum/radial_menu/persistent/choice_menu // Radial menu for the user
	var/datum/radial_menu/persistent/choice_menu_target // Radial menu for the target
	var/holding_at_gunpoint = FALSE // used for boosting shot damage
	var/auto_shoot = FALSE // Used for auto-shooting the target
	COOLDOWN_DECLARE(voiceline_cooldown) // 2 seconds, prevents spamming commands
	COOLDOWN_DECLARE(notification_cooldown) // 5 seconds, prevents spamming the equip notification/sound

/datum/component/aiming/Initialize(source)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, PROC_REF(on_parent_equip))
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, PROC_REF(on_parent_unequip))

/datum/component/aiming/proc/aim(mob/user, mob/target)
	if(QDELETED(user) || QDELETED(target)) // We lost the user or target somehow
		return
	if(src.target || user == target) // No double-aiming
		return
	if (!do_after(user, 1 SECONDS, target, IGNORE_TARGET_LOC_CHANGE))
		return
	src.user = user
	src.target = target
	user.visible_message(span_warning("[user] points [parent] at [target]!"))
	to_chat(target, span_userdanger("[user] is pointing [parent] at you! If you equip or drop anything they will be notified! \n<b>You can use *surrender to give yourself up</b>."))
	to_chat(user, span_notice("You're now aiming at [target]. If they attempt to equip anything you'll be notified by a loud sound."))
	user.balloon_alert_to_viewers("[user] points [parent] at [target]!", ignored_mobs = list(user, target))
	user.balloon_alert(target, "[user] points [parent] at you!")
	playsound(target, 'sound/weapons/autoguninsert.ogg', 100, TRUE)
	new /obj/effect/temp_visual/aiming(get_turf(target))

	// Register signals to alert our user if the target does something shifty.
	RegisterSignal(target, COMSIG_MOB_EQUIPPED_ITEM, PROC_REF(on_equip))
	RegisterSignal(target, COMSIG_MOB_DROPPED_ITEM, PROC_REF(on_drop))
	RegisterSignal(src.target, COMSIG_LIVING_STATUS_PARALYZE, PROC_REF(on_paralyze))

	// Registers movement signals
	RegisterSignal(src.user, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))
	RegisterSignal(src.target, COMSIG_MOVABLE_MOVED, PROC_REF(on_move))

	// Shows the radials to the aimer and target
	aim_react(src.target)
	show_ui(src.user, src.target, stage="start")

/*

Handles equipping/unequipping and pointing with the parent weapon.

*/

/// Registers pointing signal and sets up our user. Used for picking up/unstowing a weapon.
/datum/component/aiming/proc/on_parent_equip(datum/source, mob/equipper, slot)
	SIGNAL_HANDLER
	if(slot == ITEM_SLOT_HANDS)
		RegisterSignal(equipper, COMSIG_MOB_POINTED, PROC_REF(do_aim))
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
	INVOKE_ASYNC(src, PROC_REF(aim), user, target) // Start aiming
	return COMSIG_MOB_POINTED_CANCEL

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
	to_chat(user, span_nicegreen("[target] appears to be surrendering!"))
	target.balloon_alert(user, "[target] surrenders!")

// Cancels aiming if we can't see the target
/datum/component/aiming/proc/on_move()
	SIGNAL_HANDLER
	if(QDELETED(target) || QDELETED(user))
		stop_aiming()
		return
	if(target in view(user))
		if (auto_shoot)
			INVOKE_ASYNC(src, PROC_REF(shoot))
		return
	user.balloon_alert(user, "You can't see [target] anymore!")
	stop_aiming()

/datum/component/aiming/proc/on_resist()
	SIGNAL_HANDLER
	target.balloon_alert(user, "Tries to break free!")

/datum/component/aiming/proc/stop_holding()
	SIGNAL_HANDLER
	var/obj/item/held = user.get_active_held_item()
	user.visible_message(span_warning("[user] stops holding \the [held] at [target]'s temple!"), \
				span_notice("You stop holding \the [held] at [target]'s temple"), ignored_mobs = list(target))
	to_chat(target, span_warning("[user] stops holding \the [held] at your temple!"))
	user.balloon_alert_to_viewers("Lets go of [target]", "Let go of [target]", ignored_mobs = list(target), show_in_chat = FALSE)
	user.balloon_alert(target, "[user] Lets go of you", show_in_chat = FALSE)
	remove_pointblank()
	auto_shoot = FALSE
	show_ui(user, target, START)

/**

Method to show a radial menu to the person who's aiming, in stages:

AIMING_START means they just recently started aiming
AIMING_RAISE_HANDS means they selected the "raise your hands above your head" command
AIMING_DROP_WEAPON means they selected the "drop your weapon" command

*/

/datum/component/aiming/proc/show_ui(mob/user, mob/target, stage)
	var/list/options = list()
	var/list/possible_actions = list(CANCEL, SHOOT, RAISE_HANDS)
	if(holding_at_gunpoint)
		possible_actions += LET_GO
	else
		possible_actions += POINTBLANK
	if (auto_shoot)
		possible_actions += DISABLE_AUTO
	else
		possible_actions += ENABLE_AUTO
	for(var/option in possible_actions)
		options[option] = image(icon = 'icons/hud/radials/radial_aiming.dmi', icon_state = option)
	if(choice_menu)
		choice_menu.change_choices(options)
		return
	choice_menu = show_radial_menu_persistent(user, user, options, select_proc = CALLBACK(src, PROC_REF(act)))

/datum/component/aiming/proc/act(choice)
	if(QDELETED(user) || QDELETED(target)) // We lost our user or target somehow, abort aiming
		stop_aiming()
		return
	if(!choice)
		stop_aiming()
		return
	if(choice == RAISE_HANDS) // Handling voiceline cooldowns and mimes
		if(!COOLDOWN_FINISHED(src, voiceline_cooldown))
			to_chat(user, span_warning("You've already given a command recently!"))
			show_ui(user, target, choice)
			return
		if(HAS_TRAIT(user, TRAIT_MIMING))
			user.visible_message(span_warning("[user] waves [parent] around menacingly!"))
			show_ui(user, target, choice)
			COOLDOWN_START(src, voiceline_cooldown, 2 SECONDS)
			return
	switch(choice)
		if(CANCEL) //first off, are they telling us to stop aiming?
			stop_aiming()
			return
		if(SHOOT)
			shoot()
			return
		if(RAISE_HANDS)
			user.say(pick("Put your hands above your head!", "Hands! Now!", "Hands up!"), forced = "Weapon aiming")
		if(ENABLE_AUTO)
			auto_shoot = TRUE
			user.say(pick("Do not move, I will shoot!", "If you move I will shoot!", "Stay put if you want to live!"), forced = "Weapon aiming")
		if(DISABLE_AUTO)
			auto_shoot = FALSE
			user.manual_emote("hesitates, lowering their weapon")
		if(POINTBLANK)
			if (holding_at_gunpoint)
				return
			if(get_dist(target, user) > 1)
				to_chat(user, span_warning("You need to be closer to [target] to hold [target.p_them()] at gunpoint!"))
				return
			if(isdead(target))
				to_chat(user, span_warning("You can't hold dead things at gunpoint!"))
				return
			var/obj/item/held = user.get_active_held_item()
			if(!held)
				to_chat(user, span_warning("You can't hold someone at gunpoint with an empty hand!"))
				return
			if(!user.pulling || user.pulling != target)
				target.CtrlClick(user)
				return
			if(user.pulling != target)
				return
			user.setGrabState(GRAB_AGGRESSIVE)
			target.Stun(2 SECONDS)
			user.say(pick("Freeze!", "Don't move!", "Don't twitch a muscle!", "Don't you dare move!", "Hold still!"), forced = "Weapon aiming")
			user.visible_message(span_warning("[user] lines up \the [held] with [target]'s temple!"), \
			span_notice("You line up \the [held] with [target]'s temple"), ignored_mobs = list(target))
			to_chat(target, span_warning("[user] lines up \the [held] with your temple!"))
			user.balloon_alert_to_viewers("Holds [target] at gunpoint!", "Holding [target] at gunpoint!", ignored_mobs = list(target), show_in_chat = FALSE)
			user.balloon_alert(target, "Holds you at gunpoint!", show_in_chat = FALSE)
			setup_pointblank()
		if(LET_GO)
			stop_holding()
	aim_react(target)
	COOLDOWN_START(src, voiceline_cooldown, 2 SECONDS)
	show_ui(user, target, choice)

/datum/component/aiming/proc/setup_pointblank()
	holding_at_gunpoint = TRUE
	RegisterSignal(src.target, COMSIG_LIVING_RESIST, PROC_REF(on_resist))
	RegisterSignal(src.target, COMSIG_MOVABLE_NO_LONGER_PULLED, PROC_REF(stop_holding))

/datum/component/aiming/proc/remove_pointblank()
	if(!holding_at_gunpoint)
		return
	holding_at_gunpoint = FALSE
	UnregisterSignal(src.target, COMSIG_LIVING_RESIST)
	UnregisterSignal(src.target, COMSIG_MOVABLE_NO_LONGER_PULLED)

/datum/component/aiming/proc/shoot()
	var/obj/item/held = user.get_active_held_item()
	if(held != parent)
		stop_aiming()
		return FALSE
	if(istype(parent, /obj/item/gun)) // If we have a gun, shoot it at the target
		var/obj/item/gun/G = parent
		if(holding_at_gunpoint)
			G.pull_trigger(target, user, null, GUN_AIMED_POINTBLANK)
		else
			G.pull_trigger(target, user, null, GUN_AIMED)
		stop_aiming()
		return TRUE
	if(isitem(parent)) // Otherwise, just wave it at them
		var/obj/item/I = parent
		I.afterattack(target, user)
		user.visible_message(span_warning("[user] waves [parent] around menacingly!"))
		stop_aiming()

/datum/component/aiming/proc/stop_aiming()
	// Clean up our signals
	if(target)
		UnregisterSignal(target, COMSIG_MOB_EQUIPPED_ITEM)
		UnregisterSignal(target, COMSIG_MOB_DROPPED_ITEM)
		UnregisterSignal(target, COMSIG_LIVING_STATUS_PARALYZE)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
		user.manual_emote("stops aiming their weapon", "lowers their weapon, satisfied")
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	// Clean up the menu if it's still open
	QDEL_NULL(choice_menu)
	QDEL_NULL(choice_menu_target)
	remove_pointblank()
	target = null

/datum/component/aiming/proc/aim_react(mob/target)
	set waitfor = FALSE
	if(QDELETED(target) || choice_menu_target) // We lost our target, or they already have a menu up
		return
	var/list/options = list()
	for(var/option in list(SURRENDER, IGNORE))
		options[option] = image(icon = 'icons/hud/radials/radial_aiming.dmi', icon_state = option)
	choice_menu_target = show_radial_menu_persistent(target, target, options, select_proc = CALLBACK(src, PROC_REF(aim_react_act)))

/datum/component/aiming/proc/aim_react_act(choice)
	if(choice == SURRENDER)
		if (target.get_num_held_items() > 0)
			target.manual_emote("drops their weapon, surrendering.")
			target.drop_all_held_items()
		else
			target.manual_emote("raises their hands, surrendering.")
	QDEL_NULL(choice_menu_target)

// Shows a crosshair effect when aiming at a target
/obj/effect/temp_visual/aiming
	icon = 'icons/hud/radials/radial_aiming.dmi'
	icon_state = "aiming"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

/// Shows a big flashy exclamation mark above the target to warn the aimer that they're trying something stupid.
/obj/effect/temp_visual/aiming/suspect_alert
	icon_state = "perp_alert"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER

#undef START
#undef RAISE_HANDS
#undef CANCEL
#undef SHOOT
#undef SURRENDER
#undef IGNORE
#undef POINTBLANK
#undef LET_GO
#undef ENABLE_AUTO
#undef DISABLE_AUTO
