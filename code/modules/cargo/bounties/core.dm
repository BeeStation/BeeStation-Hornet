/datum/bounty/item/core/New()
	..()
	description = "The admiral heard that a [name] core help you grow your beard, fetch a [name] core immediately! Ship it to receive a large payment."
	required_count = 1

/datum/bounty/item/core/mark_high_priority(scale_reward)
	return ..(max(scale_reward * 0.7, 1.2))

/datum/bounty/item/core/bleed
	name = "Bleed"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/blood)

/datum/bounty/item/core/bluespace
	name = "Bluespace"
	reward = 45000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bluespace)

/datum/bounty/item/core/delimber
	name = "Delimber"
	reward = 30000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bioscrambler)

/datum/bounty/item/core/flux
	name = "Flux"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flux)

/datum/bounty/item/core/pyro
	name = "Pyro"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/pyro)

/datum/bounty/item/core/vortex
	name = "Vortex"
	reward = 50000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/vortex)

/datum/bounty/item/core/gravity
	name = "Gravity"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/grav)

/datum/bounty/item/core/hallucination
	name = "Hallucination"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/hallucination)
