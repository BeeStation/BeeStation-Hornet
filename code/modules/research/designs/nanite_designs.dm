/datum/design/nanites
	name = "None"
	desc = "Warn a coder if you see this."
	build_type = NANITE_COMPILER
	construction_time = 50
	category = list()
	research_icon = 'icons/obj/device.dmi'
	research_icon_state = "nanite_program"
	var/program_type = /datum/nanite_program

////////////////////UTILITY NANITES//////////////////////////////////////

/datum/design/nanites/metabolic_synthesis
	name = "Metabolic Synthesis"
	desc = "The nanites use the metabolic cycle of the host to speed up their replication rate, using their extra nutrition as fuel."
	program_type = /datum/nanite_program/metabolic_synthesis
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/viral
	name = "Viral Replica"
	desc = "The nanites constantly send encrypted signals attempting to forcefully copy their own programming into other nanite clusters."
	program_type = /datum/nanite_program/viral
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/research
	name = "Distributed Computing"
	desc = "The nanites aid the research servers by performing a portion of its calculations, increasing research point generation."
	program_type = /datum/nanite_program/research
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/researchplus
	name = "Neural Network"
	desc = "The nanites link the host's brains together forming a neural research network, that becomes more efficient with the amount of total hosts. Can be overloaded to increase research output."
	program_type = /datum/nanite_program/researchplus
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/monitoring
	name = "Monitoring"
	desc = "The nanites monitor the host's vitals and location, sending them to the suit sensor network."
	program_type = /datum/nanite_program/monitoring
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/self_scan
	name = "Host Scan"
	desc = "The nanites display a detailed readout of a body scan to the host."
	program_type = /datum/nanite_program/self_scan
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/dermal_button
	name = "Dermal Button"
	desc = "Displays a button on the host's skin, which can be used to send a signal to the nanites."
	program_type = /datum/nanite_program/dermal_button
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/dermal_toggle
	name = "Dermal Toggle"
	desc = "Displays a switch on the host's skin, which can be used to send a signal to the nanites."
	program_type = /datum/nanite_program/dermal_button/toggle
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/stealth
	name = "Stealth"
	desc = "The nanites hide their activity and programming from superficial scans."
	program_type = /datum/nanite_program/stealth
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/reduced_diagnostics
	name = "Reduced Diagnostics"
	desc = "Disables some high-cost diagnostics in the nanites, making them unable to communicate their program list to portable scanners. \
	Doing so saves some power, slightly increasing their replication speed."
	program_type = /datum/nanite_program/reduced_diagnostics
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/access
	name = "Subdermal ID"
	desc = "The nanites store the host's ID access rights in a subdermal magnetic strip. Updates when triggered, copying the host's current access."
	program_type = /datum/nanite_program/access
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/relay
	name = "Relay"
	desc = "The nanites receive and relay long-range nanite signals."
	program_type = /datum/nanite_program/relay
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/repeater
	name = "Signal Repeater"
	desc = "When triggered, sends another signal to the nanites, optionally with a delay."
	program_type = /datum/nanite_program/sensor/repeat
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/relay_repeater
	name = "Relay Signal Repeater"
	desc = "When triggered, sends another signal to a relay channel, optionally with a delay."
	program_type = /datum/nanite_program/sensor/relay_repeat
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/emp
	name = "Electromagnetic Resonance"
	desc = "The nanites cause an electromagnetic pulse around the host when triggered. Will corrupt other nanite programs!"
	program_type = /datum/nanite_program/emp
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/spreading
	name = "Infective Exo-Locomotion"
	desc = "The nanites gain the ability to survive for brief periods outside of the human body, as well as the ability to start new colonies without an integration process; \
			resulting in an extremely infective strain of nanites."
	program_type = /datum/nanite_program/spreading
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/nanite_sting
	name = "Nanite Sting"
	desc = "When triggered, projects a nearly invisible spike of nanites that attempts to infect a nearby non-host with a copy of the host's nanites cluster."
	program_type = /datum/nanite_program/nanite_sting
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/mitosis
	name = "Mitosis"
	desc = "The nanites gain the ability to self-replicate, using bluespace to power the process, instead of drawing from a template. This rapidly speeds up the replication rate,\
			but it causes occasional software errors due to faulty copies."
	program_type = /datum/nanite_program/mitosis
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/signaler
	name = "Remote Signaler"
	desc = "The nanites send a pulse to all remote signalers on a given frequency and code."
	program_type = /datum/nanite_program/signaler
	category = list(RND_CATEGORY_UTILITY_NANITES)

