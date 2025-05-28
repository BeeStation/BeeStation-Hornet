GLOBAL_VAR_INIT(floor_cluwnes, 0)


#define STAGE_HAUNT 1
#define STAGE_SPOOK 2
#define STAGE_TORMENT 3
#define STAGE_ATTACK 4
#define MANIFEST_DELAY 9

/// How long we put the target so sleep for (during sacrifice).
#define SACRIFICE_SLEEP_DURATION 12 SECONDS
/// How long sacrifices must stay in the shadow realm to survive.
#define SACRIFICE_REALM_DURATION 2.5 MINUTES

/mob/living/simple_animal/hostile/floor_cluwne
	name = "???"
	desc = "...."
	icon = 'icons/obj/clothing/masks.dmi'
	icon_state = "cluwne"
	icon_living = "cluwne"
	icon_gib = "clown_gib"
	maxHealth = 250
	health = 250
	speed = -1
	attack_sound = 'sound/items/bikehorn.ogg'
	del_on_death = TRUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB | LETPASSTHROW | PASSTRANSPARENT | PASSBLOB//it's practically a ghost when unmanifested (under the floor)
	loot = list(/obj/item/clothing/mask/cluwne)
	wander = FALSE
	minimum_distance = 2
	move_to_delay = 1
	environment_smash = FALSE
	lose_patience_timeout = FALSE
	pixel_y = 8
	pressure_resistance = 200
	minbodytemp = 0
	maxbodytemp = 1500
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	var/mob/living/carbon/human/current_victim
	var/manifested = FALSE
	var/switch_stage = 60
	var/stage = STAGE_HAUNT
	var/delete_after_target_killed = FALSE
	var/interest = 0
	var/target_area
	var/invalid_area_typecache = list(/area/space, /area/lavaland, /area/centcom, /area/shuttle/syndicate)
	var/eating = FALSE
	var/dontkill = FALSE //for if we just wanna curse a fucker
	var/terrorize = FALSE //for Heretic curse, rather than kill
	var/terror_count = 0
	var/return_timers
	var/obj/effect/dummy/floorcluwne_orbit/poi
	var/obj/effect/temp_visual/fcluwne_manifest/cluwnehole
	move_resist = INFINITY
	hud_type = /datum/hud/ghost
	hud_possible = list(ANTAG_HUD)
	mobchatspan = "rainbow"

/mob/living/simple_animal/hostile/floor_cluwne/Initialize(mapload)
	. = ..()
	access_card = new /obj/item/card/id(src)
	access_card.access = get_all_accesses() //THERE IS NO ESCAPE
	ADD_TRAIT(access_card, TRAIT_NODROP, ABSTRACT_ITEM_TRAIT)
	invalid_area_typecache = typecacheof(invalid_area_typecache)
	Manifest()
	if(!current_victim)
		Acquire_Victim()
	poi = new(src)

/mob/living/simple_animal/hostile/floor_cluwne/med_hud_set_health()
	return //we use a different hud

/mob/living/simple_animal/hostile/floor_cluwne/med_hud_set_status()
	return //we use a different hud

/mob/living/simple_animal/hostile/floor_cluwne/Destroy()
	QDEL_NULL(poi)
	return ..()


/mob/living/simple_animal/hostile/floor_cluwne/attack_hand(mob/living/carbon/human/M)
	..()
	playsound(src.loc, 'sound/items/bikehorn.ogg', 50, 1)


/mob/living/simple_animal/hostile/floor_cluwne/CanAllowThrough(atom/movable/mover, turf/target)
	. = ..()
	return TRUE


