/mob/living/simple_animal/hostile/megafauna/bubblegum/hard
	name = "enraged bubblegum"
	desc = "In what passes for a hierarchy among slaughter demons, this one is king. A really angry king."
	health = 3000
	maxHealth = 3000
	armour_penetration = 60
	melee_damage = 60

	speed = 0.5 //A bit faster
	ranged_cooldown_time = 8 //Less cooldown
	crusher_loot = list(/obj/structure/closet/crate/necropolis/bubblegum/hard/crusher)
	loot = list(/obj/structure/closet/crate/necropolis/bubblegum/hard)

	var/imps = 0
	abyss_born = FALSE

/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/OpenFire()
	anger_modifier = clamp(((maxHealth - health)/50),0,20)
	if(charging || charging)
		return
	ranged_cooldown = world.time + ranged_cooldown_time
	blood_spray()
	if(prob(25 - anger_modifier / 2))
		INVOKE_ASYNC(src, .proc/summon_imps)
		return
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/proc/blood_spray()
	visible_message("<span class='danger'>[src] sprays a shower of gore around himself!</span>")
	for(var/turf/open/J in view(5, src))
		new /obj/effect/temp_visual/dir_setting/bloodsplatter(J, get_dir(src, J))
		playsound(J,'sound/effects/splat.ogg', 100, 1, -1)
		new /obj/effect/decal/cleanable/blood(J)

/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/proc/summon_imps()
	if(imps)
		return

	imps = 0
	for(var/obj/effect/decal/cleanable/blood/H in range(src, 7))
		if(prob(8))
			var/mob/living/simple_animal/hostile/imp/imp = new(H.loc)
			imp.origin = src
			imps += 1

	if(imps)
		new /obj/effect/decal/cleanable/blood(get_turf(src))
		playsound(get_turf(src), 'sound/magic/enter_blood.ogg', 100, 1, -1)
		invisibility = 100
		charging = TRUE

		visible_message("<span class='danger'>[src] summons a shoal of imps, sinking into the blood!</span>")


/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/Bump(atom/A)
	if(isliving(A))
		var/mob/living/L = A
		L.visible_message("<span class='danger'>[src] slams into [L]!</span>", "<span class='userdanger'>[src] slams into you!</span>")
		L.apply_damage(40, BRUTE)
		playsound(get_turf(L), 'sound/effects/meteorimpact.ogg', 100, 1)
		shake_camera(L, 4, 3)
		shake_camera(src, 2, 3)
		var/throwtarget = get_edge_target_turf(src, get_dir(src, get_step_away(L, src)))
		L.throw_at(throwtarget, 3)
	. = ..()

/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/proc/imp_death()
	imps -= 1

	if(!imps)
		playsound(get_turf(src), 'sound/magic/exit_blood.ogg', 100, 1, -1)
		invisibility = initial(invisibility)
		charging = FALSE
		visible_message("<span class='danger'>[src] rises from the ground as the last imp dies!</span>")

/mob/living/simple_animal/hostile/imp
	name = "imp"
	desc = "A large, menacing creature covered in armored black scales."
	speak_emote = list("cackles")
	emote_hear = list("cackles","screeches")
	icon = 'icons/mob/mob.dmi'
	icon_state = "imp"
	icon_living = "imp"
	speed = 1
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/magic/demon_attack1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 250 //Weak to cold
	maxbodytemp = INFINITY
	faction = list("mining", "boss", "hell")
	attacktext = "wildly tears into"
	maxHealth = 50
	health = 50
	healable = 0
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 10
	see_in_dark = 8
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	var/boost = 0

	var/mob/living/simple_animal/hostile/megafauna/bubblegum/hard/origin

/mob/living/simple_animal/hostile/imp/Initialize()
	..()
	boost = world.time + 30

/mob/living/simple_animal/hostile/imp/Life(seconds, times_fired)
	if(!(. = ..()))
		return
	if(boost<world.time)
		speed = 1
	else
		speed = 0

/mob/living/simple_animal/hostile/imp/death()
	..(1)
	playsound(get_turf(src),'sound/magic/demon_dies.ogg', 200, 1)
	visible_message("<span class='danger'>[src] screams in agony as it sublimates into a sulfurous smoke.</span>")
	if(origin)
		origin.imp_death()
	qdel(src)
