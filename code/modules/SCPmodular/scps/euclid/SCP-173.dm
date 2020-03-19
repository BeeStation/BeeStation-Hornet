/mob/living/simple_animal/hostile/scp_173
	name = "SCP-173"
	desc = "A statue, constructed from concrete and rebar with traces of Krylon brand spray paint"
	icon = 'hippiestation/icons/mob/scpicon/scpmobs/scp-173.dmi'
	ventcrawler = VENTCRAWLER_NUDE
	icon_state = "173"

	maxHealth = 5000
	health = 5000
	move_force = MOVE_FORCE_NORMAL
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	response_help = "touches"
	response_disarm = "pushes"
	a_intent = INTENT_HARM
//	possible_a_intents = list(INTENT_HARM)
	harm_intent_damage = 1
	obj_damage = 500
	melee_damage_lower = 5000

	melee_damage_upper = 5000

	armour_penetration = 5000


	attacktext = "crushes"
	attack_sound = 'hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg'

	spacewalk = TRUE




	var/last_snap = 0
	var/list/next_blinks = list()
	var/cannot_be_seen = 1
	animate_movement = NO_STEPS // Do not animate movement, you jump around as you're a scary statue.
	see_in_dark = 13
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	vision_range = 12
	aggro_vision_range = 12
	sight = SEE_SELF|SEE_MOBS|SEE_OBJS|SEE_TURFS

	search_objects = 1 // So that it can see through walls

/mob/living/simple_animal/hostile/scp_173/say(message, bubble_type, var/list/spans = list(), sanitize = TRUE, datum/language/language = null, ignore_spam = FALSE, forced = null)
	return FALSE

/mob/living/simple_animal/hostile/scp_173/Initialize(mapload, var/mob/living/creator)
	. = ..()
	// Give spells
	mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/flicker_lights(src)
	mob_spell_list += new /obj/effect/proc_holder/spell/aoe_turf/blindness(src)
	mob_spell_list += new /obj/effect/proc_holder/spell/targeted/night_vision(src) //this is being kept just incase normal vision fucks up

/mob/living/simple_animal/hostile/scp_173/proc/can_be_seen(turf/destination)
	if(!cannot_be_seen)
		return null
	// Check for darkness
	var/turf/T = get_turf(loc)
	if(T && destination && T.lighting_object)
		if(T.get_lumcount()<0.1 && destination.get_lumcount()<0.1) // No one can see us in the darkness, right?
			return null
		if(T == destination)
			destination = null

	// We aren't in darkness, loop for viewers.
	var/list/check_list = list(src)
	if(destination)
		check_list += destination




	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(world.view + 1, check) - src)
			if(M.client && !M.has_unlimited_silicon_privilege)
				if(!M.eye_blind)
					if(next_blinks[M] == null)
						next_blinks[M] = world.time+rand(15 SECONDS, 60 SECONDS)
					return M
		for(var/obj/mecha/M in view(world.view + 1, check)) //assuming if you can see them they can see you
			if(M.occupant && M.occupant.client)
				if(!M.occupant.eye_blind)
					if(next_blinks[M.occupant] == null)
						next_blinks[M.occupant] = world.time+rand(15 SECONDS, 60 SECONDS)
					return M.occupant
	return null






/*    VIEWLOOP
	// This loop will, at most, loop twice.
	for(var/atom/check in check_list)
		for(var/mob/living/M in viewers(world.view + 1, check) - src)
			if(M.client && !M.has_unlimited_silicon_privilege)
				if(!M.eye_blind)
					return M
		for(var/obj/mecha/M in view(world.view + 1, check)) //assuming if you can see them they can see you
			if(M.occupant && M.occupant.client)
				if(!M.occupant.eye_blind)
					return M.occupant
	return null
*/


/mob/living/simple_animal/hostile/scp_173/Move(turf/NewLoc)
	if(can_be_seen(NewLoc))
		if(client)
			to_chat(src, "<span class='warning'>You cannot move, there are eyes on you!</span>")
		return 0
	return ..()

/mob/living/simple_animal/hostile/scp_173/movement_delay()
	return -5



/mob/living/simple_animal/hostile/scp_173/Life()
	. = ..()
	if (isobj(loc))
		return
	var/list/our_view = view(src, 23)
	for(var/A in next_blinks)
		if(!(A in our_view))
			next_blinks[A] = null
			continue
		if(world.time >= next_blinks[A])
			var/mob/living/carbon/human/H = A
			if(H.stat) // Sleeping or dead people can't blink!
				next_blinks[A] = null
				continue
			H.visible_message("<span class='notice'>[H] blinks.</span>")
			H.blind_eyes(2)
			next_blinks[H] = 10+world.time+rand(15 SECONDS, 60 SECONDS)





/mob/living/simple_animal/hostile/scp_173/sentience_act()
	faction -= "neutral"


/mob/living/simple_animal/hostile/scp_173/AttackingTarget(/*var/atom/A*/) // doesnt work?
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, "<span class='warning'>You cannot attack, there are eyes on you!</span>")
		return FALSE
	else
		var/mob/living/H = target
		if(isliving(target))
			if(target == src)
				to_chat(src, "<span class='warning'><I>You can't hit yourself!</I></span>")
			if(ishuman(H))
				visible_message("<span class='danger'>[src] snaps [H]'s neck!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			if(!ishuman(H))
				visible_message("<span class='danger'>[src] crushes [H] with raw force!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			if(!isliving(target))
				visible_message("<span class='danger'>[src] crushes [H] with raw force!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			else
				return FALSE // this is just for error catching
		else
			return ..()
/*			to_chat(src, "<span class='warning'><I>Why would we waste our energy attacking [H]</I></span>")
			return //doesnt allow 173 to attack apcs
*/

/mob/living/simple_animal/hostile/scp_173/DestroyPathToTarget()
	if(!can_be_seen(get_turf(loc)))
		..()


/*
/mob/living/simple_animal/hostile/scp_173/UnarmedAttack(var/atom/A)
	if(can_be_seen(get_turf(loc)))
		if(client)
			to_chat(src, "<span class='warning'>You cannot attack, there are eyes on you!</span>")
		return FALSE
	else
		var/mob/living/H = A
		if(isliving(A))
			if(A == src)
				to_chat(src, "<span class='warning'><I>Why would we waste our energy attacking ourselves?</I></span>")
				return
			if(ishuman(A))
				visible_message("<span class='danger'>[src] snaps [H]'s neck!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			if(!ishuman(A))
				visible_message("<span class='danger'>[src] crushes [H] with raw force!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			if(!ismob(A))
				visible_message("<span class='danger'>[src] crushes [H] with raw force!</span>")
				playsound(loc, pick('hippiestation/sound/scpsounds/scp/spook/NeckSnap1.ogg', 'hippiestation/sound/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
				H.death()
			else
				return // this is just for error catching
		else
			return ..()
*/
