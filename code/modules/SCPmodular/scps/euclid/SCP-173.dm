/mob/living/scp_173
	name = "SCP-173"
	desc = "A statue, constructed from concrete and rebar with traces of Krylon brand spray paint"
	icon = 'code/modules/SCPmodular/spcicon/scpmobs/scp-173.dmi'
	ventcrawler = VENTCRAWLER_NUDE
	icon_state = "173"

	maxHealth = 5000000000
	health = 5000000000

	var/last_snap = 0
	var/list/next_blinks = list()

/mob/living/scp_173/examine(mob/user)
	user << "<b><span class = 'euclid'><big>SCP-173</big></span></b> - [desc]"

/mob/living/scp_173/Destroy()
	..()

/mob/living/scp_173/say(var/message)
	return // lol you can't talk

/mob/living/scp_173/proc/IsBeingWatched()
	// Am I being watched by eye pals?
	for (var/mob/living/M in view(src, 7))


	// Am I being watched by anyone else?
	for(var/mob/living/carbon/human/H in view(src, 7))
		if(is_blind(H) || H.eye_blind > 0)
			continue
		if(H.stat != CONSCIOUS)
			continue
		if(next_blinks[H] == null)
			next_blinks[H] = world.time+rand(15 SECONDS, 45 SECONDS)
		if(H.in view(src, 7))
			return TRUE
	return FALSE

/mob/living/scp_173/Move(a,b,f)
	if(IsBeingWatched())
		return FALSE
	return ..(a,b,f)

/mob/living/scp_173/movement_delay()
	return -5

/mob/living/scp_173/UnarmedAttack(var/atom/A)
	if(!IsBeingWatched() && ishuman(A))
		var/mob/living/carbon/human/H = A
		if(H.stat == DEAD)
			to_chat(src, "<span class='warning'><I>[H] is already dead!</I></span>")
			return
		visible_message("<span class='danger'>[src] snaps [H]'s neck!</span>")
		playsound(loc, pick('code/modules/SCPmodular/scpsounds/scp/spook/NeckSnap1.ogg', 'code/modules/SCPmodular/scpsounds/scp/spook/NeckSnap3.ogg'), 50, 1)
		H.death()

/mob/living/scp_173/Life()
	. = ..()
	if (isobj(loc))
		return
	var/list/our_view = view(src, 7)
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
			H.eye_blind += 2
			next_blinks[H] = 10+world.time+rand(15 SECONDS, 45 SECONDS)


