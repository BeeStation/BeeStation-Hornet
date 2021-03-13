#define MORPH_COOLDOWN 50

/mob/living/simple_animal/hostile/morph
	name = "morph"
	real_name = "morph"
	desc = "A revolting, pulsating pile of flesh."
	speak_emote = list("gurgles")
	emote_hear = list("gurgles")
	icon = 'icons/mob/animal.dmi'
	icon_state = "morph"
	icon_living = "morph"
	icon_dead = "morph_dead"
	speed = 2
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	pass_flags = PASSTABLE
	ventcrawler = VENTCRAWLER_ALWAYS
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxHealth = 150
	health = 150
	healable = 0
	obj_damage = 50
	melee_damage = 20
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attacktext = "glomps"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/slab = 2)

	var/morphed = FALSE
	var/melee_damage_disguised = 5
	var/eat_while_disguised = FALSE
	var/atom/movable/form = null
	var/morph_time = 0
	var/static/list/blacklist_typecache = typecacheof(list(
	/atom/movable/screen,
	/obj/singularity,
	/mob/living/simple_animal/hostile/morph,
	/obj/effect,
	/mob/camera
	))
	var/atom/movable/throwatom = null

	var/playstyle_string = "<span class='big bold'>You are a morph,</span></b> an abomination of science created primarily with changeling cells. \
							You may take the form of anything nearby by shift-clicking it. This process will alert any nearby \
							observers, and can only be performed once every five seconds. While morphed, you move faster, but do \
							less damage. In addition, anyone within three tiles will note an uncanny wrongness if examining you. \
							You can attack any item or dead creature to consume it - creatures will restore your health. \
							Finally, you can restore yourself to your original form while morphed by shift-clicking yourself.</b>"

	mobchatspan = "blob"

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	var/datum/action/innate/morph/stomach/S = new
	S.Grant(src)
	. = ..()

/datum/action/innate/morph/stomach
	name = "Stomach Contents"
	button_icon_state = "morph"

/datum/action/innate/morph/stomach/Activate()
	var/mob/living/simple_animal/hostile/morph/M = owner
	M.manipulate(M)

/mob/living/simple_animal/hostile/morph/proc/manipulate(var/mob/living/simple_animal/hostile/morph/M)
	var/list/choices = list()
	var/list/mobfunctions = list("Drop", "Digest", "Disguise as", "Throw", "Strip")
	var/list/itemfunctions = list("Use", "Throw", "Drop", "Use and Throw", "Digest", "Disguise as")
	for(var/atom/movable/A in contents)
		choices += A
	var/atom/movable/target = input(src,"What do you wish to use") in null|choices
	if(isliving(target))
		var/mob/living/L = target
		var/action = input(src,"What do you wish to do with [L]") in null|mobfunctions
		switch(action)
			if("Drop")
				if(throwatom == L)
					throwatom = null
				L.forceMove(loc)
				visible_message("<span class='warning'>[src] spits [L] out!</span>")
				playsound(src, 'sound/effects/splat.ogg', 50, 1)
			if("Digest")
				if(throwatom == L)
					throwatom = null
				to_chat(src, "<span class ='danger'> You begin digesting [L]</span>")
				if(do_mob(src, src, L.maxHealth))
					for(var/atom/movable/AM in L.contents)
						src.contents += AM
					L.dust()
					adjustHealth(-(L.maxHealth / 2))
					to_chat(src, "<span class ='danger'> You digest [L], restoring some health</span>")
					playsound(src, 'sound/effects/splat.ogg', 50, 1)
			if("Disguise as")
				ShiftClickOn(L)
			if("Throw")
				if(throwatom)
					to_chat(src, "<span class ='danger'> You are already preparing to throw [throwatom]</span>")
				else
					throwatom = L
					to_chat(src, "<span class ='danger'> You prepare to throw [L]</span>")
			if("Strip")
				to_chat(src, "<span class ='danger'> You start removing [L]'s possessions</span>")
				if(do_mob(src, L, 30))
					for(var/atom/movable/AM in L.contents)
						src.contents += AM
					to_chat(src, "<span class ='danger'> You place [L]'s possessions into your stomach</span>")
	else if(isitem(target))
		var/obj/item/I = target
		var/action = input(src,"What do you wish to do with [I]") in null|itemfunctions
		switch(action)
			if("Drop")
				if(throwatom == I)
					throwatom = null
				I.forceMove(loc)
				visible_message("<span class='warning'>[src] spits [I] out!</span>")
				playsound(src, 'sound/effects/splat.ogg', 50, 1)
			if("Disguise as")
				ShiftClickOn(I)
			if("Throw")
				if(throwatom)
					to_chat(src, "<span class ='danger'> You are already preparing to throw [throwatom]</span>")
				else
					throwatom = I
					to_chat(src, "<span class ='danger'> You prepare to throw [I]</span>")
			if("Use")
				I.attack_self(src)
			if("Use and Throw")
				if(throwatom)
					to_chat(src, "<span class ='danger'> You are already preparing to throw [throwatom]</span>")
				else
					throwatom = I
					to_chat(src, "<span class ='danger'> You prepare to throw [I]</span>")
					I.attack_self(src)
			if("Digest")
				if(throwatom == I)
					throwatom = null
				if((I.resistance_flags & UNACIDABLE) || (I.resistance_flags & ACID_PROOF) || (I.resistance_flags & INDESTRUCTIBLE))
					to_chat(src, "<span class ='danger'>[I] cannot be digested.</span>")
				else
					playsound(src, 'sound/items/welder.ogg', 150, 1)
					qdel(I)
					to_chat(src, "<span class ='danger'>You digest [I].</span>")


