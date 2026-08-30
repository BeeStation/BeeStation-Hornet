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

/datum/action/innate/borer_infest
	name = "Infest Host"
	desc = "Burrow into an adjacent human and form a cortical cyst in a chosen bodypart."
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	button_icon_state = "sting_extract"
	background_icon_state = "bg_changeling"

/datum/action/innate/borer_infest/on_activate()
	var/mob/living/simple_animal/borer/borer = owner
	borer?.choose_infestation_target()

/datum/action/innate/borer_core
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	background_icon_state = "bg_changeling"
	var/mob/living/simple_animal/borer/borer

/datum/action/innate/borer_core/New(mob/living/simple_animal/borer/new_borer)
	. = ..()
	borer = new_borer

/datum/action/innate/borer_core/Destroy()
	borer = null
	return ..()

/datum/action/innate/borer_secrete
	parent_type = /datum/action/innate/borer_core
	name = "Secrete Chemicals"
	desc = "Release a synthesized chemical into your host's bloodstream."
	button_icon_state = "panacea"

/datum/action/innate/borer_secrete/on_activate()
	borer?.secrete_chemicals()

/datum/action/innate/borer_leave
	parent_type = /datum/action/innate/borer_core
	name = "Leave Host"
	desc = "Emerge from your host or the severed limb carrying you."
	button_icon_state = "lesser_form"

/datum/action/innate/borer_leave/on_activate()
	borer?.leave_host()

/datum/action/innate/borer_reproduce
	parent_type = /datum/action/innate/borer_core
	name = "Reproduce"
	desc = "Consume a full chemical reserve to produce a borer egg."
	button_icon_state = "spread_infestation"

/datum/action/innate/borer_reproduce/on_activate()
	borer?.reproduce()

/datum/action/innate/borer_assume_control
	parent_type = /datum/action/innate/borer_core
	name = "Assume Host Control"
	desc = "Seize control of the nervous system of your head host."
	button_icon_state = "mindshield"

/datum/action/innate/borer_assume_control/on_activate()
	borer?.assume_host_control()

/datum/action/innate/borer_release_control
	parent_type = /datum/action/innate/borer_core
	name = "Release Host Control"
	desc = "Return control of the body to your host."
	button_icon_state = "human_form"

/datum/action/innate/borer_release_control/on_activate()
	borer?.release_host_control()

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

/datum/borer_evolution/proc/on_host_death(mob/living/simple_animal/borer/borer)
	return

/// Active evolutions override this to grant or remove their action whenever
/// the borer changes host state or body zone.
/datum/borer_evolution/proc/update_action_visibility(mob/living/simple_animal/borer/borer)
	return

/// Base for purchased, one-shot borer abilities. The action datum owns the
/// visible cooldown while this datum owns availability and the actual effect.
/datum/borer_evolution/active_ability
	var/button_icon_state = "sting"
	var/ability_cooldown = 0
	var/requires_target = FALSE
	var/target_prompt
	var/datum/action/innate/borer_evolution_ability/ability_action

/datum/borer_evolution/active_ability/Destroy()
	QDEL_NULL(ability_action)
	return ..()

/datum/borer_evolution/active_ability/proc/ensure_action()
	if(!ability_action)
		ability_action = new(src)

/datum/borer_evolution/active_ability/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ensure_action()

/datum/borer_evolution/active_ability/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	if(ability_action?.owner)
		ability_action.Remove(ability_action.owner)

/datum/borer_evolution/active_ability/update_action_visibility(mob/living/simple_animal/borer/borer)
	if(ability_action?.owner)
		ability_action.Remove(ability_action.owner)
	if(!purchased || borer.controlling_host || !borer.host || borer.host.stat == DEAD || !is_active(borer))
		return
	ensure_action()
	ability_action.Grant(borer)

/datum/borer_evolution/active_ability/proc/use_ability(mob/living/simple_animal/borer/borer, atom/target)
	return FALSE

/datum/action/innate/borer_evolution_ability
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	background_icon_state = "bg_changeling"
	check_flags = AB_CHECK_CONSCIOUS
	var/datum/borer_evolution/active_ability/evolution

