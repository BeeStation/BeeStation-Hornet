
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

//! ## Severity Defines
#define DISEASE_SEVERITY_BENEFICIAL "Beneficial"//! Symptoms that are very beneficial, whose benefits far outweigh downsides
#define DISEASE_SEVERITY_POSITIVE	"Positive"  //! Symptoms that buff or heal, but may have minor downsides, or minor effects
#define DISEASE_SEVERITY_NONTHREAT	"Harmless"  //! Symptoms that have no concrete mechanical effects that effect the host in any meaningful way (itching)
#define DISEASE_SEVERITY_MINOR		"Minor"	    //! Symptoms that can annoy in concrete ways (dizziness)
#define DISEASE_SEVERITY_MEDIUM		"Medium"    //! Diseases that can do minor harm, or severe annoyance (vomit)
#define DISEASE_SEVERITY_HARMFUL	"Harmful"   //! Diseases that can do significant harm, or severe disruption (brainrot)
#define DISEASE_SEVERITY_DANGEROUS	"Dangerous"  //! Diseases that are lethal if untreated (flesh eating)
#define DISEASE_SEVERITY_BIOHAZARD	"BIOHAZARD" //! Symptoms that can quickly kill an unprepared victim (fungal tb, gbs)
#define DISEASE_SEVERITY_PANDEMIC	"PANDEMIC"  //! Symptoms so deadly you will likely die before being cured (ARDS, autophageocytosis)

//Anything after pipes "|" Denote Possible Implementations Brainstormed during Pathogen Development. Implementation is not guaranteed.
//These are heavily inspired by Plague Inc. Disease Categories
//Special Reagent to Develop Pathogen Specific Symptoms is probably a good idea since this would vastly increase the symptom library
#define DISEASE_PATHOGEN_BACTERIUM "Bacterium" //The Default. Nothing Special, No Upside or Downside
#define DISEASE_PATHOGEN_VIRUS "Virus" //Can use symptoms in Viral.dm | Better transmission but less resistance
#define DISEASE_PATHOGEN_FUNGAL "Fungus" //Can use symptoms located in Fungal.dm | Better Resistance but less transmission
#define DISEASE_PATHOGEN_PRION "Prion" //Can use symptoms located in Prion.dm | Good Stealth and Resistance but transmission is capped to blood's threshold and stage speed is capped at 0.
#define DISEASE_PATHOGEN_BIOWEAPON "Bioweapon" //MAY NOT BE IMPLEMENTED. Uplink Only. Increases Disease Power but has stealth capped in the negatives | Has Special Symptoms Because Definitely not Overkill, special symptoms may require an entirely separate reagent.
