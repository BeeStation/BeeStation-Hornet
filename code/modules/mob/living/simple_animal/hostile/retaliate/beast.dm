/mob/living/simple_animal/hostile/retaliate/beast
	name = "Wolf-like beast"
	desc = "Some sinister monstrosity of a primal, feral nature. It's piercing gaze is enough to send shivers down your spine."
	icon = 'icons/vampires/beastform.dmi'
	icon_state = "beast"
	icon_living = "beast"
	icon_dead = "beast_dead"
	icon_gib = "beast_dead"
	speak = list("RAWR!","Rawr!","GRR!","Growl!")
	speak_emote = list("growls", "roars")
	speak_language = /datum/language/metalanguage
	emote_hear = list("rawrs.","grumbles.","grawls.")
	emote_taunt = list("stares ferociously", "stomps")
	speak_chance = 1
	taunt_chance = 25
	turns_per_move = 1
	see_in_dark = 10
	butcher_results = list(/obj/item/food/meat/slab = 5)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	armour_penetration = 60
	mob_biotypes = MOB_ORGANIC | MOB_BEAST
	maxHealth = 200
	health = 200
	spacewalk = FALSE
	melee_damage = 30
	attack_verb_continuous = "slashes"
	attack_verb_simple = "slash"
	faction = list(FACTION_HOSTILE)
	attack_sound = 'sound/weapons/bladeslice.ogg'
	obj_damage = 60
	environment_smash = ENVIRONMENT_SMASH_WALLS
	mob_size = MOB_SIZE_LARGE
	footstep_type = FOOTSTEP_MOB_CLAW
	speed = -1

// Gorillas like to dismember limbs from unconscious mobs.
// Returns null when the target is not an unconscious carbon mob; a list of limbs (possibly empty) otherwise.
/mob/living/simple_animal/hostile/retaliate/beast/proc/target_bodyparts(atom/the_target)
	var/list/parts = list()
	if(iscarbon(the_target))
		var/mob/living/carbon/C = the_target
		if(C.stat >= UNCONSCIOUS)
			for(var/X in C.bodyparts)
				var/obj/item/bodypart/BP = X
				if(BP.body_part != HEAD && BP.body_part != CHEST)
					if(BP.dismemberable)
						parts += BP
			return parts

/mob/living/simple_animal/hostile/retaliate/beast/AttackingTarget()
	if(client)
		if(prob(20))
			playsound(loc, 'sound/vampires/growl.ogg', 70, TRUE)
	var/list/parts = target_bodyparts(target)
	if(parts)
		if(!parts.len)
			return FALSE
		var/obj/item/bodypart/BP = pick(parts)
		BP.dismember()
		return ..()
	. = ..()
	if(. && isliving(target))
		playsound(loc, 'sound/vampires/bloodhealing.ogg', 30)
		add_splatter_floor(get_turf(target))
		health = health + 50

/mob/living/simple_animal/hostile/retaliate/beast/CanAttack(atom/the_target)
	var/list/parts = target_bodyparts(target)
	return ..() && !istype(the_target, /mob/living/carbon/monkey) && (!parts  || parts.len > 3)

/mob/living/simple_animal/hostile/retaliate/beast/death()
	. = ..()
	playsound(loc, 'sound/vampires/awo1.ogg', 15)
