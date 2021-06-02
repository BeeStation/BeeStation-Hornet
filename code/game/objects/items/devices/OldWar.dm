//Items for the Old War bundle//

/obj/item/signaler_art
	name = "suspicious red signaler"
	desc = "A radio with with a built in signaler for calling an air support in a specific target, which you designate using that beacon."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "blpad-remote"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	var/shut_down = FALSE
	var/can_be_used_by_everyone = FALSE //can be used by everyone ???????????
	var/failed_uses = 0
	var/shot_delay = 15
	var/shots = 5
	var/obj/item/beacon_art/linked
	var/cooldown = 0
	var/cooldown_time = 3000

/obj/item/signaler_art/Destroy()
	linked = null
	..()

/obj/item/signaler_art/Initialize()
	. = ..()
	playsound(get_turf(src), 'sound/effects/artsignaler.ogg', 50, 0, 0)
	if(!linked)
		var/obj/item/beacon_art/beacon = new(src.loc)
		linked = beacon
		beacon.linked = src

/obj/item/signaler_art/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It goes on a [cooldown_time / 10] second cooldown after a successful call.</span>"
	if(cooldown <= world.time)
		. += "<span class='notice'>[src] is ready.</span>"
	else
		var/time_show = (cooldown - world.time) / 10
		. += "<span class='notice'>[time_show] seconds left for the next call.</span>"
	if(!linked)
		. += "<span class='warning'>You can't figure what beacon is it linked to!</span>"

/obj/item/signaler_art/attack_self(mob/living/user)
	..()
	if(!linked)
		to_chat(user, "<span class='notice'>[src] is not linked to a beacon!</span>")
		return
	if(cooldown >= world.time)
		to_chat(user, "<span class='warning'>[src] is still recharging!</span>")
		return
	if(shut_down)
		to_chat(user, "<span class='danger'>No response.</span>")
		return
	var/list/factions = usr.faction
	if(!(ROLE_SYNDICATE in factions) && !can_be_used_by_everyone)
		failed_uses = failed_uses + 1
		cooldown = world.time + 50
		playsound(get_turf(src), 'sound/effects/radio2.ogg', 50, 1)
		upsetradiophrase(user)
		return
	playsound(get_turf(src), 'sound/effects/artsignaler.ogg', 50, 0, 0)
	cooldown = world.time + cooldown_time
	playsound(get_turf(src), 'sound/effects/radio1.ogg', 50, 1)
	sleep(40)
	acceptingphrase(user)
	playsound(get_turf(src), 'sound/effects/radio2.ogg', 50, 1)
	failed_uses = initial(failed_uses)
	sleep(30)
	strike()

/obj/item/signaler_art/proc/upsetradiophrase(mob/living/user)
	if(failed_uses <= 2)
		var/list/possible_angryphrases1 = list("<span class='bold'> \"Sorry, didn't hear. What did you say?\"</span>",
												"<span class='bold'> \"What did you say?\"</span>",
												"<span class='bold'> \"Sorry, static noises. Can you repeat?\"</span>",
												"<span class='bold'> \"Sorry, what?..\"</span>")
		var/chosen_angryphrase1 = pick(possible_angryphrases1)
		to_chat(user, chosen_angryphrase1)
		return
	if(failed_uses <= 3)
		var/list/possible_angryphrases2 = list("<span class='bold'> \"Who the fuck are you and how did you get this thing?!\"</span>",
												"<span class='bold'> \"Get the fuck off this channel! I don't recognize your voice!\"</span>",
												"<span class='bold'> \"Wait, who are you?\"</span>")
		var/chosen_angryphrase2 = pick(possible_angryphrases2)
		to_chat(user, chosen_angryphrase2)
		return
	if(failed_uses <= 10)
		var/list/possible_angryphrases3 = list("<span class='bold'> \"Fuck off!\"</span>",
												"<span class='bold'> \"No.\"</span>",
												"<span class='bold'> \"Nope.\"</span>",
												"<span class='bold'> \"Nah.\"</span>",
												"<span class='bold'> \"Don't even think about it.\"</span>")
		var/chosen_angryphrase3 = pick(possible_angryphrases3)
		to_chat(user, chosen_angryphrase3)
		return
	if(failed_uses <= 11)
		var/list/possible_angryphrases4 = list("<span class='bold'> \"I'm done.\"</span>",
												"<span class='bold'> \"I'm shutting this thing off.\"</span>",
												"<span class='bold'> \"Bye.\"</span>",
												"<span class='bold'> \"Fuck this, they all probably dead.\"</span>")
		var/chosen_angryphrase4 = pick(possible_angryphrases4)
		to_chat(user, chosen_angryphrase4)
		shut_down = TRUE

