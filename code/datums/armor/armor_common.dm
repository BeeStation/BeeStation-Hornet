/**
 * Common armor defines. There are generally 3 tiers of armor:
 * - Civilian
 * - Security
 * - Military
 *
 * There are different materials which define different properties of
 * armour, such as metal being highly reflective.
 */

// ===============================
// Durathread
// Durathread armour
// ===============================

/datum/armor/durathread
	penetration = 40
	blunt = 20
	absorption = 50
	reflectivity = 10
	heat = 10

/datum/armor/hardhat
	penetration = 10
	blunt = 35
	absorption = 45
	reflectivity = 5
	heat = 5

/datum/armor/bulletproof
	penetration = 85
	blunt = 20
	absorption = 15
	reflectivity = 5
	heat = 5

/datum/armor/riot
	penetration = 15
	blunt = 60
	absorption = 30
	reflectivity = 5
	heat = 5

/datum/armor/foil
	penetration = 0
	blunt = 0
	absorption = 0
	reflectivity = 70
	heat = 0

/datum/armor/suit
	penetration = 3

/datum/armor/laserproof
	penetration = 10
	blunt = 20
	absorption = 50
	reflectivity = 80
	heat = 50

/datum/armor/firesuit
	penetration = 10
	blunt = 10
	absorption = 80
	heat = 80
	reflectivity = 0

/datum/armor/bomb
	penetration = 5
	blunt = 5
	absorption = 80
	heat = 100
	reflectivity = 0

// ===============================
// Padded clothing
// Unarmoured, but with some protective padding for safety.
// ===============================

/// Non-armoured but padded civilian clothing (sports protective gear)
/datum/armor/civilian_padded
	penetration = 5
	blunt = 15
	heat = 5
	absorption = 40

/// Non-armoured but padded security clothing. (Padded gloves and other protective clothing)
/datum/armor/security_padded
	penetration = 10
	blunt = 20
	heat = 10
	absorption = 50

/// For non-armoured military clothing that is padded (Military padded gloves and other protective clothing)
/datum/armor/military_padded
	penetration = 20
	blunt = 25
	heat = 10
	absorption = 70

// ===============================
// Chitin
// Made of a thick, solid fleshy material
// ===============================

/datum/armor/civilian_chitin
	penetration = 50
	blunt = 25
	heat = 5
	absorption = 100
	reflectivity = 5

/datum/armor/security_chitin
	penetration = 60
	blunt = 35
	heat = 10
	absorption = 100
	reflectivity = 5

/datum/armor/military_chitin
	penetration = 85
	blunt = 50
	heat = 15
	absorption = 100
	reflectivity = 20

// ===============================
// Metal
// Made of a solid, rigid and reflective metal.
// ===============================

/// Metal civilian clothing (Makeshift metal armour)
/datum/armor/civilian_metal
	penetration = 25
	blunt = 10
	absorption = 10
	reflectivity = 65
	heat = 5

/// Metal security items (Chaplain armour, Security hardsuits)
/datum/armor/security_metal
	penetration = 45
	blunt = 25
	absorption = 15
	reflectivity = 50
	heat = 10

/// ERT/other military hardsuits
/datum/armor/military_metal
	penetration = 60
	blunt = 40
	absorption = 30
	reflectivity = 50
	heat = 20

// ===============================
// Light Armour
// Armour designed to protect against general threats
// but is made to be light and mobile.
// ===============================

/datum/armor/civilian_light_armor
	penetration = 40
	blunt = 30
	absorption = 40
	reflectivity = 20
	heat = 20

/datum/armor/security_light_armor
	penetration = 55
	blunt = 30
	absorption = 40
	reflectivity = 30
	heat = 30

/datum/armor/military_light_armor
	penetration = 70
	blunt = 40
	absorption = 40
	reflectivity = 40
	heat = 40

// ===============================
// Heavy Armour
// Extremely strong and tough, heavy armour
// ===============================

/// Captain's armour vest
/datum/armor/civilian_heavy_armor
	penetration = 50
	blunt = 20
	absorption = 70
	reflectivity = 20
	heat = 20

/// Captain and HOS hardsuit
/datum/armor/security_heavy_armor
	penetration = 70
	blunt = 40
	absorption = 70
	reflectivity = 40
	heat = 40

/// Deathsquad and elite syndicate armours
/datum/armor/military_heavy_armor
	penetration = 90
	blunt = 60
	absorption = 95
	reflectivity = 60
	heat = 60

// ===============================
// Glass
// Fragile and not very strong
// ===============================

/datum/armor/tempered_glass
	absorption = 100
	heat = 50

/datum/armor/tempered_plasma_glass
	blunt = 20
	absorption = 100
	heat = 80

// ===============================
// Runed
// The runes protect you
// ===============================

/datum/armor/civilian_runed_cloth
	penetration = 40
	blunt = 30
	absorption = 90
	reflectivity = 40
	heat = 40

/datum/armor/security_runed_cloth
	penetration = 55
	blunt = 40
	absorption = 90
	reflectivity = 50
	heat = 50

/datum/armor/military_runed_cloth
	penetration = 70
	blunt = 50
	absorption = 90
	reflectivity = 60
	heat = 50

// ===============================
// Generic
// For various armours that need to fit outside these categories
// ===============================
