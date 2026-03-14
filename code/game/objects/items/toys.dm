/* Toys!
 * Contains
 *		Balloons
 *		Fake singularity
 *		Toy gun
 *		Toy crossbow
 *		Toy swords
 *		Crayons
 *		Snap pops
 *		Mech prizes
 *		AI core prizes
 *		Toy codex gigas
 * 		Skeleton toys
 *		Cards
 *		Toy nuke
 *		Fake meteor
 *		Foam armblade
 *		Toy big red button
 *		Beach ball
 *		Toy xeno
 *      Kitty toys!
 *		Snowballs
 *		Clockwork Watches
 *		Toy Daggers
 *		Eldrich stuff
 *		Batong
 */


/obj/item/toy
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0
	custom_price = 25
	max_demand = 25

/*
 * Empty plushies before stuffing
 */
/obj/item/toy/empty_plush //not a plushie subtype because of all the code regarding breeding and weird jokes, this is just a transitory state
	name = "plush fabric"
	desc = "An empty plush fabric. Ready to be stuffed with cotton."
	icon = 'icons/obj/plushes.dmi'
	lefthand_file = 'icons/mob/inhands/plushes_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/plushes_righthand.dmi'
	icon_state = "debug"

/obj/item/toy/empty_plush/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/stack/sheet/cotton))
		var/obj/item/stack/S = I
		if(S.amount< 3)
			to_chat(user, span_danger("You need three stacks of cotton to stuff a plush!"))
			return
		if(do_after(user, 3 SECONDS))
			var/obj/item/toy/plush/P = pick(subtypesof(/obj/item/toy/plush) - /obj/item/toy/plush/carpplushie/dehy_carp)
			new P(get_turf(src))
			to_chat(user, span_notice("You make a new plush."))
			S.use(3)
			qdel(src)
			return
	. = ..()


/*
 * Balloons
 */
/obj/item/toy/waterballoon
	name = "water balloon"
	desc = "A translucent balloon. There's nothing in it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "waterballoon-e"
	inhand_icon_state = "balloon-empty"


/obj/item/toy/waterballoon/Initialize(mapload)
	. = ..()
	create_reagents(10)

/obj/item/toy/waterballoon/attack(mob/living/carbon/human/M, mob/user)
	return

/obj/item/toy/waterballoon/afterattack(atom/A as mob|obj, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if (istype(A, /obj/structure/reagent_dispensers))
		var/obj/structure/reagent_dispensers/RD = A
		if(RD.reagents.total_volume <= 0)
			to_chat(user, span_warning("[RD] is empty."))
		else if(reagents.total_volume >= 10)
			to_chat(user, span_warning("[src] is full."))
		else
			A.reagents.trans_to(src, 10, transfered_by = user)
			to_chat(user, span_notice("You fill the balloon with the contents of [A]."))
			desc = "A translucent balloon with some form of liquid sloshing around in it."
			update_icon()

/obj/item/toy/waterballoon/attackby(obj/item/I, mob/user, params)
	if(istype(I, /obj/item/reagent_containers/cup))
		if(I.reagents)
			if(I.reagents.total_volume <= 0)
				to_chat(user, span_warning("[I] is empty."))
			else if(reagents.total_volume >= 10)
				to_chat(user, span_warning("[src] is full."))
			else
				desc = "A translucent balloon with some form of liquid sloshing around in it."
				to_chat(user, span_notice("You fill the balloon with the contents of [I]."))
				I.reagents.trans_to(src, 10, transfered_by = user)
				update_icon()
	else if(I.get_sharpness())
		balloon_burst()
	else
		return ..()

/obj/item/toy/waterballoon/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..()) //was it caught by a mob?
		balloon_burst(hit_atom)

/obj/item/toy/waterballoon/proc/balloon_burst(atom/AT)
	if(reagents.total_volume >= 1)
		var/turf/T
		if(AT)
			T = get_turf(AT)
		else
			T = get_turf(src)
		T.visible_message(span_danger("[src] bursts!"),span_italics("You hear a pop and a splash."))
		reagents.expose(T)
		for(var/atom/A in T)
			reagents.expose(A)
		icon_state = "burst"
		qdel(src)

/obj/item/toy/waterballoon/update_icon()
	if(src.reagents.total_volume >= 1)
		icon_state = "waterballoon"
		inhand_icon_state = "balloon"
	else
		icon_state = "waterballoon-e"
		inhand_icon_state = "balloon-empty"

/obj/item/toy/balloon
	name = "balloon"
	desc = "No birthday is complete without it."
	icon = 'icons/obj/balloons.dmi'
	icon_state = "balloon"
	inhand_icon_state = "balloon"
	lefthand_file = 'icons/mob/inhands/misc/balloons_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/balloons_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	force = 0

	var/random_color = TRUE
	/// the string describing the name of balloon's current colour.
	var/current_color

/obj/item/toy/balloon/Initialize(mapload)
	. = ..()
	if(random_color)
		var/chosen_balloon_color = pick("red", "blue", "green", "yellow")
		name = "[chosen_balloon_color] [name]"
		icon_state = "[icon_state]_[chosen_balloon_color]"
		inhand_icon_state = icon_state

/obj/item/toy/balloon/corgi
	name = "corgi balloon"
	desc = "A balloon with a corgi face on it. For the all year good boys."
	icon_state = "corgi"
	inhand_icon_state = "corgi"
	random_color = FALSE

/obj/item/toy/balloon/syndicate
	name = "syndicate balloon"
	desc = "There is a tag on the back that reads \"FUK NT!11!\"."
	icon_state = "syndballoon"
	inhand_icon_state = "syndballoon"
	random_color = FALSE

/obj/item/toy/balloon/syndicate/pickup(mob/user)
	..()
	if(user?.mind && user.mind.has_antag_datum(/datum/antagonist, TRUE))
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)

/obj/item/toy/balloon/syndicate/dropped(mob/user)
	..()
	if(user)
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)

/obj/item/toy/balloon/syndicate/Destroy()
	if(ismob(loc))
		var/mob/M = loc
		SEND_SIGNAL(M, COMSIG_CLEAR_MOOD_EVENT, "badass_antag", /datum/mood_event/badass_antag)
	. = ..()

/*
 * Fake singularity
 */
/obj/item/toy/spinningtoy
	name = "gravitational singularity"
	desc = "\"Singulo\" brand spinning toy."
	icon = 'icons/obj/singularity.dmi'
	icon_state = "singularity_s1"
	item_flags = NO_PIXEL_RANDOM_DROP

/*
 * Toy gun: Why isn't this an /obj/item/gun?
 */
/obj/item/toy/gun
	name = "cap gun"
	desc = "Looks almost like the real thing! Ages 8 and up. Please recycle in an autolathe when you're out of caps."
	icon = 'icons/obj/guns/projectile.dmi'
	icon_state = "revolver"
	inhand_icon_state = "gun"
	worn_icon_state = "gun"
	lefthand_file = 'icons/mob/inhands/weapons/guns_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/guns_righthand.dmi'
	flags_1 =  CONDUCT_1
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=10)
	attack_verb_continuous = list("strikes", "pistol whips", "hits", "bashes")
	attack_verb_simple = list("strike", "pistol whip", "hit", "bash")
	var/bullets = 7

/obj/item/toy/gun/examine(mob/user)
	. = ..()
	. += "There [bullets == 1 ? "is" : "are"] [bullets] cap\s left."

/obj/item/toy/gun/attackby(obj/item/toy/ammo/gun/A, mob/user, params)

	if(istype(A, /obj/item/toy/ammo/gun))
		if (src.bullets >= 7)
			to_chat(user, span_warning("It's already fully loaded!"))
			return 1
		if (A.amount_left <= 0)
			to_chat(user, span_warning("There are no more caps!"))
			return 1
		if (A.amount_left < (7 - src.bullets))
			src.bullets += A.amount_left
			to_chat(user, span_notice("You reload [A.amount_left] cap\s."))
			A.amount_left = 0
		else
			to_chat(user, span_notice("You reload [7 - src.bullets] cap\s."))
			A.amount_left -= 7 - src.bullets
			src.bullets = 7
		A.update_icon()
		return 1
	else
		return ..()

