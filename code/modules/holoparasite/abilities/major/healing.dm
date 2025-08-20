/datum/holoparasite_ability/major/healing
	name = "Healing"
	desc = "Allows the $theme to heal anything, living or inanimate, by touch."
	ui_icon = "medkit"
	cost = 3
	thresholds = list(
		list(
			"stat" = "Potential",
			"desc" = "Increases the amount of damage that is healed with each hit."
		),
		list(
			"stat" = "Defense",
			"minimum" = 3,
			"desc" = "Purges small amounts of toxic and overdosed reagents with each hit."
		),
		list(
			"stat" = "Potential",
			"minimum" = 3,
			"desc" = "Reduces the duration of temporary ailments such as blindness, blurry vision, deafness, disgust, dizziness, confusion, and hallucinations with each hit."
		),
		list(
			"stat" = "Potential",
			"minimum" = 5,
			"desc" = "Heals cellular damage with each hit, albeit at a lesser rate than normal damage."
		)
	)
	traits = list(TRAIT_MEDICAL_HUD)
	/// Heal clone damage when healing mobs.
	var/heal_clone = TRUE
	/// Heal temporary debuffs when healing mobs.
	var/heal_debuffs = TRUE
	/// Purge toxins when healing mobs.
	var/purge_toxins = TRUE
	/// The amount of damage to heal with each hit.
	var/heal_amt = 0
	/// The amount of effect time to reduce with each hit.
	var/effect_heal_amt = 0
	/// The amount of toxins to purge with each hit.
	var/purge_amt = 0

/datum/holoparasite_ability/major/healing/apply()
	..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(owner)
	heal_clone = (master_stats.potential >= 5)
	heal_debuffs = (master_stats.potential >= 3)
	purge_toxins = (master_stats.defense >= 3)
	heal_amt = CEILING(max(master_stats.potential * 0.8, 2) + 3, 0.5)
	effect_heal_amt = CEILING(max(master_stats.potential * 0.85, 1), 1)
	purge_amt = CEILING((master_stats.potential + master_stats.defense) * 0.55 * REAGENTS_EFFECT_MULTIPLIER, 0.5)

/datum/holoparasite_ability/major/healing/remove()
	..()
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.remove_hud_from(owner)

/datum/holoparasite_ability/major/healing/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_SETUP_HUD, PROC_REF(on_hud_setup))
	RegisterSignal(owner, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_attack))

/datum/holoparasite_ability/major/healing/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_SETUP_HUD, COMSIG_HOSTILE_PRE_ATTACKINGTARGET))

/datum/holoparasite_ability/major/healing/proc/on_hud_setup(datum/_source, datum/hud/holoparasite/hud, list/huds_to_add)
	SIGNAL_HANDLER
	// too lazy to make this code better, this still works. dextrous can use more intents, so our 2-intent hud is just worse.
	if(istype(owner.stats.weapon, /datum/holoparasite_ability/weapon/dextrous))
		return
	hud.action_intent = new /atom/movable/screen/combattoggle/flashy()
	hud.action_intent.icon = hud.ui_style
	hud.action_intent.icon_state = owner.combat_mode
	huds_to_add += hud.action_intent

/**
 * Handles healing a target whenever attacking them.
 */
/datum/holoparasite_ability/major/healing/proc/on_attack(datum/_source, atom/target)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY
	if(!owner.combat_mode)
		if(owner.has_matching_summoner(target, include_summoner = FALSE))
			to_chat(owner, span_dangerbold("You can't heal yourself!"))
			owner.balloon_alert(owner, "cannot heal self", show_in_chat = FALSE)
			return
		if(heal(target))
			owner.changeNext_move(CLICK_CD_MELEE)
			owner.do_attack_animation(target)
			spawn_heal_effect(target)
			playsound(owner, 'sound/magic/staff_healing.ogg', vol = 25, vary = TRUE, frequency = 2.5)
		return COMPONENT_HOSTILE_NO_ATTACK

/**
 * Checks to see if the target is healable, and heals it if it is.
 * Returns TRUE if the target was healable, FALSE otherwise.
 */
/datum/holoparasite_ability/major/healing/proc/heal(atom/movable/target)
	if(!istype(target))
		return FALSE
	if(isliving(target))
		heal_living(target)
		return TRUE
	else if(isobj(target))
		heal_obj(target)
		return TRUE
	return FALSE

/**
 * Heals a living mob.
 */
