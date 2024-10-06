#define SPIDER_IDLE 0
#define SPINNING_WEB 1
#define LAYING_EGGS 2
#define MOVING_TO_TARGET 3
#define SPINNING_COCOON 4
#define INTERACTION_SPIDER_KEY "spider_key"

/mob/living/simple_animal/hostile/poison
	mobchatspan = "researchdirector"
	var/poison_per_bite = 5
	var/poison_type = /datum/reagent/toxin

/mob/living/simple_animal/hostile/poison/AttackingTarget()
	. = ..()
	if(. && isliving(target))
		var/mob/living/L = target
		if(poison_per_bite && L.reagents)
			L.reagents.add_reagent(poison_type, poison_per_bite)

//The base "Spider" mob
/mob/living/simple_animal/hostile/poison/giant_spider
	name = "giant spider"
	desc = "Furry and black, it makes you shudder to look at it. This one has deep red eyes."
	icon_state = "tarantula"
	icon_living = "tarantula"
	icon_dead = "tarantula_dead"
	mob_biotypes = list(MOB_ORGANIC, MOB_BUG)
	speak_emote = list("chitters")
	emote_hear = list("chitters")
	speak_chance = 5
	speed = 1
	turns_per_move = 5
	see_in_dark = 10
	butcher_results = list(/obj/item/food/meat/slab/spider = 2, /obj/item/food/spiderleg = 8)
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "gently pushes aside"
	response_disarm_simple = "gently push aside"
	initial_language_holder = /datum/language_holder/spider // Speaks buzzwords, understands buzzwords and common
	maxHealth = 85
	health = 85
	obj_damage = 25
	melee_damage = 15
	poison_per_bite = 3
	poison_type = /datum/reagent/toxin/spidervenom
	faction = list("spiders")
	pass_flags = PASSTABLE
	move_to_delay = 4
	ventcrawler = VENTCRAWLER_ALWAYS
	attack_verb_continuous = "bites"
	attack_verb_simple = "bite"
	attack_sound = 'sound/weapons/bite.ogg'
	unique_name = 1
	gold_core_spawnable = HOSTILE_SPAWN
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	footstep_type = FOOTSTEP_MOB_CLAW
	sentience_type = SENTIENCE_OTHER // not eligible for sentience potions
	var/busy = SPIDER_IDLE // What a spider's doing
	//var/obj/effect/proc_holder/spider/wrap/lesser/lesserwrap // Wrap action
	var/web_speed = 1 // How quickly a spider lays down webs (percentage)
	var/mob/master // The spider's master, used by sentience
	var/onweb_speed
	var/atom/movable/cocoon_target

	//Special spider variables defined here to prevent duplicate procs
	var/mob/living/simple_animal/hostile/poison/giant_spider/heal_target //used by nurses for healing
	var/fed = 0 //used by broodmothers to track food
	var/enriched_fed = 0
	var/datum/action/innate/spider/lay_eggs/lay_eggs //the ability to lay eggs, granted to broodmothers
	var/datum/team/spiders/spider_team = null //utilized by AI controlled broodmothers to pass antag team info onto their eggs without a mind
	var/datum/action/innate/spider/lay_web/webbing
	var/datum/action/cooldown/wrap/wrap
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	discovery_points = 1000
	gold_core_spawnable = NO_SPAWN  //Spiders are introduced to the rounds through two types of antagonists

/mob/living/simple_animal/hostile/poison/giant_spider/Initialize(mapload)
	. = ..()
	webbing = new(src)
	webbing.Grant(src)
	wrap = new(src)
	wrap.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/mind_initialize()
	. = ..()
	if(!mind.has_antag_datum(/datum/antagonist/spider))
		var/datum/antagonist/spider/spooder = new
		if(!spider_team)
			spooder.create_team()
			spider_team = spooder.spider_team
		mind.add_antag_datum(spooder, spider_team)

/mob/living/simple_animal/hostile/poison/giant_spider/Destroy()
	webbing.Remove()
	GLOB.spidermobs -= src
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/Login()
	. = ..()
	if(!. || !client)
		return FALSE
	SSmove_manager.stop_looping(src) // Just in case the AI's doing anything when we give them the mind
	GLOB.spidermobs[src] = TRUE