/obj/item/toy/gun/afterattack(atom/target as mob|obj|turf|area, mob/user, flag)
	. = ..()
	if (flag)
		return
	if (!ISADVANCEDTOOLUSER(user))
		to_chat(user, span_warning("You don't have the dexterity to do this!"))
		return
	add_fingerprint(user)
	if (src.bullets < 1)
		user.show_message(span_warning("*click*"), MSG_AUDIBLE)
		playsound(src, 'sound/weapons/gun_dry_fire.ogg', 30, TRUE)
		return
	playsound(user, 'sound/weapons/gunshot.ogg', 100, 1)
	src.bullets--
	user.visible_message(span_danger("[user] fires [src] at [target]!"), \
						span_danger("You fire [src] at [target]!"), \
						span_italics("You hear a gunshot!"))

/obj/item/toy/ammo/gun
	name = "capgun ammo"
	desc = "Make sure to recyle the box in an autolathe when it gets empty."
	icon = 'icons/obj/ammo.dmi'
	icon_state = "357OLD-7"
	w_class = WEIGHT_CLASS_TINY
	custom_materials = list(/datum/material/iron=10, /datum/material/glass=10)
	var/amount_left = 7

/obj/item/toy/ammo/gun/update_icon_state()
	icon_state = "357OLD-[amount_left]"
	return ..()

/obj/item/toy/ammo/gun/examine(mob/user)
	. = ..()
	. += "There [amount_left == 1 ? "is" : "are"] [amount_left] cap\s left."

/*
 * Toy swords
 */
/obj/item/toy/sword
	name = "toy sword"
	desc = "A cheap, plastic replica of an energy sword. Realistic sounds! Ages 8 and up."
	icon_state = "e_sword"
	base_icon_state = "e_sword"
	inhand_icon_state = "e_sword"
	icon = 'icons/obj/transforming_energy.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("attacks", "strikes", "hits")
	attack_verb_simple = list("attack", "strike", "hit")
	/// Whether our sword has been multitooled to rainbow
	var/hacked = FALSE
	/// The color of our fake energy sword
	var/saber_color = "blue"

/obj/item/toy/sword/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/transforming, \
		throw_speed_on = throw_speed, \
		hitsound_on = hitsound, \
		clumsy_check = FALSE, \
		inhand_icon_change = FALSE, \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))
	AddElement(/datum/element/update_icon_updates_onmob)


/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Updates our icon to have the correct color, and give some feedback.
 */
/obj/item/toy/sword/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	if(user)
		balloon_alert(user, "[active ? "flicked out":"pushed in"] [src]")

	playsound(src, active ? 'sound/weapons/saberon.ogg' : 'sound/weapons/saberoff.ogg', 20, TRUE)
	update_appearance(UPDATE_ICON)
	return COMPONENT_NO_DEFAULT_MESSAGE

/obj/item/toy/sword/vv_edit_var(vname, vval)
	. = ..()
	if(vname == NAMEOF(src, saber_color))
		update_appearance(UPDATE_ICON)

/obj/item/toy/sword/update_icon_state()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		icon_state = "[base_icon_state]_on_[saber_color]" // "esword_on_red"
		inhand_icon_state = icon_state
	else
		icon_state = base_icon_state
		inhand_icon_state = base_icon_state

/obj/item/toy/sword/multitool_act(mob/living/user, obj/item/tool)
	if(hacked)
		to_chat(user, span_warning("It's already fabulous!"))
		return
	hacked = TRUE
	saber_color = "rainbow"
	to_chat(user, span_warning("RNBW_ENGAGE"))
	update_appearance(UPDATE_ICON)

// Copied from /obj/item/melee/energy/sword/attackby
/obj/item/toy/sword/attackby(obj/item/weapon, mob/living/user, params)
	if(istype(weapon, /obj/item/toy/sword))
		var/obj/item/toy/sword/attatched_sword = weapon
		if(HAS_TRAIT(weapon, TRAIT_NODROP))
			to_chat(user, span_warning("[weapon] is stuck to your hand, you can't attach it to [src]!"))
			return
		else if(HAS_TRAIT(src, TRAIT_NODROP))
			to_chat(user, span_warning("[src] is stuck to your hand, you can't attach it to [weapon]!"))
			return
		else
			to_chat(user, span_notice("You attach the ends of the two plastic swords, making a single double-bladed toy! You're fake-cool."))
			var/obj/item/dualsaber/toy/new_saber = new /obj/item/dualsaber/toy(user.loc)
			if(attatched_sword.hacked || hacked)
				new_saber.hacked = TRUE
				new_saber.saber_color = "rainbow"
			qdel(weapon)
			qdel(src)
			user.put_in_hands(new_saber)
	else
		return ..()

/*
 * Foam armblade
 */
/obj/item/toy/foamblade
	name = "foam armblade"
	desc = "It says \"Sternside Changs #1 fan\" on it."
	icon = 'icons/obj/toy.dmi'
	icon_state = "foamblade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	attack_verb_continuous = list("pricks", "absorbs", "gores")
	attack_verb_simple = list("prick", "absorb", "gore")
	w_class = WEIGHT_CLASS_SMALL
	resistance_flags = FLAMMABLE
	item_flags = ISWEAPON

/*
 * Batong
 */
/obj/item/toy/batong
	name = "batong"
	desc = "Despite being a cheap plastic imitation of a stunbaton, it can still be charged."
	icon = 'icons/obj/weapons/baton.dmi'
	icon_state = "stunbaton"
	inhand_icon_state = "baton"
	lefthand_file = 'icons/mob/inhands/equipment/security_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/security_righthand.dmi'
	attack_verb_continuous = list("batongs", "stuns", "hits")
	attack_verb_simple = list("batong", "stun", "hit")
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON

/obj/item/toy/windupToolbox
	name = "windup toolbox"
	desc = "A replica toolbox that rumbles when you turn the key."
	icon_state = "his_grace"
	inhand_icon_state = "artistic_toolbox"
	lefthand_file = 'icons/mob/inhands/equipment/toolbox_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/toolbox_righthand.dmi'
	var/active = FALSE
	icon = 'icons/obj/items_and_weapons.dmi'
	hitsound = 'sound/weapons/smash.ogg'
	drop_sound = 'sound/items/handling/toolbox_drop.ogg'
	pickup_sound = 'sound/items/handling/toolbox_pickup.ogg'
	attack_verb_continuous = list("robusts")
	attack_verb_simple = list("robust")
	item_flags = ISWEAPON

/obj/item/toy/windupToolbox/attack_self(mob/user)
	if(!active)
		icon_state = "his_grace_awakened"
		to_chat(user, span_warning("You wind up [src], it begins to rumble."))
		active = TRUE
		playsound(src, 'sound/effects/pope_entry.ogg', 100)
		Rumble()
		addtimer(CALLBACK(src, PROC_REF(stopRumble)), 600)
	else
		to_chat(user, "[src] is already active.")

/obj/item/toy/windupToolbox/proc/Rumble()
	var/static/list/transforms
	if(!transforms)
		var/matrix/M1 = matrix()
		var/matrix/M2 = matrix()
		var/matrix/M3 = matrix()
		var/matrix/M4 = matrix()
		M1.Translate(-1, 0)
		M2.Translate(0, 1)
		M3.Translate(1, 0)
		M4.Translate(0, -1)
		transforms = list(M1, M2, M3, M4)
	animate(src, transform=transforms[1], time=0.2, loop=-1)
	animate(transform=transforms[2], time=0.1)
	animate(transform=transforms[3], time=0.2)
	animate(transform=transforms[4], time=0.3)

/obj/item/toy/windupToolbox/proc/stopRumble()
	icon_state = initial(icon_state)
	active = FALSE
	animate(src, transform=matrix())

/*
 * Subtype of Double-Bladed Energy Swords
 */
/obj/item/dualsaber/toy
	name = "double-bladed toy sword"
	desc = "A cheap, plastic replica of TWO energy swords.  Double the fun!"
	force = 0
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	twohand_force = 0
	attack_verb_continuous = list("attacks", "strikes", "hits")
	attack_verb_simple = list("attack", "strike", "hit")

	canblock = FALSE
	item_flags = ISWEAPON

/obj/item/dualsaber/toy/on_wield(obj/item/source, mob/living/carbon/user)
	. = ..()
	sharpness = BLUNT
	bleed_force = 0

/obj/item/dualsaber/toy/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	return 0

/obj/item/dualsaber/toy/IsReflect() //Stops Toy Dualsabers from reflecting energy projectiles
	return 0

/obj/item/dualsaber/toy/impale(mob/living/user)//Stops Toy Dualsabers from injuring clowns
	to_chat(user, span_warning("You twirl around a bit before losing your balance and impaling yourself on [src]."))
	user.adjustStaminaLoss(25)

