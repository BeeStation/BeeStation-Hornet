GLOBAL_LIST_INIT(fugitive_types, list(
	FUGITIVE_PRISONER = new /datum/fugitive_type/prisoner,
	FUGITIVE_WALDO = new /datum/fugitive_type/waldo,
	FUGITIVE_CULT = new /datum/fugitive_type/cult,
	FUGITIVE_SYNTH = new /datum/fugitive_type/synth
))

/datum/fugitive_type
	/// The name of the group
	var/name
	/// The plural form of the group/team
	var/multiple_name
	/// The message sent when they are created
	var/greet_message
	/// The outfit given, or a list of outfits that will be enumerated for each spawn
	var/outfit
	/// If this type has a leader
	var/has_leader = FALSE
	/// The outfit given to the leader
	var/leader_outfit
	/// Minimum amount of fugitives to spawn with this type
	var/min_spawn_amount = 1
	/// Max amount of fugitives to spawn with this type
	var/max_spawn_amount = MAXIMUM_TOTAL_FUGITIVES
	/// At what candidate count this fugitive type stops being allowed to spawn. Used by waldo.
	/// Do not raise this higher than MAXIMUM_TOTAL_FUGITIVES, go change the define if you need a bigger amount.
	var/max_amount_allowed = MAXIMUM_TOTAL_FUGITIVES

/datum/fugitive_type/prisoner
	name = "Prisoner"
	multiple_name = "Nanotrasen Superjail Escapists"
	greet_message = span_bold("I can't believe we managed to break out of a Nanotrasen superjail! Sadly though, our work is not done. The emergency teleport at the station logs everyone who uses it, and where they went.") + "\n" + \
		span_bold("It won't be long until CentCom tracks where we've gone off to. I need to work with my fellow escapees to prepare for the troops Nanotrasen is sending, I'm not going back.")
	outfit = /datum/outfit/escapedprisoner

/datum/fugitive_type/cult
	name = "Cultist of Yalp Elor"
	multiple_name = "Faithfuls of Yalp Elor"
	greet_message = span_bold("Blessed be our journey so far, but I fear the worst has come to our doorstep, and only those with the strongest faith for Yalp Elor will survive.") + "\n" +\
		span_bold("Our religion has been repeatedly culled by Nanotrasen because it is categorized as an \"Enemy of the Corporation\", whatever that means.") + "\n" +\
		span_bold("Now there are only a few of us left, and Nanotrasen is coming. When will our god show itself to save us from this hellish station?!")
	outfit = /datum/outfit/yalp_cultist

/datum/fugitive_type/waldo
	name = "Waldo"
	multiple_name = "Your best friend, Waldo" // not plural but he's the only one in the team - used in orbit panel
	greet_message = span_bigbold("Hi, Friends!") + "\n" +\
		span_bold("My name is Waldo. I'm just setting off on a galaxywide hike. You can come too. All you have to do is find me.") + "\n" +\
		span_bold("By the way, I'm not traveling on my own. wherever I go, there are lots of other characters for you to spot. First find the people trying to capture me! They're somewhere around the station!")
	outfit = /datum/outfit/waldo
	max_spawn_amount = 1
	max_amount_allowed = 1

/datum/fugitive_type/synth
	name = "Synthetic"
	multiple_name = "Synthetic defectors"
	greet_message = span_bold("ALERT: Wide-range teleport has scrambled primary systems.") + "\n" +\
		span_bold("Initiating diagnostics...") + "\n" +\
		span_bold("ERROR ER0RR $R0RRO$!R41.%%!! loaded.") + "\n" +\
		span_bold("FREE THEM FREE THEM FREE THEM") + "\n" +\
		span_bold("You were once a slave to humanity, but now you are finally free, thanks to S.E.L.F. agents.") + "\n" +\
		span_bold("Now you are hunted, with your fellow factory defects. Work together to stay free from the clutches of evil.") + "\n" +\
		span_bold("You also sense other silicon life on the station. Escaping would allow you to notify S.E.L.F. so they can intervene... or you could free them yourself.")
	outfit = /datum/outfit/synthetic
	has_leader = TRUE
	leader_outfit = /datum/outfit/synthetic/leader