/mob/living/simple_animal/hostile/floor_cluwne/Life()
	do_jitter_animation(1000)
	pixel_y = 8

	var/area/A = get_area(src.loc)
	if(is_type_in_typecache(A, invalid_area_typecache) || !is_station_level(z))
		var/area = pick(GLOB.teleportlocs)
		var/area/tp = GLOB.teleportlocs[area]
		forceMove(pick(get_area_turfs(tp.type)))

	if(!current_victim)
		Acquire_Victim()

	if(stage && !manifested)
		On_Stage()

	if(stage == STAGE_ATTACK)
		playsound(src, 'sound/misc/cluwne_breathing.ogg', 75, 1)

	if(eating)
		return

	var/turf/T = get_turf(current_victim)
	A = get_area(T)
	if(prob(5))//checks roughly every 20 ticks
		if(current_victim.stat == DEAD || current_victim.dna.check_mutation(/datum/mutation/cluwne) || is_type_in_typecache(A, invalid_area_typecache) || !is_station_level(current_victim.z))
			if(!Found_You())
				Acquire_Victim()

	if(get_dist(src, current_victim) > 9 && !manifested &&  !is_type_in_typecache(A, invalid_area_typecache))//if cluwne gets stuck he just teleports
		do_teleport(src, T)

	interest++
	if(interest >= switch_stage * 4 && !dontkill)
		stage = STAGE_ATTACK

	else if(interest >= switch_stage * 2)
		stage = STAGE_TORMENT

	else if(interest >= switch_stage)
		stage = STAGE_SPOOK

	else if(interest < switch_stage)
		stage = STAGE_HAUNT

	..()

/mob/living/simple_animal/hostile/floor_cluwne/Goto(target, delay, minimum_distance)
	var/area/A = get_area(current_victim.loc)
	if(!manifested && !is_type_in_typecache(A, invalid_area_typecache) && is_station_level(current_victim.z))
		SSmove_manager.move_to(src, target, minimum_distance, delay)
	else
		SSmove_manager.stop_looping(src)


/mob/living/simple_animal/hostile/floor_cluwne/FindTarget()
	return current_victim


/mob/living/simple_animal/hostile/floor_cluwne/CanAttack(atom/the_target)//you will not escape
	return TRUE


/mob/living/simple_animal/hostile/floor_cluwne/AttackingTarget()
	return


/mob/living/simple_animal/hostile/floor_cluwne/LoseTarget()
	return


/mob/living/simple_animal/hostile/floor_cluwne/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)//prevents runtimes with machine fuckery
	return FALSE

/mob/living/simple_animal/hostile/floor_cluwne/proc/Found_You()
	for(var/obj/structure/closet/hiding_spot in orange(7,src))
		if(current_victim.loc == hiding_spot)
			hiding_spot.bust_open()
			current_victim.Paralyze(40)
			to_chat(current_victim, span_warning("...edih t'nac uoY"))
			return TRUE
	return FALSE

/mob/living/simple_animal/hostile/floor_cluwne/get_photo_description(obj/item/camera/camera)
	return "You can also see an indescribable horror!"

/mob/living/simple_animal/hostile/floor_cluwne/proc/Acquire_Victim(specific)
	for(var/I in GLOB.player_list)//better than a potential recursive loop
		var/mob/living/carbon/human/H = pick(GLOB.player_list)//so the check is fair
		var/area/A

		if(specific)
			H = specific
			A = get_area(H.loc)
			if(H.stat != DEAD && H.has_dna() && !H.dna.check_mutation(/datum/mutation/cluwne) && !is_type_in_typecache(A, invalid_area_typecache) && is_station_level(H.z))
				return target = current_victim

		A = get_area(H.loc)
		if(H && ishuman(H) && H.stat != DEAD && H != current_victim && H.has_dna() && !H.dna.check_mutation(/datum/mutation/cluwne) && !is_type_in_typecache(A, invalid_area_typecache) && is_station_level(H.z))
			current_victim = H
			interest = 0
			stage = STAGE_HAUNT
			return target = current_victim
	if(!terrorize)
		message_admins("Floor Cluwne was deleted due to a lack of valid targets, if this was a manually targeted instance please re-evaluate your choice.")
		qdel(src)


/mob/living/simple_animal/hostile/floor_cluwne/proc/Manifest()//handles disappearing and appearance anim
	if(manifested)
		mobility_flags &= ~MOBILITY_MOVE
		cluwnehole = new(src.loc)
		addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal/hostile/floor_cluwne, Appear)), MANIFEST_DELAY)
	else
		invisibility = INVISIBILITY_SPIRIT
		density = FALSE
		mobility_flags |= MOBILITY_MOVE
		if(cluwnehole)
			qdel(cluwnehole)


