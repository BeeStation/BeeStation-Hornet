/datum/action/innate/slime
	check_flags = AB_CHECK_CONSCIOUS
	button_icon = 'icons/hud/actions/actions_slime.dmi'
	button_icon_state = null
	background_icon_state = "bg_alien"
	///Does the ability require a specific slime lifestage?
	var/life_stage_required
	///Does the ability requires the slime to hit max growth?
	var/needs_growth = FALSE
	///Does the ability cost nutrition?
	var/nutrition_cost = 0

/datum/action/innate/slime/is_available(feedback = FALSE)
	. = ..()
	if(!.)
		return FALSE

	var/mob/living/basic/slime/slime_owner = owner

	if(!isnull(life_stage_required) && slime_owner.life_stage != life_stage_required)
		return FALSE

	if(slime_owner.nutrition < nutrition_cost)
		return FALSE

	if(needs_growth && slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		return FALSE
	return TRUE

//Evolving

/datum/action/innate/slime/evolve
	name = "Evolve"
	button_icon_state = "slimegrow"
	desc = "This will let you evolve from baby to adult slime."
	life_stage_required = SLIME_LIFE_STAGE_BABY
	needs_growth = TRUE
	nutrition_cost = SLIME_EVOLUTION_COST

///Turns a baby slime into an adult slime
/datum/action/innate/slime/evolve/on_activate()
	var/mob/living/basic/slime/slime_owner = owner

	if(slime_owner.stat)
		slime_owner.balloon_alert(slime_owner, "unconscious!")
		return
	if(slime_owner.life_stage == SLIME_LIFE_STAGE_ADULT)
		slime_owner.balloon_alert(slime_owner, "already adult!")
		return
	if(slime_owner.amount_grown < SLIME_EVOLUTION_THRESHOLD)
		slime_owner.balloon_alert(slime_owner, "need to grow!")
		return
	if(slime_owner.nutrition < nutrition_cost)
		slime_owner.balloon_alert(slime_owner, "need food!")
		return

	slime_owner.adjust_nutrition(-nutrition_cost)

	slime_owner.set_life_stage(SLIME_LIFE_STAGE_ADULT)
	slime_owner.update_name()
	slime_owner.regenerate_icons()

	slime_owner.amount_grown = 0

//Reproduction

/datum/action/innate/slime/reproduce
	name = "Reproduce"
	button_icon_state = "slimesplit"
	desc = "This will make you split into four slimes."
	life_stage_required = SLIME_LIFE_STAGE_ADULT
	needs_growth = TRUE

/datum/action/innate/slime/reproduce/on_activate()
	var/mob/living/basic/slime/slime_owner = owner
	slime_owner.reproduce()

///Splits the slime into multiple children if possible
/mob/living/basic/slime/proc/reproduce()
	if(stat != CONSCIOUS)
		balloon_alert(src, "not conscious!")
		return

	if(!isopenturf(loc))
		balloon_alert(src, "not here!")
		return

	if(life_stage != SLIME_LIFE_STAGE_ADULT)
		balloon_alert(src, "not adult!")
		return

	if(amount_grown < SLIME_EVOLUTION_THRESHOLD)
		balloon_alert(src, "need growth!")
		return

	var/list/friends_list = list()
	for(var/mob/living/basic/slime/friend in loc)
		if(QDELETED(friend))
			continue
		if(friend == src)
			continue
		friends_list += friend

	overcrowded = length(friends_list) >= SLIME_OVERCROWD_AMOUNT
	if(overcrowded)
		balloon_alert(src, "overcrowded!")
		return

	if(GLOB.total_slimes >= CONFIG_GET(number/max_slimes))
		balloon_alert(src, "too many slimes!")
		return

	var/new_nutrition = floor(nutrition * 0.9)
	var/new_powerlevel = floor(powerlevel * 0.25)
	var/new_life_stage = SLIME_LIFE_STAGE_BABY
	var/child_amount = 3
	var/turf/drop_loc = drop_location()
	var/datum/component/nanites/original_nanites = GetComponent(/datum/component/nanites)

	if(transformeffects & SLIME_EFFECT_GREY)
		child_amount++
	if(transformeffects & SLIME_EFFECT_CERULEAN)
		child_amount = 1
		new_nutrition = floor(nutrition * 0.5)
		new_powerlevel = floor(powerlevel * 0.5)
		new_life_stage = SLIME_LIFE_STAGE_ADULT

	var/list/created_slimes = list()
	var/list/slime_friends = ai_controller?.blackboard[BB_FRIENDS_LIST]

	for(var/i in 1 to child_amount)
		var/child_colour = (transformeffects & SLIME_EFFECT_CERULEAN) ? slime_type.type : get_random_mutation()
		var/mob/living/basic/slime/baby = new(drop_loc, child_colour, new_life_stage)
		created_slimes += baby
		step_away(baby, src)

		for(var/slime_friend in slime_friends)
			baby.befriend(slime_friend)

		baby.transformeffects = transformeffects
		if(transformeffects & SLIME_EFFECT_METAL)
			baby.maxHealth = round(baby.maxHealth * 1.3)
			baby.health = baby.maxHealth
		if(transformeffects & SLIME_EFFECT_RED)
			baby.melee_damage *= 1.1
		if(transformeffects & SLIME_EFFECT_PINK)
			baby.grant_language(/datum/language/common)
			var/datum/language_holder/language_holder = baby.get_language_holder()
			language_holder.selected_language = /datum/language/common
		if(transformeffects & SLIME_EFFECT_BLUESPACE)
			baby.add_verb(/mob/living/basic/slime/proc/teleport)
		if(transformeffects & SLIME_EFFECT_LIGHT_PINK)
			baby.master = master
			baby.set_playable_slime(ROLE_SENTIENCE)

		if(original_nanites)
			baby.AddComponent(/datum/component/nanites, original_nanites.nanite_volume * 0.25)
			SEND_SIGNAL(baby, COMSIG_NANITE_SYNC, original_nanites, TRUE, TRUE, TRUE) //The trues are to copy activation as well

		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.colour)

	if(original_nanites)
		original_nanites.nanite_volume *= 0.25

	var/new_colour = (transformeffects & (SLIME_EFFECT_CERULEAN | SLIME_EFFECT_BLUE)) ? slime_type.type : get_random_mutation()

	// The parent goes last so the children roll their mutation chance off its old value
	created_slimes += src
	set_nutrition(SLIME_STARTING_NUTRITION)
	for(var/mob/living/basic/slime/split_slime as anything in created_slimes)
		if(ckey || (transformeffects & SLIME_EFFECT_CERULEAN))
			split_slime.set_nutrition(new_nutrition) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!
		split_slime.powerlevel = new_powerlevel
		if(mutation_chance)
			split_slime.mutation_chance = clamp(mutation_chance + rand(-5, 5), 0, 100)
		else
			split_slime.mutation_chance = 0

	set_life_stage(new_life_stage)
	set_slime_type(new_colour)
	amount_grown = 0
	mutator_used = FALSE
	cores = initial(cores)
	special_mutation_type = null
	crossbreed_modification = null
	applied_crossbreed_amount = 0

///Picks the colour of a child of this slime
/mob/living/basic/slime/proc/get_random_mutation()
	if(mutation_chance >= 100)
		return /datum/slime_type/rainbow
	if(special_mutation_type)
		return special_mutation_type
	if(!prob(mutation_chance))
		return slime_type.type
	var/list/possible_mutations = slime_type.mutations
	if(transformeffects & SLIME_EFFECT_PYRITE)
		var/datum/slime_type/random_type = possible_slime_types[pick(GLOB.random_slime_types - /datum/slime_type/rainbow)]
		possible_mutations = random_type.mutations
	return pick_weight(possible_mutations)

///Bluespace transformative effect, teleports a random distance at the cost of charge
/mob/living/basic/slime/proc/teleport()
	set category = "Slime"
	set name = "teleport"
	set desc = "teleport to random location"
	if(powerlevel <= 0)
		to_chat(src, span_warning("Not enough power."))
		return
	var/power = rand(1, powerlevel)
	do_teleport(src, get_turf(src), power, asoundin = 'sound/effects/phasein.ogg', channel = TELEPORT_CHANNEL_BLUESPACE)
	powerlevel -= power
