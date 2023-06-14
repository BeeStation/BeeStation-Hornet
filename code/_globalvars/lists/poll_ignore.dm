//Each lists stores ckeys for "Never for this round" option category

#define POLL_IGNORE_ALIEN_LARVA "alien_larva"
#define POLL_IGNORE_ASHWALKER "ashwalker"
#define POLL_IGNORE_BLOB_HELPER "blob_helper"
#define POLL_IGNORE_CLOCKWORK_HELPER "clockwork_helper"
#define POLL_IGNORE_CULT_SHADE "cult_shade"
#define POLL_IGNORE_GOLEM "golem"
#define POLL_IGNORE_DRONE "drone"
#define POLL_IGNORE_HOLYCARP "holy_carp"
#define POLL_IGNORE_HOLYUNDEAD "holy_undead"
#define POLL_IGNORE_PAI "pai"
#define POLL_IGNORE_POSIBRAIN "posibrain"
#define POLL_IGNORE_SPECTRAL_BLADE "spectral_blade"
#define POLL_IGNORE_SHADE "shade"
#define POLL_IGNORE_SPIDER "spider"
#define POLL_IGNORE_MRAT "mrat"
#define POLL_IGNORE_WIZARD_HELPER "wizard_helper"

GLOBAL_LIST_INIT(poll_ignore_list, list(
	POLL_IGNORE_ALIEN_LARVA,
	POLL_IGNORE_ASHWALKER,
	POLL_IGNORE_BLOB_HELPER,
	POLL_IGNORE_CLOCKWORK_HELPER,
	POLL_IGNORE_CULT_SHADE,
	POLL_IGNORE_GOLEM,
	POLL_IGNORE_DRONE,
	POLL_IGNORE_HOLYCARP,
	POLL_IGNORE_HOLYUNDEAD,
	POLL_IGNORE_PAI,
	POLL_IGNORE_POSIBRAIN,
	POLL_IGNORE_SPECTRAL_BLADE,
	POLL_IGNORE_SHADE,
	POLL_IGNORE_SPIDER,
	POLL_IGNORE_MRAT,
	POLL_IGNORE_WIZARD_HELPER,
))
GLOBAL_LIST_INIT(poll_ignore, init_poll_ignore())


/proc/init_poll_ignore()
	. = list()
	for (var/k in GLOB.poll_ignore_list)
		.[k] = list()
