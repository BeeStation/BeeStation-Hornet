/datum/borer_evolution_menu
	var/mob/living/simple_animal/borer/borer

/datum/borer_evolution_menu/New(mob/living/simple_animal/borer/new_borer)
	. = ..()
	borer = new_borer

/datum/borer_evolution_menu/Destroy()
	borer = null
	return ..()

/datum/borer_evolution_menu/ui_state(mob/user)
	return GLOB.always_state

/datum/borer_evolution_menu/ui_status(mob/user, datum/ui_state/state)
	return borer && user == borer ? UI_INTERACTIVE : UI_CLOSE

/datum/borer_evolution_menu/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "BorerEvolution", "Borer Evolution")
		ui.open()

/datum/borer_evolution_menu/ui_data(mob/user)
	var/list/data = list()
	data["evolution_points"] = borer.evolution_points
	data["host_zone"] = borer.cyst ? parse_zone(borer.cyst.zone) : "No host"
	var/list/evolutions = list()
	for(var/datum/borer_evolution/evolution as anything in borer.available_evolutions)
		evolutions += list(list(
			"name" = evolution.name,
			"desc" = evolution.desc,
			"path" = evolution.type,
			"helptext" = evolution.helptext,
			"cost" = evolution.cost,
			"owned" = evolution.purchased,
			"can_purchase" = evolution.can_purchase(borer),
			"zone" = evolution.required_zone_label || (evolution.required_zone ? parse_zone(evolution.required_zone) : "Any host zone"),
		))
	data["evolutions"] = evolutions
	return data

/datum/borer_evolution_menu/ui_act(action, list/params)
	if(..())
		return
	if(action != "evolve")
		return FALSE
	var/evolution_path = text2path(params["path"])
	if(!ispath(evolution_path, /datum/borer_evolution))
		return FALSE
	return borer.purchase_evolution(evolution_path)

/datum/action/innate/borer_evolution
	name = "Borer Evolution"
	desc = "Spend evolution points to adapt to your host."
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = "sting"
	background_icon_state = "bg_changeling"
	var/datum/borer_evolution_menu/menu

/datum/action/innate/borer_evolution/New(datum/borer_evolution_menu/new_menu)
	. = ..()
	menu = new_menu

/datum/action/innate/borer_evolution/Destroy()
	menu = null
	return ..()

/datum/action/innate/borer_evolution/on_activate()
	menu?.ui_interact(owner)

/datum/borer_evolution
	abstract_type = /datum/borer_evolution
	var/name = "Borer evolution"
	var/desc = ""
	var/helptext = ""
	var/cost = 1
	var/required_zone = null
	var/required_zone_label = null
	var/purchased = FALSE

/datum/borer_evolution/proc/can_purchase(mob/living/simple_animal/borer/borer)
	if(purchased || !borer?.host || borer.evolution_points < cost)
		return FALSE
	return !required_zone || borer.cyst?.zone == required_zone

/datum/borer_evolution/proc/is_active(mob/living/simple_animal/borer/borer)
	return borer.host && is_active_in_zone(borer.cyst?.zone)

/datum/borer_evolution/proc/is_active_in_zone(zone)
	return !required_zone || zone == required_zone

/datum/borer_evolution/proc/on_purchase(mob/living/simple_animal/borer/borer)
	purchased = TRUE
	if(borer.host)
		on_attached(borer, borer.host)

/datum/borer_evolution/proc/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	return

/datum/borer_evolution/proc/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	return

/datum/borer_evolution/proc/on_life(mob/living/simple_animal/borer/borer, delta_time)
	return

/// Learned secretion knowledge. The matching secretion only works while this
/// borer remains attached in the evolution's required body zone.
/datum/borer_evolution/chemical
	name = "Chemical Secretion"
	desc = "Learn to synthesize a new chemical inside a suitable host."
	helptext = "Unlocks one secretion while the cyst is in the required body zone."

/datum/borer_evolution/chemical/head
	required_zone = BODY_ZONE_HEAD

