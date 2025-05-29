/datum/design/nanites
	name = "None"
	desc = "Warn a coder if you see this."
	id = "default_nanites"
	build_type = NANITE_COMPILER
	construction_time = 50
	category = list()
	research_icon = 'icons/obj/device.dmi'
	research_icon_state = "nanite_program"
	var/datum/nanite_program/program_type = /datum/nanite_program

/datum/design/nanites/New()
	name = program_type::name
	desc = program_type::desc
	. = ..()

////////////////////UTILITY NANITES//////////////////////////////////////

/datum/design/nanites/metabolic_synthesis
	id = "metabolic_nanites"
	program_type = /datum/nanite_program/metabolic_synthesis
	category = list("Utility Nanites")

/datum/design/nanites/viral
	id = "viral_nanites"
	program_type = /datum/nanite_program/viral
	category = list("Utility Nanites")

/datum/design/nanites/research
	id = "research_nanites"
	program_type = /datum/nanite_program/research
	category = list("Utility Nanites")

/datum/design/nanites/researchplus
	id = "researchplus_nanites"
	program_type = /datum/nanite_program/researchplus
	category = list("Utility Nanites")

/datum/design/nanites/monitoring
	id = "monitoring_nanites"
	program_type = /datum/nanite_program/monitoring
	category = list("Utility Nanites")

/datum/design/nanites/self_scan
	id = "selfscan_nanites"
	program_type = /datum/nanite_program/self_scan
	category = list("Utility Nanites")

/datum/design/nanites/dermal_button
	id = "dermal_button_nanites"
	program_type = /datum/nanite_program/dermal_button
	category = list("Utility Nanites")

/datum/design/nanites/dermal_toggle
	id = "dermal_toggle_nanites"
	program_type = /datum/nanite_program/dermal_button/toggle
	category = list("Utility Nanites")

/datum/design/nanites/stealth
	id = "stealth_nanites"
	program_type = /datum/nanite_program/stealth
	category = list("Utility Nanites")

/datum/design/nanites/reduced_diagnostics
	id = "red_diag_nanites"
	program_type = /datum/nanite_program/reduced_diagnostics
	category = list("Utility Nanites")

/datum/design/nanites/access
	id = "access_nanites"
	program_type = /datum/nanite_program/access
	category = list("Utility Nanites")

/datum/design/nanites/relay
	id = "relay_nanites"
	program_type = /datum/nanite_program/relay
	category = list("Utility Nanites")

/datum/design/nanites/repeater
	id = "repeater_nanites"
	program_type = /datum/nanite_program/sensor/repeat
	category = list("Utility Nanites")

/datum/design/nanites/relay_repeater
	id = "relay_repeater_nanites"
	program_type = /datum/nanite_program/sensor/relay_repeat
	category = list("Utility Nanites")

/datum/design/nanites/emp
	id = "emp_nanites"
	program_type = /datum/nanite_program/emp
	category = list("Utility Nanites")

/datum/design/nanites/spreading
	id = "spreading_nanites"
	program_type = /datum/nanite_program/spreading
	category = list("Utility Nanites")

/datum/design/nanites/nanite_sting
	id = "nanite_sting_nanites"
	program_type = /datum/nanite_program/nanite_sting
	category = list("Utility Nanites")

/datum/design/nanites/mitosis
	id = "mitosis_nanites"
	program_type = /datum/nanite_program/mitosis
	category = list("Utility Nanites")

/datum/design/nanites/signaler
	id = "remote_signal_nanites"
	program_type = /datum/nanite_program/signaler
	category = list("Utility Nanites")

/datum/design/nanites/vampire
	id = "vampire_nanites"
	program_type = /datum/nanite_program/vampire
	category = list("Utility Nanites")

/datum/design/nanites/gas
	id = "gas_nanites"
	program_type = /datum/nanite_program/gas
	category = list("Utility Nanites")

/datum/design/nanites/doorjack
	id = "doorjack_nanites"
	program_type = /datum/nanite_program/doorjack
	category = list("Utility Nanites")

