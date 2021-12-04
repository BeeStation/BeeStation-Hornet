// Aiming component, ported from NSV

/datum/component/aiming
	can_transfer = FALSE
	var/mob/living/user = null
	var/mob/living/target = null
	var/aiming_cooldown = FALSE
	var/cooldown_time = 5 SECONDS // So you can't spam aiming for faster bullets/spamming lines

/datum/component/aiming/Initialize(source)
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/stop_aiming)

/datum/component/aiming/proc/aim(mob/user, mob/target)
	set waitfor = FALSE // So we don't hold up the pointing animation.
	if(aiming_cooldown || src.target || user == target) // No double-aiming
		return
	src.user = user
	src.target = target
	user.visible_message("<span class='warning'>[user] points [parent] at [target]!</span>")
	to_chat(target, "<span class='userdanger'>[user] is pointing [parent] at you! If you equip or drop anything they will be notified! \n <b>You can use *surrender to give yourself up</b>.</span>")
	to_chat(user, "<span class='notice'>You're now aiming at [target]. If they attempt to equip anything you'll be notified by a loud sound.</span>")
	playsound(target, 'sound/weapons/autoguninsert.ogg', 100, TRUE)
	aiming_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, aiming_cooldown, FALSE), cooldown_time)
	new /obj/effect/temp_visual/aiming(get_turf(target))

	// Register signals to alert our user if the target does something shifty.
	RegisterSignal(src.target, COMSIG_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(src.target, COMSIG_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(src.target, COMSIG_LIVING_STATUS_PARALYZE, .proc/on_paralyze)

	// Shows the radials to the aimer and target
	src.target.aim_react()
	show_ui(user, target, stage="start")

/*

Methods to alert the aimer about events, usually to signify that they're complying or trying to pull something.

*/

/datum/component/aiming/proc/on_drop()
	to_chat(user, "<span class='nicegreen'>[target] has dropped something.</span>")

/datum/component/aiming/proc/on_paralyze()
	to_chat(user, "<span class='nicegreen'>[target] appears to be surrendering!</span>")

/datum/component/aiming/proc/on_equip()
	new /obj/effect/temp_visual/aiming/suspect_alert(get_turf(target))
	to_chat(user, "<span class='userdanger'>[target] has equipped something!</span>")
	SEND_SOUND(user, 'sound/machines/chime.ogg')

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
			possible_actions += "face_wall"
			possible_actions += "raise_hands"
		if("drop_weapon")
			possible_actions += "drop_to_floor"
			possible_actions += "drop_weapon"
			possible_actions += "raise_hands"
		if("drop_to_floor")
			possible_actions += "drop_to_floor"
		if("face_wall")
			possible_actions += "face_wall"
	for(var/option in possible_actions)
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/choice = show_radial_menu(user, user, options, require_near = FALSE)
	act(choice)

/datum/component/aiming/proc/act(choice)
	if(!user || !target)
		return //If the aim was cancelled halfway through the process, and the radial didn't close by itself.
	switch(choice)
		if("cancel") //first off, are they telling us to stop aiming?
			stop_aiming()
			return
		if("fire")
			fire()
			return
		if("raise_hands")
			user.say("PUT YOUR HANDS BEHIND YOUR HEAD!")
		if("drop_weapon")
			user.say("DROP YOUR WEAPON!")
		if("face_wall")
			user.say("TURN AROUND AND FACE THE WALL. SLOWLY.")
		if("drop_to_floor")
			user.say("ON THE FLOOR, NOW!")
	show_ui(user, target, choice)

/datum/component/aiming/proc/fire()
	var/obj/item/held = user.get_active_held_item()
	if(held != parent)
		stop_aiming()
		return FALSE
	if(!(target in view(user))) // Check to make sure we can still see the target
		to_chat(user, "<span class='warning'>You can't see [target] anymore!</span>")
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
	if(target)
		UnregisterSignal(target, COMSIG_ITEM_DROPPED)
		UnregisterSignal(target, COMSIG_ITEM_EQUIPPED)
		UnregisterSignal(target, COMSIG_LIVING_STATUS_PARALYZE)
	user = null
	target = null

/mob/living/proc/aim_react()
	set waitfor = FALSE
	var/list/options = list()
	for(var/option in list("surrender", "ignore"))
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/choice = show_radial_menu(src, src, options)
	if(choice == "surrender")
		emote("surrender")

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

// Initializes aiming component in guns and gun-shaped fruits
/obj/item/gun/Initialize()
	. = ..()
	AddComponent(/datum/component/aiming)

/obj/item/reagent_containers/food/snacks/grown/banana/Initialize()
	. = ..()
	AddComponent(/datum/component/aiming)
