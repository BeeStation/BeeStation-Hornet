//Cat
/mob/living/simple_animal/pet/cat
	name = "cat"
	desc = "Kitty!!"
	icon = 'icons/mob/pets.dmi'
	icon_state = "cat2"
	icon_living = "cat2"
	icon_dead = "cat2_dead"
	gender = MALE
	speak = list("Meow!", "Esp!", "Purr!", "HSSSSS")
	speak_emote = list("purrs", "meows")
	speak_language = /datum/language/metalanguage
	emote_hear = list("meows.", "mews.")
	emote_see = list("shakes its head.", "shivers.")
	speak_chance = 1
	turns_per_move = 5
	see_in_dark = 6
	ventcrawler = VENTCRAWLER_ALWAYS
	pass_flags = PASSTABLE
	mob_size = MOB_SIZE_SMALL
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	minbodytemp = 200
	maxbodytemp = 400
	unsuitable_atmos_damage = 1
	animal_species = /mob/living/simple_animal/pet/cat
	childtype = list(/mob/living/simple_animal/pet/cat/kitten)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1, /obj/item/organ/tongue/cat = 1)
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "kicks"
	var/turns_since_scan = 0
	var/mob/living/simple_animal/mouse/movement_target
	gold_core_spawnable = FRIENDLY_SPAWN
	collar_type = "cat"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "cat2"
	chat_color = "#FFD586"

	do_footstep = TRUE

/mob/living/simple_animal/pet/cat/Initialize(mapload)
	. = ..()
	add_verb(/mob/living/proc/lay_down)

/mob/living/simple_animal/pet/cat/space
	name = "space cat"
	desc = "It's a cat... in space!"
	icon_state = "spacecat"
	icon_living = "spacecat"
	icon_dead = "spacecat_dead"
	unsuitable_atmos_damage = 0
	minbodytemp = TCMB
	maxbodytemp = T0C + 40
	held_state = "spacecat"

/mob/living/simple_animal/pet/cat/original
	name = "Batsy"
	desc = "The product of alien DNA and bored geneticists."
	gender = FEMALE
	icon_state = "original"
	icon_living = "original"
	icon_dead = "original_dead"
	collar_type = null
	unique_pet = TRUE
	held_state = "original"

/mob/living/simple_animal/pet/cat/kitten
	name = "kitten"
	desc = "D'aaawwww."
	icon_state = "kitten"
	icon_living = "kitten"
	icon_dead = "kitten_dead"
	density = FALSE
	pass_flags = PASSMOB
	mob_size = MOB_SIZE_SMALL
	collar_type = "kitten"

//RUNTIME IS ALIVE! SQUEEEEEEEE~
/mob/living/simple_animal/pet/cat/Runtime
	name = "Runtime"
	desc = "GCAT"
	icon_state = "cat"
	icon_living = "cat"
	icon_dead = "cat_dead"
	gender = FEMALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE
	var/list/family = list()//var restored from savefile, has count of each child type
	var/list/children = list()//Actual mob instances of children
	var/cats_deployed = 0
	var/memory_saved = FALSE
	held_state = "cat"

/mob/living/simple_animal/pet/cat/Runtime/Initialize(mapload)
	if(prob(5))
		icon_state = "original"
		icon_living = "original"
		icon_dead = "original_dead"
	Read_Memory()
	. = ..()

/mob/living/simple_animal/pet/cat/Runtime/Life()
	if(!cats_deployed && SSticker.current_state >= GAME_STATE_SETTING_UP)
		Deploy_The_Cats()
	if(!stat && SSticker.current_state == GAME_STATE_FINISHED && !memory_saved)
		Write_Memory()
		memory_saved = TRUE
	..()

/mob/living/simple_animal/pet/cat/Runtime/make_babies()
	var/mob/baby = ..()
	if(baby)
		children += baby
		return baby

/mob/living/simple_animal/pet/cat/Runtime/death()
	if(!memory_saved)
		Write_Memory(TRUE)
	..()