/datum/design/nanites/jammer
	id = "jammer_nanites"
	program_type = /datum/nanite_program/jammer
	category = list("Utility Nanites")

/datum/design/nanites/night_vision
	id = "night_vision_nanites"
	program_type = /datum/nanite_program/night_vision
	category = list("Utility Nanites")

////////////////////MEDICAL NANITES//////////////////////////////////////
/datum/design/nanites/regenerative
	id = "regenerative_nanites"
	program_type = /datum/nanite_program/regenerative
	category = list("Medical Nanites")

/datum/design/nanites/temperature
	id = "temperature_nanites"
	program_type = /datum/nanite_program/temperature
	category = list("Medical Nanites")

/datum/design/nanites/purging
	id = "purging_nanites"
	program_type = /datum/nanite_program/purging
	category = list("Medical Nanites")

/datum/design/nanites/purging_advanced
	id = "purging_plus_nanites"
	program_type = /datum/nanite_program/purging_advanced
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal
	id = "brainheal_nanites"
	program_type = /datum/nanite_program/brain_heal
	category = list("Medical Nanites")

/datum/design/nanites/brain_heal_advanced
	id = "brainheal_plus_nanites"
	program_type = /datum/nanite_program/brain_heal_advanced
	category = list("Medical Nanites")

/datum/design/nanites/blood_restoring
	id = "bloodheal_nanites"
	program_type = /datum/nanite_program/blood_restoring
	category = list("Medical Nanites")

/datum/design/nanites/cauterize
	id = "cauterize_nanites"
	program_type = /datum/nanite_program/cauterize
	category = list("Medical Nanites")

/datum/design/nanites/defib
	id = "defib_nanites"
	program_type = /datum/nanite_program/defib
	category = list("Medical Nanites")

/datum/design/nanites/tomb
	id = "nanite_tomb"
	program_type = /datum/nanite_program/nanite_tomb
	category = list("Medical Nanites")

////////////////////AUGMENTATION NANITES//////////////////////////////////////

/datum/design/nanites/nervous
	id = "nervous_nanites"
	program_type = /datum/nanite_program/nervous
	category = list("Augmentation Nanites")

/datum/design/nanites/hardening
	id = "hardening_nanites"
	program_type = /datum/nanite_program/hardening
	category = list("Augmentation Nanites")

/datum/design/nanites/refractive
	id = "refractive_nanites"
	program_type = /datum/nanite_program/refractive
	category = list("Augmentation Nanites")

/datum/design/nanites/coagulating
	id = "coagulating_nanites"
	program_type = /datum/nanite_program/coagulating
	category = list("Augmentation Nanites")

/datum/design/nanites/conductive
	id = "conductive_nanites"
	program_type = /datum/nanite_program/conductive
	category = list("Augmentation Nanites")

/datum/design/nanites/adrenaline
	id = "adrenaline_nanites"
	program_type = /datum/nanite_program/adrenaline
	category = list("Augmentation Nanites")

////////////////////DEFECTIVE NANITES//////////////////////////////////////

/datum/design/nanites/glitch
	id = "glitch_nanites"
	program_type = /datum/nanite_program/glitch
	category = list("Defective Nanites")

/datum/design/nanites/necrotic
	id = "necrotic_nanites"
	program_type = /datum/nanite_program/necrotic
	category = list("Defective Nanites")

/datum/design/nanites/toxic
	id = "toxic_nanites"
	program_type = /datum/nanite_program/toxic
	category = list("Defective Nanites")

/datum/design/nanites/suffocating
	id = "suffocating_nanites"
	program_type = /datum/nanite_program/suffocating
	category = list("Defective Nanites")

/datum/design/nanites/brain_misfire
	id = "brainmisfire_nanites"
	program_type = /datum/nanite_program/brain_misfire
	category = list("Defective Nanites")

/datum/design/nanites/skin_decay
	id = "skindecay_nanites"
	program_type = /datum/nanite_program/skin_decay
	category = list("Defective Nanites")

