
/*

CONTAINS:
T-RAY
HEALTH ANALYZER
GAS ANALYZER
SLIME SCANNER
NANITE SCANNER
GENE SCANNER

*/

/obj/item/nanite_scanner
	name = "nanite scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "nanite_scanner"
	inhand_icon_state = "nanite_remote"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held body scanner able to detect nanites and their programming."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)

/obj/item/nanite_scanner/attack(mob/living/M, mob/living/carbon/human/user)
	user.visible_message(span_notice("[user] analyzes [M]'s nanites."), \
						span_notice("You analyze [M]'s nanites."))

	add_fingerprint(user)

	var/response = SEND_SIGNAL(M, COMSIG_NANITE_SCAN, user, TRUE)
	if(!response)
		to_chat(user, span_info("No nanites detected in the subject."))

/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	inhand_icon_state = "healthanalyzer"
	worn_icon_state = "healthanalyzer"
	lefthand_file = 'icons/mob/inhands/equipment/medical_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/medical_righthand.dmi'
	desc = "A hand-held scanner for analyzing someones gene sequence on the fly. Hold near a DNA console to update the internal database."
	flags_1 = CONDUCT_1
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	throwforce = 3
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 3
	throw_range = 7
	custom_materials = list(/datum/material/iron=200)
	var/list/discovered = list() //hit a dna console to update the scanners database
	var/list/buffer
	var/ready = TRUE
	var/cooldown = 200

/obj/item/sequence_scanner/attack(mob/living/M, mob/living/user)
	add_fingerprint(user)
	if(!HAS_TRAIT(M, TRAIT_RADIMMUNE) && !HAS_TRAIT(M, TRAIT_BADDNA)) //no scanning if its a husk or DNA-less Species
		user.visible_message(span_notice("[user] analyzes [M]'s genetic sequence."), \
							span_notice("You analyze [M]'s genetic sequence."))
		gene_scan(M, user)
		playsound(src, 'sound/effects/fastbeep.ogg', 20)

	else
		user.visible_message(span_notice("[user] failed to analyse [M]'s genetic sequence."), span_warning("[M] has no readable genetic sequence!"))

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(obj/O, mob/user, proximity)
	. = ..()
	if(!istype(O) || !proximity)
		return

	if(istype(O, /obj/machinery/computer/scan_consolenew))
		var/obj/machinery/computer/scan_consolenew/C = O
		if(C.stored_research)
			to_chat(user, span_notice("[name] linked to central research database."))
			discovered = C.stored_research.discovered_mutations
		else
			to_chat(user,span_warning("No database to update from."))

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/C, mob/living/user)
	if(!iscarbon(C) || !C.has_dna())
		return
	buffer = C.dna.mutation_index
	to_chat(user, "<span class='notice'>Subject [C.name]'s DNA sequence has been saved to buffer.</span>")
	genescan(C, user, discovered)

