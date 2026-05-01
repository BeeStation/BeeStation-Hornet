// Employer groups: above-department grouping used by the prefs/latejoin UI.

/datum/employer_group
	/// EMPLOYER_ID_* string. Must be unique. Subtypes MUST set this.
	var/id = null
	/// Player-facing name.
	var/display_name = "Unknown"
	/// In-character lore blurb shown in the info box.
	var/lore = ""
	var/logo_icon = 'icons/ui/employer_logos.dmi'
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
//   Owns: Station Administration (Command), Research Division (Science),
//   Silicon Intelligences (Silicon).
// ---------------------------------------------------------------------
/datum/employer_group/nanotrasen
	id = EMPLOYER_ID_NANOTRASEN
	display_name = "Nanotrasen"
	colour = "#5d7dff"
	pref_order = EMPLOYER_PREF_ORDER_NANOTRASEN
	logo_icon_state = "nanotrasen"
	department_ids = list(DEPT_NAME_COMMAND, DEPT_NAME_SCIENCE, DEPT_NAME_SILICON)
	lore = "Nanotrasen is a power-house in technology-related industries with several subsidiaries providing anything from defence related technologies, gene-operations, and unproven high-risk research.<br><br>\
			It is the leading plasma research corporation in the Auri system and the direct operator of this station. Its focus on plasma study, containment, and commercialization drives most on-site operations. <b>Their work is tightly controlled and often classified.</b><br><br>\
			Nanotrasen's ambition has earned it both influence and enemies, but its reach remains unmatched. Working under its banner means access to cutting-edge discovery, and accepting that corporate goals always come first."

// ---------------------------------------------------------------------
//                         Stationside Services
//   Owns: Galley Operations (Service), Habitation Services (Civilian),
//   Recreation. Low-ranking civilian personnel renting space on the
//   station; respond to the Head of Personnel via the chain of command.
// ---------------------------------------------------------------------
/datum/employer_group/stationside_services
	id = EMPLOYER_ID_STATIONSIDE_SERVICES
	display_name = "Stationside Services"
	colour = "#7fb368"
	logo_icon_state = "services"
	pref_order = EMPLOYER_PREF_ORDER_STATIONSIDE_SERVICES
	department_ids = list(DEPT_NAME_SERVICE, DEPT_NAME_CIVILIAN, DEPT_NAME_RECREATION)
	lore = "<b> Stationside Services are hired by, employed by, and contracted to the station. The Head of Personnel has the ultimate say over their operations.</b><br><br>\
			A loose group of low-ranking civilian personnel renting space on the station to provide necessary services such as catering, gardening, \
			and entertainment. <br><br>\
			They are too far below the corporate ladder for company politics to matter, most are just trying to make rent."

// ---------------------------------------------------------------------
//                          Auri Private Security
//   Owns: Enforcement (Security), Support Staff. Subsidiary of Nanotrasen
//   handling onboard security; the Tellune government doesn't allow
//   stations to run their own.
// ---------------------------------------------------------------------
/datum/employer_group/auri_security
	id = EMPLOYER_ID_AURI_SECURITY
	display_name = "Auri Private Security"
	colour = "#8b2f2f"
	logo_icon_state = "aps"
	pref_order = EMPLOYER_PREF_ORDER_AURI_SECURITY
	department_ids = list(DEPT_NAME_SECURITY, DEPT_NAME_SUPPORT)
	lore = "APS, or AuSec, is a subsidiary of Nanotrasen, contracted to provide security on NT stations because of Telgov regulations concerning the operation of private security forces on a corporation's own vessels. <br><br>\
	Though the Tellune government would prefer stations to rely on SpacePol for security, the reality of their stretched resources means that private contractors such as APS have become a common necessity.<br><br>\
	Its board consists of previous Nanotrasen managers and executives 'promoted' to C-suite positions to move them out of Nanotrasen's more important projects. Despite high-levels of performance, this method of political promotion harbours animosity between Nanotrasen and AuSec executives to this day."

// ---------------------------------------------------------------------
//                            Eclipse Express
//   Owns: Supply Operations (Cargo). Shipping company with a near-monopoly
//   on supply runs in the Lavaland orbital region.
// ---------------------------------------------------------------------
/datum/employer_group/eclipse_express
	id = EMPLOYER_ID_ECLIPSE_EXPRESS
	display_name = "Eclipse Express"
	colour = "#b48548ff"
	logo_icon_state = "eclipse"
	pref_order = EMPLOYER_PREF_ORDER_ECLIPSE_EXPRESS
	department_ids = list(DEPT_NAME_CARGO)
	lore = "Eclipse Express runs supply stations across the orbit of Cinis. Thanks to the still-developing nature of the region they enjoy what amounts	to a monopoly over station imports and exports. <br><br>\
	Headquartered in Auri itself, a decision that lets them pull continual returns without waiting \
	twenty-three years for a transfer window back to Geminae."


// ---------------------------------------------------------------------
//                          Nakamura Engineering
//   Owns: Engineering Staff. Half-engineering, half-research contractor
//   that maintains the station's bespoke supermatter and atmospherics.
// ---------------------------------------------------------------------
/datum/employer_group/nakamura_engineering
	id = EMPLOYER_ID_NAKAMURA_ENGINEERING
	display_name = "Nakamura Engineering"
	colour = "#d6c14c"
	logo_icon_state = "nakamura"
	pref_order = EMPLOYER_PREF_ORDER_NAKAMURA_ENGINEERING
	department_ids = list(DEPT_NAME_ENGINEERING)
	lore = "LORE WIP: A small contracting company, one of the few capable of maintaining \
	the rare moth-tech supermatter reactors aboard the station. Nakamura \
	didn't build them, but they're trained in their upkeep, and they run \
	atmospherics and gas research alongside their primary engineering duties."


// ---------------------------------------------------------------------
//                       Acrux Medical Technologies
//   Owns: Medical Staff. Private medical contractor with a flexible-payment
//   "treat anyone who pays" policy.
// ---------------------------------------------------------------------
/datum/employer_group/acrux_medical
	id = EMPLOYER_ID_ACRUX_MEDICAL
	display_name = "Acrux Medical Technologies"
	colour = "#5fb6c8"
	logo_icon_state = "acrux"
	pref_order = EMPLOYER_PREF_ORDER_ACRUX_MEDICAL
	department_ids = list(DEPT_NAME_MEDICAL)
	lore = "LORE WIP: Acrux Medical Technologies provides medical services for a wide \
	array of corporate clients. Their stated policy is to work with anyone if \
	the price is right. Acrux offers tiered health packages: From basic \
	treatment to full monitoring and recovery, with flexible instalment plans."


// ---------------------------------------------------------------------
//                                Non-Crew
//   Owns: Fugitives and Miscreants (Unassigned), Visitors (VIP).
//   People aboard the station who aren't on the formal crew roster.
// ---------------------------------------------------------------------
/datum/employer_group/non_crew
	id = EMPLOYER_ID_NON_CREW
	display_name = "Non-Crew"
	colour = "#777777"
	pref_order = EMPLOYER_PREF_ORDER_NON_CREW
	logo_icon_state = "non_crew"
	department_ids = list(DEPT_NAME_UNASSIGNED, DEPT_NAME_VIP)
	lore = "People aboard the station who aren't on the crew roster: prisoners \
	working off their sentences, stowaways, drifters, visitors, \
	and other unlisted bodies."