/mob/living/simple_animal/hostile/morph/ClickOn(atom/A)
	if(throwatom)
		throwatom.forceMove(loc)
		throwatom.safe_throw_at(A, throwatom.throw_range, throwatom.throw_speed, src, null, null, null, move_force)
		visible_message("<span class='warning'>[src] spits [throwatom] at [A]!</span>")
		throwatom = null
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
	. = ..()


/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = form.examine(user)
		if(get_dist(user,src)<=3)
			. += "<span class='warning'>It doesn't look quite right...</span>"
	else
		. = ..()

/mob/living/simple_animal/hostile/morph/med_hud_set_health()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/med_hud_set_status()
	if(morphed && !isliving(form))
		var/image/holder = hud_list[STATUS_HUD]
		holder.icon_state = null
		return //we hide medical hud while morphed
	..()

/mob/living/simple_animal/hostile/morph/proc/allowed(atom/movable/A) // make it into property/proc ? not sure if worth it
	return !is_type_in_typecache(A, blacklist_typecache) && (isobj(A) || ismob(A))

/mob/living/simple_animal/hostile/morph/proc/eat(atom/movable/A)
	if(morphed && !eat_while_disguised)
		to_chat(src, "<span class='warning'>You can not eat anything while you are disguised!</span>")
		return FALSE
	if(A && A.loc != src)
		visible_message("<span class='warning'>[src] swallows [A] whole!</span>")
		A.forceMove(src)
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(morph_time <= world.time && !stat)
		if(A == src)
			restore()
			return
		if(allowed(A))
			assume(A)
	else
		to_chat(src, "<span class='warning'>Your chameleon skin is still repairing itself!</span>")
		..()

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	if(morphed)
		to_chat(src, "<span class='warning'>You must restore to your original form first!</span>")
		return
	morphed = TRUE
	form = target

	visible_message("<span class='warning'>[src] suddenly twists and changes shape, becoming a copy of [target]!</span>", \
					"<span class='notice'>You twist your body and assume the form of [target].</span>")
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)	//fucking chameleons
	transform = initial(transform)
	pixel_y = initial(pixel_y)
	pixel_x = initial(pixel_x)
	density = target.density

	if(isliving(target))
		var/mob/living/L = target
		mobchatspan = L.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	//Morphed is weaker
	melee_damage = melee_damage_disguised
	set_varspeed(0)

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we're an object honest
	return

/mob/living/simple_animal/hostile/morph/proc/restore()
	if(!morphed)
		to_chat(src, "<span class='warning'>You're already in your normal form!</span>")
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)

	visible_message("<span class='warning'>[src] suddenly collapses in on itself, dissolving into a pile of green flesh!</span>", \
					"<span class='notice'>You reform to your normal body.</span>")
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline stats
	melee_damage = initial(melee_damage)
	set_varspeed(initial(speed))

	morph_time = world.time + MORPH_COOLDOWN
	med_hud_set_health()
	med_hud_set_status() //we are not an object

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message("<span class='warning'>[src] twists and dissolves into a pile of green flesh!</span>", \
						"<span class='userdanger'>Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--</span>")
		restore()
	barf_contents()
	..()

/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		AM.forceMove(loc)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))

/mob/living/simple_animal/hostile/morph/wabbajack_act(mob/living/new_mob)
	barf_contents()
	. = ..()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(var/list/possible_targets)
	. = ..()
	if(.)
		var/list/things = list()
		for(var/atom/A as() in view(src))
			if(allowed(A))
				things += A
		var/atom/movable/T = pick(things)
		assume(T)

/mob/living/simple_animal/hostile/morph/can_track(mob/living/user)
	if(morphed)
		return FALSE
	return ..()

/mob/living/simple_animal/hostile/morph/AttackingTarget()
	if(morphed && !melee_damage_disguised)
		to_chat(src, "<span class='warning'>You can not attack while disguised!</span>")
		return
	if(isliving(target)) //Eat living beings to store them for a snack, or other uses
		var/mob/living/L = target
		if(L.stat)
			if(L.stat == DEAD)
				eat(L)
			else if(do_after(src, 30, target = L)) //Don't Return after this, it's important that the morph can attack softcrit targets to bring them into hardcrit
				eat(L)
	else if(isitem(target)) //Eat items for later use
		var/obj/item/I = target
		if(!I.anchored)
			eat(I)
			return
	return ..()

//Spawn Event

/datum/round_event_control/morph
	name = "Spawn Morph"
	typepath = /datum/round_event/ghost_role/morph
	weight = 2
	max_occurrences = 1

/datum/round_event/ghost_role/morph
	minimum_required = 1
	role_name = "morphling"

/datum/round_event/ghost_role/morph/spawn_role()
	var/list/candidates = get_candidates(ROLE_ALIEN, null, ROLE_ALIEN)
	if(!candidates.len)
		return NOT_ENOUGH_PLAYERS

	var/mob/dead/selected = pick_n_take(candidates)

	var/datum/mind/player_mind = new /datum/mind(selected.key)
	player_mind.active = 1
	if(!GLOB.xeno_spawn)
		return MAP_ERROR
	var/mob/living/simple_animal/hostile/morph/S = new /mob/living/simple_animal/hostile/morph(pick(GLOB.xeno_spawn))
	player_mind.transfer_to(S)
	player_mind.assigned_role = "Morph"
	player_mind.special_role = "Morph"
	player_mind.add_antag_datum(/datum/antagonist/morph)
	to_chat(S, S.playstyle_string)
	SEND_SOUND(S, sound('sound/magic/mutate.ogg'))
	message_admins("[ADMIN_LOOKUPFLW(S)] has been made into a morph by an event.")
	log_game("[key_name(S)] was spawned as a morph by an event.")
	spawned_mobs += S
	return SUCCESSFUL_SPAWN