/datum/action/innate/borer_evolution_ability/New(datum/borer_evolution/active_ability/new_evolution)
	. = ..(new_evolution)
	evolution = new_evolution
	name = evolution.name
	desc = evolution.helptext || evolution.desc
	button_icon_state = evolution.button_icon_state
	cooldown_time = evolution.ability_cooldown
	requires_target = evolution.requires_target
	if(requires_target && evolution.target_prompt)
		enable_text = evolution.target_prompt

/datum/action/innate/borer_evolution_ability/Destroy()
	evolution = null
	return ..()

/datum/action/innate/borer_evolution_ability/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/borer/borer = owner
	if(!evolution?.use_ability(borer, target))
		return FALSE
	// Targeted actions are cooled down by the click-intercept machinery after
	// a successful return. Ordinary buttons must start their own cooldown.
	if(!requires_target && cooldown_time)
		start_cooldown()
	return TRUE

/// Base for continuous toggle abilities with a chemical drain.
/datum/borer_evolution/toggle_ability
	var/button_icon_state = "sting"
	var/activation_cost = 0
	var/chemical_drain = 0
	var/active = FALSE
	var/mob/living/simple_animal/borer/active_borer
	var/mob/living/carbon/human/active_host
	var/datum/action/innate/borer_toggle_evolution/toggle_action

/datum/borer_evolution/toggle_ability/Destroy()
	force_deactivate()
	QDEL_NULL(toggle_action)
	return ..()

/datum/borer_evolution/toggle_ability/proc/ensure_action()
	if(!toggle_action)
		toggle_action = new(src)

/datum/borer_evolution/toggle_ability/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	ensure_action()

/datum/borer_evolution/toggle_ability/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	force_deactivate()
	if(toggle_action?.owner)
		toggle_action.Remove(toggle_action.owner)

/datum/borer_evolution/toggle_ability/on_host_death(mob/living/simple_animal/borer/borer)
	force_deactivate()

/datum/borer_evolution/toggle_ability/update_action_visibility(mob/living/simple_animal/borer/borer)
	var/valid_state = purchased && !borer.controlling_host && borer.host && borer.host.stat != DEAD && is_active(borer)
	if(!valid_state)
		force_deactivate()
	if(toggle_action?.owner)
		toggle_action.Remove(toggle_action.owner)
	if(!valid_state)
		return
	ensure_action()
	toggle_action.Grant(borer)

/datum/borer_evolution/toggle_ability/on_life(mob/living/simple_animal/borer/borer, delta_time)
	if(!active || !chemical_drain)
		return
	var/drain_amount = chemical_drain * delta_time
	if(borer.chemicals < drain_amount)
		borer.chemicals = 0
		to_chat(borer, span_warning("You can no longer sustain [name]."))
		force_deactivate()
		return
	borer.chemicals -= drain_amount

/datum/borer_evolution/toggle_ability/proc/activate_ability(mob/living/simple_animal/borer/borer)
	if(active || !borer?.host || borer.host.stat == DEAD || !is_active(borer))
		return FALSE
	if(borer.chemicals < activation_cost)
		to_chat(borer, span_warning("You need [activation_cost] chemicals to activate [name]."))
		return FALSE
	active_borer = borer
	active_host = borer.host
	if(!activate_effect())
		active_borer = null
		active_host = null
		return FALSE
	borer.chemicals -= activation_cost
	active = TRUE
	return TRUE

/datum/borer_evolution/toggle_ability/proc/deactivate_ability()
	if(!active)
		return FALSE
	deactivate_effect()
	active = FALSE
	active_borer = null
	active_host = null
	return TRUE

/datum/borer_evolution/toggle_ability/proc/force_deactivate()
	if(!active)
		return
	if(toggle_action?.owner)
		toggle_action.deactivate(toggle_action.owner)
	if(active)
		deactivate_ability()

/datum/borer_evolution/toggle_ability/proc/activate_effect()
	return TRUE

/datum/borer_evolution/toggle_ability/proc/deactivate_effect()
	return

/datum/action/innate/borer_toggle_evolution
	button_icon = 'icons/hud/actions/actions_changeling.dmi'
	background_icon_state = "bg_changeling"
	check_flags = AB_CHECK_CONSCIOUS
	toggleable = TRUE
	var/datum/borer_evolution/toggle_ability/evolution
	var/inactive_name

