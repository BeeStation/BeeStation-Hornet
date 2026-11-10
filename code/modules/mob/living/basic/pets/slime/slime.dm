#define SLIME_EXTRA_SHOCK_COST 3
#define SLIME_EXTRA_SHOCK_THRESHOLD 8
#define SLIME_BASE_SHOCK_PERCENTAGE 10
#define SLIME_SHOCK_PERCENTAGE_PER_LEVEL 7

/mob/living/basic/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	gender = NEUTER
	faction = list(FACTION_SLIME, FACTION_NEUTRAL)

	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"

	attack_sound = 'sound/weapons/bite.ogg'

	//Base physiology

	maxHealth = 150
	health = 150
	speed = 2 //simple_animal speed 1 plus the simple_animal config slowdown
	mob_biotypes = MOB_SLIME
	melee_damage = 15
	can_buckle_to = FALSE
	see_in_dark = NIGHTVISION_FOV_RANGE

	damage_coeff = list(BRUTE = 1, BURN = -1, TOX = 1, CLONE = 1, STAMINA = 0, OXY = 1) //Healed by fire
	unsuitable_cold_damage = 15
	unsuitable_heat_damage = 0
	maximum_survivable_temperature = INFINITY
	habitable_atmos = null

	//Messages

	attack_verb_simple = "glomp"
	attack_verb_continuous = "glomps"

	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"

	//Speech

	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime
	chat_color = "#A6E398"
	mobchatspan = "slimemobsay"

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	//AI controller

	ai_controller = /datum/ai_controller/basic_controller/slime

	//Slime physiology
	///What is our current lifestage?
	var/life_stage = SLIME_LIFE_STAGE_BABY

	///Our slime's current mood
	var/current_mood = SLIME_MOOD_NONE

	///The number of /obj/item/slime_extract's the slime has left inside
	var/cores = 1
	///Chance of mutating, should be between 25 and 35
	var/mutation_chance = 30
	///1-10 controls how much electricity they are generating
	var/powerlevel = SLIME_MIN_POWER
	///Controls how long the slime has been overfed, if 10, grows or reproduces
	var/amount_grown = 0
	/// No hunger
	var/hunger_disabled = FALSE

	///Has a mutator been used on the slime? Only one is allowed
	var/mutator_used = FALSE

	//The datum that handles the slime colour's core and possible mutations
	var/datum/slime_type/slime_type

	///Slime type every non-colour-locked child becomes, set by environmental triggers
	var/datum/slime_type/special_mutation_type
	///Burn damage absorbed since the last Life() tick, turns red slimes crimson
	var/burn_damage_stored = 0

	///Transformative extract effects, passed down to children
	var/transformeffects = SLIME_EFFECT_DEFAULT
	///Who a light pink slime serves
	var/mob/master

	//CORE-CROSSING CODE

	///What cross core modification is being used.
	var/crossbreed_modification
	///How many extracts of the modtype have been applied.
	var/applied_crossbreed_amount = 0

	//AI related traits

	/// Instructions you can give to slimes
	var/static/list/pet_commands = list(
		/datum/pet_command/idle,
		/datum/pet_command/free,
		/datum/pet_command/follow,
		/datum/pet_command/attack/slime,
	)

	/// Our evolve action
	var/datum/action/innate/slime/evolve/evolve_action
	/// Our reproduction action
	var/datum/action/innate/slime/reproduce/reproduce_action

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/basic/slime)

/mob/living/basic/slime/Initialize(mapload, new_type=/datum/slime_type/grey, new_life_stage=SLIME_LIFE_STAGE_BABY)
	GLOB.total_slimes++
	set_slime_type(new_type) //refresh_gravity() in the parent reads it
	. = ..()

	evolve_action = new (src)
	evolve_action.Grant(src)

	reproduce_action = new (src)
	reproduce_action.Grant(src)

	set_life_stage(new_life_stage)
	update_name()
	regenerate_icons()

	set_nutrition(SLIME_STARTING_NUTRITION)

	AddComponent(/datum/component/health_scaling_effects, min_health_slowdown = 2)
	AddComponent(/datum/component/obeys_commands, pet_commands)
	AddComponent(/datum/component/discoverable, TECHWEB_TIER_1_POINTS, get_discover_id = CALLBACK(src, PROC_REF(get_discovery_id)))

	AddElement(/datum/element/ai_retaliate)
	AddElement(/datum/element/basic_health_examine, light_damage_message = "It has some punctures in its flesh!", heavy_damage_message = span_bold("It has severe punctures and tears in its flesh!"), heavy_threshold = 0.4)
	AddElement(/datum/element/footstep, footstep_type = FOOTSTEP_MOB_SLIME)
	AddElement(/datum/element/soft_landing)
	AddElement(/datum/element/trackable)

	add_traits(list(TRAIT_CAN_MOUNT_HUMANS, TRAIT_CANT_RIDE, TRAIT_VENTCRAWLER_ALWAYS), INNATE_TRAIT)

	RegisterSignal(src, COMSIG_HOSTILE_PRE_ATTACKINGTARGET, PROC_REF(on_slime_pre_attack))
	RegisterSignal(src, COMSIG_ATOM_ATTACK_HAND, PROC_REF(on_attack_hand))
	RegisterSignal(src, COMSIG_MOB_UNBUCKLED, PROC_REF(on_unbuckled))

	ai_controller.set_blackboard_key(BB_SLIME_EVOLVE, evolve_action)
	ai_controller.set_blackboard_key(BB_SLIME_REPRODUCE, reproduce_action)

