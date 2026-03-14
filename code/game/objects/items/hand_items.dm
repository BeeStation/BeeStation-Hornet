/// For all of the items that are really just the user's hand used in different ways, mostly (all, really) from emotes
/obj/item/hand_item
	icon = 'icons/obj/hand.dmi'
	icon_state = "latexballoon"
	force = 0
	throwforce = 0
	item_flags = DROPDEL | ABSTRACT | HAND_ITEM | ISWEAPON

/obj/item/hand_item/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_STORAGE_INSERT, TRAIT_GENERIC)

/obj/item/hand_item/attack(mob/living/target_mob, mob/living/user)
	. = ..()
	SEND_SIGNAL(user, COMSIG_LIVING_HAND_ITEM_ATTACK, target_mob)

/obj/item/hand_item/circlegame
	name = "circled hand"
	desc = "If somebody looks at this while it's below your waist, you get to bop them."
	icon_state = "madeyoulook"
	attack_verb_continuous = list("bops")
	attack_verb_simple = list("bop")

/obj/item/hand_item/slapper
	name = "slapper"
	desc = "This is how real men fight."
	inhand_icon_state = "nothing"
	attack_verb_continuous = list("slaps")
	attack_verb_simple = list("slap")
	hitsound = 'sound/effects/snap.ogg'
	/// How many smaller table smacks we can do before we're out
	var/table_smacks_left = 3

/obj/item/hand_item/slapper/attack(mob/living/M, mob/living/carbon/human/user)
	if(ishuman(M))
		var/mob/living/carbon/human/L = M
		if(L && L.dna && L.dna.species)
			L.dna.species.stop_wagging_tail(M)
	user.do_attack_animation(M)

	var/slap_volume = 50
	if(user.is_zone_selected(BODY_ZONE_HEAD, precise_only = TRUE) || user.is_zone_selected(BODY_ZONE_PRECISE_MOUTH, simplified_probability = 50))
		user.visible_message(span_danger("[user] slaps [M] in the face!"),
			span_notice("You slap [M] in the face!"),
			span_hear("You hear a slap."))
	else
		user.visible_message(span_danger("[user] slaps [M]!"),
			span_notice("You slap [M]!"),
			span_hear("You hear a slap."))
	playsound(M, 'sound/weapons/slap.ogg', slap_volume, TRUE, -1)
	return

/obj/item/hand_item/slapper/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	if(!istype(target, /obj/structure/table))
		return ..()

	var/obj/structure/table/the_table = target

	if(!proximity_flag)
		return

	if(user.combat_mode && table_smacks_left == initial(table_smacks_left)) // so you can't do 2 weak slaps followed by a big slam
		transform = transform.Scale(5) // BIG slap
		if(HAS_TRAIT(user, TRAIT_HULK))
			transform = transform.Scale(2)
			color = COLOR_GREEN
		user.do_attack_animation(the_table)
		//Uncomment if we ever port table slam signals
		//SEND_SIGNAL(user, COMSIG_LIVING_SLAM_TABLE, the_table)
		//SEND_SIGNAL(the_table, COMSIG_TABLE_SLAMMED, user)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 110, TRUE)
		user.visible_message("<b>[span_danger("[user] slams [user.p_their()] fist down on [the_table]!")]</b>", "<b>[span_danger("You slam your fist down on [the_table]!")]</b>")
		qdel(src)
	else
		user.do_attack_animation(the_table)
		playsound(get_turf(the_table), 'sound/effects/tableslam.ogg', 40, TRUE)
		user.visible_message(span_notice("[user] slaps [user.p_their()] hand on [the_table]."), span_notice("You slap your hand on [the_table]."), vision_distance=COMBAT_MESSAGE_RANGE)
		table_smacks_left--
		if(table_smacks_left <= 0)
			qdel(src)