/obj/item/signaler_art/proc/acceptingphrase(mob/living/user)
	if(failed_uses == 0)
		var/list/possible_lines = list("<span class='bold'> \"This is station, copy that. Artillery strike is inbound.\"</span>",
									"<span class='bold'> \"Understood, agent. Firing artillery at the target.\"</span>",
									"<span class='bold'> \"Artillery strike is inbound, take cover.\"</span>")
		var/chosen_line = pick(possible_lines)
		to_chat(user, chosen_line)
		return
	if(failed_uses == 3)
		var/list/possible_lines2 = list("<span class='bold'> \"Ah, it's actually you. Sorry, didn't recognize that time. Sending artillery strike.\"</span>",
										"<span class='bold'> \"Oh, my bad. Sending artillery.\"</span>",
										"<span class='bold'> \"I actually thought you're the bad guy. Artillery strike incoming.\"</span>")
		var/chosen_line2 = pick(possible_lines2)
		to_chat(user, chosen_line2)
		return
	if(failed_uses > 3) //reveals if someone tried to use the radio before
		var/list/possible_lines3 = list("<span class='bold'> \"Finally. I've got a very naughty person on the radio before you came. \
										Sending artillery strike.\"</span>",
										"<span class='bold'> \"Good to know you're actually alive. I've had a very deep conversation with a person. \
										Artillery strike incoming.\"</span>",
										"<span class='bold'> \"Someone tried to use us as their toy, but they didn't pay us for this. \
										Request accepted, artillery incoming.\"</span>")
		var/chosen_line3 = pick(possible_lines3)
		to_chat(user, chosen_line3)

/obj/item/signaler_art/proc/strike()
	if(!linked)
		return
	else
		priority_announce("Bluespace artillery fire detected. Brace for impact.")
		var/turf/T = get_turf(linked)
		var/datum/callback/cb = CALLBACK(src, .proc/shot, T)
		for(var/i in 1 to shots)
			addtimer(cb, (i - 1)*shot_delay)

/obj/item/signaler_art/proc/shot(turf/T)
		var/loc = locate(T.x, T.y, T.z)
		var/loc2 = locate(T.x + rand(-3,3), T.y + rand(-3,3), T.z)
		var/loc3 = locate(T.x + rand(-2,2), T.y + rand(-2,2), T.z)
		var/loc4 = locate(T.x + rand(-1,1), T.y + rand(-1,1), T.z)
		var/list/locations = list(loc, loc2, loc3, loc4)
		playsound(T, 'sound/weapons/beam_sniper.ogg', 70, 0, 5)
		var/chosen_loc = pick(locations)
		var/obj/effect/targ = new /obj/effect/pod_landingzone_effect(chosen_loc)
		sleep(20)
		qdel(targ)
		explosion(chosen_loc, 1, 2, 6)

/obj/item/signaler_art/not_restricted
	can_be_used_by_everyone = TRUE

/obj/item/beacon_art
	name = "suspicious red beacon"
	desc = "It looks like a very suspicious verson of GPS"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "gps-art"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/obj/item/beacon_art/linked

/obj/item/beacon_art/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It can be picked up after a usage.</span>"
	. += "<span class='notice'>You can use a screwdriver to permanently remove the link from the beacon.</span>"
	if(!linked)
		. += "<span class='warning'>You can see the lights on the beacon are off.</span>"