/datum/holoparasite_ability/major/healing/proc/heal_living(mob/living/target)
	var/actual_heal_amt = heal_amt
	var/actual_effect_heal_amt = effect_heal_amt
	var/actual_purge_amt = purge_amt
	if(!owner.is_manifested())
		actual_heal_amt = CEILING(max(heal_amt * 0.5, 2), 0.5)
		actual_effect_heal_amt = CEILING(max(effect_heal_amt * 0.45, 1), 1)
		actual_purge_amt = CEILING(max(purge_amt * 0.5, 1), 0.5)
	else if(target.stat && !owner.has_matching_summoner(target))
		actual_heal_amt = CEILING(heal_amt * 1.25, 0.5)
		actual_effect_heal_amt = CEILING(heal_amt * 1.25, 1)
		actual_purge_amt = CEILING(purge_amt * 1.25, 0.5)
	var/old_health = target.health
	var/old_brute = target.getBruteLoss()
	var/old_burn = target.getFireLoss()
	var/old_oxy = target.getOxyLoss()
	var/old_tox = target.getToxLoss()
	var/old_clone = target.getCloneLoss()
	target.heal_overall_damage(brute = actual_heal_amt, burn = actual_heal_amt, updating_health = FALSE)
	target.adjustOxyLoss(-actual_heal_amt, updating_health = FALSE)
	target.adjustToxLoss(-actual_heal_amt, updating_health = FALSE, forced = TRUE)

	if(iscarbon(target))
		var/mob/living/carbon/carbon_target = target
		if((!carbon_target.dna?.species || !HAS_TRAIT(src, TRAIT_NOBLOOD)) && carbon_target.blood_volume < HOLOPARA_MAX_BLOOD_VOLUME_HEAL)
			carbon_target.blood_volume = min(carbon_target.blood_volume + actual_heal_amt, HOLOPARA_MAX_BLOOD_VOLUME_HEAL)
		if(ishuman(carbon_target))
			var/mob/living/carbon/human/human_target = carbon_target
			human_target.cauterise_wounds(actual_heal_amt * 0.2)

	if(purge_toxins)
		var/list/reagents_purged = list()
		for(var/datum/reagent/reagent in target.reagents.reagent_list)
			var/remove = FALSE
			if(istype(reagent, /datum/reagent/toxin))
				var/datum/reagent/toxin/toxin_reagent = reagent
				// Don't remove toxins from toxin lovers.
				if(toxin_reagent.toxpwr > 0 && HAS_TRAIT(target, TRAIT_TOXINLOVER))
					continue
				remove = TRUE
			if(reagent.overdosed)
				remove = TRUE
			if(remove)
				reagents_purged |= "[reagent.type]"
				target.reagents.remove_reagent(reagent.type, actual_purge_amt)
		if(length(reagents_purged))
			SSblackbox.record_feedback("nested tally", "holoparasite_reagents_purged", 1, reagents_purged)
	if(heal_debuffs)
		target.restoreEars()
		var/obj/item/organ/eyes/eyes = target.get_organ_slot(ORGAN_SLOT_EYES)
		if(istype(eyes))
			eyes.apply_organ_damage(-actual_heal_amt)
		target.adjust_blindness(-actual_effect_heal_amt)
		target.adjust_blurriness(-actual_effect_heal_amt)
		target.adjust_disgust(-actual_effect_heal_amt)
		target.dizziness = max(target.dizziness - actual_effect_heal_amt, 0)
		target.confused = max(target.confused - actual_effect_heal_amt, 0)
		target.adjust_hallucinations(-actual_effect_heal_amt)
	if(heal_clone)
		target.adjustCloneLoss(-max(CEILING(actual_heal_amt * 0.75, 0.5), 1), updating_health = FALSE)
	target.updatehealth()
	if(old_health > target.health)
		SSblackbox.record_feedback("associative", "holoparasite_mob_damage_healed", 1, list(
			"target" = replacetext("[target.type]", "/mob/living/", ""),
			"brute" = max(old_brute - target.getBruteLoss(), 0),
			"burn" = max(old_burn - target.getFireLoss(), 0),
			"oxy" = max(old_oxy - target.getOxyLoss(), 0),
			"tox" = max(old_tox - target.getToxLoss(), 0),
			"clone" = heal_clone ? max(old_clone - target.getCloneLoss(), 0) : 0,
			"total" = max(old_health - target.health, 0),
			"self" = target == owner.summoner.current
		))

/**
 * Heals an object.
 */
/datum/holoparasite_ability/major/healing/proc/heal_obj(obj/target)
	var/old_integrity = target.get_integrity()
	target.repair_damage(target.get_integrity() + (target.max_integrity * 0.1), target.max_integrity)
	if(old_integrity > target.get_integrity())
		SSblackbox.record_feedback("associative", "holoparasite_obj_damage_healed", 1, list(
			"target" = replacetext("[target.type]", "/obj/", ""),
			"amount" = max(old_integrity - target.get_integrity(), 0)
		))

/**
 * Spawns a visual effect for the heal at the location of the target.
 */
/datum/holoparasite_ability/major/healing/proc/spawn_heal_effect(atom/target)
	new /obj/effect/temp_visual/heal(get_turf(target), owner.accent_color)

/*
/atom/movable/screen/act_intent/holopara_healer/MouseEntered(location, control, params)
	..()
	if(!QDELETED(src))
		openToolTip(usr, src, params, title = "Healing Intent", content = "<font color='green'><b>HELP</b></font> intent to heal.<br><font color='red'><b>HARM</b></font> intent to attack normally.")

/atom/movable/screen/act_intent/holopara_healer/MouseExited(location, control, params)
	closeToolTip(usr)
*/