/obj/item/toy/katana
	name = "replica katana"
	desc = "Woefully underpowered in D20."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK
	force = 15
	throwforce = 5
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices")
	attack_verb_simple = list("attack", "slash", "stab", "slice")
	hitsound = 'sound/weapons/bladeslice.ogg'

	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	item_flags = ISWEAPON
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_SURFACE

/*
 * Snap pops
 */

/obj/item/toy/snappop
	name = "snap pop"
	desc = "Wow!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "snappop"
	w_class = WEIGHT_CLASS_TINY
	var/ash_type = /obj/effect/decal/cleanable/ash

/obj/item/toy/snappop/proc/pop_burst(n=3, c=1)
	var/datum/effect_system/spark_spread/s = new()
	s.set_up(n, c, src)
	s.start()
	new ash_type(loc)
	visible_message(span_warning("[src] explodes!"),
		span_italics("You hear a snap!"))
	playsound(src, 'sound/effects/snap.ogg', 50, 1)
	qdel(src)

/obj/item/toy/snappop/fire_act(exposed_temperature, exposed_volume)
	pop_burst()

/obj/item/toy/snappop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		pop_burst()

/obj/item/toy/snappop/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/item/toy/snappop/proc/on_entered(datum/source, H as mob|obj)
	SIGNAL_HANDLER
	if(ishuman(H) || issilicon(H)) //i guess carp and shit shouldn't set them off
		var/mob/living/carbon/M = H
		if(issilicon(H) || M.m_intent == MOVE_INTENT_RUN)
			to_chat(M, span_danger("You step on the snap pop!"))
			pop_burst(2, 0)

/obj/item/toy/snappop/phoenix
	name = "phoenix snap pop"
	desc = "Wow! And wow! And wow!"
	ash_type = /obj/effect/decal/cleanable/ash/snappop_phoenix

/obj/effect/decal/cleanable/ash/snappop_phoenix
	var/respawn_time = 300

/obj/effect/decal/cleanable/ash/snappop_phoenix/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(respawn)), respawn_time)

/obj/effect/decal/cleanable/ash/snappop_phoenix/proc/respawn()
	new /obj/item/toy/snappop/phoenix(get_turf(src))
	qdel(src)


/*
 * Mech prizes
 */
/obj/item/toy/mecha
	icon = 'icons/obj/toy.dmi'
	icon_state = "fivestarstoy"
	verb_say = "beeps"
	verb_ask = "beeps"
	verb_exclaim = "beeps"
	verb_yell = "beeps"
	w_class = WEIGHT_CLASS_TINY
	var/timer = 0
	var/cooldown = 30
	var/quiet = FALSE

/obj/item/toy/mecha/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/series, /obj/item/toy/mecha, "Mini-Mecha action figures")
	AddElement(/datum/element/toy_talk)

//all credit to skasi for toy mech fun ideas
/obj/item/toy/mecha/attack_self(mob/user)
	if(timer < world.time)
		to_chat(user, span_notice("You play with [src]."))
		timer = world.time + cooldown
		if(!quiet)
			playsound(user, 'sound/mecha/mechstep.ogg', 20, TRUE)
	else
		. = ..()

/obj/item/toy/mecha/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	if(loc == user)
		attack_self(user)

/obj/item/toy/mecha/ripley
	name = "toy Ripley MK-I"
	icon_state = "ripleytoy"
	//max_combat_health = 4 //200 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "CLAMP SMASH"

/obj/item/toy/mecha/ripleymkii
	name = "toy Ripley MK-II"
	icon_state = "ripleymkiitoy"
	//max_combat_health = 5 //250 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "GIGA DRILL BREAK"

/obj/item/toy/mecha/hauler
	name = "toy Hauler"
	icon_state = "haulertoy"
	//max_combat_health = 3 //100 integrity?
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "HAUL AWAY"

/obj/item/toy/mecha/clarke
	name = "toy Clarke"
	icon_state = "clarketoy"
	//max_combat_health = 4 //200 integrity
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "ROLL OUT"

/obj/item/toy/mecha/odysseus
	name = "toy Odysseus"
	icon_state = "odysseustoy"
	//max_combat_health = 4 //120 integrity
	//special_attack_type = SPECIAL_ATTACK_HEAL
	//special_attack_cry = "MECHA BEAM"

/obj/item/toy/mecha/gygax
	name = "toy Gygax"
	icon_state = "gygaxtoy"
	//max_combat_health = 5 //250 integrity
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "SUPER SERVOS"

/obj/item/toy/mecha/durand
	name = "toy Durand"
	icon_state = "durandtoy"
	//max_combat_health = 6 //400 integrity
	//special_attack_type = SPECIAL_ATTACK_HEAL
	//special_attack_cry = "SHIELD OF PROTECTION"

/* We dont have this one, dont reference yet.
/obj/item/toy/mecha/savannahivanov
	name = "toy Savannah-Ivanov"
	icon_state = "savannahivanovtoy"
	//max_combat_health = 7 //450 integrity
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "SKYFALL!! IVANOV STRIKE"
*/

/obj/item/toy/mecha/phazon
	name = "toy Phazon"
	icon_state = "phazontoy"
	//max_combat_health = 6 //200 integrity
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "NO-CLIP"

/obj/item/toy/mecha/honk
	name = "toy H.O.N.K."
	icon_state = "honktoy"
	//max_combat_health = 4 //140 integrity
	//special_attack_type = SPECIAL_ATTACK_OTHER
	//special_attack_type_message = "puts the opposing mech's special move on cooldown and heals this mech."
	//special_attack_cry = "MEGA HORN"

/*
/obj/item/toy/mecha/honk/super_special_attack(obj/item/toy/mecha/victim)
	playsound(src, 'sound/machines/honkbot_evil_laugh.ogg', 20, TRUE)
	victim.special_attack_cooldown += 3 //Adds cooldown to the other mech and gives a minor self heal
	combat_health++
*/

/obj/item/toy/mecha/darkgygax
	name = "toy Dark Gygax"
	icon_state = "darkgygaxtoy"
	//max_combat_health = 6 //300 integrity
	//special_attack_type = SPECIAL_ATTACK_UTILITY
	//special_attack_cry = "ULTRA SERVOS"

/obj/item/toy/mecha/mauler
	name = "toy Mauler"
	icon_state = "maulertoy"
	//max_combat_health = 7 //500 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "BULLET STORM"

/obj/item/toy/mecha/darkhonk
	name = "toy Dark H.O.N.K."
	icon_state = "darkhonktoy"
	//max_combat_health = 5 //300 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "BOMBANANA SPREE"

/obj/item/toy/mecha/deathripley
	name = "toy Death-Ripley"
	icon_state = "deathripleytoy"
	//max_combat_health = 5 //250 integrity
	//special_attack_type = SPECIAL_ATTACK_OTHER
	//special_attack_type_message = "instantly destroys the opposing mech if its health is less than this mech's health."
	//special_attack_cry = "KILLER CLAMP"

/*
/obj/item/toy/mecha/deathripley/super_special_attack(obj/item/toy/mecha/victim)
	playsound(src, 'sound/weapons/sonic_jackhammer.ogg', 20, TRUE)
	if(victim.combat_health < combat_health) //Instantly kills the other mech if it's health is below our's.
		say("EXECUTE!!")
		victim.combat_health = 0
	else //Otherwise, just deal one damage.
		victim.combat_health--
*/

/obj/item/toy/mecha/reticence
	name = "toy Reticence"
	icon_state = "reticencetoy"
	quiet = TRUE
	//max_combat_health = 4 //100 integrity
	//special_attack_type = SPECIAL_ATTACK_OTHER
	//special_attack_type_message = "has a lower cooldown than normal special moves, increases the opponent's cooldown, and deals damage."
	//special_attack_cry = "*wave"

/*
/obj/item/toy/mecha/reticence/super_special_attack(obj/item/toy/mecha/victim)
	special_attack_cooldown-- //Has a lower cooldown...
	victim.special_attack_cooldown++ //and increases the opponent's cooldown by 1...
	victim.combat_health-- //and some free damage.
*/

/obj/item/toy/mecha/marauder
	name = "toy Marauder"
	icon_state = "maraudertoy"
	//max_combat_health = 7 //500 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "BEAM BLAST"

