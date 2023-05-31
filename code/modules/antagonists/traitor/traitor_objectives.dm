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

	var/martyr_compatibility = TRUE
	if(is_hijacker)
		if (!(locate(/datum/objective/hijack) in objectives))
			var/datum/objective/hijack/hijack_objective = new
			hijack_objective.owner = owner
			add_objective(hijack_objective)
	else
		for(var/datum/objective/O in objectives)
			if(!O.martyr_compatible) // You can't succeed in stealing if you're dead.
				martyr_compatibility = FALSE
				break

		if(is_martyr && martyr_compatibility)
			var/datum/objective/martyr/martyr_objective = new
			martyr_objective.owner = owner
			add_objective(martyr_objective)
		else if(!(locate(/datum/objective/escape) in objectives))
			var/datum/objective/escape/escape_objective = new
			escape_objective.owner = owner
			add_objective(escape_objective)
	assign_backstory(!is_hijacker && is_martyr && martyr_compatibility, is_hijacker)

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

/datum/antagonist/traitor
	/// A list of bosses the traitor can pick from freely.
	var/list/allowed_bosses = list(TRAITOR_BOSS_SYNDICATE, TRAITOR_BOSS_BLACK_MARKET, TRAITOR_BOSS_INDEPENDENT)
	/// A list of bosses the traitor can pick from freely.
	var/list/recommended_bosses
	/// A list of backstories that are allowed for this traitor.
	var/list/allowed_backstories
	/// A list of recommended backstories for this traitor, based on their murderbone status.
	var/list/recommended_backstories

/datum/antagonist/traitor/proc/assign_backstory(murderbone, hijack)
	recommended_bosses = murderbone ? list(TRAITOR_BOSS_SYNDICATE, TRAITOR_BOSS_INDEPENDENT) : allowed_bosses
	allowed_backstories = list()
	recommended_backstories = list()
	add_menu_action()

/datum/objective/assassinate
	flavor_text = "Diplomacy has many means. Murder is the oldest of them."

/proc/backstory_objectives()
	var/backstory_html = "<body>"
	for(var/datum/traitor_backstory/path as anything in subtypesof(/datum/traitor_backstory))
		var/datum/traitor_backstory/backstory = GLOB.traitor_backstories["[path]"]
		if(!istype(backstory))
			continue
		for(var/boss in list(TRAITOR_BOSS_SYNDICATE, TRAITOR_BOSS_BLACK_MARKET, TRAITOR_BOSS_INDEPENDENT))
			if(!(boss in backstory.valid_bosses))
				continue
			backstory_html += "<h1>[backstory.name] ([boss])</h1>"
			backstory_html += "<p>[backstory.description]</p>"
			for(var/datum/objective_backstory/obj_path as anything in subtypesof(/datum/objective_backstory/assassinate))
				var/datum/objective_backstory/obj_backstory = GLOB.traitor_objective_backstories["[obj_path]"]
				if(!istype(obj_backstory))
					continue
				if(islist(obj_backstory.valid_for_boss) && !(boss in obj_backstory.valid_for_boss))
					continue
				if(obj_backstory.valid_forced_only && !backstory.forced)
					continue
				if(obj_backstory.valid_free_only && backstory.forced)
					continue
				if(obj_backstory.valid_money_only && !backstory.money_motivated)
					continue
				if(islist(obj_backstory.valid_for_backstory) && !(path in obj_backstory.valid_for_backstory))
					continue
				backstory_html += "<h2>Why? [obj_backstory.title]</h2>"
				if(boss != TRAITOR_BOSS_INDEPENDENT)
					backstory_html += "<blockquote>[obj_backstory.boss_text]</blockquote>"
				backstory_html += "<p>[obj_backstory.personal_text]</p>"
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
	/// If this is valid for forced backstories
	var/valid_forced_only = FALSE
	/// If this is valid for free backstories
	var/valid_free_only = FALSE
	/// If this is valid for money-motivated backstories
	var/valid_money_only = FALSE

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

/datum/objective_backstory/assassinate/death
	title = "They Killed My Loved One"
	personal_text = "Their incompetence led to the death of a loved one. A friend, a family member - either directly or indirectly. \
	They blocked funding that would've let them get the surgery - they mismanaged their workplace - they botched a surgery, repair, something or the other. \
	I can't stand for this."
	valid_for_backstory = list(
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/savior,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/promotion
	title = "They Stole My Promotion"
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
	title = "They Know"
	personal_text = "Oh god, they know. They know what I'm doing, what I'm a part of. They saw something shady, \
	and it's only a matter of time until they sell me out."
	boss_text = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. " + GENERAL_TEXT
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

/datum/objective_backstory/assassinate/obstacle
	title = "An Obstacle"
	personal_text = "They're in the way of my success. They saw something shady, and will probably turn me in at any moment. It's time to clean up."
	boss_text = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. " + GENERAL_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)

/*/datum/objective_backstory/assassinate/forced_syndicate
	title = "Because you must - for the syndicate (forced)"
	personal_text = "The Syndicate said so... I better listen to them."
	boss_text = FORCED_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/member_syndicate
	title = "Because you want to - for the syndicate (free)"
	personal_text = "The Syndicate said so... I better listen to them."
	boss_text = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/forced_market
	title = "Because you must - for yourself & loved ones (forced)"
	personal_text = "I need to do this if I want my reward."
	boss_text = FORCED_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FORCED_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/member_market
	title = "Because you want to - for the black market (free)"
	personal_text = "I need to do this if I want my reward."
	boss_text = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)
*/

/*/datum/objective_backstory/assassinate/member_indepenent
	title = "Because you must - for yourself"
	personal_text = "It's the only way to achieve my goals."
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)
*/

/datum/objective_backstory/assassinate/money_syndicate_free
	title = "For The Money"
	personal_text = "The rewards for this bounty are huge. It's my only shot at making it big."
	boss_text = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)
	valid_money_only = TRUE
	valid_free_only = TRUE


