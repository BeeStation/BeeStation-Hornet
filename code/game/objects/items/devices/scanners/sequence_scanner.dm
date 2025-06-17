/obj/item/sequence_scanner
	name = "genetic sequence scanner"
	icon = 'icons/obj/device.dmi'
	icon_state = "gene"
	item_state = "healthanalyzer"
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

/obj/item/sequence_scanner/attack(mob/living/target_mob, mob/living/user, params)
	add_fingerprint(user)

	if(HAS_TRAIT(target_mob, TRAIT_GENELESS) || HAS_TRAIT(target_mob, TRAIT_BADDNA))
		user.visible_message(
			span_notice("[user] failed to analyse [target_mob]'s genetic sequence."),
			span_warning("[target_mob] has no readable genetic sequence!")
		)
		return

	user.visible_message(span_notice("[user] analyzes [target_mob]'s genetic sequence."))
	user.balloon_alert(user, "sequence analyzed")
	playsound(src, 'sound/effects/fastbeep.ogg', 20)

	gene_scan(target_mob, user)

/obj/item/sequence_scanner/attack_self(mob/user)
	display_sequence(user)

/obj/item/sequence_scanner/attack_self_tk(mob/user)
	return

/obj/item/sequence_scanner/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!istype(target, /obj/machinery/computer/scan_consolenew) || !proximity_flag)
		return

	var/obj/machinery/computer/scan_consolenew/console = target
	if(console.stored_research)
		to_chat(user, span_notice("[name] database updated."))
		discovered = console.stored_research.discovered_mutations
	else
		to_chat(user, span_warning("No database to update from."))

/obj/item/sequence_scanner/proc/gene_scan(mob/living/carbon/carbon_target, mob/living/user)
	if(!iscarbon(carbon_target) || !carbon_target.has_dna())
		return
	buffer = carbon_target.dna.mutation_index
	to_chat(user, span_notice("Subject [carbon_target]'s DNA sequence has been saved to buffer."))
	genescan(carbon_target, user, discovered)

/obj/item/sequence_scanner/proc/display_sequence(mob/living/user)
	if(!LAZYLEN(buffer) || !ready)
		return
	var/list/options = list()
	for(var/A in buffer)
		options += get_display_name(A)

	var/answer = input(user, "Analyze Potential", "Sequence Analyzer")  as null|anything in sort_list(options)
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

/proc/genescan(mob/living/carbon/C, mob/user, list/discovered)
	. = TRUE
	if(!iscarbon(C) || !C.has_dna())
		return FALSE
	if(HAS_TRAIT(C, TRAIT_RADIMMUNE) || HAS_TRAIT(C, TRAIT_BADDNA))
		return FALSE
	var/list/message = list()
	var/list/active_inherent_muts = list()
	var/list/active_injected_muts = list()
	var/list/inherent_muts = list()
	var/list/mut_index = C.dna.mutation_index.Copy()

	for(var/datum/mutation/each in C.dna.mutations)
		//get name and alias if discovered (or no discovered list was provided) or just alias if not
		var/datum/mutation/each_mutation = GET_INITIALIZED_MUTATION(each.type) //have to do this as instances of mutation do not have alias but global ones do....
		var/each_mut_details = "ERROR"
		if(!discovered || (each_mutation.type in discovered))
			each_mut_details = span_info("[each_mutation.name] ([each_mutation.alias])")
		else
			each_mut_details = span_info("[each_mutation.alias]")

		if(each_mutation.type in mut_index)
			//add mutation readout for all active inherent mutations
			active_inherent_muts += "[each_mut_details][span_infobold(" : Active ")]"
			mut_index -= each_mutation.type
		else
			//add mutation readout for all injected (not inherent) mutations
			active_injected_muts += each_mut_details

	for(var/each in mut_index)
		var/datum/mutation/each_mutation = GET_INITIALIZED_MUTATION(each)
		var/each_mut_details = "ERROR"
		if(each_mutation)
			//repeating this code twice is nasty, but nested procs (if even possible??) or more global procs then needed is... less so
			if(!discovered || (each_mutation.type in discovered))
				each_mut_details = span_info("[each_mutation.name] ([each_mutation.alias])")
			else
				each_mut_details = span_info("[each_mutation.alias]")
		inherent_muts += each_mut_details

	message += span_noticebold("[C] scan results")
	active_inherent_muts.len > 0 ? (message += "[jointext(active_inherent_muts, "\n")]") : ""
	inherent_muts.len > 0 ? (message += "[jointext(inherent_muts, "\n")]") : ""
	active_injected_muts.len > 0 ? (message += "[span_infobold("Injected mutations:\n")][jointext(active_injected_muts, "\n")]") : ""

	to_chat(user, examine_block(jointext(message, "\n")), avoid_highlighting = TRUE, trailing_newline = FALSE, type = MESSAGE_TYPE_INFO)
