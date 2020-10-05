/mob/living/simple_animal/hostile/statue/scp_173
	name = "SCP-173"
	icon = 'Oasis/SCP_MAIN/icons/scpmobs/scp-173.dmi'
	desc = "<b><span class='warning'><big>SCP-173</big></span></b> - A statue, constructed from concrete and rebar with traces of Krylon brand spray paint"
	ventcrawler = VENTCRAWLER_NUDE
	icon_state = "173"
	icon_living = "173"
	icon_dead = "173"
	obj_damage = 500
	melee_damage = 1000
	attacktext = "crushes"
	attack_sound = 'Oasis/SCP_MAIN/sound/scp/spook/NeckSnap1.ogg'
	spacewalk = TRUE //Move in space
	move_force = MOVE_FORCE_NORMAL
	environment_smash = ENVIRONMENT_SMASH_WALLS
	speed = -5

	var/last_snap = 0

/mob/living/simple_animal/hostile/statue/scp_173/examine(mob/user)
	. = ..()

/mob/living/simple_animal/hostile/statue/scp_173/Life() // BLINK IF IN RANGE
	. = ..()
	if (isobj(loc))
		return

	for(var/A in next_blinks)
		if(!(A in viewers(world.view + 1, A) - src))
			next_blinks[A] = null
			continue
		if(world.time >= next_blinks[A])
			var/mob/living/carbon/human/H = A
			if(H.stat) // Sleeping or dead people can't blink!
				next_blinks[A] = null
				continue
			H.visible_message("<span class='notice'>[H] blinks.</span>")
			H.blind_eyes(2)
			next_blinks[H] = 10+world.time+rand(10 SECONDS, 40 SECONDS)





/mob/living/simple_animal/hostile/statue/scp_173/AttackingTarget() // AI ATTACKBLOCK
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, "<span class='warning'>You cannot attack, there are eyes on you!</span>")
		return FALSE
	else
		if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) || istype(target, /obj/machinery/light) || istype(target, /obj/machinery/light/small) || istype(target, /obj/machinery/vending) || istype(target, /obj/machinery/door) || istype(target, /obj/machinery/computer) || istype(target, /obj/structure/closet) || istype(target, /obj/structure/girder) || istype(target, /obj/structure/grille) || istype(target, /turf/closed/wall))
			return ..()  //The above line checks for lights, tables, computers, vendimg machines, doors, racks and closets. if the target is any of these objects, Attack as normal doing obj_damage)
		else if(istype(target,/mob))
			if(isliving(target))
				var/mob/living/H = target
				if(target == src)
					to_chat(src, "<span class='warning'><I>You can't hit yourself!</I></span>")
					return
				else if(ishuman(target)) //If target is a human subtype, Snap their neck
					visible_message("<span class='danger'>[src] snaps [target]'s neck!</span>")
					playsound(loc, pick('Oasis/SCP_MAIN/sound/scp/spook/NeckSnap1.ogg', 'Oasis/SCP_MAIN/sound/scp/spook/NeckSnap3.ogg'), 50, 1)
					H.death()
				else if(isliving(target)) //If target is not a human subtype but still a living thing, crush it
					visible_message("<span class='danger'>[src] crushes [target] with raw force!</span>")
					playsound(loc, pick('Oasis/SCP_MAIN/sound/scp/spook/NeckSnap1.ogg', 'Oasis/SCP_MAIN/sound/scp/spook/NeckSnap3.ogg'), 50, 1)
					H.death()
				else
					return FALSE // this is just for error catching
		else
			to_chat(src, "<span class='warning'><I>Why would we waste our energy attacking [target]</I></span>")
			return // If none of the above, dont attack



/mob/living/simple_animal/hostile/statue/scp_173/UnarmedAttack(var/atom/target) // PLAYER ATTACKBLOCK
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, "<span class='warning'>You cannot attack, there are eyes on you!</span>")
		return FALSE
	else
		if(istype(target, /obj/structure/table) || istype(target, /obj/structure/rack) || istype(target, /obj/machinery/light) || istype(target, /obj/machinery/light/small) || istype(target, /obj/machinery/vending) || istype(target, /obj/machinery/door) || istype(target, /obj/machinery/computer) || istype(target, /obj/structure/closet) || istype(target, /obj/structure/girder) || istype(target, /obj/structure/grille) || istype(target, /turf/closed/wall))
			return ..()  //The above line checks for lights, tables, computers, vendimg machines, doors, racks and closets. if the target is any of these objects, Attack as normal doing obj_damage
		else if(istype(target,/mob))
			if(isliving(target))
				var/mob/living/H = target
				if(target == src)
					to_chat(src, "<span class='warning'><I>Why would we waste our energy attacking ourselves?</I></span>")
					return
				else if(ishuman(target)) //If target is a human subtype, Snap their neck
					visible_message("<span class='danger'>[src] snaps [target]'s neck!</span>")
					playsound(loc, pick('Oasis/SCP_MAIN/sound/scp/spook/NeckSnap1.ogg', 'Oasis/SCP_MAIN/sound/scp/spook/NeckSnap3.ogg'), 50, 1)
					H.death()
				else if(isliving(target)) //If target is not a human subtype but still a living thing, crush it
					visible_message("<span class='danger'>[src] crushes [target] with raw force!</span>")
					playsound(loc, pick('Oasis/SCP_MAIN/sound/scp/spook/NeckSnap1.ogg', 'Oasis/SCP_MAIN/sound/scp/spook/NeckSnap3.ogg'), 50, 1)
					H.death()
				else
					return FALSE // this is just for error catching
		else
			to_chat(src, "<span class='warning'><I>Why would we waste our energy attacking [target]</I></span>")
			return // If none of the above, dont attack
