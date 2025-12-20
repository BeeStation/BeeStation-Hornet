

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
	speed = 0
	combat_mode = TRUE
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
	melee_damage_type = BURN //Did you know morphs are highly acidic blobs?
	see_in_dark = NIGHTVISION_FOV_RANGE
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	vision_range = 1 // Only attack when target is close
	wander = FALSE
	attack_verb_continuous = "glomps"
	attack_verb_simple = "glomp"
	attack_sound = 'sound/effects/blobattack.ogg'
	butcher_results = list(/obj/item/food/meat/slab = 2)
	sight = SEE_SELF|SEE_MOBS

	COOLDOWN_DECLARE(morph_transformation)
	var/morphed = FALSE
	var/atom/movable/form = null
	var/static/list/blacklist_typecache = typecacheof(list(
		/atom/movable/screen,
		/obj/anomaly,
		/obj/eldritch/narsie,
		/mob/living/simple_animal/hostile/morph,
		/obj/effect,
		/mob/camera,
	))
	var/atom/movable/throwatom = null

	mobchatspan = "blob"
	discovery_points = 2000
	var/datum/morph_stomach/morph_stomach
	var/datum/action/innate/morph_stomach/stomach_action

/mob/living/simple_animal/hostile/morph/Initialize(mapload)
	morph_stomach = new(src)
	stomach_action = new(morph_stomach)
	stomach_action.Grant(src)
	. = ..()

/mob/living/simple_animal/hostile/morph/Destroy()
	QDEL_NULL(morph_stomach)
	QDEL_NULL(stomach_action)
	. = ..()

/mob/living/simple_animal/hostile/morph/proc/RemoveContents(atom/movable/A, throwatom_required = FALSE)
	A.forceMove(loc)
	morph_stomach.favorites -= REF(A)
	if(throwatom == A && !throwatom_required)
		throwatom = null

/mob/living/simple_animal/hostile/morph/proc/AddContents(atom/movable/A)
	A.forceMove(src)

/mob/living/simple_animal/hostile/morph/ClickOn(atom/A)
	if(throwatom)
		RemoveContents(throwatom, TRUE)
		throwatom.safe_throw_at(A, throwatom.throw_range, throwatom.throw_speed, src, null, null, null, ismob(throwatom) ? MOVE_FORCE_VERY_WEAK : move_force)
		visible_message(span_warning("[src] spits [throwatom] at [A]!"))
		throwatom = null
		playsound(src, 'sound/effects/splat.ogg', 50, 1)
		morph_stomach.ui_update()
	. = ..()


/mob/living/simple_animal/hostile/morph/examine(mob/user)
	if(morphed)
		. = form.examine(user)
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
	if(ishuman(A))
		//We don't store human mobs, we eat them now where they are
		return digest_mob(A)

	if(A && A.loc != src)
		playsound(src, attack_sound, 50, TRUE)
		visible_message(span_warning("[src] swallows [A] whole!"))
		AddContents(A)
		morph_stomach.ui_update()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/morph/proc/digest_mob(mob/living/living_target)
	if(HAS_TRAIT(living_target, TRAIT_HUSK))
		to_chat(src, span_warning("[span_name("[living_target]")] has already been stripped of all nutritional value!"))
		return FALSE
	if(throwatom == living_target)
		throwatom = null
	to_chat(src, span_danger("You begin digesting [span_name("[living_target]")]"))
	if(do_after(src, 3 SECONDS, living_target))
		if(ishuman(living_target) || ismonkey(living_target) || isalienadult(living_target) || istype(living_target, /mob/living/basic/pet/dog) || istype(living_target, /mob/living/simple_animal/parrot))
			var/list/turfs_to_throw = view(2, src)
			var/list/target_contents = living_target.get_equipped_items(include_pockets = TRUE) + living_target.held_items
			for(var/obj/item/item in target_contents)
				if(isclothing(item))
					continue //no reason to strip them of sensors
				living_target.dropItemToGround(item, TRUE)
				if(QDELING(item))
					continue //skip it
				item.throw_at(pick(turfs_to_throw), 3, 1, spin = FALSE)
				item.pixel_x = rand(-10, 10)
				item.pixel_y = rand(-10, 10)
		RemoveContents(living_target)
		living_target.death(FALSE)
		living_target.take_overall_damage(burn = 50)
		living_target.become_husk("burn") // Digested bodies can be fixed with synthflesh.
		adjustHealth(-(living_target.maxHealth * 0.5))
		to_chat(src, span_danger("You digest [span_name("[living_target]")], restoring some health"))
		playsound(src, 'sound/effects/splat.ogg', vol = 50, vary = TRUE)
		return TRUE

/mob/living/simple_animal/hostile/morph/ShiftClickOn(atom/movable/A)
	if(COOLDOWN_FINISHED(src, morph_transformation) && !stat)
		if(A == src)
			restore()
			return
		if(allowed(A))
			assume(A)
	else
		to_chat(src, span_warning("Your chameleon skin is still repairing itself!"))

