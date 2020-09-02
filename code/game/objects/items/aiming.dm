/obj/item/gun/Initialize()
	. = ..()
	AddComponent(/datum/component/aiming)

/obj/item/reagent_containers/food/snacks/grown/banana/Initialize() //Yes, you can hold someone at gunpoint with a banana.
	. = ..()
	AddComponent(/datum/component/aiming)

/mob/living/proc/aim_react()
	set waitfor = FALSE
	var/list/options = list()
	for(var/option in list("surrender", "ignore"))
		options[option] = image(icon = 'icons/effects/aiming.dmi', icon_state = option)
	var/choice = show_radial_menu(src, src, options)
	if(choice == "surrender")
		emote("surrender")

/datum/action/item_action/aim
	name = "Manually aim"
	desc = "Aim at a target manually. You can also aim with 'point' or SHIFT + middle mouse while holding a gun."
	button_icon_state = "aim"
	icon_icon = 'icons/mob/actions/actions_security.dmi'

/obj/item/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/aim))
		var/datum/component/aiming/aiming = GetComponent(/datum/component/aiming)
		if(!aiming)
			return
		var/list/mobs = list()
		for(var/mob/living/M in view(user, 15))
			if(M == user || !isliving(M) || M.invisibility > 0 || !M.alpha)
				continue
			mobs += M
		var/mob/living/A = input(user, "Who do you want to point [src] at?", "[src]", null) as null|anything in mobs
		if(isliving(A))
			aiming.aim(user, A)
		return
	. = ..()

//Happens before the actual projectile creation
/obj/item/gun/before_firing(atom/target,mob/user, aimed)
	if(aimed)
		if(chambered?.BB && !istype(src, /obj/item/gun/ballistic/automatic/toy))
			chambered.BB.stamina = initial(chambered.BB.stamina) += 55
			chambered.BB.jitter = initial(chambered.BB.jitter) += 2
			chambered.BB.jitter = initial(chambered.BB.speed) *= 0.5 //Apparently "SPEED" makes the bullet go slower as SPEED increases. THANK YOU SS13.
	. = ..()

/obj/effect/temp_visual/aiming
	icon = 'icons/effects/aiming.dmi'
	icon_state = "aiming"
	duration = 3 SECONDS
	layer = ABOVE_MOB_LAYER

///Shows a big flashy exclamation mark above the suspect to warn the space cop that they're trying something stupid.
/obj/effect/temp_visual/aiming/suspect_alert
	icon_state = "perp_alert"
	duration = 1 SECONDS
	layer = ABOVE_MOB_LAYER

/datum/component/aiming
	can_transfer = FALSE
	var/mob/living/user = null
	var/mob/living/target = null
	var/aiming_cooldown = FALSE
	var/cooldown_time = 5 SECONDS //A pretty hefty cooldown to prevent spamming aim mode to get the superspeed bullet

/datum/component/aiming/Initialize(source)
	. = ..()
	if(!istype(parent, /obj/item))
		return COMPONENT_INCOMPATIBLE
	new /datum/action/item_action/aim(parent)
	RegisterSignal(parent, COMSIG_ITEM_DROPPED, .proc/stop_aiming)

/datum/component/aiming/proc/aim(mob/user, mob/target)
	set waitfor = FALSE //So we don't hold up the pointing animation.
	if(aiming_cooldown || src.target || user == target) //No double-aiming
		return
	src.user = user
	src.target = target
	user.visible_message("<span class='warning'>[user] points [parent] at [target]!</span>")
	to_chat(target, "<span class='warning'>[user] is pointing [parent] at you! If you attempt to pull out a weapon, or otherwise resist, they will be notified! \n <b>You can use *surrender to give yourself up</b>.</span>")
	to_chat(user, "<span class='notice'>You're now aiming at [target]. If they attempt to pull a weapon on you, or otherwise resist, you'll be notified by a loud sound.</span>")
	user.say("FREEZE!!")
	playsound(target, 'sound/weapons/autoguninsert.ogg', 100, TRUE)
	aiming_cooldown = TRUE
	addtimer(VARSET_CALLBACK(src, aiming_cooldown, FALSE), cooldown_time)
	new /obj/effect/temp_visual/aiming(get_turf(target))

	//Register signals to alert our user if the target does something shifty.
	RegisterSignal(src.target, COMSIG_MOB_ITEM_DROPPED, .proc/on_drop)
	RegisterSignal(src.target, COMSIG_MOB_ITEM_EQUIPPED, .proc/on_equip)
	RegisterSignal(src.target, COMSIG_LIVING_STATUS_PARALYZE, .proc/on_paralyze)
	//And show the radials to perp and officer mc space cop...
	src.target.aim_react()
	show_ui(user, target, stage="start")

