/mob/living/simple_animal/kalo //basically an IC garbage collector for blood tracks and snacks
	name = "Kalo"
	desc = "The Janitor's tiny pet lizard." //does the job better than the janitor itself
	icon_state = "lizard"
	icon_living = "lizard"
	icon_dead = "lizard_dead"
	can_be_held = TRUE
	worn_slot_flags = ITEM_SLOT_HEAD
	held_state = "lizard"
	do_footstep = TRUE
	can_be_held = TRUE
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST, MOB_REPTILE)
	mob_size = MOB_SIZE_SMALL
	pass_flags = PASSTABLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	density = FALSE
	see_in_dark     = 5
	speak_chance    = 1
	turns_per_move  = 3
	response_help   = "pets"
	response_disarm = "shoos"
	response_harm   = "stomps"
	speak = list("Hissssss!", "Squeak!")
	speak_emote = list("hisses", "squeaks")
	emote_hear = list("hisses", "squeaks")
	emote_see = list("pounces")
	faction = list("Lizard")
	health = 15
	maxHealth = 15
	minbodytemp = 50
	maxbodytemp = 800
	var/turns_since_scan = 0
	var/obj/item/reagent_containers/food/snacks/movement_target
	mobchatspan = "centcom"

/mob/living/simple_animal/kalo/Destroy()
	movement_target = null
	return ..()

/mob/living/simple_animal/kalo/Life() //This code is absolute trash but I'm too sleepy to rewrite it.
	..()

	if(!stat && !resting && !buckled)
		turns_since_scan++
		if(turns_since_scan > 20)
			turns_since_scan = 0
			if((movement_target) && !isturf(movement_target.loc))
				movement_target = null
				stop_automated_movement = 0
			if(!movement_target || !(src in viewers(5, movement_target.loc)))
				stop_automated_movement = 0
				movement_target = locate(/obj/item/reagent_containers/food/snacks) in oview(5, src) //can smell things up to 5 blocks radius

			if(movement_target)
				stop_automated_movement = 1
				for(var/i = 1 to rand(5,7))
					sleep(rand(6,7))
					step_to(src,movement_target,1)

				if(movement_target)		//Not redundant due to sleeps
					if (movement_target.loc.x < src.x) setDir(WEST)
					else if (movement_target.loc.x > src.x) setDir(EAST)
					else if (movement_target.loc.y < src.y) setDir(SOUTH)
					else if (movement_target.loc.y > src.y) setDir(NORTH)
					else setDir(SOUTH)

					if(!Adjacent(movement_target)) //can't reach food through windows.
						return

					if(isturf(movement_target.loc) )
						if(movement_target.bitecount == 0 || prob(50))
							INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "nibbles on \the [movement_target]")
						movement_target.bitecount++
						taste(movement_target.reagents)
						turns_since_scan = 2
						if(movement_target.bitecount >= 4)
							if(prob(60))
								INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "burps")
							fully_heal()
							qdel(movement_target)
							turns_since_scan = 0

			else //if we don't see a better snack, lick up nearby blood
				var/obj/effect/decal/cleanable/blood/B
				for(var/obj/effect/decal/cleanable/blood/O in oview(2, src))
					if (!istype(O, /obj/effect/decal/cleanable/blood/gibs) && !istype(O, /obj/effect/decal/cleanable/blood/innards)) //dont lick up gibs or innards
						B = O
						break
				if(B)
					stop_automated_movement = 1
					step_to(src,B,1) //get up right next to it
					sleep(5)
					if (B.loc.x < src.x) setDir(WEST)
					else if (B.loc.x > src.x) setDir(EAST)
					else if (B.loc.y < src.y) setDir(SOUTH)
					else if (B.loc.y > src.y) setDir(NORTH)
					else setDir(SOUTH)
					if(Adjacent(B))
						sleep(30) //take your time
						if(B && Adjacent(B)) //make sure it's still there and we're still there
							if(prob(60))
								INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "licks up \the [B]")
							qdel(B)
							adjustBruteLoss(-5)
							stop_automated_movement = 0

		if(prob(1))
			INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "pounces around!")
			spawn(0)
				for(var/i in list(1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2,1,2,4,8,4,2)) //ian dance but longer
					setDir(i)
					sleep(1)

/mob/living/simple_animal/kalo/attack_hand(mob/living/carbon/human/M)
	..()
	if (M.a_intent == "help")
		if(prob(20))
			//yes lizards chirp I googled it it must be true
			INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, pick("chirps","squeaks"))
		turns_since_move = 0
	else
		if(prob(30))
			//no likey that
			INVOKE_ASYNC(src, /mob.proc/emote, "me", 1, "hisses!")
