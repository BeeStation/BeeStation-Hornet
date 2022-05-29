/datum/award/achievement/antagmastery
	category = "Antag Mastery"
	reward = 400

/datum/award/achievement/antagmastery/on_unlock(mob/user)
	. = ..()
	for(var/A in SSachievements.antag_mastery_list)
		var/datum/award/achievement/antagmastery/cheevo = A
		if(!user.client?.player_details.achievements.get_achievement_status(cheevo))
			return
	user.client?.give_award(/datum/award/achievement/antagmastery/super, user)

/datum/award/achievement/antagmastery/super
	name = "Syndie Supreme"
	desc = "Possess all other antagonist mastery achievements."
	database_id = MASTERY_ALLANTAGS

/datum/award/achievement/antagmastery/abductor
	name = "Area 51"
	desc = "As an Abductor, double your experimentation goal."
	database_id = MASTERY_ABDUCTOR

/datum/award/achievement/antagmastery/blob
	name = "No Strain Train"
	desc = "As a Blob, reach critical mass without changing strain."
	database_id = MASTERY_BLOB

/datum/award/achievement/antagmastery/brother
	name = "Brother from Another Mother"
	desc = "As a Blood Brother, complete your objectives and escape with all of your teammates."
	database_id = MASTERY_BROTHER

/datum/award/achievement/antagmastery/changeling
	name = "Pretender to the Armchair"
	desc = "As a Changeling, escape as the Captain or Acting Captain."
	database_id = MASTERY_CHANGELING

/datum/award/achievement/antagmastery/clock_cult
	name = "Engine of Destruction"
	desc = "As a Clockwork Cultist, successfully open the Ark after elevating to Delta Alert before the one hour mark."
	database_id = MASTERY_CLOCKCULT

/datum/award/achievement/antagmastery/cult
	name = "Another Day, Another Eldritch God"
	desc = "As a Blood Cultist, summon Nar'Sie before the one hour mark."
	database_id = MASTERY_CULT

/datum/award/achievement/antagmastery/heretic
	name = "Drive Thru Heresy"
	desc = "As a Heretic, achieve ascension before the one hour mark."
	database_id = MASTERY_HERETIC

/datum/award/achievement/antagmastery/guardian
	name = "One Nice Stand"
	desc = "As a Guardian, assist your master in completing their objectives."
	database_id = MASTERY_GUARDIAN

/datum/award/achievement/antagmastery/incursion
	name = "Mission: Impossible"
	desc = "As an Incursionist, complete your objectives and escape with all of your teammates."
	database_id = MASTERY_INCURSION

/datum/award/achievement/antagmastery/ninja
	name = "I Call Shogun"
	desc = "As a Space Ninja, complete your objectives and escape alive."
	database_id = MASTERY_NINJA

/datum/award/achievement/antagmastery/nukeop
	name = "Cool Guys Don't Look At Explosions"
	desc = "As a Nuclear Operative, destroy the station and escape with all of your teammates."
	database_id = MASTERY_NUKEOP

/datum/award/achievement/antagmastery/pirate
	name = "The Best Pirate I've Ever Seen"
	desc = "As a Space Pirate, steal two hundred thousand credits of loot and survive until the end of the round."
	database_id = MASTERY_PIRATE

/datum/award/achievement/antagmastery/revenant
	name = "DiCaprio Jr."
	desc = "As a Revenant, steal one thousand essence points and survive until the end of the round."
	database_id = MASTERY_REVENANT

/datum/award/achievement/antagmastery/revolution
	name = "Make Love Not War"
	desc = "As a Head Revolutionary, overthrow the Heads of Staff with all Head Revolutionaries and Heads of Staff alive."
	database_id = MASTERY_REVOLUTION

/datum/award/achievement/antagmastery/space_dragon
	name = "Breakfast of Champions"
	desc = "As a Space Dragon, eat all of the Heads of Staff and survive until the end of the round."
	database_id = MASTERY_DRAGON

/datum/award/achievement/antagmastery/traitor
	name = "Bad Ass Syndie"
	desc = "As a Traitor, accomplish your objectives without spending any Telecrystals."
	database_id = MASTERY_TRAITOR

/datum/award/achievement/antagmastery/loneop
	name = "Bad Ass Nukie"
	desc = "As a Lone Operative, destroy the station without spending any Telecrystals."
	database_id = MASTERY_LONEOP

/datum/award/achievement/antagmastery/wizard
	name = "Penned and Told"
	desc = "As a Wizard, complete your objectives without buying any spells."
	database_id = MASTERY_WIZARD

/datum/award/achievement/antagmastery/xeno
	name = "Outbreak Prime"
	desc = "As a Xenomorph, arrive at CentCom on an escape shuttle that contains no living non-xenomorphs."
	database_id = MASTERY_XENOMORPH

