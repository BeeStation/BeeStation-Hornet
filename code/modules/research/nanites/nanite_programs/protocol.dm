///A nanite program containing a behaviour protocol. Only one protocol of each class can be active at once.
/datum/nanite_program/protocol
	name = "Nanite Protocol"
	var/protocol_class = NONE

/datum/nanite_program/protocol/check_conditions()
	. = ..()
	for(var/datum/nanite_program/protocol/protocol as anything in nanites.protocols)
		if(protocol != src && protocol.activated && protocol.protocol_class == protocol_class)
			return FALSE

/datum/nanite_program/protocol/on_add(datum/component/nanites/_nanites)
	..()
	nanites.protocols += src

/datum/nanite_program/protocol/Destroy()
	if(nanites)
		nanites.protocols -= src
	return ..()

//Replication Protocols
/datum/nanite_program/protocol/kickstart
	name = "Kickstart Protocol"
	desc = "Replication Protocol: the nanites focus on early growth, heavily boosting replication rate for a few minutes after the initial implantation, \
			resulting in an additional 420 nanite volume being produced during the first two minutes."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost_duration = 2 MINUTES

/datum/nanite_program/protocol/kickstart/check_conditions()
	if(!(world.time < nanites.start_time + boost_duration))
		return FALSE
	return ..()

/datum/nanite_program/protocol/kickstart/active_effect()
	nanites.adjust_nanites(amount = 3.5)


/datum/nanite_program/protocol/factory
	name = "Factory Protocol"
	desc = "Replication Protocol: the nanites build a factory matrix within the host, gradually increasing replication speed over time, \
			granting a maximum of 2 additional nanite production after roughly 17 minutes. \
			The factory decays if the protocol is not active, or if the nanites are disrupted by shocks or EMPs."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/factory_efficiency = 0
	var/max_efficiency = 1000 //Goes up to 2 bonus regen per tick after 16 minutes and 40 seconds

/datum/nanite_program/protocol/factory/on_process()
	if(!activated || !check_conditions())
		factory_efficiency = max(0, factory_efficiency - 5)
	..()

/datum/nanite_program/protocol/factory/on_emp(severity)
	..()
	factory_efficiency = max(0, factory_efficiency - 300)

/datum/nanite_program/protocol/factory/active_effect()
	factory_efficiency = min(factory_efficiency + 1, max_efficiency)
	nanites.adjust_nanites(amount = round(0.002 * factory_efficiency, 0.1))


/datum/nanite_program/protocol/pyramid
	name = "Pyramid Protocol"
	desc = "Replication Protocol: Produces an additional 2 nanites per second, but nanite production requires twice the amount of food."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 2

/datum/nanite_program/protocol/pyramid/enable_passive_effect()
	. = ..()
	nanites.nutrition_rate += 0.2

/datum/nanite_program/protocol/pyramid/disable_passive_effect()
	. = ..()
	nanites.nutrition_rate -= 0.2

/datum/nanite_program/protocol/pyramid/active_effect()
	nanites.adjust_nanites(amount = boost)


/datum/nanite_program/protocol/offline
	name = "Eclipse Protocol"
	desc = "Replication Protocol: Produces an additional 3 nanites per second while the host is sleeping or unconcious."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 3

/datum/nanite_program/protocol/offline/check_conditions()
	if(nanites.host_mob.stat == CONSCIOUS)
		return FALSE
	return ..()

/datum/nanite_program/protocol/offline/active_effect()
	nanites.adjust_nanites(amount = boost)


/datum/nanite_program/protocol/silo
	name = "Silo Protocol"
	desc = "Replication Protocol: Produces an additional 5 nanites per second while the host has excess food in their body. Excess food is consumed even while nanites are at maximum capacity."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_REPLICATION
	var/boost = 5

/datum/nanite_program/protocol/silo/active_effect()
	if (host_mob.nutrition < NUTRITION_LEVEL_FULL)
		return
	host_mob.adjust_nutrition(-1)
	nanites.adjust_nanites(amount = boost)


/datum/nanite_program/protocol/zip
	name = "Zip Protocol"
	desc = "Cooldown Protocol: the nanites work faster, halving cooldowns at the cost of consuming some nanites and increasing the amount of food required to maintain the nanites when active."
	use_rate = 0.5
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_COOLDOWN

/datum/nanite_program/protocol/zip/enable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier *= 0.5

