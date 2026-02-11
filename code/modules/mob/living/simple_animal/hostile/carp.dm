#define REGENERATION_DELAY 60  // After taking damage, how long it takes for automatic regeneration to begin for megacarps (ty robustin!)

/mob/living/simple_animal/hostile/carp
	name = "space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	unique_name = TRUE
	icon = 'icons/mob/carp.dmi'
	icon_state = "base"
	icon_living = "base"
	icon_dead = "base_dead"
	icon_gib = "carp_gib"
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	speak_chance = 0
	turns_per_move = 5
	butcher_results = list(/obj/item/food/fishmeat/carp = 2)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	emote_taunt = list("gnashes")
	taunt_chance = 30
	speed = 0
	maxHealth = 25
	health = 25

	obj_damage = 50
	melee_damage = 20
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	speak_emote = list("gnashes")
	chat_color = "#B15FB9"
	mobchatspan = "researchdirector"

	//Space carp aren't affected by cold.
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = 1500
	faction = list(FACTION_CARP)
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	pressure_resistance = 200
	gold_core_spawnable = HOSTILE_SPAWN

	/// If the carp uses random coloring
	var/random_color = TRUE
	/// The chance for a rare color variant
	var/rarechance = 1
	/// List of usual carp colors
	var/static/list/carp_colors = list(
		"lightpurple" = "#aba2ff",
		"lightpink" = "#da77a8",
		"green" = "#70ff25",
		"grape" = "#df0afb",
		"swamp" = "#e5e75a",
		"turquoise" = "#04e1ed",
		"brown" = "#ca805a",
		"teal" = "#20e28e",
		"lightblue" = "#4d88cc",
		"rusty" = "#dd5f34",
		"lightred" = "#fd6767",
		"yellow" = "#f3ca4a",
		"blue" = "#09bae1",
		"palegreen" = "#7ef099"
	)

	/// List of rare carp colors
	var/static/list/carp_colors_rare = list(
		"silver" = "#fdfbf3"
	)

/mob/living/simple_animal/hostile/carp/Initialize(mapload)
	ADD_TRAIT(src, TRAIT_FREE_HYPERSPACE_MOVEMENT, INNATE_TRAIT)
	ADD_TRAIT(src, TRAIT_SPACEWALK, INNATE_TRAIT)
	if(random_color)
		set_greyscale(new_config=/datum/greyscale_config/carp)
		carp_randomify(rarechance)
	. = ..()
	make_tameable()

/mob/living/simple_animal/hostile/carp/proc/make_tameable()
	AddComponent(/datum/component/tameable, food_types = list(/obj/item/food/meat), tame_chance = 10, bonus_tame_chance = 5, after_tame = CALLBACK(src, PROC_REF(tamed)))

/**
 * Randomly assigns a color to a carp from either a common or rare color variant lists
 *
 * Arguments:
 * * rare The chance of the carp receiving color from the rare color variant list
 */
/mob/living/simple_animal/hostile/carp/proc/carp_randomify(rarechance)
	var/our_color
	if(prob(rarechance))
		our_color = pick(carp_colors_rare)
		set_greyscale(colors=list(carp_colors_rare[our_color]))
	else
		our_color = pick(carp_colors)
		set_greyscale(colors=list(carp_colors[our_color]))

/mob/living/simple_animal/hostile/carp/revive(full_heal_flags = NONE, excess_healing = 0, force_grab_ghost = FALSE)
	. = ..()
	if(!.)
		return

	update_greyscale()
	update_icon()

/mob/living/simple_animal/hostile/carp/proc/tamed(mob/living/tamer)
	can_buckle = TRUE
	buckle_lying = 0
	AddElement(/datum/element/ridable, /datum/component/riding/creature/carp)

/mob/living/simple_animal/hostile/carp/holocarp
	icon_state = "holocarp"
	icon_living = "holocarp"
	maxbodytemp = INFINITY
	gold_core_spawnable = NO_SPAWN
	del_on_death = TRUE
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/holocarp/make_tameable()
	return

/mob/living/simple_animal/hostile/carp/megacarp
	icon = 'icons/mob/broadMobs.dmi'
	name = "Mega Space Carp"
	desc = "A ferocious, fang bearing creature that resembles a shark. This one seems especially ticked off."
	unique_name = FALSE
	icon_state = "megacarp"
	icon_living = "megacarp"
	icon_dead = "megacarp_dead"
	icon_gib = "megacarp_gib"
	maxHealth = 20
	health = 20
	pixel_x = -16
	base_pixel_x = -16
	mob_size = MOB_SIZE_LARGE
	random_color = FALSE

	obj_damage = 80
	melee_damage = 20

	var/regen_cooldown = 0

/mob/living/simple_animal/hostile/carp/megacarp/Initialize(mapload)
	. = ..()
	name = "[pick(GLOB.megacarp_first_names)] [pick(GLOB.megacarp_last_names)]"
	melee_damage += rand(10,20) //this is on initialize so even with rng the damage will be consistent
	maxHealth += rand(30,60)
	move_to_delay = rand(3,7)

/mob/living/simple_animal/hostile/carp/megacarp/make_tameable()
	return

/mob/living/simple_animal/hostile/carp/megacarp/adjustHealth(amount, updating_health = TRUE, forced = FALSE)
	. = ..()
	if(.)
		regen_cooldown = world.time + REGENERATION_DELAY

