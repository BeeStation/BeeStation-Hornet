/obj/item/nanoforgedkatana
	name = "Nanoforged Katana"
	desc = "Glorious space nippon steel, folded a million times, producing the finest blade known to mankind. \
			This blade seems to transmit knowledge of how to use its powers directly to its owner."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "nanoforgedkatana"
	item_state = "nanoforgedkatana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	obj_flags = UNIQUE_RENAME
	w_class = WEIGHT_CLASS_BULKY
	force = 30
	throwforce = 70
	throw_speed = 3
	throw_range = 7
	sharpness = IS_SHARP_ACCURATE
	embedding = list( "pain_mult" = 0, "jostle_pain_mult" = 0, "embed_chance" = 300, "armour_block" = 100, "fall_chance" = 0, "ignore_throwspeed_threshold" = TRUE)
	// Last ditch effort to kill someone. Obviously, terrible idea unless the situation is desperate, as it WILL embed and WILL need surgery to remove. No extra embed damage tho, so as to not make it op.
	hitsound = 'sound/weapons/anime_slash.ogg'
	armour_penetration = 75
	block_level = 2
	block_upgrade_walk = 0 // Base desword blocking, but no possible improvements.
	block_power = 60 //lower block power.
	block_sound = 'sound/weapons/egloves.ogg' //placeholder
	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "diced", "cut")
	var/linking_time = 40
	var/feeding_time = 100
	var/primed = FALSE // necessary for anime bullshit, determines dash attack readiness
	var/mob/living/owner //defining an owner is, as far as I know, necessary to allow on_enter_storage to register COMSIG_CLICKON. Equipped would have done the job much better, but doesn't work when inserting into storage.
	var/obj/item/storage/belt/nanoforgedkatana/current_sheathe //needed to prevent wacky shit happening by removing the blade after it is primed.
	var/dash_sound = 'sound/weapons/unsheathed_blade.ogg'
	var/beam_effect = "blood_beam"
	var/phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/cult/phase
	actions_types = list(/datum/action/item_action/nanoforgedkatana)

/obj/item/nanoforgedkatana/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 25, 90, 5) //Not made for scalping victims, but will work nonetheless

/obj/item/nanoforgedkatana/suicide_act(mob/user)
	if(prob(50))
		user.visible_message("<span class='suicide'>[user] carves deep into [user.p_their()] torso! It looks like [user.p_theyre()] trying to commit seppuku...</span>")
	else
		user.visible_message("<span class='suicide'>[user] carves a grid into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/obj/item/nanoforgedkatana/attack(mob/living/victim)
	if(iscarbon(victim))
		var/prevstat = victim.stat //save original state
		. = ..()
		if(victim.mind && victim.stat == SOFT_CRIT && victim.stat != prevstat) //when they're in crit but they weren't before the attack, prime it
			primed = TRUE
		//if(prob(1)) , owner says "show me a good time, [victim]"
	else
		var/prevstat = victim.stat
		. = ..()
		if(victim.mind && victim.stat == DEAD && victim.stat != prevstat) //sadly silicons/simplemobs have to die for the weapon to be primed.
			primed = TRUE

/obj/item/nanoforgedkatana/attack_self(mob/living/carbon/user)
	. = ..()
	var/opposite_active_arm = BODY_ZONE_R_ARM
	if(!(user.active_hand_index % 2)) // no direct function for getting the opposite body zone of the current active hand. Uses the hand index to be able to assign the correct zone;
		// since you can have more than two hands, the modulo returns 0 or 1 depending if it's a right or left one.
		opposite_active_arm = BODY_ZONE_L_ARM
	if (user != owner) // linking = true? needed?
		if (do_after(user, linking_time, needhand=TRUE, target = user, progress = TRUE))
			owner = user
			owner.apply_damage(10, BRUTE, opposite_active_arm, FALSE, TRUE)
			primed = TRUE
			user.bleed(30)//about 4%
			//desc
			return
	if (user == owner)
		if (do_after(user, feeding_time, needhand = TRUE, target = user, progress = TRUE))
			user.apply_damage(20, BRUTE, opposite_active_arm, FALSE, TRUE)
			primed = TRUE
			user.bleed(50)//about 9%
			//desc
			return
	//anyone can become owner, but need sheathe for the dash.

/obj/item/nanoforgedkatana/on_exit_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/nanoforgedkatana/nanobelt = S.real_location()
	if(istype(nanobelt))
		playsound(nanobelt, 'sound/items/unsheath.ogg', 25, TRUE)
		nanobelt.update_icon()
		update_icon()

/obj/item/nanoforgedkatana/on_enter_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/nanoforgedkatana/nanobelt = S.real_location()
	if(istype(nanobelt))
		playsound(nanobelt, 'sound/items/sheath.ogg', 25, TRUE)
		nanobelt.update_icon()
		update_icon()
		if(primed) // if primed, then allow dash.
			current_sheathe = nanobelt
			RegisterSignal(owner, COMSIG_MOB_CLICKON, .proc/predash)
	return

/obj/item/nanoforgedkatana/proc/predash(mob/user, atom/location, params)
	SIGNAL_HANDLER

	if((!length(current_sheathe.contents)) || current_sheathe.current_wearer != owner)
		to_chat(user,"<span class='warning'>The blade needs to be in its sheathe, on its owner's body, in order to dash !")
		UnregisterSignal(owner, COMSIG_MOB_CLICKON)
		return // with enough fuckery, the blade can be taken out before the dash. Which is bad.
	if(!(location in view(user)))
		to_chat(user,"<span class='warning'>The selected dash location is out of view !")
		return //probable if lag high, and someone clicks then moves too far before it gets processed.
	if(!user.put_in_active_hand(src))
		to_chat(user,"<span class='warning'>Your active hand needs to be empty for you to dash!</span>")
		return
	current_sheathe.update_icon()
	update_icon()
	UnregisterSignal(owner, COMSIG_MOB_CLICKON)
	primed = FALSE //reset primed
	primed_attack(location, user, src)
	if(CanReach(location))
		melee_attack_chain(user, location, params) //normal sword slash on final target.
	return COMSIG_MOB_CANCEL_CLICKON

/obj/item/nanoforgedkatana/proc/primed_attack(atom/target, mob/living/user, obj/item/nanoforgedkatana/sword)
	var/turf/start = get_turf(user)
	var/halt = FALSE
	var/dashdir = get_dir(start, get_turf(target))
	var/prevturf
	var/newdir //prevturf allows to stop *before* a blocked tile, not after. newdir helps for tiles with orientation based restrictions.
	user.setDir(dashdir)
	// Stolen dash code from ninja
	for(var/T in getline(start, get_turf(target)))
		var/turf/tile = T
		newdir = get_dir(prevturf, tile)
		user.setDir(newdir)
		for(var/mob/living/victim in tile)
			if(victim != user)
				var/Pdash = victim.stat
				playsound(victim, 'sound/weapons/anime_slash.ogg', 10, TRUE)
				victim.take_bodypart_damage(35) // High damage, but no armor penetration.
				if(victim.stat == SOFT_CRIT && victim.stat != Pdash)
					primed = TRUE
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
			prevturf = tile
		new phaseout(prevturf, newdir) // can be removed, but it helps to visualize what tiles your character actually walked through. A straight line doesnt represent byond's "getline".
	user.forceMove(prevturf)
	playsound(start, dash_sound, 35, TRUE)
	var/obj/spot1 = new phaseout(start, dashdir)
	var/obj/spot2 = new phasein(prevturf, dashdir)
	spot1.Beam(spot2, beam_effect, time=20)
	user.visible_message("<span class='warning'>In a flash of red, [user] draws [user.p_their()] blade!</span>", "<span class='notice'>You dash forward while drawing your weapon!</span>", "<span class='warning'>You hear a blade slice through the air at impossible speeds!</span>")

/obj/item/nanoforgedkatana/ui_action_click(mob/user, actiontype)
	//checks done before, so
	var/attack_dir = user.dir
	to_chat(user, "test complete!")
	//depending on attack dir, create a way with getstep to get a box that's 3x2 large in such a direction, and make a sprite appear in each of those + attack.

/obj/item/storage/belt/nanoforgedkatana
	name = "nanoforged blade sheath"
	desc = "It yearns to bathe in the blood of your enemies... but you hold it back!"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "weeb_sheath"
	item_state = "sheath" // need sprite.
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/dash_sound = 'sound/weapons/unsheathed_blade.ogg'
	var/mob/living/current_wearer

/obj/item/storage/belt/nanoforgedkatana/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/nanoforgedkatana
		))