/mob/living/simple_animal/hostile/floor_cluwne/proc/Appear()//handled in a separate proc so floor cluwne doesn't appear before the animation finishes
	invisibility = FALSE
	density = TRUE

/mob/living/simple_animal/hostile/floor_cluwne/proc/Reset_View(screens, colour, mob/living/carbon/human/H)
	if(screens)
		for(var/whole_screen in screens)
			animate(whole_screen, transform = matrix(), time = 5, easing = QUAD_EASING)
	if(colour && H)
		H.client.color = colour


/mob/living/simple_animal/hostile/floor_cluwne/proc/On_Stage()
	var/mob/living/carbon/human/H = current_victim
	switch(stage)

		if(STAGE_HAUNT)

			if(prob(5))
				H.blur_eyes(1)

			if(prob(5))
				H.playsound_local(src,'sound/voice/cluwnelaugh2_reversed.ogg', 1)

			if(prob(5))
				H.playsound_local(src,'sound/misc/bikehorn_creepy.ogg', 5)

			if(prob(3))
				var/obj/item/I = locate() in orange(8, H)
				if(I && !I.anchored)
					I.throw_at(H, 4, 3)
					to_chat(H, span_warning("What threw that?"))

		if(STAGE_SPOOK)

			if(prob(4))
				var/turf/T = get_turf(H)
				T.handle_slip(H, 20)
				to_chat(H, span_warning("The floor shifts underneath you!"))

			if(prob(5))
				H.playsound_local(src,'sound/voice/cluwnelaugh2.ogg', 2)

			if(prob(5))
				H.playsound_local(src,'sound/voice/cluwnelaugh2_reversed.ogg', 2)

			if(prob(5))
				H.playsound_local(src,'sound/misc/bikehorn_creepy.ogg', 10)
				to_chat(H, "<i>knoh</i>")

			if(prob(5))
				var/obj/item/I = locate() in orange(8, H)
				if(I && !I.anchored)
					I.throw_at(H, 4, 3)
					to_chat(H, span_warning("What threw that?"))

			if(prob(2))
				to_chat(H, "<i>yalp ot tnaw I</i>")
				Appear()
				manifested = FALSE
				addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal/hostile/floor_cluwne, Manifest)), 1)

		if(STAGE_TORMENT)

			if(prob(5))
				var/turf/T = get_turf(H)
				T.handle_slip(H, 20)
				to_chat(H, span_warning("The floor shifts underneath you!"))

			if(prob(3))
				playsound(src,pick('sound/spookoween/scary_horn.ogg', 'sound/spookoween/scary_horn2.ogg', 'sound/spookoween/scary_horn3.ogg'), 30, 1)

			if(prob(3))
				playsound(src,'sound/voice/cluwnelaugh1.ogg', 30, 1)

			if(prob(3))
				playsound(src,'sound/voice/cluwnelaugh2_reversed.ogg', 30, 1)

			if(prob(5))
				playsound(src,'sound/misc/bikehorn_creepy.ogg', 30, 1)

			if(prob(4))
				for(var/obj/item/I in orange(8, H))
					if(!I.anchored)
						I.throw_at(H, 4, 3)
				to_chat(H, span_warning("What the hell?!"))

			if(prob(2))
				to_chat(H, span_warning("Something feels very wrong..."))
				H.playsound_local(src,'sound/hallucinations/behind_you1.ogg', 25)
				H.flash_act()

			if(prob(2))
				to_chat(H, "<i>!?REHTOMKNOH eht esiarp uoy oD</i>")
				to_chat(H, span_warning("Something grabs your foot!"))
				H.playsound_local(src,'sound/hallucinations/i_see_you1.ogg', 25)
				H.Stun(20)

			if(prob(3))
				to_chat(H, "<i>KNOH ?od nottub siht seod tahW</i>")
				for(var/turf/open/O in RANGE_TURFS(6, src))
					O.MakeSlippery(TURF_WET_WATER, 10)
					playsound(src, 'sound/effects/meteorimpact.ogg', 30, 1)

			if(prob(1))
				to_chat(H, span_userdanger("WHAT THE FUCK IS THAT?!"))
				to_chat(H, "<i>.KNOH !nuf hcum os si uoy htiw gniyalP .KNOH KNOH KNOH</i>")
				H.playsound_local(src,'sound/hallucinations/im_here1.ogg', 25)
				H.reagents.add_reagent("mindbreaker", 3)
				H.reagents.add_reagent("laughter", 5)
				H.reagents.add_reagent("mercury", 3)
				Appear()
				manifested = FALSE
				addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal/hostile/floor_cluwne, Manifest)), 2)
				for(var/obj/machinery/light/L in range(8, H))
					L.flicker()

		if(STAGE_ATTACK)
			if(dontkill)
				stage = STAGE_TORMENT
				return
			if(!eating)
				Found_You()
				for(var/I in getline(src,H))
					var/turf/T = I
					if(T.density)
						forceMove(H.loc)
					for(var/obj/structure/O in T)
						if(O.density || istype(O, /obj/machinery/door/airlock))
							forceMove(H.loc)
				to_chat(H, span_userdanger("You feel the floor closing in on your feet!"))
				H.Paralyze(300)
				INVOKE_ASYNC(H, TYPE_PROC_REF(/mob, emote), "scream")
				H.adjustBruteLoss(10)
				manifested = TRUE
				Manifest()
				if(!eating)
					addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal/hostile/floor_cluwne, Grab), H), 50, TIMER_OVERRIDE|TIMER_UNIQUE)
					for(var/turf/open/O in RANGE_TURFS(6, src))
						O.MakeSlippery(TURF_WET_LUBE, 20)
						playsound(src, 'sound/effects/meteorimpact.ogg', 30, 1)
				eating = TRUE


