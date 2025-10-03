// Shoots out in a wave-like, what rust heretics themselves get
/datum/action/spell/cone/staggered/entropic_plume
	name = "Entropic Plume"
	desc = "Spews forth a disorienting plume that causes enemies to strike each other, \
		briefly blinds them (increasing with range) and poisons them (decreasing with range). \
		Also spreads rust in the path of the plume."
	background_icon_state = "bg_heretic"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "entropic_plume"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 30 SECONDS

	invocation = "'NTR'P'C PL'M'"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	cone_levels = 5
	respect_density = TRUE

/datum/action/spell/cone/staggered/entropic_plume/on_cast(mob/user, atom/target)
	. = ..()
	new /obj/effect/temp_visual/dir_setting/entropic(get_step(user, user.dir), user.dir)

/datum/action/spell/cone/staggered/entropic_plume/do_turf_cone_effect(turf/target_turf, atom/caster, level)
	target_turf.rust_heretic_act()

/datum/action/spell/cone/staggered/entropic_plume/do_mob_cone_effect(mob/living/victim, atom/caster, level)
	if(victim.can_block_magic(MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) || IS_HERETIC_OR_MONSTER(victim) || victim == caster)
		return
	victim.apply_status_effect(/datum/status_effect/amok)
	victim.apply_status_effect(/datum/status_effect/cloudstruck, (level * 1 SECONDS))
	if(iscarbon(victim))
		var/mob/living/carbon/carbon_victim = victim
		carbon_victim.reagents?.add_reagent(/datum/reagent/eldritch, min(1, 6 - level))

/datum/action/spell/cone/staggered/entropic_plume/calculate_cone_shape(current_level)
	// At the first level (that isn't level 1) we will be small
	if(current_level == 2)
		return 3
	// At the max level, we turn small again
	if(current_level == cone_levels)
		return 3
	// Otherwise, all levels in between will be wider
	return 5

/obj/effect/temp_visual/dir_setting/entropic
	icon = 'icons/effects/160x160.dmi'
	icon_state = "entropic_plume"
	duration = 3 SECONDS
/obj/effect/temp_visual/dir_setting/entropic/setDir(dir)
	. = ..()
	switch(dir)
		if(NORTH)
			pixel_x = -64
		if(SOUTH)
			pixel_x = -64
			pixel_y = -128
		if(EAST)
			pixel_y = -64
		if(WEST)
			pixel_y = -64
			pixel_x = -128

// Shoots a straight line of rusty stuff ahead of the caster, what rust monsters get
/datum/action/spell/basic_projectile/rust_wave
	name = "Patron's Reach"
	desc = "Channels energy into your hands to release a wave of rust."
	background_icon_state = "bg_heretic"
	icon_icon = 'icons/hud/actions/actions_ecult.dmi'
	button_icon_state = "rust_wave"

	school = SCHOOL_FORBIDDEN
	cooldown_time = 35 SECONDS

	invocation = "SPR'D TH' WO'D"
	invocation_type = INVOCATION_WHISPER
	spell_requirements = NONE

	projectile_type = /obj/projectile/magic/aoe/rust_wave

/obj/projectile/magic/aoe/rust_wave
	name = "Patron's Reach"
	icon_state = "eldritch_projectile"
	alpha = 180
	damage = 30
	damage_type = TOX
	hitsound = 'sound/weapons/punch3.ogg'
	trigger_range = 0
	//ignored_factions = list(FACTION_HERETIC) I am not touching projectile code with a ten metre pole
	range = 15
	speed = 1

/obj/projectile/magic/aoe/rust_wave/Moved(atom/OldLoc, Dir)
	. = ..()
	playsound(src, 'sound/items/welder.ogg', 75, TRUE)
	var/list/turflist = list()
	var/turf/T1
	turflist += get_turf(src)
	T1 = get_step(src,turn(dir,90))
	turflist += T1
	turflist += get_step(T1,turn(dir,90))
	T1 = get_step(src,turn(dir,-90))
	turflist += T1
	turflist += get_step(T1,turn(dir,-90))
	for(var/X in turflist)
		if(!X || prob(25))
			continue
		var/turf/T = X
		T.rust_heretic_act()

/datum/action/spell/basic_projectile/rust_wave/short
	name = "Lesser Patron's Reach"
	projectile_type = /obj/projectile/magic/aoe/rust_wave/short

/obj/projectile/magic/aoe/rust_wave/short
	range = 7
	speed = 2
