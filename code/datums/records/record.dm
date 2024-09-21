/**
 * Record datum. Used for crew records and admin locked records.
 */
/datum/record
	/// Age of the character
	var/age
	/// Their blood type
	var/blood_type
	/// Character appearance
	var/mutable_appearance/character_appearance
	/// DNA string
	var/dna_string
	/// Fingerprint string (md5)
	var/fingerprint
	/// The character's gender
	var/gender
	/// The character's initial rank at roundstart
	var/initial_rank
	/// The character's name
	var/name = "Unknown"
	/// The character's rank
	var/rank
	/// The character's species
	var/species

/datum/record/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
)
	src.age = age
	src.blood_type = blood_type
	src.character_appearance = character_appearance
	src.dna_string = dna_string
	src.fingerprint = fingerprint
	src.gender = gender
	src.initial_rank = rank
	src.name = name
	src.rank = rank
	src.species = species

/**
 * Crew record datum
 */
/datum/record/crew
	/// List of citations
	var/list/citations = list()
	/// List of crimes
	var/list/crimes = list()
	/// Unique ID generated that is used to fetch lock record
	var/lock_ref
	/// Names of major disabilities
	var/major_disabilities
	/// Fancy description of major disabilities
	var/major_disabilities_desc
	/// List of medical notes
	var/list/medical_notes = list()
	/// Names of minor disabilities
	var/minor_disabilities
	/// Fancy description of minor disabilities
	var/minor_disabilities_desc
	/// Physical status of this person in medical records.
	var/physical_status
	/// Mental status of this person in medical records.
	var/mental_status
	/// Positive and neutral quirk strings
	var/quirk_notes
	/// Security note
	var/security_note
	/// Current arrest status
	var/wanted_status = null

	///Photo used for records, which we store here so we don't have to constantly make more of.
	var/list/obj/item/photo/record_photos

/datum/record/crew/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	/// Crew specific
	lock_ref,
	major_disabilities = "None",
	major_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	minor_disabilities = "None",
	minor_disabilities_desc = "No disabilities have been diagnosed at the moment.",
	physical_status = PHYSICAL_ACTIVE,
	mental_status = MENTAL_STABLE,
	quirk_notes,
)
	. = ..()
	src.lock_ref = lock_ref
	src.major_disabilities = major_disabilities
	src.major_disabilities_desc = major_disabilities_desc
	src.minor_disabilities = minor_disabilities
	src.minor_disabilities_desc = minor_disabilities_desc
	src.physical_status = physical_status
	src.mental_status = mental_status
	src.quirk_notes = quirk_notes

	GLOB.manifest.general += src

/datum/record/crew/Destroy()
	GLOB.manifest.general -= src
	QDEL_LAZYLIST(record_photos)
	return ..()

/**
 * Admin locked record
 */
/datum/record/locked
	/// Mob's dna
	var/datum/dna/locked_dna
	/// Mind datum
	var/datum/weakref/mind_ref
	/// Typepath of species used by player, for usage in respawning via records
	var/species_type

/datum/record/locked/New(
	age = 18,
	blood_type = "?",
	character_appearance,
	dna_string = "Unknown",
	fingerprint = "?????",
	gender = "Other",
	initial_rank = "Unassigned",
	name = "Unknown",
	rank = "Unassigned",
	species = "Human",
	/// Locked specific
	datum/dna/locked_dna,
	datum/mind/mind_ref,
)
	. = ..()
	src.locked_dna = locked_dna
	src.mind_ref = WEAKREF(mind_ref)
	species_type = locked_dna.species.type

	GLOB.manifest.locked += src

/datum/record/locked/Destroy()
	GLOB.manifest.locked -= src
	return ..()
