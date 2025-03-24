#define SLIME_CARES_ABOUT(to_check) (to_check && (to_check == Target || to_check == Leader || (to_check in Friends)))
/mob/living/simple_animal/slime
	name = "grey baby slime (123)"
	icon = 'icons/mob/slimes.dmi'
	icon_state = "grey baby slime"
	pass_flags = PASSTABLE | PASSGRILLE
	ventcrawler = VENTCRAWLER_ALWAYS
	gender = NEUTER
	var/is_adult = 0
	var/docile = 0
	faction = list(FACTION_SLIME,FACTION_NEUTRAL)

	icon_living = "grey baby slime"
	icon_dead = "grey baby slime dead"
	response_help_continuous = "pets"
	response_help_simple = "pet"
	response_disarm_continuous = "shoos"
	response_disarm_simple = "shoo"
	response_harm_continuous = "stomps on"
	response_harm_simple = "stomp on"
	emote_see = list("jiggles", "bounces in place")
	speak_emote = list("blorbles")
	bubble_icon = "slime"
	initial_language_holder = /datum/language_holder/slime
	chat_color = "#A6E398"
	mobchatspan = "slimemobsay"

	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)

	maxHealth = 150
	health = 150
	healable = 0
	gender = NEUTER

	see_in_dark = NIGHTVISION_FOV_RANGE

	verb_say = "blorbles"
	verb_ask = "inquisitively blorbles"
	verb_exclaim = "loudly blorbles"
	verb_yell = "loudly blorbles"

	// canstun and canknockdown don't affect slimes because they ignore stun and knockdown variables
	// for the sake of cleanliness, though, here they are.
	status_flags = CANUNCONSCIOUS|CANPUSH

	footstep_type = FOOTSTEP_MOB_SLIME

	hardattacks = TRUE //A sharp blade wont cut a slime from a mere parry

	discovery_points = 1000

	var/cores = 1 // the number of /obj/item/slime_extract's the slime has left inside
	var/mutation_chance = 30 // Chance of mutating, should be between 25 and 35

	var/powerlevel = 0 // 1-10 controls how much electricity they are generating
	var/amount_grown = 0 // controls how long the slime has been overfed, if 10, grows or reproduces

	var/number = 0 // Used to understand when someone is talking to it

	var/mob/living/Target // AI variable - tells the slime to hunt this down
	var/mob/living/Leader // AI variable - tells the slime to follow this person

	var/attacked = 0 // Determines if it's been attacked recently. Can be any number, is a cooloff-ish variable
	var/rabid = 0 // If set to 1, the slime will attack and eat anything it comes in contact with
	var/holding_still = 0 // AI variable, cooloff-ish for how long it's going to stay in one place
	var/target_patience = 0 // AI variable, cooloff-ish for how long it's going to follow its target
	var/bucklestrength = 5 //rng replacement var for wrestling slimes off

	var/list/Friends = list() // A list of friends; they are not considered targets for feeding; passed down after splitting

	var/list/speech_buffer = list() // Last phrase said near it and person who said it

	var/mood = "" // To show its face
	var/mutator_used = FALSE //So you can't shove a dozen mutators into a single slime
	var/force_stasis = FALSE

	var/static/regex/slime_name_regex = new("\\w+ (baby|adult) slime \\(\\d+\\)")
	///////////TIME FOR SUBSPECIES

	var/colour = "grey"
	var/coretype = /obj/item/slime_extract/grey
	var/list/slime_mutation[4]

	var/static/list/slime_colours = list("rainbow", "grey", "purple", "metal", "orange",
	"blue", "dark blue", "dark purple", "yellow", "silver", "pink", "red",
	"gold", "green", "adamantine", "oil", "light pink", "bluespace",
	"cerulean", "sepia", "black", "pyrite")

	///////////CORE-CROSSING CODE

	var/effectmod //What core modification is being used.
	var/applied = 0 //How many extracts of the modtype have been applied.

	// Transformative extract effects - get passed down
	var/transformeffects = SLIME_EFFECT_DEFAULT
	var/mob/master

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/slime)

/mob/living/simple_animal/slime/Initialize(mapload, new_colour="grey", new_is_adult=FALSE)
	GLOB.total_slimes++
	var/datum/action/innate/slime/feed/F = new
	F.Grant(src)

	is_adult = new_is_adult

	if(is_adult)
		var/datum/action/innate/slime/reproduce/R = new
		R.Grant(src)
		health = 200
		maxHealth = 200
	else
		var/datum/action/innate/slime/evolve/E = new
		E.Grant(src)
	create_reagents(100)
	set_colour(new_colour)
	. = ..()
	set_nutrition(SLIME_DEFAULT_NUTRITION)
	if(transformeffects & SLIME_EFFECT_LIGHT_PINK)
		set_playable(ROLE_SENTIENCE)

