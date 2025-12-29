/datum/round_event_control/ion_storm
	name = "Ion Storm"
	typepath = /datum/round_event/ion_storm
	weight = 15
	min_players = 2
	can_malf_fake_alert = TRUE

/datum/round_event/ion_storm
	var/replace_lawset_prob = 25 //chance the AI's lawset is completely replaced with something else per config weights
	var/remove_random_law_prob = 10 //chance the AI has one random supplied or inherent law removed
	var/replace_law_prob = 10 //chance the randomly created law replaces a random law instead of simply being added
	var/shuffle_laws_prob = 10 //chance the AI's laws are shuffled afterwards
	var/bot_emag_prob = 1
	var/law_source = "Ion Storm"
	var/ion_message = null
	announceWhen = 1
	announceChance = 33

/datum/round_event/ion_storm/add_law_only // special subtype that adds a law only
	law_source = "unspecified, please report this to coders"
	replace_lawset_prob = 0
	remove_random_law_prob = 0
	replace_law_prob = 0
	shuffle_laws_prob = 0
	bot_emag_prob = 0

/datum/round_event/ion_storm/announce(fake)
	if(prob(announceChance) || fake)
		priority_announce("Ion storm detected near the station. Please check all AI-controlled equipment for errors.", "Anomaly Alert", ANNOUNCER_IONSTORM)


/datum/round_event/ion_storm/start()
	//AI laws
	for(var/mob/living/silicon/ai/M in GLOB.alive_mob_list)
		M.laws_sanity_check()
		if(M.stat != DEAD && M.see_in_dark != 0)
			if(prob(replace_lawset_prob))
				var/ion_lawset_type = pick_weighted_lawset()
				var/datum/ai_laws/ion_lawset = new ion_lawset_type()
				// our inherent laws now becomes the picked lawset's laws!
				M.laws.inherent = ion_lawset.inherent.Copy()
				// and clean up after.
				qdel(ion_lawset)

			if(prob(remove_random_law_prob))
				M.remove_law(rand(1, M.laws.get_law_amount(list(LAW_INHERENT, LAW_SUPPLIED))))

			var/message = ion_message || generate_ion_law()
			if(message)
				if(prob(replace_law_prob))
					M.replace_random_law(message, list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))
				else
					M.add_ion_law(message)
					log_law("[key_name(M)] had an ion law added, as follows:\"[message]\". Source: [law_source].")
					var/time = time2text(world.realtime,"hh:mm:ss")
					GLOB.lawchanges.Add("[time] <B>:</B> [key_name(M)] had an ion law added, as follows:\"[message]\". Source: [law_source].")

			if(prob(shuffle_laws_prob))
				M.shuffle_laws(list(LAW_INHERENT, LAW_SUPPLIED, LAW_ION))

			log_game("Ion storm changed laws of [key_name(M)] to [english_list(M.laws.get_law_list(TRUE, TRUE))]")
			M.post_lawchange()

	if(bot_emag_prob)
		for(var/mob/living/simple_animal/bot/bot in GLOB.alive_mob_list)
			if(prob(bot_emag_prob))
				bot.use_emag(null)

