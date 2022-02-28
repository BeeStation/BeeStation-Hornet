// Aiming component, ported from NSV

/datum/component/aiming
	can_transfer = FALSE
	var/mob/living/user = null
	var/mob/living/target = null
	var/datum/radial_menu/persistent/choice_menu // Radial menu for the user
	var/datum/radial_menu/persistent/choice_menu_target // Radial menu for the target
	COOLDOWN_DECLARE(aiming_cooldown) // 5 second cooldown so you can't spam aiming for faster bullets/spam commands
	COOLDOWN_DECLARE(voiceline_cooldown)

/datum/component/aiming/Initialize(source)
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_EQUIPPED, .proc/on_parent_equip)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/on_parent_unequip)

/datum/component/aiming/proc/aim(mob/user, mob/target)
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
	RegisterSignal(src.target, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(src.target, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(src.target, COMSIG_LIVING_STATUS_PARALYZE, .proc/on_paralyze)

	// Registers movement signals
	RegisterSignal(src.user, COMSIG_MOVABLE_MOVED, .proc/on_move)
	RegisterSignal(src.target, COMSIG_MOVABLE_MOVED, .proc/on_move)

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

Methods to alert the aimer about events, usually to signify that they're complying or trying to pull something.

*/

/datum/component/aiming/proc/on_drop()
	SIGNAL_HANDLER
	to_chat(user, "<span class='nicegreen'>[target] has dropped something.</span>")
	target.balloon_alert(user, "[target] dropped something!")

/datum/component/aiming/proc/on_paralyze()
	SIGNAL_HANDLER
	to_chat(user, "<span class='nicegreen'>[target] appears to be surrendering!</span>")
	target.balloon_alert(user, "[target] surrenders!")

/datum/component/aiming/proc/on_equip()
	SIGNAL_HANDLER
	new /obj/effect/temp_visual/aiming/suspect_alert(get_turf(target))
	to_chat(user, "<span class='userdanger'>[target] has equipped something!</span>")
	target.balloon_alert(user, "[target] equipped something!")
	SEND_SOUND(user, 'sound/machines/chime.ogg')

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

/**

Method to show a radial menu to the person who's aiming, in stages:

AIMING_START means they just recently started aiming
AIMING_RAISE_HANDS means they selected the "raise your hands above your head" command
AIMING_DROP_WEAPON means they selected the "drop your weapon" command

*/

/datum/component/aiming/proc/show_ui(mob/user, mob/target, stage)
	var/list/options = list()
	var/list/possible_actions = list("cancel", "fire")
	switch(stage)
		if("start")
			possible_actions += "raise_hands"
			possible_actions += "drop_weapon"
		if("raise_hands")
			possible_actions += "drop_to_floor"
			possible_actions += "raise_hands"
		if("drop_weapon")
			possible_actions += "drop_to_floor"
			possible_actions += "drop_weapon"
			possible_actions += "raise_hands"
		if("drop_to_floor")
			possible_actions += "drop_to_floor"
	for(var/option in possible_actions)
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	if(choice_menu)
		choice_menu.change_choices(options)
		return
	choice_menu = show_radial_menu_persistent(user, user, options, select_proc = CALLBACK(src, .proc/act))

/datum/component/aiming/proc/act(choice)
	if(QDELETED(user) || QDELETED(target)) // We lost our user or target somehow, abort aiming
		stop_aiming()
		return
	if(!choice)
		stop_aiming()
		return
	if(choice != "cancel" && choice != "fire") // Handling voiceline cooldowns and mimes
		if(!COOLDOWN_FINISHED(src, voiceline_cooldown))
			to_chat(user, "<span class = 'warning'>You've already given a command recently!</span>")
			show_ui(user, target, choice)
			return
		if(user.mind.assigned_role == "Mime")
			user.visible_message("<span class='warning'>[user] waves [parent] around menacingly!</span>")
			show_ui(user, target, choice)
			COOLDOWN_START(src, voiceline_cooldown, 2 SECONDS)
			return
	var/alert_message
	var/alert_message_3p
	switch(choice)
		if("cancel") //first off, are they telling us to stop aiming?
			stop_aiming()
			return
		if("fire")
			fire()
			return
		if("raise_hands")
			alert_message = "raise your hands!"
			alert_message_3p = "raise their hands!"
		if("drop_weapon")
			alert_message = "drop your weapon!"
			alert_message_3p = "drop their weapon!"
		if("drop_to_floor")
			alert_message = "lie down!"
			alert_message_3p = "lie down!"
	user.balloon_alert(target, "[user] orders you to [alert_message]")
	user.balloon_alert_to_viewers("[user] orders [target] to [alert_message_3p]!", "You order [target] to [alert_message_3p]", ignored_mobs = target)
	COOLDOWN_START(src, voiceline_cooldown, 2 SECONDS)
	show_ui(user, target, choice)

/datum/component/aiming/proc/fire()
	var/obj/item/held = user.get_active_held_item()
	if(held != parent)
		stop_aiming()
		return FALSE
	if(istype(parent, /obj/item/gun)) // If we have a gun, fire it at the target
		var/obj/item/gun/G = parent
		G.afterattack(target, user, null, null, TRUE)
		stop_aiming()
		return TRUE
	if(isitem(parent)) // Otherwise, just wave it at them
		var/obj/item/I = parent
		I.afterattack(target, user)
		user.visible_message("<span class='warning'>[user] waves [parent] around menacingly!</span>")
		stop_aiming()

/datum/component/aiming/proc/stop_aiming()
	// Clean up our signals
	if(target)
		UnregisterSignal(target, COMSIG_ITEM_DROPPED)
		UnregisterSignal(target, COMSIG_ITEM_EQUIPPED)
		UnregisterSignal(target, COMSIG_LIVING_STATUS_PARALYZE)
		UnregisterSignal(target, COMSIG_MOVABLE_MOVED)
	if(user)
		UnregisterSignal(user, COMSIG_MOVABLE_MOVED)
	// Clean up the menu if it's still open
	QDEL_NULL(choice_menu)
	QDEL_NULL(choice_menu_target)
	target = null

/datum/component/aiming/proc/aim_react(mob/target)
	set waitfor = FALSE
	var/list/options = list()
	for(var/option in list("surrender", "ignore"))
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	choice_menu_target = show_radial_menu_persistent(target, target, options, select_proc = CALLBACK(src, .proc/aim_react_act))

/datum/component/aiming/proc/aim_react_act(choice)
	if(choice == "surrender")
		target.emote("surrender")
	QDEL_NULL(choice_menu_target)

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
/obj/item/reagent_containers/food/snacks/grown/banana/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/aiming)
