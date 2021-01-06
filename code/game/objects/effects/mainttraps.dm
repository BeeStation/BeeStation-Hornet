#define PICK_STYLE_RANDOM 1
#define PICK_STYLE_ORDERED 2
#define PICK_STYLE_ALL 3

/obj/effect/trap
	name = "nasty trap"
	desc = "doesn't do much, really..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "gavelblock"
	invisibility = INVISIBILITY_MAXIMUM //sorry ghosts and curators, my tricks will remain hidden
	var/reusable = FALSE //can it trigger more than once
	var/inuse = FALSE //used to make sure it dont get used when it shouldnt

/obj/effect/trap/proc/TrapEffect(AM)
	return TRUE

/obj/effect/trap/trigger //this only triggers other traps
	name = "pressure pad"
	desc = "seems flimsy"
	var/grounded = FALSE //does it ignore fliers
	var/pick_style = PICK_STYLE_ORDERED
	var/requirehuman = TRUE
	var/list/possibletraps = list()

/obj/effect/trap/trigger/Crossed(AM as mob|obj)
	if(isturf(loc))
		if(ismob(AM) && grounded)
			var/mob/MM = AM
			if(!(MM.movement_type & FLYING))
				if(TrapEffect(AM))
					if(!reusable)
						qdel(src)
		else if(!requirehuman)
			if(TrapEffect(AM))
				if(!reusable)
					qdel(src)
		else if(ismob(AM))
			var/mob/MM = AM
			if(MM.mind)
				if(TrapEffect(AM))
					if(!reusable)
						qdel(src)

/obj/effect/trap/trigger/TrapEffect(AM)
	if(inuse)
		return FALSE
	else 
		inuse = TRUE
	if(!LAZYLEN(possibletraps))
		for(var/obj/effect/trap/nexus/payload in view(10, src))
			possibletraps += payload
		if(!LAZYLEN(possibletraps))
			qdel(src)
			return FALSE
	switch(pick_style)
		if(PICK_STYLE_RANDOM)
			var/obj/effect/trap/nexus/chosen = pick(possibletraps)
			if(chosen.TrapEffect(AM))
				if(!chosen.reusable)
					qdel(chosen)
				inuse = FALSE
				return TRUE
		if(PICK_STYLE_ORDERED)
			for(var/obj/effect/trap/nexus/chosen in possibletraps)
				if(chosen.TrapEffect(AM))
					if(!chosen.reusable)
						qdel(chosen)
					inuse = FALSE
					return TRUE
		if(PICK_STYLE_ALL)
			var/success = FALSE
			for(var/obj/effect/trap/nexus/chosen in possibletraps)
				if(chosen.TrapEffect(AM))
					if(!chosen.reusable)
						qdel(chosen)
					success = TRUE
				stoplag()
			if(success)
				inuse = FALSE
				return TRUE
	inuse = FALSE
	return FALSE

/obj/effect/trap/trigger/all
	pick_style = PICK_STYLE_ALL

/obj/effect/trap/trigger/random
	pick_style = PICK_STYLE_RANDOM

/obj/effect/trap/trigger/reusable
	desc = "seems sturdy"
	reusable = TRUE

/obj/effect/trap/trigger/reusable/all
	pick_style = PICK_STYLE_ALL

/obj/effect/trap/trigger/reusable/random
	pick_style = PICK_STYLE_RANDOM

/obj/effect/trap/nexus //this trap is triggered by pressurepads. doesnt do anything alone
	icon_state = "madeyoulook" 

/obj/effect/trap/nexus/doorbolt //a nasty little trap to put in a room with a simplemob
	name = "door bolter"
	desc = "locks an unfortunate victim in for a few seconds"
	var/locktime = 10 SECONDS

