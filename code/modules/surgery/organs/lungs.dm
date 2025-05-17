// / Breathing types. Lungs can access either by these or by a string, which will be considered a gas ID.
#define BREATH_OXY		/datum/breathing_class/oxygen
#define BREATH_PLASMA	/datum/breathing_class/plasma

/obj/item/organ/lungs
	var/failed = FALSE
	var/operated = FALSE	//whether we can still have our damages fixed through surgery
	name = "lungs"
	icon_state = "lungs"
	visual = FALSE
	zone = BODY_ZONE_CHEST
	slot = ORGAN_SLOT_LUNGS
	gender = PLURAL
	w_class = WEIGHT_CLASS_SMALL

	healing_factor = STANDARD_ORGAN_HEALING
	decay_factor = STANDARD_ORGAN_DECAY

	high_threshold_passed = span_warning("You feel some sort of constriction around your chest as your breathing becomes shallow and rapid.")
	now_fixed = span_warning("Your lungs seem to once again be able to hold air.")
	high_threshold_cleared = span_info("The constriction around your chest loosens as your breathing calms down.")


	food_reagents = list(/datum/reagent/consumable/nutriment = 5, /datum/reagent/medicine/salbutamol = 5)

	//Breath damage
	//These thresholds are checked against what amounts to total_mix_pressure * (gas_type_mols/total_mols)

	var/breathing_class = BREATH_OXY // can be a gas instead of a breathing class
	var/safe_breath_min = 16
	var/safe_breath_max = 50
	var/safe_breath_dam_min = MIN_TOXIC_GAS_DAMAGE
	var/safe_breath_dam_max = MAX_TOXIC_GAS_DAMAGE
	var/safe_damage_type = OXY
	var/list/gas_min = list()
	var/list/gas_max = list(
		/datum/gas/carbon_dioxide = 30, // Yes it's an arbitrary value who cares?
		/datum/breathing_class/plasma = MOLES_GAS_VISIBLE
	)
	var/list/gas_damage = list(
		"default" = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = OXY
		),
		/datum/gas/plasma = list(
			min = MIN_TOXIC_GAS_DAMAGE,
			max = MAX_TOXIC_GAS_DAMAGE,
			damage_type = TOX
		)
	)

	var/SA_para_min = 1 //nitrous values
	var/SA_sleep_min = 5
	var/BZ_trip_balls_min = 0.1 //BZ gas
	var/BZ_brain_damage_min = 1
	var/gas_stimulation_min = 0.002 //nitrium and Freon

	var/cold_message = "your face freezing and an icicle forming"
	var/cold_level_1_threshold = 260
	var/cold_level_2_threshold = 200
	var/cold_level_3_threshold = 120
	var/cold_level_1_damage = COLD_GAS_DAMAGE_LEVEL_1 //Keep in mind with gas damage levels, you can set these to be negative, if you want someone to heal, instead.
	var/cold_level_2_damage = COLD_GAS_DAMAGE_LEVEL_2
	var/cold_level_3_damage = COLD_GAS_DAMAGE_LEVEL_3
	var/cold_damage_type = BURN

	var/hot_message = "your face burning and a searing heat"
	var/heat_level_1_threshold = 360
	var/heat_level_2_threshold = 400
	var/heat_level_3_threshold = 1000
	var/heat_level_1_damage = HEAT_GAS_DAMAGE_LEVEL_1
	var/heat_level_2_damage = HEAT_GAS_DAMAGE_LEVEL_2
	var/heat_level_3_damage = HEAT_GAS_DAMAGE_LEVEL_3
	var/heat_damage_type = BURN

	var/list/thrown_alerts

	var/crit_stabilizing_reagent = /datum/reagent/medicine/epinephrine

/obj/item/organ/lungs/New()
	. = ..()
	populate_gas_info()

