/mob/living/simple_animal/hostile/asteroid/ash_whelp
	name = "ash whelp"
	desc = "A small ash drake, much weaker than it's mother but still dangerous."
	icon = 'icons/mob/lavaland/abyss_demons.dmi'
	icon_state = "ash_whelp"
	icon_living = "ash_whelp"
	icon_dead = "ash_whelp_dead"
	mouse_opacity = MOUSE_OPACITY_ICON
	speak_emote = list("roars")
	speed = 2
	move_to_delay = 15
	ranged = TRUE
	ranged_cooldown_time = 40
	maxHealth = 550
	health = 550
	obj_damage = 40
	armour_penetration = 20
	melee_damage = 20
	attacktext = "chomps"
	attack_sound = 'sound/magic/demon_attack1.ogg'
	vision_range = 9
	aggro_vision_range = 9
	move_force = MOVE_FORCE_VERY_STRONG
	move_resist = MOVE_FORCE_VERY_STRONG
	pull_force = MOVE_FORCE_VERY_STRONG
	butcher_results = list(/obj/item/stack/sheet/sinew = 2, /obj/item/stack/sheet/bone = 10, /obj/item/stack/sheet/animalhide/ashdrake = 1)
	loot = list()
	crusher_loot = /obj/item/crusher_trophy/legion_skull/ash_whelp_wing
	deathmessage = "collapses on it's side."
	deathsound = 'sound/magic/demon_dies.ogg'
	stat_attack = UNCONSCIOUS
	robust_searching = TRUE
	/// How far the whelps fire can go
	var/fire_range = 4

/mob/living/simple_animal/hostile/asteroid/ash_whelp/OpenFire()
	var/turf/T = get_turf(target)
	var/list/burn_turfs = getline(src, T) - get_turf(src)
	dragon_fire_line(src, burn_turfs)

/mob/living/simple_animal/hostile/asteroid/ash_whelp/death(gibbed)
	move_force = MOVE_FORCE_DEFAULT
	move_resist = MOVE_RESIST_DEFAULT
	pull_force = PULL_FORCE_DEFAULT
	return ..()