/obj/item/beacon_art/attackby(obj/item/I, mob/user, params)
	..()
	if(I.tool_behaviour == TOOL_SCREWDRIVER && linked)
		to_chat(user, "<span class='notice'>You remove the link from the beacon, preventing future artillery strikes.</span>")
		linked = null

/datum/action/item_action/kamikaze_vest
	name = "Activate the vest"
	desc = "Tightens the vest and starts the bomb's timer."
	icon_icon = 'icons/mob/actions/actions_spells.dmi'
	button_icon_state = "sacredflame"

/obj/item/clothing/suit/armor/vest/kamikaze
	name = "kamikaze's vest"
	desc = "A vest with a bomb with an activator strapped on it. It also has small needles in it that inject user with adrenaline upon activation."
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	icon_state = "bomb"
	item_state = "bomb"
	actions_types = list(/datum/action/item_action/kamikaze_vest)
	var/activated = FALSE
	var/bombtimer = 50

/obj/item/clothing/suit/armor/vest/kamikaze/Initialize()
	. = ..()
	playsound(get_turf(src), 'sound/machines/beep.ogg', 20, 0)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 20, 0)

/obj/item/clothing/suit/armor/vest/kamikaze/examine(mob/user)
	. = ..()
	. += "<span class='notice'>The bomb is protected from impact and wont explode upon being hit with anything.</span>"
	. += "<span class='notice'>You won't be able to take off the vest upon activation because it has its spring system.</span>"
	. += "<span class='notice'>The timer is set for 5 seconds, it can't be changed and it will do an obvious sound on activation.</span>"

/obj/item/clothing/suit/armor/vest/kamikaze/ui_action_click(mob/user, action)
	activate()

/obj/item/clothing/suit/armor/vest/kamikaze/verb/activate(mob/user)
	set category = "Object"
	set name = "Activate the vest"
	set src in usr
	if(!isliving(usr))
		return
	if(activated)
		return
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_MASK_TRAIT)
	activated = TRUE
	ADD_TRAIT(usr, TRAIT_STUNIMMUNE, TRAIT_HULK)
	ADD_TRAIT(usr, TRAIT_PUSHIMMUNE, TRAIT_HULK)
	ADD_TRAIT(usr, TRAIT_CONFUSEIMMUNE, TRAIT_HULK)
	ADD_TRAIT(usr, TRAIT_NOSTAMCRIT, TRAIT_HULK)
	ADD_TRAIT(usr, TRAIT_IGNOREDAMAGESLOWDOWN, TRAIT_HULK)
	var/list/possible_lines = list("<span class='suicide'>So be it.</span>",
									"<span class='suicide'>BANZAI!</span>",
									"<span class='suicide'>Bring them hell.</span>",
									"<span class='suicide'>Kamikaze!</span>",
									"<span class='suicide'>Bye.</span>",
									"<span class='suicide'>Yes.</span>")
	var/chosen_line = pick(possible_lines)
	to_chat(usr, chosen_line)
	addtimer(CALLBACK(src, .proc/prime), bombtimer)
	playsound(get_turf(src), 'sound/items/kamikazeactivate.ogg', 50, 0, 5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beep.ogg', 40, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beeplong.ogg', 50, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beeplong.ogg', 50, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beeplong.ogg', 50, 0, 5)
	sleep(5)
	playsound(get_turf(src), 'sound/machines/beepfinal.ogg', 50, 0, 5)

/obj/item/clothing/suit/armor/vest/kamikaze/proc/prime()
	explosion(get_turf(src), 1, 5, 8)
	qdel(src)

/obj/item/backup_caller    //abstract
	name = "funny radio"
	desc = "A strange device that looks like a radio. It seems like it's used in situations when only you is not enough. SHOULDN'T SEE THIS THING YOU SHOULDN'T SEE THIS THING YOU SHOULDN'T"
	icon = 'icons/obj/telescience.dmi'
	icon_state = "bcaller"
	var/cooldown = 0
	var/cooldown_time = 2000
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_BELT
	var/Stationwide_cooldown_time = 2000
	var/Stationwide_mode = FALSE
	var/Stationwide_charges = 0
	var/list/mobs = list(/mob/living/simple_animal/hostile/retaliate/clown,
							/mob/living/simple_animal/hostile/retaliate/clown/longface,
							/mob/living/simple_animal/hostile/retaliate/clown/mutant)