/obj/item/toy/mecha/seraph
	name = "toy Seraph"
	icon_state = "seraphtoy"
	//max_combat_health = 8 //550 integrity
	//special_attack_type = SPECIAL_ATTACK_DAMAGE
	//special_attack_cry = "ROCKET BARRAGE"

/obj/item/toy/mecha/firefighter //rip
	name = "toy Firefighter"
	icon_state = "firefightertoy"
	//max_combat_health = 5 //250 integrity?
	//special_attack_type = SPECIAL_ATTACK_HEAL
	//special_attack_cry = "FIRE SHIELD"


/obj/item/toy/talking
	name = "talking action figure"
	desc = "A generic action figure modeled after nothing in particular."
	icon = 'icons/obj/toy.dmi'
	icon_state = "owlprize"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = FALSE
	var/messages = list("I'm super generic!", "Mathematics class is of variable difficulty!")
	var/span = "danger"
	var/recharge_time = 30

	var/chattering = FALSE
	var/phomeme

// Talking toys are language universal, and thus all species can use them
/obj/item/toy/talking/attack_alien(mob/user)
	return attack_hand(user)

/obj/item/toy/talking/attack_self(mob/user)
	if(!cooldown)
		var/list/messages = generate_messages()
		activation_message(user)
		playsound(loc, 'sound/machines/click.ogg', 20, 1)

		spawn(0)
			for(var/message in messages)
				toy_talk(user, message)
				sleep(10)

		cooldown = TRUE
		addtimer(VARSET_CALLBACK(src, cooldown, FALSE), recharge_time)
		return
	..()

/obj/item/toy/talking/proc/activation_message(mob/user)
	user.visible_message(
		span_notice("[user] pulls the string on \the [src]."),
		span_notice("You pull the string on \the [src]."),
		span_notice("You hear a string being pulled."))

/obj/item/toy/talking/proc/generate_messages()
	return list(pick(messages))

/obj/item/toy/talking/proc/toy_talk(mob/user, message)
	user.loc.visible_message("<span class='[span]'>[icon2html(src, viewers(user.loc))] [message]</span>")
	if(chattering)
		chatter(message, phomeme, user)

/*
 * AI core prizes
 */
/obj/item/toy/talking/AI
	name = "toy AI"
	desc = "A little toy model AI core with real law announcing action!"
	icon_state = "AI"

/obj/item/toy/talking/AI/generate_messages()
	return list(generate_ion_law())

/obj/item/toy/talking/codex_gigas
	name = "Toy Codex Gigas"
	desc = "A tool to help you write fictional devils!"
	icon = 'icons/obj/library.dmi'
	icon_state = "demonomicon"
	lefthand_file = 'icons/mob/inhands/misc/books_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/books_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	recharge_time = 60

/obj/item/toy/talking/codex_gigas/activation_message(mob/user)
	user.visible_message(
		span_notice("[user] presses the button on \the [src]."),
		span_notice("You press the button on \the [src]."),
		span_notice("You hear a soft click..."),
		span_notice("Nothing happens, maybe it's broken?"),)

/obj/item/toy/talking/owl
	name = "owl action figure"
	desc = "An action figure modeled after 'The Owl', defender of justice."
	icon_state = "owlprize"
	messages = list("You won't get away this time, Griffin!", "Stop right there, criminal!", "Hoot! Hoot!", "I am the night!")
	chattering = TRUE
	phomeme = "owl"

/obj/item/toy/talking/griffin
	name = "griffin action figure"
	desc = "An action figure modeled after 'The Griffin', criminal mastermind."
	icon_state = "griffinprize"
	messages = list("You can't stop me, Owl!", "My plan is flawless! The vault is mine!", "Caaaawwww!", "You will never catch me!")
	chattering = TRUE
	phomeme = "griffin"

/*
|| A Deck of Cards for playing various games of chance ||
*/



/obj/item/toy/cards
	resistance_flags = FLAMMABLE
	max_integrity = 50
	item_flags = ISWEAPON
	var/parentdeck = null
	var/deckstyle = "nanotrasen"
	var/card_hitsound = null
	var/card_force = 0
	var/card_throwforce = 0
	var/card_throw_speed = 3
	var/card_throw_range = 7
	var/list/card_attack_verb_continuous = list("attacks")
	var/list/card_attack_verb_simple = list("attack")
	var/card_sharpness

/obj/item/toy/cards/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] wrists with \the [src]! It looks like [user.p_they()] [user.p_have()] a crummy hand!"))
	playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
	return BRUTELOSS

/obj/item/toy/cards/proc/apply_card_vars(obj/item/toy/cards/newobj, obj/item/toy/cards/sourceobj) // Applies variables for supporting multiple types of card deck
	if(!istype(sourceobj))
		return

/obj/item/toy/cards/deck
	name = "deck of cards"
	desc = "A deck of space-grade playing cards."
	icon = 'icons/obj/toy.dmi'
	deckstyle = "nanotrasen"
	icon_state = "deck_nanotrasen_full"
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 15
	var/cooldown = 0
	var/obj/machinery/computer/holodeck/holo = null // Holodeck cards should not be infinite
	var/list/cards = list()
	var/original_size = 52

/obj/item/toy/cards/deck/Initialize(mapload)
	. = ..()
	populate_deck()

///Generates all the cards within the deck.
/obj/item/toy/cards/deck/proc/populate_deck()
	icon_state = "deck_[deckstyle]_full"
	for(var/suit in list("Hearts", "Spades", "Clubs", "Diamonds"))
		cards += "Ace of [suit]"
		for(var/i in 2 to 10)
			cards += "[i] of [suit]"
		for(var/person in list("Jack", "Queen", "King"))
			cards += "[person] of [suit]"

//ATTACK HAND IGNORING PARENT RETURN VALUE
//ATTACK HAND NOT CALLING PARENT
/obj/item/toy/cards/deck/attack_hand(mob/user, list/modifiers)
	draw_card(user)

/obj/item/toy/cards/deck/proc/draw_card(mob/user)
	if(isliving(user))
		var/mob/living/L = user
		if(!(L.mobility_flags & MOBILITY_PICKUP))
			return
	var/choice = null
	if(cards.len == 0)
		to_chat(user, span_warning("There are no more cards to draw!"))
		return
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(user.loc)
	if(holo)
		holo.spawned += H // track them leaving the holodeck
	choice = cards[1]
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	popleft(cards)
	H.pickup(user)
	user.put_in_hands(H)
	user.visible_message(span_notice("[user] draws a card from the deck."), span_notice("You draw a card from the deck."))
	update_icon()
	return H

/obj/item/toy/cards/deck/update_icon_state()
	switch(cards.len)
		if(27 to INFINITY)
			icon_state = "deck_[deckstyle]_full"
		if(11 to 27)
			icon_state = "deck_[deckstyle]_half"
		if(1 to 11)
			icon_state = "deck_[deckstyle]_low"
		else
			icon_state = "deck_[deckstyle]_empty"
	return ..()

/obj/item/toy/cards/deck/attack_self(mob/user)
	if(cooldown < world.time - 50)
		cards = shuffle(cards)
		playsound(src, 'sound/items/cardshuffle.ogg', 50, TRUE)
		user.visible_message(span_notice("[user] shuffles the deck."), span_notice("You shuffle the deck."))
		cooldown = world.time

