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
	desc = "The mutation enables the growth of Heat Pits in the eyes, not unlike those of a reptile, which can visually percieve the unique infrared thermal signature of living creatures."
	quality = POSITIVE
	difficulty = 18
	instability = 25
	locked = TRUE
	var/visionflag = TRAIT_THERMAL_VISION

/datum/mutation/thermal/on_acquiring(mob/living/carbon/owner)
	if(..())
		return

	ADD_TRAIT(owner, visionflag, GENETIC_MUTATION)
	owner.update_sight()

/datum/mutation/thermal/on_losing(mob/living/carbon/owner)
	if(..())
		return
	REMOVE_TRAIT(owner, visionflag, GENETIC_MUTATION)
	owner.update_sight()

//X-ray Vision lets you see through walls.
/datum/mutation/thermal/x_ray
	name = "X Ray Vision"
	desc = "A strange mutation that allows the user to see between the spaces of walls." //actual x-ray would mean you'd constantly be blasting rads, wich might be fun for later //hmb
	instability = 35
	locked = TRUE
	visionflag = TRAIT_XRAY_VISION

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
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "lasereyes", -FRONT_MUTATIONS_LAYER))

/datum/mutation/laser_eyes/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/laser_eyes/on_ranged_attack(atom/target, mouseparams)
	if(owner.a_intent == INTENT_HARM)
		owner.LaserEyes(target, mouseparams)
