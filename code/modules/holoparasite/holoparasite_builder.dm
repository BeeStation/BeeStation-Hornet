/datum/holoparasite_builder
	/// The saved stats of the holoparasite being built.
	var/datum/holoparasite_stats/saved_stats = new
	/// The custom name of the holoparasite being built.
	var/holopara_name
	/**
	 * The notes the user has set for the holoparasite.
	 * These can be used for RP purposes, OOC notices, ensuring they remember your targets, or whatever else.
	 */
	var/notes = ""
	/// The accent color of the holoparasite being built.
	var/accent_color = COLOR_WHITE
	/// The maximum amount of points the user can spend on the holoparasite.
	var/max_points = 20
	/// The current amount of available points the user can spend on the holoparasite.
	var/points
	/// The maximum level holoparasite abilities can reach.
	var/max_level = 5
	/// The theme of the holoparasite being built.
	var/datum/holoparasite_theme/theme
	/// Whether this holoparasite builder is currently waiting for a ghost poll or not.
	var/waiting = FALSE
	/// How many uses this holoparasite builder has left.
	var/uses = 1
	/// Debug mode will simply yoink the user into the newly created holoparasite when enabled.
	var/debug_mode = FALSE
	/// The 'host' item linked to this builder.
	var/obj/item/host

/datum/holoparasite_builder/New(obj/item/_host, datum/holoparasite_theme/_theme, _max_points, _max_level, _uses, _debug_mode)
	..()
	if(host)
		_host = host
	theme = get_holoparasite_theme(_theme)
	if(!istype(theme))
		CRASH("Holoparasite builder created without valid theme!")
	if(isnum_safe(_max_points))
		max_points = max(round(_max_points), 1)
	points = max_points
	if(isnum_safe(_max_level))
		max_level = max(round(_max_level), 1)
	saved_stats.max_level = max_level
	if(isnum_safe(_uses))
		uses = max(round(_uses), 1)
	debug_mode = _debug_mode
	accent_color = pick(GLOB.color_list_rainbow)

/datum/holoparasite_builder/Destroy()
	QDEL_NULL(saved_stats)
	return ..()

/datum/holoparasite_builder/ui_host(mob/user)
	if(!QDELETED(host))
		return host
	return ..()

/datum/holoparasite_builder/ui_state(mob/user)
	if(!QDELETED(host))
		return GLOB.inventory_state
	return GLOB.always_state

/datum/holoparasite_builder/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "HoloparasiteBuilder", "[theme.name] Builder")
		ui.set_autoupdate(TRUE)
		ui.open()


/datum/holoparasite_builder/ui_data(mob/user)
	. = list(
		"custom_name" = holopara_name,
		"accent_color" = accent_color,
		"waiting" = waiting,
		"used" = uses <= 0,
		"points" = calc_points(),
		"no_ability" = !istype(saved_stats.ability),
		"selected_abilities" = list(),
		"rated_skills" = list(
			list(
				name = "Damage",
				desc = "Amount of damage the $theme can deal per hit.",
				level = saved_stats.damage,
			),
			list(
				name = "Defense",
				desc = "Amount of damage the $theme can negate, rather than transferring the entirety of it to the summoner.",
				level = saved_stats.defense
			),
			list(
				name = "Speed",
				desc = "How fast the $theme can move and attack targets.",
				level = saved_stats.speed
			),
			list(
				name = "Potential",
				desc = "Does nothing on its own, but it boosts the power of the $theme's abilities in various ways, although other stats can do so as well.",
				level = saved_stats.potential
			),
			list(
				name = "Range",
				desc = "How far the $theme can travel from its summoner before being forcefully snapped back to the summoner's position.",
				level = saved_stats.range
			)
		),
		"validation" = list(
			"color" = is_color_dark_with_saturation(accent_color, HOLOPARA_MAX_ACCENT_LIGHTNESS) ? "too dark" : "valid",
			"name" = check_name_validity(),
			"notes" = check_notes_validity()
		)
	)
	if(length(notes))
		.["notes"] = notes
	if(saved_stats.ability)
		.["selected_abilities"] += "[saved_stats.ability.type]"
		if(saved_stats.ability.forced_weapon)
			.["forced_weapon"] = "[saved_stats.ability.forced_weapon]"
	for(var/datum/holoparasite_ability/ability as() in saved_stats.lesser_abilities)
		.["selected_abilities"] += "[ability.type]"
	.["selected_abilities"] += "[saved_stats.weapon.type]"