/obj/item/organ/lungs/Insert(mob/living/carbon/M, special, drop_if_replaced, pref_load)
	// This may look weird, but uh, organ code is weird, so we FIRST check to see if this organ is going into a NEW person.
	// If it is going into a new person, ..() will ensure that organ is Remove()d first, and we won't run into any issues with duplicate signals.
	var/new_owner = QDELETED(owner) || owner != M
	..()
	if(new_owner)
		RegisterSignal(M, SIGNAL_ADDTRAIT(TRAIT_NOBREATH), PROC_REF(on_nobreath))

/obj/item/organ/lungs/Remove(mob/living/carbon/M, special, pref_load)
	. = ..()
	UnregisterSignal(M, SIGNAL_ADDTRAIT(TRAIT_NOBREATH))
	LAZYNULL(thrown_alerts)

/obj/item/organ/lungs/proc/populate_gas_info()
	gas_min[breathing_class] = safe_breath_min
	gas_max[breathing_class] = safe_breath_max
	gas_damage[breathing_class] = list(
		min = safe_breath_dam_min,
		max = safe_breath_dam_max,
		damage_type = safe_damage_type
	)

/obj/item/organ/lungs/proc/on_nobreath(mob/living/carbon/source)
	SIGNAL_HANDLER
	var/static/list/breath_moodlets = list("chemical_euphoria", "suffocation") // Moodlets directly caused by breathing
	if(!istype(source))
		return
	source.failed_last_breath = FALSE
	for(var/alert_category in thrown_alerts)
		source.clear_alert(alert_category)
	LAZYNULL(thrown_alerts)
	for(var/moodlet in breath_moodlets)
		SEND_SIGNAL(source, COMSIG_CLEAR_MOOD_EVENT, moodlet)

/obj/item/organ/lungs/proc/throw_alert_for(mob/living/carbon/target, alert_category, alert_type)
	if(!istype(target) || !alert_category || !alert_type)
		return
	target.throw_alert(alert_category, alert_type)
	LAZYOR(thrown_alerts, alert_category)

/obj/item/organ/lungs/proc/clear_alert_for(mob/living/carbon/target, alert_category)
	if(!istype(target) || !alert_category)
		return
	target.clear_alert(alert_category)
	LAZYREMOVE(thrown_alerts, alert_category)

