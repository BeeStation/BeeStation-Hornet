
#define FREE_TEXT_PRE "That's the target. Now go and kill them."
#define MONEY_TEXT "You agreed on the price and received the TCs."
#define FORCED_TEXT_PRE "Kill them or we'll make more trouble for you than it's worth."
#define SYNDICATE_TEXT "Murdering others is the very core of being part of the Syndicate."
#define SYNDICATE_FREE_TEXT "Show us you have the resolve for it!"
#define SADIST_TEXT "Oh, and... bonus points if you make them scream!"
#define GENERAL_TEXT "Don't fuss over it and prepare to do everything you need in order to prevent their revival. Take no chances and go to any extent."
#define BLACK_MARKET_FREE_TEXT "Make sure no one finds out that I hired you, or you'll be working for me with a little less freedom."

/datum/objective_filterable/objective_backstory/assassinate/death
	title = "They Killed My Loved One"
	personal_text = "Their incompetence led to the death of a loved one. A friend, a family member - either directly or indirectly. \
	They blocked funding that would've let them get the surgery - they mismanaged their workplace - they botched a surgery, repair, something or the other. \
	I can't stand for this."
	recommended_backstories = list(
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/savior,
	)
	allowed_factions = list(
		TRAITOR_FACTION_INDEPENDENT,
	)

/datum/objective_filterable/objective_backstory/assassinate/promotion
	title = "They Stole My Promotion"
	personal_text = "They <b>stole</b> that promotion from me. That would've changed my life. I'd finally save enough to move on with my life. \
	But now I'm stuck here, with nothing to show for it. That shady bastard will pay for it."
	recommended_backstories = list(
		/datum/traitor_backstory/greedy,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/savior,
	)
	allowed_factions = list(
		TRAITOR_FACTION_INDEPENDENT,
	)

/datum/objective_filterable/objective_backstory/assassinate/sellout
	title = "They Know"
	personal_text = "Oh god, they know. They know what I'm doing, what I'm a part of. They saw something shady, \
	and it's only a matter of time until they sell me out."
	recommended_backstories = list(
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

/datum/objective_filterable/objective_briefing/assassinate/sellout
	briefing = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. " + GENERAL_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/sellout

/datum/objective_filterable/objective_backstory/assassinate/obstacle
	title = "An Obstacle"
	personal_text = "They're in the way of my success. They saw something shady, and will probably turn me in at any moment. It's time to clean up."
	recommended_backstories = list(
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)

/datum/objective_filterable/objective_briefing/assassinate/sellout_syndicate_evil
	briefing = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. " + GENERAL_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE)
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/obstacle

/datum/objective_filterable/objective_briefing/assassinate/sellout_evil
	briefing = "We've received reliable information from an internal source that the target is \
	at least partially aware of your situation. Clean up after yourself. " + GENERAL_TEXT + " " + SADIST_TEXT
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET)
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/obstacle

// -----------
// MONEY
// -----------

/datum/objective_filterable/objective_backstory/assassinate/money_free
	title = "For The Money (Free)"
	personal_text = "The rewards for this bounty are huge. It's my only shot at making it big."
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
		TRAITOR_FACTION_BLACK_MARKET,
	)
	recommend_money_only = TRUE
	recommend_free_only = TRUE

/datum/objective_filterable/objective_backstory/assassinate/money_forced
	title = "For The Money (Forced)"
	personal_text = "The payout on this kill is huge... and I really need the money."
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
		TRAITOR_FACTION_BLACK_MARKET,
	)
	recommend_money_only = TRUE
	recommend_forced_only = TRUE

/datum/objective_filterable/objective_backstory/assassinate/money_independent
	title = "For The Money"
	personal_text = "There's a lot of money to be gained by eliminating this target. I could ransom their body, \
	loot their bank account, sell their personal effects. As long as I don't get caught, everything will work out."
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)
	recommend_money_only = TRUE
	recommend_free_only = TRUE

// ----------------
// MONEY BRIEFINGS
// ----------------

/datum/objective_filterable/objective_briefing/assassinate/money_syndicate_free
	briefing = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/money_free
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE)

/datum/objective_filterable/objective_briefing/assassinate/money_syndicate_forced
	briefing = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/money_forced
	allowed_factions = list(TRAITOR_FACTION_SYNDICATE)

/datum/objective_filterable/objective_briefing/assassinate/money_market_free
	briefing = MONEY_TEXT + " " + FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/money_free
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET)

/datum/objective_filterable/objective_briefing/assassinate/money_market_forced
	briefing = MONEY_TEXT + " " + FORCED_TEXT_PRE + " " + GENERAL_TEXT + " This will help you earn your damn money back! You owe me, don't mess this up!"
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/money_forced
	allowed_factions = list(TRAITOR_FACTION_BLACK_MARKET)