/obj/item/toy/cards/deck/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard))
		var/obj/item/toy/cards/singlecard/SC = I
		if(SC.parentdeck == src)
			if(!user.temporarilyRemoveItemFromInventory(SC))
				to_chat(user, span_warning("The card is stuck to your hand, you can't add it to the deck!"))
				return
			cards += SC.cardname
			user.visible_message(span_notice("[user] adds a card to the bottom of the deck."),span_notice("You add the card to the bottom of the deck."))
			qdel(SC)
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
		update_icon()
	else if(istype(I, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/CH = I
		if(CH.parentdeck == src)
			if(!user.temporarilyRemoveItemFromInventory(CH))
				to_chat(user, span_warning("The hand of cards is stuck to your hand, you can't add it to the deck!"))
				return
			cards += CH.currenthand
			user.visible_message(span_notice("[user] puts [user.p_their()] hand of cards in the deck."), span_notice("You put the hand of cards in the deck."))
			qdel(CH)
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
		update_icon()
	else
		return ..()

/obj/item/toy/cards/deck/MouseDrop(atom/over_object)
	. = ..()
	var/mob/living/M = usr
	if(!istype(M) || !(M.mobility_flags & MOBILITY_PICKUP))
		return
	if(Adjacent(usr))
		if(over_object == M && loc != M)
			M.put_in_hands(src)
			to_chat(usr, span_notice("You pick up the deck."))

		else if(istype(over_object, /atom/movable/screen/inventory/hand))
			var/atom/movable/screen/inventory/hand/H = over_object
			if(M.putItemFromInventoryInHandIfPossible(src, H.held_index))
				to_chat(usr, span_notice("You pick up the deck."))

	else
		to_chat(usr, span_warning("You can't reach it from here!"))



/obj/item/toy/cards/cardhand
	name = "hand of cards"
	desc = "A number of cards not in a deck, customarily held in ones hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nothing"
	w_class = WEIGHT_CLASS_TINY
	var/list/currenthand = list()
	var/choice = null

/obj/item/toy/cards/cardhand/attack_self(mob/user)
	var/list/handradial = list()
	interact(user)

	for(var/t in currenthand)
		handradial[t] = image(icon = src.icon, icon_state = "sc_[t]_[deckstyle]")

	if(usr.stat || !ishuman(usr))
		return
	var/mob/living/carbon/human/cardUser = usr
	if(!(cardUser.mobility_flags & MOBILITY_USE))
		return
	var/O = src
	var/choice = show_radial_menu(usr,src, handradial, custom_check = CALLBACK(src, PROC_REF(check_menu), user), radius = 36, require_near = TRUE)
	if(!choice)
		return FALSE
	var/obj/item/toy/cards/singlecard/C = new/obj/item/toy/cards/singlecard(cardUser.loc)
	currenthand -= choice
	handradial -= choice
	C.parentdeck = parentdeck
	C.cardname = choice
	C.apply_card_vars(C,O)
	C.pickup(cardUser)
	cardUser.put_in_hands(C)
	cardUser.visible_message(span_notice("[cardUser] draws a card from [cardUser.p_their()] hand."), span_notice("You take the [C.cardname] from your hand."))

	interact(cardUser)
	update_sprite()
	if(length(currenthand) == 1)
		var/obj/item/toy/cards/singlecard/N = new/obj/item/toy/cards/singlecard(loc)
		N.parentdeck = parentdeck
		N.cardname = currenthand[1]
		N.apply_card_vars(N,O)
		qdel(src)
		N.pickup(cardUser)
		cardUser.put_in_hands(N)
		to_chat(cardUser, span_notice("You also take [currenthand[1]] and hold it."))

/obj/item/toy/cards/cardhand/attackby(obj/item/toy/cards/singlecard/C, mob/living/user, params)
	if(istype(C))
		if(C.parentdeck == src.parentdeck)
			src.currenthand += C.cardname
			user.visible_message(span_notice("[user] adds a card to [user.p_their()] hand."), span_notice("You add the [C.cardname] to your hand."))
			qdel(C)
			interact(user)
			update_sprite()
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
	else
		return ..()

/obj/item/toy/cards/cardhand/apply_card_vars(obj/item/toy/cards/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	update_sprite()
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.card_attack_verb_continuous = sourceobj.card_attack_verb_continuous
	newobj.card_attack_verb_simple = sourceobj.card_attack_verb_simple
	newobj.resistance_flags = sourceobj.resistance_flags

/**
  * check_menu: Checks if we are allowed to interact with a radial menu
  *
  * Arguments:
  * * user The mob interacting with a menu
  */
/obj/item/toy/cards/cardhand/proc/check_menu(mob/living/user)
	if(!istype(user))
		return FALSE
	if(user.incapacitated)
		return FALSE
	return TRUE

/**
  * This proc updates the sprite for when you create a hand of cards
  */
/obj/item/toy/cards/cardhand/proc/update_sprite()
	cut_overlays()
	var/overlay_cards = currenthand.len

	var/k = overlay_cards == 2 ? 1 : overlay_cards - 2
	for(var/i = k; i <= overlay_cards; i++)
		var/card_overlay = image(icon=src.icon,icon_state="sc_[currenthand[i]]_[deckstyle]",pixel_x=(1-i+k)*3,pixel_y=(1-i+k)*3)
		add_overlay(card_overlay)

/obj/item/toy/cards/singlecard
	name = "card"
	desc = "A playing card used to play card games like poker."
	icon = 'icons/obj/toy.dmi'
	icon_state = "singlecard_down_nanotrasen"
	w_class = WEIGHT_CLASS_TINY
	var/cardname = null
	var/flipped = 0
	pixel_x = -5

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.embedding = sourceobj.embedding
	newobj.card_sharpness = sourceobj.card_sharpness
	newobj.sharpness = sourceobj.card_sharpness
	newobj.updateEmbedding()

/obj/item/toy/cards/singlecard/examine(mob/user)
	. = ..()
	if(ishuman(user))
		var/mob/living/carbon/human/cardUser = user
		if(cardUser.is_holding(src))
			cardUser.visible_message(span_notice("[cardUser] checks [cardUser.p_their()] card."), span_notice("The card reads: [cardname]."))
		else
			. += span_warning("You need to have the card in your hand to check it!")


/obj/item/toy/cards/singlecard/verb/Flip()
	set name = "Flip Card"
	set category = "Object"
	set src in range(1)
	if(!ishuman(usr) || !usr.canUseTopic(src, BE_CLOSE))
		return
	if(!flipped)
		src.flipped = 1
		if (cardname)
			src.icon_state = "sc_[cardname]_[deckstyle]"
			src.name = src.cardname
		else
			src.icon_state = "sc_Ace of Spades_[deckstyle]"
			src.name = "What Card"
		src.pixel_x = 5
	else if(flipped)
		src.flipped = 0
		src.icon_state = "singlecard_down_[deckstyle]"
		src.name = "card"
		src.pixel_x = -5

/obj/item/toy/cards/singlecard/attackby(obj/item/I, mob/living/user, params)
	if(istype(I, /obj/item/toy/cards/singlecard/))
		var/obj/item/toy/cards/singlecard/C = I
		if(C.parentdeck == src.parentdeck)
			var/obj/item/toy/cards/cardhand/H = new/obj/item/toy/cards/cardhand(user.loc)
			H.currenthand += C.cardname
			H.currenthand += src.cardname
			H.parentdeck = C.parentdeck
			H.apply_card_vars(H,C)
			to_chat(user, span_notice("You combine the [C.cardname] and the [src.cardname] into a hand."))
			qdel(C)
			qdel(src)
			H.pickup(user)
			user.put_in_active_hand(H)
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))

	if(istype(I, /obj/item/toy/cards/cardhand/))
		var/obj/item/toy/cards/cardhand/H = I
		if(H.parentdeck == parentdeck)
			H.currenthand += cardname
			user.visible_message(span_notice("[user] adds a card to [user.p_their()] hand."), span_notice("You add the [cardname] to your hand."))
			qdel(src)
			H.interact(user)
			H.update_sprite()
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
	else
		return ..()

/obj/item/toy/cards/singlecard/attack_self(mob/living/carbon/human/user)
	if(!ishuman(user) || !(user.mobility_flags & MOBILITY_USE))
		return
	Flip()

/obj/item/toy/cards/singlecard/apply_card_vars(obj/item/toy/cards/singlecard/newobj,obj/item/toy/cards/sourceobj)
	..()
	newobj.deckstyle = sourceobj.deckstyle
	newobj.icon_state = "singlecard_down_[deckstyle]" // Without this the card is invisible until flipped. It's an ugly hack, but it works.
	newobj.card_hitsound = sourceobj.card_hitsound
	newobj.hitsound = newobj.card_hitsound
	newobj.card_force = sourceobj.card_force
	newobj.force = newobj.card_force
	newobj.card_throwforce = sourceobj.card_throwforce
	newobj.throwforce = newobj.card_throwforce
	newobj.card_throw_speed = sourceobj.card_throw_speed
	newobj.throw_speed = newobj.card_throw_speed
	newobj.card_throw_range = sourceobj.card_throw_range
	newobj.throw_range = newobj.card_throw_range
	newobj.card_attack_verb_continuous = sourceobj.card_attack_verb_continuous
	newobj.attack_verb_continuous = newobj.card_attack_verb_continuous
	newobj.card_attack_verb_simple = sourceobj.card_attack_verb_simple
	newobj.attack_verb_simple = newobj.card_attack_verb_simple

/*
|| Syndicate playing cards, for pretending you're Gambit and playing poker for the nuke disk. ||
*/
/obj/item/toy/cards/deck/syndicate
	name = "suspicious looking deck of cards"
	desc = "A deck of space-grade playing cards. They seem unusually rigid."
	icon_state = "deck_syndicate_full"
	deckstyle = "syndicate"
	card_hitsound = 'sound/weapons/bladeslice.ogg'
	card_force = 5
	card_throwforce = 12
	card_throw_speed = 6
	embedding = list("pain_mult" = 1, "embed_chance" = 80, "max_damage_mult" = 8, "fall_chance" = 0, "embed_chance_turf_mod" = 15, "armour_block" = 60) //less painful than throwing stars
	card_sharpness = SHARP
	bleed_force = BLEED_SURFACE
	card_throw_range = 7
	card_attack_verb_continuous = list("attacks", "slices", "dices", "slashes", "cuts")
	card_attack_verb_simple = list("attack", "slice", "dice", "slash", "cut")
	resistance_flags = NONE
	trade_flags = TRADE_CONTRABAND

/*
 * Fake nuke
 */

/obj/item/toy/nuke
	name = "\improper Nuclear Fission Explosive toy"
	desc = "A plastic model of a Nuclear Fission Explosive."
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoyidle"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/nuke/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message(span_warning("[user] presses a button on [src]."), span_notice("You activate [src], it plays a loud noise!"), span_italics("You hear the click of a button."))
		sleep(5)
		icon_state = "nuketoy"
		playsound(src, 'sound/machines/alarm.ogg', 100, 0)
		sleep(135)
		icon_state = "nuketoycool"
		sleep(cooldown - world.time)
		icon_state = "nuketoyidle"
	else
		var/timeleft = (cooldown - world.time)
		to_chat(user, "[span_alert("Nothing happens, and")] [round(timeleft/10)] [span_alert("appears on a small display.")]")

/*
 * Fake meteor
 */

/obj/item/toy/minimeteor
	name = "\improper Mini-Meteor"
	desc = "Relive the excitement of a meteor shower! SweetMeat-eor. Co is not responsible for any injuries, headaches or hearing loss caused by Mini-Meteor."
	icon = 'icons/obj/toy.dmi'
	icon_state = "minimeteor"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/minimeteor/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		playsound(src, 'sound/effects/meteorimpact.ogg', 40, 1)
		for(var/mob/M in urange(10, src))
			if(!M.stat && !isAI(M))
				shake_camera(M, 3, 1)
		qdel(src)

/*
 * Toy big red button
 */
/obj/item/toy/redbutton
	name = "big red button"
	desc = "A big, plastic red button. Reads 'From Honk Co. Pranks?' on the back."
	icon = 'icons/obj/assemblies.dmi'
	icon_state = "bigred"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/redbutton/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = (world.time + 300) // Sets cooldown at 30 seconds
		user.visible_message(span_warning("[user] presses the big red button."), span_notice("You press the button, it plays a loud noise!"), span_italics("The button clicks loudly."))
		playsound(src, 'sound/effects/explosionfar.ogg', 50, 0)
		for(var/mob/M in urange(10, src)) // Checks range
			if(!M.stat && !isAI(M)) // Checks to make sure whoever's getting shaken is alive/not the AI
				sleep(8) // Short delay to match up with the explosion sound
				shake_camera(M, 2, 1) // Shakes player camera 2 squares for 1 second.

	else
		to_chat(user, span_alert("Nothing happens."))

/*
 * Snowballs
 */

/obj/item/toy/snowball
	name = "snowball"
	desc = "A compact ball of snow. Good for throwing at people."
	icon = 'icons/obj/toy.dmi'
	icon_state = "snowball"
	throwforce = 12 //pelt your enemies to death with lumps of snow

/obj/item/toy/snowball/afterattack(atom/target as mob|obj|turf|area, mob/user)
	. = ..()
	if(user.dropItemToGround(src))
		throw_at(target, throw_range, throw_speed)

/obj/item/toy/snowball/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	if(!..())
		playsound(src, 'sound/effects/pop.ogg', 20, 1)
		qdel(src)

/*
 * Beach ball
 */
/obj/item/toy/beach_ball
	icon = 'icons/misc/beach.dmi'
	icon_state = "ball"
	name = "beach ball"
	inhand_icon_state = "beachball"
	w_class = WEIGHT_CLASS_BULKY //Stops people from hiding it in their bags/pockets
	item_flags = NO_PIXEL_RANDOM_DROP

/*
 * Clockwork Watch
 */

/obj/item/toy/clockwork_watch
	name = "steampunk watch"
	desc = "A stylish steampunk watch made out of thousands of tiny cogwheels."
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "dread_ipad"
	worn_icon_state = "dread_ipad"
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/clockwork_watch/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 1800 //3 minutes
		user.visible_message(span_warning("[user] rotates a cogwheel on [src]."), span_notice("You rotate a cogwheel on [src], it plays a loud noise!"), span_italics("You hear cogwheels turning."))
		playsound(src, 'sound/magic/clockwork/ark_activation.ogg', 50, 0)
	else
		to_chat(user, span_alert("The cogwheels are already turning!"))

/obj/item/toy/clockwork_watch/examine(mob/user)
	. = ..()
	. += span_info("Station Time: [station_time_timestamp()]")

/*
 * Toy Dagger
 */

/obj/item/toy/toy_dagger
	name = "toy dagger"
	desc = "A cheap plastic replica of a dagger. Produced by THE ARM Toys, Inc."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_SMALL
	item_flags = ISWEAPON

/*
 * Toy Cog
 */

/obj/item/toy/cog
	name = "integration cog"
	desc = "A small cog that seems to spin by its own acord when left alone."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "integration_cog"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/cog/examine(mob/user)
	. = ..()
	if(IS_SERVANT_OF_RATVAR(user))
		. += span_warning("It's clearly a fake, how could anybody fall for this!")

/*
 * Replica fabricator
 */

/obj/item/toy/replica_fabricator
	name = "replica fabricator"
	desc = "A strange, brass device with many twisting cogs and vents."
	resistance_flags = FIRE_PROOF | ACID_PROOF
	icon = 'icons/obj/clockwork_objects.dmi'
	icon_state = "replica_fabricator"
	w_class = WEIGHT_CLASS_SMALL

/obj/item/toy/replica_fabricator/examine(mob/user)
	. = ..()
	if(IS_SERVANT_OF_RATVAR(user))
		. += span_warning("It's clearly a fake, how could anybody fall for this!")

/*
 * Xenomorph action figure
 */

/obj/item/toy/toy_xeno
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_xeno"
	name = "xenomorph action figure"
	desc = "MEGA presents the new Xenos Isolated action figure! Comes complete with realistic sounds! Pull back string to use."
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0

/obj/item/toy/toy_xeno/attack_self(mob/user)
	if(cooldown <= world.time)
		cooldown = (world.time + 50) //5 second cooldown
		user.visible_message(span_notice("[user] pulls back the string on [src]."))
		icon_state = "[initial(icon_state)]_used"
		sleep(5)
		audible_message(span_danger("[icon2html(src, viewers(src))] Hiss!"))
		var/list/possible_sounds = list('sound/voice/hiss1.ogg', 'sound/voice/hiss2.ogg', 'sound/voice/hiss3.ogg', 'sound/voice/hiss4.ogg')
		var/chosen_sound = pick(possible_sounds)
		playsound(get_turf(src), chosen_sound, 50, 1)
		addtimer(VARSET_CALLBACK(src, icon_state, initial(icon_state)), 45)
	else
		to_chat(user, span_warning("The string on [src] hasn't rewound all the way!"))
		return

// TOY MOUSEYS :3 :3 :3

/obj/item/toy/cattoy
	name = "toy mouse"
	desc = "A colorful toy mouse!"
	icon = 'icons/obj/toy.dmi'
	icon_state = "toy_mouse"
	w_class = WEIGHT_CLASS_SMALL
	var/cooldown = 0
	resistance_flags = FLAMMABLE


/*
 * Action Figures
 */

/obj/item/toy/figure
	name = "Non-Specific Action Figure action figure"
	icon = 'icons/obj/toy.dmi'
	icon_state = "nuketoy"
	w_class = WEIGHT_CLASS_TINY
	var/cooldown = 0
	var/toysay = "What the fuck did you do?"
	var/toysound = 'sound/machines/click.ogg'

/obj/item/toy/figure/Initialize(mapload)
	. = ..()
	desc = "A \"Space Life\" brand [src]."
	AddElement(/datum/element/toy_talk)

/obj/item/toy/figure/attack_self(mob/user as mob)
	if(cooldown <= world.time)
		cooldown = world.time + 50
		to_chat(user, span_notice("[src] says \"[toysay]\""))
		playsound(user, toysound, 20, 1)

/obj/item/toy/figure/cmo
	name = "\improper Chief Medical Officer action figure"
	icon_state = "cmo"
	toysay = "Suit sensors!"

/obj/item/toy/figure/assistant
	name = "\improper Assistant action figure"
	icon_state = "assistant"
	inhand_icon_state = "doll"
	toysay = "Greytide world wide!"

/obj/item/toy/figure/atmos
	name = "\improper Atmospheric Technician action figure"
	icon_state = "atmos"
	toysay = "Glory to Atmosia!"

/obj/item/toy/figure/bartender
	name = "\improper Bartender action figure"
	icon_state = "bartender"
	toysay = "Where is Pun Pun?"

/obj/item/toy/figure/borg
	name = "\improper Cyborg action figure"
	icon_state = "borg"
	toysay = "I. LIVE. AGAIN."
	toysound = 'sound/voice/liveagain.ogg'

/obj/item/toy/figure/botanist
	name = "\improper Botanist action figure"
	icon_state = "botanist"
	toysay = "Blaze it!"

/obj/item/toy/figure/captain
	name = "\improper Captain action figure"
	icon_state = "captain"
	toysay = "Any heads of staff?"

/obj/item/toy/figure/cargotech
	name = "\improper Cargo Technician action figure"
	icon_state = "cargotech"
	toysay = "For Cargonia!"

/obj/item/toy/figure/ce
	name = "\improper Chief Engineer action figure"
	icon_state = "ce"
	toysay = "Wire the solars!"

/obj/item/toy/figure/chaplain
	name = "\improper Chaplain action figure"
	icon_state = "chaplain"
	toysay = "Praise Space Jesus!"

/obj/item/toy/figure/chef
	name = "\improper Cook action figure"
	icon_state = "chef"
	toysay = "I'll make you into a burger!"

/obj/item/toy/figure/chemist
	name = "\improper Chemist action figure"
	icon_state = "chemist"
	toysay = "Get your pills!"

/obj/item/toy/figure/clown
	name = "\improper Clown action figure"
	icon_state = "clown"
	toysay = "Honk!"
	toysound = 'sound/items/bikehorn.ogg'

/obj/item/toy/figure/ian
	name = "\improper Ian action figure"
	icon_state = "ian"
	toysay = "Arf!"

/obj/item/toy/figure/detective
	name = "\improper Detective action figure"
	icon_state = "detective"
	toysay = "This airlock has grey jumpsuit and insulated glove fibers on it."

/obj/item/toy/figure/dsquad
	name = "\improper Deathsquad Officer action figure"
	icon_state = "dsquad"
	toysay = "Kill 'em all!"

/obj/item/toy/figure/engineer
	name = "\improper Station Engineer action figure"
	icon_state = "engineer"
	toysay = "Oh god, the singularity is loose!"

/obj/item/toy/figure/geneticist
	name = "\improper Geneticist action figure"
	icon_state = "geneticist"
	toysay = "Smash!"

/obj/item/toy/figure/hop
	name = "\improper Head of Personnel action figure"
	icon_state = "hop"
	toysay = "Giving out all access!"

/obj/item/toy/figure/hos
	name = "\improper Head of Security action figure"
	icon_state = "hos"
	toysay = "Go ahead, make my day."

/obj/item/toy/figure/qm
	name = "\improper Quartermaster action figure"
	icon_state = "qm"
	toysay = "Please sign this form in triplicate and we will see about geting you a welding mask within 3 business days."

/obj/item/toy/figure/janitor
	name = "\improper Janitor action figure"
	icon_state = "janitor"
	toysay = "Look at the signs, you idiot."

/obj/item/toy/figure/lawyer
	name = "\improper Lawyer action figure"
	icon_state = "lawyer"
	toysay = "My client is a dirty traitor!"

/obj/item/toy/figure/curator
	name = "\improper Curator action figure"
	icon_state = "curator"
	toysay = "One day while..."

/obj/item/toy/figure/md
	name = "\improper Medical Doctor action figure"
	icon_state = "md"
	toysay = "The patient is already dead!"

/obj/item/toy/figure/paramedic
	name = "\improper Paramedic action figure"
	icon_state = "paramedic"
	toysay = "And the best part? I'm not even a real doctor!"

/obj/item/toy/figure/psychologist
	name = "\improper Psychologist action figure"
	icon_state = "psychologist"
	toysay = "Alright, just take these happy pills!"

/obj/item/toy/figure/prisoner
	name = "\improper Prisoner action figure"
	icon_state = "prisoner"
	toysay = "I did not hit her! I did not!"

/obj/item/toy/figure/mime
	name = "\improper Mime action figure"
	icon_state = "mime"
	toysay = "..."
	toysound = null

/obj/item/toy/figure/miner
	name = "\improper Shaft Miner action figure"
	icon_state = "miner"
	toysay = "COLOSSUS RIGHT OUTSIDE THE BASE!"

/obj/item/toy/figure/ninja
	name = "\improper Space Ninja action figure"
	icon_state = "ninja"
	toysay = "I am the shadow warrior!"

/obj/item/toy/figure/wizard
	name = "\improper Wizard action figure"
	icon_state = "wizard"
	toysay = "EI NATH!"
	toysound = 'sound/magic/disintegrate.ogg'

/obj/item/toy/figure/rd
	name = "\improper Research Director action figure"
	icon_state = "rd"
	toysay = "Blowing all of the borgs!"

/obj/item/toy/figure/roboticist
	name = "\improper Roboticist action figure"
	icon_state = "roboticist"
	toysay = "Big stompy mechs!"
	toysound = 'sound/mecha/mechstep.ogg'

/obj/item/toy/figure/scientist
	name = "\improper Scientist action figure"
	icon_state = "scientist"
	toysay = "I call toxins."
	toysound = 'sound/effects/explosionfar.ogg'

/obj/item/toy/figure/syndie
	name = "\improper Nuclear Operative action figure"
	icon_state = "syndie"
	toysay = "Get that fucking disk!"

/obj/item/toy/figure/secofficer
	name = "\improper Security Officer action figure"
	icon_state = "secofficer"
	toysay = "I am the law!"
	toysound = 'sound/voice/complionator/dredd.ogg'

/obj/item/toy/figure/virologist
	name = "\improper Virologist action figure"
	icon_state = "virologist"
	toysay = "It's beneficial! Mostly."
	toysound = 'sound/ambience/antag/ling_aler.ogg'

/obj/item/toy/figure/warden
	name = "\improper Warden action figure"
	icon_state = "warden"
	toysay = "Seventeen minutes for coughing at an officer!"


/obj/item/toy/dummy
	name = "ventriloquist dummy"
	desc = "It's a dummy, dummy. Use .l to talk out of it if held in your left hand, or .r if held in your right hand."
	icon = 'icons/obj/toy.dmi'
	icon_state = "puppet"
	inhand_icon_state = "puppet"
	var/doll_name = "Dummy"

//Add changing looks when i feel suicidal about making 20 inhands for these.
/obj/item/toy/dummy/attack_self(mob/user)
	var/new_name = tgui_input_text(usr, "What would you like to name the dummy?", "Input a name", doll_name, MAX_NAME_LEN)
	if(!new_name) // no input so we return
		to_chat(user, span_warning("You need to enter something!"))
		return
	if(CHAT_FILTER_CHECK(new_name)) // check for forbidden words
		to_chat(user, span_warning("That name contains forbidden words."))
		return
	doll_name = new_name
	to_chat(user, "You name the dummy as \"[doll_name]\"")
	name = "[initial(name)] - [doll_name]"

/obj/item/toy/dummy/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/toy_talk)