/datum/nanite_program/protocol/zip/disable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier *= 2


/datum/nanite_program/protocol/cellular_embedding
	name = "Cellular Embedding Protocol"
	desc = "Storage Protocol: the nanites embed themselves inside of cells, reducing cooldowns by 30% whilst simultaneously preventing viral infections."
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_COOLDOWN

/datum/nanite_program/protocol/cellular_embedding/enable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier -= 0.3
	ADD_TRAIT(host_mob, TRAIT_VIRUSIMMUNE, SOURCE_NANITE_CELLULAR)
	for (var/datum/disease/disease in host_mob.diseases)
		disease.cure(FALSE)

/datum/nanite_program/protocol/cellular_embedding/disable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier += 0.3
	REMOVE_TRAIT(host_mob, TRAIT_VIRUSIMMUNE, SOURCE_NANITE_CELLULAR)


/datum/nanite_program/protocol/free_range
	name = "Free-range Protocol"
	desc = "Cooldown Protocol: the nanites achieve complete harmony with the body, requiring no food to maintain (as long as another protocol doesn't consume food) but doubling the length of all cooldowns."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_COOLDOWN

/datum/nanite_program/protocol/free_range/enable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier *= 2
	nanites.nutrition_rate -= 0.2

/datum/nanite_program/protocol/free_range/disable_passive_effect()
	. = ..()
	nanites.cooldown_multiplier /= 2
	nanites.nutrition_rate += 0.2


/datum/nanite_program/protocol/unsafe_storage
	name = "S.L.O. Protocol"
	desc = "Cooldown Protocol: Overrides the standard storage mechanism for nanites, allowing them to operate without any cooldowns. However, the nanites\
		will constantly replicate until either the body becomes oversaturated, or the host starves."
	use_rate = 0
	rogue_types = list(/datum/nanite_program/necrotic)
	protocol_class = NANITE_PROTOCOL_COOLDOWN
	var/next_warning = 0
	var/min_warning_cooldown = 120
	var/max_warning_cooldown = 350
	var/volume_warnings_stage_1 = list("You feel a dull pain in your abdomen.",
									"You feel a tickling sensation in your abdomen.")
	var/volume_warnings_stage_2 = list("You feel a dull pain in your stomach.",
									"You feel a dull pain when breathing.",
									"Your stomach grumbles.",
									"You feel a tickling sensation in your throat.",
									"You feel a tickling sensation in your lungs.",
									"You feel a tickling sensation in your stomach.",
									"Your lungs feel stiff.")
	var/volume_warnings_stage_3 = list("You feel a dull pain in your chest.",
									"You hear a faint buzzing coming from nowhere.",
									"You hear a faint buzzing inside your head.",
									"Your head aches.")
	var/volume_warnings_stage_4 = list("You feel a dull pain in your ears.",
									"You feel a dull pain behind your eyes.",
									"You hear a loud, echoing buzz inside your ears.",
									"You feel dizzy.",
									"You feel an itch coming from behind your eyes.",
									"Your eardrums itch.",
									"You see tiny grey motes drifting in your field of view.")
	var/volume_warnings_stage_5 = list("You feel sick.",
									"You feel a dull pain from every part of your body.",
									"You feel nauseous.")
	var/volume_warnings_stage_6 = list("Your skin itches and burns.",
									"Your muscles ache.",
									"You feel tired.",
									"You feel something skittering under your skin.",)

/datum/nanite_program/protocol/unsafe_storage/enable_passive_effect()
	. = ..()
	// Slight nutrition cost increase, since we want the owner to starve
	// more frequently as the cost of too many nanites can be managed
	// entirely by the nanites themselves.
	nanites.nutrition_rate += 0.1
	nanites.max_production_ratio += 1000
	nanites.cooldown_multiplier = 0
	// Required to prevent exploitation where you enable it, activate an effect,
	// then disable
	nanites.set_volume(0)

/datum/nanite_program/protocol/unsafe_storage/disable_passive_effect()
	. = ..()
	nanites.nutrition_rate -= 0.1
	nanites.max_production_ratio -= 1000
	nanites.cooldown_multiplier = 1