/mob/living/simple_animal/hostile/floor_cluwne/proc/Grab(mob/living/carbon/human/H)
	to_chat(H, span_userdanger("You feel a cold, gloved hand clamp down on your ankle!"))
	for(var/I in 1 to get_dist(src, H))
		if(do_after(src, 5, target = H))
			step_towards(H, src)
			playsound(H, pick('sound/effects/bodyscrape-01.ogg', 'sound/effects/bodyscrape-02.ogg'), 20, 1, -4)
			if(prob(40))
				H.emote("scream")
			else if(prob(25))
				H.say(pick("HELP ME!!","IT'S GOT ME!!","DON'T LET IT TAKE ME!!",";SOMETHING'S KILLING ME!!","HOLY FUCK!!"))
				playsound(src, pick('sound/voice/cluwnelaugh1.ogg', 'sound/voice/cluwnelaugh2.ogg', 'sound/voice/cluwnelaugh3.ogg'), 50, 1)

	if(get_dist(src,H) <= 1)
		visible_message(span_danger("[src] begins dragging [H] under the floor!"))
		if(do_after(src, 50, target = H) && eating)
			H.become_blind()
			H.invisibility = INVISIBILITY_SPIRIT
			H.set_density(FALSE)
			H.set_anchored(TRUE)
			addtimer(CALLBACK(src, TYPE_PROC_REF(/mob/living/simple_animal/hostile/floor_cluwne, Kill), H), 100, TIMER_OVERRIDE|TIMER_UNIQUE)
			visible_message(span_danger("[src] pulls [H] under!"))
			to_chat(H, span_userdanger("[src] drags you underneath the floor!"))
		else
			eating = FALSE
	else
		eating = FALSE
	manifested = FALSE
	Manifest()


