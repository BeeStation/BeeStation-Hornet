
//MOBS//

/mob/living/simple_animal/hostile/russian/army
	name = "Russian soldier"
	desc = "For the Motherland!"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "russianarmy"
	icon_living = "russianarmy"
	icon_gib = "syndicate_gib"
	speak_chance = 0
	turns_per_move = 5
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	robust_searching = 1
	move_to_delay = 2
	projectiletype = /obj/item/projectile/bullet/a762
	projectilesound = 'sound/weapons/rifleshot.ogg'
	ranged = TRUE
	approaching_target = TRUE
	dodging = TRUE
	minimum_distance = 6
	rapid_melee = 2
	maxHealth = 200
	health = 200
	check_friendly_fire = 1
	ranged_cooldown_time = 25
	melee_queue_distance = 2
	stat_attack = UNCONSCIOUS
	attacktext = "beats"
	attack_sound = 'sound/weapons/genhit1.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/russian_army)
	var/ammo = 5
	var/reloading = FALSE
	var/mob/living/defend_target

/mob/living/simple_animal/hostile/russian/army/Life()
	. = ..()
	if(defend_target && !target && get_dist(src, defend_target) >= 5)
		MoveToDefendTarget(defend_target)
		if(get_dist(src, defend_target) >= 9)
			lose_patience_timeout = 30

/mob/living/simple_animal/hostile/russian/army/proc/MoveToDefendTarget(mob/living/defend_target)
	for(src in range(get_dist(src, defend_target), targets_from))
		MoveToTarget(defend_target)
		Goto(defend_target,move_to_delay,minimum_distance)
		lose_patience_timeout = initial(lose_patience_timeout)

/mob/living/simple_animal/hostile/russian/army/Aggro()
	..()
	soundeffects()

/mob/living/simple_animal/hostile/russian/army/proc/soundeffects()
	playsound(get_turf(src), 'sound/effects/suitstep1.ogg', 30, 1)
	sleep(5)
	playsound(get_turf(src), 'sound/effects/suitstep2.ogg', 30, 1)

/mob/living/simple_animal/hostile/russian/army/OpenFire(atom/A)
	if(reloading)
		return
	..()

/mob/living/simple_animal/hostile/russian/army/Shoot(atom/targeted_atom)
	..()
	ammo = ammo - 1
	if(ammo == 0)
		reload()
		return
	rack()

/mob/living/simple_animal/hostile/russian/army/proc/rack()
	sleep(10)
	playsound(get_turf(src), 'sound/weapons/mosinboltout.ogg', 60, 0)
	var/obj/item/ammo_casing/casing = new /obj/item/ammo_casing/a762
	casing.BB = null
	casing.caliber = null
	casing.icon_state =  "762-casing"
	casing.item_state = "762-casing"
	casing.forceMove(get_turf(src))
	sleep(10)
	playsound(get_turf(src), 'sound/weapons/mosinboltin.ogg', 60, 0)