/mob/living/simple_animal/hostile/poison/giant_spider/give_mind(mob/user)
	..()
	var/datum/antagonist/spider/spider_antag = mind?.has_antag_datum(/datum/antagonist/spider)
	if(spider_antag.spider_team.directive)
		log_game("[key_name(src)] took control of [name] with the objective: '[spider_antag.spider_team.directive]'.")
	return TRUE

// Allows spiders to take damage slowdown. 2 max, but they don't start moving slower until under 75% health
/mob/living/simple_animal/hostile/poison/giant_spider/updatehealth()
	. = ..()
	if(HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)
		return
	var/health_percentage = round((health / maxHealth) * 100)
	if(health_percentage <= 75)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown, multiplicative_slowdown = ((100 - health_percentage) / 50))
	else
		remove_movespeed_modifier(/datum/movespeed_modifier/damage_slowdown)

// Handles faster movement on webs
// This is triggered after the first time a spider steps on/off a web, making web-peeking using this harder
/mob/living/simple_animal/hostile/poison/giant_spider/Moved(atom/oldloc, dir)
	. = ..()
	if(onweb_speed == null)
		return
	var/turf/T = get_turf(src)
	if(locate(/obj/structure/spider/stickyweb) in T)
		set_varspeed(onweb_speed)
		move_to_delay = max(2, initial(move_to_delay)-1) //Clamps AI at a maximum speed equivalent to that of vipers
	else
		set_varspeed(initial(speed))
		move_to_delay = initial(move_to_delay)

// Handles webspinning of all varieties for spiders
/mob/living/simple_animal/hostile/poison/giant_spider/handle_automated_movement()
	..()
	if(AIStatus == AI_IDLE)
		if(!busy)
			var/obj/structure/spider/stickyweb/W = locate() in get_turf(src)
			if(!W)
				webbing.Activate()
			else
				var/list/can_see = view(10, src)
				for(var/obj/O in can_see)
					if(O.anchored)
						continue //Can't wrap anchored objects
					if(isitem(O) || isstructure(O) || ismachinery(O))
						cocoon_target = O
						busy = MOVING_TO_TARGET
						Goto(O, move_to_delay)
						addtimer(CALLBACK(src, PROC_REF(GiveUp), O), 20 SECONDS)
		if(cocoon_target && get_dist(src, cocoon_target) <= 1)
			cocoon()
			GiveUp() //if something interrupts the attempt to cocoon, there is probably an enemy entity nearby and we need to reset

// Handles cocooning items and food
/mob/living/simple_animal/hostile/poison/giant_spider/proc/cocoon()
	if(stat != DEAD && cocoon_target && !cocoon_target.anchored)
		if(cocoon_target == src)
			to_chat(src, "<span class='warning'>You can't wrap yourself!</span>")
			return
		if(istype(cocoon_target, /mob/living/simple_animal/hostile/poison/giant_spider))
			to_chat(src, "<span class='warning'>You can't wrap other spiders!</span>")
			return
		if(!Adjacent(cocoon_target))
			to_chat(src, "<span class='warning'>You can't reach [cocoon_target]!</span>")
			return
		if(busy == SPINNING_COCOON)
			to_chat(src, "<span class='warning'>You're already spinning a cocoon!</span>")
			return //we're already doing this, don't cancel out or anything
		if(isliving(cocoon_target))
			if(!istype(src, /mob/living/simple_animal/hostile/poison/giant_spider/broodmother))
				to_chat(src, "<span class='warning'>You should bring food to your broodmother!</span>")
				return
			var/mob/living/M = cocoon_target
			M.attacked_by(null, src)
		busy = SPINNING_COCOON
		visible_message("<span class='notice'>[src] begins to secrete a sticky substance around [cocoon_target].</span>","<span class='notice'>You begin wrapping [cocoon_target] into a cocoon.</span>")
		stop_automated_movement = TRUE
		SSmove_manager.stop_looping(src)
		if(do_after(src, 50, target = cocoon_target))
			if(busy == SPINNING_COCOON)
				var/obj/structure/spider/cocoon/C = new(cocoon_target.loc)
				if(isliving(cocoon_target))
					var/mob/living/L = cocoon_target
					if(L.stat != DEAD)
						L.investigate_log("has been killed by being wrapped in a cocoon.", INVESTIGATE_DEATHS)
						L.death() //If it's not already dead, we want it dead regardless of nourishment
					if(L.blood_volume >= BLOOD_VOLUME_BAD && !isipc(L)) //IPCs and drained mobs are not nourishing.
						L.blood_volume = 0 //Remove all fluids from this mob so they are no longer nourishing.
						health = maxHealth //heal up from feeding.
						if(istype(L,/mob/living/carbon/human))
							enriched_fed++ //it is a humanoid, and is very nourishing
						else
							fed++ //it is not a humanoid, but still has nourishment
						if(lay_eggs)
							lay_eggs.UpdateButtons(TRUE)
						visible_message("<span class='danger'>[src] sticks a proboscis into [L] and sucks a viscous substance out.</span>","<span class='notice'>You suck the nutriment out of [L], feeding you enough to lay a cluster of eggs.</span>")
					else
						to_chat(src, "<span class='warning'>[L] cannot sate your hunger!</span>")
				cocoon_target.forceMove(C)

				if(cocoon_target.density || ismob(cocoon_target))
					C.icon_state = pick("cocoon_large1","cocoon_large2","cocoon_large3")
	cocoon_target = null
	busy = SPIDER_IDLE
	stop_automated_movement = FALSE