/mob/living/simple_animal/slime/Destroy()
	set_target(null)
	set_leader(null)
	clear_friends()
	return ..()

/mob/living/simple_animal/slime/proc/set_colour(new_colour)
	colour = new_colour
	update_name()
	slime_mutation = mutation_table(colour)
	var/sanitizedcolour = replacetext(colour, " ", "")
	coretype = text2path("/obj/item/slime_extract/[sanitizedcolour]")
	regenerate_icons()

/mob/living/simple_animal/slime/update_name()
	. = ..()
	if(slime_name_regex.Find(name))
		number = rand(1, 1000)
		name = "[colour] [is_adult ? "adult" : "baby"] slime ([number])"
		real_name = name

/mob/living/simple_animal/slime/proc/random_colour()
	set_colour(pick(slime_colours))

/mob/living/simple_animal/slime/regenerate_icons()
	cut_overlays()
	var/icon_text = "[colour] [is_adult ? "adult" : "baby"] slime"
	icon_dead = "[icon_text] dead"
	if(stat != DEAD)
		icon_state = icon_text
		if(mood && !stat)
			add_overlay("aslime-[mood]")
	else
		icon_state = icon_dead
	..()

/mob/living/simple_animal/slime/on_reagent_change()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod)
	var/amount = 0
	if(reagents.has_reagent(/datum/reagent/medicine/morphine)) // morphine slows slimes down
		amount = 2
	if(reagents.has_reagent(/datum/reagent/consumable/frostoil)) // Frostoil also makes them move VEEERRYYYYY slow
		amount = 5
	if(amount)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_reagentmod, multiplicative_slowdown = amount)

/mob/living/simple_animal/slime/updatehealth()
	. = ..()
	remove_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod)
	var/health_deficiency = (100 - health)
	var/mod = 0
	if(!HAS_TRAIT(src, TRAIT_IGNOREDAMAGESLOWDOWN))
		if(health_deficiency >= 45)
			mod += (health_deficiency / 25)
		if(health <= 0)
			mod += 2
	add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_healthmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/adjust_bodytemperature()
	. = ..()
	var/mod = 0
	if(bodytemperature >= 330.23) // 135 F or 57.08 C
		mod = -1	// slimes become supercharged at high temperatures
	else if(bodytemperature < 283.222)
		mod = ((283.222 - bodytemperature) / 10) * 1.75
	if(mod)
		add_or_update_variable_movespeed_modifier(/datum/movespeed_modifier/slime_tempmod, multiplicative_slowdown = mod)

/mob/living/simple_animal/slime/ObjBump(obj/O)
	if(!client && powerlevel > 0)
		var/probab = 10
		switch(powerlevel)
			if(1 to 2)
				probab = 20
			if(3 to 4)
				probab = 30
			if(5 to 6)
				probab = 40
			if(7 to 8)
				probab = 60
			if(9)
				probab = 70
			if(10)
				probab = 95
		if(prob(probab))
			if(istype(O, /obj/structure/window) || istype(O, /obj/structure/grille))
				if(attack_cooldown < world.time && nutrition <= get_hunger_nutrition())
					if (is_adult || prob(5))
						O.attack_slime(src)
						attack_cooldown = world.time + attack_cooldown_time

/mob/living/simple_animal/slime/Process_Spacemove(movement_dir = 0)
	return 2

/mob/living/simple_animal/slime/get_stat_tab_status()
	var/list/tab_data = ..()
	if(!docile)
		tab_data["Nutrition"] = GENERATE_STAT_TEXT("[nutrition]/[get_max_nutrition()]")
	if(amount_grown >= SLIME_EVOLUTION_THRESHOLD)
		if(is_adult)
			tab_data["Slime Status"] = GENERATE_STAT_TEXT("You can reproduce!")
		else
			tab_data["Slime Status"] = GENERATE_STAT_TEXT("You can evolve!")

	switch(stat)
		if(HARD_CRIT, UNCONSCIOUS)
			tab_data["Unconscious"] = GENERATE_STAT_TEXT("You are knocked out by high levels of BZ!")
		else
			tab_data["Power Level"] = GENERATE_STAT_TEXT("[powerlevel]")
	return tab_data

