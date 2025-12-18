
#define DISEASE_LIMIT		1
#define VIRUS_SYMPTOM_LIMIT	6

// Visibility Flags
#define HIDDEN_SCANNER	(1<<0)
#define HIDDEN_PANDEMIC	(1<<1)

// Disease Flags
#define CURABLE		(1<<0)
#define CAN_CARRY	(1<<1)
#define CAN_RESIST	(1<<2)

// Spread Flags
#define DISEASE_SPREAD_SPECIAL			(1<<0)
#define DISEASE_SPREAD_NON_CONTAGIOUS	(1<<1)
#define DISEASE_SPREAD_BLOOD			(1<<2)
#define DISEASE_SPREAD_CONTACT_FLUIDS	(1<<3)
#define DISEASE_SPREAD_CONTACT_SKIN 	(1<<4)
#define DISEASE_SPREAD_AIRBORNE			(1<<5)
#define DISEASE_SPREAD_FALTERED			(1<<6)

//! ## Disease Danger Defines
#define DISEASE_BENEFICIAL "Beneficial"//! Symptoms that are very beneficial, whose benefits far outweigh downsides
#define DISEASE_POSITIVE	"Positive"  //! Symptoms that buff or heal, but may have minor downsides, or minor effects
#define DISEASE_NONTHREAT	"Harmless"  //! Symptoms that have no concrete mechanical effects that effect the host in any meaningful way (itching)
#define DISEASE_MINOR		"Minor"	    //! Symptoms that can annoy in concrete ways (dizziness)
#define DISEASE_MEDIUM		"Medium"    //! Diseases that can do minor harm, or severe annoyance (vomit)
#define DISEASE_HARMFUL	"Harmful"   //! Diseases that can do significant harm, or severe disruption (brainrot)
#define DISEASE_DANGEROUS	"Dangerous"  //! Diseases that are lethal if untreated (flesh eating)
#define DISEASE_BIOHAZARD	"BIOHAZARD" //! Symptoms that can quickly kill an unprepared victim (fungal tb, gbs)
#define DISEASE_PANDEMIC	"PANDEMIC"  //! Symptoms so deadly you will likely die before being cured (ARDS, autophageocytosis)

#define EXTRAPOLATOR_RESULT_DISEASES		"extrapolator_result_disease"
#define EXTRAPOLATOR_RESULT_ACT_PRIORITY	"extrapolator_result_action_priority"
#define EXTRAPOLATOR_ACT_PRIORITY_SPECIAL	"extrapolator_action_priority_special"
#define EXTRAPOLATOR_ACT_PRIORITY_ISOLATE	"extrapolator_action_priority_isolate"
#define EXTRAPOLATOR_ACT_CHECK(target_list, wanted_action_priority) (##target_list[EXTRAPOLATOR_RESULT_ACT_PRIORITY] == ##wanted_action_priority)
