/datum/mutation/void
	name = "Void Magnet"
	desc = "A rare genome that attracts odd forces not usually observed."
	quality = MINOR_NEGATIVE //upsides and downsides
	instability = 30
	power_path = /datum/action/spell/void
	energy_coeff = 1
	synchronizer_coeff = 1

/datum/mutation/void/on_life(delta_time, times_fired)
	// Move this onto the spell itself at some point?
	var/datum/action/spell/void/curse = locate(power_path) in owner
	if(!curse)
		remove()
		return

	if(!curse.is_valid_spell(owner, null))
		return

	//very rare, but enough to annoy you hopefully. + 0.5 probability for every 10 points lost in stability
	if(DT_PROB((0.25 + ((100 - dna.stability) / 40)) * GET_MUTATION_SYNCHRONIZER(src), delta_time))
		curse.on_cast(owner, null)

/datum/action/spell/void
	name = "Convoke Void" //magic the gathering joke here
	desc = "A rare genome that attracts odd forces not usually observed. May sometimes pull you in randomly."
	button_icon_state = "void_magnet"
	mindbound = FALSE
	school = SCHOOL_EVOCATION
	cooldown_time = 1 MINUTES

	invocation = "DOOOOOOOOOOOOOOOOOOOOM!!!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE
	antimagic_flags = NONE

/datum/action/spell/void/is_valid_spell(mob/user, atom/target)
	return isturf(user.loc)

/datum/action/spell/void/on_cast(mob/user, atom/target)
	. = ..()
	new /obj/effect/immortality_talisman/void(get_turf(user), user)
