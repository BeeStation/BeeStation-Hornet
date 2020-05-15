#define UNREGISTER_BOMB_SIGNALS(A) \
	do { \
		UnregisterSignal(A, boom_signals); \
		UnregisterSignal(A, COMSIG_PARENT_EXAMINE); \
	} while (0)

/datum/guardian_ability/major/explosive
	name = "Explosive"
	desc = "The guardian can, with a single touch, turn any inanimate object into a bomb."
	ui_icon = "bomb"
	cost = 4
	var/bomb_cooldown = 0
	var/static/list/boom_signals = list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND)

/datum/guardian_ability/major/explosive/Apply()
	. = ..()
	guardian.verbs += /mob/living/simple_animal/hostile/guardian/proc/DetonateBomb

/datum/guardian_ability/major/explosive/Remove()
	. = ..()
	guardian.verbs -= /mob/living/simple_animal/hostile/guardian/proc/DetonateBomb

/datum/guardian_ability/major/explosive/Attack(atom/target)
	if(prob(40) && isliving(target))
		var/mob/living/M = target
		if(!M.anchored && M != guardian.summoner?.current && !guardian.hasmatchingsummoner(M))
			new /obj/effect/temp_visual/guardian/phase/out(get_turf(M))
			do_teleport(M, M, 10, channel = TELEPORT_CHANNEL_BLUESPACE)
			for(var/mob/living/L in range(1, M))
				if(guardian.hasmatchingsummoner(L)) //if the summoner matches don't hurt them
					continue
				if(L != guardian && L != guardian.summoner?.current)
					L.apply_damage(15, BRUTE)
			new /obj/effect/temp_visual/explosion(get_turf(M))

/datum/guardian_ability/major/explosive/AltClickOn(atom/A)
	if(!istype(A))
		return
	if(!guardian.is_deployed())
		to_chat(guardian, "<span class='danger'><B>You must be manifested to create bombs!</B></span>")
		return
	if(isobj(A) && guardian.Adjacent(A))
		if(bomb_cooldown <= world.time && !guardian.stat)
			to_chat(guardian, "<span class='danger'><B>Success! Bomb armed!</B></span>")
			bomb_cooldown = world.time + 200
			RegisterSignal(A, COMSIG_PARENT_EXAMINE, .proc/display_examine)
			RegisterSignal(A, boom_signals, .proc/kaboom)
			addtimer(CALLBACK(src, .proc/disable, A), master_stats.potential * 18 * 10, TIMER_UNIQUE|TIMER_OVERRIDE)
			guardian.bombs += A
		else
			to_chat(guardian, "<span class='danger'><B>Your powers are on cooldown! You must wait 20 seconds between bombs.</B></span>")

/datum/guardian_ability/major/explosive/proc/kaboom(atom/source, mob/living/explodee)
	if(!istype(explodee))
		return
	if(explodee == guardian || explodee == guardian.summoner?.current || guardian.hasmatchingsummoner(explodee))
		return
	to_chat(explodee, "<span class='danger'><B>[source] was boobytrapped!</B></span>")
	to_chat(guardian, "<span class='danger'><B>Success! Your trap caught [explodee]</B></span>")
	var/turf/T = get_turf(source)
	playsound(T,'sound/effects/explosion2.ogg', 200, 1)
	new /obj/effect/temp_visual/explosion(T)
	explodee.ex_act(EXPLODE_HEAVY)
	guardian.bombs -= source
	UNREGISTER_BOMB_SIGNALS(source)

/datum/guardian_ability/major/explosive/proc/disable(atom/A)
	to_chat(src, "<span class='danger'><B>Failure! Your trap didn't catch anyone this time.</B></span>")
	guardian.bombs -= A
	UNREGISTER_BOMB_SIGNALS(A)

/datum/guardian_ability/major/explosive/proc/display_examine(datum/source, mob/user, text)
	text += "<span class='holoparasite'>It glows with a strange <font color=\"[guardian.guardiancolor]\">light</font>!</span>"


/mob/living/simple_animal/hostile/guardian/proc/DetonateBomb()
	set name = "Detonate Bomb"
	set category = "Guardian"
	set desc = "Detonate an armed bomb manually."
	var/picked_bomb = input(src, "Pick which bomb to detonate", "Detonate Bomb") as null|anything in src.bombs
	if(picked_bomb)
		bombs -= picked_bomb
		UnregisterSignal(picked_bomb, list(COMSIG_PARENT_ATTACKBY, COMSIG_ATOM_BUMPED, COMSIG_ATOM_ATTACK_HAND));
		UnregisterSignal(picked_bomb, COMSIG_PARENT_EXAMINE);
		explosion(picked_bomb, -1, 1, 1, 1)
		to_chat(src, "<span class='danger'><B>Bomb detonated.</span></B>")

#undef UNREGISTER_BOMB_SIGNALS