/mob/living/simple_animal/slime/adjustFireLoss(amount, updating_health = TRUE, forced = FALSE)
	if(!forced)
		amount = -abs(amount)
	return ..() //Heals them

/mob/living/simple_animal/slime/bullet_act(obj/projectile/Proj, def_zone, piercing_hit = FALSE)
	attacked += 10
	if((Proj.damage_type == BURN))
		adjustBruteLoss(-abs(Proj.damage)) //fire projectiles heals slimes.
		Proj.on_hit(src, 0, piercing_hit)
	else
		. = ..(Proj)
	. = . || BULLET_ACT_BLOCK

/mob/living/simple_animal/slime/emp_act(severity)
	. = ..()
	if(. & EMP_PROTECT_SELF)
		return
	powerlevel = 0 // oh no, the power!

/mob/living/simple_animal/slime/MouseDrop(atom/movable/A as mob|obj)
	if(isliving(A) && A != src && usr == src)
		var/mob/living/Food = A
		if(CanFeedon(Food))
			Feedon(Food)
	return ..()

/mob/living/simple_animal/slime/doUnEquip(obj/item/W, was_thrown = FALSE, silent = FALSE)
	return

/mob/living/simple_animal/slime/start_pulling(atom/movable/AM, state, force = move_force, supress_message = FALSE)
	return

/mob/living/simple_animal/slime/attack_ui(slot, params)
	return

/mob/living/simple_animal/slime/attack_slime(mob/living/simple_animal/slime/M, list/modifiers)
	if(..()) //successful slime attack
		if(M == src)
			return
		if(buckled)
			Feedstop(silent = TRUE)
			visible_message(span_danger("[M] pulls [src] off!"), \
				span_danger("You pull [src] off!"))
			return
		attacked += 5
		if(nutrition >= 100) //steal some nutrition. negval handled in life()
			adjust_nutrition(-(50 + (40 * M.is_adult)))
			M.add_nutrition(25 + (20 * M.is_adult))
		if(health > 0)
			M.adjustBruteLoss(-10 + (-10 * M.is_adult))
			M.updatehealth()

/mob/living/simple_animal/slime/attack_animal(mob/living/simple_animal/M)
	. = ..()
	if(.)
		attacked += 10


/mob/living/simple_animal/slime/attack_paw(mob/living/carbon/monkey/M)
	if(..()) //successful monkey bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_larva(mob/living/carbon/alien/larva/L, list/modifiers)
	if(..()) //successful larva bite.
		attacked += 10

/mob/living/simple_animal/slime/attack_hulk(mob/living/carbon/human/user, does_attack_animation = 0)
	if(user.combat_mode)
		discipline_slime(user)
		return ..()

/mob/living/simple_animal/slime/attack_hand(mob/living/carbon/human/M, modifiers)
	if(buckled)
		M.do_attack_animation(src, ATTACK_EFFECT_DISARM)
		if(bucklestrength >= 0)
			M.visible_message(span_warning("[M] attempts to wrestle \the [name] off!"), \
				span_danger("You attempt to wrestle \the [name] off!"))
			playsound(loc, 'sound/weapons/punchmiss.ogg', 25, 1, -1)
			bucklestrength --

		else
			M.visible_message(span_warning("[M] manages to wrestle \the [name] off!"), \
				span_notice("You manage to wrestle \the [name] off!"))
			playsound(loc, 'sound/weapons/thudswoosh.ogg', 50, 1, -1)

			discipline_slime(M)
	else
		if(stat == DEAD && surgeries.len)
			if(!M.combat_mode || LAZYACCESS(modifiers, RIGHT_CLICK))
				for(var/datum/surgery/S in surgeries)
					if(S.next_step(M, modifiers))
						return 1
		if(..()) //successful attack
			attacked += 10

/mob/living/simple_animal/slime/attack_alien(mob/living/carbon/alien/humanoid/M)
	if(..()) //if harm or disarm intent.
		attacked += 10
		discipline_slime(M)