/mob/living/simple_animal/hostile/morph/proc/assume(atom/movable/target)
	morphed = TRUE
	form = target

	visible_message(span_warning("[src] suddenly twists and changes shape, becoming a copy of [target]!"), \
					span_notice("You twist your body and assume the form of [target]."))
	appearance = target.appearance
	if(length(target.vis_contents))
		add_overlay(target.vis_contents)
	alpha = max(alpha, 150)	//fucking chameleons
	transform = initial(transform)
	pixel_y = base_pixel_y
	pixel_x = base_pixel_x
	density = target.density

	if(isliving(target))
		var/mob/living/L = target
		mobchatspan = L.mobchatspan
	else
		mobchatspan = initial(mobchatspan)

	//Morphed is slower
	set_varspeed(2)
	set_cooldown_and_hud(FALSE)
	return

/mob/living/simple_animal/hostile/morph/proc/restore(ambush = FALSE)
	if(!morphed)
		return
	morphed = FALSE
	form = null
	alpha = initial(alpha)
	color = initial(color)
	animate_movement = SLIDE_STEPS
	maptext = null
	density = initial(density)

	visible_message(span_warning("[src] suddenly collapses in on itself, dissolving into a pile of green flesh!"), \
					span_notice("You reform to your normal body."))
	name = initial(name)
	icon = initial(icon)
	icon_state = initial(icon_state)
	cut_overlays()

	//Baseline abilities
	melee_damage_type = BURN
	set_varspeed(initial(speed))
	set_cooldown_and_hud(ambush)

/mob/living/simple_animal/hostile/morph/proc/set_cooldown_and_hud(ambush = FALSE)
	if(ambush)
		COOLDOWN_START(src, morph_transformation, 20 SECONDS)
		apply_status_effect(/datum/status_effect/morph_cooldown)
	med_hud_set_health()
	med_hud_set_status()

/mob/living/simple_animal/hostile/morph/proc/morph_ambush(mob/living/L, touched_morph = FALSE)
	changeNext_move(CLICK_CD_MELEE)
	L.Stun(1 SECONDS)
	to_chat(L, span_userdanger("[src] bites you!"))
	visible_message(span_danger("[src] violently bites [L]!"),\
			span_userdanger("You ambush [L]!"), null, COMBAT_MESSAGE_RANGE)

	//After the ambush we show our true form, the attack will register as coming from whatever we were disguised as
	restore(ambush = TRUE)

	if(touched_morph)
		L.Knockdown(5 SECONDS)
		L.reagents.add_reagent(/datum/reagent/toxin/morphvenom, 7)
	else
		L.Knockdown(3 SECONDS)

	if(issilicon(L))
		L.flash_act(affect_silicon = TRUE)

/mob/living/simple_animal/hostile/morph/death(gibbed)
	if(morphed)
		visible_message(span_warning("[src] twists and dissolves into a pile of green flesh!"), \
						span_userdanger("Your skin ruptures! Your flesh breaks apart! No disguise can ward off de--"))
		restore()
	barf_contents()
	..()

//TODO Componentize this
/mob/living/simple_animal/hostile/morph/proc/barf_contents()
	for(var/atom/movable/AM in src)
		RemoveContents(AM)
		if(prob(90))
			step(AM, pick(GLOB.alldirs))
	morph_stomach.ui_update()

/mob/living/simple_animal/hostile/morph/Aggro() // automated only
	..()
	restore()

/mob/living/simple_animal/hostile/morph/LoseAggro()
	vision_range = initial(vision_range)

/mob/living/simple_animal/hostile/morph/AIShouldSleep(list/possible_targets)
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
	if(isitem(target)) //Eat items for later use
		var/obj/item/I = target
		if(!I.anchored)
			eat(I)
			return
	else if(isliving(target)) //Eat living beings to store them for a snack, or other uses
		var/mob/living/L = target
		if(morphed)
			morph_ambush(L, FALSE)
			return //The ambush is our attack
		if(L?.stat >= SOFT_CRIT && eat(L))
			return //attack continues if eat() fails, but we don't want to finish attacking if it doesn't.
	return ..()
//Ambush attack
/mob/living/simple_animal/hostile/morph/attack_hand(mob/living/carbon/human/M)
	if(morphed)
		morph_ambush(M, TRUE)
	else
		..()

/mob/living/simple_animal/hostile/morph/attacked_by(obj/item/I, mob/living/user)
	. = ..()
	if(morphed)
		restore(TRUE) //It is us who was ambushed!

/mob/living/simple_animal/hostile/morph/mind_initialize()
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(notify_non_antag)), 3 SECONDS)

/mob/living/simple_animal/hostile/morph/proc/notify_non_antag()
	if(!mind.has_antag_datum(/datum/antagonist/morph))
		to_chat(src, span_boldwarning("If you were not an antagonist before you did not become one now. You still retain your retain your original loyalties and mind!"))
