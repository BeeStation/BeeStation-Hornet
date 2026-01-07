GLOBAL_LIST_EMPTY_TYPED(holoparasites, /mob/living/simple_animal/hostile/holoparasite) //! All currently existing holoparasites.

/mob/living/simple_animal/hostile/holoparasite
	name = "Holoparasite"
	real_name = "Holoparasite"
	desc = "A sentient bluespace crystallization of someone's willpower, this being will forever protect and serve its host, standing guard until the last embers of their life are extinguished."
	speak_emote = list("emanates", "radiates")
	gender = NEUTER
	mob_biotypes = MOB_INORGANIC
	bubble_icon = "guardian"
	response_help_continuous = "passes through"
	response_help_simple = "pass through"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	icon = 'icons/mob/holoparasite.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = FALSE
	combat_mode = TRUE
	stop_automated_movement = TRUE
	is_flying_animal = TRUE // Immunity to chasms and landmines, etc.
	no_flying_animation = TRUE
	attack_sound = "punch"
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attack_verb_continuous = "punches"
	attack_verb_simple = "punch"
	maxHealth = INFINITY // The spirit itself is invincible
	health = INFINITY
	healable = FALSE // Don't bruise pack the holopara!
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0) // How much damage from each damage type we transfer to the owner
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 15
	AIStatus = AI_OFF
	hud_type = /datum/hud/holoparasite
	dextrous_hud_type = /datum/hud/holoparasite
	chat_color = "#ffffff"
	mobchatspan = "holoparasite"
	faction = list()
	discovery_points = 10000
	see_in_dark = 10
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	/**
	 * The name of the holoparasite, formatted with the [accent_color] in a <font> tag.
	 * Automatically set by [set_name()].
	 */
	var/color_name
	/// Notes left by the summoner of the holoparasite.
	var/notes = ""
	/**
	 * The accent color of the holoparasite, usually used to color an overlay.
	 * If [recolor_entire_sprite] is TRUE, it will instead be used to recolor the entire sprite.
	 */
	var/accent_color
	/// A list of accent color overlays.
	var/list/mutable_appearance/accent_overlays = list()
	/// Whether this holoparasite has emissive overlays or not.
	var/emissive = FALSE
	/// Whether to recolor the entire holoparasite with the [accent_color], or just the overlay.
	var/recolor_entire_sprite = FALSE
	/// The theme of this holoparasite.
	var/datum/holoparasite_theme/theme
	/**
	 * The range, in tiles, that this holoparasite can go from its summoner while manifested.
	 * A range of 1 will be permanently attached to its summoner.
	 * A range below 1 will have infinite range.
	 */
	var/range = 10
	/**
	 * The mind that summoned this holoparasite.
	 * The holoparasite is completely and utterly loyal to this user.
	 */
	var/datum/mind/summoner
	/// The stats associated with this holoparasite.
	var/datum/holoparasite_stats/stats
	/// The summoner's holoparasite holder.
	var/datum/holoparasite_holder/parent_holder
	/**
	 * The 'battle cry' the holoparasite uses when attacking.
	 * If blank, no battle cry will be shouted at all.
	 */
	var/battlecry = "AT"
	/// Whether this holoparasite can use abilities currently or not.
	var/can_use_abilities = TRUE
	/**
	 * Whether the holoparasite is attached to its summoner when manifested or not.
	 * This does not affect range=1 holoparasites, those will always be permanently attached,
	 * this is used for 'manual' attaching.
	 */
	var/attached_to_summoner = FALSE
	/// The amount of HUD elements on the base "toolbar" at the bottom.
	var/toolbar_element_count = 0
	/// If the holoparasite talks out loud (rather than privately with its summoner) whenever it talks while recalled.
	var/talk_out_loud = FALSE
	/// The tracking beacon component used for the host to track the holoparasite when scouting.
	var/datum/component/tracking_beacon/tracking_beacon

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/hostile/holoparasite)

