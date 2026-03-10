//suit sensors: sensor_mode defines
/// Suit sensor was not changed by user
#define SENSOR_NOT_SET -1
/// Suit sensor is turned off
#define SENSOR_OFF 0
/// Suit sensor displays the mob as alive or dead
#define SENSOR_LIVING 1
/// Suit sensor displays the mob damage values
#define SENSOR_VITALS 2
/// Suit sensor displays the mob damage values and exact location
#define SENSOR_COORDS 3

//suit sensors: has_sensor defines
/// Suit sensor has been EMP'd and cannot display any information (can be fixed)
#define BROKEN_SENSORS -1
/// Suit sensor is not present and cannot display any information
#define NO_SENSORS 0
/// Suit sensor is present and can display information
#define HAS_SENSORS 1
/// Suit sensor is present and is forced to display information (used on prisoner jumpsuits)
#define LOCKED_SENSORS 2

/*
	Bit flags for clothing restrictions
*/
#define RESTRICTION_SHOES (1<<0)
#define RESTRICTION_EARS	(1<<1)
#define RESTRICTION_GLASSES (1<<2)
#define RESTRICTION_GLOVES (1<<3)
#define RESTRICTION_HEAD (1<<4)
#define RESTRICTION_MASK (1<<5)
#define RESTRICTION_NECK (1<<6)
#define RESTRICTION_SUIT (1<<7)
#define RESTRICTION_UNDER (1<<8)