/datum/design/nanites/vampire
	name = "Vampiric Synthesis"
	desc = "The nanites can consume the host's blood in order to replicate much faster. Does not have a built-in safety limiter."
	program_type = /datum/nanite_program/vampire
	category = list(RND_CATEGORY_UTILITY_NANITES)

////////////////////MEDICAL NANITES//////////////////////////////////////
/datum/design/nanites/regenerative
	name = "Accelerated Regeneration"
	desc = "The nanites boost the host's natural regeneration, increasing their healing speed."
	program_type = /datum/nanite_program/regenerative
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/regenerative_advanced
	name = "Bio-Reconstruction"
	desc = "The nanites manually repair and replace organic cells, acting much faster than normal regeneration. \
			However, this program cannot detect the difference between harmed and unharmed, causing it to consume nanites even if it has no effect."
	program_type = /datum/nanite_program/regenerative_advanced
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/temperature
	name = "Temperature Adjustment"
	desc = "The nanites adjust the host's internal temperature to an ideal level."
	program_type = /datum/nanite_program/temperature
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/purging
	name = "Blood Purification"
	desc = "The nanites purge toxins and chemicals from the host's bloodstream."
	program_type = /datum/nanite_program/purging
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/purging_advanced
	name = "Selective Blood Purification"
	desc = "The nanites purge toxins and dangerous chemicals from the host's bloodstream, while ignoring beneficial chemicals. \
			The added processing power required to analyze the chemicals severely increases the nanite consumption rate."
	program_type = /datum/nanite_program/purging_advanced
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/brain_heal
	name = "Neural Regeneration"
	desc = "The nanites fix neural connections in the host's brain, reversing brain damage and minor traumas."
	program_type = /datum/nanite_program/brain_heal
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/brain_heal_advanced
	name = "Neural Reimaging"
	desc = "The nanites are able to backup and restore the host's neural connections, potentially replacing entire chunks of missing or damaged brain matter."
	program_type = /datum/nanite_program/brain_heal_advanced
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/blood_restoring
	name = "Blood Regeneration"
	desc = "The nanites stimulate and boost blood cell production in the host."
	program_type = /datum/nanite_program/blood_restoring
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/repairing
	name = "Mechanical Repair"
	desc = "The nanites fix damage in the host's mechanical limbs."
	program_type = /datum/nanite_program/repairing
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/defib
	name = "Defibrillation"
	desc = "The nanites, when triggered, send a defibrillating shock to the host's heart."
	program_type = /datum/nanite_program/defib
	category = list(RND_CATEGORY_MEDICAL_NANITES)

/datum/design/nanites/coagulating
	name = "Rapid Coagulation"
	desc = "The nanites induce rapid coagulation when the host is wounded, closing bleeding wounds rapidly. Does not consume nanites if the host is not bleeding."
	program_type = /datum/nanite_program/coagulating
	category = list(RND_CATEGORY_MEDICAL_NANITES)


////////////////////AUGMENTATION NANITES//////////////////////////////////////

/datum/design/nanites/nervous
	name = "Nerve Support"
	desc = "The nanites act as a secondary nervous system, reducing the amount of time the host is stunned."
	program_type = /datum/nanite_program/nervous
	category = list(RND_CATEGORY_AUGMENTATION_NANITES)

/datum/design/nanites/hardening
	name = "Dermal Hardening"
	desc = "The nanites form a mesh under the host's skin, protecting them from melee and bullet impacts."
	program_type = /datum/nanite_program/hardening
	category = list(RND_CATEGORY_AUGMENTATION_NANITES)