/mob/living/simple_animal/hostile/holoparasite/Initialize(mapload, _key, _name, datum/holoparasite_theme/_theme, _accent_color, _notes, datum/mind/_summoner, datum/holoparasite_stats/_stats)
	. = ..()
	if(!istype(_summoner))
		stack_trace("Holoparasite initialized without a valid summoner!")
		return INITIALIZE_HINT_QDEL
	if(!istype(_stats))
		stack_trace("Holoparasite initialized without valid stats!")
		return INITIALIZE_HINT_QDEL
	if(!istype(_theme))
		stack_trace("Holoparasite initialized without a valid theme!")
		return INITIALIZE_HINT_QDEL
	GLOB.holoparasites += src
	set_accent_color(_accent_color || pick(GLOB.color_list_rainbow), silent = TRUE)
	set_theme(_theme)
	if(length(_name))
		set_name(_name, internal = TRUE)
	if(length(_notes))
		notes = _notes
	set_summoner(_summoner)
	stats = _stats
	stats.apply(src)
	set_battlecry(pick("ORA", "MUDA", "DORA", "ARRI", "VOLA", "AT"), silent = TRUE)
	if(length(_key))
		key = _key
	RegisterSignal(src, COMSIG_LIVING_PRE_WABBAJACKED, PROC_REF(on_pre_wabbajacked))
	tracking_beacon = LoadComponent(/datum/component/tracking_beacon, REF(parent_holder), null, parent_holder.get_monitor(), FALSE, accent_color, TRUE, TRUE)
	ADD_LUM_SOURCE(src, LUM_SOURCE_INNATE)

/mob/living/simple_animal/hostile/holoparasite/Destroy()
	GLOB.holoparasites -= src
	QDEL_LIST(accent_overlays)
	parent_holder?.remove_holoparasite(src)
	if(tracking_beacon)
		QDEL_NULL(tracking_beacon)
	return ..()

/mob/living/simple_animal/hostile/holoparasite/Login()
	var/datum/antagonist/holoparasite/first_time_show_popup
	if(mind && key && key != mind.key) // Ooh, new player!
		first_time_show_popup = mind.has_antag_datum(/datum/antagonist/holoparasite)
	. = ..()
	if(!. || !client)
		return FALSE
	if(mind)
		mind.name = "[real_name]"
	if(QDELETED(summoner?.current))
		message_admins("BUG: [ADMIN_LOOKUPFLW(src)], a holoparasite, somehow either has no summoner, or is in their body while their summoner is dead. This is <b>very bad</b>, and unless you caused this by screwing around with holoparasites using admin tools, is most definitely a bug, in which case <a href='byond://winset?command=report-issue'><i>please</i> report this ASAP!!</a>")
		log_runtime("BUG: [key_name(src)], a holoparasite, somehow either has no summoner, or is in their body while their summoner is dead. This is very bad and is most definitely a bug!!")
		to_chat(src, span_userdanger("For some reason, somehow, you have no summoner. <a href='byond://winset?command=report-issue'>Please report this bug immediately</a>, because this should <i>never</i> be possible! (outside of admins screwing with stuff they don't fully understand)"))
		ghostize(FALSE)
		return
	var/list/info_block = list()
	info_block += span_bigholoparasite("You can use :[MODE_KEY_HOLOPARASITE] or .[MODE_KEY_HOLOPARASITE] to privately communicate with your summoner!")
	info_block += span_holoparasite("You are [color_name], bound to serve [span_name("[summoner.name]")].")
	info_block += span_holoparasite("You are capable of manifesting or recalling to your summoner with the buttons on your HUD. You will also find a button to communicate with [summoner.current.p_them()] privately there.")
	info_block += span_holoparasite("While personally invincible, you will die if [span_name("[summoner.name]")] does, and any damage dealt to you will have a portion passed on to [summoner.current.p_them()] as you feed upon [summoner.current.p_them()] to sustain yourself.")
	info_block += span_holoparasitebold("Click the INFO button on your HUD in order to learn more about your stats, abilities, and your summoner.")
	setup_barriers()
	first_time_show_popup?.ui_interact(src)
	var/list/stat_popups = list()
	if(stats.ability)
		var/ability_info = stats.ability.notify_user()
		if(length(ability_info))
			stat_popups += "[span_holoparasitebig("Ability: <b>[stats.ability.name]</b>")]\n[ability_info]"
	for(var/datum/holoparasite_ability/lesser/lability as() in stats.lesser_abilities)
		var/ability_info = lability.notify_user()
		if(length(ability_info))
			stat_popups += "[span_holoparasitebig("Lesser Ability: <b>[lability.name]</b>")]\n[ability_info]"
	var/weapon_info = stats.weapon.notify_user()
	if(length(weapon_info))
		stat_popups += "[span_holoparasitebig("Weapon: <b>[stats.weapon.name]</b>")]\n[weapon_info]"
	if(length(stat_popups))
		info_block += list(span_info("================"), span_bigboldinfo("\[ABILITY NOTES\]"), "[stat_popups.Join("\n[span_info("====")]\n")]")
	to_chat(src, examine_block(info_block.Join("\n")), type = MESSAGE_TYPE_INFO, avoid_highlighting = TRUE)

