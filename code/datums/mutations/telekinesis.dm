//Telekinesis lets you interact with objects from range, and gives you a light blue halo around your head.
/datum/mutation/telekinesis
	name = "Telekinesis"
	desc = "A strange mutation that allows the holder to interact with objects purely through thought."
	quality = POSITIVE
	difficulty = 18
	limb_req = BODY_ZONE_HEAD
	instability = 30

/datum/mutation/telekinesis/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "telekinesishead", -MUTATIONS_LAYER))

/datum/mutation/telekinesis/get_visual_indicator()
	return visual_indicators[type][1]

/datum/mutation/telekinesis/on_ranged_attack(atom/target)
	target.attack_tk(owner)

//A weaker version used for the psyphoza species
/datum/mutation/telekinesis/weak
	name = "Natural Telekinesis"
	desc = "A strange mutation that allows the holder to weakly interact with objects through thought."

/datum/mutation/telekinesis/weak/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	//Clear visual indicators for custom effect
	visual_indicators[type] = list()

/datum/mutation/telekinesis/weak/on_acquiring(mob/living/carbon/C)
	. = ..()
	owner.filters += filter(type = "outline", size = 1, color = "#ff00f7")
	animate(owner.filters[owner.filters.len], color = "#ffbae5", size = 1.25, loop = -1, time = 1 SECONDS, flags = ANIMATION_PARALLEL)
	animate(color = "#ff00f7", size = 1, time = 1 SECONDS)

/datum/mutation/telekinesis/weak/get_visual_indicator()
	return

/datum/mutation/telekinesis/weak/on_ranged_attack(atom/target)
	target.attack_tk(owner, TRUE)