/obj/item/backup_caller/examine(mob/user)
	. = ..()
	. += "<span class='notice'>[src] goes on a [cooldown_time / 10] seconds cooldown after a successful call.</span>"
	if(cooldown <= world.time)
		. += "<span class='notice'>[src] is ready.</span>"
	else
		var/time_show = (cooldown - world.time) / 10
		. += "<span class='notice'>[time_show] seconds left for the next call.</span>"
	if(!Stationwide_charges)
		. += "<span class='bold'>There are currently no \"Station-Wide mode\" charges left.</span>"
		return
	. += "<span class='bold'>Alt+Click on it to turn it's \"Station-Wide mode\" ON. Using radio with this mode will result in a wave of reinforcements sent not only to you, \
							but also across the station in very different places. This will spend one \"Station-wide mode\" \
							charge and the cooldown will be [(cooldown_time + Stationwide_cooldown_time) / 10] seconds instead \
							of default [cooldown_time / 10] seconds.</span>"
	. += "<span class='bold'>There are currently [Stationwide_charges] \"Station-Wide mode\" charges left.</span>"

/obj/item/backup_caller/AltClick(mob/user)
	..()
	if(!Stationwide_mode)
		Stationwide_mode = TRUE
		to_chat(user, "<span class='bold'>\"Station-Wide mode\" activated.</span>")
		return
	Stationwide_mode = FALSE
	to_chat(user, "<span class='bold'>\"Station-Wide mode\" deactivated.</span>")

/obj/item/backup_caller/attack_self(mob/living/user)
	..()
	if(cooldown > world.time)
		return to_chat(user, "<span class='warning'>The backup is not ready yet!</span>")
	cooldown = world.time + cooldown_time
	var/list/possible_phrases = list("<span class='bold'> \"Sending reinforcements. The next call will be available in about [cooldown_time / 10] seconds.</span>\"",
										"<span class='bold'> \"Got it, reinforcements are on the way.</span>\"",
										"<span class='bold'> \"Got way too lonely? Alright, sending it.</span>\"",
										"<span class='bold'> \"Request accepted, sending more people to your location.</span>\"",
										"<span class='bold'> \"Whatever you say. Sending your reinforcements.</span>\"")
	var/chosen_phrase = pick(possible_phrases)
	to_chat(user, chosen_phrase)
	var/datum/callback/cb = CALLBACK(src, .proc/drop)
	for(var/i in 2 to rand(4,6))
		addtimer(cb, (i - 1)*5)
	if(Stationwide_mode)
		sleep(30)
		cooldown = world.time + cooldown_time + Stationwide_cooldown_time
		sleep(50)
		priority_announce("Unindentified lifesigns detected coming aboard [station_name()]. Brace for impact.")
		var/datum/callback/cb2 = CALLBACK(src, .proc/DropStationWide)
		for(var/i in 4 to rand(5,12))
			addtimer(cb2, (i - 1)*5)
		to_chat(user, "<span class='bold'>\"[Stationwide_cooldown_time / 10] more seconds is added to prepare the next call.\"</span>")

/obj/item/backup_caller/proc/drop()
	var/chosen_mob = pick(mobs)
	var/mob/living/M = new chosen_mob
	var/list/factions = usr.faction
	if(ROLE_SYNDICATE in factions)
		M.faction = list(ROLE_SYNDICATE)
	else
		M.faction = factions
	var/turf/T = get_turf(usr)
	var/turf/R = locate(T.x + rand(-3,3), T.y + rand(-3,3), T.z)
	if(iswallturf(R) || !R)
		R = get_turf(usr)
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	M.forceMove(pod)
	new /obj/effect/pod_landingzone(R, pod)