/datum/holoparasite_builder/ui_static_data(mob/user)
	. = list(
		"themed_name" = theme.name,
		"max_points" = max_points,
		"max_level" = max_level,
		"abilities" = list(
			"major" = list(),
			"lesser" = list(),
			"weapons" = list()
		),
		"max_lengths" = list(
			"name" = MAX_NAME_LEN,
			"notes" = MAX_PAPER_LENGTH
		)
	)
	for(var/ability_path in GLOB.holoparasite_abilities)
		if(!is_valid_ability(ability_path))
			continue
		var/datum/holoparasite_ability/ability = GLOB.holoparasite_abilities[ability_path]
		var/list/target_data
		if(ispath(ability_path, /datum/holoparasite_ability/major))
			target_data = .["abilities"]["major"]
		else if(ispath(ability_path, /datum/holoparasite_ability/lesser))
			target_data = .["abilities"]["lesser"]
		else if(ispath(ability_path, /datum/holoparasite_ability/weapon))
			target_data = .["abilities"]["weapons"]
		else
			continue
		target_data += list(list(
			name = ability.name,
			desc = ability.desc,
			cost = ability.cost,
			icon = ability.ui_icon,
			thresholds = ability.thresholds,
			path = "[ability.type]",
			hidden = ability.hidden
		))

/datum/holoparasite_builder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	. = ..()
	if(. || uses <= 0 || waiting)
		return TRUE
	switch(action)
		if("set:name")
			var/value = params["name"]
			if(!istext(value))
				return
			holopara_name = trim(value, MAX_NAME_LEN)
			. = TRUE
		if("set:stat")
			var/stat = params["stat"]
			var/value = params["level"]
			if(!istext(stat) || !length(stat) || !isnum_safe(value))
				return
			var/level = clamp(round(value), 1, max_level)
			switch(stat)
				if("Damage")
					saved_stats.damage = level
					. = TRUE
				if("Defense")
					saved_stats.defense = level
					. = TRUE
				if("Speed")
					saved_stats.speed = level
					. = TRUE
				if("Potential")
					saved_stats.potential = level
					. = TRUE
				if("Range")
					saved_stats.range = level
					. = TRUE
		if("set:color")
			var/color = params["color"]
			if(!istext(color) || length(color) != 7)
				return
			var/new_accent_color = sanitize_hexcolor(color, include_crunch = TRUE, default = (length(accent_color) == 7 && accent_color != initial(accent_color)) ? accent_color : pick(GLOB.color_list_rainbow))
			if(is_color_dark_with_saturation(new_accent_color, HOLOPARA_MAX_ACCENT_LIGHTNESS))
				to_chat(usr, span_warning("Selected accent color is too dark!"))
				return
			accent_color = new_accent_color
			. = TRUE
		if("set:notes")
			var/value = params["notes"]
			if(!istext(value))
				return
			notes = trim(value, MAX_PAPER_LENGTH)
			. = TRUE
		if("ability:major:clear")
			QDEL_NULL(saved_stats.ability)
			. = TRUE
		if("ability:major:set")
			var/ability_path = text2path(params["path"])
			if(!is_valid_ability(ability_path, /datum/holoparasite_ability/major))
				return
			saved_stats.set_major_ability(ability_path)
			enforce_ability_weapon()
			. = TRUE
		if("ability:major:take")
			if(saved_stats.ability)
				QDEL_NULL(saved_stats.ability)
				. = TRUE
		if("ability:lesser:add")
			var/ability_path = text2path(params["path"])
			if(!is_valid_ability(ability_path, /datum/holoparasite_ability/lesser))
				return
			saved_stats.add_lesser_ability(ability_path)
			. = TRUE
		if("ability:lesser:take")
			var/datum/holoparasite_ability/lesser/ability_path = text2path(params["path"])
			if(!is_valid_ability(ability_path, /datum/holoparasite_ability/lesser))
				return
			saved_stats.take_lesser_ability(ability_path)
			. = TRUE
		if("ability:weapon:set")
			var/weapon_path = text2path(params["path"])
			if(!is_valid_ability(weapon_path, /datum/holoparasite_ability/weapon) || !enforce_ability_weapon(weapon_path))
				return
			saved_stats.set_weapon(weapon_path)
			. = TRUE
		if("spawn")
			. = spawn_holoparasite(usr)
		if("reset")
			QDEL_NULL(saved_stats)
			saved_stats = new
			. = TRUE
		if("random")
			saved_stats.randomize(max_points)
			to_chat(usr, span_boldnotice("Stats randomized."))
			. = TRUE
	if(.)
		if(saved_stats.ability && !saved_stats.ability.can_buy()) // In case stat changes made some abilities invalid to have. Right now only Frenzy.
			QDEL_NULL(saved_stats.ability)
		var/forced_weapon_path = saved_stats.ability?.forced_weapon
		if(is_valid_ability(forced_weapon_path, /datum/holoparasite_ability/weapon) && !istype(saved_stats.weapon, forced_weapon_path))
			QDEL_NULL(saved_stats.weapon)
			saved_stats.weapon = new forced_weapon_path
		for(var/datum/holoparasite_ability/lesser/lability as() in saved_stats.lesser_abilities)
			if(!lability.can_buy())
				saved_stats.lesser_abilities -= lability
				qdel(lability)
		if(!saved_stats.weapon.can_buy())
			QDEL_NULL(saved_stats.weapon)
			saved_stats.weapon = new /datum/holoparasite_ability/weapon/punch
		calc_points()

