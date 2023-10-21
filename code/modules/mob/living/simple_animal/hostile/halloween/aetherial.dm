//These are designed to be a weak annoyance, fragile but difficult to see.
//They are fully invisible in well lit areas, but will also regularly break wall-mounted light fixtures
//In dark areas they are difficult to see because it is... dark, but night vision will enable them to be easily spotted
//They have a short aggro radius, but when angered will actually emit negative light, making the surroundings darker
//They occasionally whisper spooky things when docile, and every other time they attack when aggro'd


/mob/living/simple_animal/hostile/aetherial
	name = "???"
	desc = "There's some kind of distortion here"
	icon = 'icons/mob/halloween/aetherial.dmi'
	icon_state = "aetherial"
	icon_living = "aetherial"
	icon_dead = "aetherial"
	icon_gib = "aetherial"
	mob_biotypes = list(MOB_INORGANIC)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 0
	speed = 3
	maxHealth = 45
	health = 45
	obj_damage = 0
	melee_damage = 8
	attacktext = "engulfs"
	attack_sound = 'sound/hallucinations/over_here2.ogg'
	vision_range = 2
	aggro_vision_range = 6 //turns out a short aggro range was bad
	a_intent = INTENT_HARM
	var/light_search = 0
	alpha = 0 //So it is invisible until alpha updates the first time.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 50000
	weather_immunities = list("snow")

/mob/living/simple_animal/hostile/aetherial/Life(delta_time)
	..()
	if(isturf(loc))
		var/turf/T = loc
		switch(T.get_lumcount())
			if(0 to 0.1)
				alpha = 255
			if(0.1 to 0.2)
				alpha = 180
			if(0.2 to 0.4)
				alpha = 120
			if(0.4 to 0.6)
				alpha = 80
			else
				alpha = 0
				light_search += delta_time
				if(light_search >= 10)
					haunted_light()
	else
		alpha = 255
	if(!target && prob(2))
		rotate_sound()
		playsound(loc, attack_sound, 100, TRUE)

/mob/living/simple_animal/hostile/aetherial/death(gibbed)
	qdel(src)
	..()

/mob/living/simple_animal/hostile/aetherial/Aggro()
	set_light(4, -1)
	..()

/mob/living/simple_animal/hostile/aetherial/LoseAggro()
	set_light(0)
	..()

/mob/living/simple_animal/hostile/aetherial/AttackingTarget()
	..()
	if(attack_sound)
		attack_sound = null //So one sound plays on every other attack.
	else
		rotate_sound()

/mob/living/simple_animal/hostile/aetherial/proc/rotate_sound()
	attack_sound = pick('sound/hallucinations/over_here2.ogg',
						'sound/hallucinations/over_here3.ogg',
						'sound/hallucinations/turn_around1.ogg',
						'sound/hallucinations/turn_around2.ogg',
						'sound/hallucinations/look_up1.ogg',
						'sound/hallucinations/look_up2.ogg',
						'sound/hallucinations/im_here1.ogg',
						'sound/hallucinations/im_here2.ogg',
						'sound/hallucinations/i_see_you1.ogg',
						'sound/hallucinations/i_see_you2.ogg',
						'sound/hallucinations/behind_you1.ogg',
						'sound/hallucinations/behind_you2.ogg')

/mob/living/simple_animal/hostile/aetherial/proc/haunted_light()
	var/list/lights_to_destroy = list()

	for(var/turf/target in view_or_range(4,src,"view"))
		for(var/obj/machinery/light/L in target)
			if(!L.on)
				break
			lights_to_destroy += L

	if(length(lights_to_destroy))
		var/obj/machinery/light/L = pick(lights_to_destroy)
		L.visible_message("<span class='warning'><b>\The [L] suddenly flares brightly and begins to spark!</span>")
		var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
		s.set_up(4, 0, L)
		s.start()
		new /obj/effect/temp_visual/revenant(get_turf(L))
		addtimer(CALLBACK(L, TYPE_PROC_REF(/obj/machinery/light, break_light_tube)), 2 SECONDS)
		light_search = 0

