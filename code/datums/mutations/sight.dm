//Nearsightedness restricts your vision by several tiles.
/datum/mutation/nearsight
	name = "Near Sightness"
	desc = "A hereditary mutation causing Myopia and poor vision."
	quality = MINOR_NEGATIVE

/datum/mutation/nearsight/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.become_nearsighted(GENETIC_MUTATION)

/datum/mutation/nearsight/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.cure_nearsighted(GENETIC_MUTATION)


//Blind makes you blind. Who knew?
/datum/mutation/blind
	name = "Blindness"
	desc = "A hereditary mutation which renders the optic nerves of the individual inert, making them effectively blind. No amount of corrective surgery can fix this."
	quality = NEGATIVE

/datum/mutation/blind/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	owner.become_blind(GENETIC_MUTATION)

/datum/mutation/blind/on_losing(mob/living/carbon/owner)
	if(..())
		return
	owner.cure_blind(GENETIC_MUTATION)


/datum/mutation/thermal
	name = "Thermal Vision"
	desc = "The mutation enables the growth of Heat Pits in the eyes, not unlike those of a reptile, which can visually perceive the unique infrared thermal signature of living creatures."
	quality = POSITIVE
	difficulty = 18
	instability = 25
	locked = TRUE
	traits = TRAIT_THERMAL_VISION
	power_path = /datum/action/spell/thermal_vision

/datum/mutation/human/thermal/on_losing(mob/living/carbon/human/owner)
	if(..())
		return

	// Something went wront and we still have the thermal vision from our power, no cheating.
	if(HAS_TRAIT_FROM(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		REMOVE_TRAIT(owner, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
		owner.update_sight()


/datum/mutation/human/thermal/modify()
	. = ..()
	var/datum/action/spell/thermal_vision/to_modify = .
	if(!istype(to_modify)) // null or invalid
		return

	to_modify.eye_damage = 10 * GET_MUTATION_SYNCHRONIZER(src)
	to_modify.thermal_duration = 10 * GET_MUTATION_POWER(src)


/datum/action/spell/thermal_vision
	name = "Activate Thermal Vision"
	desc = "You can see thermal signatures, at the cost of your eyesight."
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = "augmented_eyesight"
	toggleable = TRUE

	cooldown_time = 25 SECONDS
	spell_requirements = NONE
	mindbound = FALSE
	/// How much eye damage is given on cast
	var/eye_damage = 10
	/// The duration of the thermal vision
	var/thermal_duration = 10 SECONDS

/datum/action/spell/thermal_vision/Remove(mob/living/remove_from)
	REMOVE_TRAIT(remove_from, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	remove_from.update_sight()
	return ..()

/datum/action/spell/thermal_vision/is_valid_spell(mob/user, atom/target)
	return isliving(user) && !HAS_TRAIT(user, TRAIT_THERMAL_VISION)

/datum/action/spell/thermal_vision/on_cast(mob/living/user, atom/target)
	. = ..()
	ADD_TRAIT(user, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	user.update_sight()
	to_chat(user, ("<span class='info'>You focus your eyes intensely, as your vision becomes filled with heat signatures.</span>"))
	addtimer(CALLBACK(src, PROC_REF(deactivate)), thermal_duration)

/datum/action/spell/thermal_vision/on_deactivate(mob/user, mob/cast_on)
	if(QDELETED(cast_on) || !HAS_TRAIT_FROM(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION))
		return

	REMOVE_TRAIT(cast_on, TRAIT_THERMAL_VISION, GENETIC_MUTATION)
	cast_on.update_sight()
	to_chat(cast_on, ("<span class='info'>You blink a few times, your vision returning to normal as a dull pain settles in your eyes.</span>"))

	if(iscarbon(cast_on))
		var/mob/living/carbon/carbon_cast_on = cast_on
		carbon_cast_on.adjustOrganLoss(ORGAN_SLOT_EYES, eye_damage)


//X-ray Vision lets you see through walls.
/datum/mutation/thermal/x_ray
	name = "X Ray Vision"
	desc = "A strange mutation that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	instability = 35
	locked = TRUE
	traits = TRAIT_XRAY_VISION

//Laser Eyes lets you shoot lasers from your eyes!
/datum/mutation/laser_eyes
	name = "Laser Eyes"
	desc = "A mutation that allows for the reflection of concentrated light from the back of the eyes."
	quality = POSITIVE
	locked = TRUE
	difficulty = 16
	layer_used = FRONT_MUTATIONS_LAYER
	limb_req = BODY_ZONE_HEAD

/datum/mutation/laser_eyes/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "lasereyes"))

/datum/mutation/laser_eyes/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/laser_eyes/on_ranged_attack(mob/living/carbon/human/source, atom/target, modifiers)
	if(owner.combat_mode)
		owner.LaserEyes(target, modifiers)
