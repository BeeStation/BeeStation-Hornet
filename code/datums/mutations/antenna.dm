/datum/mutation/antenna
	name = "Antenna"
	desc = "The affected person sprouts an antenna. This is known to allow them to access common radio channels passively."
	quality = POSITIVE
	instability = 5
	difficulty = 8
	var/datum/weakref/radio_weakref

/obj/item/implant/radio/antenna
	name = "internal antenna organ"
	desc = "The internal organ part of the antenna. Science has not yet given it a good name."
	icon = 'icons/obj/radio.dmi'//maybe make a unique sprite later. not important
	icon_state = "walkietalkie"

/obj/item/implant/radio/antenna/Initialize(mapload)
	..()
	radio.name = "internal antenna"

/datum/mutation/antenna/on_acquiring(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = new(owner)
	linked_radio.implant(owner, null, TRUE, TRUE)
	radio_weakref = WEAKREF(linked_radio)

/datum/mutation/antenna/on_losing(mob/living/carbon/owner)
	if(..())
		return
	var/obj/item/implant/radio/antenna/linked_radio = radio_weakref.resolve()
	if(linked_radio)
		QDEL_NULL(linked_radio)

/datum/mutation/antenna/New(class_ = MUT_OTHER, timer, datum/mutation/copymut)
	..()
	if(!(type in visual_indicators))
		visual_indicators[type] = list(mutable_appearance('icons/effects/genetics.dmi', "antenna", -FRONT_MUTATIONS_LAYER+1))//-MUTATIONS_LAYER+1

/datum/mutation/antenna/get_visual_indicator()
	return visual_indicators[type][1]
