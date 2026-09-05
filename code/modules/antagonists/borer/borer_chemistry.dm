/// A chemical a cortical borer can introduce directly into its host.
/datum/borer_secretion
	var/name = "chemical secretion"
	var/reagent_type
	var/chemical_cost = 10
	var/dose_size = 5
	/// Null means a baseline secretion works from every cyst location.
	var/required_zone
	/// Used for paired limb locations such as either arm or either leg.
	var/list/required_zones
	/// Advanced secretions require a matching purchased evolution.
	var/unlock_type

/datum/borer_secretion/proc/can_secrete(mob/living/simple_animal/borer/borer)
	if(!borer?.host || (required_zone && borer.cyst?.zone != required_zone) || (required_zones && !(borer.cyst?.zone in required_zones)))
		return FALSE
	return !unlock_type || borer.has_active_evolution(unlock_type)

// Baseline medicine: deliberately available from any cyst location.
/datum/borer_secretion/bicaridine
	name = "Bicaridine"
	reagent_type = /datum/reagent/medicine/bicaridine

/datum/borer_secretion/kelotane
	name = "Kelotane"
	reagent_type = /datum/reagent/medicine/kelotane

/datum/borer_secretion/charcoal
	name = "Charcoal"
	reagent_type = /datum/reagent/medicine/charcoal

/datum/borer_secretion/epinephrine
	name = "Epinephrine"
	reagent_type = /datum/reagent/medicine/epinephrine

// Basic specialist secretions.
/datum/borer_secretion/head
	required_zone = BODY_ZONE_HEAD

/datum/borer_secretion/head/mannitol
	name = "Mannitol"
	reagent_type = /datum/reagent/medicine/mannitol

/datum/borer_secretion/head/oculine
	name = "Oculine"
	reagent_type = /datum/reagent/medicine/oculine

/datum/borer_secretion/head/inacusiate
	name = "Inacusiate"
	reagent_type = /datum/reagent/medicine/inacusiate

/datum/borer_secretion/chest
	required_zone = BODY_ZONE_CHEST

/datum/borer_secretion/chest/blood
	name = "Blood"
	reagent_type = /datum/reagent/blood

/datum/borer_secretion/chest/dexalin
	name = "Dexalin"
	reagent_type = /datum/reagent/medicine/dexalin

/datum/borer_secretion/chest/leporazine
	name = "Leporazine"
	reagent_type = /datum/reagent/medicine/leporazine

/datum/borer_secretion/chest/nutriment
	name = "Nutriment"
	reagent_type = /datum/reagent/consumable/nutriment

/datum/borer_secretion/arm
	required_zones = list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/borer_secretion/arm/iron
	name = "Iron"
	reagent_type = /datum/reagent/iron

/datum/borer_secretion/leg
	required_zones = list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_secretion/leg/ephedrine
	name = "Ephedrine"
	reagent_type = /datum/reagent/medicine/ephedrine

// Advanced head secretions.
/datum/borer_secretion/head/mutadone
	name = "Mutadone"
	reagent_type = /datum/reagent/medicine/mutadone
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/head/genetic_restoration

/datum/borer_secretion/head/rezadone
	name = "Rezadone"
	reagent_type = /datum/reagent/medicine/rezadone
	chemical_cost = 20
	unlock_type = /datum/borer_evolution/chemical/head/genetic_restoration

/datum/borer_secretion/head/morphine
	name = "Morphine"
	reagent_type = /datum/reagent/medicine/morphine
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/head/neurochemical_control

/datum/borer_secretion/head/space_drugs
	name = "Space Drugs"
	reagent_type = /datum/reagent/drug/space_drugs
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/head/neurochemical_control

/datum/borer_secretion/head/synaptizine
	name = "Synaptizine"
	reagent_type = /datum/reagent/medicine/synaptizine
	chemical_cost = 20
	unlock_type = /datum/borer_evolution/chemical/head/neurochemical_control

// Advanced chest secretions.
/datum/borer_secretion/chest/dexalinp
	name = "Dexalin Plus"
	reagent_type = /datum/reagent/medicine/dexalinp
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/chest/respiratory_radiation_care

/datum/borer_secretion/chest/potass_iodide
	name = "Potassium Iodide"
	reagent_type = /datum/reagent/medicine/potass_iodide
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/chest/respiratory_radiation_care

/datum/borer_secretion/chest/capsaicin
	name = "Capsaicin Oil"
	reagent_type = /datum/reagent/consumable/capsaicin
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/chest/metabolic_disruption

/datum/borer_secretion/chest/frostoil
	name = "Frostoil"
	reagent_type = /datum/reagent/consumable/frostoil
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/chest/metabolic_disruption

/datum/borer_secretion/chest/lipolicide
	name = "Lipolicide"
	reagent_type = /datum/reagent/toxin/lipolicide
	chemical_cost = 15
	unlock_type = /datum/borer_evolution/chemical/chest/metabolic_disruption

/datum/borer_secretion/chest/omnizine
	name = "Omnizine"
	reagent_type = /datum/reagent/medicine/omnizine
	chemical_cost = 25
	unlock_type = /datum/borer_evolution/chemical/chest/advanced_critical_care

/datum/borer_secretion/chest/stabilizing_nanites
	name = "Stabilizing Nanites"
	reagent_type = /datum/reagent/medicine/stabilizing_nanites
	chemical_cost = 25
	unlock_type = /datum/borer_evolution/chemical/chest/advanced_critical_care

/datum/borer_secretion/chest/atropine
	name = "Atropine"
	reagent_type = /datum/reagent/medicine/atropine
	chemical_cost = 25
	unlock_type = /datum/borer_evolution/chemical/chest/advanced_critical_care