/mob/living/simple_animal/pet/cat/Runtime/proc/Read_Memory()
	if(fexists("data/npc_saves/Runtime.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Runtime.sav")
		S["family"] >> family
		fdel("data/npc_saves/Runtime.sav")
	else
		var/json_file = file("data/npc_saves/Runtime.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(rustg_file_read(json_file))
		family = json["family"]
	if(isnull(family))
		family = list()

/mob/living/simple_animal/pet/cat/Runtime/proc/Write_Memory(dead)
	var/json_file = file("data/npc_saves/Runtime.json")
	var/list/file_data = list()
	family = list()
	if(!dead)
		for(var/mob/living/simple_animal/pet/cat/kitten/C in children)
			if(istype(C,type) || C.stat || !C.z || !C.butcher_results) //That last one is a work around for hologram cats
				continue
			if(C.type in family)
				family[C.type] += 1
			else
				family[C.type] = 1
	file_data["family"] = family
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/mob/living/simple_animal/pet/cat/Runtime/proc/Deploy_The_Cats()
	cats_deployed = 1
	for(var/cat_type in family)
		if(family[cat_type] > 0)
			for(var/i in 1 to min(family[cat_type],25)) //Limits to about 25 cats, whoever thought leaving the max at 500 was a genius. Prevents catsplosions.
				new cat_type(loc)

/mob/living/simple_animal/pet/cat/Proc
	name = "Proc"
	gender = MALE
	gold_core_spawnable = NO_SPAWN
	unique_pet = TRUE

/mob/living/simple_animal/pet/cat/Move()
	. = ..()
	if(.)
		if(stat || resting || buckled)
			return .

		for(var/mob/living/simple_animal/mouse/M in get_turf(src))
			if(!M.stat)
				INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, "splats \the [M]!")
				M.splat()
				movement_target = null
				stop_automated_movement = 0
				break
		for(var/obj/item/toy/cattoy/T in get_turf(src))
			if (T.cooldown < (world.time - 400))
				INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, "bats \the [T] around with its paw!")
				T.cooldown = world.time

/mob/living/simple_animal/pet/cat/update_resting()
	. = ..()
	if(stat != DEAD)
		if (resting)
			icon_state = "[icon_living]_rest"
			collar_type = "[initial(collar_type)]_rest"
		else
			icon_state = "[icon_living]"
			collar_type = "[initial(collar_type)]"

/mob/living/simple_animal/pet/cat/Life()
	if(!stat && !buckled && !client)
		if(prob(3))
			switch(rand(1, 3))
				if (1)
					INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("stretches out for a belly rub.", "wags its tail.", "lies down."))
					set_resting(TRUE)
				if (2)
					INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("sits down.", "crouches on its hind legs.", "looks alert."))
					set_resting(TRUE)
					icon_state = "[icon_living]_sit"
					collar_type = "[initial(collar_type)]_sit"
				if (3)
					if (resting)
						INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("gets up and meows.", "walks around.", "stops resting."))
						set_resting(FALSE)
					else
						INVOKE_ASYNC(src, TYPE_PROC_REF(/mob, emote), "me", 1, pick("grooms its fur.", "twitches its whiskers.", "shakes out its coat."))

	..()
	if(next_scan_time <= world.time)
		make_babies()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 5)
			SSmove_manager.stop_looping(src)
			turns_since_scan = 0
			if((movement_target) && !(isturf(movement_target.loc) || ishuman(movement_target.loc) ))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(src in viewers(3, movement_target.loc)))
				movement_target = null
				stop_automated_movement = 0
				for(var/mob/living/simple_animal/mouse/snack in oview(3, src))
					if(!snack.stat)
						movement_target = snack
						break
			if(movement_target)
				stop_automated_movement = 1
				SSmove_manager.move_to(src, movement_target, 0, 3)

