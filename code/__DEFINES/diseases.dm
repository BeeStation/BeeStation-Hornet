
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

// Symptom Thresholds
var/disease_sneeze_stealth = rand(2,5)
var/disease_sneeze_transmission = rand(10,13)

var/disease_visionloss_resistance = rand(10,14)
var/disease_visionloss_stealth = rand(2,5)

var/disease_voice_change_transmission = rand(8,12)
var/disease_voice_change_stage_speed = rand(5,9)
var/disease_voice_change_stealth = rand(1,5)

var/disease_vomit_stage_speed = rand(3,7)
var/disease_vomit_transmission = rand(4,8)
var/disease_vomit_stealth = rand(2,5)

var/disease_weight_loss_stealth = rand(0,4)

var/disease_wizarditis_transmission = rand(6,10)
var/disease_wizarditis_stage_speed = rand(5,9)

var/disease_alcohol_stealth = rand(1,5)
var/disease_alcohol_stage_speed = rand(4,8)

var/disease_beesease_resistance = rand(10,14)
var/disease_beesease_transmission = rand(8,12)

var/disease_blobspores_resistance1 = rand(6,9)
var/disease_blobspores_resistance2 = rand(10,12)
var/disease_blobspores_resistance3 = rand(13,15)

var/disease_braindamage_transmission = rand(10,13)
var/disease_braindamage_stage_speed = rand(7,11)

var/disease_asphyxiation_stage_speed = rand(6,10)
var/disease_asphyxiation_transmission = rand(6,10)

var/disease_robotic_adaptation_stage_speed1 = rand(2,6)
var/disease_robotic_adaptation_stage_speed2 = rand(10,14)
var/disease_robotic_adaptation_resistance = rand(2,6)

var/disease_cockroach_stage_speed = rand(6,10)
var/disease_cockroach_transmission = rand(6,10)

var/disease_confusion_resistance = rand(4,8)
var/disease_confusion_transmission = rand(4,8)
var/disease_confusion_stealth = rand(2,5)

var/disease_cough_resistance1 = rand(1,5)
var/disease_cough_resistance2 = rand(8,12)
var/disease_cough_stage_speed = rand(4,8)
var/disease_cough_stealth = rand(2,5)
var/disease_cough_transmission = rand(9,13)

var/disease_deafness_resistance = rand(7,11)
var/disease_deafness_stealth = rand(2,5)

var/disease_fever_resistance1 = rand(3,7)
var/disease_fever_resistance2 = rand(8,12)

var/disease_fire_stage_speed1 = rand(2,6)
var/disease_fire_stage_speed2 = rand(7,10)
var/disease_fire_transmission = rand(6,10)
var/disease_fire_stealth = rand(2,5)

var/disease_alkali_stealth = rand(2,4)
var/disease_alkali_stage_speed = rand(6,10)
var/disease_alkali_resistance = rand(6,10)

var/disease_flesh_eating_resistance = rand(8,12)
var/disease_flesh_eating_transmission = rand(6,10)

var/disease_flesh_death_stage_speed = rand(5,9)
var/disease_flesh_death_stealth = rand(3,7)

var/disease_genetic_mutation_resistance = rand(6,10)
var/disease_genetic_mutation_stage_speed = rand(8,12)
var/disease_genetic_mutation_stealth = rand(3,7)

var/disease_hallucigen_stage_speed = rand(5,9)
var/disease_hallucigen_stealth = rand(0,4)

var/disease_headache_stage_speed1 = rand(4,7)
var/disease_headache_stage_speed2 = rand(8,11)
var/disease_headache_stealth = rand(2,5)

var/disease_heal_chem_resistance = rand(5,9)
var/disease_heal_chem_stage_speed = rand(4,8)

var/disease_heal_coma_stealth = rand(0,4)
var/disease_heal_coma_resistance = rand(2,6)
var/disease_heal_coma_stage_speed = rand(5,9)

var/disease_heal_surface_stage_speed = rand(6,10)
var/disease_heal_surface_resistance = rand(8,12)

var/disease_heal_metabolize_stealth = rand(1,5)
var/disease_heal_metabolize_stage_speed = rand(8,12)

var/disease_EMP_stealth = rand(0,4)
var/disease_EMP_transmission = rand(6,10)

var/disease_sweat_transmission1 = rand(3,5)
var/disease_sweat_transmission2 = rand(6,7)
var/disease_sweat_stage_speed = rand(4,8)

var/disease_teleport_restistance = rand(4,8)
var/disease_teleport_transmission = rand(6,10)

var/disease_growth_stage_speed1 = rand(4,8)
var/disease_growth_stage_speed2 = rand(10,14)

var/disease_vampirism_transmission1 = rand(2,5)
var/disease_vampirism_stage_speed = rand(5,9)
var/disease_vampirism_transmission2 = rand(6,7)

var/disease_parasite_stealth = rand(0,4)
var/disease_parasite_stage_speed = rand(4,8)

var/disease_jitters_resistance = rand(6,10)
var/disease_jitters_stage_speed = rand(6,10)

var/disease_heartattack_transmission = rand(8,12)
var/disease_heartattack_stealth = rand(0,4)

var/disease_itching_transmission = rand(4,8)
var/disease_itching_stage_speed = rand(5,9)

var/disease_light_stealth = rand(1,5)

var/disease_lubefeet_transmission = rand(8,12)
var/disease_lubefeet_resistance = rand(12,16)