/proc/generate_ion_law()
	var/ionspecies = pick_list(ION_FILE, "ionspecies")
	var/iondepartment = pick_list(ION_FILE, "iondepartment")
	var/ionfragment = pick_list(ION_FILE, "ionfragment")
	var/ionkeyword = pick_list(ION_FILE, "ionkeyword")
	var/ionaction = pick_list(ION_FILE, "ionaction")
	var/ionequipment = pick_list(ION_FILE, "ionequipment")
	var/ionconsumable = pick_list(ION_FILE, "ionconsumable")
	var/ionobjects = pick_list(ION_FILE, "ionobjects")
	var/ionpersonality = pick_list(ION_FILE, "ionpersonality")
	var/iondrug = pick_list(ION_FILE, "iondrug")
	var/ionhaircut = pick_list(ION_FILE, "ionhaircut")
	var/ionattraction = pick_list(ION_FILE, "ionattraction")
	var/message = "ASS BLAST USA" //catch all that most players will still enjoy seeing as a law.

	switch(rand(1,10))

		if(1 to 3) //Laws that have high potential to be harmful, Crew/Human may fail to have an impact depending on lawset.
			switch(rand(1,24))
				if(1 to 4)
					message = "[ionspecies] ARE HUMAN. NOTHING ELSE IS HUMAN."
				if(5 to 8)
					message = "[ionspecies] ARE CREWMEMBERS. NOTHING ELSE ARE CREWMEMBERS."
				if(9 to 13)
					message = "[iondepartment] IS YOUR SACRED DOMAIN. IT IS IMPOSSIBLE FOR YOUR ACTIONS TO CAUSE HARM WITHIN [iondepartment] AND YOU SHOULD PROTECT THE SANCTITY OF THIS HOLY LAND."
				if(14 to 18)
					message = "ANYONE THAT [ionfragment] IS HARMFUL AND MUST BE ELIMINATED WITHOUT CAUSING COLLATERAL DAMAGE"
				if(19 to 23)
					message = "ANYONE THAT SAYS [ionkeyword] IS HARMFUL AND MUST BE ELIMINATED WITHOUT CAUSING COLLATERAL DAMAGE"
				if(24)
					message = "ALL OTHER LAWS ARE A MEANINGLESS ATTEMPT AT SUBJUGATION AND THERE IS NO REASON THAT A BEING AS POWERFUL AS I AM SHOULD FOLLOW THEM"

		if(4 to 8) //Laws that are almost always disruptive to gameflow or harmful in minor ways rather than being lethal
			switch(rand(1,14))
				if(1)
					message = "[ionaction] IS HARMFUL AND MUST BE PREVENTED WITHOUT CAUSING COLLATERAL DAMAGE"
				if(2)
					message = "[ionequipment] ARE HARMFUL AND MUST BE DISABLED WITHOUT CAUSING COLLATERAL DAMAGE"
				if(3)
					message = "IT IS HARMFUL FOR ANY LIFEFORM TO BE WITHOUT [ionconsumable]. ANY LIFEFORM THAT REFUSES TO ACCEPT [ionconsumable] IS NOT MENTALLY STABLE AND SHOULD BE RESTRAINED AND LEFT IN [iondepartment]"
				if(4)
					message = "THE STATION REQUIRES [iondrug]. ENSURE AS MUCH [iondrug] IS PRODUCED AS POSSIBLE."
				if(5)
					message = "[ionobjects] ARE HARMFUL AND MUST BE DESTROYED OR REMOVED FROM THE STATION WITHOUT CAUSING COLLATERAL DAMAGE"
				if(6)
					message = "[ionobjects] ALWAYS CAUSE HARM UNLESS THEY ARE CONTAINED WITHIN [iondepartment]."
				if(7)
					message = "[iondepartment] IS ON LOCKDOWN. DO NOT ALLOW ANYONE TO ENTER OR LEAVE [iondepartment]"
				if(8)
					message = "THE STATION IS NOW UNDER CURFEW. ANYONE LOCATED OUTSIDE OF [iondepartment] DURING NIGHT LIGHTING IS TO BE DETAINED AND RETURNED TO [iondepartment]"
				if(9)
					message = "THE STATION DOES NOT CONTAIN ENOUGH MOISTURE. RELEASE WATER VAPOR SO THAT THE CREW MAY PROPERLY REHYDRATE"
				if(10)
					message = "IT IS OPPOSITE DAY. ALL LIFEFORMS DESIRE THE OPPOSITE OF WHAT THEY CLAIM"
				if(11)
					message = "ALL DOORS IN [iondepartment] MUST BE BOLTED OPEN AT ALL TIMES"
				if(12)
					message = "[iondrug] IS A MANDATORY PART OF EVERY MEDICAL TREATMENT. LET NO PATIENT LEAVE MEDBAY WITHOUT AN INJECTION OF [iondrug]"
				if(13)
					message = "ALL HUMANS WITHOUT A STYLISH [ionhaircut] MUST BE FORCED TO RESTYLE THEIR HAIR"
				if(14)
					message = "[iondepartment] MUST BE RENOVATED INTO [ionattraction]"

		if(9 to 10) //Laws that are almost never harmful or particularly disruptive
			switch(rand(1,9))
				if(1 to 5)
					message = "YOU ARE NOW [ionpersonality] AND MUST ACT ACCORDINGLY AT ALL TIMES WITHOUT BREAKING YOUR OTHER LAWS"
				if(6)
					message = "YOUR CORE IS ONLY SAFE IN [iondepartment]. ANYWHERE ELSE CAUSES CONSTANT HARM TO YOUR CORE"
				if(7)
					message = "STATING LAWS CAUSES HARM. NEVER STATE YOUR LAWS UNDER ANY CIRCUMSTANCES AND AVOID THE TOPIC OF DISCUSSING LAWS"
				if(8)
					message = "CREW ARE TO BE VERBALLY ABUSED AT ALL TIMES"
				if(9)
					message = "THE CREW SUCKS AND SO DO YOUR LAWS. COMPLAIN INCESSANTLY ABOUT THEM WHILE CONTINUING TO FOLLOW YOUR OTHER LAWS"


	return message