/datum/action/innate/borer_toggle_evolution/New(datum/borer_evolution/toggle_ability/new_evolution)
	. = ..(new_evolution)
	evolution = new_evolution
	name = evolution.name
	inactive_name = evolution.name
	desc = evolution.helptext || evolution.desc
	button_icon_state = evolution.button_icon_state

/datum/action/innate/borer_toggle_evolution/Destroy()
	evolution = null
	return ..()

/datum/action/innate/borer_toggle_evolution/on_activate(mob/user, atom/target)
	var/mob/living/simple_animal/borer/borer = owner
	if(!evolution?.activate_ability(borer))
		deactivate(user)
		return FALSE
	name = "Deactivate [inactive_name]"
	update_buttons()
	return TRUE

/datum/action/innate/borer_toggle_evolution/on_deactivate(mob/user, atom/target)
	evolution?.deactivate_ability()
	name = inactive_name
	update_buttons()
	return TRUE

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
	cooldown_time = 60 SECONDS
	var/datum/borer_evolution/chest/metabolic_purge/evolution

/datum/action/innate/borer_metabolic_purge/New(datum/borer_evolution/chest/metabolic_purge/new_evolution)
	. = ..()
	evolution = new_evolution

/datum/action/innate/borer_metabolic_purge/Destroy()
	evolution = null
	return ..()

/datum/action/innate/borer_metabolic_purge/on_activate()
	if(evolution?.purge(owner))
		start_cooldown()

/datum/borer_evolution/chest/metabolic_purge
	name = "Metabolic Purge"
	desc = "Develop a filtering organ that can flush all chemicals from a host's bloodstream."
	helptext = "Chest cyst only. Costs 30 chemicals and has a 60-second cooldown. Removes helpful reagents too."
	cost = 2
	required_zone = BODY_ZONE_CHEST
	var/datum/action/innate/borer_metabolic_purge/purge_action

/datum/borer_evolution/chest/metabolic_purge/Destroy()
	QDEL_NULL(purge_action)
	return ..()

/datum/borer_evolution/chest/metabolic_purge/on_attached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	if(!purge_action)
		purge_action = new(src)

/datum/borer_evolution/chest/metabolic_purge/on_detached(mob/living/simple_animal/borer/borer, mob/living/carbon/human/host)
	purge_action?.Remove(borer)

/datum/borer_evolution/chest/metabolic_purge/update_action_visibility(mob/living/simple_animal/borer/borer)
	if(purge_action?.owner)
		purge_action.Remove(purge_action.owner)
	if(purchased && !borer.controlling_host && borer.host && is_active(borer))
		if(!purge_action)
			purge_action = new(src)
		purge_action.Grant(borer)

/datum/borer_evolution/chest/metabolic_purge/proc/purge(mob/living/simple_animal/borer/borer)
	if(!borer?.host || borer.cyst?.zone != BODY_ZONE_CHEST || !borer.host.reagents)
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

// --------------------------------------------------------------------------
// Active evolutions

/datum/borer_evolution/taste_blood
	parent_type = /datum/borer_evolution/active_ability
	name = "Taste Blood"
	desc = "Develop sensory filaments capable of identifying chemicals in a host's bloodstream."
	helptext = "Any host zone. Reports every reagent currently present in the host."
	cost = 1
	button_icon_state = "sting_extract"

/datum/borer_evolution/taste_blood/use_ability(mob/living/simple_animal/borer/borer, atom/target)
	if(!borer?.host?.reagents)
		return FALSE
	if(!length(borer.host.reagents.reagent_list))
		to_chat(borer, span_notice("You taste no foreign chemicals in [borer.host]'s bloodstream."))
		return TRUE
	var/list/readout = list()
	for(var/datum/reagent/reagent as anything in borer.host.reagents.reagent_list)
		readout += "[reagent.name]: [round(reagent.volume, 0.1)] units"
	var/formatted_readout = readout.Join("<br>")
	to_chat(borer, span_notice("<b>Chemical profile for [borer.host]:</b><br>[formatted_readout]"))
	return TRUE

/datum/borer_evolution/chest/brute_resistance
	parent_type = /datum/borer_evolution/toggle_ability
	name = "Brute Resistance"
	desc = "Reinforce your host's tissues against physical trauma."
	helptext = "Chest cyst only. Toggle 30% brute resistance for 1 chemical per second."
	cost = 2
	required_zone = BODY_ZONE_CHEST
	button_icon_state = "chitinous_armor"
	chemical_drain = 1
	var/resistance_multiplier = 0.7

