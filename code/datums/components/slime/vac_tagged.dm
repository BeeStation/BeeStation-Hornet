/datum/component/vac_tagged
	var/datum/weakref/creator

/datum/component/vac_tagged/Initialize(mob/creator_mob)
	. = ..()
	if(!creator_mob)
		return COMPONENT_INCOMPATIBLE

	creator = WEAKREF(creator_mob)

/datum/component/vac_tagged/Destroy(force, silent)
	UnregisterSignal(parent, list(COMSIG_MOB_FED_ON, COMSIG_QDELETING))
	. = ..()

/datum/component/vac_tagged/RegisterWithParent()
	. = ..()
	RegisterSignal(parent, COMSIG_MOB_FED_ON, PROC_REF(on_fed_on))
	RegisterSignal(parent, COMSIG_QDELETING, PROC_REF(on_deleting))

/datum/component/vac_tagged/proc/on_deleting()
	qdel(src)

/datum/component/vac_tagged/proc/on_fed_on(mob/living/source, mob/living/feeder, hunger_restored)
	SEND_SIGNAL(feeder, COMSIG_FRIENDSHIP_CHANGE, creator.resolve(), (hunger_restored * 0.1))