/mob/living/simple_animal/slime/attackby(obj/item/W, mob/living/user, params)
	if(stat == DEAD && surgeries.len)
		var/list/modifiers = params2list(params)
		if(!user.combat_mode || (LAZYACCESS(modifiers, RIGHT_CLICK)))
			for(var/datum/surgery/S in surgeries)
				if(S.next_step(user, modifiers))
					return 1
	if(istype(W, /obj/item/stack/sheet/mineral/plasma) && !stat) //Let's you feed slimes plasma.
		add_friendship(user, 1)
		to_chat(user, span_notice("You feed the slime the plasma. It chirps happily."))
		var/obj/item/stack/sheet/mineral/plasma/S = W
		S.use(1)
		return
	if(W.force > 0)
		attacked += 10
		if(prob(25))
			user.do_attack_animation(src)
			user.changeNext_move(CLICK_CD_MELEE)
			to_chat(user, span_danger("[W] passes right through [src]!"))
			return
		if(Discipline && prob(50)) // wow, buddy, why am I getting attacked??
			Discipline = 0
	if(W.force >= 3)
		var/force_effect = 2 * W.force
		if(is_adult)
			force_effect = round(W.force/2)
		if(prob(10 + force_effect))
			discipline_slime(user)
	if(istype(W, /obj/item/storage/bag/bio))
		var/obj/item/storage/P = W
		if(!effectmod)
			to_chat(user, span_warning("The slime is not currently being mutated."))
			return
		var/hasOutput = FALSE //Have we outputted text?
		var/hasFound = FALSE //Have we found an extract to be added?
		for(var/obj/item/slime_extract/S in P.contents)
			if(S.effectmod == effectmod)
				P.atom_storage.attempt_remove(S, get_turf(src), silent = TRUE)
				qdel(S)
				applied++
				hasFound = TRUE
			if(applied >= SLIME_EXTRACT_CROSSING_REQUIRED)
				to_chat(user, span_notice("You feed the slime as many of the extracts from the bag as you can, and it mutates!"))
				playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
				spawn_corecross(user)
				hasOutput = TRUE
				break
		if(!hasOutput)
			if(!hasFound)
				to_chat(user, span_warning("There are no extracts in the bag that this slime will accept!"))
			else
				to_chat(user, span_notice("You feed the slime some extracts from the bag."))
				playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
		return
	..()

/mob/living/simple_animal/slime/proc/spawn_corecross(mob/living/user)
	var/static/list/crossbreeds = subtypesof(/obj/item/slimecross)
	visible_message(span_danger("[src] shudders, its mutated core consuming the rest of its body!"))
	playsound(src, 'sound/magic/smoke.ogg', 50, 1)
	var/crosspath
	var/crosspath_dangerous = FALSE
	var/crosspath_name = "crossbred slime extract"
	for(var/X in crossbreeds)
		var/obj/item/slimecross/S = X
		if(initial(S.colour) == colour && initial(S.effect) == effectmod)
			crosspath = S
			if(initial(S.dangerous))
				crosspath_dangerous = TRUE
			crosspath_name =  initial(S.effect) + " " + initial(S.colour) + " extract"
			break
	if(crosspath)
		log_game("A [crosspath_name] was created at [AREACOORD(src)] by [key_name(user)]")
		if(crosspath_dangerous)
			message_admins("A [crosspath_name] was created at [ADMIN_VERBOSEJMP(src)] by [ADMIN_LOOKUPFLW(user)]")
		new crosspath(loc)
	else
		visible_message(span_warning("The mutated core shudders, and collapses into a puddle, unable to maintain its form."))
	qdel(src)

/mob/living/simple_animal/slime/proc/apply_water()
	var/new_damage = rand(15,20)
	if(transformeffects & SLIME_EFFECT_DARK_BLUE)
		new_damage *= 0.5
	adjustBruteLoss(new_damage)
	if(!client)
		if(Target) // Like cats
			set_target(null)
			++Discipline
	return

/mob/living/simple_animal/slime/examine(mob/user)
	. = list(span_info("This is [icon2html(src, user)] \a <EM>[src]</EM>!"))
	if (stat == DEAD)
		. += span_deadsay("It is limp and unresponsive.")
	else
		if (stat == UNCONSCIOUS || stat == HARD_CRIT) // Slime stasis
			. += span_deadsay("It appears to be alive but unresponsive.")
		if (getBruteLoss())
			. += "<span class='warning'>"
			if (getBruteLoss() < 40)
				. += "It has some punctures in its flesh!"
			else
				. += "<B>It has severe punctures and tears in its flesh!</B>"
			. += "</span>\n"

		switch(powerlevel)
			if(2 to 3)
				. += "It is flickering gently with a little electrical activity."

			if(4 to 5)
				. += "It is glowing gently with moderate levels of electrical activity."

			if(6 to 9)
				. += span_warning("It is glowing brightly with high levels of electrical activity.")

			if(10)
				. += span_warning("<B>It is radiating with massive levels of electrical activity!</B>")

	. += "</span>"