/mob/living/simple_animal/hostile/poison/giant_spider/proc/do_action()
	stop_automated_movement = FALSE
	SSmove_manager.stop_looping(src)

/mob/living/simple_animal/hostile/poison/giant_spider/AttackingTarget()
	if(is_busy)
		return
	var/mob/target_mob = target
	if(!istype(target_mob))
		return ..()
	// Spider IFF
	if(istype(target, /mob/living/simple_animal/hostile/poison/giant_spider))
		visible_message("<span class='notice'>[src] nuzzles [target_mob.name]!</span>", \
			"<span class='notice'>You nuzzle [target_mob.name]!</span>", null, COMBAT_MESSAGE_RANGE)
		return
	return ..()

/mob/living/simple_animal/hostile/poison/giant_spider/proc/GiveUp()
	if(busy == MOVING_TO_TARGET)
		cocoon_target = null
		heal_target = null
		busy = FALSE
		stop_automated_movement = FALSE
		SSmove_manager.stop_looping(src)


// Nurses heal other spiders and maintain the core of the nest.
/mob/living/simple_animal/hostile/poison/giant_spider/nurse
	name = "nurse"
	desc = "Furry and black, it makes you shudder to look at it. This one has brilliant green eyes."
	icon_state = "nurse"
	icon_living = "nurse"
	icon_dead = "nurse_dead"
	gender = FEMALE
	maxHealth = 45
	health = 45
	melee_damage = 10
	poison_per_bite = 3
	speed = 1
	onweb_speed = 0
	web_speed = 0.33
	///The health HUD applied to the mob.
	var/health_hud = DATA_HUD_MEDICAL_ADVANCED
	var/datum/action/innate/spider/set_directive/set_directive

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/Initialize(mapload)
	. = ..()
	var/datum/atom_hud/datahud = GLOB.huds[health_hud]
	datahud.add_hud_to(src)

// Allows nurses to heal other spiders if they're adjacent
/mob/living/simple_animal/hostile/poison/giant_spider/nurse/AttackingTarget()
	if(DOING_INTERACTION(src, INTERACTION_SPIDER_KEY))
		return
	var/mob/target_mob = target
	if(!istype(target_mob))
		return ..()
	if(!istype(target, /mob/living/simple_animal/hostile/poison/giant_spider))
		return ..()
	var/mob/living/simple_animal/hostile/poison/giant_spider/hurt_spider = target
	if(hurt_spider.health >= hurt_spider.maxHealth)
		to_chat(src, "<span class='warning'>You can't find any wounds to wrap up.</span>")
		return ..() // IFF is handled in parent
	if(hurt_spider == src)
		visible_message("<span class='notice'>[src] begins wrapping their wounds.</span>","<span class='notice'>You begin wrapping your wounds.</span>")
	else
		visible_message("<span class='notice'>[src] begins wrapping the wounds of [hurt_spider].</span>","<span class='notice'>You begin wrapping the wounds of [hurt_spider].</span>")
	if(!do_after(src, 2 SECONDS, target = hurt_spider))
		return

	hurt_spider.heal_overall_damage(20, 20)
	new /obj/effect/temp_visual/heal(get_turf(hurt_spider), "#80F5FF")
	visible_message(
		span_notice("[src] wraps the wounds of [hurt_spider]."),
		span_notice("You wrap the wounds of [hurt_spider]."),
	)

