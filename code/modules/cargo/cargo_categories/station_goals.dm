/**
 * # Station Goal Crates
 *
 * Pre-assembled crate orders for station goals. These use the cargo_crate datum
 * and are enabled at runtime when station goals fire their on_report() proc.
 *
 * All station goal crates are special = TRUE and only appear once enabled.
 */

// --- Bluespace Artillery ---
/datum/cargo_crate/station_goal/

/datum/cargo_crate/station_goal/bsa
	name = "Bluespace Artillery Parts"
	desc = "The pride of Nanotrasen Naval Command. Contains all circuit boards needed to construct BSA artillery."
	cost = 15000
	max_supply = 1
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(
		/obj/item/circuitboard/machine/bsa/front,
		/obj/item/circuitboard/machine/bsa/middle,
		/obj/item/circuitboard/machine/bsa/back,
		/obj/item/circuitboard/computer/bsa_control,
	)

// --- DNA Vault ---

/datum/cargo_crate/station_goal/dna_vault
	name = "DNA Vault Parts"
	desc = "Contains the DNA Vault circuit board and five DNA probes."
	cost = 12000
	max_supply = 1
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(
		/obj/item/circuitboard/machine/dna_vault,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
	)

/datum/cargo_crate/station_goal/dna_probes
	name = "DNA Vault Samplers"
	desc = "Contains five DNA probes for use in the DNA vault."
	cost = 3000
	max_supply = 4
	special = TRUE
	access_budget = ACCESS_HEADS
	contains = list(
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
		/obj/item/dna_probe,
	)

// --- Bluespace Harvester ---

/datum/cargo_crate/station_goal/bluespace_tap
	name = "Bluespace Harvester Parts"
	desc = "Contains the Bluespace Harvester circuit board and instruction manual."
	cost = 15000
	max_supply = 1
	special = TRUE
	contains = list(
		/obj/item/circuitboard/machine/bluespace_tap,
		/obj/item/paper/bluespace_tap,
	)

// --- Shuttle Engine (enabled by airless emergency shuttle) ---

/datum/cargo_crate/station_goal/shuttle_engine
	name = "Shuttle Engine Crate"
	desc = "Through advanced bluespace-shenanigans, our engineers have managed to fit an entire shuttle engine into one tiny little crate. Requires CE access to open."
	cost = 5000
	max_supply = 2
	access = ACCESS_CE
	access_budget = ACCESS_CE
	special = TRUE
	contains = list(/obj/structure/shuttle/engine/propulsion/burst/cargo)
	crate_type = /obj/structure/closet/crate/secure/engineering
