/mob/living/simple_animal/hostile/wizard
	name = "Space Wizard"
	desc = "EI NATH?"
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "wizard"
	icon_living = "wizard"
	icon_dead = "wizard_dead"
	mob_biotypes = MOB_ORGANIC | MOB_HUMANOID
	speak_chance = 0
	turns_per_move = 3
	speed = 0
	maxHealth = 100
	health = 100
	melee_damage = 5
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	attack_sound = 'sound/weapons/punch1.ogg'
	combat_mode = TRUE
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 7.5
	faction = list(FACTION_WIZARD)
	status_flags = CANPUSH
	footstep_type = FOOTSTEP_MOB_SHOE
	retreat_distance = 3 //out of fireball range
	minimum_distance = 3
	del_on_death = TRUE
	loot = list(/obj/effect/mob_spawn/human/corpse/wizard,
				/obj/item/staff)

	var/datum/action/spell/pointed/projectile/fireball/fireball
	var/datum/action/spell/teleport/radius_turf/blink/blink
	var/datum/action/spell/aoe/magic_missile/magic_missile

	var/next_cast = 0

	discovery_points = 3000

/mob/living/simple_animal/hostile/wizard/Initialize(mapload)
	. = ..()
	var/obj/item/implant/exile/exiled = new /obj/item/implant/exile(src)
	exiled.implant(src)

	fireball = new(src)
	fireball.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	fireball.Grant(src)

	magic_missile = new(src)
	magic_missile.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	magic_missile.Grant(src)

	blink = new(src)
	blink.spell_requirements &= ~(SPELL_REQUIRES_HUMAN|SPELL_REQUIRES_WIZARD_GARB|SPELL_REQUIRES_MIND)
	blink.outer_tele_radius = 3
	blink.Grant(src)

/mob/living/simple_animal/hostile/wizard/Destroy()
	QDEL_NULL(fireball)
	QDEL_NULL(magic_missile)
	QDEL_NULL(blink)
	return ..()

/mob/living/simple_animal/hostile/wizard/handle_automated_action()
	. = ..()
	if(target && next_cast < world.time)
		if((get_dir(src, target) in list(SOUTH, EAST, WEST, NORTH)) && fireball.can_cast_spell(feedback = FALSE))
			setDir(get_dir(src, target))
			fireball.pre_activate(src, target)
			next_cast = world.time + 1 SECONDS
			return

		if(magic_missile.is_available())
			magic_missile.pre_activate(src, target)
			next_cast = world.time + 1 SECONDS
			return

		if(blink.is_available()) // Spam Blink when you can
			blink.pre_activate(src, src)
			next_cast = world.time + 1 SECONDS
			return