/datum/holoparasite_builder/proc/enforce_ability_weapon(new_weapon_path, silent = FALSE)
	. = FALSE
	var/forced_weapon_path = saved_stats.ability?.forced_weapon
	if(!forced_weapon_path || !is_valid_ability(forced_weapon_path, /datum/holoparasite_ability/weapon))
		return TRUE
	if((new_weapon_path && ispath(new_weapon_path, forced_weapon_path)) || (!new_weapon_path && istype(saved_stats.weapon, forced_weapon_path)))
		return TRUE
	var/datum/holoparasite_ability/weapon/forced_weapon = GLOB.holoparasite_abilities[forced_weapon_path]
	to_chat(usr, span_danger("The <b>[saved_stats.ability.name]</b> ability forces you to use the <b>[forced_weapon.name]</b> weapon! You cannot choose a different weapon with this ability selected!"))
	saved_stats.set_weapon(forced_weapon_path)


/datum/holoparasite_builder/proc/is_valid_ability(path, base_path)
	. = TRUE
	base_path = base_path || /datum/holoparasite_ability
	if(!path || !ispath(path, base_path))
		return FALSE
	var/datum/holoparasite_ability/ability = GLOB.holoparasite_abilities[path]
	if(!istype(ability) || !isnum_safe(ability.cost)) // null cost means this ability is NOT obtainable through normal means.
		return FALSE
/**
 * Checks the validity of the name of the holoparasite, returning the reason if it's invalid, or "valid" if it is in fact valid.
 */
/datum/holoparasite_builder/proc/check_name_validity()
	. = "valid"
	var/name_length = length(holopara_name)
	if(!name_length)
		return "blank"
	if(name_length > MAX_NAME_LEN)
		return "too long"
	if(!reject_bad_name(holopara_name))
		return "invalid"
	if(CHAT_FILTER_CHECK(holopara_name))
		return "filtered"

/**
 * Checks the validity of the custom notes of the holoparasite, returning the reason if it's invalid, or "valid" if it is in fact valid.
 */