/obj/effect/trap/nexus/doorbolt/TrapEffect(AM)
	if(inuse)
		return FALSE
	else 
		inuse = TRUE
	var/list/airlocks = list()
	for(var/obj/machinery/door/airlock/airlock in view(10, src))
		airlocks += airlock
		airlock.unbolt()//you think you're so smart, hm? I'm smarter.
		if(!airlock.density)
			if(!airlock.close())
				airlock.safe = FALSE
				airlock.close(3)//yank that bitch shut as hard as you can. this'll be noisy
				airlock.visible_message("<span class='warning'>[airlock] shudders for a second, and then grinds closed ominously.</span>")
		airlock.bolt()
	stoplag(locktime)
	for(var/obj/machinery/door/airlock/airlock in airlocks)
		airlock.unbolt()
	inuse = FALSE
	return TRUE

/obj/effect/trap/nexus/cluwnecurse
	name = "honk :0)"
	desc = "oh god..."

/obj/effect/trap/nexus/cluwnecurse/TrapEffect(AM)
	var/turf/T = get_turf(src)
	for(var/mob/living/carbon/human/C in range(5, src))
		if(C.mind)
			var/mob/living/simple_animal/hostile/floor_cluwne/FC = new /mob/living/simple_animal/hostile/floor_cluwne(T)
			FC.force_target(C)
			FC.dontkill = TRUE
			FC.delete_after_target_killed = TRUE //it only affects the one to walk on the rune. when he dies, the rune is no longer usable
			playsound(C,'sound/misc/honk_echo_distant.ogg', 30, 1)
			return TRUE
	return FALSE

/obj/effect/trap/nexus/darkness
	name = "lightbreaker"
	desc = "for effect"

/obj/effect/trap/nexus/darkness/TrapEffect()
	for(var/obj/machinery/light/L in view(10, src))
		L.on = TRUE
		L.break_light_tube()
		L.on = FALSE
		stoplag()
	return TRUE

/obj/effect/trap/nexus/trickyspawner //attempts to spawn a simplemob somewhere out of sight, aggroed to the target
	name = "tricky little bastard"
	desc = "I don't think it's gonna do anything"
	var/crossattempts = 3
	var/crossed = 0
	var/mobs = 1
	reusable = TRUE
	var/mob/living/simple_animal/hostile/spawned = /mob/living/simple_animal/hostile/retaliate/spaceman

/obj/effect/trap/nexus/trickyspawner/Initialize()
	. = ..()
	crossattempts = rand(1, 10)

/obj/effect/trap/nexus/trickyspawner/TrapEffect(AM)
	crossed ++
	if(crossed <= crossattempts)
		return FALSE
	var/list/turfs = list()
	var/list/mobss = list()
	var/list/validturfs = list()
	var/turf/T = get_turf(src)
	for(var/atom/I in view(7, src))
		if(isopenturf(I))
			turfs += I 
			continue 
		if(isliving(I))
			var/mob/living/L = I
			if(L.mind)
				mobss += L 
				continue
	for(var/turf/turf in turfs)
		var/visible = FALSE
		if(isspaceturf(turf))
			continue
		for(var/mob/living/L in mobss)
			if(can_see(L, turf))
				visible = TRUE
		if(visible)
			continue
		validturfs += T
	if(validturfs.len)
		T = pick(validturfs)
	if(mobs)
		var/mob/living/simple_animal/hostile/spawninstance = new spawned(T)
		spawninstance.target = AM
		if(istype(spawninstance, /mob/living/simple_animal/hostile/retaliate))
			var/mob/living/simple_animal/hostile/retaliate/R = spawninstance
			R.enemies += AM 
		mobs--
		crossattempts = rand(1, 5)
		if(!mobs)
			reusable = FALSE
		return TRUE
	return TRUE

/obj/effect/trap/nexus/trickyspawner/catbutcher
	spawned = /mob/living/simple_animal/hostile/cat_butcherer/hugbox

/obj/effect/trap/nexus/trickyspawner/faithless
	spawned = /mob/living/simple_animal/hostile/faithless 

/obj/effect/trap/nexus/trickyspawner/shitsec
	spawned = /mob/living/simple_animal/hostile/nanotrasen/hugbox

/obj/effect/trap/nexus/trickyspawner/eldritch //currently unused. if used, note these guys are quite powerful with a whopping 35 melee
	spawned = /mob/living/simple_animal/hostile/netherworld

/obj/effect/trap/nexus/trickyspawner/spookyskeleton
	spawned = /mob/living/simple_animal/hostile/skeleton