/obj/item/organ/lungs/proc/check_breath(datum/gas_mixture/breath, mob/living/carbon/human/H)
//TODO: add lung damage = less oxygen gains
	var/breathModifier = (5-(5*(damage/maxHealth)/2)) //range 2.5 - 5
	if(H.status_flags & GODMODE)
		return
	if(HAS_TRAIT(H, TRAIT_NOBREATH))
		return

	if(!breath || (breath.total_moles() == 0))
		if(H.reagents.has_reagent(crit_stabilizing_reagent))
			return
		if(H.health >= H.crit_threshold)
			H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		else if(!HAS_TRAIT(H, TRAIT_NOCRITDAMAGE))
			H.adjustOxyLoss(HUMAN_CRIT_MAX_OXYLOSS)

		H.failed_last_breath = TRUE
		var/alert_category
		var/alert_type
		if(ispath(breathing_class))
			var/datum/breathing_class/class = GLOB.breathing_class_info[breathing_class]
			alert_category = class.low_alert_category
			alert_type = class.low_alert_datum
		else
			var/list/alert = GLOB.meta_gas_info[breathing_class][META_GAS_BREATH_ALERT_INFO]?["not_enough_alert"]
			if(alert)
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
		throw_alert_for(H, alert_category, alert_type)
		return FALSE

	#define PP_MOLES(X) ((X / total_moles) * pressure)

	#define PP(air, gas) PP_MOLES(GET_MOLES(gas, air))

	var/gas_breathed = 0

	var/pressure = breath.return_pressure()
	var/total_moles = breath.total_moles()
	var/list/breathing_classes = GLOB.breathing_class_info
	var/list/mole_adjustments = list()
	for(var/entry in gas_min)
		var/required_pp = 0
		var/required_moles = 0
		var/safe_min = gas_min[entry]
		var/alert_category = null
		var/alert_type = null
		var/datum/breathing_class/class = breathing_classes[entry]
		if(class)
			var/list/gases = class.gases
			var/list/products = class.products
			alert_category = class.low_alert_category
			alert_type = class.low_alert_datum
			for(var/gas in gases)
				if (!(gas in breath.gases))
					continue
				var/moles = breath.gases[gas][MOLES]
				var/multiplier = gases[gas]
				mole_adjustments[gas] = (gas in mole_adjustments) ? mole_adjustments[gas] - moles : -moles
				required_pp += PP_MOLES(moles) * multiplier
				required_moles += moles
				if(multiplier > 0)
					var/to_add = moles * multiplier
					for(var/product in products)
						mole_adjustments[product] = (product in mole_adjustments) ? mole_adjustments[product] + to_add : to_add
		else
			required_moles = GET_MOLES(entry, breath)
			required_pp = PP_MOLES(required_moles)
			var/list/alert = GLOB.meta_gas_info[entry][META_GAS_BREATH_ALERT_INFO]?["not_enough_alert"]
			if(alert)
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
			mole_adjustments[entry] = -required_moles
			mole_adjustments[GLOB.meta_gas_info[entry][META_GAS_BREATH_RESULTS]] = required_moles
		if(required_pp < safe_min)
			var/multiplier = handle_too_little_breath(H, required_pp, safe_min, required_moles)
			if(required_moles > 0)
				multiplier /= required_moles
			for(var/adjustment in mole_adjustments)
				mole_adjustments[adjustment] *= multiplier
			throw_alert_for(H, alert_category, alert_type)
		else
			H.failed_last_breath = FALSE
			if(H.health >= H.crit_threshold)
				H.adjustOxyLoss(-breathModifier)
			clear_alert_for(H, alert_category)
	for(var/entry in gas_max)
		var/found_pp = 0
		var/datum/breathing_class/breathing_class = breathing_classes[entry]
		var/datum/reagent/danger_reagent = null
		var/alert_category = null
		var/alert_type = null
		if(breathing_class)
			alert_category = breathing_class.high_alert_category
			alert_type = breathing_class.high_alert_datum
			danger_reagent = breathing_class.danger_reagent
			found_pp = breathing_class.get_effective_pp(breath)
		else
			danger_reagent = GLOB.meta_gas_info[entry][META_GAS_BREATH_REAGENT_DANGEROUS]
			var/list/alert = GLOB.meta_gas_info[entry][META_GAS_BREATH_ALERT_INFO]?["too_much_alert"]
			if(alert)
				alert_category = alert["alert_category"]
				alert_type = alert["alert_type"]
			found_pp = PP(breath, entry)
		if(found_pp > gas_max[entry])
			if(danger_reagent && istype(danger_reagent))
				H.reagents.add_reagent(danger_reagent,1)
			var/list/damage_info = (entry in gas_damage) ? gas_damage[entry] : gas_damage["default"]
			var/dam = found_pp / gas_max[entry] * 10
			H.apply_damage_type(clamp(dam, damage_info["min"], damage_info["max"]), damage_info["damage_type"])
			throw_alert_for(H, alert_category, alert_type)
		else
			clear_alert_for(H, alert_category)
	for(var/gas in breath.gases)
		var/datum/reagent/R = GLOB.meta_gas_info[gas][META_GAS_BREATH_REAGENT]
		if(R)
			//H.reagents.add_reagent(R, breath.gases[gas][MOLES] * R.molarity) // See next line
			H.reagents.add_reagent(R, breath.gases[gas][MOLES] * 2) // 2 represents molarity of O2, we don't have citadel molarity
			mole_adjustments[gas] = (gas in mole_adjustments) ? mole_adjustments[gas] - breath.gases[gas][MOLES] : -breath.gases[gas][MOLES]

	for(var/gas in mole_adjustments)
		ADJUST_MOLES(gas, breath, mole_adjustments[gas])

	if(breath)	// If there's some other shit in the air lets deal with it here.

	// N2O

		var/SA_pp = PP(breath, /datum/gas/nitrous_oxide)
		if(SA_pp > SA_para_min) // Enough to make us stunned for a bit
			H.Unconscious(60) // 60 gives them one second to wake up and run away a bit!
			if(SA_pp > SA_sleep_min) // Enough to make us sleep as well
				H.Sleeping(max(H.AmountSleeping() + 40, 200))
		else if(SA_pp > 0.01)	// There is sleeping gas in their lungs, but only a little, so give them a bit of a warning
			if(prob(20))
				H.emote(pick("giggle", "laugh"))
				SEND_SIGNAL(owner, COMSIG_ADD_MOOD_EVENT, "chemical_euphoria", /datum/mood_event/chemical_euphoria)
		else
			SEND_SIGNAL(owner, COMSIG_CLEAR_MOOD_EVENT, "chemical_euphoria")

	// BZ

		var/bz_pp = PP(breath, /datum/gas/bz)
		if(bz_pp > BZ_brain_damage_min)
			H.hallucination += 10
			H.reagents.add_reagent(/datum/reagent/metabolite/bz,5)
			if(prob(33))
				H.adjustOrganLoss(ORGAN_SLOT_BRAIN, 3, 150)

		else if(bz_pp > BZ_trip_balls_min)
			H.hallucination += 5
			H.reagents.add_reagent(/datum/reagent/metabolite/bz,1)

	// Nitrium
		var/nitrium_pp = PP(breath, /datum/gas/nitrium)
		if (prob(nitrium_pp) && nitrium_pp > 15)
			H.adjustOrganLoss(ORGAN_SLOT_LUNGS, nitrium_pp * 0.1)
			to_chat(H, span_notice("You feel a burning sensation in your chest"))
		gas_breathed = PP(breath, /datum/gas/nitrium)
		if (nitrium_pp > 5)
			var/existing = H.reagents.get_reagent_amount(/datum/reagent/nitrium_low_metabolization)
			H.reagents.add_reagent(/datum/reagent/nitrium_low_metabolization, max(0, 2 - existing))
		if (nitrium_pp > 10)
			var/existing = H.reagents.get_reagent_amount(/datum/reagent/nitrium_high_metabolization)
			H.reagents.add_reagent(/datum/reagent/nitrium_high_metabolization, max(0, 1 - existing))

		REMOVE_MOLES(/datum/gas/nitrium, breath, gas_breathed)

		handle_breath_temperature(breath, H)

	return TRUE