/datum/borer_evolution/chemical/chest
	required_zone = BODY_ZONE_CHEST

/datum/borer_evolution/chemical/head/genetic_restoration
	name = "Genetic Restoration"
	desc = "Learn to secrete Mutadone and Rezadone for genetic restoration."
	helptext = "Unlocks Mutadone and Rezadone. Head cyst only."

/datum/borer_evolution/chemical/head/neurochemical_control
	name = "Neurochemical Control"
	desc = "Learn to manipulate a host's nervous system with sedatives and stimulants."
	helptext = "Unlocks Morphine, Space Drugs, and Synaptizine. Head cyst only."

/datum/borer_evolution/chemical/chest/respiratory_radiation_care
	name = "Respiratory & Radiation Care"
	desc = "Learn to secrete advanced oxygen treatment and radiation protection."
	helptext = "Unlocks Dexalin Plus and Potassium Iodide. Chest cyst only."

/datum/borer_evolution/chemical/chest/metabolic_disruption
	name = "Metabolic Disruption"
	desc = "Learn to alter a host's temperature and metabolism with disruptive chemicals."
	helptext = "Unlocks Capsaicin Oil, Frostoil, and Lipolicide. Chest cyst only."

/datum/borer_evolution/chemical/chest/advanced_critical_care
	name = "Advanced Critical Care"
	desc = "Develop powerful emergency chemistry for a host on the edge of death."
	helptext = "Unlocks Omnizine, Stabilizing Nanites, and Atropine. Chest cyst only."
	cost = 2

/datum/borer_evolution/neural_domination
	name = "Neural Domination"
	desc = "Develop control filaments capable of briefly taking over a host's body."
	helptext = "Unlocks voluntary host takeover. Head cyst only."
	cost = 2
	required_zone = BODY_ZONE_HEAD

/datum/borer_evolution/head/night_vision
	name = "Night Vision"
	desc = "Reshape your host's eyes for clear sight in darkness."
	helptext = "Head cyst only. Grants Nightmare-grade dark sight."
	required_zone = BODY_ZONE_HEAD

/datum/borer_evolution/head/night_vision/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_NIGHT_VISION, REF(src))
	host.update_sight()

/datum/borer_evolution/head/night_vision/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_NIGHT_VISION, REF(src))
	host.update_sight()

/datum/borer_evolution/head/thermal_vision
	name = "Thermal Vision"
	desc = "Grow heat-sensitive structures around your host's optic nerves."
	helptext = "Head cyst only. Reveals living heat signatures, including in darkness."
	cost = 3
	required_zone = BODY_ZONE_HEAD

/datum/borer_evolution/head/thermal_vision/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_THERMAL_VISION, REF(src))
	host.update_sight()

/datum/borer_evolution/head/thermal_vision/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_THERMAL_VISION, REF(src))
	host.update_sight()

/datum/borer_evolution/chest/thermal_regulation
	name = "Thermal Regulation"
	desc = "Stabilise your host against environmental extremes."
	helptext = "Grants cold and heat resistance while the chest cyst is attached."
	required_zone = BODY_ZONE_CHEST

/datum/borer_evolution/chest/thermal_regulation/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_RESISTCOLD, REF(src))
	ADD_TRAIT(host, TRAIT_RESISTHEAT, REF(src))

/datum/borer_evolution/chest/thermal_regulation/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_RESISTCOLD, REF(src))
	REMOVE_TRAIT(host, TRAIT_RESISTHEAT, REF(src))

/datum/action/innate/borer_metabolic_purge
	name = "Metabolic Purge"
	desc = "Purge every reagent from your host's bloodstream."
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = "sting"
	background_icon_state = "bg_changeling"
	var/datum/borer_evolution/chest/metabolic_purge/evolution

/datum/action/innate/borer_metabolic_purge/New(datum/borer_evolution/chest/metabolic_purge/new_evolution)
	. = ..()
	evolution = new_evolution

/datum/action/innate/borer_metabolic_purge/Destroy()
	evolution = null
	return ..()