/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = tgui_input_list(user, "Analyze Potential", "Sequence Analyzer", sort_list(options))
	if(answer && ready && user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		var/sequence
		for(var/A in buffer) //this physically hurts but i dont know what anything else short of an assoc list
			if(get_display_name(A) == answer)
				sequence = buffer[A]
				break

		if(sequence)
			var/display
			for(var/i in 0 to length_char(sequence) / DNA_MUTATION_BLOCKS-1)
				if(i)
					display += "-"
				display += copytext_char(sequence, 1 + i*DNA_MUTATION_BLOCKS, DNA_MUTATION_BLOCKS*(1+i) + 1)

			to_chat(user, "[span_boldnotice("[display]")]<br>")

		ready = FALSE
		icon_state = "[icon_state]_recharging"
		addtimer(CALLBACK(src, PROC_REF(recharge)), cooldown, TIMER_UNIQUE)

/obj/item/sequence_scanner/proc/recharge()
	icon_state = initial(icon_state)
	ready = TRUE

/obj/item/sequence_scanner/proc/get_display_name(mutation, active_detail=FALSE)
	var/datum/mutation/HM = GET_INITIALIZED_MUTATION(mutation)
	if(!HM)
		return "ERROR"
	if(discovered[mutation])
		return !active_detail ? "[HM.name] ([HM.alias])" : span_green("[HM.name] ([HM.alias]) - [active_detail]")
	else
		return !active_detail ? HM.alias : span_green("[HM.alias] - [active_detail]")

/obj/item/extrapolator
	name = "virus extrapolator"
	icon = 'icons/obj/device.dmi'
	icon_state = "extrapolator_scan"
	worn_icon_state = "healthanalyzer"
	desc = "A bulky scanning device, used to extract genetic material of potential pathogens."
	item_flags = NOBLUDGEON
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_NORMAL
	/// Whether the extrapolator is currently in use.
	var/using = FALSE
	/// Whether the extrapolator is currently in SCAN or EXTRACT mode.
	var/scan = TRUE
	/// The scanning module installed in the extrapolator. Used to determine extraction speed, and the stealthiest virus that's possible to extract.
	var/obj/item/stock_parts/scanning_module/scanner
	/// A list of advance disease IDs that this extrapolator has already extracted.
	var/list/extracted_ids = list()
	/// How long it takes, in deciseconds, for the extrapolator to extract a virus.
	var/extract_time = 10 SECONDS
	/// How long it takes, in deciseconds, for the extrapolator to isolate a symptom.
	var/isolate_time = 15 SECONDS
	/// The extrapolator can extract any virus with a stealth below this value.
	var/maximum_stealth = 3
	/// The extrapolator can extract any symptom with a stealth below this value.
	var/maximum_level = 7
	/// The typepath of the default scanning module that will generate in the extrapolator, if it starts with none.
	var/default_scanning_module = /obj/item/stock_parts/scanning_module
	/// Cooldown for when the extrapolator can be used next.
	COOLDOWN_DECLARE(usage_cooldown)

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/extrapolator)

/obj/item/extrapolator/Initialize(mapload, obj/item/stock_parts/scanning_module/starting_scanner)
	. = ..()
	starting_scanner = starting_scanner || default_scanning_module
	if(ispath(starting_scanner, /obj/item/stock_parts/scanning_module))
		scanner = new starting_scanner(src)
	else if(istype(starting_scanner))
		starting_scanner.forceMove(src)
		scanner = starting_scanner
	refresh_parts()

/obj/item/extrapolator/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/stock_parts/scanning_module))
		if(!scanner)
			if(!user.transferItemToLoc(item, src))
				return
			scanner = item
			to_chat(user, span_notice("You install \the [scanner] in [src]."))
			refresh_parts()
		else
			to_chat(user, span_notice("[src] already has \the [scanner] installed."))
		return
	return ..()

/obj/item/extrapolator/screwdriver_act(mob/living/user, obj/item/item)
	. = TRUE
	if(..())
		return
	if(!scanner)
		to_chat(user, span_warning("\The [src] has no scanner to remove!"))
		return FALSE
	to_chat(user, span_notice("You remove \the [scanner] from \the [src]."))
	scanner.forceMove(drop_location())
	scanner = null
	item.play_tool_sound(src)

/obj/item/extrapolator/attack_self(mob/user)
	. = ..()
	playsound(src, 'sound/machines/click.ogg', vol = 50, vary = TRUE)
	if(scan)
		icon_state = "extrapolator_sample"
		scan = FALSE
		to_chat(user, span_notice("You remove the probe from the device and set it to EXTRACT."))
	else
		icon_state = "extrapolator_scan"
		scan = TRUE
		to_chat(user, span_notice("You put the probe back in the device and set it to SCAN."))

