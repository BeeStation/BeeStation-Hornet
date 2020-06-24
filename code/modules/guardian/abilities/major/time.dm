/datum/guardian_ability/major/time
	name = "Time Erasure"
	desc = "The guardian can erase a short period of time."
	ui_icon = "theater-masks"
	cost = 6
	spell_type = /obj/effect/proc_holder/spell/self/erase_time
	arrow_weight = 0.2

/datum/guardian_ability/major/time/Apply()
	. = ..()
	var/obj/effect/proc_holder/spell/self/erase_time/S = spell
	S.length = master_stats.potential * 2 * 10

/obj/effect/proc_holder/spell/self/erase_time
	name = "Erase Time"
	desc = "Erase the very concept of time for a short period of time."
	clothes_req = FALSE
	human_req = FALSE
	charge_max = 90 SECONDS
	action_icon_state = "time"
	var/length = 10 SECONDS

/obj/effect/proc_holder/spell/self/erase_time/cast(list/targets, mob/user)
	if(!isturf(user.loc) && !isguardian(user))
		revert_cast()
		return
	var/list/immune = list(user)
	var/list/fakes = list()
	if(isguardian(user))
		var/mob/living/simple_animal/hostile/guardian/G = user
		if(G.summoner?.current)
			immune |= G.summoner.current
			for(var/mob/living/simple_animal/hostile/guardian/GG in G.summoner.current.hasparasites())
				immune |= GG
	for(var/mob/living/L in immune)
		SEND_SOUND(L, sound('sound/effects/kingcrimson_start.ogg'))
		var/image/I = image(icon = 'icons/effects/blood.dmi', icon_state = null, loc = L)
		I.override = TRUE
		if(isturf(L.loc))
			var/mob/living/simple_animal/hostile/illusion/doppelganger/E = new(L.loc)
			E.setDir(L.dir)
			E.Copy_Parent(L, INFINITY, 100)
			E.target = null
			fakes += E
		L.status_flags |= GODMODE
		L.opacity = FALSE
		L.mouse_opacity = FALSE
		L.density = FALSE
		L.alpha = 128
		if(L.pulledby)
			L.pulledby.stop_pulling()
		if(isguardian(L))
			var/mob/living/simple_animal/hostile/guardian/G = L
			G.erased_time = TRUE
		ADD_TRAIT(L, TRAIT_PACIFISM, "king_crimson")
		L.remove_alt_appearance("king_crimson")
		L.add_alt_appearance(/datum/atom_hud/alternate_appearance/basic/king_crimson, "king_crimson", I, NONE, immune)
	sleep(length)
	if(LAZYLEN(fakes))
		var/mob/living/simple_animal/hostile/illusion/doppelganger/DP = pick(fakes)
		playsound(DP.loc, 'sound/effects/kingcrimson_end.ogg', 100)
	for(var/mob/living/simple_animal/hostile/illusion/doppelganger/DG in fakes)
		DG.death()
	for(var/mob/living/L in immune)
		SEND_SOUND(L, sound('sound/effects/kingcrimson_end.ogg'))
		if(isguardian(L))
			var/mob/living/simple_animal/hostile/guardian/G = L
			G.erased_time = FALSE
		L.status_flags &= ~GODMODE
		L.opacity = initial(L.opacity)
		L.mouse_opacity = initial(L.mouse_opacity)
		L.density = initial(L.density)
		L.alpha = initial(L.alpha)
		L.remove_alt_appearance("king_crimson")
		REMOVE_TRAIT(L, TRAIT_PACIFISM, "king_crimson")

/datum/atom_hud/alternate_appearance/basic/king_crimson
	var/list/seers

/datum/atom_hud/alternate_appearance/basic/king_crimson/New(key, image/I, options, list/seers)
	..()
	src.seers = seers
	for(var/mob/M in GLOB.mob_list)
		if(mobShouldSee(M))
			add_hud_to(M)
			M.reload_huds()

/datum/atom_hud/alternate_appearance/basic/king_crimson/mobShouldSee(mob/M)
	if(isobserver(M) || (M in seers))
		return FALSE // they see the actual sprite
	return TRUE

/mob/living/simple_animal/hostile/illusion/doppelganger
	melee_damage = 0
	speed = -1
	obj_damage = 0
	vision_range = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
