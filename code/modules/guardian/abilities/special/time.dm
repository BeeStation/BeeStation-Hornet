/datum/guardian_ability/major/special/timestop
	name = "Time Stop"
	desc = "The guardian can stop time in a localized area."
	cost = 5
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian

/datum/guardian_ability/major/special/timestop/Berserk()
	guardian.RemoveSpell(spell)
	spell = new /obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian/berserk
	guardian.AddSpell(spell)

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian
	invocation_type = "none"
	clothes_req = FALSE
	staff_req = FALSE
	summon_type = list(/obj/effect/timestop)

/obj/effect/proc_holder/spell/aoe_turf/conjure/timestop/guardian/berserk
	summon_type = list(/obj/effect/timestop/wizard/lag_stone)