/datum/objective_backstory/assassinate/money_syndicate_forced
	title = "For The Money"
	personal_text = "The payout on this kill is huge... and I really need the money."
	boss_text = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " This will help you earn your money back."
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)
	valid_money_only = TRUE
	valid_forced_only = TRUE

/datum/objective_backstory/assassinate/money_market_free
	title = "For The Money"
	personal_text = "The rewards for this bounty are huge. It's my only shot at making it big."
	boss_text = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)
	valid_money_only = TRUE
	valid_free_only = TRUE

/datum/objective_backstory/assassinate/money_market_forced
	title = "For The Money"
	personal_text = "The payout on this kill is huge... and I really need the money."
	boss_text = MONEY_TEXT + " " + FORCED_TEXT_PRE + " " + GENERAL_TEXT + " This will help you earn your money back."
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)
	valid_money_only = TRUE
	valid_forced_only = TRUE


/datum/objective_backstory/assassinate/money_independent
	title = "For The Money"
	personal_text = "There's a lot of money to be gained by eliminating this target. I could ransom their body, \
	loot their bank account, sell their personal effects. As long as I don't get caught, everything will work out."
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)
	valid_money_only = TRUE
	valid_free_only = TRUE

/datum/objective_backstory/assassinate/political_syndicate
	title = "Corruption"
	personal_text = "The Syndicate have declared them a political enemy. It's my job to eliminate them. Anything to stop Nanotrasen from succeeding."
	boss_text = "This person is in the way of the Syndicate's goals. Wipe them out. " + GENERAL_TEXT + " " + SYNDICATE_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/loyal_syndicate
	title = "Loyalty To Nanotrasen"
	personal_text = "The Syndicate have declared them a political enemy. It's my job to eliminate them. Anything to stop Nanotrasen from succeeding."
	boss_text = "The target is too loyal to Nanotrasen. Eliminate them. " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SADIST_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/political_market
	title = "Corruption"
	personal_text = "The boss wants 'em gone... Anything to stop Nanotrasen from succeeding."
	boss_text = "The target is responsible for damages to my company. Wipe them out. " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/political_indepenent
	title = "Corruption"
	personal_text = "Working with them, I've discovered their shady and outright immoral doings. The wage theft, selective hiring, furthering the interests of an \
	intergalatic megacorporation that mistreats and steals wages from its workers... I can't stand for this. \
	I have to put an end to it. Now."
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/loyal_independent
	title = "Loyalty To Nanotrasen"
	personal_text = "Working with them, hearing what they say, the conversations about Nanotrasen... They're too unwaveringly loyal and too important. \
	Furthering the interests of an intergalatic megacorporation that mistreats and steals wages from its workers... I can't stand for this. \
	I have to put an end to it. Now."
	valid_for_backstory = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist
	)
	valid_for_boss = list(
		TRAITOR_BOSS_INDEPENDENT,
	)

/datum/objective_backstory/assassinate/classified_syndicate
	title = "Classified"
	personal_text = "The Syndicate isn't gonna give me a reason why, but I have a duty to them. Let's eliminate them."
	boss_text = FREE_TEXT_PRE + " Why? It's classified. " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT + " " + SADIST_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)
	valid_free_only = TRUE

/datum/objective_backstory/assassinate/classified_market
	title = "Classified"
	personal_text = "The Syndicate isn't gonna give me a reason why, but I have a duty to them. Let's eliminate them."
	boss_text = FREE_TEXT_PRE + " Why? It's classified. " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)
	valid_free_only = TRUE

/datum/objective_backstory/assassinate/fun_syndicate
	title = "Fun"
	personal_text = "Heh. To hold their life in my hands... It would be my greatest pleasure."
	boss_text = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_SYNDICATE,
	)

/datum/objective_backstory/assassinate/fun_black_market
	title = "Fun"
	personal_text = "Heh. To hold their life in my hands... It would be my greatest pleasure."
	boss_text = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT + " " + SADIST_TEXT
	valid_for_backstory = list(
		/datum/traitor_backstory/sadist,
	)
	valid_for_boss = list(
		TRAITOR_BOSS_BLACK_MARKET,
	)

/datum/objective_backstory/assassinate/fun_independent
	title = "Fun"
	personal_text = "Heh. To hold their life in my hands... It would be my greatest pleasure."
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