/mob/living/simple_animal/hostile/carp/megacarp/Login()
	. = ..()
	if(!. || !client)
		return FALSE

	AddElement(/datum/element/ridable, /datum/component/riding/creature/megacarp)
	can_buckle = TRUE
	buckle_lying = 0

/mob/living/simple_animal/hostile/carp/megacarp/Life(delta_time = SSMOBS_DT, times_fired)
	. = ..()
	if(regen_cooldown < world.time)
		heal_overall_damage(2 * delta_time)

/mob/living/simple_animal/hostile/carp/cayenne
	name = "Cayenne"
	desc = "A failed Syndicate experiment in weaponized space carp technology, it now serves as a lovable mascot."
	gender = FEMALE
	unique_name = FALSE
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	rarechance = 100
	faction = list(FACTION_CARP, FACTION_SYNDICATE)
	health = 60
	maxHealth = 60
	melee_damage = 25
	//A lil bit faster than a human
	speed = -0.2
	/// Keeping track of the nuke disk for the functionality of storing it.
	var/obj/item/disk/nuclear/disky
	/// Location of the file storing disk overlays
	var/icon/disk_overlay_file = 'icons/mob/carp.dmi'
	/// Colored disk mouth appearance for adding it as a mouth overlay
	var/mutable_appearance/colored_disk_mouth

/mob/living/simple_animal/hostile/carp/cayenne/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_DISK_VERIFIER, INNATE_TRAIT) //carp can verify disky
	ADD_TRAIT(src, TRAIT_CAN_USE_NUKE, INNATE_TRAIT)  //carp SMART
	ADD_TRAIT(src, TRAIT_ADVANCEDTOOLUSER, INNATE_TRAIT) //carp SMART

/mob/living/simple_animal/hostile/carp/cayenne/make_tameable()
	return

/mob/living/simple_animal/hostile/carp/cayenne/death(gibbed)
	if(disky)
		disky.forceMove(drop_location())
		disky = null
	return ..()

/mob/living/simple_animal/hostile/carp/cayenne/Destroy(force)
	QDEL_NULL(disky)
	return ..()

/mob/living/simple_animal/hostile/carp/cayenne/examine(mob/user)
	. = ..()
	if(disky)
		. += span_notice("Wait... is that [disky] in [p_their()] mouth?")

/mob/living/simple_animal/hostile/carp/cayenne/AttackingTarget()
	if(istype(target, /obj/item/disk/nuclear))
		var/obj/item/disk/nuclear/potential_disky = target
		if(potential_disky.anchored)
			return
		potential_disky.forceMove(src)
		disky = potential_disky
		to_chat(src, span_nicegreen("YES!! You manage to pick up [disky]. (Click anywhere to place it back down.)"))
		update_icon()
		if(!disky.fake)
			client.give_award(/datum/award/achievement/misc/cayenne_disk, src)
		return
	if(disky)
		if(isopenturf(target))
			to_chat(src, span_notice("You place [disky] on [target]"))
			disky.forceMove(target)
			disky = null
			update_icon()
		else
			disky.melee_attack_chain(src, target)
		return
	if(istype(target, /obj/machinery/nuclearbomb))
		var/obj/machinery/nuclearbomb/nuke = target
		nuke.ui_interact(src)
		return
	return ..()

/mob/living/simple_animal/hostile/carp/cayenne/Exited(atom/movable/AM, atom/newLoc)
	. = ..()
	if(AM == disky)
		disky = null
		update_icon()

/mob/living/simple_animal/hostile/carp/cayenne/update_overlays()
	. = ..()
	if(!disky || stat == DEAD)
		return
	if (isnull(colored_disk_mouth))
		colored_disk_mouth = mutable_appearance(SSgreyscale.GetColoredIconByType(/datum/greyscale_config/carp/disk_mouth, greyscale_colors), "disk_mouth")
	. += colored_disk_mouth
	. += mutable_appearance(disk_overlay_file, "disk_overlay")

/mob/living/simple_animal/hostile/carp/lia
	name = "Lia"
	real_name = "Lia"
	desc = "A failed experiment of Nanotrasen to create weaponised carp technology. This less than intimidating carp now serves as the Head of Security's pet."
	gender = FEMALE
	unique_name = FALSE
	speak_emote = list("squeaks")
	gold_core_spawnable = NO_SPAWN
	faction = list(FACTION_NEUTRAL)
	health = 200
	icon_dead = "magicarp_dead"
	icon_gib = "magicarp_gib"
	icon_living = "magicarp"
	icon_state = "magicarp"
	maxHealth = 200
	random_color = FALSE

/mob/living/simple_animal/hostile/carp/lia/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/pet_bonus, "bloops happily!")

/mob/living/simple_animal/hostile/carp/lia/make_tameable()
	return

/mob/living/simple_animal/hostile/carp/advanced
	name = "advanced space carp"
	desc = "A ferocious, fang-bearing creature that resembles a fish."
	maxHealth = 80
	health = 80
	gold_core_spawnable = NO_SPAWN
	obj_damage = 25

/mob/living/simple_animal/hostile/carp/advanced/examine(mob/user)
	. = ..()
	if(mind)
		. += span_notice("This one seems to be self-aware.")

#undef REGENERATION_DELAY
