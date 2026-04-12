// List of Record Arguments to make things safer
// I know this looks extremely wonky, but it's better than manual management... Believe me.

/// This macro does nothing - It is to give you a hint where you should take a look into
#define RECORD_STRICT_ARGS_NONE

#define RECORD_ARG_01 age
#define RECORD_ARG_02 blood_type
#define RECORD_ARG_03 character_appearance
#define RECORD_ARG_04 unique_enzymes
#define RECORD_ARG_05 unique_identity
#define RECORD_ARG_06 fingerprint
#define RECORD_ARG_07 gender
#define RECORD_ARG_08 initial_rank
#define RECORD_ARG_09 name
#define RECORD_ARG_10 rank
#define RECORD_ARG_11 species
#define RECORD_ARG_12 hud
#define RECORD_ARG_13 active_department

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13

#define RECORD_LOCK_ARG_01 weakref_dna
#define RECORD_LOCK_ARG_02 weakref_mind
#define RECORD_LOCK_ARG_03 datum_dna

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_LOCK_STRICT_ARGS(arg01, arg02, arg03)\
arg01, arg02, arg03

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_CREW_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11

#define RECORD_CREW_ARG_01 lock_ref
#define RECORD_CREW_ARG_02 medical_notes
#define RECORD_CREW_ARG_03 major_disabilities
#define RECORD_CREW_ARG_04 major_disabilities_desc
#define RECORD_CREW_ARG_05 minor_disabilities
#define RECORD_CREW_ARG_06 minor_disabilities_desc
#define RECORD_CREW_ARG_07 physical_status
#define RECORD_CREW_ARG_08 mental_status
#define RECORD_CREW_ARG_09 quirk_notes
#define RECORD_CREW_ARG_10 security_note
#define RECORD_CREW_ARG_11 wanted_status

/// Strict the number of args, so that you won't make any mistake.
#define RECORD_CLONE_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12, arg13, arg14, arg15, arg16, arg17

#define RECORD_CLONE_ARG_01 RECORD_ARG_01 // age
#define RECORD_CLONE_ARG_02 RECORD_ARG_02 // blood_type
						// RECORD_ARG_03 unused
#define RECORD_CLONE_ARG_03 RECORD_ARG_04 // unique_enzymes
#define RECORD_CLONE_ARG_04 RECORD_ARG_05 // unique_identity
#define RECORD_CLONE_ARG_05 RECORD_ARG_06 // fingerprint
#define RECORD_CLONE_ARG_06 RECORD_ARG_07 // gender
#define RECORD_CLONE_ARG_07 RECORD_ARG_08 // initial_rank
#define RECORD_CLONE_ARG_08 RECORD_ARG_09 // name
						// RECORD_ARG_10 unused
#define RECORD_CLONE_ARG_09 RECORD_ARG_11 // species
						// RECORD_ARG_12 unused
						// RECORD_ARG_13 unused
#define RECORD_CLONE_ARG_10 datum_dna
#define RECORD_CLONE_ARG_11 weakref_mind
#define RECORD_CLONE_ARG_12 last_death
#define RECORD_CLONE_ARG_13 factions
#define RECORD_CLONE_ARG_14 traumas
#define RECORD_CLONE_ARG_15 body_only
#define RECORD_CLONE_ARG_16 implant
#define RECORD_CLONE_ARG_17 bank_account

/// Strict the number of args, so that you won't make any mistake.
#define CLONING_STRICT_ARGS(arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12)\
arg01, arg02, arg03, arg04, arg05, arg06, arg07, arg08, arg09, arg10, arg11, arg12