/datum/holoparasite_builder/proc/check_notes_validity()
	. = "valid"
	var/notes_length = length(notes)
	if(!notes_length)
		return
	if(notes_length > MAX_PAPER_LENGTH)
		return "too long"
	if(OOC_FILTER_CHECK(notes))
		return "filtered"

/datum/holoparasite_builder/proc/calc_points()
	points = max_points - max(saved_stats.damage - 1, 0) - max(saved_stats.defense - 1, 0) - max(saved_stats.speed - 1, 0) - max(saved_stats.potential - 1, 0) - max(saved_stats.range - 1, 0) - saved_stats.weapon.cost
	if(saved_stats.ability)
		points -= saved_stats.ability.cost
	for(var/datum/holoparasite_ability/lesser/minor as() in saved_stats.lesser_abilities)
		points -= minor.cost
	return points

/datum/holoparasite_builder/proc/spawn_holoparasite(mob/living/user)
	. = TRUE
	if(!iscarbon(user) || !user?.mind)
		return FALSE
	if(waiting)
		to_chat(user, span_warning("You're already trying to summon a [theme.name]! Be patient!"))
		user.balloon_alert(user, "failed, already trying to summon", show_in_chat = FALSE)
		return FALSE
	if(uses <= 0)
		to_chat(user, span_warning("You've already used up this builder!"))
		user.balloon_alert(user, "failed, builder used up", show_in_chat = FALSE)
		return FALSE
	holopara_name = reject_bad_name(holopara_name, allow_numbers = TRUE)
	if(!length(holopara_name))
		to_chat(user, span_warning("Your [theme.name] must have a name!"))
		user.balloon_alert(user, "failed, empty name", show_in_chat = FALSE)
		return FALSE
	if(CHAT_FILTER_CHECK(holopara_name))
		to_chat(src, span_warning("The chosen [theme.name] name contains forbidden words."))
		user.balloon_alert(user, "failed, filtered name", show_in_chat = FALSE)
		return FALSE
	if(OOC_FILTER_CHECK(notes))
		to_chat(src, span_warning("The provided notes contain forbidden words."))
		user.balloon_alert(user, "failed, filtered notes", show_in_chat = FALSE)
		return FALSE
	if(is_color_dark_with_saturation(accent_color, HOLOPARA_MAX_ACCENT_LIGHTNESS))
		to_chat(src, span_warning("The provided accent color ([accent_color]) is too dark (lightness of [rgb2num(accent_color, COLORSPACE_HSL)[3]], must be below [HOLOPARA_MAX_ACCENT_LIGHTNESS])."))
		user.balloon_alert(user, "failed, accent color too dark", show_in_chat = FALSE)
		return FALSE
	calc_points()
	if(points < 0)
		to_chat(user, span_danger("You don't have enough points for a [theme.name] like that!"))
		user.balloon_alert(user, "failed, not enough points", show_in_chat = FALSE)
		return FALSE
	waiting = TRUE
	theme.display_message(user, HOLOPARA_MESSAGE_USE)
	user.balloon_alert(user, "attempting to summon [LOWER_TEXT(theme.name)]", show_in_chat = FALSE)
	var/tldr_stats = saved_stats.tldr()
	user.log_message("is attempting to summon a holoparasite ([theme.name]), with the following stats: [tldr_stats]", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] is attempting to summon a holoparasite ([theme.name]), with the following stats: [tldr_stats]")
	// IMPORTANT - if we're debugging, the user gets thrown into the stand
	var/list/mob/dead/observer/candidates
	if(debug_mode)
		candidates = list(user)
	else
		var/datum/poll_config/config = new()
		config.check_jobban = ROLE_HOLOPARASITE
		config.poll_time = 30 SECONDS
		config.jump_target = user
		config.role_name_text = "[holopara_name], [user]'s [theme.name]"
		config.alert_pic = /mob/living/simple_animal/hostile/holoparasite
		candidates = SSpolling.poll_ghost_candidates(config)
	waiting = FALSE
	if(!length(candidates))
		theme.display_message(user, HOLOPARA_MESSAGE_FAILED)
		user.balloon_alert(user, "failed to summon [LOWER_TEXT(theme.name)]", show_in_chat = FALSE)
		return FALSE
	uses--
	var/mob/dead/observer/candidate = pick(candidates)
	var/mob/living/simple_animal/hostile/holoparasite/holoparasite = new(user, candidate.key, holopara_name, theme, accent_color, notes, user.mind, saved_stats)
	var/datum/antagonist/holoparasite/holopara_antag = holoparasite.mind.add_antag_datum(new /datum/antagonist/holoparasite(user.mind.holoparasite_holder(), saved_stats, theme))
	saved_stats = new
	holopara_antag.ui_interact(holoparasite) // Show them the info popup
	user.log_message("summoned [key_name(holoparasite)], a holoparasite ([theme.name]), with the following stats: [tldr_stats]", LOG_GAME)
	message_admins("[ADMIN_LOOKUPFLW(user)] has summoned [ADMIN_LOOKUPFLW(holoparasite)], a holoparasite ([theme.name]), with the following stats: [tldr_stats]")
	theme.display_message(user, HOLOPARA_MESSAGE_SUCCESS, holoparasite)
	user.balloon_alert(user, "successfully summoned [LOWER_TEXT(theme.name)]", show_in_chat = FALSE)
	record_to_blackbox()

