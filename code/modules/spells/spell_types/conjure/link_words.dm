/datum/action/cooldown/spell/conjure/link_worlds
	name = "Link Worlds"
	desc = "A whole new dimension for you to play with! They won't be happy about it, though."

	sound = 'sound/weapons/marauder.ogg'
	cooldown_time = 1 MINUTES
	cooldown_reduction_per_rank = 10 SECONDS

	invocation = "WTF"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = NONE

	summon_radius = 1
	summon_type = list(/obj/structure/spawner/nether)
	summon_amount = 1