/datum/nanite_program/protocol/unsafe_storage/active_effect()
	if(!iscarbon(host_mob))
		if(nanites.nanite_volume < NUTRITION_LEVEL_FULL)
			return
		if(prob(10))
			host_mob.adjustBruteLoss(((max(nanites.nanite_volume - NUTRITION_LEVEL_FULL, 0) / 100) ** 2 ) * 0.5) // 0.5 -> 2 -> 4.5 -> 8 damage per successful tick
		return

	var/mob/living/carbon/C = host_mob

	if (host_mob.nutrition < NUTRITION_LEVEL_STARVING)
		var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
		if(liver)
			liver.applyOrganDamage(0.5)
		C.adjustToxLoss(0.2, forced = TRUE)
		volume_warning(1)
		return

	if(nanites.nanite_volume < NUTRITION_LEVEL_FULL)
		return

	var/current_stage = 0
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL) //Liver is the main hub of nanite replication and the first to be threatened by excess volume
		if(prob(10))
			var/obj/item/organ/liver/liver = C.getorganslot(ORGAN_SLOT_LIVER)
			if(liver)
				liver.applyOrganDamage(0.6)
		current_stage++
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL + 50) //Extra volume spills out in other central organs
		if(prob(10))
			var/obj/item/organ/stomach/stomach = C.getorganslot(ORGAN_SLOT_STOMACH)
			if(stomach)
				stomach.applyOrganDamage(0.75)
		if(prob(10))
			var/obj/item/organ/lungs/lungs = C.getorganslot(ORGAN_SLOT_LUNGS)
			if(lungs)
				lungs.applyOrganDamage(0.75)
		current_stage++
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL + 100) //Extra volume spills out in more critical organs
		if(prob(10))
			var/obj/item/organ/heart/heart = C.getorganslot(ORGAN_SLOT_HEART)
			if(heart)
				heart.applyOrganDamage(0.75)
		if(prob(10))
			var/obj/item/organ/brain/brain = C.getorganslot(ORGAN_SLOT_BRAIN)
			if(brain)
				brain.applyOrganDamage(0.75)
		current_stage++
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL + 200) //Excess nanites start invading smaller organs for more space, including sensory organs
		if(prob(13))
			var/obj/item/organ/eyes/eyes = C.getorganslot(ORGAN_SLOT_EYES)
			if(eyes)
				eyes.applyOrganDamage(0.75)
		if(prob(13))
			var/obj/item/organ/ears/ears = C.getorganslot(ORGAN_SLOT_EARS)
			if(ears)
				ears.applyOrganDamage(0.75)
		current_stage++
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL + 250) //Nanites start spilling into the bloodstream, causing toxicity
		if(prob(15))
			C.adjustToxLoss(0.5, TRUE, forced = TRUE) //Not healthy for slimepeople either
		current_stage++
	if(nanites.nanite_volume > NUTRITION_LEVEL_FULL + 300) //Nanites have almost reached their physical limit, and the pressure itself starts causing tissue damage
		if(prob(15))
			C.adjustBruteLoss(0.75, TRUE)
		current_stage++

	volume_warning(current_stage)

/datum/nanite_program/protocol/unsafe_storage/proc/volume_warning(tier)
	if(world.time < next_warning)
		return

	var/list/main_warnings
	var/list/extra_warnings

	switch(tier)
		if(1)
			main_warnings = volume_warnings_stage_1
			extra_warnings = null
		if(2)
			main_warnings = volume_warnings_stage_2
			extra_warnings = volume_warnings_stage_1
		if(3)
			main_warnings = volume_warnings_stage_3
			extra_warnings = volume_warnings_stage_1 + volume_warnings_stage_2
		if(4)
			main_warnings = volume_warnings_stage_4
			extra_warnings = volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3
		if(5)
			main_warnings = volume_warnings_stage_5
			extra_warnings = volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3 + volume_warnings_stage_4
		if(6)
			main_warnings = volume_warnings_stage_6
			extra_warnings = volume_warnings_stage_1 + volume_warnings_stage_2 + volume_warnings_stage_3 + volume_warnings_stage_4 + volume_warnings_stage_5

	if(prob(35))
		to_chat(host_mob, span_warning("[pick(main_warnings)]"))
		next_warning = world.time + rand(min_warning_cooldown, max_warning_cooldown)
	else if(islist(extra_warnings))
		to_chat(host_mob, span_warning("[pick(extra_warnings)]"))
		next_warning = world.time + rand(min_warning_cooldown, max_warning_cooldown)
