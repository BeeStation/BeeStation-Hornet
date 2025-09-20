
// If you add a core here make sure it has a normal export price aswell (code\modules\cargo\exports\core.dm).

/datum/bounty/item/core/New()
	..()
	description = "The admiral heard that a [name] could help you grow your beard, fetch a [name] immediately! Ship it to receive a large payment."
	required_count = 1

/datum/bounty/item/core/mark_high_priority(scale_reward)
	return ..(max(scale_reward * 0.7, 1.2))

/datum/bounty/item/core/bleed
	name = "blood anomaly core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/blood)

/datum/bounty/item/core/flesh
	name = "flesh anomaly core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flesh)

/datum/bounty/item/core/bluespace
	name = "bluespace anomaly core"
	reward = 45000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bluespace)

/datum/bounty/item/core/bioscrambler
	name = "bioscrambler anomaly core"
	reward = 30000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/bioscrambler)

/datum/bounty/item/core/flux
	name = "flux anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/flux)

/datum/bounty/item/core/exo
	name = "exothermic anomaly core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/exo)

/datum/bounty/item/core/endo
	name = "endothermic anomaly core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/endo)

/datum/bounty/item/core/vortex
	name = "vortex anomaly core"
	reward = 50000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/vortex)

/datum/bounty/item/core/tech
	name = "tech anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/tech)

/datum/bounty/item/core/gravity
	name = "gravitational anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/grav)

/datum/bounty/item/core/hallucination
	name = "hallucination anomaly core"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/hallucination)

/datum/bounty/item/core/glitch
	name = "glitch anomaly core"
	reward = 49999
	wanted_types = list(/obj/item/assembly/signaler/anomaly/glitch)

/datum/bounty/item/core/moth
	name = "moth anomaly core"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/moth)

/datum/bounty/item/core/cheese
	name = "cheese anomaly core"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/cheese)

/datum/bounty/item/core/monkey
	name = "monkey anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/monkey)

/datum/bounty/item/core/carp
	name = "carp anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/carp)

/datum/bounty/item/core/lock
	name = "lock anomaly core"
	reward = 15000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/lock)

/datum/bounty/item/core/mime
	name = "mime anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/mime)

/datum/bounty/item/core/clown
	name = "clown anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/clown)

/datum/bounty/item/core/nuclear
	name = "nuclear anomaly core"
	reward = 25000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/nuclear)

/datum/bounty/item/core/trap
	name = "beartrap anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/trap)

/datum/bounty/item/core/babel
	name = "babel anomaly core"
	reward = 20000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/babel)

/datum/bounty/item/core/greed
	name = "greed anomaly core"
	reward = 30000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/greed)

/datum/bounty/item/core/omni
	name = "omni anomaly core"
	reward = 60000
	wanted_types = list(/obj/item/assembly/signaler/anomaly/omni)