/obj/item/storage/belt/nanoforgedkatana/examine(mob/user)
	. = ..()
	if(length(contents))
		. += "<span class='info'>Alt-click or Shift+E to instantly draw it.</span>"

/obj/item/storage/belt/nanoforgedkatana/AltClick(mob/user)
	if(!iscarbon(user) || !user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		return
	if(length(contents))
		var/obj/item/nanoforgedkatana/sword = contents[1]
		playsound(user, dash_sound, 25, TRUE)
		user.visible_message("<span class='notice'>[user] swiftly draws \the [sword].</span>", "<span class='notice'>You draw \the [sword].</span>")
		user.put_in_hands(sword)
		update_icon()
	else
		to_chat(user, "<span class='warning'>[src] is empty!</span>")

/obj/item/storage/belt/nanoforgedkatana/equipped(mob/living/user)
	current_wearer = user
	. = ..()// could equip, then unequip and manually use the katana while in hand -
	//then give it to someone else without it touching the ground and them putting it in belt/boh
	//but that's so contrived when you could just change owner.

/obj/item/storage/belt/nanoforgedkatana/on_enter_storage()
	current_wearer = null
	. = ..()

/obj/item/storage/belt/nanoforgedkatana/dropped(mob/user)
	current_wearer = null
	. = ..()

/obj/item/storage/belt/nanoforgedkatana/update_icon()
	icon_state = "nanoforgedsheath"
	item_state = "sheath" // need sprite, default cap sheath atm.
	if(length(contents))
		var/obj/item/nanoforgedkatana/sword = contents[1]
		if(sword.primed)
			icon_state += "-primed"
		else
			icon_state += "-blade"
		item_state += "-sabre" //need sprite

/obj/item/storage/belt/nanoforgedkatana/PopulateContents()
	//Time to generate names now that we have the sword
	var/n_title = pick(GLOB.ninja_titles)
	var/n_name = pick(GLOB.ninja_names)
	var/obj/item/nanoforgedkatana/sword = new /obj/item/nanoforgedkatana(src)
	sword.name = "[n_title] blade of clan [n_name]"
	name = "[n_title] scabbard of clan [n_name]"
	update_icon()