/mob/living/basic/slime/Destroy()
	for(var/obj/machinery/computer/camera_advanced/xenobio/console as anything in SSmachines.get_machines_by_type_and_subtypes(/obj/machinery/computer/camera_advanced/xenobio))
		console.stored_slimes -= src
	if(stat != DEAD)
		GLOB.total_slimes--
	remove_from_spawner_menu()
	master = null
	QDEL_NULL(evolve_action)
	QDEL_NULL(reproduce_action)
	return ..()

///Random slime subtype
/mob/living/basic/slime/random

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/basic/slime/random)

/mob/living/basic/slime/random/Initialize(mapload, new_colour, new_life_stage)
	return ..(mapload, pick(GLOB.random_slime_types), prob(50) ? SLIME_LIFE_STAGE_ADULT : SLIME_LIFE_STAGE_BABY)

///Friendly docile subtype
/mob/living/basic/slime/pet
	hunger_disabled = TRUE

/mob/living/basic/slime/pet/Initialize(mapload, new_colour, new_life_stage)
	. = ..()
	set_pacified_behaviour()

/mob/living/basic/slime/rainbow

/mob/living/basic/slime/rainbow/Initialize(mapload, new_colour, new_life_stage)
	return ..(mapload, /datum/slime_type/rainbow, new_life_stage)

/mob/living/basic/slime/adjust_nutrition(change, forced)
	. = ..()
	nutrition = min(nutrition, SLIME_MAX_NUTRITION)

/mob/living/basic/slime/set_nutrition(set_to, forced = FALSE)
	. = ..()
	nutrition = min(nutrition, SLIME_MAX_NUTRITION)

/mob/living/basic/slime/update_name()
	///Checks if the slime has a generic name, in the format of baby/adult slime (123)
	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	if(slime_name_regex.Find(name))
		var/slime_id = rand(1, 1000)
		name = "[slime_type.colour] [life_stage] slime ([slime_id])"
		real_name = name
	return ..()

/mob/living/basic/slime/regenerate_icons()
	cut_overlays()
	var/icon_text = "[slime_type.colour] [life_stage] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(current_mood && current_mood != SLIME_MOOD_NONE && !stat)
			add_overlay("aslime-[current_mood]")
	else
		icon_state = icon_dead
	..()

/mob/living/basic/slime/get_stat_tab_status()
	var/list/tab_data = ..()
	if(!hunger_disabled)
		tab_data["Nutrition"] = GENERATE_STAT_TEXT("[nutrition]/[SLIME_MAX_NUTRITION]")
		tab_data["Growth"] = GENERATE_STAT_TEXT("[amount_grown]/[SLIME_EVOLUTION_THRESHOLD]")
	tab_data["Power Level"] = GENERATE_STAT_TEXT("[powerlevel]/[SLIME_MAX_POWER]")
	return tab_data

/mob/living/basic/slime/MouseDrop(atom/movable/target_atom as mob|obj)
	if(isliving(target_atom) && target_atom != src && usr == src)
		var/mob/living/food = target_atom
		if(can_feed_on(food))
			start_feeding(food)
	return ..()

///Slimes can hop off mobs they have latched onto
/mob/living/basic/slime/resist_buckle()
	if(isliving(buckled))
		buckled.unbuckle_mob(src,force=TRUE)

//slimes can not pull
/mob/living/basic/slime/start_pulling(atom/movable/moveable_atom, state, force = move_force, supress_message = FALSE)
	return

/mob/living/basic/slime/Process_Spacemove(movement_dir = 0, continuous_move = FALSE)
	return TRUE

/mob/living/basic/slime/refresh_gravity()
	. = ..()
	if(slime_type.colour == SLIME_TYPE_GOLD && has_gravity() > STANDARD_GRAVITY)
		special_mutation_type = /datum/slime_type/cobalt
		visible_message(span_danger("[src] shudders under the intense gravity, flecks of blue swirling in their membrane."))

