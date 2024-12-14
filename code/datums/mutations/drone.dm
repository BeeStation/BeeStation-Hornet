//Diona species mutation
/datum/mutation/drone
	name = "Nymph Drone"
	desc = "An ancient mutation that gives diona the ability to send out a nymph drone."
	quality = POSITIVE
	difficulty = 12
	locked = TRUE
	power_path = /datum/action/spell/drone
	instability = 30
	energy_coeff = 1
	power_coeff = 1
	species_allowed = list(SPECIES_DIONA)

/datum/action/spell/drone
	name = "Release/Control Drone"
	desc = "A rare genome that allows the diona to evict a nymph from their gestalt and gain the ability to control them."
	school = "evocation"
	invocation = ""
	spell_requirements = null
	cooldown_time = 60 SECONDS
	invocation_type = INVOCATION_NONE
	button_icon_state = "control"
	mindbound = FALSE
	var/has_drone = FALSE //If the diona has a drone active or not, for their special mutation.
	var/datum/weakref/drone_ref

/datum/action/spell/drone/on_cast(mob/user, atom/target)
	. = ..()
	var/mob/living/carbon/human/C = user
	if(!isdiona(C))
		return
	CHECK_DNA_AND_SPECIES(C)
	var/datum/species/diona/S = C.dna.species
	if(has_drone)
		var/mob/living/simple_animal/hostile/retaliate/nymph/drone = drone_ref?.resolve()
		if(drone.stat == DEAD || QDELETED(drone))
			to_chat(C, "You can't seem to find the psychic link with your nymph.")
			has_drone = FALSE
		else
			to_chat(C, "Switching to nymph...")
			SwitchTo(C)
	else
		if(!do_after(C, 5 SECONDS, C, NONE, TRUE))
			return
		has_drone = TRUE
		var/mob/living/simple_animal/hostile/retaliate/nymph/nymph = new(C.loc)
		nymph.is_drone = TRUE
		nymph.drone_parent = C
		nymph.switch_ability = new
		nymph.switch_ability.Grant(nymph)
		drone_ref = WEAKREF(nymph)
		S.drone_ref = WEAKREF(nymph)

/datum/action/spell/drone/proc/SwitchTo(mob/living/carbon/M)
	var/mob/living/simple_animal/hostile/retaliate/nymph/drone = drone_ref?.resolve()
	if(!drone)
		return
	if(drone.stat == DEAD || QDELETED(drone)) //sanity check
		return
	var/datum/mind/C = M.mind
	if(M.stat == CONSCIOUS)
		M.visible_message("<span class='notice'>[M] \
			stops moving and starts staring vacantly into space.</span>",
			"<span class='notice'>You stop moving this form...</span>")
	else
		to_chat(C, "<span class='notice'>You abandon this nymph...</span>")
	C.transfer_to(drone)
	drone.mind = C
	drone.visible_message("<span class='notice'>[drone] blinks and looks \
		around.</span>",
		"<span class='notice'>...and move this one instead.</span>")
