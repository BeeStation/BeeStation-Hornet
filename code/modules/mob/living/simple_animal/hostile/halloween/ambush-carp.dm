/mob/living/simple_animal/hostile/ambush
	name = "???"
	desc = "Something seems off over there."
	icon = 'icons/mob/halloween/ambush.dmi'
	icon_state = "abyssal_carp"
	icon_living = "abyssal_carp"
	icon_dead = "abyssal_carp_dead"
	icon_gib = ""
	butcher_results = list(/obj/item/reagent_containers/food/snacks/carpmeat = 3)
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	mouse_opacity = MOUSE_OPACITY_ICON
	move_to_delay = 4 SECONDS //Slow and easy to get away from... for the person rescuing you.
	speed = 0
	maxHealth = 120
	health = 120
	obj_damage = 0
	melee_damage = 23
	attacktext = "shreds"
	var/idle_sound
	var/aggro_sound
	var/list
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1200
	weather_immunities = list("snow")
	faction = list("hostile", "twisted")
	vision_range = 2
	aggro_vision_range = 9
	a_intent = INTENT_HARM
	var/light_search = 0
	alpha = 50
	speak_language = /datum/language/narsie

/mob/living/simple_animal/hostile/ambush/Initialize()
	..()
	rotate_sound("all")

/mob/living/simple_animal/hostile/ambush/proc/rotate_sound(type)
	switch(type)
		if("idle")
			idle_sound = pick('sound/creatures/halloween/ACarp/ACarpIdle1.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle2.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle3.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle4.ogg')
		if("aggro")
			aggro_sound = pick('sound/creatures/halloween/ACarp/ACarpAlert1.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert2.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert3.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert4.ogg')

		if("attack")
			attack_sound = pick('sound/creatures/halloween/ACarp/ACarpAttack1.ogg',
							'sound/creatures/halloween/ACarp/ACarpAttack2.ogg',
							'sound/creatures/halloween/ACarp/ACarpAttack3.ogg')
		if("all")
			deathsound = pick('sound/creatures/halloween/ACarp/ACarpDeath1.ogg',
							'sound/creatures/halloween/ACarp/ACarpDeath2.ogg',
							'sound/creatures/halloween/ACarp/ACarpDeath3.ogg')

			attack_sound = pick('sound/creatures/halloween/ACarp/ACarpAttack1.ogg',
							'sound/creatures/halloween/ACarp/ACarpAttack2.ogg',
							'sound/creatures/halloween/ACarp/ACarpAttack3.ogg')

			aggro_sound = pick('sound/creatures/halloween/ACarp/ACarpAlert1.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert2.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert3.ogg',
							'sound/creatures/halloween/ACarp/ACarpAlert4.ogg')

			idle_sound = pick('sound/creatures/halloween/ACarp/ACarpIdle1.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle2.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle3.ogg',
							'sound/creatures/halloween/ACarp/ACarpIdle4.ogg')

/mob/living/simple_animal/hostile/ambush/attack_basic_mob(mob/living/basic/user, list/modifiers)
	playsound(loc, attack_sound, 50)
	attack_sound = null //we want to override modulation
	..()
	rotate_sound("attack")

/mob/living/simple_animal/hostile/ambush/Life(delta_time)
	..()
	if(!target && !key)
		if(alpha > 50)
			alpha -= 20
		if(prob(3) || key && prob(15))
			playsound(loc, idle_sound, 50)
			rotate_sound("idle")

/mob/living/simple_animal/hostile/ambush/death(gibbed)
	..()

/mob/living/simple_animal/hostile/ambush/Aggro()
	..()
	name = "abyssal carp"
	desc = "Distorts space around it and lies in ambush for unsuspecting prey. Very intelligent and powerful, an extreme hazard to personnel"
	if(buckled)
		buckled.unbuckle_mob(src,force=TRUE)
	playsound(loc, aggro_sound, 100)
	rotate_sound("aggro")
	if(alpha <= 50 && isliving(target))
		var/mob/living/L = target
		L.Paralyze(12 SECONDS) //Get ambushed scrub, hope you have a buddy system
		visible_message("<span class='userdanger'>\The [src] ambushes [L] with a burst of abyssal energy!</span>", \
					"<span class='userdanger'>\The [src] ambushes you with a burst of abyssal energy!</span>", null, COMBAT_MESSAGE_RANGE)
	alpha = 250

/mob/living/simple_animal/hostile/ambush/LoseTarget()
	if(isliving(target))
		var/mob/living/L = target
		var/atom/target_from = GET_TARGETS_FROM(src)
		if(L.Adjacent(target_from) && L.stat > CONSCIOUS) //If the target is adjacent and also in crit, they have probably not received help yet so we move on top of them
			L.unbuckle_all_mobs(force=TRUE)
			if(L.buckle_mob(src, force=TRUE))
				layer = L.layer+0.01
				playsound(loc, idle_sound, 50)
				rotate_sound("idle")
	..()

/mob/living/simple_animal/hostile/ambush/LoseAggro()
	..()
	if(!key)
		name = initial(name)
		desc = initial(desc)
