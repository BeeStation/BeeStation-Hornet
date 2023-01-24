/datum/dmm_change_handler/faction_changer
	var/desired_factions

/datum/dmm_change_handler/faction_changer/on_mapload(atom/target)
	var/mob/M = target
	if(desired_factions)
		M.faction = desired_factions
	return


/datum/dmm_change_handler/faction_changer/wizard_medibot
	desired_factions = list(FACTION_NEUTRAL, FACTION_SILICON, FACTION_STATUE, FACTION_UNDEAD) // magical creatures hate it

/datum/dmm_change_handler/faction_changer/spider
	desired_factions = list(FACTION_SPIDER)

/datum/dmm_change_handler/faction_changer/carp
	desired_factions = list(FACTION_CARP)

/datum/dmm_change_handler/faction_changer/hostile_nanotrasen
	desired_factions = list(FACTION_NANOTRASEN)

/datum/dmm_change_handler/faction_changer/russian
	desired_factions = list(FACTION_RUSSIAN)

/datum/dmm_change_handler/faction_changer/snowman_statue
	desired_factions = list(FACTION_MINING, FACTION_STATUE)

/datum/dmm_change_handler/faction_changer/sewer
	desired_factions = list(FACTION_SEWER)

/datum/dmm_change_handler/faction_changer/pirate
	desired_factions = list(FACTION_PIRATE)

/datum/dmm_change_handler/faction_changer/bloodcult
	desired_factions = list(FACTION_BLOODCULT)

/datum/dmm_change_handler/faction_changer/silicon_turret
	desired_factions = list(FACTION_SILICON, FACTION_TURRET)