/**
 * Records data about a created holoparasite to SSblackbox.
 */
/datum/holoparasite_builder/proc/record_to_blackbox()
	var/list/lesser_abilities = list()
	for(var/datum/holoparasite_ability/lesser/lesser_ability as() in saved_stats.lesser_abilities)
		lesser_abilities += "[lesser_abilities.type]"
	SSblackbox.record_feedback("amount", "holoparasites_created", 1)
	SSblackbox.record_feedback("associative", "holoparasite_stats", 1, list(
		"damage" = saved_stats.damage,
		"defense" = saved_stats.defense,
		"speed" = saved_stats.speed,
		"potential" = saved_stats.potential,
		"range" = saved_stats.range,
		"major_ability" = saved_stats.ability ? "[saved_stats.ability.type]" : "(none)",
		"lesser_abilities" = lesser_abilities,
		"weapon" = "[saved_stats.weapon.type]",
		"theme" = "[theme.type]",
		"has_notes" = length(notes) > 0 ? "yes" : "no"
	))

/**
 * A holoparasite builder intended to be used by admins to create holoparasites for other players.
 */
/datum/holoparasite_builder/admin
	max_points = 99

/datum/holoparasite_builder/admin/ui_host(mob/user)
	return src

/datum/holoparasite_builder/admin/ui_state(mob/user)
	return GLOB.admin_state

/datum/holoparasite_builder/admin/ui_status(mob/user, datum/ui_state/_state)
	if(check_rights_for(user.client, R_FUN))
		return UI_INTERACTIVE
	return UI_CLOSE

// the item
/obj/item/holoparasite_creator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	obj_flags = USES_TGUI
	item_flags = NOBLUDGEON | NO_MAT_REDEMPTION
	w_class = WEIGHT_CLASS_SMALL
	custom_price = 20000
	max_demand = 5
	/// The internal holoparasite builder object, which handles actually, well, building the holoparasite.
	var/datum/holoparasite_builder/builder
	/// A typepath to the theme of the holoparasite to create.
	var/theme = /datum/holoparasite_theme/magic
	/// Whether to allow someone to summon another holoparasite if they already have one.
	var/allow_multiple = FALSE
	/// Whether to allow changelings to summon holoparasites.
	var/allow_changeling = TRUE
	/// The maximum amount of points available when building a holoparasite.
	var/max_points = 15
	/// The maximum level holoparasite stats can reach when building a holoparasite.
	var/max_level = 5
	/// How many uses this holoparasite creator has left.
	var/uses = 1
	/// Debug mode will simply yoink the user into the newly created holoparasite when enabled.
	var/debug_mode = FALSE

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/holoparasite_creator)

/obj/item/holoparasite_creator/Initialize(mapload, datum/holoparasite_theme/theme_override)
	. = ..()
	builder = new(src, theme_override || theme, max_points, max_level, uses, debug_mode)
	ADD_TRAIT(src, TRAIT_EXAMINE_SKIP, INNATE_TRAIT)

