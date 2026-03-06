// Max limits
#define CLOCKCULT_COGSCARAB_LIMIT 8
#define CLOCKCULT_MARAUDER_LIMIT 4

// Invokation speech types
#define INVOKATION_WHISPER 1
#define INVOKATION_SPOKEN 2
#define INVOKATION_SHOUT 3

/// How far transmission sigils transmit power
#define SIGIL_TRANSMISSION_RANGE 4

/// Clockcult drone
#define CLOCKDRONE "drone_clock"

// Scripture types
/// Undefined
#define SPELLTYPE_ABSTRACT "Abstract"
/// Conversion
#define SPELLTYPE_SERVITUDE "Servitude"
/// Health
#define SPELLTYPE_PRESERVATION "Preservation"
/// Structures
#define SPELLTYPE_STRUCTURES "Structures"

// Conversion warning stages
#define CONVERSION_WARNING_NONE 0
#define CONVERSION_WARNING_HALFWAY 1
#define CONVERSION_WARNING_THREEQUARTERS 2
#define CONVERSION_WARNING_CRITIAL 3

// Prefix types. Not strings because we assign different values per person. i.e: Clockfather or Clockmother
#define CLOCKCULT_PREFIX_EMINENCE 2
#define CLOCKCULT_PREFIX_MASTER 1
#define CLOCKCULT_PREFIX_RECRUIT 0

/// Helper macro to check if an atom is on Reebe virtual z-level
#define is_on_reebe(atom) atom.get_virtual_z_level() == REEBE_VIRTUAL_Z