/datum/design/nanites/refractive
	name = "Dermal Refractive Surface"
	desc = "The nanites form a membrane above the host's skin, reducing the effect of laser and energy impacts."
	program_type = /datum/nanite_program/refractive
	category = list(RND_CATEGORY_AUGMENTATION_NANITES)

/datum/design/nanites/conductive
	name = "Electric Conduction"
	desc = "The nanites act as a grounding rod for electric shocks, protecting the host. Shocks can still damage the nanites themselves."
	program_type = /datum/nanite_program/conductive
	category = list(RND_CATEGORY_AUGMENTATION_NANITES)

/datum/design/nanites/adrenaline
	name = "Adrenaline Burst"
	desc = "The nanites cause a burst of adrenaline when triggered, waking the host from stuns and temporarily increasing their speed."
	program_type = /datum/nanite_program/adrenaline
	category = list(RND_CATEGORY_AUGMENTATION_NANITES)

////////////////////DEFECTIVE NANITES//////////////////////////////////////

/datum/design/nanites/glitch
	name = "Glitch"
	desc = "A heavy software corruption that causes nanites to gradually break down."
	program_type = /datum/nanite_program/glitch
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/necrotic
	name = "Necrosis"
	desc = "The nanites attack internal tissues indiscriminately, causing widespread damage."
	program_type = /datum/nanite_program/necrotic
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/toxic
	name = "Toxin Buildup"
	desc = "The nanites cause a slow but constant toxin buildup inside the host."
	program_type = /datum/nanite_program/toxic
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/suffocating
	name = "Hypoxemia"
	desc = "The nanites prevent the host's blood from absorbing oxygen efficiently."
	program_type = /datum/nanite_program/suffocating
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/brain_misfire
	name = "Brain Misfire"
	desc = "The nanites interfere with neural pathways, causing minor psychological disturbances."
	program_type = /datum/nanite_program/brain_misfire
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/skin_decay
	name = "Dermalysis"
	desc = "The nanites attack skin cells, causing irritation, rashes, and minor damage."
	program_type = /datum/nanite_program/skin_decay
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/nerve_decay
	name = "Nerve Decay"
	desc = "The nanites attack the host's nerves, causing lack of coordination and short bursts of paralysis."
	program_type = /datum/nanite_program/nerve_decay
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

/datum/design/nanites/brain_decay
	name = "Brain-Eating Nanites"
	desc = "Damages brain cells, gradually decreasing the host's cognitive functions."
	program_type = /datum/nanite_program/brain_decay
	category = list(RND_CATEGORY_DEFECTIVE_NANITES)

////////////////////WEAPONIZED NANITES/////////////////////////////////////

/datum/design/nanites/flesh_eating
	name = "Cellular Breakdown"
	desc = "The nanites destroy cellular structures in the host's body, causing brute damage."
	program_type = /datum/nanite_program/flesh_eating
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/poison
	name = "Poisoning"
	desc = "The nanites deliver poisonous chemicals to the host's internal organs, causing toxin damage and vomiting."
	program_type = /datum/nanite_program/poison
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/memory_leak
	name = "Memory Leak"
	desc = "This program invades the memory space used by other programs, causing frequent corruptions and errors."
	program_type = /datum/nanite_program/memory_leak
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/aggressive_replication
	name = "Aggressive Replication"
	desc = "Nanites will consume organic matter to improve their replication rate, damaging the host."
	program_type = /datum/nanite_program/aggressive_replication
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/meltdown
	name = "Meltdown"
	desc = "Causes an internal meltdown inside the nanites, causing internal burns inside the host as well as rapidly destroying the nanite population.\
			Sets the nanites' safety threshold to 0 when activated."
	program_type = /datum/nanite_program/meltdown
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/cryo
	name = "Cryogenic Treatment"
	desc = "The nanites rapidly skin heat through the host's skin, lowering their temperature."
	program_type = /datum/nanite_program/cryo
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/pyro
	name = "Sub-Dermal Combustion"
	desc = "The nanites cause buildup of flammable fluids under the host's skin, then ignites them."
	program_type = /datum/nanite_program/pyro
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/heart_stop
	name = "Heart-Stopper"
	desc = "Stops the host's heart when triggered; restarts it if triggered again."
	program_type = /datum/nanite_program/heart_stop
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/explosive
	name = "Chain Detonation"
	desc = "Blows up all the nanites inside the host in a chain reaction when triggered."
	program_type = /datum/nanite_program/explosive
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/mind_control
	name = "Mind Control"
	desc = "The nanites imprint an absolute directive onto the host's brain while they're active."
	program_type = /datum/nanite_program/comm/mind_control
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/haste
	name = "Amphetamine Injection"
	desc = "The nanites synthesize amphetamine when triggered, which temporarily increases the host's running speed."
	program_type = /datum/nanite_program/haste
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