/mob/living/basic/slime/apply_damage(damage = 0, damagetype = BRUTE, def_zone = null, blocked = 0, forced = FALSE, spread_damage = FALSE, sharpness = NONE, attack_direction = null, attacking_item)
	if(damagetype == BRUTE && !forced && (transformeffects & SLIME_EFFECT_ADAMANTINE))
		blocked += 50
	return ..()

/mob/living/basic/slime/examine(mob/user)
	. = ..()

	switch(powerlevel)
		if(SLIME_MIN_POWER to SLIME_EXTRA_SHOCK_COST)
			. += "It is flickering gently with harmless levels of electrical activity."

		if(SLIME_EXTRA_SHOCK_COST to SLIME_MEDIUM_POWER)
			. += "It is glowing brightly with medium levels electrical activity."


		if(SLIME_MEDIUM_POWER to SLIME_MAX_POWER)
			. += "It is glowing alarmingly with high levels of electrical activity."

		if(SLIME_MAX_POWER)
			. += span_boldwarning("It is radiating with massive levels of electrical activity!")

/mob/living/basic/slime/proc/get_discovery_id()
	return "[slime_type.colour] slime"

/mob/living/basic/slime/give_mind(mob/user)
	. = ..()
	if(. && master)
		mind.store_memory("<b>Serve [master.real_name], your master.</b>")

/mob/living/basic/slime/get_spawner_desc()
	return "be a slime[master ? " under the command of [master.real_name]" : " with free will"]."

/mob/living/basic/slime/get_spawner_flavour_text()
	return "You are a slime born and raised in a laboratory.[master ? " Your duty is to follow the orders of [master.real_name].": " You are not subject to anyone's commands, but the crew may not take kindly to a murderous slime!"]"

///Changes the slime's current life state
/mob/living/basic/slime/proc/set_life_stage(new_life_stage = SLIME_LIFE_STAGE_BABY)
	life_stage = new_life_stage

	switch(life_stage)
		if(SLIME_LIFE_STAGE_BABY)

			health = initial(health)
			maxHealth = initial(maxHealth)

			obj_damage = initial(obj_damage)
			melee_damage = initial(melee_damage)

		if(SLIME_LIFE_STAGE_ADULT)

			health = 200
			maxHealth = 200

			obj_damage = 15
			melee_damage = initial(melee_damage) + 10

	if(transformeffects & SLIME_EFFECT_METAL)
		maxHealth = round(maxHealth * 1.3)
		health = maxHealth
	if(transformeffects & SLIME_EFFECT_RED)
		melee_damage *= 1.1

	ai_controller.set_blackboard_key(BB_SLIME_LIFE_STAGE, life_stage)
	update_action_buttons_icon()

///Sets the slime's type, name and its icons
/mob/living/basic/slime/proc/set_slime_type(new_type)
	slime_type = new new_type

///randomizes the colour of a slime
/mob/living/basic/slime/proc/random_colour()
	set_slime_type(pick(GLOB.random_slime_types))
	update_name()
	regenerate_icons()

