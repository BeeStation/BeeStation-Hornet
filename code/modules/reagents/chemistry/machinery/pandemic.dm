#define MAIN_SCREEN 1
#define SYMPTOM_DETAILS 2

/obj/machinery/computer/pandemic
	name = "PanD.E.M.I.C 2200"
	desc = "Used to work with viruses."
	density = TRUE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "pand0"
	use_power = IDLE_POWER_USE
	idle_power_usage = 20
	resistance_flags = ACID_PROOF
	circuit = /obj/item/circuitboard/computer/pandemic

	base_icon_state = null
	smoothing_flags = NONE
	smoothing_groups = null
	canSmoothWith = null

	var/wait
	var/datum/symptom/selected_symptom
	var/obj/item/reagent_containers/beaker

/obj/machinery/computer/pandemic/Initialize(mapload)
	. = ..()
	update_icon()

/obj/machinery/computer/pandemic/Destroy()
	QDEL_NULL(beaker)
	return ..()

/obj/machinery/computer/pandemic/examine(mob/user)
	. = ..()
	if(beaker)
		var/is_close
		if(Adjacent(user)) //don't reveal exactly what's inside unless they're close enough to see the UI anyway.
			. += "It contains \a [beaker]."
			is_close = TRUE
		else
			. += "It has a beaker inside it."
		. += span_info("Alt-click to eject [is_close ? beaker : "the beaker"].")

/obj/machinery/computer/pandemic/attack_hand_secondary(mob/user, list/modifiers)
	. = ..()
	if(. == SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN)
		return
	if(!can_interact(user) || !user.canUseTopic(src, !issilicon(user), FALSE, NO_TK))
		return
	eject_beaker()
	return SECONDARY_ATTACK_CANCEL_ATTACK_CHAIN

/obj/machinery/computer/pandemic/attack_robot_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/computer/pandemic/attack_ai_secondary(mob/user, list/modifiers)
	return attack_hand_secondary(user, modifiers)

/obj/machinery/computer/pandemic/handle_atom_del(atom/thingy)
	if(thingy == beaker)
		beaker = null
		update_icon()
	return ..()

/obj/machinery/computer/pandemic/proc/get_by_index(thing, index)
	if(!beaker?.reagents)
		return
	var/datum/reagent/blood/blood = locate() in beaker.reagents.reagent_list
	if(length(blood?.data) && blood.data[thing])
		return blood.data[thing][index]

/obj/machinery/computer/pandemic/proc/get_virus_by_index(index)
	return get_by_index("viruses", index)

/obj/machinery/computer/pandemic/proc/get_virus_id_by_index(index)
	var/datum/disease/virus = get_virus_by_index(index)
	return virus?.GetDiseaseID()

/obj/machinery/computer/pandemic/proc/get_viruses_data(datum/reagent/blood/blood)
	. = list()
	var/list/virus_list = blood.get_diseases()
	var/index = 1
	for(var/datum/disease/virus in virus_list)
		if(CHECK_BITFIELD(virus.visibility_flags, HIDDEN_PANDEMIC))
			continue

		var/list/this = list()
		this["name"] = virus.name
		if(istype(virus, /datum/disease/advance))
			var/datum/disease/advance/adv_virus = virus
			var/disease_name = SSdisease.get_disease_name(adv_virus.GetDiseaseID())
			this["can_rename"] = ((disease_name == "Unknown") && adv_virus.mutable)
			this["name"] = disease_name
			this["is_adv"] = TRUE
			this["symptoms"] = list()
			for(var/datum/symptom/symptom as() in adv_virus.symptoms)
				this["symptoms"] += list(get_symptom_data(symptom))
			this["resistance"] = adv_virus.resistance
			this["stealth"] = adv_virus.stealth
			this["stage_speed"] = adv_virus.stage_rate
			this["transmission"] = adv_virus.transmission
			this["symptom_severity"] = adv_virus.severity

		this["index"] = index++
		this["agent"] = virus.agent
		this["description"] = virus.desc || "none"
		this["spread"] = virus.spread_text || "none"
		this["cure"] = virus.cure_text || "none"
		this["danger"] = virus.danger || "none"

		. += list(this)

/obj/machinery/computer/pandemic/proc/get_symptom_data(datum/symptom/symptom)
	. = list()
	var/list/this = list()
	this["name"] = symptom.name
	this["desc"] = symptom.desc
	this["stealth"] = symptom.stealth
	this["resistance"] = symptom.resistance
	this["stage_speed"] = symptom.stage_speed
	this["transmission"] = symptom.transmission
	this["level"] = symptom.level
	this["neutered"] = symptom.neutered
	this["threshold_desc"] = symptom.threshold_desc
	this["severity"] = symptom.severity
	. += this

/obj/machinery/computer/pandemic/proc/get_resistance_data(datum/reagent/blood/blood)
	. = list()
	var/list/resistances = blood.data["resistances"]
	if(!islist(resistances))
		return
	for(var/id in resistances)
		var/list/this = list()
		var/datum/disease/disease = SSdisease.archive_diseases[id]
		if(disease)
			this["id"] = id
			this["name"] = disease.name
		. += list(this)

/obj/machinery/computer/pandemic/proc/reset_replicator_cooldown()
	wait = FALSE
	update_icon()
	SStgui.update_uis(src)
	playsound(src, 'sound/machines/ping.ogg', 30, TRUE)

