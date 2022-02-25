/obj/item/weebstick
	name = "Nanoforged Katana"
	desc = "Glorious space nippon steel, folded a million times, producing the finest blade known to mankind. \
			After downing an opponent, sheathe it to prepare yourself for an opening strike. \
			When primed and sheathed, click anywhere to dash forward, severely cutting up anyone in your way. "
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
	embedding = list("embed_chance" = 300, "armour_block" = 60, "max_pain_mult" = 15)
	// Last ditch effort to kill someone. Obviously, terrible idea unless the situation is desperate, as it WILL embed and WILL need surgery to remove.
	hitsound = 'sound/weapons/anime_slash.ogg'
	armour_penetration = 40
	block_level = 2
	block_upgrade_walk = 0 // Base desword blocking, but no possible improvements.
	block_power = 60
	block_sound = 'sound/weapons/egloves.ogg'
	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE
	max_integrity = 200
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0, "energy" = 0, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 100, "acid" = 70, "stamina" = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	attack_verb = list("attacked", "slashed", "stabbed", "sliced", "diced", "cut")
	var/primed = TRUE // necessary for anime bullshit, determines dash attack readiness
	// it's cooler to put it back into the sheathe then pull it out into a dash *teleports behind u, for peak animuh

/obj/item/weebstick/Initialize()
	. = ..()
	AddComponent(/datum/component/butchering, 25, 90, 5) //Not made for scalping victims, but will work nonetheless

/obj/item/weebstick/attack(mob/living/M)
    var/P = M.stat //save original state
    . = ..() // run attack
    if(M.stat == SOFT_CRIT && M.stat != P) //If state is changed, and is now crit
        primed = TRUE // prime the weapon

/obj/item/weebstick/on_exit_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/weebstick/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/unsheath.ogg', 25, TRUE)
		//unless i create a signal to differentiate normal unsheathe from a dash attack unsheathe, which would be pain, the chat will get overloaded with messages.
		//alt click has a description message for unsheating, and that's gonna cover it for the most part i believe.
		update_icon()

/obj/item/weebstick/on_enter_storage(datum/component/storage/concrete/S)
	var/obj/item/storage/belt/weebstick/B = S.real_location()
	if(istype(B))
		playsound(B, 'sound/items/sheath.ogg', 25, TRUE)
		update_icon()
		//wish i could have put special desc for priming and unpriming here, but alas, i cana't seem to make it work

/obj/item/weebstick/suicide_act(mob/user)
	if(prob(50))
		user.visible_message("<span class='suicide'>[user] carves deep into [user.p_their()] torso! It looks like [user.p_theyre()] trying to commit seppuku...</span>")
	else
		user.visible_message("<span class='suicide'>[user] carves a grid into [user.p_their()] chest! It looks like [user.p_theyre()] trying to commit sudoku...</span>")
	return (BRUTELOSS)

/obj/item/storage/belt/weebstick
	name = "nanoforged blade sheath"
	desc = "It yearns to bathe in the blood of your enemies... but you hold it back!"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "weeb_sheath"
	item_state = "sheath" // need sprite
	w_class = WEIGHT_CLASS_BULKY
	force = 3
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/dash_sound = 'sound/weapons/unsheathed_blade.ogg'
	var/beam_effect = "blood_beam"
	var/phasein = /obj/effect/temp_visual/dir_setting/cult/phase
	var/phaseout = /obj/effect/temp_visual/dir_setting/cult/phase

/obj/item/storage/belt/weebstick/ComponentInitialize()
	. = ..()
	var/datum/component/storage/STR = GetComponent(/datum/component/storage)
	STR.max_items = 1
	STR.rustle_sound = FALSE
	STR.max_w_class = WEIGHT_CLASS_BULKY
	STR.can_hold = typecacheof(list(
		/obj/item/weebstick
		)) // if other items are allowed in, this should severely fuck up the code. shouldn't happen tho
	if(length(contents))
		var/obj/item/weebstick/sword = contents[1]
		if(sword.primed)
			RegisterSignal(src, COMSIG_CLICK, .proc/afterattack) // i thought this was the way forward, after many hours. it wasn't.

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

/obj/item/storage/belt/weebstick/afterattack(atom/A, mob/living/user, proximity_flag, params)
	. = ..()
	var/primed = FALSE
	var/obj/item/weebstick/sword = contents[1]
	if(length(contents))// in case the sheath is empty, so it doesn't return null.
		primed = sword.primed
	if(primed)
		if(!user.put_in_inactive_hand(sword))
			to_chat(user,"<span class='warning'>You need a free hand!</span>")
			return
		if(!(A in view(user.client.view,user)))
			return
		sword.primed = FALSE //reset primed
		update_icon()
		primed_attack(A, user, sword) // since sword has been put in hand, can't redefine sword in primed_attack.
		if(CanReach(A, sword))
			sword.melee_attack_chain(user, A, params) //normal sword slash on final target.
		user.swap_hand()

/obj/item/storage/belt/weebstick/proc/primed_attack(atom/target, mob/living/user, obj/item/weebstick/sword)
	var/turf/end = get_turf(user)
	var/turf/start = get_turf(user)
	var/obj/spot1 = new phaseout(start, user.dir)
	var/halt = FALSE
	// Stolen dash code
	for(var/T in getline(start, get_turf(target)))
		var/turf/tile = T
		for(var/mob/living/victim in tile)
			if(victim != user)
				var/Pdash = victim.stat
				playsound(victim, 'sound/weapons/anime_slash.ogg', 10, TRUE)
				victim.take_bodypart_damage(45) // High damage, but no armor penetration.
				if(victim.stat == SOFT_CRIT && victim.stat != Pdash)
					sword.primed = TRUE
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
	 spot1.Beam(spot2, beam_effect, time=20)
	 user.visible_message("<span class='warning'>In a flash of red, [user] draws [user.p_their()] blade!</span>", "<span class='notice'>You dash forward while drawing your weapon!</span>", "<span class='warning'>You hear a blade slice through the air at impossible speeds!</span>")

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
