/// Checks if an object is covered in blood
#define HAS_BLOOD_DNA(thing) (length(thing.GetComponent(/datum/component/forensics)?.blood_DNA))

//Bloody shoes/footprints
/// Maximum possible value
#define MAX_SHOE_BLOODINESS 100
/// Amount the default alpha
#define BLOODY_FOOTPRINT_BASE_ALPHA 150
/// Amount gained in each step
#define BLOOD_GAIN_PER_STEP 100
/// Amount lost in each step
#define BLOOD_LOSS_PER_STEP 5
/// Amount lost in spread
#define BLOOD_LOSS_IN_SPREAD 20
/// Amount in each decal
#define BLOOD_AMOUNT_PER_DECAL 20

//Bloody shoe blood states
/// Red blood
#define BLOOD_STATE_HUMAN "blood"
/// Green xeno blood
#define BLOOD_STATE_XENO "xeno"
/// Black robot oil
#define BLOOD_STATE_OIL "oil"
/// No blood is present
#define BLOOD_STATE_NOT_BLOODY "no blood whatsoever"