//Helper procs to notify the aiming component of when a mob equips / drops any item.

/obj/item/equipped(mob/equipper, slot)
	. = ..()
	SEND_SIGNAL(equipper, COMSIG_MOB_ITEM_EQUIPPED)

/obj/item/dropped(mob/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_MOB_ITEM_DROPPED)

/*

Methods to alert the aimer about events, usually to signify that they're complying with the arrest or to warn them if the perp is trying something funny.

*/

/datum/component/aiming/proc/on_drop()
	to_chat(user, "<span class='nicegreen'>[target] has dropped something.</span>")

/datum/component/aiming/proc/on_paralyze()
	to_chat(user, "<span class='nicegreen'>[target] appears to be surrendering!</span>")

/datum/component/aiming/proc/on_equip()
	new /obj/effect/temp_visual/aiming/suspect_alert(get_turf(target))
	to_chat(user, "<span class='userdanger'>[target] has pulled out something from their storage!</span>")
	SEND_SOUND(user, 'sound/machines/chime.ogg')

/**

Method to show a radial menu to the person who's aiming, in stages:

AIMING_START means they just recently started aiming
AIMING_RAISE_HANDS means they selected the "raise your hands above your head" command
AIMING_DROP_WEAPON means they selected the "drop your weapon" command

There are two main branches, dictated by SOP. If the perp is armed, tell them to drop their weapon, otherwise get them to raise their hands and face the wall.

*/

/datum/component/aiming/proc/show_ui(mob/user, mob/target, stage)
	var/list/options = list()
	var/list/possible_actions = list("cancel", "fire")
	switch(stage)
		if("start")
			possible_actions += "raise_hands"
			possible_actions += "drop_weapon"
		if("raise_hands")
			possible_actions += "face_wall"
			possible_actions += "raise_hands"
		if("drop_weapon")
			possible_actions += "drop_to_floor"
			possible_actions += "drop_weapon"
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

/datum/component/aiming/proc/fire() //Todo
	var/obj/item/held = user.get_active_held_item()
	if(held != parent)
		stop_aiming()
		return FALSE
	if(istype(parent, /obj/item/gun)) //This is mostly for guns. Otherwise you just sort of wave it menacingly at them.
		var/obj/item/gun/G = parent
		G.afterattack(target, user, null, null, TRUE)
		stop_aiming()
		return TRUE
	if(isitem(parent))
		var/obj/item/I = parent
		I.afterattack(target, user)
		user.visible_message("<span class='warning'>[user] waves [parent] around menacingly!</span>") //lets you still aim at someone with a wrench / knife for epic psycho RP!
		stop_aiming()

/datum/component/aiming/proc/stop_aiming()
	if(target)
		UnregisterSignal(target, COMSIG_MOB_ITEM_DROPPED)
		UnregisterSignal(target, COMSIG_MOB_ITEM_EQUIPPED)
		UnregisterSignal(target, COMSIG_LIVING_STATUS_PARALYZE)
	user = null
	target = null

/mob/living/pointed(atom/A as mob|obj|turf in view())
	if(incapacitated())
		return FALSE
	if(HAS_TRAIT(src, TRAIT_DEATHCOMA))
		return FALSE
	var/obj/item/held = get_active_held_item()
	var/datum/component/aiming/aiming = held?.GetComponent(/datum/component/aiming)
	if(aiming && isliving(A))
		aiming.aim(src, A)
	. = ..()
