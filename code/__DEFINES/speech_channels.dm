// Used to direct channels to speak into.
#define SAY_CHANNEL "Say"
#define RADIO_CHANNEL "Radio"
#define ME_CHANNEL "Me"
#define OOC_CHANNEL "OOC"
#define LOOC_CHANNEL "LOOC"

// Locked channels
#define ASAY_CHANNEL "Asay"
#define DSAY_CHANNEL "Dsay"
#define MSAY_CHANNEL "Msay"

/// These cannot be GLORFED since they are either OOC or somewhat OOC if leaked early
GLOBAL_LIST_INIT(leakless_channels, list(
	ME_CHANNEL,
	OOC_CHANNEL,
	LOOC_CHANNEL,
	ASAY_CHANNEL,
	DSAY_CHANNEL,
	MSAY_CHANNEL,
))

/// These are entirely OOC
GLOBAL_LIST_INIT(ooc_channels, list(
	OOC_CHANNEL,
	LOOC_CHANNEL,
	ASAY_CHANNEL,
	DSAY_CHANNEL,
	MSAY_CHANNEL,
))