/obj/item/toy/dummy/GetVoice()
	return doll_name

/*
 * Eldrich Toys
 */

/obj/item/toy/eldrich_book
	name = "Codex Cicatrix"
	desc = "A toy book that closely resembles the Codex Cicatrix. Covered in fake polyester human flesh and has a huge goggly eye attached to the cover. The runes are gibberish and cannot be used to summon demons... Hopefully?"
	icon = 'icons/obj/heretic.dmi'
	icon_state = "book"
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("sacrifices", "transmutes", "grasps", "curses")
	attack_verb_simple = list("sacrifice", "transmute", "grasp", "curse")
	var/open = FALSE

/obj/item/toy/eldrich_book/attack_self(mob/user)
	open = !open
	update_icon()

/obj/item/toy/eldrich_book/update_icon()
	icon_state = open ? "book_open" : "book"

/*
 * Fake tear
 */

/obj/item/toy/reality_pierce
	name = "Pierced reality"
	desc = "Hah. You thought it was the real deal!"
	icon = 'icons/effects/heretic.dmi'
	icon_state = "pierced_illusion"
	item_flags = NO_PIXEL_RANDOM_DROP

/obj/item/storage/box/heretic_asshole
	name = "box of pierced realities"
	desc = "A box containing toys resembling pierced realities."

