/datum/action/spell/shapeshift/wizard
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. \
		Once you've made your choice, it cannot be changed."

	cooldown_time = 20 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS

	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/basic/pet/dog/corgi,
		/mob/living/simple_animal/hostile/carp/ranged/chaos,
		/mob/living/simple_animal/bot/ed209,
		/mob/living/simple_animal/hostile/poison/giant_spider,
		/mob/living/simple_animal/hostile/construct/juggernaut/mystic,
	)

/datum/action/spell/shapeshift/magician
	name = "Magician's Shapechange"
	desc = "Transform into a different creature, gaining its abilities and appearance. \
		Once you have made your choice, it cannot be changed."

	cooldown_time = 60 SECONDS
	cooldown_reduction_per_rank = 9.5 SECONDS

	invocation = "Hocus Pocus!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC | SPELL_REQUIRES_MAGICIAN_FOCUS

	possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/basic/pet/dog/corgi/capybara,
		/mob/living/basic/mothroach,
		/mob/living/simple_animal/pet/cat,
		/mob/living/simple_animal/chicken/rabbit/easter,
		/mob/living/simple_animal/hostile/illusion,
	)
