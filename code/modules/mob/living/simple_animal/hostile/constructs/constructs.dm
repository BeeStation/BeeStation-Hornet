/mob/living/simple_animal/hostile/construct
	name = "Construct"
	real_name = "Construct"
	desc = ""
	gender = NEUTER
	mob_biotypes = NONE
	speak_emote = list("hisses")
	response_help_continuous = "thinks better of touching"
	response_help_simple = "think better of touching"
	response_disarm_continuous = "flails at"
	response_disarm_simple = "flail at"
	response_harm_continuous = "punches"
	response_harm_simple = "punch"
	speak_chance = 1
	icon = 'icons/mob/cult.dmi'
	speed = 0
	combat_mode = TRUE
	stop_automated_movement = 1
	status_flags = CANPUSH
	attack_sound = 'sound/weapons/punch1.ogg'
	see_in_dark = 7
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	healable = 0
	faction = list(FACTION_CULT)
	is_flying_animal = TRUE
	no_flying_animation = TRUE
	pressure_resistance = 100
	unique_name = 1
	AIStatus = AI_OFF //normal constructs don't have AI
	loot = list(/obj/item/ectoplasm)
	del_on_death = TRUE
	initial_language_holder = /datum/language_holder/construct
	deathmessage = "collapses in a shattered heap."
	hardattacks = TRUE
	/// List of spells that this construct can cast
	var/list/construct_spells = list()
	/// Flavor text shown to players when they spawn as this construct
	var/playstyle_string = span_bigbold("You are a generic construct!") + "<b> Your job is to not exist, and you should probably adminhelp this.</b>"
	/// The construct's master
	var/master = null
	/// Whether this construct is currently seeking nar nar
	var/seeking = FALSE
	// The original name of the person, passed down by /proc/makeNewConstruct(mob/living/simple_animal/hostile/construct
	var/original_name = null
	// Aghghghshhg
	var/original_real_name = null
	/// Whether this construct can repair other constructs or cult buildings.
	var/can_repair = FALSE
	/// Whether this construct can repair itself. Works independently of can_repair.
	var/can_repair_self = FALSE
	/// Theme controls color. THEME_CULT is red THEME_WIZARD is purple and THEME_HOLY is blue
	var/theme = THEME_CULT

	chat_color = "#FF6262"
	mobchatspan = "cultmobsay"
	discovery_points = 1000

/mob/living/simple_animal/hostile/construct/death(gibbed)
	if(!mind)
		return ..()
	var/obj/item/soulstone/stone = /obj/item/soulstone/anybody
	switch(theme)
		if(THEME_CULT)
			stone = /obj/item/soulstone
		if(THEME_WIZARD)
			stone = /obj/item/soulstone/mystic
		if(THEME_HOLY)
			stone = /obj/item/soulstone/anybody/purified
		else
			stone = /obj/item/soulstone/anybody
	if(original_name)
		name = original_name //set the names so init_shade() uses the right one. I know this is spagetti, but the other solution was adding even more params to init_shade
	if(original_real_name)
		real_name = original_real_name
	stone = new stone(drop_location())
	stone.init_shade(src)
	return ..()

/mob/living/simple_animal/hostile/construct/Initialize(mapload)
	. = ..()
	for(var/spell in construct_spells)
		var/datum/action/new_spell = new spell(src)
		new_spell.Grant(src)

	var/spell_count = 1
	for(var/datum/action/spell as anything in actions)
		if(!(type in construct_spells))
			continue

		var/pos = 2 + spell_count * 31
		if(construct_spells.len >= 4)
			pos -= 31 * (construct_spells.len - 4)
		spell.default_button_position = "6:[pos],4:-2" // Set the default position to this random position
		spell_count++
		update_action_buttons()

	if(icon_state)
		add_overlay("glow_[icon_state]_[theme]")

/mob/living/simple_animal/hostile/construct/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	to_chat(src, playstyle_string)

/mob/living/simple_animal/hostile/construct/examine(mob/user)
	var/pronoun = p_they(TRUE)
	var/plural = p_s()
	var/text_span
	switch(theme)
		if(THEME_CULT)
			text_span = "cult"
		if(THEME_WIZARD)
			text_span = "purple"
		if(THEME_HOLY)
			text_span = "blue"
	. = list("<span class='[text_span]'>This is [icon2html(src, user)] \a <b>[src]</b>!\n[desc]")
	if(health < maxHealth)
		if(health >= maxHealth/2)
			. += span_warning("[pronoun] look[plural] slightly dented.")
		else
			. += span_warning("<b>[pronoun] look[plural] severely dented!</b>")
	. += "</span>"