/datum/borer_evolution/chest/brute_resistance/activate_effect()
	if(!active_host?.physiology)
		return FALSE
	active_host.physiology.brute_mod *= resistance_multiplier
	to_chat(active_borer, span_notice("You harden [active_host]'s tissues against physical trauma."))
	to_chat(active_host, span_notice("Your flesh tightens into a dense protective lattice."))
	return TRUE

/datum/borer_evolution/chest/brute_resistance/deactivate_effect()
	if(active_host?.physiology)
		active_host.physiology.brute_mod /= resistance_multiplier
		to_chat(active_host, span_notice("The protective tension in your flesh subsides."))

/datum/borer_evolution/chest/burn_resistance
	parent_type = /datum/borer_evolution/toggle_ability
	name = "Burn Resistance"
	desc = "Saturate your host's tissues against heat and corrosive trauma."
	helptext = "Chest cyst only. Toggle 30% burn resistance for 1 chemical per second."
	cost = 2
	required_zone = BODY_ZONE_CHEST
	button_icon_state = "organic_suit"
	chemical_drain = 1
	var/resistance_multiplier = 0.7

/datum/borer_evolution/chest/burn_resistance/activate_effect()
	if(!active_host?.physiology)
		return FALSE
	active_host.physiology.burn_mod *= resistance_multiplier
	to_chat(active_borer, span_notice("You saturate [active_host]'s tissues against burns."))
	to_chat(active_host, span_notice("A cool, protective film spreads beneath your skin."))
	return TRUE

/datum/borer_evolution/chest/burn_resistance/deactivate_effect()
	if(active_host?.physiology)
		active_host.physiology.burn_mod /= resistance_multiplier
		to_chat(active_host, span_notice("The protective film beneath your skin recedes."))

/datum/borer_evolution/toggle_ability/arm_manifestation
	required_zone = BODY_ZONE_L_ARM
	required_zone_label = "Either arm"
	activation_cost = 10
	chemical_drain = 1
	var/obj/item/manifested_item
	var/manifest_type
	var/manifest_name = "growth"

