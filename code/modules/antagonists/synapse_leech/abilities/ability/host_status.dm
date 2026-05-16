/datum/action/leech/host_status
	name = "Host Status"
	desc = "Check on the status of your current host, and inject chemicals directly into their bloodstream."
	power_explanation = "Opens a menu to view and manage the status of your current host."
	button_icon_state = "inject"

	cooldown_time = 1 SECONDS

	burrow_usage_flags = LEECH_ABILITY_USABLE_BURROWED

/// Static metadata describing every reagent the leech can inject through this UI.
/// "goal" is the at-a-glance reason a leech would pick it (the actual problem it solves).
/// "label" is the simple-english effect name. "flavor" is the in-universe (flowery) reagent name.
GLOBAL_LIST_INIT(leech_injectable_chems, list(
	// === HEALING ===
	"brute_burn" = list(
		"typepath" = /datum/reagent/medicine/leech_bruteburn,
		"category" = "Healing",
		"goal" = "Heal physical & burn wounds",
		"label" = "Brute & Burn Repair",
		"flavor" = "Hematodermic Fibrilase",
		"description" = "Knits muscle and skin, healing brute and burn damage steadily.",
		"warning" = null,
	),
	"toxpurge" = list(
		"typepath" = /datum/reagent/medicine/leech_toxpurge,
		"category" = "Healing",
		"goal" = "Purge toxins, mutations, and cellular damage",
		"label" = "Toxin Purge",
		"flavor" = "Xenotrophic Neutralysin",
		"description" = "Removes toxin reagents and heals tox/clone damage. Strips mutations.",
		"warning" = null,
	),
	"oxyfix" = list(
		"typepath" = /datum/reagent/medicine/leech_oxyfix,
		"category" = "Healing",
		"goal" = "Stop suffocation, revive from crit",
		"label" = "Oxygen Restorer",
		"flavor" = "Adrenalic Surge Polymer",
		"description" = "Restores breathing, clears immobility, stabilizes a host bleeding out in crit.",
		"warning" = null,
	),
	"organheal" = list(
		"typepath" = /datum/reagent/medicine/leech_organheal,
		"category" = "Healing",
		"goal" = "Repair damaged organs (esp. brain) and brain trauma",
		"label" = "Organ Repair",
		"flavor" = "Gliostatic Myelostim",
		"description" = "Heals all internal organs. Brain heals fastest. Chance to cure brain traumas.",
		"warning" = null,
	),
	"bloodclot" = list(
		"typepath" = /datum/reagent/medicine/leech_bloodclot,
		"category" = "Healing",
		"goal" = "Stop bleeding, restore blood",
		"label" = "Clotting & Blood Restore",
		"flavor" = "Coagulant Myelofroth",
		"description" = "Seals bleeds and refills blood volume. Slight brute heal as a bonus.",
		"warning" = null,
	),
	"reanimant" = list(
		"typepath" = /datum/reagent/medicine/leech_reanimant,
		"category" = "Healing",
		"goal" = "Last-resort revive — heal everything at once",
		"label" = "Emergency Revival Surge",
		"flavor" = "Hyphovariant Reanimant",
		"description" = "Powerful all-damage heal and clotting burst. Causes spasms, jitter and dropped items.",
		"warning" = "Causes severe motor side effects.",
	),

	// === BUFFS ===
	"stunshield" = list(
		"typepath" = /datum/reagent/medicine/leech_stunshield,
		"category" = "Buff",
		"goal" = "Make host immune to stuns",
		"label" = "Stun Immunity",
		"flavor" = "Heliothene Substrate",
		"description" = "Grants stun immunity, clears existing stuns, and regenerates stamina.",
		"warning" = null,
	),
	"speedboost" = list(
		"typepath" = /datum/reagent/medicine/leech_speedboost,
		"category" = "Buff",
		"goal" = "Make host run faster",
		"label" = "Movement Speed Boost",
		"flavor" = "Xyrthropenic Lattice Serum",
		"description" = "Significantly increases host movement speed. Mild stamina drain.",
		"warning" = null,
	),

	// === DEBUFFS ===
	"toxin" = list(
		"typepath" = /datum/reagent/toxin/leech_toxin,
		"category" = "Debuff",
		"goal" = "Slowly cripple and kill someone",
		"label" = "Crippling Neurotoxin",
		"flavor" = "Nocivorant Mycelotoxin",
		"description" = "Escalating pain, blur, motor failure, paralysis, and finally brain death over time.",
		"warning" = "Lethal in large doses.",
	),
	"stun" = list(
		"typepath" = /datum/reagent/toxin/leech_stun,
		"category" = "Debuff",
		"goal" = "Paralyze the host for a fight",
		"label" = "Paralytic",
		"flavor" = "Corticolytic Paralytide",
		"description" = "Builds stamina damage rapidly, then collapses the victim into sustained paralysis.",
		"warning" = null,
	),
	"fakedeath" = list(
		"typepath" = /datum/reagent/toxin/leech_fakedeath,
		"category" = "Debuff",
		"goal" = "Make host appear dead",
		"label" = "Fake Death",
		"flavor" = "Somnic Virellate",
		"description" = "Puts the host into a fake-death state, suppressing speech and vital signs.",
		"warning" = "The host will appear deceased to most scanners.",
	),
))