/obj/item/organ/lungs/proc/handle_too_little_breath(mob/living/carbon/human/H = null, breath_pp = 0, safe_breath_min = 0, true_pp = 0)
	. = 0
	if(!H || !safe_breath_min) //the other args are either: Ok being 0 or Specifically handled.
		return FALSE

	if(prob(20))
		H.emote("gasp")
	if(breath_pp > 0)
		var/ratio = safe_breath_min/breath_pp
		H.adjustOxyLoss(min(5*ratio, HUMAN_MAX_OXYLOSS)) // Don't fuck them up too fast (space only does HUMAN_MAX_OXYLOSS after all!
		H.failed_last_breath = TRUE
		. = true_pp*ratio/6
	else
		H.adjustOxyLoss(HUMAN_MAX_OXYLOSS)
		H.failed_last_breath = TRUE

/obj/item/organ/lungs/proc/handle_breath_temperature(datum/gas_mixture/breath, mob/living/carbon/human/H) // called by human/life, handles temperatures
	var/breath_temperature = breath.return_temperature()

	if(!HAS_TRAIT(H, TRAIT_RESISTCOLD)) // COLD DAMAGE
		var/cold_modifier = H.dna.species.coldmod
		if(breath_temperature < cold_level_3_threshold)
			H.apply_damage_type(cold_level_3_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_3_threshold && breath_temperature < cold_level_2_threshold)
			H.apply_damage_type(cold_level_2_damage*cold_modifier, cold_damage_type)
		if(breath_temperature > cold_level_2_threshold && breath_temperature < cold_level_1_threshold)
			H.apply_damage_type(cold_level_1_damage*cold_modifier, cold_damage_type)
		if(breath_temperature < cold_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("You feel [cold_message] in your [name]!"))

	if(!HAS_TRAIT(H, TRAIT_RESISTHEAT)) // HEAT DAMAGE
		var/heat_modifier = H.dna.species.heatmod
		if(breath_temperature > heat_level_1_threshold && breath_temperature < heat_level_2_threshold)
			H.apply_damage_type(heat_level_1_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_2_threshold && breath_temperature < heat_level_3_threshold)
			H.apply_damage_type(heat_level_2_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_3_threshold)
			H.apply_damage_type(heat_level_3_damage*heat_modifier, heat_damage_type)
		if(breath_temperature > heat_level_1_threshold)
			if(prob(20))
				to_chat(H, span_warning("You feel [hot_message] in your [name]!"))

	// The air you breathe out should match your body temperature
	breath.temperature = H.bodytemperature

