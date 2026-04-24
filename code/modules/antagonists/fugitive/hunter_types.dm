GLOBAL_LIST_INIT(hunter_types, list(
	FUGITIVE_HUNTER_SPACE_POLICE = new /datum/fugitive_type/hunter/space_police,
	FUGITIVE_HUNTER_RUSSIAN = new /datum/fugitive_type/hunter/russian,
	FUGITIVE_HUNTER_BOUNTY = new /datum/fugitive_type/hunter/bounty
))

/datum/fugitive_type/hunter
	/// The ship this type uses
	var/ship_type

/datum/fugitive_type/hunter/space_police
	name = "Space Police"
	multiple_name = "Space Police Officers"
	greet_message = span_bigbold("Justice has arrived. I am a member of the Spacepol!") + "\n" +\
	span_bold("The criminals should be on the station, we have special HUDs implanted to recognize them.") + "\n" +\
	span_bold("As we have lost pretty much all power over these damned lawless megacorporations, it's a mystery if their security will even cooperate with us.")
	ship_type = /datum/map_template/shuttle/hunter/space_cop
	outfit = /datum/outfit/spacepol/officer
	has_leader = TRUE
	leader_outfit = /datum/outfit/spacepol/sergeant

/datum/fugitive_type/hunter/russian
	name = "Space-Russian Smuggler"
	multiple_name = "Space-Russian Smugglers"
	greet_message = span_bold("Ay blyat. I am a Space-Russian smuggler! We were mid-flight when our cargo was beamed off our ship!") + "\n" +\
	span_bold("We were hailed by a man in a green uniform, promising the safe return of our goods in exchange for a favor:") + "\n" +\
	span_bold("There is a local station housing fugitives that the man is after, he wants them returned; dead or alive.") + "\n" +\
	span_bold("We will not be able to make ends meet without our cargo, so we must do as he says and capture them.")
	ship_type = /datum/map_template/shuttle/hunter/russian
	outfit = /datum/outfit/russian_hunter
	has_leader = TRUE
	leader_outfit = /datum/outfit/russian_hunter/leader

/datum/fugitive_type/hunter/bounty
	name = "Bounty Hunter"
	multiple_name = "Bounty Hunters"
	greet_message = span_bold("You are a bounty hunter, chasing profits through the capture of dangerous and desired people across the galaxy.") + "\n" +\
	span_bold("You've been tracking this bounty for a while, and you've nearly caught up to them. Now's your chance!")
	ship_type = /datum/map_template/shuttle/hunter/bounty
	outfit = list(/datum/outfit/bounty/operative, /datum/outfit/bounty/gunner, /datum/outfit/bounty/technician)
