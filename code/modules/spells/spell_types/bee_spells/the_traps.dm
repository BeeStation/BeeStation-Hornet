/datum/action/cooldown/spell/aoe/area_conversion/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	cooldown_time = 240 SECONDS
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC
	invocation = "CAVERE INSIDIAS"
	invocation_type = INVOCATION_SHOUT
	aoe_radius = 3
	var/summon_type = list(
		/obj/structure/trap/stun,
		/obj/structure/trap/fire,
		/obj/structure/trap/chill,
		/obj/structure/trap/damage
	)
	//summon_lifespan = 3000
	//summon_amt = 5
	button_icon_state = "the_traps"

/datum/action/cooldown/spell/aoe/area_conversion/the_traps/cast_on_thing_in_aoe(turf/victim, mob/caster)
	var/obj/structure/trap/T = pick(summon_type)
	T.New(victim.loc)
	T.immune_minds += caster.mind
	T.charges = 1