/datum/design/nanites/nerve_decay
	id = "nervedecay_nanites"
	program_type = /datum/nanite_program/nerve_decay
	category = list("Defective Nanites")

/datum/design/nanites/brain_decay
	id = "braindecay_nanites"
	program_type = /datum/nanite_program/brain_decay
	category = list("Defective Nanites")

////////////////////WEAPONIZED NANITES/////////////////////////////////////

/datum/design/nanites/flesh_eating
	id = "flesheating_nanites"
	program_type = /datum/nanite_program/flesh_eating
	category = list("Weaponized Nanites")

/datum/design/nanites/poison
	id = "poison_nanites"
	program_type = /datum/nanite_program/poison
	category = list("Weaponized Nanites")

/datum/design/nanites/memory_leak
	id = "memleak_nanites"
	program_type = /datum/nanite_program/memory_leak
	category = list("Weaponized Nanites")

/datum/design/nanites/aggressive_replication
	id = "aggressive_nanites"
	program_type = /datum/nanite_program/aggressive_replication
	category = list("Weaponized Nanites")

/datum/design/nanites/meltdown
	id = "meltdown_nanites"
	program_type = /datum/nanite_program/meltdown
	category = list("Weaponized Nanites")

/datum/design/nanites/cryo
	id = "cryo_nanites"
	program_type = /datum/nanite_program/cryo
	category = list("Weaponized Nanites")

/datum/design/nanites/pyro
	id = "pyro_nanites"
	program_type = /datum/nanite_program/pyro
	category = list("Weaponized Nanites")

/datum/design/nanites/heart_stop
	id = "heartstop_nanites"
	program_type = /datum/nanite_program/heart_stop
	category = list("Weaponized Nanites")

/datum/design/nanites/explosive
	id = "explosive_nanites"
	program_type = /datum/nanite_program/explosive
	category = list("Weaponized Nanites")

/datum/design/nanites/mind_control
	id = "mindcontrol_nanites"
	program_type = /datum/nanite_program/comm/mind_control
	category = list("Weaponized Nanites")

/datum/design/nanites/haste
	id = "haste_nanites"
	program_type = /datum/nanite_program/haste
	category = list("Weaponized Nanites")

/datum/design/nanites/armblade
	id = "armblade_nanites"
	program_type = /datum/nanite_program/armblade
	category = list("Weaponized Nanites")

/datum/design/nanites/pressure_suit
	id = "pressure_suit_nanites"
	program_type = /datum/nanite_program/pressure_suit
	category = list("Weaponized Nanites")

/datum/design/nanites/crush_resistance
	id = "crush_resistance_nanites"
	program_type = /datum/nanite_program/crush_resistance
	category = list("Weaponized Nanites")

////////////////////SUPPRESSION NANITES//////////////////////////////////////

/datum/design/nanites/shock
	id = "shock_nanites"
	program_type = /datum/nanite_program/shocking
	category = list("Suppression Nanites")

/datum/design/nanites/stun
	id = "stun_nanites"
	program_type = /datum/nanite_program/stun
	category = list("Suppression Nanites")

/datum/design/nanites/sleepy
	id = "sleep_nanites"
	program_type = /datum/nanite_program/sleepy
	category = list("Suppression Nanites")

/datum/design/nanites/paralyzing
	id = "paralyzing_nanites"
	program_type = /datum/nanite_program/paralyzing
	category = list("Suppression Nanites")

/datum/design/nanites/fake_death
	id = "fakedeath_nanites"
	program_type = /datum/nanite_program/fake_death
	category = list("Suppression Nanites")

/datum/design/nanites/pacifying
	id = "pacifying_nanites"
	program_type = /datum/nanite_program/pacifying
	category = list("Suppression Nanites")

/datum/design/nanites/blinding
	id = "blinding_nanites"
	program_type = /datum/nanite_program/blinding
	category = list("Suppression Nanites")

/datum/design/nanites/mute
	id = "mute_nanites"
	program_type = /datum/nanite_program/mute
	category = list("Suppression Nanites")

