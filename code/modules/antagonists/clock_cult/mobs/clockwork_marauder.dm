#define MARAUDER_SHIELD_RECHARGE 600
#define MARAUDER_SHIELD_MAX 4

/mob/living/simple_animal/clockwork_marauder
	name = "clockwork marauder"
	desc = "A brass machine of destruction,"
	icon = 'icons/mob/clockwork_mobs.dmi'
	icon_state = "clockwork_marauder"
	icon_dead = "anime_fragment"
	possible_a_intents = list(INTENT_HARM)
	health = 140
	maxHealth = 140

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	movement_type = FLYING
	move_resist = MOVE_FORCE_OVERPOWERING
	mob_size = MOB_SIZE_LARGE
	pass_flags = PASSTABLE
	hud_possible = list(ANTAG_HUD)
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)

	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	chat_color = "#CAA25B"
	mobchatspan = "brassmobsay"
	obj_damage = 80
	melee_damage = 24
	faction = list("ratvar")

	initial_language_holder = /datum/language_holder/clockmob

	var/shield_health = MARAUDER_SHIELD_MAX
	var/next_shield_recharge = 0

	var/debris = list(/obj/item/clockwork/alloy_shards/large = 1, \
	/obj/item/clockwork/alloy_shards/medium = 2, \
	/obj/item/clockwork/alloy_shards/small = 3) //Parts left behind when a structure breaks

/mob/living/simple_animal/clockwork_marauder/Login()
	. = ..()
	add_servant_of_ratvar(src)
	to_chat(src, "<span class='brass'>You can block up to 4 attacks with your shield, however it requires a welder to be repaired.</span>")

/mob/living/simple_animal/clockwork_marauder/death(gibbed)
	. = ..()
	for(var/item in debris)
		var/count = debris[item]
		for(var/i in 1 to count)
			new item(get_turf(src))
	qdel(src)

/mob/living/simple_animal/clockwork_marauder/bullet_act(obj/item/projectile/Proj)
	//Block Ranged Attacks
	if(shield_health > 0)
		damage_shield()
		to_chat(src, "<span class='warning'>Your shield blocks the attack.</span>")
		return BULLET_ACT_BLOCK
	return ..()

/mob/living/simple_animal/clockwork_marauder/proc/damage_shield()
	if(shield_health == MARAUDER_SHIELD_MAX)
		next_shield_recharge = world.time + MARAUDER_SHIELD_RECHARGE
	shield_health --
	playsound(src, 'sound/magic/clockwork/anima_fragment_attack.ogg', 60, TRUE)
	if(shield_health == 0)
		to_chat(src, "<span class='userdanger'>Your shield breaks!</span>")
		to_chat(src, "<span class='brass'>You require a welding tool to repair your damaged shield!</span>")

/mob/living/simple_animal/clockwork_marauder/welder_act(mob/living/user, obj/item/I)
	if(do_after(user, 25, target=src))
		health = min(health + 10, maxHealth)
		to_chat(user, "<span class='notice'>You repair some of [src]'s damage.</span>")
		if(shield_health < MARAUDER_SHIELD_MAX)
			shield_health ++
			playsound(src, 'sound/magic/charge.ogg', 60, TRUE)
	return TRUE

#undef MARAUDER_SHIELD_RECHARGE
#undef MARAUDER_SHIELD_MAX