///Handles slime attacking restrictions, and any extra effects that would trigger
/mob/living/basic/slime/proc/on_slime_pre_attack(mob/living/basic/slime/our_slime, atom/target, proximity, modifiers)
	SIGNAL_HANDLER

	if(LAZYACCESS(modifiers, RIGHT_CLICK) && isliving(target) && target != src && usr == src)
		if(our_slime.can_feed_on(target))
			our_slime.start_feeding(target)
		return COMPONENT_HOSTILE_NO_ATTACK

	if(isAI(target)) //The aI is not tasty!
		target.balloon_alert(our_slime, "not tasty!")
		return COMPONENT_HOSTILE_NO_ATTACK

	if(our_slime.buckled == target) //If you try to attack the creature you are latched on, you instead cancel feeding
		our_slime.stop_feeding()
		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscyborg(target))
		var/mob/living/silicon/robot/borg_target = target
		borg_target.flash_act()
		do_sparks(5, TRUE, borg_target)
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE
		if(prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			borg_target.apply_damage(our_slime.powerlevel * rand(6, 10), BRUTE, spread_damage = TRUE)
			borg_target.visible_message(span_danger("The [our_slime.name] shocks [borg_target]!"), span_userdanger("The [our_slime.name] shocks you!"))
		else
			borg_target.visible_message(span_danger("The [our_slime.name] fails to hurt [borg_target]!"), span_userdanger("The [our_slime.name] failed to hurt you!"))

		return COMPONENT_HOSTILE_NO_ATTACK

	if(iscarbon(target) && our_slime.powerlevel > SLIME_MIN_POWER)
		var/mob/living/carbon/carbon_target = target
		var/stunprob = our_slime.powerlevel * SLIME_SHOCK_PERCENTAGE_PER_LEVEL + SLIME_BASE_SHOCK_PERCENTAGE  // 17 at level 1, 80 at level 10
		if(!prob(stunprob))
			return NONE // normal attack

		carbon_target.visible_message(span_danger("The [our_slime.name] shocks [carbon_target]!"), span_userdanger("The [our_slime.name] shocks you!"))

		do_sparks(5, TRUE, carbon_target)
		var/power = our_slime.powerlevel + rand(0,3)
		carbon_target.Paralyze(2 SECONDS)
		carbon_target.Knockdown(power * 2 SECONDS)
		carbon_target.set_stutter_if_lower(power * 2 SECONDS)
		if(our_slime.transformeffects & SLIME_EFFECT_ORANGE)
			carbon_target.adjust_fire_stacks(2)
			carbon_target.ignite_mob()
		if (prob(stunprob) && our_slime.powerlevel >= SLIME_EXTRA_SHOCK_COST)
			our_slime.powerlevel = clamp(our_slime.powerlevel - SLIME_EXTRA_SHOCK_COST, SLIME_MIN_POWER, SLIME_MAX_POWER)
			carbon_target.apply_damage(our_slime.powerlevel * rand(6, 10), BURN, spread_damage = TRUE)

	if(isslime(target))
		if(target == our_slime)
			return COMPONENT_HOSTILE_NO_ATTACK
		var/mob/living/basic/slime/target_slime = target
		if(target_slime.buckled)
			target_slime.stop_feeding(silent = TRUE)
			visible_message(span_danger("[our_slime] pulls [target_slime] off!"), \
				span_danger("You pull [target_slime] off!"))
			return NONE // normal attack

		var/is_adult_slime = our_slime.life_stage == SLIME_LIFE_STAGE_ADULT
		if(target_slime.nutrition >= 100) //steal some nutrition. negval handled in life()
			var/stolen_nutrition = min(is_adult_slime ? 90 : 50, target_slime.nutrition)
			target_slime.adjust_nutrition(-stolen_nutrition)
			our_slime.adjust_nutrition(stolen_nutrition)
		if(target_slime.health > 0)
			our_slime.adjustBruteLoss(is_adult_slime ? -20 : -10)


///Spawns a crossed slimecore item
/mob/living/basic/slime/proc/spawn_corecross(mob/living/user)
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, TRUE)
	var/obj/item/slimecross/selected_crossbreed_path
	for(var/crossbreed_path in crossbreeds)
		var/obj/item/slimecross/cross_item = crossbreed_path
		if(initial(cross_item.colour) == slime_type.colour && initial(cross_item.effect) == crossbreed_modification)
			selected_crossbreed_path = cross_item
			break
	if(selected_crossbreed_path)
		var/crosspath_name = "[initial(selected_crossbreed_path.effect)] [initial(selected_crossbreed_path.colour)] extract"
		log_game("A [crosspath_name] was created at [AREACOORD(src)] by [key_name(user)]")
		if(initial(selected_crossbreed_path.dangerous))
			message_admins("A [crosspath_name] was created at [ADMIN_VERBOSEJMP(src)] by [ADMIN_LOOKUPFLW(user)]")
		new selected_crossbreed_path(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

///Makes the slime peaceful and content
/mob/living/basic/slime/proc/set_pacified_behaviour()
	hunger_disabled = TRUE
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, TRUE)
	set_nutrition(SLIME_STARTING_NUTRITION)

///Makes the slime angry and hungry
/mob/living/basic/slime/proc/set_enraged_behaviour()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, TRUE)

///Makes the slime hungry but mostly friendly
/mob/living/basic/slime/proc/set_default_behaviour()
	hunger_disabled = FALSE
	ai_controller?.set_blackboard_key(BB_SLIME_HUNGER_DISABLED, FALSE)
	ai_controller?.set_blackboard_key(BB_SLIME_RABID, FALSE)

/mob/living/basic/slime/proc/make_master(mob/user)
	befriend(user)
	master = user

///Puts the slime in the ghost spawner menu, grouped by master so one owner's slimes share an entry
/mob/living/basic/slime/proc/set_playable_slime(ban_type)
	playable = TRUE
	playable_bantype = ban_type
	LAZYADD(GLOB.mob_spawners["[master ? "[master.real_name]'s slime" : "free [slime_type.colour] slime"]"], src)
	SSmobs.update_spawners()
	if(!key)
		notify_ghosts("[name] can be controlled", source = src)
		SSpoints_of_interest.make_point_of_interest(src)

#undef SLIME_EXTRA_SHOCK_COST
#undef SLIME_EXTRA_SHOCK_THRESHOLD
#undef SLIME_BASE_SHOCK_PERCENTAGE
#undef SLIME_SHOCK_PERCENTAGE_PER_LEVEL