//Handles AI nurse healing when spiders are idle
/mob/living/simple_animal/hostile/poison/giant_spider/nurse/handle_automated_movement()
	if(AIStatus == AI_IDLE)
		if(!busy)
			var/list/can_see = view(10, src)
			for(var/mob/living/C in can_see)
				if(istype(C, /mob/living/simple_animal/hostile/poison/giant_spider) && C.health < C.maxHealth)
					heal_target = C
					busy = MOVING_TO_TARGET
					Goto(C, move_to_delay)
					addtimer(CALLBACK(src, PROC_REF(GiveUp)), 20 SECONDS) //to prevent infinite chases
		if(heal_target && get_dist(src, heal_target) <= 1)
			UnarmedAttack(heal_target)
			if(!heal_target || heal_target.health >= heal_target.maxHealth)
				GiveUp()
	..() //Do normal stuff after giving priority to healing attempts

//Broodmothers have well rounded stats and are able to lay eggs, but somewhat slow.
/mob/living/simple_animal/hostile/poison/giant_spider/broodmother
	name = "broodmother"
	desc = "Furry and black, it makes you shudder to look at it. This one has scintillating green eyes."
	icon_state = "broodmother"
	icon_living = "broodmother"
	icon_dead = "broodmother_dead"
	maxHealth = 90
	health = 90
	melee_damage = 15
	poison_per_bite = 5
	speed = 2
	onweb_speed = 1
	web_speed = 0.25

	gender = FEMALE
	butcher_results = list(
		/obj/item/food/meat/slab/spider = 2,
		/obj/item/food/spiderleg = 8,
		/obj/item/food/spidereggs = 4
	)
	var/datum/action/innate/spider/set_directive/set_directive
	/// Allows the spider to use spider comms
	var/datum/action/innate/spider/comm/letmetalkpls

/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/Initialize(mapload)
	. = ..()
	wrap = new
	wrap.Grant()
	lay_eggs = new
	lay_eggs.Grant(src)
	letmetalkpls = new
	letmetalkpls.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/Destroy()
	wrap.Remove()
	QDEL_NULL(lay_eggs)
	QDEL_NULL(letmetalkpls)
	return ..()

//Handles Broodmother feeding and egglaying
/mob/living/simple_animal/hostile/poison/giant_spider/broodmother/handle_automated_movement()
	if(AIStatus == AI_IDLE && !busy)
		var/list/can_see = view(10, src)
		for(var/mob/living/C in can_see)
			if(istype(C, /mob/living/simple_animal/hostile/poison/giant_spider))
				continue //Not interested in other spiders for food
			else if(C.stat && !C.anchored)
				cocoon_target = C
				busy = MOVING_TO_TARGET
				Goto(C, move_to_delay)
				addtimer(CALLBACK(src, PROC_REF(GiveUp), C), 20 SECONDS)
		if(prob(10) && lay_eggs.IsAvailable()) //so eggs aren't always placed immediately and directly by corpses
			lay_eggs.Activate()
	..()

// Hunters are the most independent of the spiders, not relying on web and having a bit more damage and venom at the cost of health.
// They are intended to bring prey back from outside of the web.
/mob/living/simple_animal/hostile/poison/giant_spider/hunter
	name = "hunter"
	desc = "Furry and black, it makes you shudder to look at it. This one has sparkling purple eyes."
	icon_state = "hunter"
	icon_living = "hunter"
	icon_dead = "hunter_dead"
	maxHealth = 65
	health = 65
	melee_damage = 18
	poison_per_bite = 5
	move_to_delay = 3
	speed = 0

// Vipers are physically very weak and fragile, but also very fast and inject a lot of venom.
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper
	name = "viper"
	desc = "Furry and black, it makes you shudder to look at it. This one has effervescent purple eyes."
	icon_state = "viper"
	icon_living = "viper"
	icon_dead = "viper_dead"
	maxHealth = 35
	health = 35
	melee_damage = 8
	poison_per_bite = 8
	onweb_speed = -1
	move_to_delay = 2
	poison_type = /datum/reagent/toxin/venom

