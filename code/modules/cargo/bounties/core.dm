/datum/bounty/item/core/New()
	..()
	description = "The admiral heard that a [name] could help you grow your beard, fetch a [name] immediately! Ship it to receive a large payment."
	required_count = 1

/datum/bounty/item/core/mark_high_priority(scale_reward)
	return ..(max(scale_reward * 0.7, 1.2))

/datum/bounty/item/core/bleed
	name = "Blood Anomaly Core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/blood)

/datum/bounty/item/core/bluespace
	name = "Bluespace Anomaly Core"
	reward = 45000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bluespace)

/datum/bounty/item/core/delimber
	name = "Bioscrambler Anomaly Core"
	reward = 30000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bioscrambler)

/datum/bounty/item/core/flux
	name = "Flux Anomaly Core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flux)

/datum/bounty/item/core/pyro
	name = "Pyroclastic Anomaly Core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/pyro)

/datum/bounty/item/core/vortex
	name = "Vortex Anomaly Core"
	reward = 50000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/vortex)

/datum/bounty/item/core/gravity
	name = "Gravitational Anomaly Core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/grav)

/datum/bounty/item/core/hallucination
	name = "Hallucination Anomaly Core"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/hallucination)
