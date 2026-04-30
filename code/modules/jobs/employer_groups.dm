// Employer groups: above-department grouping used by the prefs/latejoin UI.

/datum/employer_group
	/// EMPLOYER_ID_* string. Must be unique. Subtypes MUST set this.
	var/id = null
	/// Player-facing name.
	var/display_name = "Unknown"
	/// In-character lore blurb shown in the info box. Plain text.
	var/lore = ""
	/// Icon file the logo is sourced from. Referenced as a file literal so
	/// BYOND ships the DMI to the client via the asset cache (the way the
	/// vampire clan UI does it). Subtypes can override this if they want to
	/// pull from a different DMI.
	var/logo_icon = 'icons/ui/employer_logos.dmi'
	/// Icon state in `logo_icon`.
	var/logo_icon_state = null
	/// Accent colour (hex). Used by the info box border / label.
	var/colour = "#888888"

	/// Sort order for the employer dropdown (ascending).
	var/pref_order = 100

	/// List of dept_id strings (DEPT_NAME_*) this employer owns.
	/// Departments are still rendered in their declared order; this list
	/// also defines the order they appear under the employer.
	var/list/department_ids = list()


// ---------------------------------------------------------------------
//                              Nanotrasen
//   Owns: Command, Science. Captain & Head of Personnel are also placed
//   here via /datum/job.employer_id_override (see _job.dm).
// ---------------------------------------------------------------------
/datum/employer_group/nanotrasen
	id = EMPLOYER_ID_NANOTRASEN
	display_name = "Nanotrasen"
	colour = "#5d7dff"
	pref_order = EMPLOYER_PREF_ORDER_NANOTRASEN
	logo_icon_state = "nanotrasen"
	department_ids = list(DEPT_NAME_COMMAND, DEPT_NAME_SCIENCE)
	lore = "LORE WIP: Nanotrasen is an increasingly dominant plasma research corporation \
	and the direct operator of this station. Command and Science staff are \
	employed by Nanotrasen itself; classified research and the experimentation \
	of plasma fall under their direct purview."


// ---------------------------------------------------------------------
//                          Auri Private Security
//   Owns: Security. Subsidiary of Nanotrasen handling onboard security
//   because the Tellune government doesn't allow stations to run their own.
// ---------------------------------------------------------------------
/datum/employer_group/auri_security
	id = EMPLOYER_ID_AURI_SECURITY
	display_name = "Auri Private Security"
	colour = "#c44d4d"
	pref_order = EMPLOYER_PREF_ORDER_AURI_SECURITY
	logo_icon_state = "auri_security"
	department_ids = list(DEPT_NAME_SECURITY)
	lore = "LORE WIP: A subsidiary of Nanotrasen, contracted to provide security on \
	NT stations because the Tellune government forbids station administrations \
	from running their own security forces. Originally formed to insulate \
	Nanotrasen's riskier endeavours, APS's executive board still harbours \
	quiet animosity toward its parent company."


// ---------------------------------------------------------------------
//                         Stationside Services
//   Owns: Service, Civilian. Low-ranking civilian personnel renting space
//   on the station for catering, hydroponics, etc.
// ---------------------------------------------------------------------
/datum/employer_group/stationside_services
	id = EMPLOYER_ID_STATIONSIDE_SERVICES
	display_name = "Stationside Services"
	colour = "#7fb368"
	pref_order = EMPLOYER_PREF_ORDER_STATIONSIDE_SERVICES
	logo_icon_state = "stationside_services"
	department_ids = list(DEPT_NAME_SERVICE, DEPT_NAME_CIVILIAN)
	lore = "LORE WIP: A loose group of low-ranking civilian personnel renting space \
	on the station to provide necessary services such as catering, gardening, \
	and entertainment. They are too far below the corporate ladder for company \
	politics to matter, most are just trying to make rent."