/mob/living/simple_animal/pet/cat/attack_hand(mob/living/carbon/human/M)
	. = ..()
	switch(M.a_intent)
		if("help")
			wuv(TRUE, M)
		if("harm")
			wuv(FALSE, M)

/mob/living/simple_animal/pet/cat/proc/wuv(change, mob/M)
	if(change)
		if(M && stat != DEAD)
			new /obj/effect/temp_visual/heart(loc)
			emote("me", 1, "purrs!")
			if(flags_1 & HOLOGRAM_1)
				return
			SEND_SIGNAL(M, COMSIG_ADD_MOOD_EVENT, src, /datum/mood_event/pet_animal, src)
	else
		if(M && stat != DEAD)
			emote("me", 1, "hisses!")

/mob/living/simple_animal/pet/cat/cak //I told you I'd do it, Remie
	name = "Keeki"
	desc = "It's a cat made out of cake."
	icon_state = "cak"
	icon_living = "cak"
	icon_dead = "cak_dead"
	health = 50
	maxHealth = 50
	gender = FEMALE
	butcher_results = list(/obj/item/organ/brain = 1, /obj/item/organ/heart = 1, /obj/item/food/cakeslice/birthday = 3,  \
	/obj/item/reagent_containers/food/snacks/meat/slab = 2)
	response_harm = "takes a bite out of"
	attacked_sound = 'sound/items/eatfood.ogg'
	deathmessage = "loses its false life and collapses!"
	deathsound = "bodyfall"
	held_state = "cak"

/mob/living/simple_animal/pet/cat/cak/CheckParts(list/parts)
	..()
	var/obj/item/organ/brain/B = locate(/obj/item/organ/brain) in contents
	if(!B || !B.brainmob || !B.brainmob.mind)
		return
	B.brainmob.mind.transfer_to(src)
	to_chat(src, "<span class='big bold'>You are a cak!</span><b> You're a harmless cat/cake hybrid that everyone loves. People can take bites out of you if they're hungry, but you regenerate health \
	so quickly that it generally doesn't matter. You're remarkably resilient to any damage besides this and it's hard for you to really die at all. You should go around and bring happiness and \
	free cake to the station!</b>")
	var/new_name = stripped_input(src, "Enter your name, or press \"Cancel\" to stick with Keeki.", "Name Change")
	if(new_name)
		to_chat(src, "<span class='notice'>Your name is now <b>\"new_name\"</b>!</span>")
		name = new_name

/mob/living/simple_animal/pet/cat/cak/Life()
	..()
	if(stat)
		return
	if(health < maxHealth)
		adjustBruteLoss(-8) //Fast life regen

/mob/living/simple_animal/pet/cat/cak/Move()
	. = ..()
	if(. && !stat)
		for(var/obj/item/reagent_containers/food/snacks/donut/D in get_turf(src)) //Frosts nearby donuts!
			if(!D.is_decorated)
				D.decorate_donut()

/mob/living/simple_animal/pet/cat/cak/attack_hand(mob/living/L)
	..()
	if(L.a_intent == INTENT_HARM && L.reagents && !stat)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment, 0.4)
		L.reagents.add_reagent(/datum/reagent/consumable/nutriment/vitamin, 0.4)

/mob/living/simple_animal/pet/cat/breadcat
	name = "bread cat"
	desc = "It's a cat... with a bread!"
	gender = MALE
	icon_state = "breadcat"
	icon_living = "breadcat"
	icon_dead = "breadcat_dead"
	collar_type = null
	held_state = "breadcat"
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2, /obj/item/organ/ears/cat = 1, /obj/item/organ/tail/cat = 1, /obj/item/organ/tongue/cat = 1, /obj/item/food/breadslice/plain = 1)

/mob/living/simple_animal/pet/cat/halal
	name = "arabian cat"
	desc = "It's a cat with Agal on his head."
	gender = MALE
	icon_state = "cathalal"
	icon_living = "cathalal"
	collar_type = null
	held_state = "cathalal"
