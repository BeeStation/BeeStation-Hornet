/obj/item/weebstick
	name = "Nanoforged Katana" //need to remove all weebstick with "nanoforged katana", but weebstick is funny. depends on outside opinions.
	desc = "Glorious space nippon steel, folded a million times, producing the finest blade known to mankind. \
			After downing an opponent, sheathe it to prepare yourself for an opening strike. \
			When primed and sheathed, click anywhere to dash forward, severely cutting up anyone in your way. "
			//same as uplink desc. better desc needed
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "weeb_blade"
	item_state = "weeb_blade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	w_class = WEIGHT_CLASS_BULKY
	force = 26
	throwforce = 70
	throw_speed = 3
	throw_range = 7
	sharpness = IS_SHARP_ACCURATE
	embedding = list( "pain_mult" = 0, "jostle_pain_mult" = 0, "embed_chance" = 300, "armour_block" = 100, "fall_chance" = 0, "ignore_throwspeed_threshold" = TRUE)
	// Last ditch effort to kill someone. Obviously, terrible idea unless the situation is desperate, as it WILL embed and WILL need surgery to remove. No extra embed damage tho, so as to not make it op.
	hitsound = 'sound/weapons/anime_slash.ogg'
	armour_penetration = 40
	block_level = 2
	block_upgrade_walk = 0 // Base desword blocking, but no possible improvements.
	block_power = 50 //lower block power tho.
	block_sound = 'sound/weapons/egloves.ogg' //that's a terrible parry sound
	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "diced", "cut")
	var/primed = FALSE // necessary for anime bullshit, determines dash attack readiness
	// it's cooler to put it back into the sheathe then pull it out into a dash *teleports behind u, for peak animuh
	var/mob/living/owner // necessary to proc predash through on_enter_storage, which doesn't give the user. equipped doesn't work here.
	var/dash_sound = 'sound/weapons/unsheathed_blade.ogg'
	var/beam_effect = "blood_beam"
	var/phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/cult/phase
	COOLDOWN_DECLARE(katanalinking_cd)

/obj/item/weebstick/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 25, 90, 5) //Not made for scalping victims, but will work nonetheless

