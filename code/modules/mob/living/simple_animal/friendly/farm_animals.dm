//goat
/mob/living/simple_animal/hostile/retaliate/goat
	name = "goat"
	desc = "Not known for their pleasant disposition."
	icon_state = "goat"
	icon_living = "goat"
	icon_dead = "goat_dead"
	speak = list("EHEHEHEHEH","eh?")
	speak_emote = list("brays")
	speak_language = /datum/language/metalanguage
	emote_hear = list("brays.")
	emote_see = list("shakes its head.", "stamps a foot.", "glares around.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 4)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	faction = list(FACTION_NEUTRAL)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	attack_same = 1
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 40
	maxHealth = 40
	minbodytemp = 180
	melee_damage = 5
	environment_smash = ENVIRONMENT_SMASH_NONE
	stop_automated_movement_when_pulled = 1
	blood_volume = BLOOD_VOLUME_NORMAL
	chat_color = "#B2CEB3"

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/hostile/retaliate/goat/Initialize(mapload)
	AddComponent(/datum/component/udder)
	. = ..()

/mob/living/simple_animal/hostile/retaliate/goat/Life()
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && prob(1))
			Retaliate()

		if(enemies.len && prob(10))
			clear_enemies()
			LoseTarget()
			src.visible_message(span_notice("[src] calms down."))
	if(stat != CONSCIOUS)
		return

	eat_plants()
	if(pulledby)
		return

	for(var/direction in shuffle(list(1,2,4,8,5,6,9,10)))
		var/step = get_step(src, direction)
		if(step)
			if(locate(/obj/structure/spacevine) in step || locate(/obj/structure/glowshroom) in step)
				Move(step, get_dir(src, step))

/mob/living/simple_animal/hostile/retaliate/goat/Retaliate()
	..()
	src.visible_message(span_danger("[src] gets an evil-looking gleam in [p_their()] eye."))

/mob/living/simple_animal/hostile/retaliate/goat/Move()
	. = ..()
	if(!stat)
		eat_plants()

/mob/living/simple_animal/hostile/retaliate/goat/proc/eat_plants()
	var/eaten = FALSE
	var/obj/structure/spacevine/SV = locate(/obj/structure/spacevine) in loc
	if(SV)
		SV.eat(src)
		eaten = TRUE

	var/obj/structure/glowshroom/GS = locate(/obj/structure/glowshroom) in loc
	if(GS)
		qdel(GS)
		eaten = TRUE

	if(eaten && prob(10))
		INVOKE_ASYNC(src, /atom/movable/proc/say, "Nom")

/mob/living/simple_animal/hostile/retaliate/goat/AttackingTarget()
	. = ..()
	if(. && ishuman(target))
		var/mob/living/carbon/human/H = target
		if(isdiona(H))
			var/obj/item/bodypart/NB = pick(H.bodyparts)
			H.visible_message(span_warning("[src] takes a big chomp out of [H]!"), \
									span_userdanger("[src] takes a big chomp out of your [NB]!"))
			NB.dismember()

/mob/living/simple_animal/hostile/retaliate/goat/rabid
	name = "Rabid Maintenance Pete"
	faction = list(FACTION_HOSTILE)
			
