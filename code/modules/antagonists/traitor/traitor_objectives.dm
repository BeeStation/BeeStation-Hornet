#define USE_GIMMICK_OBJECTIVES

/datum/antagonist/traitor/proc/forge_human_objectives()
	var/is_hijacker = FALSE
	if (GLOB.joined_player_list.len >= 30) // Less murderboning on lowpop thanks
		is_hijacker = prob(10)
	var/is_martyr = prob(15)

	var/objectives_to_assign = CONFIG_GET(number/traitor_objectives_amount)
	if(is_hijacker)
		objectives_to_assign--
#ifdef USE_GIMMICK_OBJECTIVES
	objectives_to_assign--
#endif


 	//Set up an exchange if there are enough traitors
	if(!SSticker.mode.exchange_blue && SSticker.mode.traitors.len >= 8)
		if(!SSticker.mode.exchange_red)
			SSticker.mode.exchange_red = owner
		else
			SSticker.mode.exchange_blue = owner
			assign_exchange_role(SSticker.mode.exchange_red)
			assign_exchange_role(SSticker.mode.exchange_blue)
		objectives_to_assign-- //Exchange counts towards number of objectives

	//assign_backstory(is_hijacker, is_martyr)

	for(var/i in 1 to objectives_to_assign) // minus 1
		forge_single_human_objective(is_martyr)
		objectives_to_assign--

#ifdef USE_GIMMICK_OBJECTIVES
	//Add a gimmick objective
	var/datum/objective/gimmick/gimmick_objective = new
	gimmick_objective.owner = owner
	gimmick_objective.find_target()
	gimmick_objective.update_explanation_text()
	add_objective(gimmick_objective) //Does not count towards the number of objectives, to allow hijacking as well
#endif

	if(is_hijacker)
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
			return


	var/martyr_compatibility = TRUE //You can't succeed in stealing if you're dead.
	for(var/datum/objective/O in objectives)
		if(!O.martyr_compatible)
			martyr_compatibility = FALSE
			break

	if(is_martyr && martyr_compatibility)
		var/datum/objective/martyr/martyr_objective = new
		martyr_objective.owner = owner
		add_objective(martyr_objective)
		return
	else
		if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
			return

/datum/antagonist/traitor/proc/forge_single_human_objective(is_martyr)
	if(prob(50) || is_martyr) // martyr can't steal stuff, since they die, so they have to have a kill objective
		var/list/active_ais = active_ais()
		if(active_ais.len && prob(100/GLOB.joined_player_list.len))
			var/datum/objective/destroy/destroy_objective = new
			destroy_objective.owner = owner
			destroy_objective.find_target()
			add_objective(destroy_objective)
		else if(prob(30))
			var/datum/objective/maroon/maroon_objective = new
			maroon_objective.owner = owner
			maroon_objective.find_target()
			add_objective(maroon_objective)
		else
			var/datum/objective/assassinate/kill_objective = new
			kill_objective.owner = owner
			kill_objective.find_target()
			add_objective(kill_objective)
	else
		if(prob(15) && !(locate(/datum/objective/download) in objectives) && !(owner.assigned_role in list(JOB_NAME_RESEARCHDIRECTOR, JOB_NAME_SCIENTIST, JOB_NAME_ROBOTICIST)))
			var/datum/objective/download/download_objective = new
			download_objective.owner = owner
			download_objective.gen_amount_goal()
			add_objective(download_objective)
		else
			var/datum/objective/steal/steal_objective = new
			steal_objective.owner = owner
			steal_objective.find_target()
			add_objective(steal_objective)

