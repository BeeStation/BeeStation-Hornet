//Each lists stores ckeys for "Never for this round" option category
#define POLL_IGNORE_ALIEN_LARVA "alien_larva"
#define POLL_IGNORE_SYNDICATE "syndicate"
#define POLL_IGNORE_HOLOPARASITE "holoparasite"
#define POLL_IGNORE_EXPERIMENTAL_CLONE "experimental_clone"
#define POLL_IGNORE_IMAGINARYFRIEND "imaginary_friend"
#define POLL_IGNORE_HOLY_SWORD "holy_sword"
#define POLL_IGNORE_SENTIENCE_POTION "sentience_potion"
#define POLL_IGNORE_SENTIENT_BEING "sentient_being"
#define POLL_IGNORE_LAVALAND_ELITE "lavaland_elite"
#define POLL_IGNORE_BLODCULT_OVERALL "bloodcult"
#define POLL_IGNORE_CLOCKWORK_OVERALL "clockwork"
#define POLL_IGNORE_SPLITPERSONALITY "split_personality"

#define POLL_IGNORE_SPECTRAL_BLADE "spectral_blade"
#define POLL_IGNORE_POSIBRAIN "posibrain"
#define POLL_IGNORE_PAI "pai"

#define POLL_IGNORE_SPIDER "spider"
#define POLL_IGNORE_ASHWALKER "ashwalker"
#define POLL_IGNORE_DRONE "drone"
#define POLL_IGNORE_SWARMER "swarmer"
#define POLL_IGNORE_GOLEM "golem"

/*
These ignore stuff should be applied for specific roles
	1. Notification: It pops up "wanna play" windows a lot (xeno lava, sentient potion is toxic)
	2. Spawn Reqest: It sends messages of "Here's the thing" a lot. (posibrain is toxic)
	3. Creation: It shows a message it's been spawned even if you are not interested
*/
GLOBAL_LIST_INIT(poll_ignore_desc, list( // TO-DO: some ghost notifications are missing of this
	POLL_IGNORE_ALIEN_LARVA = "Notification: Xenomorph larva",
	POLL_IGNORE_SYNDICATE = "Notification: Syndicate support",
	POLL_IGNORE_HOLOPARASITE = "Notification: Holoparasite",
	POLL_IGNORE_EXPERIMENTAL_CLONE = "Notification: Experimental clone",
	POLL_IGNORE_IMAGINARYFRIEND = "Notification: Imaginary Friend",
	POLL_IGNORE_HOLY_SWORD = "Notification: Spiritual Sword",
	POLL_IGNORE_SENTIENCE_POTION = "Notification: Sentience \"potion\"",
	POLL_IGNORE_SENTIENT_BEING = "Notification: Sentient beings",
	POLL_IGNORE_LAVALAND_ELITE = "Notification: Be a lavaland boss",
	POLL_IGNORE_BLODCULT_OVERALL = "Notification: all bloodcult notifications",
	POLL_IGNORE_CLOCKWORK_OVERALL = "Notification: all clockcult notifications",
	POLL_IGNORE_SPLITPERSONALITY = "Notificaiton: Split Personality",

	POLL_IGNORE_SPECTRAL_BLADE = "Spawn Request: Necropolis Spectral blade",
	POLL_IGNORE_POSIBRAIN = "Spawn Request: Positronic brain",
	POLL_IGNORE_PAI = "Spawn Request: Personal AI",

	POLL_IGNORE_SPIDER = "Creation: Spiders eggs",
	POLL_IGNORE_ASHWALKER = "Creation: Ashwalker eggs",
	POLL_IGNORE_DRONE = "Creation: Drone shells",
	POLL_IGNORE_SWARMER = "Creation: Swarmer shells"
	POLL_IGNORE_GOLEM = "Creation: Golems shells"
))
GLOBAL_LIST_INIT(poll_ignore, init_poll_ignore())


/proc/init_poll_ignore()
	. = list()
	for (var/k in GLOB.poll_ignore_desc)
		.[k] = list()
