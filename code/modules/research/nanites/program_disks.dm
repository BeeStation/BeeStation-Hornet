/obj/item/disk/nanite_program
	name = "nanite program disk"
	desc = "A disk capable of storing nanite programs. Can be customized using a Nanite Programming Console."
	var/program_type
	var/datum/nanite_program/program

/obj/item/disk/nanite_program/Initialize(mapload)
	. = ..()
	if(program_type)
		program = new program_type

/obj/item/disk/nanite_program/aggressive_replication
	name = "Aggressive Replication"
	program_type = /datum/nanite_program/aggressive_replication

/obj/item/disk/nanite_program/metabolic_synthesis
	name = "Metabolic Synthesis"
	program_type = /datum/nanite_program/metabolic_synthesis

/obj/item/disk/nanite_program/viral
	name = "Viral Replica"
	program_type = /datum/nanite_program/viral

/obj/item/disk/nanite_program/meltdown
	name = "Meltdown"
	program_type = /datum/nanite_program/meltdown

/obj/item/disk/nanite_program/monitoring
	name = "Monitoring"
	program_type = /datum/nanite_program/monitoring

/obj/item/disk/nanite_program/relay
	name = "Relay"
	program_type = /datum/nanite_program/relay

/obj/item/disk/nanite_program/emp
	name = "Electromagnetic Resonance"
	program_type = /datum/nanite_program/emp

/obj/item/disk/nanite_program/spreading
	name = "Infective Exo-Locomotion"
	program_type = /datum/nanite_program/spreading

/obj/item/disk/nanite_program/regenerative
	name = "Accelerated Regeneration"
	program_type = /datum/nanite_program/regenerative

/obj/item/disk/nanite_program/regenerative_advanced
	name = "Bio-Reconstruction"
	program_type = /datum/nanite_program/regenerative_advanced

/obj/item/disk/nanite_program/temperature
	name = "Temperature Adjustment"
	program_type = /datum/nanite_program/temperature

/obj/item/disk/nanite_program/purging
	name = "Blood Purification"
	program_type = /datum/nanite_program/purging

/obj/item/disk/nanite_program/purging_advanced
	name = "Selective Blood Purification"
	program_type = /datum/nanite_program/purging_advanced

/obj/item/disk/nanite_program/brain_heal
	name = "Neural Regeneration"
	program_type = /datum/nanite_program/brain_heal

/obj/item/disk/nanite_program/brain_heal_advanced
	name = "Neural Reimaging"
	program_type = /datum/nanite_program/brain_heal_advanced

/obj/item/disk/nanite_program/blood_restoring
	name = "Blood Restoration"
	program_type = /datum/nanite_program/blood_restoring

/obj/item/disk/nanite_program/repairing
	name = "Mechanical Repair"
	program_type = /datum/nanite_program/repairing

/obj/item/disk/nanite_program/nervous
	name = "Nerve Support"
	program_type = /datum/nanite_program/nervous

/obj/item/disk/nanite_program/hardening
	name = "Dermal Hardening"
	program_type = /datum/nanite_program/hardening

/obj/item/disk/nanite_program/coagulating
	name = "Rapid Coagulation"
	program_type = /datum/nanite_program/coagulating

/obj/item/disk/nanite_program/necrotic
	name = "Necrosis"
	program_type = /datum/nanite_program/necrotic

/obj/item/disk/nanite_program/brain_decay
	name = "Brain-Eating Nanites"
	program_type = /datum/nanite_program/brain_decay

/obj/item/disk/nanite_program/pyro
	name = "Sub-Dermal Combustion"
	program_type = /datum/nanite_program/pyro

/obj/item/disk/nanite_program/cryo
	name = "Cryogenic Treatment"
	program_type = /datum/nanite_program/cryo

/obj/item/disk/nanite_program/toxic
	name = "Toxin Buildup"
	program_type = /datum/nanite_program/toxic

/obj/item/disk/nanite_program/suffocating
	name = "Hypoxemia"
	program_type = /datum/nanite_program/suffocating

/obj/item/disk/nanite_program/heart_stop
	name = "Heart-Stopper"
	program_type = /datum/nanite_program/heart_stop

/obj/item/disk/nanite_program/explosive
	name = "Chain Detonation"
	program_type = /datum/nanite_program/explosive

/obj/item/disk/nanite_program/shock
	name = "Electric Shock"
	program_type = /datum/nanite_program/shocking

/obj/item/disk/nanite_program/sleepy
	name = "Sleep Induction"
	program_type = /datum/nanite_program/sleepy

/obj/item/disk/nanite_program/paralyzing
	name = "Paralysis"
	program_type = /datum/nanite_program/paralyzing

/obj/item/disk/nanite_program/fake_death
	name = "Death Simulation"
	program_type = /datum/nanite_program/fake_death

/obj/item/disk/nanite_program/pacifying
	name = "Pacification"
	program_type = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/glitch
	name = "Glitch"
	program_type = /datum/nanite_program/glitch

/obj/item/disk/nanite_program/brain_misfire
	name = "Brain Misfire"
	program_type = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/skin_decay
	name = "Dermalysis"
	program_type = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/nerve_decay
	name = "Nerve Decay"
	program_type = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/refractive
	name = "Dermal Refractive Surface"
	program_type = /datum/nanite_program/refractive

/obj/item/disk/nanite_program/conductive
	name = "Electric Conduction"
	program_type = /datum/nanite_program/pacifying

/obj/item/disk/nanite_program/stun
	name = "Neural Shock"
	program_type = /datum/nanite_program/stun

/obj/item/disk/nanite_program/species_sensor
	name = "Species Sensor"
	program_type = /datum/nanite_program/sensor/species

/obj/item/disk/nanite_program/mindshield
	name = "Mindshield"
	program_type = /datum/nanite_program/mindshield