/datum/borer_evolution/toggle_ability/arm_manifestation/can_purchase(mob/living/simple_animal/borer/borer)
	return !purchased && borer?.host && borer.evolution_points >= cost && (borer.cyst?.zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/datum/borer_evolution/toggle_ability/arm_manifestation/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/borer_evolution/toggle_ability/arm_manifestation/activate_effect()
	var/obj/item/bodypart/infested_arm = active_host?.get_bodypart(active_borer.cyst?.zone)
	if(!infested_arm || infested_arm.bodypart_disabled || !infested_arm.held_index)
		to_chat(active_borer, span_warning("Your infested arm cannot support [manifest_name]."))
		return FALSE
	if(active_host.get_item_for_held_index(infested_arm.held_index))
		to_chat(active_borer, span_warning("The corresponding hand must be empty to form [manifest_name]."))
		return FALSE
	for(var/datum/borer_evolution/toggle_ability/arm_manifestation/other as anything in active_borer.available_evolutions)
		if(other != src && other.active)
			to_chat(active_borer, span_warning("You must retract [other.name] before forming [name]."))
			return FALSE
	manifested_item = new manifest_type(active_host)
	// We have already validated the exact arm, its hand, and that hand's contents.
	// Use forced placement so the host's pickup state cannot silently reject an
	// ABSTRACT organic weapon (for example while the host is unconscious).
	if(!active_host.put_in_hand(manifested_item, infested_arm.held_index, forced = TRUE))
		QDEL_NULL(manifested_item)
		to_chat(active_borer, span_warning("You fail to force [manifest_name] into [active_host]'s corresponding hand."))
		return FALSE
	RegisterSignal(manifested_item, COMSIG_QDELETING, PROC_REF(on_manifest_deleted))
	playsound(active_host, 'sound/effects/blobattack.ogg', 30, TRUE)
	to_chat(active_borer, span_notice("You form [manifest_name] in [active_host]'s [active_host.get_held_index_name(infested_arm.held_index)]."))
	active_host.visible_message(
		span_warning("With a sickening crunch, [manifest_name] erupts from [active_host]'s [parse_zone(active_borer.cyst.zone)]!"),
		span_userdanger("With a sickening crunch, [manifest_name] erupts from your [parse_zone(active_borer.cyst.zone)]!"),
	)
	return TRUE

/datum/borer_evolution/toggle_ability/arm_manifestation/deactivate_effect()
	if(manifested_item && !QDELETED(manifested_item))
		UnregisterSignal(manifested_item, COMSIG_QDELETING)
		qdel(manifested_item)
	manifested_item = null
	if(active_host && !QDELETED(active_host))
		active_host.visible_message(span_notice("[active_host]'s [manifest_name] crumbles into fragments of dead bone."), span_notice("Your [manifest_name] crumbles away."))

/datum/borer_evolution/toggle_ability/arm_manifestation/proc/on_manifest_deleted(datum/source)
	SIGNAL_HANDLER
	manifested_item = null
	force_deactivate()

/datum/borer_evolution/arm/bone_blade
	parent_type = /datum/borer_evolution/toggle_ability/arm_manifestation
	name = "Bone Blade"
	desc = "Grow a large organic blade from the arm containing you."
	helptext = "Either arm. Costs 10 chemicals to form and 1 per second to sustain. Requires that arm's hand to be empty."
	cost = 2
	button_icon_state = "armblade"
	manifest_type = /obj/item/melee/borer_bone_blade
	manifest_name = "a serrated blade of bone"

/datum/borer_evolution/arm/bone_shield
	parent_type = /datum/borer_evolution/toggle_ability/arm_manifestation
	name = "Bone Shield"
	desc = "Grow an interlocking organic shield from the arm containing you."
	helptext = "Either arm. Costs 10 chemicals to form and 1 per second to sustain. Mutually exclusive with Bone Blade."
	cost = 2
	button_icon_state = "organic_suit"
	manifest_type = /obj/item/shield/borer_bone
	manifest_name = "an interlocking shield of bone"

/obj/item/melee/borer_bone_blade
	name = "borer bone blade"
	desc = "A vicious blade of living bone extruded from its wielder's arm."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	item_flags = NEEDS_PERMIT | ABSTRACT | DROPDEL | ISWEAPON
	w_class = WEIGHT_CLASS_HUGE
	force = 24
	throwforce = 0
	throw_range = 0
	throw_speed = 0
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("slashes", "stabs", "tears", "lacerates")
	attack_verb_simple = list("slash", "stab", "tear", "lacerate")
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_DEEP_WOUND

/obj/item/melee/borer_bone_blade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/obj/item/shield/borer_bone
	name = "borer bone shield"
	desc = "Interlocking plates of living bone grown around an arm."
	icon_state = "buckler"
	inhand_icon_state = "buckler"
	lefthand_file = 'icons/mob/inhands/equipment/shields_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/shields_righthand.dmi'
	item_flags = ABSTRACT | DROPDEL | ISWEAPON
	custom_materials = null
	block_power = 35
	max_integrity = 140
	shield_break_sound = 'sound/effects/splat.ogg'

/obj/item/shield/borer_bone/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, INNATE_TRAIT)

/datum/borer_evolution/arm/electromagnetic_pulse
	parent_type = /datum/borer_evolution/active_ability
	name = "Electromagnetic Pulse"
	desc = "Discharge stored bioelectricity through your host and nearby electronics."
	helptext = "Either arm. Costs 25 chemicals. Produces the same EMP radius as a changeling's Dissonant Shriek."
	cost = 2
	required_zone = BODY_ZONE_L_ARM
	required_zone_label = "Either arm"
	button_icon_state = "dissonant_shriek"
	ability_cooldown = 30 SECONDS

/datum/borer_evolution/arm/electromagnetic_pulse/can_purchase(mob/living/simple_animal/borer/borer)
	return !purchased && borer?.host && borer.evolution_points >= cost && (borer.cyst?.zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM))

/datum/borer_evolution/arm/electromagnetic_pulse/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_ARM, BODY_ZONE_R_ARM)