/mob/living/simple_animal/hostile/russian/army/proc/reload()
	reloading = TRUE
	sleep(10)
	var/list/possible_phrases = list("Blyat! Reloading!", "Another clip!", "Tovarischi, I have to reload!", "I'm empty! Need a second!", "Cyka! New clip!")
	var/chosen_phrase = pick(possible_phrases)
	say(chosen_phrase)
	retreat_distance = 4
	sleep(5)
	playsound(get_turf(src), 'sound/weapons/mosinboltout.ogg', 50, 0)
	sleep(15)
	var/list/possible_sounds = list('sound/weapons/gun_magazine_insert_full_4.ogg', 'sound/weapons/gun_magazine_insert_full_5.ogg', 'sound/weapons/gun_magazine_insert_full_3.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 50, 0)
	var/obj/item/ammo_box/emptymag = new /obj/item/ammo_box/a762/empty
	emptymag.forceMove(get_turf(src))
	ammo = initial(ammo)
	sleep(10)
	playsound(get_turf(src), 'sound/weapons/mosinboltin.ogg', 50, 0)
	retreat_distance = null
	reloading = FALSE

/mob/living/simple_animal/hostile/russian/army/army2
	name = "Russian soldier with a bottle"
	desc = "For the Motherland! With extra vodka."
	icon_state = "russianarmy2"
	icon_living = "russianarmy2"
	minimum_distance = 2
	in_melee = TRUE
	var/bottle_broken = FALSE
	var/vodka_charges = 3
	var/ability_cooldown = 0
	var/ability_cooldown_time = 100
	health = 180
	maxHealth = 180
	loot = list(/obj/effect/mob_spawn/human/corpse/russian_army/army2)
	move_to_delay = 3
	rapid_melee = 1
	melee_damage = 20
	attack_sound = "shatter"
	attacktext = "smashes the bottle against"

/mob/living/simple_animal/hostile/russian/army/army2/OpenFire(atom/A)
	if(prob(20) && ability_cooldown < world.time)
		ability_cooldown = world.time + ability_cooldown_time
		ThrowBottle(A)
		ranged_cooldown = 10
		return
	. = ..()

/mob/living/simple_animal/hostile/russian/army/army2/proc/ThrowBottle(atom/targeted_atom)
	move_to_delay = 6
	speed = 5
	minimum_distance = 5
	in_melee = FALSE
	ranged = FALSE
	visible_message("<span class='warning'[src] takes out a bottle of vodka out of nowhere, preparing to throw!</span>")
	sleep(15)
	var/obj/item/reagent_containers/food/drinks/bottle/B = new /obj/item/reagent_containers/food/drinks/bottle/vodka
	B.forceMove(src.loc)
	B.throw_at(targeted_atom, 50, 8, src)
	sleep(5)
	move_to_delay = initial(move_to_delay)
	speed = initial(speed)
	in_melee = TRUE
	ranged = TRUE

/mob/living/simple_animal/hostile/russian/army/army2/Life()
	. = ..()
	if(health < 80 && prob(20) && vodka_charges > 0 && bottle_broken == FALSE)
		visible_message("[src] drinks some vodka. You notice that their wounds are washing away!")
		playsound(get_turf(src), 'sound/items/drink.ogg', 100, 1)
		health = health + 60
		vodka_charges = vodka_charges - 1

/mob/living/simple_animal/hostile/russian/army/army2/AttackingTarget()
	if(!bottle_broken)
		if(ishuman(target))
			. = ..()
			var/mob/living/carbon/human/C = target
			C.apply_damage(20, BRUTE, BODY_ZONE_HEAD)
			C.apply_effect(min(15, 200) , EFFECT_KNOCKDOWN)
			bottle_broken = TRUE
			playsound(get_turf(src), "shatter", 80, 0)
			icon_state = "russianarmy2_bottlebroken"
			icon_living = "russianarmy2_bottlebroken"
			visible_message("[src] smashes the bottle of vodka against your head!")
			var/datum/reagent/R = /datum/reagent/consumable/ethanol/vodka
			R.reaction_mob(target, TOUCH)
			attack_sound = 'sound/weapons/bladeslice.ogg'
			attacktext = "slices"
			melee_damage = 16
			return
		else
			. = ..()
			icon_state = "russianarmy2_bottlebroken"
			icon_living = "russianarmy2_bottlebroken"
			attack_sound = 'sound/weapons/bladeslice.ogg'
			attacktext = "slices"
			melee_damage = 16
			bottle_broken = TRUE
			return
	. = ..()

/mob/living/simple_animal/hostile/russian/army/army3
	name = "Russian soldier with a knife"
	desc = "Looks really angry."
	icon_state = "russianarmy3"
	icon_living = "russianarmy3"
	maxHealth = 230
	health = 230
	in_melee = TRUE
	ranged = FALSE
	rapid_melee = 3
	minimum_distance = 0
	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	melee_damage = 20
	loot = list(/obj/effect/mob_spawn/human/corpse/russian_army/army3, /obj/item/kitchen/knife)
	var/knives_left = 10
	var/ability_cooldown = 0
	var/ability_cooldown_time = 80

/mob/living/simple_animal/hostile/russian/army/army3/MoveToTarget(list/possible_targets)
	. = ..()
	if(knives_left > 0 && prob(30) && ability_cooldown < world.time)
		move_to_delay = 8
		speed = 10
		visible_message("[src] prepares a knife to throw!")
		addtimer(CALLBACK(src, .proc/throwknife, target), 30)
		ability_cooldown = world.time + ability_cooldown_time

/mob/living/simple_animal/hostile/russian/army/army3/proc/throwknife(atom/target)
	var/list/knives = list(/obj/item/kitchen/knife,
						/obj/item/kitchen/knife/butcher,
						/obj/item/kitchen/knife/carrotshiv,
						/obj/item/kitchen/knife/combat,
						/obj/item/kitchen/knife/combat/bone,
						/obj/item/kitchen/knife/combat/survival)
	var/chosen_knife = pick(knives)
	var/obj/item/kitchen/K = new chosen_knife(src.loc)
	K.forceMove(src.loc)
	K.throw_at(target, 15, 6, src)
	knives_left = knives_left - 1
	sleep(5)
	move_to_delay = initial(move_to_delay)
	speed = initial(speed)

/mob/living/simple_animal/hostile/russian/army/army4
	name = "Russian officer"
	maxHealth = 150
	health = 150
	icon_state = "russianarmy4"
	icon_living = "russianarmy4"
	projectiletype = /obj/item/projectile/bullet/n762
	projectilesound = 'sound/weapons/revolver357shot.ogg'
	minimum_distance = 5
	attacktext = "punches"
	attack_sound = 'sound/weapons/punch1.ogg'
	loot = list(/obj/effect/mob_spawn/human/corpse/russian_army/army4)
	ranged_cooldown_time = 15
	ammo = 7
	var/giving_thermals = FALSE
	var/ability_cooldown = 0
	var/ability_cooldown_time = 150

/mob/living/simple_animal/hostile/russian/army/army4/rack()
	return

/mob/living/simple_animal/hostile/russian/army/army4/reload()
	reloading = TRUE
	var/list/possible_phrases = list("More bullets, tovarischi.", "Give me a second!", "I'm empty!", "Reloading!", "Need some time to get my bullets!")
	var/chosen_phrase = pick(possible_phrases)
	say(chosen_phrase)
	retreat_distance = 5
	sleep(10)
	playsound(get_turf(src), 'sound/weapons/revolverempty.ogg', 50, 0)
	var/datum/callback/ul = CALLBACK(src, .proc/Unload)
	for(var/i in 1 to initial(ammo))
		addtimer(ul, (i - 1)*0.1)
	sleep(10)
	var/datum/callback/cb = CALLBACK(src, .proc/insertboolet)
	for(var/i in initial(ammo))
		addtimer(cb, (i - 1)*4)
	sleep(5)
	var/list/possible_sounds = list('sound/weapons/revolverspin1.ogg', 'sound/weapons/revolverspin2.ogg', 'sound/weapons/revolverspin3.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 50, 0)
	sleep(10)
	ammo = initial(ammo)
	retreat_distance = null
	reloading = FALSE

/mob/living/simple_animal/hostile/russian/army/army4/proc/Unload()
	var/obj/item/ammo_casing/spent/C = new
	C.forceMove(drop_location())
	C.bounce_away(FALSE, NONE)
	C.name = "7.62x38mmR bullet casing"

/mob/living/simple_animal/hostile/russian/army/army4/proc/insertboolet()
	playsound(get_turf(src), 'sound/weapons/revolverload.ogg', 80, 0)

/mob/living/simple_animal/hostile/russian/army/army4/Aggro()
	. = ..()
	if(target)
		if(defend_target && ability_cooldown < world.time && prob(60) && get_dist(src, defend_target) <= 7)
			var/list/possible_lines = list("They can't hide from us!", "I will make them reveal themselves!", "We can see them!")
			var/chosen_line = pick(possible_lines)
			say(chosen_line)
			ability()
			return
		if(!defend_target)
			summon_backup_nosound()
		if(ability_cooldown < world.time && prob(60))
			var/list/possible_lines = list("I still can see you!", "You can't hide!", "You can't run forever!")
			var/chosen_line = pick(possible_lines)
			say(chosen_line)
			ability()

/mob/living/simple_animal/hostile/russian/army/army4/proc/ability()
	ranged_ignores_vision = TRUE
	if(defend_target)
		ability_cooldown = world.time + ability_cooldown_time
		ADD_TRAIT(defend_target, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		ADD_TRAIT(src, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		defend_target.update_sight()
		update_sight()
		playsound(get_turf(src), 'sound/magic/teleport_app.ogg', 50, 0)
		giving_thermals = TRUE
		sleep(50)
		REMOVE_TRAIT(defend_target, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		REMOVE_TRAIT(src, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		defend_target.update_sight()
		update_sight()
		playsound(get_turf(src), 'sound/magic/teleport_diss.ogg', 50, 0)
		giving_thermals = FALSE
	else
		ability_cooldown = world.time + ability_cooldown_time
		ADD_TRAIT(src, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		update_sight()
		playsound(get_turf(src), 'sound/magic/teleport_app.ogg', 10, 0)
		giving_thermals = TRUE
		sleep(50)
		REMOVE_TRAIT(src, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		update_sight()
		playsound(get_turf(src), 'sound/magic/teleport_diss.ogg', 10, 0)
		giving_thermals = FALSE
	ranged_ignores_vision = FALSE

/mob/living/simple_animal/hostile/russian/army/army4/summon_backup_nosound(distance, exact_faction_match)
	. = ..()
	var/list/possible_phrases = list("Target, over there!", "Contact!", "Got one right there!", "Over there!")
	var/chosen_phrase = pick(possible_phrases)
	say(chosen_phrase)

/mob/living/simple_animal/hostile/russian/army/army4/soundeffects()
	return

/mob/living/simple_animal/hostile/russian/army/army4/death(gibbed)
	if(giving_thermals)
		REMOVE_TRAIT(src, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		REMOVE_TRAIT(defend_target, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		defend_target.update_sight()
	. = ..()

//CORPSES//

/obj/effect/mob_spawn/human/corpse/russian_army
	name = "Russian soldier 1"
	hair_style = "Bald"
	facial_hair_style = "Shaved"
	skin_tone = "caucasian1"
	gender = MALE
	outfit = /datum/outfit/russian_army1

/datum/outfit/russian_army1
	name = "Russian soldier ver. 1"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/vest/russian
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/helmet/rus_helmet
	gloves = /obj/item/clothing/gloves/fingerless
	mask = /obj/item/clothing/mask/russian_balaclava

/obj/effect/mob_spawn/human/corpse/russian_army/army2
	name = "Russian soldier 2"
	outfit = /datum/outfit/russian_army2

/datum/outfit/russian_army2
	name = "Russian soldier ver. 2"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/vest/russian
	shoes = /obj/item/clothing/shoes/russian
	head = /obj/item/clothing/head/helmet/rus_helmet

/obj/effect/mob_spawn/human/corpse/russian_army/army3
	name = "Russian soldier ver. 3"
	outfit = /datum/outfit/russian_army3

/datum/outfit/russian_army3
	name = "Russian soldier ver. 3"
	uniform = /obj/item/clothing/under/pants/camo
	suit = /obj/item/clothing/suit/armor/vest/russian
	shoes = /obj/item/clothing/shoes/russian
	belt = /obj/item/storage/belt/bandolier
	head = /obj/item/clothing/head/helmet/rus_ushanka

/obj/effect/mob_spawn/human/corpse/russian_army/army3/equip(mob/living/carbon/human/H)
	H.undershirt = "redshirt"
	..()

/obj/effect/mob_spawn/human/corpse/russian_army/army4
	name = "Russian officer's corpse"
	outfit = /datum/outfit/russian_army4

/datum/outfit/russian_army4
	name = "Russian officer with nice coat"
	shoes = /obj/item/clothing/shoes/russian
	uniform = /obj/item/clothing/under/costume/russian_officer
	head = /obj/item/clothing/head/hopcap
	suit = /obj/item/clothing/suit/armor/vest/russian_coat
