//Gutlunches, passive mods that devour blood and gibs
/mob/living/simple_animal/hostile/asteroid/gutlunch
	name = "gutlunch"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Produces a thick, nutritious milk."
	icon = 'icons/mob/lavaland/lavaland_monsters.dmi'
	icon_state = "gutlunch"
	icon_living = "gutlunch"
	icon_dead = "gutlunch_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BEAST)
	speak_emote = list("warbles", "quavers")
	emote_hear = list("trills.")
	emote_see = list("sniffs.", "burps.")
	weather_immunities = list("lava","ash")
	faction = list("mining", "ashwalker")
	density = FALSE
	speak_chance = 1
	turns_per_move = 8
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	move_to_delay = 15
	response_help  = "pets"
	response_disarm = "gently pushes aside"
	response_harm   = "squishes"
	friendly = "pinches"
	a_intent = INTENT_HELP
	ventcrawler = VENTCRAWLER_ALWAYS
	gold_core_spawnable = FRIENDLY_SPAWN
	stat_attack = UNCONSCIOUS
	gender = NEUTER
	stop_automated_movement = FALSE
	stop_automated_movement_when_pulled = TRUE
	stat_exclusive = TRUE
	robust_searching = TRUE
	search_objects = 3 //Ancient simplemob AI shitcode. This makes them ignore all other mobs.
	del_on_death = FALSE
	loot = list(/obj/effect/decal/cleanable/blood/gibs)
	butcher_results = list(/obj/item/reagent_containers/food/snacks/meat/rawcrab = 1)
	deathmessage = "is pulped into bugmash"
	animal_species = /mob/living/simple_animal/hostile/asteroid/gutlunch
	childtype = list(/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch = 100)
	wanted_objects = list(/obj/effect/decal/cleanable/xenoblood, /obj/effect/decal/cleanable/blood, /obj/item/organ, /obj/item/reagent_containers/food/snacks/meat/slab)
	deathsound = "desecration"
	var/udder_type = /obj/item/udder/gutlunch
	var/datum/component/udder/comp
	var/obj/item/udder/gutlunch/udder

/mob/living/simple_animal/hostile/asteroid/gutlunch/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/udder, udder_type, CALLBACK(src, PROC_REF(regenerate_icons)), CALLBACK(src, PROC_REF(regenerate_icons)))
	comp = GetComponent(/datum/component/udder)
	udder = comp.udder

/mob/living/simple_animal/hostile/asteroid/gutlunch/CanAttack(atom/the_target) // Gutlunch-specific version of CanAttack to handle stupid stat_exclusive = true crap so we don't have to do it for literally every single simple_animal/hostile except the two that spawn in lavaland
	if(isturf(the_target) || !the_target || the_target.type == /atom/movable/lighting_object) // bail out on invalids
		return FALSE

	if(see_invisible < the_target.invisibility)//Target's invisible to us, forget it
		return FALSE

	if(isliving(the_target))
		var/mob/living/L = the_target

		if(faction_check_mob(L) && !attack_same)
			return FALSE
		if(L.stat > stat_attack || L.stat != stat_attack && stat_exclusive)
			return FALSE

		return TRUE

	if(isobj(the_target) && is_type_in_typecache(the_target, wanted_objects))
		if(udder.reagents.total_volume < udder.reagents.maximum_volume)
			return TRUE
		else
			return FALSE

	return FALSE

/mob/living/simple_animal/hostile/asteroid/gutlunch/regenerate_icons()
	cut_overlays()
	var/static/gutlunch_full_overlay
	if(isnull(gutlunch_full_overlay))
		gutlunch_full_overlay = iconstate2appearance(icon, "gl_full")
	if(udder.reagents.total_volume == udder.reagents.maximum_volume && health > 0)
		add_overlay(gutlunch_full_overlay)
	..()

/mob/living/simple_animal/hostile/asteroid/gutlunch/death()
	. = ..()
	chem_splash(get_turf(src), 1, list(udder.reagents))
	spawn_gibs()
	regenerate_icons()

//Male gutlunch. They're smaller and more colorful!
/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck
	name = "gubbuck"
	desc = "A scavenger that eats raw meat, often found alongside ash walkers. Males produce harmful chemicals in their nutrient sacs."
	icon_state = "gutlunch_male"
	icon_living = "gutlunch_male"
	icon_dead = "gutlunch_male_dead"
	gender = MALE
	udder_type = /obj/item/udder/gutlunch/male

/mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck/Initialize(mapload)
	. = ..()
	update_transform()

//Lady gutlunch. They make the babby.
/mob/living/simple_animal/hostile/asteroid/gutlunch/guthen
	name = "guthen"
	gender = FEMALE

//Baby gutlunch
/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch
	name = "grublunch"
	icon_state = "gutlunch_baby"
	icon_living = "gutlunch_baby"
	icon_dead = "gutlunch_baby_dead"
	desc = "A baby Gutlunch. It must feed on a lot of meat and guts to become a strong bug!"
	gold_core_spawnable = NO_SPAWN
	udder_type = /obj/item/udder/gutlunch/baby
	var/growth = 0

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Initialize(mapload)
	. = ..()
	update_transform()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/Life()
	..()
	if(udder.reagents.total_volume == udder.reagents.maximum_volume) //originally used a timer for this, but it became more of a problem than it was worth.
		growUp()

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/regenerate_icons()
	cut_overlays()
	return

/mob/living/simple_animal/hostile/asteroid/gutlunch/grublunch/proc/growUp()
	var/mob/living/L
	if(prob(45))
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/gubbuck(loc)
	else
		L = new /mob/living/simple_animal/hostile/asteroid/gutlunch/guthen(loc)
	mind?.transfer_to(L)
	L.faction = faction
	L.setDir(dir)
	visible_message("<span class='notice'>[src] grows up into [L].</span>")
	Destroy()
