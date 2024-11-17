//WHY ISN'T THIS COMPONENT

/mob/living/get_spawner_desc()
	return "Become [name]."

/mob/living/get_spawner_flavour_text()
	switch (flavor_text)
		if (FLAVOR_TEXT_EVIL)
			return "You are a untamed creature with no reason to hold back. Kill anyone you see as a threat to you or your cause."
		if (FLAVOR_TEXT_GOOD)
			return "Remember, you have no hate towards the inhabitants of the station. There is no reason for you to attack them unless you are attacked."
		if (FLAVOR_TEXT_GOAL_ANTAG)
			return "You have a disdain for the inhabitants of this station, but your goals are more important. Make sure you work towards your objectives with your kin, instead of attacking everything on sight."
	return flavor_text

/mob/living/proc/sentience_act(mob/user)
	return