/datum/design/nanites/voice
	id = "voice_nanites"
	program_type = /datum/nanite_program/comm/voice
	category = list("Suppression Nanites")

/datum/design/nanites/speech
	id = "speech_nanites"
	program_type = /datum/nanite_program/comm/speech
	category = list("Suppression Nanites")

/datum/design/nanites/hallucination
	id = "hallucination_nanites"
	program_type = /datum/nanite_program/comm/hallucination
	category = list("Suppression Nanites")

/datum/design/nanites/good_mood
	id = "good_mood_nanites"
	program_type = /datum/nanite_program/good_mood
	category = list("Suppression Nanites")

/datum/design/nanites/bad_mood
	id = "bad_mood_nanites"
	program_type = /datum/nanite_program/bad_mood
	category = list("Suppression Nanites")

////////////////////SENSOR NANITES//////////////////////////////////////

/datum/design/nanites/sensor_health
	id = "sensor_health_nanites"
	program_type = /datum/nanite_program/sensor/health
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_damage
	id = "sensor_damage_nanites"
	program_type = /datum/nanite_program/sensor/damage
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_crit
	id = "sensor_crit_nanites"
	program_type = /datum/nanite_program/sensor/crit
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_death
	id = "sensor_death_nanites"
	program_type = /datum/nanite_program/sensor/death
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_voice
	id = "sensor_voice_nanites"
	program_type = /datum/nanite_program/sensor/voice
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_nanite_volume
	id = "sensor_nanite_volume"
	program_type = /datum/nanite_program/sensor/nanite_volume
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_species
	id = "sensor_species_nanites"
	program_type = /datum/nanite_program/sensor/species
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_nutrition
	id = "sensor_nutrition_nanites"
	program_type = /datum/nanite_program/sensor/nutrition
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_blood
	id = "sensor_blood_nanites"
	program_type = /datum/nanite_program/sensor/blood
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_receiver
	id = "sensor_receiver_nanites"
	program_type = /datum/nanite_program/sensor/receiver
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_bleeding
	id = "sensor_bleed_nanites"
	program_type = /datum/nanite_program/sensor/bleeding
	category = list("Sensor Nanites")

/datum/design/nanites/sensor_pressure
	id = "sensor_pressure_nanites"
	program_type = /datum/nanite_program/sensor/pressure
	category = list("Sensor Nanites")

////////////////////NANITE PROTOCOLS//////////////////////////////////////
//Note about the category name: The UI cuts the last 8 characters from the category name to remove the " Nanites" in the other categories
//Because of this, Protocols was getting cut down to "P", so i had to add some padding
/datum/design/nanites/kickstart
	id = "kickstart_nanites"
	program_type = /datum/nanite_program/protocol/kickstart
	category = list("Protocols_Nanites")

/datum/design/nanites/factory
	id = "factory_nanites"
	program_type = /datum/nanite_program/protocol/factory
	category = list("Protocols_Nanites")

/datum/design/nanites/pyramid
	id = "pyramid_nanites"
	program_type = /datum/nanite_program/protocol/pyramid
	category = list("Protocols_Nanites")

/datum/design/nanites/offline
	id = "offline_nanites"
	program_type = /datum/nanite_program/protocol/offline
	category = list("Protocols_Nanites")

/datum/design/nanites/silo
	id = "silo_nanites"
	program_type = /datum/nanite_program/protocol/silo
	category = list("Protocols_Nanites")

/datum/design/nanites/zip
	id = "zip_nanites"
	program_type = /datum/nanite_program/protocol/zip
	category = list("Protocols_Nanites")

/datum/design/nanites/free_range
	id = "free_range_nanites"
	program_type = /datum/nanite_program/protocol/free_range
	category = list("Protocols_Nanites")

/datum/design/nanites/unsafe_storage
	id = "unsafe_storage_nanites"
	program_type = /datum/nanite_program/protocol/unsafe_storage
	category = list("Protocols_Nanites")