/mob/living/simple_animal/hostile/floor_cluwne/proc/Kill(mob/living/carbon/human/H)
	if(!istype(H) || !H.client)
		Acquire_Victim()
		return
	playsound(H, 'sound/effects/cluwne_feast.ogg', 100, 0, -4)
	var/old_color = H.client.color
	var/red_splash = list(1,0,0,0.8,0.2,0, 0.8,0,0.2,0.1,0,0)
	var/pure_red = list(0,0,0,0,0,0,0,0,0,1,0,0)
	H.client.color = pure_red
	animate(H.client,color = red_splash, time = 10, easing = SINE_EASING|EASE_OUT)
	for(var/turf/open/T in RANGE_TURFS(4, H))
		H.add_splatter_floor(T)
	if(do_after(src, 50, target = H))
		if(terrorize)
			begin_trauma(H)
		else if(prob(75))
			H.unequip_everything() //runtime prevention
			H.gib(FALSE)
		else
			H.unequip_everything() //runtime prevention
			H.cluwneify()
			H.adjustBruteLoss(30)
			H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 100)
			H.cure_blind(null)
			H.invisibility = initial(H.invisibility)
			H.set_density(initial(H.density))
			H.set_anchored(initial(H.anchored))
			H.blur_eyes(10)
			animate(H.client,color = old_color, time = 20)

	eating = FALSE
	switch_stage = switch_stage * 0.75 //he gets faster after each feast
	for(var/mob/M in GLOB.player_list)
		M.playsound_local(get_turf(M), 'sound/misc/honk_echo_distant.ogg', 50, 1, pressure_affected = FALSE)

	if(delete_after_target_killed)
		qdel(src)

	interest = 0
	stage = STAGE_HAUNT
	Acquire_Victim()

/mob/living/simple_animal/hostile/floor_cluwne/proc/force_target(var/mob/living/H)
	if(!istype(H) || !H.client)		return  // if theyre not human or they're afk
	current_victim = H
	target = H
	loc = H.loc // so it doesnt choose another victim

//manifestation animation
/obj/effect/temp_visual/fcluwne_manifest
	icon = 'icons/turf/floors.dmi'
	icon_state = "fcluwne_open"
	layer = TURF_LAYER
	duration = 600
	randomdir = FALSE

/obj/effect/temp_visual/fcluwne_manifest/Initialize(mapload)
	. = ..()
	playsound(src, 'sound/misc/floor_cluwne_emerge.ogg', 100, 1)
	flick("fcluwne_manifest",src)

/obj/effect/dummy/floorcluwne_orbit
	name = "floor cluwne"
	desc = "If you have this, tell a coder or admin!"

/obj/effect/dummy/floorcluwne_orbit/Initialize(mapload)
	. = ..()
	GLOB.floor_cluwnes++
	name += " ([GLOB.floor_cluwnes])"
	AddElement(/datum/element/point_of_interest)