/*
/datum/objective/assassinate
	flavor_text = "Diplomacy has many means. Murder is the oldest of them."

/datum/objective/assassinate/setup_traitor_data(datum/traitor_backstory/backstory, boss_type)
	has_traitor_data = TRUE
	switch(boss_type)
		if(TRAITOR_BOSS_BLACK_MARKET)
			its_personal()
		if(TRAITOR_BOSS_INDEPENDENT)
			its_personal()
		if(TRAITOR_BOSS_SYNDICATE)
			if(initial(backstory.forced))
				greet_text = "Kill [target?.current?.p_them() || "them"] or we'll make more trouble for you than it's worth. \
				[backstory.money_motivated ? "You agreed on the price and received the TCs. " : ""] \
				The Syndicate doesn't mess around. Don't fuss over it and prepare to do everything you need in order to prevent [target?.current?.p_their() || "their"] revival. \
				Take no chances and go to any extent. Murdering others is the very core of being part of the syndicate."
			else
				greet_text = "[backstory.money_motivated ? "You agreed on the price and received the TCs. " : ""]That's the target. \
				Now go and kill [target?.current?.p_them() || "them"]. \
				[backstory.politically_motivated ? ((target.assigned_role in GLOB.command_positions) ? \
				"The target is integral to the function of the station, and if you eliminate them, their empire crumbles. " \
				: "The target is too loyal to Nanotrasen. Eliminate them. ") : ""] \
				Don't fuss over it and prepare to do everything you need in order to prevent [target?.current?.p_their() || "their"] revival. \
				Take no chances and go to any extent. Murdering others is the very core of being part of the syndicate. \
				Show us you have the resolve for it! Oh, and... bonus points if you make [target?.current?.p_them() || "them"] scream!"

/datum/objective/assassinate/proc/its_personal(datum/traitor_backstory/backstory, boss_type)
	greet_text = pick("")

*/


/proc/backstory_objectives()
	var/backstory_html = "<body>"
	for(var/path in subtypesof(/datum/traitor_backstory))
		var/datum/traitor_backstory/backstory = new path()
		for(var/boss in list(TRAITOR_BOSS_BLACK_MARKET, TRAITOR_BOSS_SYNDICATE, TRAITOR_BOSS_INDEPENDENT))
			if(!(boss in backstory.valid_bosses))
				continue
			backstory_html += "<h1>[backstory.name] ([boss])</h1>"
			backstory_html += "<p>[backstory.description]</p>"
			for(var/path2 in subtypesof(/datum/objective_backstory/assassinate))
				var/datum/objective_backstory/backstory2 = new path2()
				if(!(boss in backstory2.valid_for_boss))
					continue
				if(islist(backstory2.valid_for_backstory) && !(path in backstory2.valid_for_backstory))
					continue
				backstory_html += "<h2>[backstory2.title]</h2>"
				if(boss != TRAITOR_BOSS_INDEPENDENT)
					backstory_html += "<blockquote>[backstory2.boss_text]</blockquote>"
				backstory_html += "<p>[backstory2.personal_text]</p>"
	backstory_html += "</body>"
	usr << browse(backstory_html, "window=backstory_list")

/datum/objective_backstory
	var/title
	var/personal_text
	var/boss_text
	/// A list of backstory typepaths this is valid for
	var/list/datum/objective_backstory/valid_for_backstory
	/// A list of boss types this is valid for
	var/list/valid_for_boss
	/// If this requires the target be a head
	var/target_head = FALSE

/datum/objective_backstory/proc/personalize(datum/traitor_backstory/backstory, datum/mind/target)
	return

#define FREE_TEXT_PRE "That's the target. Now go and kill them."
#define MONEY_TEXT "You agreed on the price and received the TCs."
#define FORCED_TEXT_PRE "Kill them or we'll make more trouble for you than it's worth."
#define SYNDICATE_TEXT "Murdering others is the very core of being part of the Syndicate."
#define SYNDICATE_FREE_TEXT "Show us you have the resolve for it!"
#define SADIST_TEXT "Oh, and... bonus points if you make them scream!"
#define GENERAL_TEXT "Don't fuss over it and prepare to do everything you need in order to prevent their revival. Take no chances and go to any extent."
#define BLACK_MARKET_FREE_TEXT "Make sure no one finds out that I hired you, or you'll be working for me with a little less freedom."
#define BLACK_MARKET_FORCED_TEXT "Make sure no one finds out that I hired you, or... you know what happens."

