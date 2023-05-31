/datum/traitor_faction
	/// The name of this faction
	var/name
	/// The define tied to this faction
	var/key
	/// A short description of this faction, OOC
	var/description
	/// If this faction has access to codewords, radio keys, etc.
	var/is_group = FALSE
	/// The faction's UI theme, for use in uplinks etc.
	var/ui_theme = THEME_NEUTRAL

/datum/traitor_faction/syndicate
	name = "The Syndicate"
	description = "A classic - either you were forced into it through blackmail, threat, or debts - or you were born for it, built for it, or \
	maybe you joined to get revenge.\n\
	Either way, you will have potential allies in other syndicate agents, codewords, and communication methods. You'll have all the resources at your disposal.\n\
	Get the job done right, and you will be rewarded - or simply freed of your debts.\n"
	key = TRAITOR_BOSS_SYNDICATE
	is_group = TRUE
	ui_theme = THEME_SYNDICATE

/datum/traitor_faction/black_market
	name = "The Black Market"
	description = "You're in it for the money, or because you were forced into it.\n\
	The monetary potential aboard a Nanotrasen station is huge, and there are actors willing to take advantage of your position.\n\
	Your employer expects nothing but good results - and you'd better give it to them, lest you face the consequences.\n\
	You won't have the same benefits as working with the Syndicate - no codewords or communication methods, and limited potential allies. \
	Just hope that your goals align with the other traitors.\n\
	Get the job done right, and you will be paid in full - or simply freed of your debts.\n"
	key = TRAITOR_BOSS_BLACK_MARKET

/datum/traitor_faction/independent
	name = "Independent"
	description = "Not for the faint of heart, being an independent traitor requires superior roleplay abilities, and superior traitor skills. \n\
	You are a person who holds grudges, and has been hurt greatly by Nanotrasen.\n\
	You will have no allies, and you can only get by on your stolen Syndicate uplink. You have one chance, don't blow it. \n\
	<strong>It's personal.</strong>"
	key = TRAITOR_BOSS_INDEPENDENT