// ----------------
// POLITICAL
// ----------------

/datum/objective_filterable/objective_backstory/assassinate/political_syndicate
	title = "Corruption"
	personal_text = "The Syndicate have declared them a political enemy. It's my job to eliminate them. Anything to stop Nanotrasen from succeeding."
	recommended_backstories = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_briefing/assassinate/political_syndicate
	briefing = "This person is in the way of the Syndicate's goals. Wipe them out. " + GENERAL_TEXT + " " + SYNDICATE_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/political_syndicate
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_backstory/assassinate/loyal_syndicate
	title = "Loyalty To Nanotrasen"
	personal_text = "The Syndicate have declared them a political enemy. It's my job to eliminate them. Anything to stop Nanotrasen from succeeding."
	recommended_backstories = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist
	)
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_briefing/assassinate/loyal_syndicate
	briefing = "The target is too loyal to Nanotrasen. Eliminate them. " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/loyal_syndicate
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_backstory/assassinate/political_market
	title = "Corruption"
	personal_text = "The boss wants 'em gone... Anything to stop Nanotrasen from succeeding."
	recommended_backstories = list(
		/datum/traitor_backstory/hater,
	)
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)

/datum/objective_filterable/objective_briefing/assassinate/political_market
	briefing = "The target is responsible for damages to my company. Wipe them out. " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/political_market
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)

/datum/objective_filterable/objective_backstory/assassinate/political_indepenent
	title = "Corruption"
	personal_text = "Working with them, I've discovered their shady and outright immoral doings. The wage theft, selective hiring, furthering the interests of an \
	intergalatic megacorporation that mistreats and steals wages from its workers... I can't stand for this. \
	I have to put an end to it. Now."
	recommended_backstories = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
	)
	allowed_factions = list(
		TRAITOR_FACTION_INDEPENDENT,
	)

/datum/objective_filterable/objective_backstory/assassinate/loyal_independent
	title = "Loyalty To Nanotrasen"
	personal_text = "Working with them, hearing what they say, the conversations about Nanotrasen... They're too unwaveringly loyal and too important. \
	Furthering the interests of an intergalatic megacorporation that mistreats and steals wages from its workers... I can't stand for this. \
	I have to put an end to it. Now."
	recommended_backstories = list(
		/datum/traitor_backstory/savior,
		/datum/traitor_backstory/hater,
		/datum/traitor_backstory/climber,
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist
	)
	allowed_factions = list(
		TRAITOR_FACTION_INDEPENDENT,
	)

/datum/objective_filterable/objective_backstory/assassinate/classified_syndicate
	title = "Classified"
	personal_text = "The Syndicate isn't gonna give me a reason why, but I have a duty to them. Let's eliminate them."
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)
	recommend_free_only = TRUE

/datum/objective_filterable/objective_briefing/assassinate/classified_syndicate
	briefing = FREE_TEXT_PRE + " Why? It's classified. " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/classified_syndicate
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_backstory/assassinate/classified_market
	title = "Classified"
	personal_text = "The Syndicate isn't gonna give me a reason why, but I have a duty to them. Let's eliminate them."
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)
	recommend_free_only = TRUE

/datum/objective_filterable/objective_briefing/assassinate/classified_market
	briefing = FREE_TEXT_PRE + " Why? It's classified. " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/classified_market
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)

/datum/objective_filterable/objective_backstory/assassinate/fun
	title = "Fun"
	personal_text = "Heh. To hold their life in my hands... It would be my greatest pleasure."
	recommended_backstories = list(
		/datum/traitor_backstory/machine,
		/datum/traitor_backstory/sadist,
	)

/datum/objective_filterable/objective_briefing/assassinate/fun_syndicate
	briefing = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + SYNDICATE_TEXT + " " + SYNDICATE_FREE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/fun
	allowed_factions = list(
		TRAITOR_FACTION_SYNDICATE,
	)

/datum/objective_filterable/objective_briefing/assassinate/fun_market
	briefing = FREE_TEXT_PRE + " " + GENERAL_TEXT + " " + BLACK_MARKET_FREE_TEXT + " " + SADIST_TEXT
	attach_to_objective_backstory = /datum/objective_filterable/objective_backstory/assassinate/fun
	allowed_factions = list(
		TRAITOR_FACTION_BLACK_MARKET,
	)

#undef FREE_TEXT_PRE
#undef MONEY_TEXT
#undef FORCED_TEXT_PRE
#undef SYNDICATE_TEXT
#undef SYNDICATE_FREE_TEXT
#undef SADIST_TEXT
#undef GENERAL_TEXT
#undef BLACK_MARKET_FREE_TEXT
