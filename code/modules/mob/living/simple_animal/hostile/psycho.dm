

/mob/living/simple_animal/hostile/psycho
	name = "Psycho"
	desc = "They're wearing a pretty uncomfortable jacket."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "psycho"
	icon_living = "psycho"
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	turns_per_move = 0
	del_on_death = TRUE
	speak_chance = 5
	attack_sound = 'sound/weapons/bite.ogg'
	speak = list("I'm not mad!","What insanity?","Kill")
	speed = -2
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 2.5
	faction = list(FACTION_HOSTILE)
	move_to_delay = 3
	rapid_melee = 2
	in_melee = TRUE
	approaching_target = TRUE
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 5
	sidestep_per_cycle = 0
	stat_attack = HARD_CRIT
	melee_damage = 15
	lose_patience_timeout = 350
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost)

/mob/living/simple_animal/hostile/psycho/regular
	var/cooldown = 0
	var/static/list/idle_sounds

/mob/living/simple_animal/hostile/psycho/regular/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psycidle1.ogg','sound/creatures/psycidle2.ogg','sound/creatures/psycidle3.ogg')

/mob/living/simple_animal/hostile/psycho/regular/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, FALSE)

/mob/living/simple_animal/hostile/psycho/regular/Aggro()
	..()
	var/list/possible_sounds = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/regular/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psycdeath1.ogg','sound/creatures/psycdeath2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/fast
	move_to_delay = 2
	speed = -5
	maxHealth = 70
	health = 70

/mob/living/simple_animal/hostile/psycho/muzzle
	icon_state = "psychomuzzle"
	icon_living = "psychomuzzle"
	attack_sound = null
	speak_chance = 0
	melee_damage = 9
	var/cooldown = 0
	var/static/list/idle_sounds
	speed = 0
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost/muzzle)

/mob/living/simple_animal/hostile/psycho/muzzle/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psychidle.ogg','sound/creatures/psychidle2.ogg')

/mob/living/simple_animal/hostile/psycho/muzzle/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psychdeath.ogg','sound/creatures/psychdeath2.ogg',)
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/muzzle/Aggro()
	..()
	var/list/possible_sounds = list('sound/creatures/psychsight.ogg','sound/creatures/psychsight2.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/muzzle/AttackingTarget()
	..()
	playsound(get_turf(src), 'sound/creatures/psychattack1.ogg', 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/muzzle/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/psycho/trap
	desc = "This one has a strange device on his head."
	icon_state = "psychotrap"
	icon_living = "psychotrap"
	speak_chance = 0
	speed = -3
	move_to_delay = 2
	melee_damage = 15
	attack_sound = null
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost/trap)
	var/cooldown = 0
	var/static/list/idle_sounds

/mob/living/simple_animal/hostile/psycho/trap/Aggro()
	..()
	var/list/possible_sounds = list('sound/creatures/psychsight.ogg','sound/creatures/psychsight2.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/trap/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psychidle.ogg','sound/creatures/psychidle2.ogg')

/mob/living/simple_animal/hostile/psycho/trap/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, FALSE)
	if(health < maxHealth)
		playsound(src, 'sound/machines/beep.ogg', 80, FALSE)
		addtimer(CALLBACK(src, PROC_REF(death)), 200)

/mob/living/simple_animal/hostile/psycho/trap/AttackingTarget()
	var/list/possible_sounds = list('sound/creatures/psychhead.ogg','sound/creatures/psychhead2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 100, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/trap/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psychdeath.ogg','sound/creatures/psychdeath2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, 0, 0)
	playsound(get_turf(src), 'sound/effects/snap.ogg', 75, TRUE, 0)
	playsound(get_turf(src), 'sound/effects/splat.ogg', 90, TRUE, 0)
	visible_message(span_boldwarning("The device activates!"))
	..()
