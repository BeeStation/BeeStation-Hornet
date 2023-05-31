/datum/traitor_backstory
	/// The name of this traitor backstory type, displayed as a title
	var/name
	/// A description of the events leading up to this traitor's existence
	var/description
	/// Bosses you can have as this backstory
	var/valid_bosses = list(
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_SYNDICATE
	)
	/// If this backstory involves being forced into the job
	var/forced = FALSE
	/// If this backstory is motivated by money or personal gain
	var/money_motivated = FALSE
	/// If this backstory is politically motivated, wanting to "change the world".
	var/politically_motivated = FALSE
	/// If this backstory is motivated through the power of love (your family, friends, etc)
	var/love_motivated = FALSE
	/// If this backstory is motivated by your reputation, or by knowledge (blackmail)
	var/reputation_motivated = FALSE
	/// If this backstory is motivated by the threat of death or personal harm
	var/death_motivated = FALSE
	/// If this backstory is implicitly motivated by their boss
	var/simply_motivated = FALSE
	/// If this backstory is implicitly murderbone
	var/murderbone = FALSE

/datum/traitor_backstory/debtor
	name = "The Debtor"
	description = "I owe a <b>lot</b> of money... Falling on hard times... \
	I couldn't pay to live - and now I have to earn it all back if I want to continue living."
	forced = TRUE
	money_motivated = TRUE
	death_motivated = TRUE

/datum/traitor_backstory/stolen
	name = "The Stolen"
	description = "They have... <b>everything</b>. They stole my entire fortune, and now I'm destitute. \
	The only way I'm earning it back is if I do what they say."
	forced = TRUE
	money_motivated = TRUE

/datum/traitor_backstory/gambler
	name = "The Gambler"
	description = "They warned me, told me to not enter that card game, but they didn't stop me. They knew I'd lose tens of thousands, \
	I can't help it. Now, there's only one way to crawl out of this hole I dug myself into. Such bad luck... \
	but if I can only repay them by fulfilling these tasks, maybe just maybe I can make it big."
	forced = TRUE
	valid_bosses = list(TRAITOR_BOSS_BLACK_MARKET, TRAITOR_BOSS_SYNDICATE)
	money_motivated = TRUE

/datum/traitor_backstory/blackmailed
	name = "The Blackmailed"
	description = "They know all about <b>what I did</b>... and they're not afraid to turn me in if I don't do what they say."
	forced = TRUE
	reputation_motivated = TRUE

/datum/traitor_backstory/hostage
	name = "The Hostage"
	description = "They have someone I love hostage. Oh god... What would I do without them? \
	I <b>need</b> to do this, or I'll never see them again. I <b>have</b> to do this. There's no other way out."
	forced = TRUE
	love_motivated = TRUE

/datum/traitor_backstory/legally_enslaved
	name = "The Legal Slave"
	description = "Shit... I signed a contract I shouldn't have. <b>Now they own me.</b> I have to do their bidding, and if I don't... \
	<b>They'll come for me.</b>"
	forced = TRUE
	death_motivated = TRUE

/datum/traitor_backstory/savior
	name = "The Savior"
	description = "Nanotrasen are corrupt, evil to the core. The crew here are sheep, and I must liberate them by showing the error in their ways. \
	Expose Nanotrasen for what they truly are."
	valid_bosses = list(
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_INDEPENDENT
	)
	politically_motivated = TRUE

/datum/traitor_backstory/hater
	name = "The Hater"
	description = "Nanotrasen ruined my life. They ruined everything. They took the things that I love away from me. Now I'm going to make them pay."
	valid_bosses = list(
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_INDEPENDENT
	)
	politically_motivated = TRUE
	love_motivated = TRUE

/datum/traitor_backstory/greedy
	name = "The Greedy"
	description = "If I do this, I'll be set for life. I'll have everything I ever wanted, and more. \
	The payment is astronomical, and I'm fit for the job. Let's do this."
	valid_bosses = list(
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_INDEPENDENT
	)
	money_motivated = TRUE

/datum/traitor_backstory/climber
	name = "The Climber"
	description = "Life is a ladder, and there is only climbing it. I shall have no friends, I shall hold no loyalties, \
	for the only end goal in life is for my ego to be supreme. \
	In my many years of observing the dynamics in this universe, it is clear to me that this is the surest way to achieve the domination of myself. \
	Today marks the beginning of my ascent, nothing matters but my rise. I am supreme."
	valid_bosses = list(
		TRAITOR_BOSS_BLACK_MARKET,
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_INDEPENDENT
	)
	money_motivated = TRUE
	reputation_motivated = TRUE

/datum/traitor_backstory/machine
	name = "The Machine"
	description = "I was born in the Syndicate. I was made in the Syndicate. I <b>am</b> the Syndicate. \
	I am nothing without the Syndicate, and I will do <b>everything</b> I am asked."
	valid_bosses = list(TRAITOR_BOSS_SYNDICATE)
	murderbone = TRUE
	simply_motivated = TRUE

/datum/traitor_backstory/sadist
	name = "The Sadist"
	description = "I want power, not over people, but over life, to inflict pain and suffering is my road to power. \
	They want a killer? I shall play their little game if it helps me fulfill my morbid desires. \
	No, I do not want money or influence, power over the souls that inhabit this station is my payment. \
	Hahahahah. HAHAHAHAHAHAHAHAHAH. HAHAHAHAHHAHHH!!!!! KILL!!! KILL!!!! KILL!!!!!! BURN!!!!!"
	valid_bosses = list(
		TRAITOR_BOSS_SYNDICATE,
		TRAITOR_BOSS_INDEPENDENT
	)
	murderbone = TRUE
	simply_motivated = TRUE
