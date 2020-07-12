/datum/guardianbuilder
	var/datum/guardian_stats/saved_stats = new
	var/mob/living/target
	var/guardian_name
	var/guardian_color = "#FFFFFF"
	var/max_points = 20
	var/points = 20
	var/mob_name = "Guardian"
	var/theme = GUARDIAN_MAGIC
	var/failure_message = "<span class='holoparasite bold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/used = FALSE
	var/allow_special = FALSE
	var/debug_mode = FALSE

/datum/guardianbuilder/New(mob_name, theme, failure_message, max_points, allow_special, debug_mode)
	..()
	if(mob_name)
		src.mob_name = mob_name
	if(theme)
		src.theme = theme
	if(failure_message)
		src.failure_message = failure_message
	if(max_points)
		src.max_points = max_points
	src.allow_special = allow_special
	src.debug_mode = debug_mode
	src.guardian_color = rgb(rand(1, 255), rand(1, 255), rand(1, 255))

/datum/guardianbuilder/ui_interact(mob/user, ui_key, datum/tgui/ui = null, force_open, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "Guardian", "Build-A-Guardian", 500, 600, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/guardianbuilder/ui_data(mob/user)
	. = list()
	.["guardian_name"] = guardian_name
	.["guardian_color"] = guardian_color
	.["name"] = mob_name
	.["waiting"] = used
	.["points"] = calc_points()
	.["ratedskills"] = list()
	.["ratedskills"] += list(list(
						name = "Damage",
						desc = "Amount of damage the [mob_name] can deal per hit (melee or projectile).",
						level = saved_stats.damage,
					))
	.["ratedskills"] += list(list(
						name = "Defense",
						desc = "Amount of damage the [mob_name] can absorb instead of transferring.",
						level = saved_stats.defense
					))
	.["ratedskills"] += list(list(
						name = "Speed",
						desc = "How fast the [mob_name] can attack targets.",
						level = saved_stats.speed
					))
	.["ratedskills"] += list(list(
						name = "Potential",
						desc = "Affects the power of the [mob_name]'s primary ability. Some abilities are not affected by this!",
						level = saved_stats.potential
					))
	.["ratedskills"] += list(list(
						name = "Range",
						desc = "How far the the [mob_name] can travel from it's host.",
						level = saved_stats.range
					))
	.["no_ability"] = (!saved_stats.ability || !istype(saved_stats.ability))
	.["melee"] = !saved_stats.ranged
	.["abilities_major"] = list()
	var/list/types = allow_special ? (subtypesof(/datum/guardian_ability/major) - /datum/guardian_ability/major/special) : (subtypesof(/datum/guardian_ability/major) - typesof(/datum/guardian_ability/major/special))
	for(var/ability in types)
		var/datum/guardian_ability/major/GA = new ability
		GA.master_stats = saved_stats
		.["abilities_major"] += list(list(
			name = GA.name,
			desc = GA.desc,
			cost = GA.cost,
			icon = GA.ui_icon,
			selected = istype(saved_stats.ability, ability),
			available = (points >= GA.cost) && GA.CanBuy(),
			path = "[ability]",
			requiem = istype(GA, /datum/guardian_ability/major/special)
		))
	.["abilities_minor"] = list()
	for(var/ability in subtypesof(/datum/guardian_ability/minor))
		var/datum/guardian_ability/minor/GA = new ability
		GA.master_stats = saved_stats
		.["abilities_minor"] += list(list(
			name = GA.name,
			desc = GA.desc,
			cost = GA.cost,
			icon = GA.ui_icon,
			selected = saved_stats.HasMinorAbility(ability),
			available = (points >= GA.cost) && GA.CanBuy(),
			path = "[ability]"
		))

/datum/guardianbuilder/ui_act(action, list/params, datum/tgui/ui, datum/ui_state/state)
	if(..() || used)
		return
	calc_points()
	switch(action)
		if("name")
			guardian_name = params["name"]
		if("set")
			switch(params["name"])
				if("Damage")
					var/lvl = CLAMP(text2num(params["level"]), 1, 5)
					if((points + (saved_stats.damage > 1 ? saved_stats.damage - 1 : 0)) >= lvl - 1 || lvl == 1)
						saved_stats.damage = lvl
					. = TRUE
				if("Defense")
					var/lvl = CLAMP(text2num(params["level"]), 1, 5)
					if((points + (saved_stats.defense > 1 ? saved_stats.defense - 1 : 0)) >= lvl - 1 || lvl == 1)
						saved_stats.defense = lvl
					. = TRUE
				if("Speed")
					var/lvl = CLAMP(text2num(params["level"]), 1, 5)
					if((points + (saved_stats.speed > 1 ? saved_stats.speed - 1 : 0)) >= lvl - 1 || lvl == 1)
						saved_stats.speed = lvl
					. = TRUE
				if("Potential")
					var/lvl = CLAMP(text2num(params["level"]), 1, 5)
					if((points + (saved_stats.potential > 1 ? saved_stats.potential - 1 : 0)) >= lvl - 1 || lvl == 1)
						saved_stats.potential = lvl
					. = TRUE
				if("Range")
					var/lvl = CLAMP(text2num(params["level"]), 1, 5)
					if((points + (saved_stats.range > 1 ? saved_stats.range - 1 : 0)) >= lvl - 1 || lvl == 1)
						saved_stats.range = lvl
					. = TRUE
		if("color")
			var/color = input(usr, "What would you like your guardian's color to be?", "Choose Your Color", "#ffffff") as color|null
			if(color)
				guardian_color = color
		if("clear_ability_major")
			QDEL_NULL(saved_stats.ability)
		if("ability_major")
			var/ability = text2path(params["path"])
			var/list/types = allow_special ? (subtypesof(/datum/guardian_ability/major) - /datum/guardian_ability/major/special) : (subtypesof(/datum/guardian_ability/major) - typesof(/datum/guardian_ability/major/special))
			if(ispath(ability))
				if(saved_stats.ability && saved_stats.ability.type == ability)
					QDEL_NULL(saved_stats.ability)
				else if(ability in types) // no nullspace narsie for you!
					QDEL_NULL(saved_stats.ability)
					saved_stats.ability = new ability
					saved_stats.ability.master_stats = saved_stats
		if("ability_minor")
			var/ability = text2path(params["path"])
			if(ispath(ability) && (ability in subtypesof(/datum/guardian_ability/minor))) // no nullspace narsie for you!
				if(saved_stats.HasMinorAbility(ability))
					saved_stats.TakeMinorAbility(ability)
				else
					saved_stats.AddMinorAbility(ability)
		if("spawn")
			. = spawn_guardian(usr)
		if("reset")
			QDEL_NULL(saved_stats)
			saved_stats = new
			. = TRUE
		if("ranged")
			if(points >= 3)
				saved_stats.ranged = TRUE
		if("melee")
			saved_stats.ranged = FALSE

/datum/guardianbuilder/proc/calc_points()
	points = max_points
	if(saved_stats.damage > 1)
		points -= saved_stats.damage - 1
	if(saved_stats.defense > 1)
		points -= saved_stats.defense - 1
	if(saved_stats.potential > 1)
		points -= saved_stats.potential - 1
	if(saved_stats.speed > 1)
		points -= saved_stats.speed - 1
	if(saved_stats.range > 1)
		points -= saved_stats.range - 1
	if(saved_stats.ranged)
		points -= 3
	if(saved_stats.ability)
		points -= saved_stats.ability.cost
	for(var/datum/guardian_ability/minor/minor in saved_stats.minor_abilities)
		points -= minor.cost
	return points

/datum/guardianbuilder/proc/spawn_guardian(mob/living/user)
	if(!user || !iscarbon(user) || !user.mind)
		return FALSE
	used = TRUE
	calc_points()
	if(points < 0)
		to_chat("<span class='danger'>You don't have enough points for a Guardian like that!</span>")
		used = FALSE
		return FALSE
	// IMPORTANT - if we're debugging, the user gets thrown into the stand
	var/list/mob/dead/observer/candidates = debug_mode ? list(user) : pollGhostCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_HOLOPARASITE, null, FALSE, 100, POLL_IGNORE_HOLOPARASITE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/hostile/guardian/G = new(user, theme, guardian_color)
		if(guardian_name)
			G.real_name = guardian_name
			G.name = guardian_name
		G.summoner = user.mind
		G.key = C.key
		G.mind.enslave_mind_to_creator(user)
		G.RegisterSignal(user, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
		G.RegisterSignal(user, COMSIG_LIVING_REVIVE, /mob/living/simple_animal/hostile/guardian.proc/Reviveify)
		G.RegisterSignal(user.mind, COMSIG_MIND_TRANSFER_TO, /mob/living/simple_animal/hostile/guardian.proc/OnMindTransfer)
		var/datum/antagonist/guardian/S = new
		S.stats = saved_stats
		S.summoner = user.mind
		G.mind.add_antag_datum(S)
		G.stats = saved_stats
		G.stats.Apply(G)
		G.show_detail()
		log_game("[key_name(user)] has summoned [key_name(G)], a holoparasite.")
		switch(theme)
			if(GUARDIAN_TECH)
				to_chat(user, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> is now online!</span>")
			if(GUARDIAN_MAGIC)
				to_chat(user, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been summoned!</span>")
			if(GUARDIAN_CARP)
				to_chat(user, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been caught!</span>")
			if(GUARDIAN_HIVE)
				to_chat(user, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been created from the core!</span>")
		user.verbs += /mob/living/proc/guardian_comm
		user.verbs += /mob/living/proc/guardian_recall
		user.verbs += /mob/living/proc/guardian_reset
		return TRUE
	else
		to_chat(user, "[failure_message]")
		used = FALSE
		return FALSE

// the item
/obj/item/guardiancreator
	name = "deck of tarot cards"
	desc = "An enchanted deck of tarot cards, rumored to be a source of unimaginable power."
	icon = 'icons/obj/toy.dmi'
	icon_state = "deck_syndicate_full"
	var/datum/guardianbuilder/builder
	var/use_message = "<span class='holoparasite'>You shuffle the deck...</span>"
	var/used_message = "<span class='holoparasite'>All the cards seem to be blank now.</span>"
	var/failure_message = "<span class='holoparasite bold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/ling_failure = "<span class='holoparasite bold'>The deck refuses to respond to a souless creature such as you.</span>"
	var/random = TRUE
	var/allowmultiple = FALSE
	var/allowling = TRUE
	var/allowguardian = FALSE
	var/mob_name = "Guardian Spirit"
	var/theme = GUARDIAN_MAGIC
	var/max_points = 15
	var/allowspecial = FALSE
	var/debug_mode = FALSE

/obj/item/guardiancreator/Initialize()
	. = ..()
	builder = new(mob_name, theme, failure_message, max_points, allowspecial, debug_mode)

/obj/item/guardiancreator/attack_self(mob/living/user)
	if(isguardian(user) && !allowguardian)
		to_chat(user, "<span class='holoparasite'>[mob_name] chains are not allowed.</span>")
		return
	var/list/guardians = user.hasparasites()
	if(LAZYLEN(guardians) && !allowmultiple)
		to_chat(user, "<span class='holoparasite'>You already have a [mob_name]!</span>")
		return
	if(user.mind && user.mind.has_antag_datum(/datum/antagonist/changeling) && !allowling)
		to_chat(user, "[ling_failure]")
		return
	if(builder.used)
		to_chat(user, "[used_message]")
		return
	builder.ui_interact(user)

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/guardiancreator/debug
	desc = "If you're seeing this and you're not debugging, yell at @Zyzarda"
	debug_mode = TRUE
	allowspecial = TRUE

/////////////////////////////////////////////////////////////////////////////////////////////////////////

/obj/item/guardiancreator/rare
	allowspecial = TRUE

/obj/item/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = GUARDIAN_TECH
	mob_name = "Holoparasite"
	use_message = "<span class='holoparasite'>You start to power on the injector...</span>"
	used_message = "<span class='holoparasite'>The injector has already been used.</span>"
	failure_message = "<span class='holoparasite bold'>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</span>"
	ling_failure = "<span class='holoparasite bold'>The holoparasites recoil in horror. They want nothing to do with a creature like you.</span>"

/obj/item/guardiancreator/tech/rare
	allowspecial = TRUE

/obj/item/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fishfingers"
	theme = GUARDIAN_CARP
	mob_name = "Holocarp"
	use_message = "<span class='holoparasite'>You put the fishsticks in your mouth...</span>"
	used_message = "<span class='holoparasite'>Someone's already taken a bite out of these fishsticks! Ew.</span>"
	failure_message = "<span class='holoparasite bold'>You couldn't catch any carp spirits from the seas of Lake Carp. Maybe there are none, maybe you fucked up.</span>"
	ling_failure = "<span class='holoparasite bold'>Carp'sie is fine with changelings, so you shouldn't be seeing this message.</span>"
	allowmultiple = TRUE
	allowling = TRUE

/obj/item/guardiancreator/carp/rare
	allowspecial = TRUE

/obj/item/guardiancreator/wizard
	allowmultiple = TRUE

/obj/item/guardiancreator/wizard/rare
	allowspecial = TRUE

/obj/item/guardiancreator/hive
	name = "mysterious core"
	desc = "All that remains of a hivelord. It has a mysterious aura around it..."
	icon = 'icons/obj/surgery.dmi'
	icon_state = "roro core 2"
	theme = GUARDIAN_HIVE
	mob_name = "Hivelord"
	use_message = "<span class='holoparasite'>You place the core near your heart...</span>"
	used_message = "<span class='holoparasite'>This core seems to have decayed and doesn't work anymore...</span>"
	failure_message = "<span class='holoparasite bold'>You couldn't gather any mass with the core, maybe try again later.</span>"
	ling_failure = "<span class='holoparasite bold'>Even the dark energies seem to not want to be near your horrific body.</span>"

/obj/item/guardiancreator/hive/rare
	allowspecial = TRUE