// ---------------------------------------------------------------------
//                            Eclipse Express
//   Owns: Cargo. Shipping company with a near-monopoly on supply runs
//   in the Lavaland orbital region.
// ---------------------------------------------------------------------
/datum/employer_group/eclipse_express
	id = EMPLOYER_ID_ECLIPSE_EXPRESS
	display_name = "Eclipse Express"
	colour = "#c8924a"
	pref_order = EMPLOYER_PREF_ORDER_ECLIPSE_EXPRESS
	logo_icon_state = "eclipse_express"
	department_ids = list(DEPT_NAME_CARGO)
	lore = "LORE WIP: Eclipse Express runs supply stations across the orbit of Cinis. \
	Thanks to the still-developing nature of the region they enjoy what amounts \
	to a monopoly over station imports and exports. Headquartered in Auri \
	itself, a decision that lets them pull continual returns without waiting \
	twenty-three years for a transfer window back to Geminae."


// ---------------------------------------------------------------------
//                          Nakamura Engineering
//   Owns: Engineering. Half-engineering, half-research contractor that
//   maintains the station's bespoke supermatter and atmospherics systems.
// ---------------------------------------------------------------------
/datum/employer_group/nakamura_engineering
	id = EMPLOYER_ID_NAKAMURA_ENGINEERING
	display_name = "Nakamura Engineering"
	colour = "#d6c14c"
	pref_order = EMPLOYER_PREF_ORDER_NAKAMURA_ENGINEERING
	logo_icon_state = "nakamura_engineering"
	department_ids = list(DEPT_NAME_ENGINEERING)
	lore = "LORE WIP: A small contracting company, one of the few capable of maintaining \
	the rare moth-tech supermatter reactors aboard the station. Nakamura \
	didn't build them, but they're trained in their upkeep, and they run \
	atmospherics and gas research alongside their primary engineering duties."


// ---------------------------------------------------------------------
//                       Acrux Medical Technologies
//   Owns: Medical. Private medical contractor with a flexible-payment
//   "treat anyone who pays" policy.
// ---------------------------------------------------------------------
/datum/employer_group/acrux_medical
	id = EMPLOYER_ID_ACRUX_MEDICAL
	display_name = "Acrux Medical Technologies"
	colour = "#5fb6c8"
	pref_order = EMPLOYER_PREF_ORDER_ACRUX_MEDICAL
	logo_icon_state = "acrux_medical"
	department_ids = list(DEPT_NAME_MEDICAL)
	lore = "LORE WIP: Acrux Medical Technologies provides medical services for a wide \
	array of corporate clients. Their stated policy is to work with anyone if \
	the price is right. Acrux offers tiered health packages: From basic \
	treatment to full monitoring and recovery, with flexible instalment plans."


// ---------------------------------------------------------------------
//                                Silicons
//   Owns: Silicon. AI and cyborg roles.
// ---------------------------------------------------------------------
/datum/employer_group/silicons
	id = EMPLOYER_ID_SILICONS
	display_name = "Silicons"
	colour = "#a0d99a"
	pref_order = EMPLOYER_PREF_ORDER_SILICONS
	logo_icon_state = "silicons"
	department_ids = list(DEPT_NAME_SILICON)
	lore = "LORE WIP: Synthetic intelligences bound to lawsets and the cyborg shells they \
	puppet. Silicons technically belong to whoever owns their core, but they \
	answer to their laws first."


// ---------------------------------------------------------------------
//                                Non-Crew
//   Owns: no department_group directly. Prisoner is mapped here via
//   /datum/job/prisoner.employer_id_override. Reserved for future
//   non-crew roles (stowaways, etc.).
// ---------------------------------------------------------------------
/datum/employer_group/non_crew
	id = EMPLOYER_ID_NON_CREW
	display_name = "Non-Crew"
	colour = "#777777"
	pref_order = EMPLOYER_PREF_ORDER_NON_CREW
	logo_icon_state = "non_crew"
	department_ids = list() // jobs reach here only via employer_id_override
	lore = "People aboard the station who aren't on the crew roster: prisoners \
	working off their sentences, stowaways, drifters, visitors, \
	and other unlisted bodies."