/obj/machinery/computer/pandemic/update_icon()
	if(CHECK_BITFIELD(machine_stat, BROKEN))
		icon_state = (beaker ? "pand1_b" : "pand0_b")
		return

	icon_state = "pand[(beaker) ? "1" : "0"][powered() ? "" : "_nopower"]"
	if(wait)
		add_overlay("waitlight")
	else
		cut_overlays()

/obj/machinery/computer/pandemic/proc/eject_beaker()
	if(beaker)
		try_put_in_hand(beaker, usr)
		beaker = null
		update_icon()
		ui_update()

/obj/machinery/computer/pandemic/ui_state(mob/user)
	return GLOB.default_state

/obj/machinery/computer/pandemic/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Pandemic")
		ui.open()

/obj/machinery/computer/pandemic/ui_data(mob/user)
	. = list(
		"is_ready" = !wait,
		"has_beaker" = FALSE,
		"has_blood" = FALSE
	)
	if(QDELETED(beaker))
		return
	.["has_beaker"] = TRUE
	.["beaker_empty"] = !beaker.reagents.total_volume || !length(beaker.reagents.reagent_list)
	var/datum/reagent/blood/blood = locate() in beaker.reagents.reagent_list
	if(!blood)
		return
	.["has_blood"] = TRUE
	.[/datum/reagent/blood] = list(
		"dna" = blood.data["blood_DNA"] || "none",
		"type" = blood.data["blood_type"] || "none"
	)
	.["viruses"] = get_viruses_data(blood)
	.["resistances"] = get_resistance_data(blood)

/obj/machinery/computer/pandemic/ui_act(action, params)
	if(..())
		return
	switch(action)
		if("eject_beaker")
			eject_beaker()
			. = TRUE
		if("empty_beaker")
			if(!QDELETED(beaker))
				beaker.reagents.clear_reagents()
			. = TRUE
		if("empty_eject_beaker")
			if(!QDELETED(beaker))
				beaker.reagents.clear_reagents()
				eject_beaker()
			. = TRUE
		if("rename_disease")
			var/id = get_virus_id_by_index(text2num(params["index"]))
			var/datum/disease/advance/disease = SSdisease.archive_diseases[id]
			if(istype(disease) && disease.mutable)
				var/new_name = sanitize_name(html_encode(params["name"]))
				if(!new_name || ..())
					return
				disease.AssignName(new_name)
				. = TRUE
		if("create_culture_bottle")
			if(wait)
				return
			var/datum/disease/advance/inserted_disease = get_virus_by_index(text2num(params["index"]))
			if(!istype(inserted_disease))
				to_chat(usr, span_warning("ERROR: Virus not found."))
				return
			var/id = inserted_disease.GetDiseaseID()
			var/datum/disease/advance/archived_disease = SSdisease.archive_diseases[id]
			if(!istype(archived_disease) || !archived_disease.mutable)
				to_chat(usr, span_warning("ERROR: Cannot replicate virus strain."))
				return
			var/datum/disease/advance/new_disease = inserted_disease.Copy()
			new_disease.carrier = FALSE
			new_disease.dormant = FALSE
			new_disease.Refresh()
			var/list/data = list("viruses" = list(new_disease))
			var/obj/item/reagent_containers/cup/bottle/culture_bottle = new(drop_location())
			culture_bottle.name = "[new_disease.name] culture bottle"
			culture_bottle.desc = "A small bottle. Contains [new_disease.agent] culture in synthblood medium."
			culture_bottle.reagents.add_reagent(/datum/reagent/blood, 20, data)
			wait = TRUE
			update_icon()
			var/turf/source_turf = get_turf(src)
			log_virus("A culture bottle was printed for the virus [new_disease.admin_details()] at [loc_name(source_turf)] by [key_name(usr)]")
			addtimer(CALLBACK(src, PROC_REF(reset_replicator_cooldown)), 50)
			. = TRUE
		if("create_vaccine_bottle")
			if(wait)
				return
			var/id = params["index"]
			var/datum/disease/disease = SSdisease.archive_diseases[id]
			var/obj/item/reagent_containers/cup/bottle/vaccine_bottle = new(drop_location())
			vaccine_bottle.name = "[disease.name] vaccine bottle"
			vaccine_bottle.reagents.add_reagent(/datum/reagent/vaccine, 15, list(id))
			var/turf/source_turf = get_turf(src)
			log_virus("A vaccine bottle was printed for the virus [disease.admin_details()] at [loc_name(source_turf)] by [key_name(usr)]")
			wait = TRUE
			update_icon()
			addtimer(CALLBACK(src, PROC_REF(reset_replicator_cooldown)), 200)
			. = TRUE

/obj/machinery/computer/pandemic/attackby(obj/item/item, mob/user, params)
	if(istype(item, /obj/item/reagent_containers) && !CHECK_BITFIELD(item.item_flags, ABSTRACT) && item.is_open_container())
		. = TRUE //no afterattack
		if(CHECK_BITFIELD(machine_stat, (NOPOWER|BROKEN)))
			return
		if(!QDELETED(beaker))
			to_chat(user, span_warning("A container is already loaded into [src]!"))
			return
		if(!user.transferItemToLoc(item, src))
			return
		beaker = item
		to_chat(user, span_notice("You insert [item] into [src]."))
		update_icon()
		ui_update()
	else
		return ..()

/obj/machinery/computer/pandemic/on_deconstruction()
	eject_beaker()
	. = ..()

#undef MAIN_SCREEN
#undef SYMPTOM_DETAILS
