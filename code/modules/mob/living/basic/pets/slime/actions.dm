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

	if(GLOB.total_slimes >= CONFIG_GET(number/max_slimes))
		balloon_alert(src, "too many slimes!")
		return

	var/list/babies = list()
	var/new_nutrition = round(nutrition * 0.9)
	var/new_powerlevel = round(powerlevel / 4)
	var/new_life_stage = SLIME_LIFE_STAGE_BABY
	var/child_amount = 4
	var/turf/drop_loc = drop_location()
	var/datum/component/nanites/original_nanites = GetComponent(/datum/component/nanites)

	if(transformeffects & SLIME_EFFECT_GREY)
		child_amount++
	if(transformeffects & SLIME_EFFECT_CERULEAN)
		child_amount = 2
		new_nutrition = round(nutrition * 0.5)
		new_powerlevel = round(powerlevel / 2)
		new_life_stage = SLIME_LIFE_STAGE_ADULT

	var/list/slime_friends = ai_controller?.blackboard[BB_FRIENDS_LIST]

	for(var/i in 1 to child_amount)
		var/child_colour = slime_type.type
		var/keep_colour = (transformeffects & SLIME_EFFECT_CERULEAN) || (i == 1 && (transformeffects & SLIME_EFFECT_BLUE))

		if(!keep_colour)
			if(mutation_chance >= 100)
				child_colour = /datum/slime_type/rainbow
			else if(special_mutation_type)
				child_colour = special_mutation_type
			else if(prob(mutation_chance))
				var/list/possible_mutations = slime_type.mutations
				if(transformeffects & SLIME_EFFECT_PYRITE)
					var/random_path = pick(GLOB.random_slime_types - /datum/slime_type/rainbow)
					var/datum/slime_type/random_type = new random_path
					possible_mutations = random_type.mutations
				child_colour = pick_weight(possible_mutations)

		var/mob/living/basic/slime/baby = new(drop_loc, child_colour, new_life_stage)

		baby.transformeffects = transformeffects
		baby.set_life_stage(new_life_stage)

		if(ckey || (transformeffects & SLIME_EFFECT_CERULEAN))
			baby.set_nutrition(new_nutrition) //Player slimes are more robust at spliting. Once an oversight of poor copypasta, now a feature!

		baby.powerlevel = new_powerlevel
		if(i != 1)
			step_away(baby, src)

		for(var/slime_friend in slime_friends)
			baby.befriend(slime_friend)

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

		babies += baby
		baby.mutation_chance = clamp(mutation_chance+(rand(5,-5)),0,100)
		SSblackbox.record_feedback("tally", "slime_babies_born", 1, baby.slime_type.colour)

	var/mob/living/basic/slime/new_slime = pick(babies) // slime that the OG slime will move into.
	new_slime.set_combat_mode(TRUE)

	if(isnull(mind))
		new_slime.key = key
	else
		mind.transfer_to(new_slime)

	qdel(src)

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