/obj/effect/trap/nexus/trickyspawner/zombie
	spawned = /mob/living/simple_animal/hostile/zombie/hugbox

/obj/effect/trap/nexus/trickyspawner/xeno
	spawned = /mob/living/simple_animal/hostile/alien/hugbox

/obj/effect/trap/nexus/trickyspawner/honkling
	mobs = 5 //honklings are annoying, but nearly harmless. 
	spawned = /mob/living/simple_animal/hostile/retaliate/clown/honkling

/obj/effect/trap/nexus/trickyspawner/clownmutant
	spawned = /mob/living/simple_animal/hostile/retaliate/clown/mutant

/obj/effect/trap/nexus/trickyspawner/tree
	spawned = /mob/living/simple_animal/hostile/tree


#undef PICK_STYLE_RANDOM
#undef PICK_STYLE_ORDERED
#undef PICK_STYLE_ALL


/mob/living/simple_animal/hostile/nanotrasen/hugbox
	loot = list(/obj/effect/gibspawner/human)//no gamer gear, sorry!

/mob/living/simple_animal/hostile/zombie/hugbox
	melee_damage = 12 //zombies have a base of 21, a bit much
	stat_attack = CONSCIOUS

/mob/living/simple_animal/hostile/alien/hugbox
	health = 60 //they go down easy, to lull the player into a sense of false security
	maxHealth = 60 

/mob/living/simple_animal/hostile/cat_butcherer/hugbox //a cat butcher without a melee speed buff or a syringe gun. he's not too hard to take down, but can still go on catification rampages
	ranged = FALSE
	rapid_melee = 1
	loot = list(/obj/effect/mob_spawn/human/corpse/cat_butcher, /obj/item/circular_saw)

//this abomination goes in here because it doesnt really belong with normal cult runes
/obj/effect/rune/cluwne
	name = "odd drawing"
	desc = "a drawing on the floor, done in crayon. Odd."
	cultist_name = "Invocation rune"
	cultist_desc = "tears apart dimensional barriers, allowing a powerful elder being to exert its will upon the world. Requires at least nine invokers" //only shown to cultists, it does not actually require nine invokers if not used by cultists
	invocation = "HONK!!"
	req_cultists = 9//if a cultist invokes this, it acts like an invocation rune by asking them to check this. 
	icon = 'icons/effects/96x96.dmi'
	icon_state = "Cluwne"
	color = RUNE_COLOR_SUMMON
	pixel_x = -32
	pixel_y = -32
	rune_in_use = FALSE

/obj/effect/rune/cluwne/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/melee/cultblade/dagger) && iscultist(user))
		SEND_SOUND(user,'sound/items/sheath.ogg')
		if(do_after(user, 15, target = src))
			to_chat(user, "<span class='clown'>It's not within your power to erase the [lowertext(cultist_name)].</span>")
	else if(istype(I, /obj/item/nullrod))
		user.say("BEGONE FOUL MAGIKS!!", forced = "nullrod")
		to_chat(user, "<span class='danger'>You try to disrupt the magic of [src] with the [I], and nothing happens to the crude crayon markings. You feel foolish.</span>")