/datum/action/innate/borer_metabolic_purge/on_activate()
	evolution?.purge(owner)

/datum/borer_evolution/chest/metabolic_purge
	name = "Metabolic Purge"
	desc = "Develop a filtering organ that can flush all chemicals from a host's bloodstream."
	helptext = "Chest cyst only. Costs 30 chemicals and has a 60-second cooldown. Removes helpful reagents too."
	cost = 2
	required_zone = BODY_ZONE_CHEST
	COOLDOWN_DECLARE(purge_cooldown)
	var/datum/action/innate/borer_metabolic_purge/purge_action

/datum/borer_evolution/chest/metabolic_purge/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	if(!purge_action)
		purge_action = new(src)
	purge_action.Grant(borer)

/datum/borer_evolution/chest/metabolic_purge/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	purge_action?.Remove(borer)

/datum/borer_evolution/chest/metabolic_purge/proc/purge(mob/living/simple_animal/borer/borer)
	if(!borer?.host || borer.cyst?.zone != BODY_ZONE_CHEST || !borer.host.reagents)
		return FALSE
	if(!COOLDOWN_FINISHED(src, purge_cooldown))
		to_chat(borer, span_warning("Your filtering organ is still recovering."))
		return FALSE
	if(borer.chemicals < 30)
		to_chat(borer, span_warning("You need 30 chemicals to purge your host."))
		return FALSE
	if(!borer.host.reagents.total_volume)
		to_chat(borer, span_notice("Your host has no reagents to purge."))
		return FALSE
	var/removed_volume = borer.host.reagents.total_volume
	borer.host.reagents.clear_reagents()
	borer.chemicals -= 30
	COOLDOWN_START(src, purge_cooldown, 60 SECONDS)
	to_chat(borer, span_notice("You purge [round(removed_volume, 0.1)] units of reagents from [borer.host]'s bloodstream."))
	to_chat(borer.host, span_warning("A sudden internal flush clears every chemical from your bloodstream!"))
	return TRUE

/datum/borer_evolution/arm/shock_dampening
	name = "Shock Dampening"
	desc = "Thread insulating tissue through a host's arm."
	helptext = "Grants shock immunity while an arm cyst is attached."
	cost = 1
	required_zone = BODY_ZONE_L_ARM
	required_zone_label = "Either arm"

/datum/borer_evolution/arm/shock_dampening/can_purchase(mob/living/simple_animal/borer/borer)
	if(..())
		return TRUE
	return !purchased && borer?.host && borer.evolution_points >= cost && borer.cyst?.zone == BODY_ZONE_R_ARM

/datum/borer_evolution/arm/shock_dampening/is_active(mob/living/simple_animal/borer/borer)
	return borer.host && is_active_in_zone(borer.cyst?.zone)

/datum/borer_evolution/arm/shock_dampening/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/borer_evolution/arm/shock_dampening/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_SHOCKIMMUNE, REF(src))

/datum/borer_evolution/arm/shock_dampening/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_SHOCKIMMUNE, REF(src))

/datum/borer_evolution/arm/regenerative_tissue
	name = "Regenerative Tissue"
	desc = "Rework your host's immune response for gradual wound repair."
	helptext = "Either arm cyst. Slowly heals organic brute and burn damage while attached."
	cost = 2
	required_zone = BODY_ZONE_L_ARM
	required_zone_label = "Either arm"

/datum/borer_evolution/arm/regenerative_tissue/can_purchase(mob/living/simple_animal/borer/borer)
	if(..())
		return TRUE
	return !purchased && borer?.host && borer.evolution_points >= cost && borer.cyst?.zone == BODY_ZONE_R_ARM