/obj/item/storage/box/heretic_asshole/PopulateContents()
	for(var/i in 1 to rand(1,4))
		new /obj/item/toy/reality_pierce(src)

// Serviceborg items

/*
|| Cyborg playing cards module. ||
*/

/obj/item/toy/cards/deck/cyborg
	name = "dealer module"
	desc = "A module for handling, fabricating cards and tricking suckers into gambling awaya their money. Ctrl Click to fabricate a new set of cards."

/obj/item/toy/cards/deck/cyborg/update_icon()
	icon_state = "deck_[deckstyle]_full"

/obj/item/toy/cards/deck/cyborg/CtrlClick(mob/user)
	..()
	if(iscyborg(user))
		var/mob/living/silicon/robot/R = user
		if(R.cell?.use(300))
			populate_deck()
			to_chat(user, span_notice("You fabricate a new set of cards."))

/obj/item/toy/cards/deck/cyborg/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if (istype(A, /obj/item/toy/cards/singlecard))
		var/obj/item/toy/cards/singlecard/SC = A
		if(SC.parentdeck == src)
			if(!user.temporarilyRemoveItemFromInventory(SC))
				to_chat(user, span_warning("The card is stuck to your hand, you can't add it to the deck!"))
				return
			cards += SC.cardname
			user.visible_message(span_notice("[user] adds a card to the bottom of the deck."),span_notice("You add the card to the bottom of the deck."))
			qdel(SC)
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
		update_icon()
	else if (istype(A, /obj/item/toy/cards/cardhand))
		var/obj/item/toy/cards/cardhand/CH = A
		if(CH.parentdeck == src)
			cards += CH.currenthand
			user.visible_message(span_notice("[user] puts [user.p_their()] hand of cards in the deck."), span_notice("You put the hand of cards in the deck."))
			qdel(CH)
		else
			to_chat(user, span_warning("You can't mix cards from other decks!"))
		update_icon()

	var/choice = null
	if(!LAZYLEN(cards))
		to_chat(user, span_warning("There are no more cards to draw!"))
		return

	choice = cards[1]
	var/obj/item/toy/cards/singlecard/H = new/obj/item/toy/cards/singlecard(get_turf(A))
	H.cardname = choice
	H.parentdeck = src
	var/O = src
	H.apply_card_vars(H,O)
	cards.Cut(1,2) //Removes the top card from the list

	if(!proximity)
		H.forceMove(get_turf(src))
		H.throw_at(get_turf(A), 10 , 1 , user)