/obj/item/extrapolator/examine(mob/user)
	. = ..()
	if(in_range(user, src) || isobserver(user))
		if(!scanner)
			. += span_notice("The scanner is missing.")
		else
			. += span_notice("A class <b>[scanner.rating]</b> scanning module is installed. It is <i>screwed</i> in place.")
			. += span_notice("Can detect diseases <b>below stealth [maximum_stealth]</b>.")
			. += span_notice("Can extract diseases in <b>[DisplayTimeText(extract_time)]</b>.")
			. += span_notice("Can isolate symptoms <b>[maximum_level >= 9 ? "of any level" : "below level [maximum_level]"]</b>, in <b>[DisplayTimeText(isolate_time)]</b>.")

/**
 * Updates the extraction and isolation times based on the scanner's rating.
 */
/obj/item/extrapolator/proc/refresh_parts()
	if(!scanner)
		return
	var/effective_scanner_rating = scanner.rating + 1
	extract_time = (10 SECONDS) / effective_scanner_rating
	isolate_time = (15 SECONDS) / effective_scanner_rating
	maximum_stealth = scanner.rating + 2
	maximum_level = scanner.rating + 7

/obj/item/extrapolator/attack(atom/AM, mob/living/user)
	return

/obj/item/extrapolator/afterattack(atom/target, mob/living/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag && !scan)
		return
	if(using)
		to_chat(user, span_warning("[icon2html(src, user)] The extrapolator is already in use."))
		return
	if(!COOLDOWN_FINISHED(src, usage_cooldown))
		to_chat(user, span_warning("[icon2html(src, user)] The extrapolator is still recharging!"))
		return
	if(scanner)
		var/list/result = target?.extrapolator_act(user, src, dry_run = TRUE)
		var/list/diseases = result && result[EXTRAPOLATOR_RESULT_DISEASES]
		if(!length(diseases))
			var/list/atom/targets = find_valid_targets(user, target)
			var/target_amt = length(targets)
			if(target_amt)
				target = target_amt > 1 ? tgui_input_list(user, "Select object to analyze", "Viral Extrapolation", targets, default = targets[1]) : targets[1]
			if(target)
				result = target.extrapolator_act(user, src, dry_run = TRUE)
				diseases = result && result[EXTRAPOLATOR_RESULT_DISEASES]
		if(!target)
			return
		if(!length(diseases))
			if(scan)
				to_chat(user, span_notice("[icon2html(src, user)] \The [src] fails to return any data."))
			else
				to_chat(user, span_notice("[icon2html(src, user)] \The [src]'s probe detects no diseases."))
			return
		if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_SPECIAL))
			// extrapolator_act did some sort of special behavior, we don't need to do anything further
			return
		if(scan)
			virusscan(user, target, maximum_stealth, maximum_level, extracted_ids)
		else
			extrapolate(user, target)
	else
		to_chat(user, span_warning("The extrapolator has no scanner installed!"))

/obj/item/extrapolator/proc/find_valid_targets(mob/living/user, atom/target)
	. = list()
	var/turf/target_turf = get_turf(target)
	if(!target_turf)
		return
	for(var/atom/target_to_try in target_turf.contents - target)
		var/list/result = target_to_try.extrapolator_act(user, src, dry_run = TRUE)
		if(length(result[EXTRAPOLATOR_RESULT_DISEASES]))
			. += target_to_try



/**
 * Attempts to either extract a disease from an atom, or isolate a symptom from an advance disease.
 */
