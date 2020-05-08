#define DASH_COOLDOWN 10 SECONDS

/mob/living/simple_animal/hostile/aeon_guardian
	name = "The Aeon"
	desc = "The companion of the one who touched heaven, guarding his master eternally."
	icon = 'icons/mob/aeon.dmi'
	icon_state = "aeon"
	icon_living = "aeon"
	health = INFINITY
	maxHealth = INFINITY
	movement_type = FLYING
	mob_biotypes = list(MOB_INORGANIC, MOB_SPIRIT)
	melee_damage_lower = 10
	melee_damage_upper = 25
	var/mob/living/simple_animal/hostile/megafauna/aeon/master
	var/last_dash = 0


/mob/living/simple_animal/hostile/megafauna/aeon
	name = "The Forgotten One"
	desc = "An ancient adventurer, forever cursed to guard an cursed artifact after grasping for heaven across the Abyss."
	health = 1500
	maxHealth = 1500
	icon_state = "one"
	icon_living = "one"
	icon = 'icons/mob/aeon.dmi'
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	movement_type = GROUND
	speak_emote = list("gasps")
	speed = 3
	loot = list(/obj/item/stand_arrow)
	wander = FALSE
	del_on_death = TRUE
	gps_name = "Lost Signal"
	var/mob/living/simple_animal/hostile/aeon_guardian/guardian

/mob/living/simple_animal/hostile/megafauna/aeon/Initialize(mapload)
	. = ..()
	guardian = new(src)
	guardian.master = src