/obj/item/backup_caller/proc/DropStationWide()
	var/chosen_mob = pick(mobs)
	var/mob/living/M = new chosen_mob
	var/list/factions = usr.faction
	if(ROLE_SYNDICATE in factions)
		M.faction = list(ROLE_SYNDICATE)
	else
		M.faction = factions
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	M.forceMove(pod)
	var/iswall_orspace = TRUE
	var/turf/T = get_random_station_turf()
	for(T in iswall_orspace)
		if(!T || iswallturf(T))
			T = get_random_station_turf()
		else
			iswall_orspace = FALSE
	new /obj/effect/pod_landingzone(T, pod)

/obj/item/backup_caller/soviet
	name = "strange looking radio"
	desc = "A device that looks like a radio. You're sure you will get response from this."
	cooldown_time = 4000
	mobs = list(/mob/living/simple_animal/hostile/russian/army,
				/mob/living/simple_animal/hostile/russian/army/army2,
				/mob/living/simple_animal/hostile/russian/army/army3,
				/mob/living/simple_animal/hostile/russian/army/army4)
	Stationwide_charges = 1
	var/restricted = TRUE

/obj/item/backup_caller/soviet/Initialize()
	. = ..()
	playsound(get_turf(src), 'sound/items/russianbackupcaller.ogg', 60, 0, 0)

/obj/item/backup_caller/soviet/attack_self(mob/living/user)
	var/list/factions = usr.faction
	if(restricted && !(ROLE_SYNDICATE in factions))
		return to_chat(user, "<span class='warning'>No response!</span>")
	if(Stationwide_mode && cooldown < world.time)
		to_chat(user, "<span class='bold'>\"The power is in numbers.\"</span>")
		playsound(get_turf(src), 'sound/items/russianbackupcaller.ogg', 60, 0, 0)
	. = ..()

/obj/item/backup_caller/soviet/drop()
	var/chosen_mob = pick(mobs)
	var/mob/living/simple_animal/hostile/russian/army/M = new chosen_mob
	M.defend_target = usr
	var/list/factions = usr.faction
	if(ROLE_SYNDICATE in factions)
		M.faction = list(ROLE_SYNDICATE)
	else
		M.faction = factions
	var/turf/T = get_turf(usr)
	var/turf/R = locate(T.x + rand(-3,3), T.y + rand(-3,3), T.z)
	if(iswallturf(R) || !R)
		R = get_turf(usr)
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	M.forceMove(pod)
	new /obj/effect/pod_landingzone(R, pod)

/obj/item/backup_caller/soviet/unrestricted
	restricted = FALSE

/obj/item/stabbing_license
	name = "Stabbing License"
	desc = "A card provided by Space London. An unknown technology will make people around you know that you are, infact, allowed to use sharp items for legal stabbing."
	icon = 'icons/obj/card.dmi'
	icon_state = "slicense2"
	lefthand_file = 'icons/mob/inhands/equipment/idcards_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/idcards_righthand.dmi'
	item_state = "orange_id"
	var/cooldown = 0
	var/cooldown_time = 60

/obj/item/stabbing_license/examine(mob/user)
	. = ..()
	. += "<span class='notice' Holding it in hand will make all your attacks with sharp items more powerful.</span>"

/obj/item/stabbing_license/attack_self(mob/user)
	if(cooldown > world.time)
		return
	cooldown = world.time + cooldown_time
	user.visible_message("<span class='userdanger'>[user] shows you their [src], mate! You got no balls to mess with them in stabbing fight, innit?</span>", "<span class='suicide'>You show your [src] to lower the morale of everyone around, innit?</span>")

/obj/item/stabbing_license/worn_overlays(isinhands)
	. = ..()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', "blessed", MOB_LAYER + 0.01)
		var/obj/item/I
		if(I.sharpness == IS_SHARP || I.sharpness == IS_SHARP_ACCURATE)
			. -= mutable_appearance('icons/effects/effects.dmi', "blessed", MOB_LAYER + 0.01)
			. += mutable_appearance('icons/effects/cult_effects.dmi', "bloodsparkles", MOB_LAYER + 0.01)
			I.attack_weight = I.attack_weight + 0.5
			I.force = I.force + 3
