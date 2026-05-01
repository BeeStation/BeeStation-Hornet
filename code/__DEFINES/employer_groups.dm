// Employer groups. High-level "who do you work for" grouping above departments.
// Used by the character creation occupation tab and the latejoin job window.
// One employer owns one or more existing department_groups (by dept_id).
//
// Adding a new employer:
//   1. Add an EMPLOYER_ID_* macro here.
//   2. Add a /datum/employer_group subtype in employer_groups.dm referencing it.
//   3. Make sure every department_id it claims is owned by exactly one employer
//      across all subtypes (SSemployer init validates this).

#define EMPLOYER_ID_NANOTRASEN           "nanotrasen"
#define EMPLOYER_ID_STATIONSIDE_SERVICES "stationside_services"
#define EMPLOYER_ID_AURI_SECURITY        "auri_security"
#define EMPLOYER_ID_ECLIPSE_EXPRESS      "eclipse_express"
#define EMPLOYER_ID_NAKAMURA_ENGINEERING "nakamura_engineering"
#define EMPLOYER_ID_ACRUX_MEDICAL        "acrux_medical"
#define EMPLOYER_ID_NON_CREW             "non_crew"

// Sort order for the employer dropdown (lower = first).
#define EMPLOYER_PREF_ORDER_NANOTRASEN           10
#define EMPLOYER_PREF_ORDER_STATIONSIDE_SERVICES 20
#define EMPLOYER_PREF_ORDER_AURI_SECURITY        30
#define EMPLOYER_PREF_ORDER_ECLIPSE_EXPRESS      40
#define EMPLOYER_PREF_ORDER_NAKAMURA_ENGINEERING 50
#define EMPLOYER_PREF_ORDER_ACRUX_MEDICAL        60
#define EMPLOYER_PREF_ORDER_NON_CREW             70