////////////////////
//money eater/maker//
////////////////////

/obj/item/gobbler
	name = "Coin Gobbler"
	desc = "Feed it credits, and activate it, with a chance to spit out DOUBLE the amount!"
	icon = 'icons/obj/plushes.dmi'
	icon_state = "debug"
	var/money = 0
	var/moneyeaten = 0
	var/cooldown = 0
	var/cooldowndelay = 20
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/gobbler/examine(mob/user)
	. = ..()
	. += span_notice("The Coin Gobbler holds [money] credits.")

/obj/item/gobbler/attackby()
	return

/obj/item/gobbler/attack_self(mob/user)
	if(cooldown > world.time)
		return
	cooldown = world.time + cooldowndelay
	if (money<=0)
		to_chat(user, span_notice("The [src] has no money stored."))
		return

	playsound(src.loc, 'sound/creatures/rattle.ogg', 10, 1)
	user.visible_message(span_notice("[src]'s eyes start spinning! What will happen?"), \
		span_notice("You activate [src]."))
	sleep(10)

	if(prob(33*(777+moneyeaten-money)/777))
		playsound(src.loc, 'sound/arcade/win.ogg', 10, 1)
		user.visible_message(span_warning("[src] cashes out! [user] starts spitting credits!"), \
		span_notice("[src] cashes out!"))
		var/obj/item/holochip/payout = new (user.drop_location(), money*2)
		payout.throw_at( get_step(loc,user.dir) ,3,1,user)
		moneyeaten-=money
		money=0
	else
		user.visible_message(span_notice("[src] gobbles up all the money!"), \
		span_notice("[src] gobbles up all the money!"))
		moneyeaten+=money
		money=0
		playsound(src.loc, 'sound/machines/buzz-sigh.ogg', 10, 1)

/obj/item/gobbler/afterattack(atom/A, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	var/cash_money = 0

	if(istype(A, /obj/item/holochip))
		var/obj/item/holochip/HC = A
		cash_money = HC.get_item_credit_value()
	else if(istype(A, /obj/item/stack/spacecash))
		var/obj/item/stack/spacecash/SC = A
		cash_money = SC.get_item_credit_value()
	else if(istype(A, /obj/item/coin))
		var/obj/item/coin/CN = A
		cash_money = CN.get_item_credit_value()

	if (!cash_money)
		to_chat(user, span_warning("[src] spits out [A] as it is not worth anything!"))
		return
	money+=cash_money
	to_chat(user, span_notice("[src] quicky gobbles up [A], and the value goes up by [cash_money]."))
	qdel(A)

/obj/item/dance_trance
	name = "Dance Fever"
	desc = "Makes everyone dance!"
	icon = 'icons/obj/grenade.dmi'
	icon_state = "disco_active"
	var/flip_cooldown = 0

/obj/item/dance_trance/attack()
	if(flip_cooldown < world.time)
		flip_mobs()
	return ..()

/obj/item/dance_trance/attack_self(mob/user)
	if(flip_cooldown < world.time)
		flip_mobs()
	..()

/obj/item/dance_trance/proc/flip_mobs(mob/living/carbon/M, mob/user)
	for(M in ohearers(7, get_turf(src)))
		if(ishuman(M) && M.can_hear())
			var/mob/living/carbon/human/H = M
			if(istype(H.ears, /obj/item/clothing/ears/earmuffs))
				continue
		switch (rand(1,3))
			if (1)
				M.emote("flip")
				M.emote("spin")
			if (2)
				M.emote("flip")
			if (3)
				M.emote("spin")
	flip_cooldown = world.time + 20


/obj/item/storage/pill_bottle/dice_cup/cyborg
	desc = "The house always wins..."
/obj/item/storage/pill_bottle/dice_cup/cyborg/Initialize(mapload)
	. = ..()
	new /obj/item/dice/d6(src)
	new /obj/item/dice/d6(src)


/obj/item/storage/box/yatzy
	name = "Game of Yatzy"
	desc = "Contains all the pieces required to play a game of Yatzy with up to 4 friends!"
	custom_price = 15

/obj/item/storage/box/yatzy/PopulateContents()
	new /obj/item/storage/pill_bottle/dice_cup/yatzy(src)
	new /obj/item/paper/yatzy(src)
	new /obj/item/paper/yatzy(src)
	new /obj/item/paper/yatzy(src)
	new /obj/item/paper/yatzy(src)

/obj/item/storage/pill_bottle/dice_cup/yatzy/Initialize(mapload)
	. = ..()
	for(var/dice in 1 to 5)
		new /obj/item/dice/d6(src)

/obj/item/paper/yatzy
	name = "paper - Yatzy Table"
	default_raw_text = "<table><tr><th>Upper</th><th>Game 1</th><th>Game 2</th><th>Game 3</th></tr><tr><th>Aces</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Twos</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Threes</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Fours</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Fives</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Sixes</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Total</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Upper Total</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th><b>Bonus</b></th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>1 Pair</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>2 Pairs</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th><th>3 of a Kind</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th><th>4 of a Kind</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Full House</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Sm. Straight</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Lg. Straight</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Yatzy</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Chance</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th>Lower Total</th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr><th><b>Grand Total</b></th><th>\[___\]</th><th>\[___\]</th><th>\[___\]</th></tr></table>"