/datum/objective_backstory/assassinate/death
	title = "Death of a loved one"
	personal_text = "Their incompetence led to the death of a loved one. A friend, a family member - either directly or indirectly. \
	Funding, surgery, whatever it may be. I can't stand for this."
	valid_for_backstory = list(
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/savior,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/promotion
	title = "Stole a promotion"
	personal_text = "They <b>stole</b> that promotion from me. That would've changed my life. I'd finally save enough to move on with my life. \
	But now I'm stuck here, with nothing to show for it. That shady bastard will pay for it."
	valid_for_backstory = list(
		/datum/traitor_backstory/greedy,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/savior,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/sellout
	title = "Will sell you out"
	personal_text = "Oh god, they know. They know what I'm doing, what I'm a part of. They saw something shady, \
	and it's only a matter of time until they sell me out."
	boss_text = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. [GENERAL_TEXT]"
	valid_for_backstory = list(
		/datum/traitor_backstory/debtor,
		/datum/traitor_backstory/stolen,
		/datum/traitor_backstory/gambler,
		/datum/traitor_backstory/blackmailed,
		/datum/traitor_backstory/hostage,
		/datum/traitor_backstory/legally_enslaved,
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/greedy,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/obstacle
	title = "An obstacle"
	personal_text = "They're in the way of my success. They saw something shady, and will probably turn me in at any moment. It's time to clean up."
	boss_text = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. [GENERAL_TEXT] [SYNDICATE_FREE_TEXT] [SADIST_TEXT]"
	valid_for_backstory = list(
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/forced_syndicate
	title = "Because you must - for the syndicate"
	personal_text = "The Syndicate said so... I better listen to them."
	boss_text = "[FORCED_TEXT_PRE] [GENERAL_TEXT] [SYNDICATE_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/member_syndicate
	title = "Because you want to - for the syndicate"
	personal_text = "The Syndicate said so... I better listen to them."
	boss_text = "[FREE_TEXT_PRE] [GENERAL_TEXT] [SYNDICATE_TEXT] [SYNDICATE_FREE_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/forced_market
	title = "Because you must - for yourself & loved ones"
	personal_text = "I need to do this if I want my reward."
	boss_text = "[FORCED_TEXT_PRE] [GENERAL_TEXT] [BLACK_MARKET_FORCED_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/member_market
	title = "Because you must - for yourself & loved ones"
	personal_text = "I need to do this if I want my reward."
	boss_text = "[FREE_TEXT_PRE] [GENERAL_TEXT] [BLACK_MARKET_FREE_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/member_indepenent
	title = "Because you must - for yourself"
	personal_text = "It's the only way to achieve my goals."
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/money_syndicate
	title = "For the money - Syndicate"
	personal_text = "The payout on this kill is huge... and I really need the money."
	boss_text = "[MONEY_TEXT] [FREE_TEXT_PRE] [SYNDICATE_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/money_market
	title = "For the money - Black Market"
	personal_text = "The payout on this kill is huge... and I really need the money."
	boss_text = "[MONEY_TEXT] [FREE_TEXT_PRE] [GENERAL_TEXT] [BLACK_MARKET_FORCED_TEXT]"
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/political/syndicate
	title = "They are corrupt - Syndicate"
	personal_text = "The Syndicate have declared them a political enemy. It's my job to eliminate them."
	boss_text = "This person is in the way of the Syndicate's goals. Wipe them out."
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/political/market
	title = "They are corrupt - Black Market"
	personal_text = "They're responsible for the failures of Nanotrasen. Through embezzlement, selective hiring, shady dealings, \
	something or the other, they've made the already terrible Nanotrasen worse."
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/political/indepenent
	title = "They are corrupt - Independent"
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/fun_syndicate
	title = "For the fun of it - Syndicate"
	personal_text = "Heh. To hold their life in my hands... It would be of utmost pleasure."
	boss_text = "[FREE_TEXT_PRE] [GENERAL_TEXT] [SYNDICATE_TEXT] [SYNDICATE_FREE_TEXT] [SADIST_TEXT]"
	valid_for_backstory = list(
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/fun_black_market
	title = "For the fun of it - Black Market"
	personal_text = "Heh. To hold their life in my hands... It would be of utmost pleasure."
	boss_text = "[FREE_TEXT_PRE] [GENERAL_TEXT] [BLACK_MARKET_FREE_TEXT] [SADIST_TEXT]"
	valid_for_backstory = list(
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/fun_independent
	title = "For the fun of it - Independent"
	personal_text = "Heh. To hold their life in my hands... It would be of utmost pleasure."
	valid_for_backstory = list(
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

#undef FREE_TEXT_PRE
#undef MONEY_TEXT
#undef FORCED_TEXT_PRE
#undef SYNDICATE_TEXT
#undef SYNDICATE_FREE_TEXT
#undef SADIST_TEXT
#undef GENERAL_TEXT
#undef BLACK_MARKET_FREE_TEXT
#undef BLACK_MARKET_FORCED_TEXT
