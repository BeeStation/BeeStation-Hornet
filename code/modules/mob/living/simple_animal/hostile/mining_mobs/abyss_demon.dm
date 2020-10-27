/mob/living/simple_animal/hostile/asteroid/abyss_demon
	name = "abyss demon"
	desc = "A horrible creature made out of lava and blood."
	icon = 'icons/mob/lavaland/abyss_demons.dmi'
	icon_state = "abyss_demon"
	icon_living = "abyss_demon"
	icon_dead = "abyss_demon"
	icon_gib = "syndicate_gib"
	mouse_opacity = MOUSE_OPACITY_ICON
	speak_emote = list("screeches")
	speed = 1
	move_to_delay = 2
	projectiletype = /obj/item/projectile/temp/basilisk/firebolt
	projectilesound = 'sound/weapons/pierce.ogg'
	ranged = TRUE
	ranged_message = "manifests a firebolt"
	ranged_cooldown_time = 30
	minimum_distance = 3
	retreat_distance = 3
	maxHealth = 550
	health = 550
	obj_damage = 40
	melee_damage = 15
	attacktext = "slices"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	vision_range = 7
	aggro_vision_range = 7
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	del_on_death = TRUE
	loot = list(/obj/item/stack/ore/diamond = 3)
	deathmessage = "fades as the energies that tied it to this world dissipate."
	deathsound = 'sound/magic/demon_dies.ogg'
	stat_attack = UNCONSCIOUS
	movement_type = FLYING
	robust_searching = TRUE
	crusher_loot = /obj/item/crusher_trophy/abyssal_crystal

	var/teleport_distance = 3

obj/item/projectile/temp/basilisk/firebolt
	name = "firebolt"
	icon_state = "lava_barrage"
	damage = 10
	damage_type = BURN
	nodamage = FALSE
	temperature = 600 //Heats up just a bit

obj/item/projectile/temp/basilisk/firebolt/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if (istype(L))
			L.adjust_fire_stacks(3)
			L.IgniteMob()

/mob/living/simple_animal/hostile/asteroid/abyss_demon/OpenFire()
	if(teleport_distance <= 0)
		return ..()
	var/list/possible_ends = list()
	for(var/turf/T in view(teleport_distance, target.loc) - view(teleport_distance - 1, target.loc))
		if(isclosedturf(T))
			continue
		possible_ends |= T
	if(length(possible_ends))
		var/turf/end = pick(possible_ends)
		do_teleport(src, end, 0,  channel=TELEPORT_CHANNEL_BLUESPACE, forced = TRUE)
	SLEEP_CHECK_DEATH(8)
	return ..()

/mob/living/simple_animal/hostile/asteroid/abyss_demon/death(gibbed)
	var/turf/T = get_turf(src)
	if(T && prob(5))
		new /obj/item/assembly/signaler/anomaly/pyro(T)
	return ..()