/datum/borer_evolution/arm/regenerative_tissue/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/borer_evolution/arm/regenerative_tissue/on_life(mob/living/simple_animal/borer/borer, delta_time)
	if(!borer.host || borer.host.stat == DEAD)
		return
	borer.host.adjustBruteLoss(-0.2 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	borer.host.adjustFireLoss(-0.1 * delta_time, updating_health = FALSE, required_bodytype = BODYTYPE_ORGANIC)
	borer.host.updatehealth()

/datum/movespeed_modifier/borer_leg_fibers
	variable = TRUE

/datum/borer_evolution/leg/motile_fibers
	name = "Motile Fibers"
	desc = "Reinforce a host's leg with fast-reacting muscle fibers."
	helptext = "Makes the host move faster while a leg cyst is attached."
	cost = 1
	required_zone = BODY_ZONE_L_LEG
	required_zone_label = "Either leg"

/datum/borer_evolution/leg/motile_fibers/can_purchase(mob/living/simple_animal/borer/borer)
	if(..())
		return TRUE
	return !purchased && borer?.host && borer.evolution_points >= cost && borer.cyst?.zone == BODY_ZONE_R_LEG

/datum/borer_evolution/leg/motile_fibers/is_active(mob/living/simple_animal/borer/borer)
	return borer.host && is_active_in_zone(borer.cyst?.zone)

/datum/borer_evolution/leg/motile_fibers/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_evolution/leg/motile_fibers/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	host.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/borer_leg_fibers, multiplicative_slowdown = -0.15)

/datum/borer_evolution/leg/motile_fibers/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	host.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_fibers)

/datum/borer_evolution/leg/grounding_tendrils
	name = "Grounding Tendrils"
	desc = "Anchor a host's footing with fine connective tendrils."
	helptext = "Prevents slipping while a leg cyst is attached."
	required_zone = BODY_ZONE_L_LEG
	required_zone_label = "Either leg"

/datum/borer_evolution/leg/grounding_tendrils/can_purchase(mob/living/simple_animal/borer/borer)
	if(..())
		return TRUE
	return !purchased && borer?.host && borer.evolution_points >= cost && borer.cyst?.zone == BODY_ZONE_R_LEG

/datum/borer_evolution/leg/grounding_tendrils/is_active(mob/living/simple_animal/borer/borer)
	return borer.host && is_active_in_zone(borer.cyst?.zone)

/datum/borer_evolution/leg/grounding_tendrils/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_evolution/leg/grounding_tendrils/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_NO_SLIP_ALL, REF(src))

/datum/borer_evolution/leg/grounding_tendrils/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_NO_SLIP_ALL, REF(src))

/datum/borer_evolution/leg/zero_g_tendons
	name = "Zero-G Tendons"
	desc = "Anchor your host's footing with tendon-level magnetic control."
	helptext = "Either leg cyst. Lets the host move normally in zero gravity, like active magboots."
	cost = 2
	required_zone = BODY_ZONE_L_LEG
	required_zone_label = "Either leg"

/datum/borer_evolution/leg/zero_g_tendons/can_purchase(mob/living/simple_animal/borer/borer)
	if(..())
		return TRUE
	return !purchased && borer?.host && borer.evolution_points >= cost && borer.cyst?.zone == BODY_ZONE_R_LEG

/datum/borer_evolution/leg/zero_g_tendons/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_evolution/leg/zero_g_tendons/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ADD_TRAIT(host, TRAIT_NEGATES_GRAVITY, REF(src))

/datum/borer_evolution/leg/zero_g_tendons/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	REMOVE_TRAIT(host, TRAIT_NEGATES_GRAVITY, REF(src))

/datum/borer_evolution/expanded_glands
	name = "Expanded Glands"
	desc = "Grow additional reservoirs for chemical secretion."
	helptext = "Increases maximum chemicals by 50."
	cost = 1

/datum/borer_evolution/expanded_glands/on_purchase(mob/living/simple_animal/borer/borer)
	..()
	borer.max_chemicals += 50

/datum/borer_evolution/efficient_glands
	name = "Efficient Glands"
	desc = "Optimise the conversion of host nutrients into secretion reserves."
	helptext = "Increases hosted chemical regeneration by 1 per second."
	cost = 1

/datum/borer_evolution/efficient_glands/on_purchase(mob/living/simple_animal/borer/borer)
	..()
	borer.chemical_regen_bonus += 1