/datum/design/nanites/armblade
	name = "Nanite Blade"
	desc = "The nanites form a sharp blade around the user's arm when activated."
	program_type = /datum/nanite_program/armblade
	category = list(RND_CATEGORY_WEAPONIZED_NANITES)

////////////////////SUPPRESSION NANITES//////////////////////////////////////

/datum/design/nanites/shock
	name = "Electric Shock"
	desc = "The nanites shock the host when triggered. Destroys a large amount of nanites!"
	program_type = /datum/nanite_program/shocking
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/stun
	name = "Neural Shock"
	desc = "The nanites pulse the host's nerves when triggered, inapacitating them for a short period."
	program_type = /datum/nanite_program/stun
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/sleepy
	name = "Sleep Induction"
	desc = "The nanites cause rapid narcolepsy when triggered."
	program_type = /datum/nanite_program/sleepy
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/paralyzing
	name = "Paralysis"
	desc = "The nanites actively suppress nervous pulses, effectively paralyzing the host."
	program_type = /datum/nanite_program/paralyzing
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/fake_death
	name = "Death Simulation"
	desc = "The nanites induce a death-like coma into the host, able to fool most medical scans."
	program_type = /datum/nanite_program/fake_death
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/pacifying
	name = "Pacification"
	desc = "The nanites suppress the aggression center of the brain, preventing the host from causing direct harm to others."
	program_type = /datum/nanite_program/pacifying
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/blinding
	name = "Blindness"
	desc = "The nanites suppress the host's ocular nerves, blinding them while they're active."
	program_type = /datum/nanite_program/blinding
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/mute
	name = "Mute"
	desc = "The nanites suppress the host's speech, making them mute while they're active."
	program_type = /datum/nanite_program/mute
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/voice
	name = "Skull Echo"
	desc = "The nanites echo a synthesized message inside the host's skull."
	program_type = /datum/nanite_program/comm/voice
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/speech
	name = "Forced Speech"
	desc = "The nanites force the host to say a pre-programmed sentence when triggered."
	program_type = /datum/nanite_program/comm/speech
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/hallucination
	name = "Hallucination"
	desc = "The nanites make the host see and hear things that aren't real."
	program_type = /datum/nanite_program/comm/hallucination
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/good_mood
	name = "Happiness Enhancer"
	desc = "The nanites synthesize serotonin inside the host's brain, creating an artificial sense of happiness."
	program_type = /datum/nanite_program/good_mood
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

/datum/design/nanites/bad_mood
	name = "Happiness Suppressor"
	desc = "The nanites suppress the production of serotonin inside the host's brain, creating an artificial state of depression."
	program_type = /datum/nanite_program/bad_mood
	category = list(RND_CATEGORY_SUPPRESSION_NANITES)

////////////////////SENSOR NANITES//////////////////////////////////////