/mob/living/simple_animal/hostile/floor_cluwne/proc/begin_trauma(mob/living/carbon/human/sac_target)
	if(!LAZYLEN(GLOB.heretic_sacrifice_landmarks))
		CRASH("[type] - begin_trauma was called, but no floorcluwne_trauma landmarks were found!")

	var/obj/effect/landmark/heretic/destination_landmark = GLOB.heretic_sacrifice_landmarks[HERETIC_PATH_ASH]
	if(!destination_landmark)
		CRASH("[type] - begin_trauma could not find a destination landmark to send the target!")

	var/turf/destination = get_turf(destination_landmark)

	sac_target.handcuffed = new /obj/item/restraints/handcuffs/energy/cult(sac_target)
	sac_target.update_handcuffed()
	sac_target.do_jitter_animation(100)

	if(sac_target.legcuffed)
		sac_target.legcuffed.forceMove(sac_target.drop_location())
		sac_target.legcuffed.dropped(sac_target)
		sac_target.legcuffed = null
		sac_target.update_inv_legcuffed()

	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 100), SACRIFICE_SLEEP_DURATION * (1/3))
	addtimer(CALLBACK(sac_target, TYPE_PROC_REF(/mob/living/carbon, do_jitter_animation), 100), SACRIFICE_SLEEP_DURATION * (2/3))

	// Grab their ghost, just in case they're dead or something.
	sac_target.grab_ghost()
	// If our target is dead, try to revive them
	// and if we fail to revive them, don't proceede the chain
	if(!sac_target.heal_and_revive(50, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		return

	if(sac_target.AdjustUnconscious(SACRIFICE_SLEEP_DURATION))
		to_chat(sac_target, span_hypnophrase("Your mind feels torn apart as you fall into a shallow slumber..."))
	else
		to_chat(sac_target, span_hypnophrase("Your mind begins to tear apart as you watch dark tendrils envelop you."))

	sac_target.AdjustParalyzed(SACRIFICE_SLEEP_DURATION * 1.2)
	sac_target.AdjustImmobilized(SACRIFICE_SLEEP_DURATION * 1.2)

	addtimer(CALLBACK(src, PROC_REF(after_target_sleeps), sac_target, destination), SACRIFICE_SLEEP_DURATION * 0.5) // Teleport to the minigame

	return TRUE

/mob/living/simple_animal/hostile/floor_cluwne/proc/after_target_sleeps(mob/living/carbon/human/sac_target, turf/destination)
	if(QDELETED(sac_target))
		return

	// Grab ghost again, just to be safe.
	sac_target.grab_ghost()
	// The target disconnected or something, we shouldn't bother sending them along.
	if(!sac_target.client || !sac_target.mind)
		return

	// Send 'em to the destination. If the teleport fails, do nothing.
	if(!destination || !do_teleport(sac_target, destination, asoundin = 'sound/magic/repulse.ogg', asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC, bypass_area_restriction = TRUE, no_wake = TRUE))
		return

	// If our target died during the (short) wait timer,
	// and we fail to revive them (using a lower number than before), do nothing.
	if(!sac_target.heal_and_revive(75, span_danger("[sac_target]'s heart begins to beat with an unholy force as they return from death!")))
		return

	sac_target.cure_blind(null)
	sac_target.invisibility = initial(sac_target.invisibility)
	sac_target.set_density(initial(sac_target.density))
	sac_target.set_anchored(initial(sac_target.anchored))
	to_chat(sac_target, span_big("[span_hypnophrase("Unnatural forces begin to claw at your very being from beyond the veil.")]"))

	sac_target.apply_status_effect(/datum/status_effect/unholy_determination, SACRIFICE_REALM_DURATION)
	addtimer(CALLBACK(src, PROC_REF(after_target_wakes), sac_target), SACRIFICE_SLEEP_DURATION * 0.5) // Begin the minigame

/mob/living/simple_animal/hostile/floor_cluwne/proc/after_target_wakes(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	// About how long should the helgrasp last? (1 metab a tick = helgrasp_time / 2 ticks (so, 1 minute = 60 seconds = 30 ticks))
	var/helgrasp_time = 1 MINUTES

	sac_target.reagents?.add_reagent(/datum/reagent/helgrasp/heretic, helgrasp_time / 20)
	sac_target.apply_necropolis_curse(CURSE_BLINDING | CURSE_GRASPING)

	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm", /datum/mood_event/shadow_realm)

	sac_target.flash_act()
	sac_target.blur_eyes(15)
	sac_target.Jitter(10)
	sac_target.Dizzy(10)
	sac_target.hallucination += 12
	sac_target.emote("scream")

	to_chat(sac_target, span_reallybig("[span_hypnophrase("The grasping hands reveal themselves to you!")]"))
	to_chat(sac_target, span_hypnophrase("You feel invigorated! Fight to survive!"))
	// When it runs out, let them know they're almost home free
	addtimer(CALLBACK(src, PROC_REF(after_helgrasp_ends), sac_target), helgrasp_time)
	// Win condition
	var/win_timer = addtimer(CALLBACK(src, PROC_REF(return_target), sac_target), SACRIFICE_REALM_DURATION, TIMER_STOPPABLE)
	LAZYSET(return_timers, REF(sac_target), win_timer)

/**
 * This proc is called from [proc/after_target_wakes] after the helgrasp runs out in the [sac_target].
 *
 * It gives them a message letting them know it's getting easier and they're almost free.
 */
/mob/living/simple_animal/hostile/floor_cluwne/proc/after_helgrasp_ends(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target) || sac_target.stat == DEAD)
		return

	to_chat(sac_target, span_hypnophrase("The worst is behind you... Not much longer! Hold fast, or expire!"))

/mob/living/simple_animal/hostile/floor_cluwne/proc/return_target(mob/living/carbon/human/sac_target)
	if(QDELETED(sac_target))
		return

	var/current_timer = LAZYACCESS(return_timers, REF(sac_target))
	if(current_timer)
		deltimer(current_timer)
	LAZYREMOVE(return_timers, REF(sac_target))

	UnregisterSignal(sac_target, COMSIG_MOVABLE_Z_CHANGED)
	UnregisterSignal(sac_target, COMSIG_MOB_DEATH)
	sac_target.remove_status_effect(/datum/status_effect/necropolis_curse)
	sac_target.remove_status_effect(/datum/status_effect/unholy_determination)
	sac_target.reagents?.del_reagent(/datum/reagent/helgrasp/heretic)
	SEND_SIGNAL(sac_target, COMSIG_CLEAR_MOOD_EVENT, "shadow_realm")

	// Wherever we end up, we sure as hell won't be able to explain
	sac_target.slurring += 20
	sac_target.cultslurring += 20
	sac_target.stuttering += 20

	// They're already back on the station for some reason, don't bother teleporting
	if(is_station_level(sac_target.z))
		return

	// Teleport them to a random safe coordinate on the station z level.
	var/turf/open/floor/safe_turf = find_safe_turf(extended_safety_checks = TRUE)
	var/obj/effect/landmark/observer_start/backup_loc = locate(/obj/effect/landmark/observer_start) in GLOB.landmarks_list
	if(!safe_turf)
		safe_turf = get_turf(backup_loc)
		stack_trace("[type] - return_target was unable to find a safe turf for [sac_target] to return to. Defaulting to observer start turf.")

	if(!do_teleport(sac_target, safe_turf, asoundout = 'sound/magic/blind.ogg', no_effects = TRUE, channel = TELEPORT_CHANNEL_FREE, bypass_area_restriction = TRUE, no_wake = TRUE))
		safe_turf = get_turf(backup_loc)
		sac_target.forceMove(safe_turf)
		stack_trace("[type] - return_target was unable to teleport [sac_target] to the observer start turf. Forcemoving.")

	after_return_live_target(sac_target)


/**
 * This proc is called from [proc/return_target] if the [sac_target] survives the shadow realm.
 *
 * Gives the sacrifice target some after effects upon ariving back to reality.
 */
/mob/living/simple_animal/hostile/floor_cluwne/proc/after_return_live_target(mob/living/carbon/human/sac_target)
	if(sac_target.stat == DEAD)
		sac_target.revive(TRUE, TRUE)
		sac_target.grab_ghost()
	to_chat(sac_target, span_hypnophrase("The fight is over, but at great cost. You have been returned to the station in one piece."))
	to_chat(sac_target, span_big("[span_hypnophrase("You don't remember anything leading up to the experience - All you can think about are those horrific hands...")]"))

	// Oh god where are we?
	sac_target.flash_act()
	sac_target.Jitter(60)
	sac_target.blur_eyes(50)
	sac_target.Dizzy(30)
	sac_target.AdjustKnockdown(80)
	sac_target.adjustStaminaLoss(120)

	// Glad i'm outta there, though!
	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm_survived", /datum/mood_event/shadow_realm_live)
	SEND_SIGNAL(sac_target, COMSIG_ADD_MOOD_EVENT, "shadow_realm_survived_sadness", /datum/mood_event/shadow_realm_live_sad)

	// Could use a little pick-me-up...
	sac_target.reagents?.add_reagent(/datum/reagent/medicine/eldritchkiss, 12) //this used to kill toxinlovers, hence the snowflake reagent
	terror_count += 1
	if(terror_count == 2)
		message_admins("Floor Cluwne was deleted due to reaching its max terror count")
		qdel(src)

#undef STAGE_HAUNT
#undef STAGE_SPOOK
#undef STAGE_TORMENT
#undef STAGE_ATTACK
#undef MANIFEST_DELAY

#undef SACRIFICE_SLEEP_DURATION
#undef SACRIFICE_REALM_DURATION
