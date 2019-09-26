/datum/guardianbuilder
	var/datum/guardian_stats/saved_stats = new
	var/mob/living/target
	var/guardian_name
	var/max_points = 20
	var/points = 20
	var/mob_name = "Guardian"
	var/theme = "magic"
	var/failure_message = "<span class='holoparasite bold'>..And draw a card! It's...blank? Maybe you should try again later.</span>"
	var/used = FALSE
	var/allow_special = FALSE

/datum/guardianbuilder/New(mob_name, theme, failure_message, max_points, allow_special)
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

/datum/guardianbuilder/ui_interact(mob/user, ui_key, datum/tgui/ui = null, force_open, datum/tgui/master_ui = null, datum/ui_state/state = GLOB.always_state)
	ui = SStgui.try_update_ui(user, src, ui_key, ui, force_open)
	if(!ui)
		ui = new(user, src, ui_key, "guardian", "Build-A-Guardian", 300, 400, master_ui, state)
		ui.set_autoupdate(TRUE)
		ui.open()

/datum/guardianbuilder/ui_data(mob/user)
	. = list()
	.["guardian_name"] = guardian_name
	.["name"] = mob_name
	.["points"] = calc_points()
	.["ratedskills"] = list()
	.["ratedskills"] += list(list(
						name = "Damage",
						level = "[saved_stats.damage]",
					))
	.["ratedskills"] += list(list(
						name = "Defense",
						level = "[saved_stats.defense]"
					))
	.["ratedskills"] += list(list(
						name = "Speed",
						level = "[saved_stats.speed]"
					))
	.["ratedskills"] += list(list(
						name = "Potential",
						level = "[saved_stats.potential]"
					))
	.["ratedskills"] += list(list(
						name = "Range",
						level = "[saved_stats.range]"
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
			guardian_name = stripped_input(usr, "Name your Guardian", ,"", MAX_NAME_LEN)
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
		if("clear_ability_major")
			QDEL_NULL(saved_stats.ability)
		if("ability_major")
			var/ability = text2path(params["path"])
			var/list/types = allow_special ? (subtypesof(/datum/guardian_ability/major) - /datum/guardian_ability/major/special) : (subtypesof(/datum/guardian_ability/major) - typesof(/datum/guardian_ability/major/special))
			if(ispath(ability) && (ability in types)) // no nullspace narsie for you!
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
	if(!user || !istype(user))
		return FALSE
	used = TRUE
	calc_points()
	if(points < 0)
		to_chat("<span class='danger'>You don't have enough points for a Guardian like that!</span>")
		used = FALSE
		return FALSE
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the [mob_name] of [user.real_name]?", ROLE_HOLOPARASITE, null, FALSE, 100, POLL_IGNORE_HOLOPARASITE)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/hostile/guardian/G = new(user, theme)
		if(guardian_name)
			G.real_name = guardian_name
			G.name = guardian_name
			G.custom_name = TRUE
		G.summoner = user
		G.key = C.key
		G.mind.enslave_mind_to_creator(user)
		G.RegisterSignal(G.summoner, COMSIG_MOVABLE_MOVED, /mob/living/simple_animal/hostile/guardian.proc/OnMoved)
		var/datum/antagonist/guardian/S = new
		S.stats = saved_stats
		S.summoner = user.mind.name
		G.mind.add_antag_datum(S)
		G.stats = saved_stats
		G.stats.Apply(G)
		G.show_detail()
		log_game("[key_name(user)] has summoned [key_name(G)], a holoparasite.")
		switch(theme)
			if("tech")
				to_chat(user, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>")
			if("magic")
				to_chat(user, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>")
			if("carp")
				to_chat(user, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been caught!</span>")
		user.verbs += /mob/living/proc/guardian_comm
		user.verbs += /mob/living/proc/guardian_recall
		user.verbs += /mob/living/proc/guardian_reset
		return TRUE
	else
		to_chat(user, "[failure_message]")
		used = FALSE
		return FALSE

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
	var/theme = "magic"
	var/max_points = 15
	var/allowspecial = FALSE

/obj/item/guardiancreator/Initialize()
	. = ..()
	builder = new(mob_name, theme, failure_message, max_points, allowspecial)

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

/obj/item/guardiancreator/rare
	allowspecial = TRUE

/obj/item/guardiancreator/tech
	name = "holoparasite injector"
	desc = "It contains an alien nanoswarm of unknown origin. Though capable of near sorcerous feats via use of hardlight holograms and nanomachines, it requires an organic host as a home base and source of fuel."
	icon = 'icons/obj/syringe.dmi'
	icon_state = "combat_hypo"
	theme = "tech"
	mob_name = "Holoparasite"
	use_message = "<span class='holoparasite'>You start to power on the injector...</span>"
	used_message = "<span class='holoparasite'>The injector has already been used.</span>"
	failure_message = "<span class='holoparasite bold'>...ERROR. BOOT SEQUENCE ABORTED. AI FAILED TO INTIALIZE. PLEASE CONTACT SUPPORT OR TRY AGAIN LATER.</span>"
	ling_failure = "<span class='holoparasite bold'>The holoparasites recoil in horror. They want nothing to do with a creature like you.</span>"

/obj/item/guardiancreator/tech/rare
	allowspecial = TRUE

/obj/item/guardiancreator/adminbus
	max_points = 1500
	allowspecial = TRUE

/obj/item/guardiancreator/carp
	name = "holocarp fishsticks"
	desc = "Using the power of Carp'sie, you can catch a carp from byond the veil of Carpthulu, and bind it to your fleshy flesh form."
	icon = 'icons/obj/food/food.dmi'
	icon_state = "fishfingers"
	theme = "carp"
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

/obj/item/guardiancreator/choose
	allowmultiple = TRUE
	allowspecial = TRUE
	max_points = 20

/obj/item/guardiancreator/wizard/rare
	allowspecial = TRUE