/mob/living/simple_animal/hostile/holoparasite/Life()
	. = ..()
	if(.)
		snapback()

/mob/living/simple_animal/hostile/holoparasite/get_stat_tab_status()
	. = ..()
	if(summoner.current)
		var/mob/living/current = summoner.current
		var/health_percent
		if(iscarbon(current))
			health_percent = round((abs(HEALTH_THRESHOLD_DEAD - current.health) / abs(HEALTH_THRESHOLD_DEAD - current.maxHealth)) * 100)
		else
			health_percent = round((current.health / current.maxHealth) * 100, 0.5)
		var/stat_text = "[health_percent]%"
		if(HAS_TRAIT(current, TRAIT_CRITICAL_CONDITION))
			stat_text += " (!! CRITICAL !!)"
		.["Summoner Health"] = GENERATE_STAT_TEXT(stat_text)
	if(!COOLDOWN_FINISHED(src, manifest_cooldown))
		.["Manifest/Recall Cooldown Remaining"] = GENERATE_STAT_TEXT(COOLDOWN_TIMELEFT_TEXT(src, manifest_cooldown))
	SEND_SIGNAL(src, COMSIG_HOLOPARA_STAT, .)

/mob/living/simple_animal/hostile/holoparasite/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/holoparasite/suicide()
	set hidden = TRUE
	to_chat(src, span_warning("You cannot commit suicide! Reset yourself (or contact an admin) if you wish to stop being a holoparasite!"))

/mob/living/simple_animal/hostile/holoparasite/set_resting(new_resting, silent = TRUE, instant = FALSE)
	return FALSE

/mob/living/simple_animal/hostile/holoparasite/can_use_guns(obj/item/gun)
	if(SEND_SIGNAL(src, COMSIG_HOLOPARA_CAN_FIRE_GUN, gun) & HOLOPARA_CAN_FIRE_GUN)
		return TRUE
	balloon_alert(src, "cannot fire [gun]", show_in_chat = FALSE)
	to_chat(src, span_warning("You can't fire \the [gun]!"))
	return FALSE // No... just... no.

/mob/living/simple_animal/hostile/holoparasite/Hear(message, atom/movable/speaker, datum/language/message_language, raw_message, radio_freq, list/spans, list/message_mods)
	var/datum/antagonist/traitor/summoner_traitor = summoner?.has_antag_datum(/datum/antagonist/traitor)
	if(summoner_traitor?.has_codewords)
		raw_message = GLOB.syndicate_code_phrase_regex.Replace(raw_message, span_blue("$1"))
		raw_message = GLOB.syndicate_code_response_regex.Replace(raw_message, span_red("$1"))
	return ..()

