/datum/holoparasite_ability/major/frenzy
	name = "Frenzy"
	desc = "This $theme attacks by teleport around a target making it hard to hit, as well as speeding up its owner while manifested."
	ui_icon = "fighter-jet"
	cost = 2 // low cost because this stand is pretty much LOUD AS FUCK, and using it is stealthily is pretty hard due to it's loud, unique sounds and abilities
				// also because in order for this to be any good, you need to spread your points real good
	thresholds = list(
		list(
			"stat" = "Range",
			"minimum" = 3,
			"desc" = "REQUIRED in order to use this ability."
		),
		list(
			"stat" = "Potential",
			"minimum" = 3,
			"desc" = "When performing a rush attack on a target, they will be violently flung back."
		),
		list(
			"stat" = "Potential",
			"desc" = "Reduces the cooldown of the rush attack."
		),
		list(
			"stat" = "Damage",
			"desc" = "When the knockback threshold is met, affects how far the knockback will send targets."
		)
	)
	/// How long the rush cooldown lasts.
	var/cooldown_length = 0
	/// Whether the rush attack has knockback or not.
	var/rush_knockback = TRUE
	/// How far the knockback attack will send targets flying.
	var/knockback_distance = 5
	/// Cooldown for when the holoparasite can do another rush.
	COOLDOWN_DECLARE(rush_cooldown)

/datum/holoparasite_ability/major/frenzy/apply()
	..()
	var/view_distance = max(getviewsize(world.view)[1], getviewsize(world.view)[2])
	cooldown_length = round((0.2 SECONDS * (5 - master_stats.potential)) + 2, 5) // 2 to 3 seconds
	rush_knockback = master_stats.potential > 3
	knockback_distance = clamp(CEILING(master_stats.damage * 1.75, 1), 2, view_distance)
	owner.add_movespeed_modifier(MOVESPEED_ID_HOLOPARA_FRENZY, update = TRUE, priority = 100, multiplicative_slowdown = -0.75)

/datum/holoparasite_ability/major/frenzy/remove()
	..()
	owner.remove_movespeed_modifier(MOVESPEED_ID_HOLOPARA_FRENZY)

/datum/holoparasite_ability/major/frenzy/can_buy()
	return ..() && master_stats.range >= 3

/datum/holoparasite_ability/major/frenzy/register_signals()
	..()
	RegisterSignal(owner, COMSIG_HOLOPARA_MANIFEST, PROC_REF(on_manifest))
	RegisterSignal(owner, COMSIG_HOLOPARA_RECALL, PROC_REF(on_recall))
	RegisterSignal(owner, COMSIG_HOLOPARA_STAT, PROC_REF(on_stat))
	RegisterSignal(owner, COMSIG_MOB_ATTACK_RANGED, PROC_REF(on_ranged_attack))

/datum/holoparasite_ability/major/frenzy/unregister_signals()
	..()
	UnregisterSignal(owner, list(COMSIG_HOLOPARA_MANIFEST, COMSIG_HOLOPARA_RECALL, COMSIG_HOLOPARA_STAT, COMSIG_MOB_ATTACK_RANGED))

/**
 * Adds the movespeed modifier whenever the holoparasite manifests.
 */
/datum/holoparasite_ability/major/frenzy/proc/on_manifest()
	SIGNAL_HANDLER
	var/mob/living/summoner = owner.summoner.current
	summoner.add_movespeed_modifier(MOVESPEED_ID_HOLOPARA_FRENZY, update = TRUE, priority = 100, multiplicative_slowdown = -1.5)
	to_chat(summoner, "<span class='notice holoparasite'>You feel much faster, as if you could outrun <i>anything!</i></span>")
	summoner.balloon_alert(summoner, "frenzy speed boost applied", show_in_chat = FALSE)

/**
 * Remove the movespeed modifier whenever the holoparasite manifests.
 */
/datum/holoparasite_ability/major/frenzy/proc/on_recall()
	SIGNAL_HANDLER
	var/mob/living/summoner = owner.summoner.current
	summoner.remove_movespeed_modifier(MOVESPEED_ID_HOLOPARA_FRENZY)
	to_chat(summoner, "<span class='notice holoparasite'>You feel the incredible energy within you fade away, leaving you to move at a normal speed once more...</span>")
	summoner.balloon_alert(summoner, "frenzy speed boost lost", show_in_chat = FALSE)

/datum/holoparasite_ability/major/frenzy/proc/on_ranged_attack(datum/_source, mob/living/target, params)
	SIGNAL_HANDLER
	ASSERT_ABILITY_USABILITY
	if(!istype(target) || !COOLDOWN_FINISHED(src, rush_cooldown) || !owner.is_manifested())
		return
	if(owner.has_matching_summoner(target))
		to_chat(owner, "<span class='danger bold'>You can't attack your summoner!</span>")
		return
	playsound(owner, 'sound/magic/blind.ogg', vol = 60, vary = FALSE)
	owner.forceMove(get_step(get_turf(target), get_dir(owner, target)))
	owner.next_move = 1
	target.attack_animal(owner)
	owner.changeNext_move(CLICK_CD_RAPID)
	if(rush_knockback)
		target.throw_at(get_edge_target_turf(target, get_dir(owner, target)), knockback_distance, 4, owner, TRUE)
		owner.visible_message("<span class='danger'>[owner.color_name] violently rushes and attacks <span class='name'>[target]</span>, flinging them backwards!</span>", "<span class='warning'>We violently rush and attack <span class='name'>[target]</span>, flinging them backwards!</span>", ignored_mobs = list(target))
		to_chat(target, "<span class='userdanger'>[owner.color_name] suddenly rushes you violently, delivering a powerful attack that sends you flying back!</span>")
		target.log_message("was flung [knockback_distance] tiles by a frenzy rush from [key_name(owner)]", LOG_ATTACK)
		owner.log_message("flung [key_name(target)] [knockback_distance] tiles with a frenzy rush", LOG_ATTACK, log_globally = FALSE)
	else
		owner.visible_message("<span class='danger'>[owner.color_name] violently rushes and attacks <span class='name'>[target]</span>!</span>", "<span class='warning'>We violently rush and attack <span class='name'>[target]</span>!</span>", ignored_mobs = list(target))
		to_chat(target, "<span class='userdanger'>[owner.color_name] suddenly rushes you violently, delivering a powerful attack!</span>")
		target.log_message("was attacked with a frenzy rush from [key_name(owner)]", LOG_ATTACK)
		owner.log_message("hit [key_name(target)] with a frenzy rush", LOG_ATTACK, log_globally = FALSE)
	SSblackbox.record_feedback("amount", "holoparasite_frenzy_rushes", 1)
	COOLDOWN_START(src, rush_cooldown, cooldown_length)

/**
 * Adds frenzy rush cooldown info to the holoparasite's stat panel.
 */
/datum/holoparasite_ability/major/frenzy/proc/on_stat(datum/_source, list/tab_data)
	SIGNAL_HANDLER
	if(!COOLDOWN_FINISHED(src, rush_cooldown))
		tab_data["Frenzy Rush Cooldown"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, rush_cooldown))
