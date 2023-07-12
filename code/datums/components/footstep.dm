/datum/component/footstep
	var/steps = 0
	var/volume
	var/e_range

/datum/component/footstep/Initialize(volume_ = 0.5, e_range_ = -1)
	if(!isliving(parent))
		return COMPONENT_INCOMPATIBLE
	volume = volume_
	e_range = e_range_
	RegisterSignal(parent, list(COMSIG_MOVABLE_MOVED), PROC_REF(play_footstep))

/datum/component/footstep/proc/play_footstep(mob/living/source)
	var/turf/open/T = get_turf(source)
	if(!istype(T))
		return

	var/v = volume
	var/e = e_range
	if(!T.footstep || source.buckled || source.throwing || source.movement_type & (VENTCRAWLING | FLYING) || HAS_TRAIT(source, TRAIT_IMMOBILIZED))
		return

	if(source.body_position == LYING_DOWN) //play crawling sound if we're lying
		playsound(T, 'sound/effects/footstep/crawl1.ogg', 15 * volume)
		return

	if(iscarbon(source))
		var/mob/living/carbon/carbon_source = source
		if(!carbon_source.get_bodypart(BODY_ZONE_L_LEG) && !carbon_source.get_bodypart(BODY_ZONE_R_LEG))
			return
		if(carbon_source.m_intent == MOVE_INTENT_WALK)
			return // stealth
	steps++

	if(steps >= 6)
		steps = 0

	if(steps % 2)
		return

	if(!source.has_gravity(T) && steps != 0) // don't need to step as often when you hop around
		return

	//begin playsound shenanigans//

	//for barefooted non-clawed mobs like monkeys
	if(isbarefoot(source))
		playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
			GLOB.barefootstep[T.barefootstep][2] * v,
			TRUE,
			GLOB.barefootstep[T.barefootstep][3] + e)
		return

	//for xenomorphs, dogs, and other clawed mobs
	if(isclawfoot(source))
		if(isalienadult(source)) //xenos are stealthy and get quieter footsteps
			v /= 2
			e -= 5

		playsound(T, pick(GLOB.clawfootstep[T.clawfootstep][1]),
				GLOB.clawfootstep[T.clawfootstep][2] * v,
				TRUE,
				GLOB.clawfootstep[T.clawfootstep][3] + e)
		return

	//for megafauna and other large and imtimidating mobs such as the bloodminer
	if(isheavyfoot(source))
		playsound(T, pick(GLOB.heavyfootstep[T.heavyfootstep][1]),
				GLOB.heavyfootstep[T.heavyfootstep][2] * v,
				TRUE,
				GLOB.heavyfootstep[T.heavyfootstep][3] + e)
		return

	//for slimes
	if(isslime(source))
		playsound(T, 'sound/effects/footstep/slime1.ogg', 15 * v)
		return

	//for (simple) humanoid mobs (clowns, russians, pirates, etc.)
	if(isshoefoot(source))
		if(!ishuman(source))
			playsound(T, pick(GLOB.footstep[T.footstep][1]),
				GLOB.footstep[T.footstep][2] * v,
				TRUE,
				GLOB.footstep[T.footstep][3] + e)
			return
		if(ishuman(source)) //for proper humans, they're special
			var/mob/living/carbon/human/H = source
			var/feetCover = (H.wear_suit && (H.wear_suit.body_parts_covered & FEET)) || (H.w_uniform && (H.w_uniform.body_parts_covered & FEET))

			if(H.shoes || feetCover) //are we wearing shoes
				playsound(T, pick(GLOB.footstep[T.footstep][1]),
					GLOB.footstep[T.footstep][2] * v,
					TRUE,
					GLOB.footstep[T.footstep][3] + e)

			//Sound of wearing shoes always plays, special movement sound
			// IE (server motors wont play bare footed.)
			if(H.dna.species.special_step_sounds)
				playsound(T, pick(H.dna.species.special_step_sounds), 50, TRUE)

			else if((!H.shoes && !feetCover)) //are we NOT wearing shoes
				playsound(T, pick(GLOB.barefootstep[T.barefootstep][1]),
					GLOB.barefootstep[T.barefootstep][2] * v,
					TRUE,
					GLOB.barefootstep[T.barefootstep][3] + e)