/datum/borer_evolution/arm/electromagnetic_pulse/use_ability(mob/living/simple_animal/borer/borer, atom/target)
	if(!borer?.host || borer.chemicals < 25)
		to_chat(borer, span_warning("You need 25 chemicals to produce an electromagnetic pulse."))
		return FALSE
	borer.chemicals -= 25
	borer.host.visible_message(span_warning("[borer.host] convulses as a wave of electromagnetic energy erupts outward!"), span_userdanger("A violent bioelectric pulse erupts from inside you!"))
	empulse(get_turf(borer.host), 2, 3, TRUE)
	return TRUE

/datum/movespeed_modifier/borer_leg_overdrive
	variable = TRUE

/datum/borer_evolution/leg/muscular_overdrive
	parent_type = /datum/borer_evolution/toggle_ability
	name = "Muscular Overdrive"
	desc = "Drive your host's leg beyond its ordinary muscular limits."
	helptext = "Either leg. Provides an additional speed boost for 1 chemical per second."
	cost = 2
	required_zone = BODY_ZONE_L_LEG
	required_zone_label = "Either leg"
	button_icon_state = "strained_muscles"
	chemical_drain = 1

/datum/borer_evolution/leg/muscular_overdrive/can_purchase(mob/living/simple_animal/borer/borer)
	return !purchased && borer?.host && borer.evolution_points >= cost && (borer.cyst?.zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))

/datum/borer_evolution/leg/muscular_overdrive/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_evolution/leg/muscular_overdrive/activate_effect()
	active_host.add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/borer_leg_overdrive, multiplicative_slowdown = -0.25)
	to_chat(active_borer, span_notice("You drive [active_host]'s leg muscles into overdrive."))
	to_chat(active_host, span_notice("Your legs surge with unnatural power."))
	return TRUE

/datum/borer_evolution/leg/muscular_overdrive/deactivate_effect()
	active_host?.remove_movespeed_modifier(/datum/movespeed_modifier/borer_leg_overdrive)
	if(active_host && !QDELETED(active_host))
		to_chat(active_host, span_notice("The unnatural power in your legs fades."))

/datum/borer_evolution/leg/hooking_talons
	parent_type = /datum/borer_evolution/active_ability
	name = "Hooking Talons"
	desc = "Grow subtle hooks through your host's foot for sudden leg sweeps."
	helptext = "Either leg. Target an adjacent standing creature to knock it down. Costs 15 chemicals."
	cost = 2
	required_zone = BODY_ZONE_L_LEG
	required_zone_label = "Either leg"
	button_icon_state = "strained_muscles"
	ability_cooldown = 15 SECONDS
	requires_target = TRUE
	target_prompt = "<span class='notice'>Click an adjacent creature to sweep its legs.</span>"

/datum/borer_evolution/leg/hooking_talons/can_purchase(mob/living/simple_animal/borer/borer)
	return !purchased && borer?.host && borer.evolution_points >= cost && (borer.cyst?.zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG))

/datum/borer_evolution/leg/hooking_talons/is_active_in_zone(zone)
	return zone in list(BODY_ZONE_L_LEG, BODY_ZONE_R_LEG)

/datum/borer_evolution/leg/hooking_talons/use_ability(mob/living/simple_animal/borer/borer, atom/target)
	if(!borer?.host || !isliving(target) || target == borer.host || !borer.host.Adjacent(target))
		to_chat(borer, span_warning("You must target an adjacent living creature."))
		return FALSE
	var/mob/living/victim = target
	if(victim.stat == DEAD || victim.body_position == LYING_DOWN)
		to_chat(borer, span_warning("[victim] cannot be swept off [victim.p_their()] feet."))
		return FALSE
	if(borer.chemicals < 15)
		to_chat(borer, span_warning("You need 15 chemicals to perform a leg sweep."))
		return FALSE
	borer.chemicals -= 15
	borer.host.do_attack_animation(victim, ATTACK_EFFECT_KICK)
	playsound(victim, 'sound/weapons/thudswoosh.ogg', 50, TRUE)
	victim.Knockdown(3 SECONDS)
	log_combat(borer.host, victim, "leg swept using a cortical borer")
	victim.visible_message(span_warning("[borer.host] hooks [victim]'s legs and sweeps [victim.p_them()] to the floor!"), span_userdanger("[borer.host] hooks your legs and sweeps you to the floor!"))
	return TRUE