/obj/item/weebstick/suicide_act(mob/user)
	if(prob(50))
		user.visible_message("<span class='suicide'>[user] carves deep into [user.p_their()] torso! It looks like [user.p_theyre()] trying to commit seppuku...</span>")
	else
		user.visible_message("<span class='suicide'>[user] carves a grid into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/obj/item/weebstick/attack(mob/living/victim)
	if(iscarbon(victim))
		var/prevstat = victim.stat //save original state
		. = ..() // run attack
		if(victim.mind && victim.stat == SOFT_CRIT && victim.stat != prevstat) //when they're in crit but they weren't before the attack, prime it
			primed = TRUE
	else
		var/prevstat = victim.stat
		. = ..()
		if(victim.mind && victim.stat == DEAD && victim.stat != prevstat) //sadly silicons/simplemobs have to die.
			primed = TRUE

/obj/item/weebstick/attack_self(mob/living/carbon/user)
	. = ..()
	if (user != owner)
		COOLDOWN_START(src, katanalinking_cd, 5 SECONDS) // doesnt work ? no runtime/bug.
		owner = user
		var/opposite_active_arm = BODY_ZONE_R_ARM
		if(!owner.active_hand_index % 2) // no direct function for getting the opposite body zone of the current active hand. Uses the hand index to be able to assign the correct zone;
		// since you can have more than two hands, the modulo returns 0 or 1 depending if it's a right or left one.
			opposite_active_arm = BODY_ZONE_L_ARM
		owner.apply_damage(20, BRUTE, opposite_active_arm, FALSE, TRUE)
		primed = TRUE //freebie
		//add bleeding effect, too. dk how strong.
		//log_combat()
		//desc here
	//Becoming the owner damages the user 20 damage and allows them to use the dash attack. anyone can become owner, but need sheathe for the dash.

/obj/item/weebstick/on_exit_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/weebstick/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/unsheath.ogg', 25, TRUE)
		B.update_icon()
		//desc here

/obj/item/weebstick/on_enter_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/weebstick/weebbelt = S.real_location()
	if(istype(weebbelt))
		playsound(weebbelt, 'sound/items/sheath.ogg', 25, TRUE)
		weebbelt.update_icon()
		//desc here
		if(primed) // if found on owner & primed, then allow for dash. else, no.
			//it's a struggle to get the owner starting from the belt. todo. also check belt is on belt slot, so it doesnt activate in boh. not important tho
			RegisterSignal(owner, COMSIG_MOB_CLICKON, .proc/predash)
	return

/obj/item/weebstick/proc/predash(mob/user, atom/location, params)
	SIGNAL_HANDLER

	if(!(location in view(user.client.view,user)))
		update_icon() //need to find a way to call the storage belt, can't figure out how to update without a signal otherwise.
		return // shouldn't happen, but better to have this. probable if lag high, and someone clicks then moves too far before it gets processed? add desc for that
	if(!user.put_in_active_hand(src))
		to_chat(user,"<span class='warning'>Your active hand needs to be empty for you to dash!</span>")
		return
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	update_icon()
	primed = FALSE //reset primed
	primed_attack(location, user, src)
	if(CanReach(location))
		melee_attack_chain(user, location, params) //normal sword slash on final target, for added oomph
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/weebstick/proc/primed_attack(atom/target, mob/living/user, obj/item/weebstick/sword)
	var/turf/end = get_turf(user)
	var/turf/start = get_turf(user)
	var/obj/spot1 = new phaseout(start, user.dir)
	var/halt = FALSE
	// Stolen dash code from ninja
	for(var/T in getline(start, get_turf(target)))
		var/turf/tile = T
		for(var/mob/living/victim in tile)
			if(victim != user)
				var/Pdash = victim.stat
				playsound(victim, 'sound/weapons/anime_slash.ogg', 10, TRUE)
				victim.take_bodypart_damage(45) // High damage, but no armor penetration.
				if(victim.stat == SOFT_CRIT && victim.stat != Pdash)
					primed = TRUE
				//log_combat()
		// Unlike actual ninjas, we stop noclip-dashing here.
		if(isclosedturf(T))
			halt = TRUE
		for(var/obj/O in tile)
			// We ignore mobs as we are cutting through them
			if(!O.CanPass(user, tile))
				halt = TRUE
		if(halt)
			break
		else
			end = T
	 user.forceMove(end) // YEET
	 playsound(start, dash_sound, 35, TRUE)
	 var/obj/spot2 = new phasein(end, user.dir)
	 spot1.Beam(spot2, beam_effect, time=20) //magical bullshit causing the graphical bug
	 // When dashing, will draw a beam line from the start (spot1) to every tile the user goes through
	 // yet it should only draw from start to end (spot2), as the "end" var doesn't change at all, and beam doesn't get called more than once
	 // I genuinely don't understand this bug.
	 // on the other hand, although i'd like the weird lines to go, i'd like the cult human outlines to stay, so as to show players what tiles they actually cut through, as it isn't clear on non straight lines.
	 user.visible_message("<span class='warning'>In a flash of red, [user] draws [user.p_their()] blade!</span>", "<span class='notice'>You dash forward while drawing your weapon!</span>", "<span class='warning'>You hear a blade slice through the air at impossible speeds!</span>")

/obj/item/storage/belt/weebstick
	name = "nanoforged blade sheath"
	desc = "It yearns to bathe in the blood of your enemies... but you hold it back!" //better desc
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "weeb_sheath"
	item_state = "sheath" // need sprite.
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/dash_sound = 'sound/weapons/unsheathed_blade.ogg'

/obj/item/storage/belt/weebstick/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/weebstick
		))

/obj/item/storage/belt/weebstick/examine(mob/user)
	. = ..()
	if(length(contents))
		. += "<span class='info'>Alt-click or Shift+E to instantly draw it.</span>"

/obj/item/storage/belt/weebstick/AltClick(mob/user)
	if(!iscarbon(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(length(contents))
		var/obj/item/weebstick/sword = contents[1]
		playsound(user, dash_sound, 25, TRUE)
		user.visible_message("<span class='notice'>[user] swiftly draws \the [sword].</span>", "<span class='notice'>You draw \the [sword].</span>")
		user.put_in_hands(sword)
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/storage/belt/weebstick/update_icon()
	icon_state = "weeb_sheath"
	item_state = "sheath" // need sprite
	if(length(contents))
		var/obj/item/weebstick/sword = contents[1]
		if(sword.primed)
			icon_state += "-primed"
		else
			icon_state += "-blade"
		item_state += "-sabre" //need sprite

/obj/item/storage/belt/weebstick/PopulateContents()
	//Time to generate names now that we have the sword
	var/n_title = pick(GLOB.ninja_titles)
	var/n_name = pick(GLOB.ninja_names)
	var/obj/item/weebstick/sword = new /obj/item/weebstick(src)
	sword.name = "[n_title] blade of clan [n_name]"
	name = "[n_title] scabbard of clan [n_name]"
	update_icon()