/obj/item/extrapolator/proc/extrapolate(mob/living/user, atom/target, isolate = FALSE)
	. = FALSE
	var/list/result = target?.extrapolator_act(user, target)
	var/list/diseases = result[EXTRAPOLATOR_RESULT_DISEASES]
	if(!length(diseases))
		return
	if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_SPECIAL)) // hardcoded "we handled this ourselves" response
		return TRUE
	if(EXTRAPOLATOR_ACT_CHECK(result, EXTRAPOLATOR_ACT_PRIORITY_ISOLATE))
		isolate = TRUE
	var/list/advance_diseases = list()
	for(var/datum/disease/advance/candidate in diseases)
		advance_diseases += candidate
	if(!length(advance_diseases))
		to_chat(user, span_warning("[icon2html(src, user)] There are no valid diseases to make a culture from."))
		return
	var/datum/disease/advance/target_disease = length(advance_diseases) > 1 ? tgui_input_list(user, "Select disease to extract", "Viral Extraction", advance_diseases, default = advance_diseases[1]) : advance_diseases[1]
	if(!target_disease)
		return
	using = TRUE
	if(isolate && CONFIG_GET(flag/isolation_allowed))
		. = isolate_symptom(user, target, target_disease)
	else
		. = isolate_disease(user, target, target_disease)
	using = FALSE

/**
 * Attempts to isolate a single symptom from an advance disease.
 */
/obj/item/extrapolator/proc/isolate_symptom(mob/living/user, atom/target, datum/disease/advance/target_disease)
	. = FALSE
	if(!CONFIG_GET(flag/isolation_allowed))
		return FALSE
	var/list/symptoms = list()
	for(var/datum/symptom/symptom in target_disease.symptoms)
		if(symptom.level <= maximum_level)
			symptoms += symptom
			continue
	if(!length(symptoms))
		to_chat(user, span_warning("[icon2html(src, user)] There are no symptoms that could be isolated.."))
		return
	var/datum/symptom/chosen = length(symptoms) > 1 ? tgui_input_list(user, "Select symptom to isolate", "Symptom Extraction", symptoms, default = symptoms[1]) : symptoms[1]
	if(!chosen)
		return
	user.visible_message(span_notice("[user] slots [target] into [src], which begins to whir and beep!"), \
		span_notice("[icon2html(src, user)] You begin isolating <b>[chosen.name]</b> from [target]..."), \
		vision_distance = COMBAT_MESSAGE_RANGE)
	var/datum/disease/advance/symptom_holder = new
	symptom_holder.name = chosen.name
	symptom_holder.symptoms += chosen
	symptom_holder.Finalize()
	symptom_holder.Refresh()
	if(do_after(user, extract_time, target = target))
		create_culture(user, symptom_holder, target)
		return TRUE

/**
 * Attempts to isolate an advance disease from a target.
 */
/obj/item/extrapolator/proc/isolate_disease(mob/living/user, atom/target, datum/disease/advance/target_disease, timer = 10 SECONDS)
	. = FALSE
	user.visible_message(span_notice("[user] begins to thoroughly scan [target] with [src]..."), \
		span_notice("[icon2html(src, user)] You begin isolating <b>[target_disease.name]</b> from [target]..."))
	if(do_after(user, isolate_time, target = target))
		create_culture(user, target_disease, target)
		return TRUE

/**
 * Creates a culture of an advance disease.
 */
/obj/item/extrapolator/proc/create_culture(mob/living/user, datum/disease/advance/disease)
	. = FALSE
	disease = disease.Copy()
	disease.dormant = FALSE
	var/list/data = list("viruses" = list(disease))
	if(user.get_active_held_item() != src)
		to_chat(user, span_warning("The extrapolator must be held in your active hand to work!"))
		return
	var/obj/item/reagent_containers/cup/bottle/culture_bottle = new(user.drop_location())
	culture_bottle.name = "[disease.name] culture bottle"
	culture_bottle.desc = "A small bottle. Contains [disease.agent] culture in synthblood medium."
	culture_bottle.reagents.add_reagent(/datum/reagent/blood, 20, data)
	user.put_in_hands(culture_bottle)
	playsound(src, 'sound/machines/ping.ogg', vol = 30, vary = TRUE)
	COOLDOWN_START(src, usage_cooldown, 1 SECONDS)
	extracted_ids[disease.GetDiseaseID()] = TRUE
	return TRUE

/obj/item/extrapolator/tier4
	default_scanning_module = /obj/item/stock_parts/scanning_module/triphasic