//cow
/mob/living/simple_animal/cow
	name = "cow"
	desc = "Known for their milk, just don't tip them over."
	icon_state = "cow"
	icon_living = "cow"
	icon_dead = "cow_dead"
	icon_gib = "cow_gib"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("moo?","moo","MOOOOOO")
	speak_emote = list("moos","moos hauntingly")
	speak_language = /datum/language/metalanguage
	emote_hear = list("brays.")
	emote_see = list("shakes its head.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	butcher_results = list(/obj/item/food/meat/slab = 6)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	attack_sound = 'sound/weapons/punch1.ogg'
	health = 50
	maxHealth = 50
	gold_core_spawnable = FRIENDLY_SPAWN
	blood_volume = BLOOD_VOLUME_NORMAL
	chat_color = "#FFFFFF"

	footstep_type = FOOTSTEP_MOB_SHOE

/mob/living/simple_animal/cow/Initialize(mapload)
	AddComponent(/datum/component/udder)
	AddComponent(/datum/component/tippable, \
		tip_time = 0.5 SECONDS, \
		untip_time = 0.5 SECONDS, \
		self_right_time = rand(25 SECONDS, 50 SECONDS), \
		post_tipped_callback = CALLBACK(src, PROC_REF(after_cow_tipped)))
	. = ..()

/*
 * Proc called via callback after the cow is tipped by the tippable component.
 * Begins a timer for us pleading for help.
 *
 * tipper - the mob who tipped us
 */
/mob/living/simple_animal/cow/proc/after_cow_tipped(mob/living/carbon/tipper)
	addtimer(CALLBACK(src, PROC_REF(look_for_help), tipper), rand(10 SECONDS, 20 SECONDS))

/*
 * Find a mob in a short radius around us (prioritizing the person who originally tipped us)
 * and either look at them for help, or give up. No actual mechanical difference between the two.
 *
 * tipper - the mob who originally tipped us
 */
/mob/living/simple_animal/cow/proc/look_for_help(mob/living/carbon/tipper)
	// visible part of the visible message
	var/seen_message = ""
	// self part of the visible message
	var/self_message = ""
	// the mob we're looking to for aid
	var/mob/living/carbon/savior
	// look for someone in a radius around us for help. If our original tipper is in range, prioritize them
	for(var/mob/living/carbon/potential_aid in oview(3, get_turf(src)))
		if(potential_aid == tipper)
			savior = tipper
			break
		savior = potential_aid

	if(prob(75) && savior)
		var/text = pick("imploringly", "pleadingly", "with a resigned expression")
		seen_message = "[src] looks at [savior] [text]."
		self_message = "You look at [savior] [text]."
	else
		seen_message = "[src] seems resigned to its fate."
		self_message = "You resign yourself to your fate."
	visible_message(span_notice("[seen_message]"), span_notice("[self_message]"))

/mob/living/simple_animal/chick
	name = "\improper chick"
	desc = "Adorable! They make such a racket though."
	icon_state = "chick"
	icon_living = "chick"
	icon_dead = "chick_dead"
	icon_gib = "chick_gib"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "chick"
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak = list("Cherp.","Cherp?","Chirrup.","Cheep!")
	speak_emote = list("cheeps")
	speak_language = /datum/language/metalanguage
	emote_hear = list("cheeps.")
	emote_see = list("pecks at the ground.","flaps its tiny wings.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 2
	butcher_results = list(/obj/item/food/meat/slab/chicken = 1)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 3
	maxHealth = 3
	ventcrawler = VENTCRAWLER_ALWAYS
	var/amount_grown = 0
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/chick/Initialize(mapload)
	. = ..()
	pixel_x = base_pixel_x + rand(-6, 6)
	pixel_y = base_pixel_y + rand(0, 10)
	GLOB.total_chickens++

/mob/living/simple_animal/chick/Life()
	. =..()
	if(!.)
		return
	if(!stat && !ckey)
		amount_grown += rand(1,2)
		if(amount_grown >= 100)
			new /mob/living/simple_animal/chicken(src.loc)
			qdel(src)

/mob/living/simple_animal/chick/death(gibbed)
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chick/Destroy()
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chick/holo/Life()
	..()
	amount_grown = 0

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	icon_state = "chicken_brown"
	icon_living = "chicken_brown"
	icon_dead = "chicken_brown_dead"
	speak = list("Cluck!","BWAAAAARK BWAK BWAK BWAK!","Bwaak bwak.")
	speak_emote = list("clucks","croons")
	speak_language = /datum/language/metalanguage
	emote_hear = list("clucks.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = FALSE
	speak_chance = 2
	turns_per_move = 3
	butcher_results = list(/obj/item/food/meat/slab/chicken = 2)
	var/egg_type = /obj/item/food/egg
	var/food_type = /obj/item/food/grown/wheat
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	response_harm_continuous = "kicks"
	response_harm_simple = "kick"
	attack_verb_continuous = "kicks"
	attack_verb_simple = "kick"
	health = 15
	maxHealth = 15
	ventcrawler = VENTCRAWLER_ALWAYS
	var/eggsleft = 0
	var/eggsFertile = TRUE
	var/body_color
	var/icon_prefix = "chicken"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	var/list/feedMessages = list("It clucks happily.","It clucks happily.")
	var/list/layMessage = EGG_LAYING_MESSAGES
	var/list/validColors = list("brown","black","white")
	gold_core_spawnable = FRIENDLY_SPAWN
	var/static/chicken_count = 0
	chat_color = "#FFDC9B"
	mobchatspan = "stationengineer"

	footstep_type = FOOTSTEP_MOB_CLAW

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	if(!body_color)
		body_color = pick(validColors)
	icon_state = "[icon_prefix]_[body_color]"
	icon_living = "[icon_prefix]_[body_color]"
	icon_dead = "[icon_prefix]_[body_color]_dead"
	held_state = "[icon_prefix]_[body_color]"
	head_icon = 'icons/mob/pets_held_large.dmi'
	pixel_x = rand(-6, 6)
	pixel_y = rand(0, 10)
	GLOB.total_chickens++

/mob/living/simple_animal/chicken/death(gibbed)
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chicken/Destroy()
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chicken/attackby(obj/item/O, mob/user, params)
	if(istype(O, food_type)) //feedin' dem chickens
		if(!stat && eggsleft < 8)
			var/feedmsg = "[user] feeds [O] to [name]! [pick(feedMessages)]"
			user.visible_message(feedmsg)
			qdel(O)
			eggsleft += rand(1, 4)
		else
			to_chat(user, span_warning("[name] doesn't seem hungry!"))
	else
		..()

/mob/living/simple_animal/chicken/Life()
	. =..()
	if(!.)
		return
	if((!stat && prob(3) && eggsleft > 0) && egg_type && GLOB.total_chickens < CONFIG_GET(number/max_chickens))
		visible_message("[src] [pick(layMessage)]")
		eggsleft--
		var/obj/item/E = new egg_type(get_turf(src))
		E.pixel_x = E.base_pixel_x + rand(-6,6)
		E.pixel_y = E.base_pixel_y + rand(-6,6)
		if(eggsFertile)
			if(prob(25))
				START_PROCESSING(SSobj, E)

/obj/item/food/egg/var/amount_grown = 0
/obj/item/food/egg/process(delta_time)
	if(isturf(loc))
		amount_grown += rand(1,2) * delta_time
		if(amount_grown >= 200)
			visible_message("[src] hatches with a quiet cracking sound.")
			new /mob/living/simple_animal/chick(get_turf(src))
			STOP_PROCESSING(SSobj, src)
			qdel(src)
	else
		STOP_PROCESSING(SSobj, src)

/mob/living/simple_animal/chicken/turkey
	name = "\improper turkey"
	desc = "it's that time again."
	icon_state = "turkey_plain"
	icon_living = "turkey_plain"
	icon_dead = "turkey_plain_dead"
	speak = list("Gobble!","GOBBLE GOBBLE GOBBLE!","Cluck.")
	speak_emote = list("clucks","gobbles")
	speak_language = /datum/language/metalanguage
	emote_hear = list("gobbles.")
	emote_see = list("pecks at the ground.","flaps its wings viciously.")
	density = FALSE
	health = 15
	maxHealth = 15
	egg_type = null
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = 'sound/creatures/turkey.ogg'
	ventcrawler = VENTCRAWLER_ALWAYS
	icon_prefix = "turkey"
	feedMessages = list("It gobbles up the food voraciously.","It clucks happily.")
	validColors = list("plain")
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"

/mob/living/simple_animal/chicken/rabbit
	name = "\improper rabbit"
	desc = "It's a rabbit, everyone knows what a rabbit is."
	icon = 'icons/mob/easter.dmi'
	icon_state = "b_rabbit_white"
	icon_living = "b_rabbit_white"
	icon_dead = "b_rabbit_white_dead"
	speak = null
	speak_emote = list("sniffles","twitches")
	emote_hear = list("hops.")
	emote_see = list("hops around","bounces up and down")
	icon_prefix = "b_rabbit"
	feedMessages = list("It nibbles happily.","It noms happily.")
	butcher_results = list(/obj/item/food/meat/slab = 1)
	food_type = /obj/item/food/grown/carrot