/mob/living/simple_animal/hostile/holoparasite/examine(mob/user)
	. = ..()
	if(isobserver(user) || has_matching_summoner(user))
		if(!stats.weapon.hidden)
			. += span_holoparasite("<b>WEAPON:</b> [stats.weapon.name] - [replacetext(stats.weapon.desc, "$theme", LOWER_TEXT(theme.name))]")
		if(stats.ability)
			. += span_holoparasite("<b>SPECIAL ABILITY:</b> [stats.ability.name] - [replacetext(stats.ability.desc, "$theme", LOWER_TEXT(theme.name))]")
		for(var/datum/holoparasite_ability/lesser/ability as() in stats.lesser_abilities)
			. += span_holoparasite("<b>LESSER ABILITY:</b> [ability.name] - [replacetext(ability.desc, "$theme", LOWER_TEXT(theme.name))]")
		. += "<span data-component=\"RadarChart\" data-width=\"300\" data-height=\"300\" data-area-color=\"[accent_color]\" data-axes=\"Damage,Defense,Speed,Potential,Range\" data-stages=\"1,2,3,4,5\" data-values=\"[stats.damage],[stats.defense],[stats.speed],[stats.potential],[stats.range]\" />"

/mob/living/simple_animal/hostile/holoparasite/get_idcard(hand_first = TRUE)
	// IMPORTANT: don't use ?. for these, because held_item might be 0 for some reason!!
	var/obj/item/card/id/id_card
	var/obj/item/held_item
	held_item = get_active_held_item()
	if(!QDELETED(held_item))
		id_card = held_item.GetID() //Check active hand
	if(QDELETED(id_card)) //If there is no id, check the other hand
		held_item = get_inactive_held_item()
		if(!QDELETED(held_item))
			id_card = held_item.GetID()

	if(!QDELETED(id_card))
		if(hand_first)
			return id_card
		. = id_card

	// Check inventory slot
	if(istype(stats.weapon, /datum/holoparasite_ability/weapon/dextrous))
		var/datum/holoparasite_ability/weapon/dextrous/dextrous_ability = stats.weapon
		var/obj/item/internal_item = dextrous_ability.internal_storage
		if(!QDELETED(internal_item))
			return internal_item.GetID()

/mob/living/simple_animal/hostile/holoparasite/CtrlClickOn(atom/target)
	. = ..()
	if(combat_mode && is_manifested() && isobj(target) && Adjacent(target))
		if(target.ui_interact(src) != FALSE) // unimplemented ui_interact returns FALSE, while implemented typically just returns... nothing.
			to_chat(src, span_notice("You take a closer look at [costly_icon2html(target, src)] [target]..."))
			return

/mob/living/simple_animal/hostile/holoparasite/shared_ui_interaction(host)
	if(isobj(host))
		var/obj/obj_host = host
		if(obj_host.loc != src && !is_manifested())
			return UI_CLOSE
	. = ..()
	if(incorporeal_move)
		. = min(., UI_UPDATE)

/mob/living/simple_animal/hostile/holoparasite/proc/toggle_light()
	if(emissive)
		set_light_on(is_manifested() || !light_on)
		if(light_range != initial(light_range) || light_power != initial(light_power))
			set_light_range(initial(light_range))
			set_light_power(initial(light_power))
			to_chat(src, span_notice("You activate your light."))
			balloon_alert(src, "light activated", show_in_chat = FALSE)
		else
			set_light_range(0)
			set_light_power(0.1)
			to_chat(src, span_notice("You deactivate your light."))
			balloon_alert(src, "light deactivated", show_in_chat = FALSE)
	else
		set_light_on(!light_on)
		var/prefix = light_on ? "" : "de"
		to_chat(src, span_notice("You [prefix]activate your light."))
		balloon_alert(src, "light [prefix]activated", show_in_chat = FALSE)

/**
 * Recreates the holoparasite's HUD.
 */
/mob/living/simple_animal/hostile/holoparasite/proc/recreate_hud()
	QDEL_NULL(hud_used)
	if(!client)
		return
	create_mob_hud()
	if(hud_used)
		hud_used.show_hud(hud_used.hud_version)