/mob/living/simple_animal/hostile/construct/attack_animal(mob/living/simple_animal/user, list/modifiers)
	if(!isconstruct(user))
		if(src != user)
			return ..()
		return

	var/mob/living/simple_animal/hostile/construct/doll = user
	if(!doll.can_repair || (doll == src && !doll.can_repair_self))
		return ..()
	if(theme != doll.theme)
		return ..()
	if(health >= maxHealth)
		if(src != user)
			to_chat(user, span_cult("You cannot repair <b>[src]'s</b> dents, as [p_they()] [p_have()] none!"))
		else
			to_chat(user, span_cult("You cannot repair your own dents, as you have none!"))
		return

	adjustHealth(-5)
	if(src != user)
		Beam(user, icon_state="sendbeam", time = 4)
		user.visible_message(
			span_danger("[user] repairs some of \the <b>[src]'s</b> dents."),
			span_cult("You repair some of <b>[src]'s</b> dents, leaving <b>[src]</b> at <b>[health]/[maxHealth]</b> health.")
		)
	else
		user.visible_message(
			span_danger("[user] repairs some of [p_their()] own dents."),
			span_cult("You repair some of your own dents, leaving you at <b>[user.health]/[user.maxHealth]</b> health.")
		)

/mob/living/simple_animal/hostile/construct/narsie_act()
	return

/mob/living/simple_animal/hostile/construct/electrocute_act(shock_damage, source, siemens_coeff = 1, flags = NONE)
	return FALSE

///////////////////////Master-Tracker///////////////////////

/datum/action/innate/seek_master
	name = "Seek your Master"
	desc = "You and your master share a soul-link that informs you of their location"
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	button_icon_state = "cult_mark"
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	var/tracking = FALSE
	var/mob/living/simple_animal/hostile/construct/the_construct


/datum/action/innate/seek_master/Grant(mob/living/C)
	the_construct = C
	..()

/datum/action/innate/seek_master/on_activate()
	var/datum/antagonist/cult/C = owner.mind.has_antag_datum(/datum/antagonist/cult)
	if(!C)
		return
	var/datum/objective/eldergod/summon_objective = locate() in C.cult_team.objectives

	if(summon_objective.check_completion())
		the_construct.master = C.cult_team.blood_target

	if(!the_construct.master)
		to_chat(the_construct, span_cultitalic("You have no master to seek!"))
		the_construct.seeking = FALSE
		return
	if(tracking)
		tracking = FALSE
		the_construct.seeking = FALSE
		to_chat(the_construct, span_cultitalic("You are no longer tracking your master."))
		return
	else
		tracking = TRUE
		the_construct.seeking = TRUE
		to_chat(the_construct, span_cultitalic("You are now tracking your master."))


/datum/action/innate/seek_prey
	name = "Seek the Harvest"
	desc = "None can hide from Nar'Sie, activate to track a survivor attempting to flee the red harvest!"
	button_icon = 'icons/hud/actions/actions_cult.dmi'
	background_icon_state = "bg_demon"
	buttontooltipstyle = "cult"
	button_icon_state = "cult_mark"

/datum/action/innate/seek_prey/on_activate()
	if(GLOB.narsie == null)
		return
	var/mob/living/simple_animal/hostile/construct/harvester/the_construct = owner
	if(the_construct.seeking)
		desc = "None can hide from Nar'Sie, activate to track a survivor attempting to flee the red harvest!"
		button_icon_state = "cult_mark"
		the_construct.seeking = FALSE
		to_chat(the_construct, span_cultitalic("You are now tracking Nar'Sie, return to reap the harvest!"))
		return
	else
		if(LAZYLEN(GLOB.narsie.souls_needed))
			the_construct.master = pick(GLOB.narsie.souls_needed)
			var/mob/living/real_target = the_construct.master //We can typecast this way because Narsie only allows /mob/living into the souls list
			to_chat(the_construct, span_cultitalic("You are now tracking your prey, [real_target.real_name] - harvest [real_target.p_them()]!"))
		else
			to_chat(the_construct, span_cultitalic("Nar'Sie has completed her harvest!"))
			return
		desc = "Activate to track Nar'Sie!"
		button_icon_state = "sintouch"
		the_construct.seeking = TRUE
