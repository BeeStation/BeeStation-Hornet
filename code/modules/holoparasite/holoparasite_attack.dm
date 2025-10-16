/mob/living/simple_animal/hostile/holoparasite/Shoot(atom/targeted_atom)
	var/atom/target_from = GET_TARGETS_FROM(src)
	if(QDELETED(targeted_atom) || targeted_atom == target_from.loc || targeted_atom == target_from)
		return
	var/turf/start_loc = get_turf(target_from)
	var/obj/projectile/holoparasite/holopara_projectile = new(start_loc)
	playsound(src, projectilesound, vol = 75, vary = TRUE)
	holopara_projectile.add_atom_colour(accent_color, FIXED_COLOUR_PRIORITY)
	holopara_projectile.damage = stats.damage * 1.5
	holopara_projectile.armour_penetration = max(stats.potential - 1, 0) * 12.5
	holopara_projectile.starting = start_loc
	holopara_projectile.firer = src
	holopara_projectile.fired_from = src
	holopara_projectile.yo = targeted_atom.y - start_loc.y
	holopara_projectile.xo = targeted_atom.x - start_loc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, target_from))
	holopara_projectile.original = targeted_atom
	holopara_projectile.preparePixelProjectile(targeted_atom, src)
	holopara_projectile.fire()
	return holopara_projectile

/mob/living/simple_animal/hostile/holoparasite/UnarmedAttack(atom/target, proximity_flag, list/modifiers)
	if(!is_manifested() && combat_mode)
		to_chat(src, span_dangerbold("You must be manifested to interact with or attack things!"))
		return
	if(SEND_SIGNAL(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, target) & COMPONENT_HOSTILE_NO_ATTACK)
		return
	if(target == src)
		to_chat(src, span_dangerbold("You can't attack yourself!"))
		return
	if(dextrous && isitem(target))
		. = target.attack_hand(src)
		update_held_items()
	else
		if(combat_mode)
			if(LAZYACCESS(modifiers, RIGHT_CLICK))
				if(isliving(target))
					var/mob/living/living_target = target
					. = living_target.grabbedby(src)
				else
					. = target.attack_hand(src)
				update_held_items()
			else
				. = harm_attack(target)
		else
			. = target.attack_hand(src)
			update_held_items()

	SEND_SIGNAL(src, COMSIG_HOSTILE_POST_ATTACKINGTARGET, target)

/mob/living/simple_animal/hostile/holoparasite/proc/harm_attack(atom/target)
	if(melee_damage && has_matching_summoner(target))
		to_chat(src, span_dangerbold("That would harm your summoner!"))
		return FALSE
	. = target.attack_animal(src)
	if(. && isliving(target))
		if(length(battlecry))
			say("[battlecry]!!", language = /datum/language/metalanguage, ignore_spam = TRUE, forced = "holoparasite battlecry")
		playsound(src, attack_sound, vol = 45, vary = TRUE, extrarange = 1)
	stats.weapon.attack_effect(target, .)
