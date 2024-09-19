/datum/action/cooldown/spell/shapeshift/wizard
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. \
		Once you've made your choice, it cannot be changed."
	button_icon_state = "shapeshift"

	school = SCHOOL_TRANSMUTATION
	cooldown_time = 20 SECONDS
	cooldown_reduction_per_rank = 3.75 SECONDS

	invocation = "RAC'WA NO!"
	invocation_type = INVOCATION_SHOUT
	spell_requirements = SPELL_REQUIRES_NO_ANTIMAGIC

	possible_shapes = list(
		/mob/living/simple_animal/mouse,
		/mob/living/simple_animal/pet/dog/corgi,
		/mob/living/simple_animal/hostile/carp/ranged/chaos,
		/mob/living/simple_animal/bot/secbot/ed209,
		/mob/living/simple_animal/hostile/giant_spider/viper/wizard,
		/mob/living/simple_animal/hostile/construct/juggernaut/mystic,
	)