/obj/effect/rune/cluwne/attack_hand(mob/living/user)//this is where we check if someone is able to use the rune
	var/cluwne = FALSE
	if(rune_in_use)
		return
	for(var/mob/living/simple_animal/hostile/floor_cluwne/clown in range(5, src))
		cluwne = TRUE
		break
	if(!cluwne && !iscultist(user))
		if(ishuman(user))
			var/mob/living/carbon/human/H = user
			if(HAS_TRAIT(H, TRAIT_CLUMSY) || H.job == "Clown" || H.dna.check_mutation(CLUWNEMUT))
				to_chat(user, "<span class='warning'>We need a connection! One of the honkmother's manifested forms!</span>")
			else
				to_chat(user, "<span class='warning'>You touch the crayon drawing, and feel somewhat foolish.</span>")
		return
	if(ishuman(user))
		var/mob/living/carbon/human/H = user
		if((HAS_TRAIT(H, TRAIT_MUTE)) || H.silent)// NO MIMES
			to_chat(user, "<span class='warning'>The quiet cannot comprehend [src].</span>")
			return
		if(HAS_TRAIT(H, TRAIT_LAW_ENFORCEMENT_METABOLISM) || HAS_TRAIT(H, TRAIT_MINDSHIELD))// NO SHITSEC
			to_chat(user, "<span class='warning'>You're too disgusted by [src] to even consider touching it.</span>")
			return
		if(HAS_TRAIT(H, TRAIT_CLUMSY) || H.job == "Clown" || H.dna.check_mutation(CLUWNEMUT))
			var/list/invokers = can_invoke(user)
			if(invokers.len >= 5)
				to_chat(user, "<span class='warning'>Honestly, this is so simple even a baby could do it!</span>")
				invoke(invokers)
			else
				to_chat(user, "<span class='warning'>This would be no fun without at least five people on the rune!</span>")
			return
		if(iscultist(H)) //cultists are good at this kind of magic, so they can use it too
			var/list/invokers = can_invoke(user)
			if(invokers.len >= req_cultists)
				invoke(invokers)
				to_chat(user, "<span class='warning'>You have a bad feeling about this, but fuck it.</span>")
			return
	to_chat(user, "<span class='warning'>You touch the crayon drawing, and feel somewhat foolish.</span>")

/obj/effect/rune/cluwne/attack_animal(mob/living/simple_animal/M)
	if(rune_in_use)
		return
	if(istype(M, /mob/living/simple_animal/cluwne) || istype(M, /mob/living/simple_animal/hostile/retaliate/clown))
		var/cluwne = FALSE
		for(var/mob/living/simple_animal/hostile/floor_cluwne/clown in range(5, src))
			cluwne = TRUE
			break
		if(!cluwne)
			to_chat(M, "<span class='warning'>We need a connection! One of the honkmother's manifested forms!</span>")
		else
			var/list/invokers = can_invoke(M)
			invoke(invokers)
	return

/obj/effect/rune/cluwne/can_invoke(user) //this is actually used to get "sacrifices", which can include the user
	var/list/invokers = list() //people eligible to invoke the rune
	var/list/things_in_range = range(1, src)
	for(var/mob/living/carbon/human/L in things_in_range)
		if(!L.mind)
			continue
		if(L.stat)
			continue
		invokers += L
	return invokers

/obj/effect/rune/cluwne/invoke(var/list/invokers)
	..()
	rune_in_use = TRUE
	for(var/mob/living/simple_animal/hostile/floor_cluwne/FC in range(5, src)) //we unleash the floor cluwne 
		FC.dontkill = FALSE
		FC.delete_after_target_killed = FALSE
		FC.interest = 300
	color = RUNE_COLOR_SUMMON
	for(var/mob/living/carbon/C in view(10, src))
		C.Stun(350, ignore_canstun = TRUE)
	priority_announce("Figments of an elder god have been detected in your sector. Exercise extreme caution, and abide by the 'buddy system' at all times.","Central Command Higher Dimensional Affairs", 'sound/ai/spanomalies.ogg')
	stoplag(315)
	for(var/mob/living/carbon/human/H in invokers)
		if(H.stat == DEAD)
			continue
		H.blind_eyes(10)
		if(prob(10))
			var/mob/living/simple_animal/hostile/floor_cluwne/cluwne = new(src.loc)
			cluwne.force_target(H)
			cluwne.stage = 4
			if(prob(75))
				cluwne.delete_after_target_killed = TRUE
			to_chat(H, "<span class='Clown'>YOU'RE MINE!</span>")
		else if(prob(20))
			var/mob/living/simple_animal/hostile/floor_cluwne/cluwne = new(src.loc)
			cluwne.force_target(H)
			if(prob(75))
				cluwne.delete_after_target_killed = TRUE
			to_chat(H, "<span class='Clown'>Do you want to play a game?</span>")
		else if(prob(60))
			H.cluwneify()
			to_chat(H, "<span class='Clown'>Join us!</span>")
		else
			to_chat(H, "<span class='Clown'>You bore me.</span>")
	sound_to_playing_players('sound/misc/honk_echo_distant.ogg')
	qdel(src)