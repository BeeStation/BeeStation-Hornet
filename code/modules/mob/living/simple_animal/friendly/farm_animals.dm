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
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
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

/mob/living/simple_animal/hostile/retaliate/goat/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(.)
		//chance to go crazy and start wacking stuff
		if(!enemies.len && DT_PROB(0.5, delta_time))
			Retaliate()

		if(enemies.len && DT_PROB(5, delta_time))
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
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
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
	var/can_grow = TRUE
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
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/chick/Life(delta_time = SSMOBS_DT, times_fired)
	. =..()
	if(!.)
		return
	if(!can_grow)
		return
	if(!stat && !ckey)
		amount_grown += rand(0.5 * delta_time, 1 * delta_time)
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

/mob/living/simple_animal/chick/holo
	can_grow = FALSE

/mob/living/simple_animal/chick/dave
	name = "Dave"
	desc = "A tiny chick personally rescued from the station's kitchen by the captain, now it's the bridge mascot. Despite his previous high density broiler diet, he seemingly does not grow or age."
	can_grow = FALSE

/mob/living/simple_animal/chicken
	name = "\improper chicken"
	desc = "Hopefully the eggs are good this season."
	gender = FEMALE
	mob_biotypes = MOB_ORGANIC|MOB_BEAST
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
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	pass_flags = PASSTABLE | PASSMOB
	mob_size = MOB_SIZE_SMALL
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
	mobchatspan = "stationengineer"

	footstep_type = FOOTSTEP_MOB_CLAW
	///counter for how many chickens are in existence to stop too many chickens from lagging shit up
	var/static/chicken_count = 0
	///boolean deciding whether eggs laid by this chicken can hatch into chicks
	var/process_eggs = TRUE

/mob/living/simple_animal/chicken/Initialize(mapload)
	. = ..()
	GLOB.total_chickens++
	AddElement(/datum/element/animal_variety, "chicken", pick("brown","black","white"), TRUE)
	AddComponent(/datum/component/egg_layer,\
		/obj/item/food/egg,\
		list(/obj/item/food/grown/wheat),\
		feed_messages = list("[p_they()] clucks happily."),\
		lay_messages = EGG_LAYING_MESSAGES,\
		eggs_left = 0,\
		eggs_added_from_eating = rand(1, 4),\
		max_eggs_held = 8,\
		egg_laid_callback = CALLBACK(src, PROC_REF(egg_laid))\
	)
	ADD_TRAIT(src, TRAIT_VENTCRAWLER_ALWAYS, INNATE_TRAIT)

/mob/living/simple_animal/chicken/death(gibbed)
	GLOB.total_chickens--
	..()

/mob/living/simple_animal/chicken/Destroy()
	if(stat != DEAD)
		GLOB.total_chickens--
	return ..()

/mob/living/simple_animal/chicken/proc/egg_laid(obj/item/egg)
	if(chicken_count <= GLOB.total_chickens && process_eggs && prob(25))
		START_PROCESSING(SSobj, egg)

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
	attack_verb_continuous = "pecks"
	attack_verb_simple = "peck"
	attack_sound = 'sound/creatures/turkey.ogg'
	gold_core_spawnable = FRIENDLY_SPAWN
	chat_color = "#FFDC9B"