/mob/living/simple_animal/slime/proc/discipline_slime(mob/user)
	if(stat)
		return

	if(prob(80) && !client)
		Discipline++

		if(!is_adult)
			if(Discipline == 1)
				attacked = 0

	set_target(null)
	if(buckled)
		Feedstop(silent = TRUE) //we unbuckle the slime from the mob it latched onto.
		bucklestrength = initial(bucklestrength)

	SStun = world.time + rand(20,60)

	Stun(3)
	if(user)
		step_away(src,user,15)

	addtimer(CALLBACK(src, PROC_REF(slime_move), user), 0.3 SECONDS)

/mob/living/simple_animal/slime/proc/slime_move(mob/user)
	if(user)
		step_away(src,user,15)

/mob/living/simple_animal/slime/pet
	docile = 1

/mob/living/simple_animal/slime/get_mob_buckling_height(mob/seat)
	if(..())
		return 3

/mob/living/simple_animal/slime/can_be_implanted()
	return TRUE

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/slime/random)

/mob/living/simple_animal/slime/random/Initialize(mapload, new_colour, new_is_adult)
	. = ..(mapload, pick(slime_colours), prob(50))

/mob/living/simple_animal/slime/apply_damage(damage = 0,damagetype = BRUTE, def_zone = null, blocked = FALSE, forced = FALSE)
	if(damage && damagetype == BRUTE && !forced && (transformeffects & SLIME_EFFECT_ADAMANTINE))
		blocked += 50
	. = ..(damage, damagetype, def_zone, blocked, forced)

/mob/living/simple_animal/slime/get_discovery_id()
	return "[colour] slime"

/mob/living/simple_animal/slime/give_mind(mob/user)
	. = ..()
	if (.)
		if(mind && master)
			mind.store_memory("<b>Serve [master.real_name], your master.</b>")
	return .

/mob/living/simple_animal/slime/get_spawner_desc()
	return "be a slime[master ? " under the command of [master.real_name]" : ""]."

/mob/living/simple_animal/slime/get_spawner_flavour_text()
	return "You are a slime born and raised in a laboratory.[master ? " Your duty is to follow the orders of [master.real_name].": ""]"

/mob/living/simple_animal/slime/proc/make_master(mob/user)
	Friends[user] += SLIME_FRIENDSHIP_ATTACK * 2
	master = user

CREATION_TEST_IGNORE_SUBTYPES(/mob/living/simple_animal/slime/rainbow)

/mob/living/simple_animal/slime/rainbow/Initialize(mapload, new_colour="rainbow", new_is_adult)
	. = ..(mapload, new_colour, new_is_adult)

/mob/living/simple_animal/slime/proc/set_target(new_target)
	var/old_target = Target
	Target = new_target
	if(old_target && !SLIME_CARES_ABOUT(old_target))
		UnregisterSignal(old_target, COMSIG_PARENT_QDELETING)
	if(Target)
		RegisterSignal(Target, COMSIG_PARENT_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/set_leader(new_leader)
	var/old_leader = Leader
	Leader = new_leader
	if(old_leader && !SLIME_CARES_ABOUT(old_leader))
		UnregisterSignal(old_leader, COMSIG_PARENT_QDELETING)
	if(Leader)
		RegisterSignal(Leader, COMSIG_PARENT_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/add_friendship(new_friend, amount = 1)
	if(!Friends[new_friend])
		Friends[new_friend] = 0
	Friends[new_friend] += amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_PARENT_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/set_friendship(new_friend, amount = 1)
	Friends[new_friend] = amount
	if(new_friend)
		RegisterSignal(new_friend, COMSIG_PARENT_QDELETING, PROC_REF(clear_memories_of), override = TRUE)

/mob/living/simple_animal/slime/proc/remove_friend(friend)
	Friends -= friend
	if(friend && !SLIME_CARES_ABOUT(friend))
		UnregisterSignal(friend, COMSIG_PARENT_QDELETING)

/mob/living/simple_animal/slime/proc/set_friends(new_buds)
	clear_friends()
	for(var/mob/friend as anything in new_buds)
		set_friendship(friend, new_buds[friend])

/mob/living/simple_animal/slime/proc/clear_friends()
	for(var/mob/friend as anything in Friends)
		remove_friend(friend)

/mob/living/simple_animal/slime/proc/clear_memories_of(datum/source)
	SIGNAL_HANDLER
	if(source == Target)
		set_target(null)
	if(source == Leader)
		set_leader(null)
	remove_friend(source)

#undef SLIME_CARES_ABOUT
