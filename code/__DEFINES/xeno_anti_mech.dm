// Xeno counterplay against mechs: Corrosive Acid on mechs, resin snare mines and the Queen's Crack Open.

/// Fraction of a mech's max integrity that one dose of xeno acid burns away. Four doses destroy any chassis.
#define MECHA_ACID_DOSE_FRACTION 0.25
/// Seconds one dose of acid keeps burning.
#define MECHA_ACID_BURN_SECONDS 20
/// Seconds the pilot's optics stay smeared after the latest dose.
#define MECHA_ACID_SMEAR_SECONDS 120
/// Percent chance for a dose to break one of the mech's systems.
#define MECHA_ACID_FAILURE_CHANCE 33

/// Snare strength, counted in seconds of hold: a pilot who never struggles is stuck this long.
#define XENO_SNARE_HOLD_SECONDS 15
/// Strength one struggle tears away (10% of a full snare).
#define XENO_SNARE_STRUGGLE_STRENGTH 1.5
/// Minimum time between two struggles that count.
#define XENO_SNARE_STRUGGLE_COOLDOWN (0.5 SECONDS)

/// How long the Queen has to hold a mech to crack it open.
#define CRACK_OPEN_CHANNEL_TIME (6 SECONDS)
/// Knockdown for pilots the Queen drags out.
#define CRACK_OPEN_EJECT_KNOCKDOWN (2 SECONDS)

/// Pilot alert category: the mech is snared.
#define ALERT_MECH_SNARED "mech_snared"
/// Pilot alert category: acid is on the hull.
#define ALERT_MECH_ACID "mech_acid"
/// Fullscreen category for the acid smear over the pilot's view.
#define FULLSCREEN_MECHA_ACID "mecha_acid"
