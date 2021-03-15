/**
  *	Lobstrosities, the poster boy of charging AI mobs. Drops crab meat and bones.
  * Outside of charging, it's intended behavior is that it is generally slow moving, but makes up for that with a knockdown attack to score additional hits.
  */
/mob/living/simple_animal/hostile/asteroid/lobstrosity
	name = "arctic lobstrosity"
	desc = "A marvel of evolution gone wrong, the frosty ice produces underground lakes where these ill tempered seafood gather. Beware its charge."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "arctic_lobstrosity"
	icon_living = "arctic_lobstrosity"
	icon_dead = "arctic_lobstrosity_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	mouse_opacity = MOUSE_OPACITY_ICON
	attacktext  = "snips"
	friendly = "chitters at"
	speak_emote = list("chitters")
	speed = 3
	move_to_delay = 20
	maxHealth = 150
	health = 150
	obj_damage = 15
	melee_damage = 20
	attack_sound = 'sound/weapons/bite.ogg'
	weather_immunities = list("snow")
	vision_range = 5
	aggro_vision_range = 7
	charger = TRUE
	charge_distance = 4
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/crab = 2, /obj/item/stack/sheet/bone = 2)
	robust_searching = TRUE
	do_footstep = TRUE
	gold_core_spawnable = HOSTILE_SPAWN

/mob/living/simple_animal/hostile/asteroid/lobstrosity/lava
	name = "tropical lobstrosity"
	desc = "A marvel of evolution gone wrong, the sulfur lakes of lavaland have given them a vibrant, red hued shell. Beware its charge."
	icon_state = "lobstrosity"
	icon_living = "lobstrosity"
	icon_dead = "lobstrosity_dead"