//Guards are really tanky brutes that rely on force more than venom but perform very poorly away from webs.
/mob/living/simple_animal/hostile/poison/giant_spider/guard
	name = "guard"
	desc = "Furry and black, it makes you shudder to look at it. This one has abyssal red eyes."
	icon_state = "guard"
	icon_living = "guard"
	icon_dead = "guard_dead"
	maxHealth = 125
	health = 125
	melee_damage = 22
	poison_per_bite = 1 //rely on brute force, but they're still spiders.
	obj_damage = 50
	move_to_delay = 5
	speed = 3
	web_speed = 1
	onweb_speed = 0
	status_flags = NONE
	mob_size = MOB_SIZE_LARGE
	web_speed = 0.5
	var/datum/action/innate/spider/block/block //Guards are huge and can block doorways

/mob/living/simple_animal/hostile/poison/giant_spider/guard/Initialize(mapload)
	. = ..()
	block = new
	block.Grant(src)

/mob/living/simple_animal/hostile/poison/giant_spider/guard/Destroy()
	QDEL_NULL(block)
	return ..()

// Ice spiders - for when you want a spider that really doesn't care about atmos
/mob/living/simple_animal/hostile/poison/giant_spider/ice
	name = "ice spider"
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/nurse/ice
	name = "ice nurse"
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

/mob/living/simple_animal/hostile/poison/giant_spider/hunter/ice
	name = "ice hunter"
	maxbodytemp = 1500
	poison_type = /datum/reagent/consumable/frostoil
	color = rgb(114,228,250)

// Buffed spider for wizards to use
/mob/living/simple_animal/hostile/poison/giant_spider/hunter/viper/wizard
	maxHealth = 100
	health = 100

// SPIDER ACTIONS/PROCS

/datum/action/innate/spider
	icon_icon = 'icons/hud/actions/actions_animal.dmi'
	background_icon_state = "bg_alien"
	check_flags = AB_CHECK_CONSCIOUS

/datum/action/innate/spider/lay_web
	name = "Spin Web"
	desc = "Spin a web to slow down potential prey."
	button_icon_state = "lay_web"

/datum/action/innate/spider/lay_web/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner

	if(!isturf(spider.loc))
		return
	var/turf/target_turf = get_turf(spider)

	var/webs = 0
	for(var/obj/structure/spider/stickyweb/web in target_turf)
		webs++
	if(webs >= MAX_WEBS_PER_TILE)
		to_chat(spider, "<span class='warning'>You can't fit more web here!</span>")
		return

	if(spider.busy != SPINNING_WEB)
		spider.busy = SPINNING_WEB
		spider.visible_message("<span class='notice'>[spider] begins to secrete a sticky substance.</span>","<span class='notice'>You begin to lay a web.</span>")
		spider.stop_automated_movement = TRUE
		if(do_after(spider, 40 * spider.web_speed, target = target_turf))
			new /obj/structure/spider/stickyweb(target_turf)
		spider.busy = SPIDER_IDLE
		spider.stop_automated_movement = FALSE
	else
		to_chat(spider, "<span class='warning'>You're already spinning a web!</span>")

/datum/action/innate/spider/block
	name = "Block Passage"
	desc = "Use your massive size to prevent others from passing by you."
	button_icon_state = "block"

/datum/action/innate/spider/block/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider))
		return
	if(owner.a_intent == INTENT_HELP)
		owner.a_intent = INTENT_HARM
		owner.visible_message("<span class='notice'>[owner] widens its stance and blocks passage around it.</span>","<span class='notice'>You are now blocking others from passing around you.</span>")
	else
		owner.a_intent = INTENT_HELP
		owner.visible_message("<span class='notice'>[owner] loosens up and allows others to pass again.</span>","<span class='notice'>You are no longer blocking others from passing around you.</span>")

/datum/action/innate/spider/lay_web/IsAvailable()
	. = ..()
	if(!.)
		return FALSE

	if(DOING_INTERACTION(owner, INTERACTION_SPIDER_KEY))
		return FALSE
	if(!isspider(owner))
		return FALSE

	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner
	var/obj/structure/spider/stickyweb/web = locate() in get_turf(spider)
	if(web && (istype(web, /obj/structure/spider/stickyweb)))
		to_chat(owner, span_warning("There's already a web here!"))
		return FALSE

	if(!isturf(spider.loc))
		return FALSE

	return TRUE

