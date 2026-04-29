/datum/ert
	var/mobtype = /mob/living/carbon/human
	var/team = /datum/team/ert
	var/opendoors = TRUE
	var/leader_role = /datum/antagonist/ert/commander
	var/enforce_human = TRUE
	var/roles = list(/datum/antagonist/ert/security, /datum/antagonist/ert/medic, /datum/antagonist/ert/engineer) //List of possible roles to be assigned to ERT members.
	var/rename_team
	var/low_priority_leader = FALSE
	var/code
	var/mission = "Assist the station."
	var/teamsize = 4
	var/polldesc
	/// If TRUE, gives the team members "[role] [random last name]" style names
	var/random_names = TRUE
	/// If TRUE, the admin who created the response team will be spawned in the briefing room in their preferred briefing outfit (assuming they're a ghost)
	var/spawn_admin = FALSE
	/// If TRUE, we try and pick one of the most experienced players who volunteered to fill the leader slot
	var/leader_experience = TRUE

/datum/ert/New()
	if (!polldesc)
		polldesc = "a Code [code] Nanotrasen Emergency Response Team"

/datum/ert/centcom_official
	code = "Green"
	teamsize = 1
	opendoors = FALSE
	leader_role = /datum/antagonist/ert/official
	roles = list(/datum/antagonist/ert/official)
	rename_team = "CentCom Officials"
	polldesc = "a CentCom Official"
	random_names = FALSE
	leader_experience = FALSE

/datum/ert/centcom_official/New()
	mission = "Conduct a routine performance review of [station_name()] and its Captain."

// Generalists
/datum/ert/generalist
	leader_role = /datum/antagonist/ert/commander/blue
	roles = list(/datum/antagonist/ert/medic/blue, /datum/antagonist/ert/engineer/blue, /datum/antagonist/ert/security/blue)
	opendoors = FALSE
	code = "blue"

/datum/ert/generalist/amber
	leader_role = /datum/antagonist/ert/commander/amber
	roles = list(/datum/antagonist/ert/medic/amber, /datum/antagonist/ert/engineer/amber, /datum/antagonist/ert/security/amber)
	code = "Amber"

/datum/ert/generalist/red
	leader_role = /datum/antagonist/ert/commander/red
	roles = list(/datum/antagonist/ert/medic/red, /datum/antagonist/ert/engineer/red, /datum/antagonist/ert/security/red)
	code = "Red"

/datum/ert/generalist/inquisition
	roles = list(/datum/antagonist/ert/medic/inquisition, /datum/antagonist/ert/engineer/inquisition, /datum/antagonist/ert/security/inquisition)
	leader_role = /datum/antagonist/ert/commander/inquisition
	rename_team = "Inquisition"
	mission = "Destroy any traces of paranormal activity aboard the station."
	polldesc = "a Nanotrasen paranormal response team"

// Deathsquad
/datum/ert/generalist/deathsquad
	roles = list(/datum/antagonist/ert/deathsquad)
	leader_role = /datum/antagonist/ert/deathsquad/officer
	rename_team = "Deathsquad"
	code = "Delta"
	mission = "Leave no witnesses. Limit collateral to a minimum. Do not harm Central Command staff if possible."
	polldesc = "an elite Nanotrasen Strike Team"

// Specialists, led by official since the official is more inclined not to run into the fray like a commander should.
/datum/ert/specialist
	leader_role = /datum/antagonist/ert/official
	opendoors = FALSE
	rename_team = "Centcom specialists"
	mission = "Assist in disaster recovery. If station loss is unavoidable, assist in evacuation and or decomissioning."
	polldesc = "a Nanotrasen Disaster Response Team"
	code = "blue"
	low_priority_leader = TRUE

/datum/ert/specialist/engineer
	roles = list(/datum/antagonist/ert/engineer/blue)

/datum/ert/specialist/security
	roles = list(/datum/antagonist/ert/security/blue)

/datum/ert/specialist/medical
	roles = list(/datum/antagonist/ert/medic/blue)

/datum/ert/specialist/eng_sec
	roles = list(/datum/antagonist/ert/engineer/blue, /datum/antagonist/ert/security/blue)

/datum/ert/specialist/med_sec
	roles = list(/datum/antagonist/ert/medic/blue, /datum/antagonist/ert/security/blue)

/datum/ert/specialist/eng_med
	roles = list(/datum/antagonist/ert/engineer/blue, /datum/antagonist/ert/medic/blue)

/datum/ert/specialist/janitor
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	polldesc = "a Nanotrasen Janitorial Response Team"

/datum/ert/specialist/janitor/heavy
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	leader_role = /datum/antagonist/ert/janitor/heavy
	teamsize = 4
	opendoors = FALSE
	polldesc = "a Nanotrasen Heavy-Duty Janitorial Response Team"

/datum/ert/specialist/janitor/kudzu
	roles = list(/datum/antagonist/ert/janitor, /datum/antagonist/ert/janitor/heavy)
	leader_role = /datum/antagonist/ert/janitor/heavy
	teamsize = 4
	opendoors = FALSE
	polldesc = "a code 'Vine Green' Nanotrasen Disaster Response Team"
	code = "Vine Green"

// Non ERT
/datum/ert/intern
	roles = list(/datum/antagonist/ert/intern)
	leader_role = /datum/antagonist/ert/intern/leader
	teamsize = 7
	opendoors = FALSE
	rename_team = "Horde of Interns"
	mission = "Assist in conflict resolution."
	polldesc = "an unpaid internship opportunity with Nanotrasen"
	random_names = FALSE

/datum/ert/intern/unarmed
	roles = list(/datum/antagonist/ert/intern/unarmed)
	leader_role = /datum/antagonist/ert/intern/leader/unarmed
	rename_team = "Unarmed Horde of Interns"

/datum/ert/lawyer
	roles = list(/datum/antagonist/ert/lawyer)
	leader_role = /datum/antagonist/ert/lawyer
	teamsize = 7
	opendoors = FALSE
	rename_team = "Law-Firm-In-A-Box"
	mission = "Assist in legal matters."
	polldesc = "a partnership with an up-and-coming Nanotrasen law firm"

/datum/ert/clown
	roles = list(/datum/antagonist/ert/clown)
	leader_role = /datum/antagonist/ert/clown
	teamsize = 4
	opendoors = FALSE
	rename_team = "The Circus"
	mission = "Provide vital morale support to the station in this time of crisis"
	code = "Banana"

/datum/ert/bounty_hunters
	roles = list(/datum/antagonist/ert/bounty/operative, /datum/antagonist/ert/bounty/gunner, /datum/antagonist/ert/bounty/technician)
	leader_role = /datum/antagonist/ert/bounty/operative
	teamsize = 3
	opendoors = FALSE
	rename_team = "Bounty Hunters"
	mission = "Assist the station in catching perps, dead or alive."
	polldesc = "a Centcom-hired bounty hunter"
	random_names = TRUE
