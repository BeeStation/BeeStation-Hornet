/**
 * A Brujah exclusive ability that acts as an enhanced version of "Brawn"
 * 'bloodcost' and 'cooldown_time' vary depending on what the power is used for.
 * Lots of code has been copied over from Brawn wherever inheritance might prove insufficient.
 * Comments from copied code have been removed (they can still be found in their original location.)
**/

/datum/action/vampire/targeted/brawn/brash
	name = "Brash"
	desc = "Break most structures apart with overwhelming force. Cooldown and cost vary depending on the object broken."
	button_icon_state = "power_strength_brujah"
	power_explanation = "This is an enhanced version of the regular 'Brawn' ability.\n\
		Use on a person to send them flying. Use while restrained, grabbed, or trapped in a locker to break free.\n\
		Punching a cyborg will temporarily disable it in addition to usual damage. \n\
		At level 2 this ability will allow you to break through unbolted airlocks. \n\
		At level 3 this ability will allow you to break through bolted airlocks. \n\
		At level 4 this ability will allow you to break through normal walls and windows. \n\
		At level 5 this ability will allow you to break through reinforced walls and windows. \n\
		Higher levels will increase this ability's damage and knockdown."
	purchase_flags = BRUJAH_DEFAULT_POWER
	power_flags = BP_AM_VERY_DYNAMIC_COOLDOWN
	bloodcost = 0 // Set on use
	cooldown_time = 1 SECONDS // Same as above
	damage_coefficient = 1.625
	brujah = TRUE

/// Hit an atom, set bloodcost, set cooldown time, play a sound, and deconstruct the atom
/// with this one convenient proc!
/datum/action/vampire/targeted/brawn/brash/proc/hit_with_style(atom/target_atom, sound, vol as num, cost as num, cooldown)
	if(!isobj(target_atom))
		return

	var/obj/target_obj = target_atom
	owner.do_attack_animation(target_obj)
	bloodcost = cost
	cooldown_time = cooldown
	playsound(target_atom, sound, 75, TRUE)
	target_obj.deconstruct(FALSE)

/datum/action/vampire/targeted/brawn/brash/FireTargetedPower(atom/target_atom)
	. = ..()
	// People
	if(isliving(target_atom))
		bloodcost = 25
		cooldown_time = 10 SECONDS
		return

	// Closets
	if(istype(target_atom, /obj/structure/closet))
		bloodcost = 8
		cooldown_time = 7 SECONDS
		return

	// Girders
	if(istype(target_atom, /obj/structure/girder))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 60, 10, 5 SECONDS)
		return

	// Grilles
	if(istype(target_atom, /obj/structure/grille))
		hit_with_style(target_atom, 'sound/effects/grillehit.ogg', 50, 1, 0.5 SECONDS)
		return

	// Windows
	if(istype(target_atom, /obj/structure/window))
		var/obj/structure/window/window = target_atom
		if(istype(target_atom, /obj/structure/window/reinforced) && level_current < 5)
			window.balloon_alert(owner, "level 5 required!")
			return
		else if(level_current < 4)
			window.balloon_alert(owner, "level 4 required!")
			return

		if(istype(window, /obj/structure/window/reinforced) || istype(window, /obj/structure/window/plasma))
			hit_with_style(window, 'sound/effects/bang.ogg', 30, 25, 15 SECONDS)
		else
			hit_with_style(window, 'sound/effects/bang.ogg', 20, 15, 10 SECONDS)
		return

	// Windoors
	if(istype(target_atom, /obj/machinery/door/window))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 50, 10, 5 SECONDS)
		return

	// Tables
	if(istype(target_atom, /obj/structure/table))
		hit_with_style(target_atom, 'sound/effects/bang.ogg', 35, 10, 5 SECONDS)
		return

	// Walls
	if(iswallturf(target_atom))
		if(isindestructiblewall(target_atom))
			target_atom.balloon_alert(owner, "this wall is indestructible!")
			return

		if(istype(target_atom, /turf/closed/wall/r_wall) && level_current < 5)
			target_atom.balloon_alert(owner, "level 5 required!")
			return
		else if(level_current < 4)
			target_atom.balloon_alert(owner, "level 4 required!")
			return

		rip_and_tear(owner, target_atom)

/// Copied over from '/datum/element/wall_tearer/proc/rip_and_tear' with appropriate adjustment.
/datum/action/vampire/targeted/brawn/brash/proc/rip_and_tear(mob/living/tearer, atom/target)
	var/tear_time = 0.75 SECONDS
	var/reinforced_multiplier = 5
	var/rip_time = (istype(target, /turf/closed/wall/r_wall) ? tear_time * reinforced_multiplier : tear_time)

	if(istype(target, /turf/closed/wall/r_wall))
		bloodcost = 40
		cooldown_time = 20 SECONDS
	else
		bloodcost = 20
		cooldown_time = 15 SECONDS

	while(istype(target, /turf/closed/wall))
		var/turf/closed/wall/wall = target

		tearer.visible_message(span_warning("[tearer] viciously rips into [wall]!"))
		playsound(tearer, 'sound/machines/airlock_alien_prying.ogg', vol = 50, vary = TRUE, frequency = 2)
		wall.balloon_alert(tearer, "tearing...")

		if(do_after(tearer, delay = rip_time, target = wall, interaction_key = "vampire interaction"))
			playsound(tearer, 'sound/effects/meteorimpact.ogg', 100, TRUE)
			tearer.do_attack_animation(wall)
			wall.dismantle_wall(1)
			return
		else
			tearer.balloon_alert(tearer, "interrupted!")

/// TODO: check if switch statements work with istype()
/datum/action/vampire/targeted/brawn/brash/check_valid_target(atom/target_atom)
	. = ..()
	if(!.)
		return FALSE

	if(INDESTRUCTIBLE in target_atom.resistance_flags)
		return FALSE
	if(isliving(target_atom))
		return TRUE
	if(istype(target_atom, /obj/machinery/door/airlock))
		return TRUE
	if(istype(target_atom, /obj/structure/table))
		return TRUE
	if(istype(target_atom, /obj/structure/closet))
		return TRUE
	if(istype(target_atom, /obj/structure/girder))
		return TRUE
	if(istype(target_atom, /obj/structure/grille))
		return TRUE
	if(istype(target_atom, /obj/structure/window))
		return TRUE
	if(iswallturf(target_atom))
		return TRUE

	return FALSE