/obj/item/organ/lungs/on_life(delta_time, times_fired)
	..()
	if((!failed) && ((organ_flags & ORGAN_FAILING)))
		if(owner.stat == CONSCIOUS)
			owner.visible_message(span_userdanger("[owner] grabs [owner.p_their()] throat, struggling for breath!"))
		failed = TRUE
	else if(!(organ_flags & ORGAN_FAILING))
		failed = FALSE
	return

/obj/item/organ/lungs/get_availability(datum/species/S)
	return !(TRAIT_NOBREATH in S.species_traits)

/obj/item/organ/lungs/plasmaman
	name = "plasma filter"
	desc = "A spongy rib-shaped mass for filtering plasma from the air."
	icon_state = "lungs-plasma"

	breathing_class = BREATH_PLASMA

/obj/item/organ/lungs/plasmaman/populate_gas_info()
	..()
	gas_max -= /datum/breathing_class/plasma

/obj/item/organ/lungs/slime
	name = "vacuole"
	desc = "A large organelle designed to store oxygen and filter toxins."

/obj/item/organ/lungs/cybernetic
	name = "cybernetic lungs"
	desc = "A cybernetic version of the lungs found in traditional humanoid entities. Allows for greater intakes of oxygen than organic lungs, requiring slightly less pressure."
	icon_state = "lungs-c"
	organ_flags = ORGAN_SYNTHETIC
	status = ORGAN_ROBOTIC
	maxHealth = 1.1 * STANDARD_ORGAN_THRESHOLD
	safe_breath_min = 13
	safe_breath_max = 100

/obj/item/organ/lungs/cybernetic/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	if(prob(30/severity))
		owner.losebreath += 10


/obj/item/organ/lungs/cybernetic/upgraded
	name = "upgraded cybernetic lungs"
	desc = "A more advanced version of the stock cybernetic lungs. Features the ability to filter out lower levels of toxins and carbon dioxide."
	icon_state = "lungs-c-u"
	safe_breath_min = 4
	safe_breath_max = 250
	gas_max = list(
		/datum/gas/plasma = 30,
		/datum/gas/carbon_dioxide = 30
	)
	maxHealth = 2 * STANDARD_ORGAN_THRESHOLD

	cold_level_1_threshold = 200
	cold_level_2_threshold = 140
	cold_level_3_threshold = 100

/obj/item/organ/lungs/apid
	name = "apid lungs"
	desc = "Lungs from an apid, or beeperson. Thanks to the many spiracles an apid has, these lungs are capable of gathering more oxygen from low-pressure environments."
	icon_state = "lungs"
	safe_breath_min = 8

/obj/item/organ/lungs/ashwalker
	name = "ash walker lungs"
	desc = "Lungs belonging to the tribal group of lizardmen that have adapted to Lavaland's atmosphere, and thus can breathe its air safely but find the station's \
	air to be oversaturated with oxygen."
	safe_breath_min = 4
	safe_breath_max = 20
	gas_max = list(
		/datum/gas/carbon_dioxide = 45,
		/datum/gas/plasma = MOLES_GAS_VISIBLE
	)

/obj/item/organ/lungs/diona
	name = "diona leaves"
	desc = "A small mass concentrated leaves, used for breathing."
	icon_state = "diona_lungs"

#undef PP
#undef PP_MOLES

#undef BREATH_OXY
#undef BREATH_PLASMA