/datum/action/leech/host_status/can_use()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	if(!leech || !host)
		return FALSE

	if(!leech.nested)
		return FALSE

	return TRUE

/datum/action/leech/host_status/activate_leech_power()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	if(!leech)
		return FALSE
	ui_interact(leech)
	return TRUE

/datum/action/leech/host_status/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "LeechHostStatus")
		ui.open()
		ui.set_autoupdate(TRUE)

/datum/action/leech/host_status/ui_state(mob/user)
	return GLOB.always_state

/datum/action/leech/host_status/ui_static_data(mob/user)
	var/list/data = list()
	var/list/chem_list = list()
	for(var/key in GLOB.leech_injectable_chems)
		var/list/entry = GLOB.leech_injectable_chems[key]
		chem_list += list(list(
			"id" = key,
			"category" = entry["category"],
			"goal" = entry["goal"],
			"label" = entry["label"],
			"flavor" = entry["flavor"],
			"description" = entry["description"],
			"warning" = entry["warning"],
		))
	data["chems"] = chem_list
	return data

/datum/action/leech/host_status/ui_data(mob/user)
	var/list/data = list()
	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()

	// Always include leech state so the inject panel can render even if host is gone.
	data["substrate"] = leech ? leech.substrate : 0
	data["max_substrate"] = leech.max_substrate

	if(!host)
		data["host_present"] = FALSE
		return data

	data["host_present"] = TRUE
	data["host_name"] = host.name
	data["host_stat"] = host.stat
	data["host_dead"] = host.stat == DEAD
	data["host_health"] = round(host.health, 0.1)
	data["host_max_health"] = host.maxHealth

	// === Core damage values (the "important" panel) ===
	data["brute_loss"] = round(host.getBruteLoss(), 0.1)
	data["fire_loss"] = round(host.getFireLoss(), 0.1)
	data["tox_loss"] = round(host.getToxLoss(), 0.1)
	data["oxy_loss"] = round(host.getOxyLoss(), 0.1)
	data["clone_loss"] = round(host.getCloneLoss(), 0.1)
	data["stamina_loss"] = round(host.getStaminaLoss(), 0.1)

	// Brain
	var/obj/item/organ/brain/brain = host.get_organ_slot(ORGAN_SLOT_BRAIN)
	if(brain)
		data["brain_present"] = TRUE
		data["brain_damage"] = round(brain.damage, 0.1)
		data["brain_max"] = brain.maxHealth
	else
		data["brain_present"] = FALSE

	// Body temp / blood / bleeding
	data["body_temperature"] = round(host.bodytemperature - T0C, 0.1)
	data["blood_volume"] = round(host.blood_volume, 0.1)
	data["blood_normal"] = BLOOD_VOLUME_NORMAL
	data["bleeding"] = host.is_bleeding()
	data["bleed_rate"] = round(host.get_bleed_rate(), 0.1)

	// Husk / cardiac
	data["husked"] = HAS_TRAIT(host, TRAIT_HUSK)
	var/obj/item/organ/heart/heart = host.get_organ_slot(ORGAN_SLOT_HEART)
	data["cardiac_arrest"] = (heart && !heart.beating) ? TRUE : FALSE

	// === Reagents in bloodstream (sorted by volume desc so UI can show top 3) ===
	var/list/reagent_list = list()
	if(host.reagents)
		for(var/datum/reagent/reagent in host.reagents.reagent_list)
			reagent_list += list(list(
				"name" = reagent.name,
				"volume" = round(reagent.volume, 0.01),
				"overdosed" = reagent.overdosed ? TRUE : FALSE,
			))
	if(length(reagent_list) > 1)
		// Selection sort: tiny list, perfectly fine.
		for(var/i in 1 to length(reagent_list) - 1)
			var/max_idx = i
			for(var/j in (i + 1) to length(reagent_list))
				if(reagent_list[j]["volume"] > reagent_list[max_idx]["volume"])
					max_idx = j
			if(max_idx != i)
				var/tmp = reagent_list[i]
				reagent_list[i] = reagent_list[max_idx]
				reagent_list[max_idx] = tmp
	data["reagents"] = reagent_list

	// === Limbs ===
	var/list/limb_list = list()
	for(var/obj/item/bodypart/limb as anything in host.bodyparts)
		var/list/embed_list = list()
		for(var/obj/item/embed as anything in limb.embedded_objects)
			embed_list += embed.name
		limb_list += list(list(
			"name" = capitalize(limb.plaintext_zone || limb.name),
			"brute" = round(limb.brute_dam, 0.1),
			"burn" = round(limb.burn_dam, 0.1),
			"max" = limb.max_damage,
			"robotic" = (limb.bodytype & BODYTYPE_ROBOTIC) ? TRUE : FALSE,
			"embedded" = embed_list,
		))
	data["limbs"] = limb_list

	// === Organs ===
	var/list/organ_list = list()
	for(var/obj/item/organ/organ as anything in host.internal_organs)
		var/status = "Healthy"
		if(organ.damage >= organ.maxHealth)
			status = "FAILING"
		else if(organ.damage >= organ.high_threshold)
			status = "Severely Damaged"
		else if(organ.damage >= organ.low_threshold)
			status = "Bruised"
		organ_list += list(list(
			"name" = organ.name,
			"damage" = round(organ.damage, 0.1),
			"max" = organ.maxHealth,
			"status" = status,
			"robotic" = IS_ROBOTIC_ORGAN(organ) ? TRUE : FALSE,
		))
	data["organs"] = organ_list

	// === Brain traumas ===
	var/list/trauma_list = list()
	for(var/datum/brain_trauma/trauma in host.get_traumas())
		var/severity = "minor"
		switch(trauma.resilience)
			if(TRAUMA_RESILIENCE_SURGERY)
				severity = "severe"
			if(TRAUMA_RESILIENCE_LOBOTOMY)
				severity = "deep-rooted"
			if(TRAUMA_RESILIENCE_MAGIC, TRAUMA_RESILIENCE_ABSOLUTE)
				severity = "permanent"
		trauma_list += list(list(
			"description" = trauma.scan_desc,
			"severity" = severity,
		))
	data["traumas"] = trauma_list

	// === Diseases ===
	var/list/disease_list = list()
	for(var/datum/disease/disease as anything in host.diseases)
		if(disease.visibility_flags & HIDDEN_SCANNER)
			continue
		disease_list += list(list(
			"name" = disease.name,
			"stage" = disease.stage,
			"max_stage" = disease.max_stages,
			"cure" = disease.cure_text,
		))
	data["diseases"] = disease_list

	return data

/datum/action/leech/host_status/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(.)
		return

	var/mob/living/basic/synapse_leech/leech = get_leech()
	var/mob/living/carbon/host = get_host()
	if(!leech)
		return TRUE

	switch(action)
		if("inject")
			if(!host)
				leech.balloon_alert(leech, "no host!")
				return TRUE
			if(!host.reagents)
				leech.balloon_alert(leech, "host has no bloodstream!")
				return TRUE
			var/chem_id = params["id"]
			var/amount = text2num(params["amount"])
			if(!chem_id || isnull(amount))
				return TRUE
			amount = clamp(round(amount, 1), 1, 50)
			var/list/entry = GLOB.leech_injectable_chems[chem_id]
			if(!entry)
				return TRUE
			// Substrate gates injection: 1 substrate = 1 unit.
			var/affordable = min(amount, leech.substrate)
			if(affordable <= 0)
				leech.balloon_alert(leech, "no substrate!")
				return TRUE
			var/datum/reagent/typepath = entry["typepath"]
			host.reagents.add_reagent(typepath, affordable)
			leech.adjust_substrate(-affordable)
			to_chat(leech, span_notice("You secrete [affordable]u of [entry["flavor"]] into your host's bloodstream."))
			return TRUE