/obj/item/holoparasite_creator/Destroy()
	QDEL_NULL(builder)
	return ..()

/obj/item/holoparasite_creator/attack_self(mob/living/user)
	if(!user.mind)
		return
	if(isholopara(user))
		to_chat(user, span_holoparasite("[builder.theme.name] chains are not allowed."))
		return
	if(user.has_holoparasites() && !allow_multiple)
		to_chat(user, span_holoparasite("You already have a [builder.theme.name]!"))
		return
	if(user.mind?.has_antag_datum(/datum/antagonist/changeling) && !allow_changeling)
		builder.theme.display_message(user, HOLOPARA_MESSAGE_LING_FAILED)
		return
	if(builder.uses <= 0)
		builder.theme.display_message(user, HOLOPARA_MESSAGE_USED)
		return
	builder.ui_interact(user)

/obj/item/holoparasite_creator/vv_edit_var(var_name, var_value)
	switch(var_name)
		if(NAMEOF(src, debug_mode))
			if(!isnum_safe(var_value))
				return FALSE
			builder.debug_mode = var_value
			builder.datum_flags |= DF_VAR_EDITED
			debug_mode = var_value
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, max_points))
			if(!isnum_safe(var_value) || var_value < 1)
				return FALSE
			var/new_max_points = round(var_value)
			builder.max_points = new_max_points
			builder.datum_flags |= DF_VAR_EDITED
			max_points = new_max_points
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, max_level))
			if(!isnum_safe(var_value) || var_value < 1)
				return FALSE
			var/new_max_level = round(var_value)
			builder.max_level = new_max_level
			builder.datum_flags |= DF_VAR_EDITED
			builder.saved_stats.max_level = new_max_level
			builder.saved_stats.datum_flags |= DF_VAR_EDITED
			max_level = new_max_level
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, theme))
			var/datum/holoparasite_theme/new_theme = get_holoparasite_theme(var_value)
			if(!istype(new_theme))
				return FALSE
			builder.theme = new_theme
			builder.datum_flags |= DF_VAR_EDITED
			theme = new_theme
			datum_flags |= DF_VAR_EDITED
			return TRUE
		if(NAMEOF(src, uses))
			if(!isnum_safe(var_value) || var_value < 0)
				return FALSE
			var/new_uses = round(var_value)
			builder.uses = new_uses
			builder.datum_flags |= DF_VAR_EDITED
			uses = new_uses
			datum_flags |= DF_VAR_EDITED
			return TRUE
	. = ..()
/////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/holoparasite_creator/debug
	name = "debug holoparasite injector"
	desc = "If you're seeing this and you're not debugging (or adminbussing), yell at @absolucy"
	debug_mode = TRUE
	allow_multiple = TRUE
	uses = 99
	theme = /datum/holoparasite_theme/tech

/obj/item/holoparasite_creator/debug/preset
	name = "debug preset holoparasite injector"
	max_points = 99

/obj/item/holoparasite_creator/debug/preset/Initialize(mapload)
	. = ..()
	builder.holopara_name = "Radiosonde Castle"
	builder.notes = "Debug Testing Holoparasite"
	builder.saved_stats.damage = max_level
	builder.saved_stats.defense = max_level
	builder.saved_stats.speed = max_level
	builder.saved_stats.potential = max_level
	builder.saved_stats.range = max_level
	builder.calc_points()

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/holoparasite_creator/tech
	name = "willpower crystallization focuser"
	desc = "A mysterious device containing alien tech, capable of crystallizing the willpower of a user into a bluespace being known as a 'holoparasite', which protects and serves its host, although it uses the host as a source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = /datum/holoparasite_theme/tech

/obj/item/holoparasite_creator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/meat.dmi'
	icon_state = "fishfingers"
	theme = /datum/holoparasite_theme/carp
	allow_multiple = TRUE
	allow_changeling = TRUE

/obj/item/holoparasite_creator/wizard
	allow_multiple = TRUE
