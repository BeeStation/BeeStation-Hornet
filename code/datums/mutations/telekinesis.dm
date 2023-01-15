//Telekinesis lets you interact with objects from range, and gives you a light blue halo around your head.
/datum/mutation/telekinesis
	name = "Telekinesis"
	desc = "A strange mutation that allows the holder to interact with objects through thought."
	quality = POSITIVE
	difficulty = 18
	text_gain_indication = "<span class='notice'>You feel smarter!</span>"
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