/datum/action/innate/spider/lay_web/Activate()
	var/turf/spider_turf = get_turf(owner)
	var/mob/living/simple_animal/hostile/poison/giant_spider/spider = owner
	var/obj/structure/spider/stickyweb/web = locate() in spider_turf
	if(web)
		spider.visible_message(
			span_notice("[spider] begins to pack more webbing onto the web."),
			span_notice("You begin to seal the web."),
		)
	else
		spider.visible_message(
			span_notice("[spider] begins to secrete a sticky substance."),
			span_notice("You begin to lay a web."),
		)

	spider.stop_automated_movement = TRUE

	if(do_after(spider, 4 SECONDS * spider.web_speed, target = spider_turf))
		if(spider.loc == spider_turf)
			new /obj/structure/spider/stickyweb(spider_turf)

	spider.stop_automated_movement = FALSE

/datum/action/cooldown/wrap
	name = "Wrap"
	desc = "Wrap something or someone in a cocoon. If it's a human or similar species, \
		you'll also consume them, allowing you to lay enriched eggs."
	background_icon_state = "bg_alien"
	icon_icon = 'icons/hud/actions/actions_animal.dmi'
	button_icon_state = "wrap_0"
	check_flags = AB_CHECK_CONSCIOUS
	click_to_activate = TRUE
	ranged_mousepointer = 'icons/effects/mouse_pointers/wrap_target.dmi'
	/// The time it takes to wrap something.
	var/wrap_time = 5 SECONDS

/datum/action/cooldown/wrap/IsAvailable()
	. = ..()
	if(!.)
		return FALSE
	if(owner.incapacitated())
		return FALSE
	if(DOING_INTERACTION(owner, INTERACTION_SPIDER_KEY))
		return FALSE
	return TRUE

/datum/action/cooldown/wrap/set_click_ability(mob/on_who)
	. = ..()
	if(!.)
		return

	to_chat(on_who, span_notice("You prepare to wrap something in a cocoon. <B>Left-click your target to start wrapping!</B>"))
	button_icon_state = "wrap_0"
	UpdateButtons()

/datum/action/cooldown/wrap/unset_click_ability(mob/on_who, refund_cooldown = TRUE)
	. = ..()
	if(!.)
		return

	if(refund_cooldown)
		to_chat(on_who, span_notice("You no longer prepare to wrap something in a cocoon."))
	button_icon_state = "wrap_1"
	UpdateButtons()

/datum/action/cooldown/wrap/Activate(atom/to_wrap)
	if(!owner.Adjacent(to_wrap))
		owner.balloon_alert(owner, "must be closer!")
		return FALSE

	if(!ismob(to_wrap) && !isobj(to_wrap))
		return FALSE

	if(to_wrap == owner)
		return FALSE

	if(isspider(to_wrap))
		owner.balloon_alert(owner, "can't wrap spiders!")
		return FALSE

	var/atom/movable/target_movable = to_wrap
	if(target_movable.anchored)
		return FALSE

	StartCooldown(wrap_time)
	INVOKE_ASYNC(src, .proc/cocoon, to_wrap)
	return TRUE

/datum/action/cooldown/wrap/proc/cocoon(atom/movable/to_wrap)
	owner.visible_message(
		span_notice("[owner] begins to secrete a sticky substance around [to_wrap]."),
		span_notice("You begin wrapping [to_wrap] into a cocoon."),
	)

	var/mob/living/simple_animal/animal_owner = owner
	if(istype(animal_owner))
		animal_owner.stop_automated_movement = TRUE

	if(do_after(owner, wrap_time, target = to_wrap))
		var/obj/structure/spider/cocoon/casing = new(to_wrap.loc)
		if(isliving(to_wrap))
			var/mob/living/living_wrapped = to_wrap
			// if they're not dead, you can consume them anyway
			if(ishuman(living_wrapped) && (living_wrapped.stat != DEAD || !HAS_TRAIT(living_wrapped, TRAIT_SPIDER_CONSUMED)))
				var/datum/action/innate/spider/lay_eggs/egg_power = locate() in owner.actions
				if(egg_power)
					egg_power.UpdateButtons()
					owner.visible_message(
						span_danger("[owner] sticks a proboscis into [living_wrapped] and sucks a viscous substance out."),
						span_notice("You suck the nutriment out of [living_wrapped], feeding you enough to lay a cluster of enriched eggs."),
					)

				living_wrapped.death() //you just ate them, they're dead.
			else
				to_chat(owner, span_warning("[living_wrapped] cannot sate your hunger!"))

		to_wrap.forceMove(casing)
		if(to_wrap.density || ismob(to_wrap))
			casing.icon_state = pick("cocoon_large1", "cocoon_large2", "cocoon_large3")

	if(istype(animal_owner))
		animal_owner.stop_automated_movement = TRUE

