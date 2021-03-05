/mob/living/Login()
	..()
	//Mind updates
	sync_mind()
	mind.show_memory(src, 0)

	//Round specific stuff
	if(SSticker.mode)
		switch(SSticker.mode.name)
			if("sandbox")
				CanBuild()

	update_damage_hud()
	update_health_hud()

	var/turf/T = get_turf(src)
	if (isturf(T))
		update_z(T.z)

	//flavor text
	switch (flavor_text)
		if (FLAVOR_TEXT_EVIL)
			to_chat(src, "<span class='warning'>You are a untamed creature with no reason to hold back. Kill anyone you see as a threat to you or your cause.</span>")
		if (FLAVOR_TEXT_GOOD)
			to_chat(src, "<span class='warning'>Remember, you have no hate towards the inhabitants of the station. There is no reason for you to attack them unless you are attacked.</span>")
		if (FLAVOR_TEXT_BLOB)
			to_chat(src, "<span class='warning'>You have a disdain for the inhabitants of this station, but your goals are more important. Make sure you work towards your objectives with your kin, instead of attacking everything on sight.</span>")

	//Vents
	if(ventcrawler)
		to_chat(src, "<span class='notice'>You can ventcrawl! Use alt+click on vents to quickly travel about the station.</span>")

	if(ranged_ability)
		ranged_ability.add_ranged_ability(src, "<span class='notice'>You currently have <b>[ranged_ability]</b> active!</span>")

	var/datum/antagonist/changeling/changeling = mind.has_antag_datum(/datum/antagonist/changeling)
	if(changeling)
		changeling.regain_powers()