/datum/design/nanites/sensor_health
	name = "Health Sensor"
	desc = "The nanites receive a signal when the host's health is above/below a certain percentage."
	program_type = /datum/nanite_program/sensor/health
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_damage
	name = "Damage Sensor"
	desc = "The nanites receive a signal when a host's specific damage type is above/below a target value."
	program_type = /datum/nanite_program/sensor/damage
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_crit
	name = "Critical Health Sensor"
	desc = "The nanites receive a signal when the host first reaches critical health."
	program_type = /datum/nanite_program/sensor/crit
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_death
	name = "Death Sensor"
	desc = "The nanites receive a signal when they detect the host is dead."
	program_type = /datum/nanite_program/sensor/death
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_voice
	name = "Voice Sensor"
	desc = "Sends a signal when the nanites hear a determined word or sentence."
	program_type = /datum/nanite_program/sensor/voice
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_nanite_volume
	name = "Nanite Volume Sensor"
	desc = "The nanites receive a signal when the nanite supply is above/below a certain percentage."
	program_type = /datum/nanite_program/sensor/nanite_volume
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_species
	name = "Species Sensor"
	desc = "When triggered, the nanites scan the host to determine their species and output a signal depending on the conditions set in the settings."
	program_type = /datum/nanite_program/sensor/species
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_nutrition
	name = "Nutrition Sensor"
	desc = "The nanites receive a signal when the host's nutrition level is above/below a certain percentage."
	program_type = /datum/nanite_program/sensor/nutrition
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_blood
	name = "Blood Sensor"
	desc = "The nanites receive a signal when the host's blood level is above/below a certain percentage."
	program_type = /datum/nanite_program/sensor/blood
	category = list(RND_CATEGORY_SENSOR_NANITES)

/datum/design/nanites/sensor_receiver
	name = "Remote Signal Receiver"
	desc = "The nanites receive signals from remote signalers, and translate them into nanite signals."
	program_type = /datum/nanite_program/sensor/receiver
	category = list(RND_CATEGORY_SENSOR_NANITES)


////////////////////NANITE PROTOCOLS//////////////////////////////////////
//Note about the category name: The UI cuts the last 8 characters from the category name to remove the " Nanites" in the other categories
//Because of this, Protocols was getting cut down to "P", so i had to add some padding
/datum/design/nanites/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation."
	program_type = /datum/nanite_program/protocol/kickstart
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time. The factory decays if the protocol is not active."
	program_type = /datum/nanite_program/protocol/factory
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/pyramid
	name = "Pyramid Protocol"
	desc = "Replication Protocol: the nanites implement an alternate cooperative replication protocol that is more efficient as long as the saturation level is above 80%."
	program_type = /datum/nanite_program/protocol/pyramid
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/offline
	name = "Eclipse Protocol"
	desc = "Replication Protocol: while the host is asleep or otherwise unconcious, the nanites exploit the reduced interference to replicate more quickly."
	program_type = /datum/nanite_program/protocol/offline
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/zip
	name = "Zip Protocol"
	desc = "Storage Protocol: the nanites are disassembled and compacted when unused, greatly increasing the maximum volume while in a host. However, the process slows down the replication rate slightly."
	program_type = /datum/nanite_program/protocol/zip
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/free_range
	name = "Free-range Protocol"
	desc = "Storage Protocol: the nanites discard their default storage protocols in favour of a cheaper and more organic approach. Reduces maximum volume, but increases the replication rate."
	program_type = /datum/nanite_program/protocol/free_range
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

/datum/design/nanites/unsafe_storage
	name = "S.L.O. Protocol"
	desc = "Storage Protocol: 'S.L.O.P.', or Storage Level Override Protocol, completely disables the safety measures normally present in nanites,\
		allowing them to reach much higher saturation levels, but at the risk of causing internal damage to the host."
	program_type = /datum/nanite_program/protocol/unsafe_storage
	category = list(RND_CATEGORY_PROTOCOL_NANITES)

////////////////////NANITE CLASSIFIED//////////////////////////////////////
/datum/design/nanites/mindshield
	name = "Mental Barrier"
	desc = "The nanites form a protective membrane around the host's brain, shielding them from abnormal influences while they're active."
	program_type = /datum/nanite_program/mindshield
	category = list("Classified_Nanites")
