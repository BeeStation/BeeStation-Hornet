/**
 * Caltrop element; for hurting people when they walk over this.
 *
 * Used for broken glass, cactuses and four sided dice.
 */
/datum/component/caltrop
	///Minimum damage done when crossed
	var/min_damage

	///Maximum damage done when crossed
	var/max_damage

	///Probability of actually "firing", stunning and doing damage
	var/probability

	///Miscelanous caltrop flags; shoe bypassing, walking interaction, silence
	var/flags

	///The sound that plays when a caltrop is triggered.
	var/soundfile

	///given to connect_loc to listen for something moving over target
	var/static/list/crossed_connections = list(
		COMSIG_ATOM_ENTERED = .proc/on_entered,
	)

	///So we can update ant damage
	dupe_mode = COMPONENT_DUPE_UNIQUE_PASSARGS

/datum/component/caltrop/Initialize(min_damage = 0, max_damage = 0, probability = 100, flags = NONE, soundfile = null)
	. = ..()
	if(!isatom(parent))
		return COMPONENT_INCOMPATIBLE

	src.min_damage = min_damage
	src.max_damage = max(min_damage, max_damage)
	src.probability = probability
	src.flags = flags
	src.soundfile = soundfile

	if(ismovable(parent))
		AddComponent(/datum/component/connect_loc_behalf, parent, crossed_connections)
	else
		RegisterSignal(get_turf(parent), COMSIG_ATOM_ENTERED, .proc/on_entered)

// Inherit the new values passed to the component
/datum/component/caltrop/InheritComponent(datum/component/caltrop/new_comp, original, min_damage, max_damage, probability, flags, soundfile)
	if(!original)
		return
	if(min_damage)
		src.min_damage = min_damage
	if(max_damage)
		src.max_damage = max_damage
	if(probability)
		src.probability = probability
	if(flags)
		src.flags = flags
	if(soundfile)
		src.soundfile = soundfile

/datum/component/caltrop/proc/on_entered(datum/source, atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	SIGNAL_HANDLER

	if(!prob(probability))
		return

	if(!ishuman(arrived))
		return

	var/mob/living/carbon/human/Human = arrived
	if(HAS_TRAIT(Human, TRAIT_PIERCEIMMUNE))
		return

	if((flags & CALTROP_IGNORE_WALKERS) && Human.m_intent == MOVE_INTENT_WALK)
		return

	if(Human.movement_type & (FLOATING|FLYING)) //check if they are able to pass over us
		//gravity checking only our parent would prevent us from triggering they're using magboots / other gravity assisting items that would cause them to still touch us.
		return

	if(Human.buckled) //if they're buckled to something, that something should be checked instead.
		return

	if(!(Human.mobility_flags & MOBILITY_STAND)) //if were not standing we cant step on the caltrop
		return

	var/picked_def_zone = pick(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)
	var/obj/item/bodypart/BodyPart = Human.get_bodypart(picked_def_zone)
	if(!istype(BodyPart))
		return

	if(!IS_ORGANIC_LIMB(BodyPart))
		return

	if (!(flags & CALTROP_BYPASS_SHOES))
		if ((Human.wear_suit?.body_parts_covered | Human.w_uniform?.body_parts_covered | Human.shoes?.body_parts_covered) & FEET)
			return

	var/damage = rand(min_damage, max_damage)
	if(HAS_TRAIT(Human, TRAIT_LIGHT_STEP))
		damage *= 0.5


	if(!(flags & CALTROP_SILENT) && !Human.has_status_effect(/datum/status_effect/caltropped))
		Human.apply_status_effect(/datum/status_effect/caltropped)
		Human.visible_message(
			span_danger("[Human] steps on [parent]."),
			span_userdanger("You step on [parent]!")
		)

	Human.apply_damage(damage, BRUTE, picked_def_zone)

	if(!(flags & CALTROP_NOSTUN)) // Won't set off the paralysis.
		Human.Paralyze(50)

	if(!soundfile)
		return
	playsound(Human, soundfile, 15, TRUE, -3)

/datum/component/caltrop/UnregisterFromParent()
	if(ismovable(parent))
		qdel(GetComponent(/datum/component/connect_loc_behalf))