/datum/action/innate/spider/lay_eggs
	name = "Lay Eggs"
	desc = "Lay a cluster of eggs, which will soon grow into more spiders. You must have a directive set and wrap a living being to do this."
	button_icon_state = "lay_eggs"

/datum/action/innate/spider/lay_eggs/IsAvailable()
	if(..())
		if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
			return FALSE
		var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner
		if(S.fed && !S.ckey)
			return TRUE
		return FALSE

/datum/action/innate/spider/lay_eggs/Activate()
	if(!istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/nurse))
		return
	var/mob/living/simple_animal/hostile/poison/giant_spider/nurse/S = owner

	var/obj/structure/spider/eggcluster/E = locate() in get_turf(S)
	if(E)
		to_chat(S, "<span class='warning'>There is already a cluster of eggs here!</span>")
	else if(!S.fed)
		to_chat(S, "<span class='warning'>You are too hungry to do this!</span>")
	else if(S.busy != LAYING_EGGS)
		S.busy = LAYING_EGGS
		S.visible_message("<span class='notice'>[S] begins to lay a cluster of eggs.</span>","<span class='notice'>You begin to lay a cluster of eggs.</span>")
		S.stop_automated_movement = TRUE
		if(do_after(S, 50, target = get_turf(S)))
			if(S.busy == LAYING_EGGS)
				E = locate() in get_turf(S)
				if(!E || !isturf(S.loc))
					var/obj/structure/spider/eggcluster/C = new /obj/structure/spider/eggcluster(get_turf(S))
					C.faction = S.faction.Copy()
					S.fed--
					UpdateButtons(TRUE)
		S.busy = SPIDER_IDLE
		S.stop_automated_movement = FALSE




// Spider command ability for broodmothers
/datum/action/innate/spider/comm
	name = "Command"
	desc = "Send a command to all living spiders."
	button_icon_state = "command"

/datum/action/innate/spider/comm/IsAvailable()
	return ..() && istype(owner, /mob/living/simple_animal/hostile/poison/giant_spider/broodmother)

/datum/action/innate/spider/comm/Trigger(trigger_flags)
	var/input = stripped_input(owner, "Input a command for your children to follow.", "Command", "")
	if(QDELETED(src) || !input || !IsAvailable())
		return FALSE
	spider_command(owner, input)
	return TRUE

/datum/action/innate/spider/comm/proc/spider_command(mob/living/user, message)
	if(!message)
		return
	if(CHAT_FILTER_CHECK(message))
		to_chat(usr, "<span class='warning'>Your message contains forbidden words.</span>")
		return
	message = user.treat_message_min(message)
	var/my_message = "<span class='spiderlarge'><b>Command from [user]:</b> [message]</span>"
	var/datum/antagonist/spider/spider_antag = user.mind?.has_antag_datum(/datum/antagonist/spider)
	if(!spider_antag)
		return
	for(var/mob/living/simple_animal/hostile/poison/giant_spider/spider as anything in GLOB.spidermobs)
		var/datum/antagonist/spider/target_spider_antag = spider.mind?.has_antag_datum(/datum/antagonist/spider)
		if(spider_antag?.spider_team == target_spider_antag?.spider_team)
			to_chat(spider, my_message)
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, user)
		to_chat(M, "[link] [my_message]")
	user.log_talk(message, LOG_SAY, tag = "spider command")

// Temperature damage
// Flat 10 brute if they're out of safe temperature, making them vulnerable to fire or spacing
/mob/living/simple_animal/hostile/poison/giant_spider/handle_temperature_damage()
	if(bodytemperature < minbodytemp)
		adjustBruteLoss(10)
		throw_alert("temp", /atom/movable/screen/alert/cold, 3)
	else if(bodytemperature > maxbodytemp)
		adjustBruteLoss(10)
		throw_alert("temp", /atom/movable/screen/alert/hot, 3)
	else
		clear_alert("temp")

#undef SPIDER_IDLE
#undef SPINNING_WEB
#undef LAYING_EGGS
#undef MOVING_TO_TARGET
#undef SPINNING_COCOON
#undef INTERACTION_SPIDER_KEY
