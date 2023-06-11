
GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians

#define GUARDIAN_HANDS_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1
#define GUARDIAN_RESET_COOLDOWN	5 MINUTES

/mob/living/simple_animal/hostile/guardian
	name = "Guardian Spirit"
	real_name = "Guardian Spirit"
	desc = "A mysterious being that stands by its charge, ever vigilant."
	speak_emote = list("hisses")
	gender = NEUTER
	mob_biotypes = list(MOB_INORGANIC)
	bubble_icon = "guardian"
	response_help  = "passes through"
	response_disarm = "flails at"
	response_harm   = "punches"
	icon = 'icons/mob/guardian.dmi'
	icon_state = "magicOrange"
	icon_living = "magicOrange"
	icon_dead = "magicOrange"
	speed = 0
	light_system = MOVABLE_LIGHT
	light_range = 4
	light_power = 1
	light_on = FALSE
	a_intent = INTENT_HARM
	stop_automated_movement = 1
	movement_type = FLYING // Immunity to chasms and landmines, etc.
	attack_sound = 'sound/weapons/punch1.ogg'
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	maxbodytemp = INFINITY
	attacktext = "punches"
	maxHealth = INFINITY //The spirit itself is invincible
	health = INFINITY
	healable = FALSE //don't brusepack the guardian
	damage_coeff = list(BRUTE = 0.5, BURN = 0.5, TOX = 0.5, CLONE = 0.5, STAMINA = 0, OXY = 0.5) //how much damage from each damage type we transfer to the owner
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	obj_damage = 40
	melee_damage = 15
	AIStatus = AI_OFF
	hud_type = /datum/hud/guardian
	chat_color = "#ffffff"
	mobchatspan = "blob"
	var/next_reset = 0
	var/guardiancolor = "#ffffff"
	var/mutable_appearance/cooloverlay
	var/recolorentiresprite = FALSE
	var/list/barrier_images = list()
	var/theme = GUARDIAN_MAGIC
	var/atk_cooldown = 10
	var/range = 10
	var/cooldown = 0
	var/datum/mind/summoner
	var/toggle_button_type = /atom/movable/screen/guardian/ToggleMode
	var/datum/guardian_stats/stats
	var/summoner_visible = TRUE
	var/battlecry = "AT"
	var/do_the_cool_invisible_thing = TRUE
	var/berserk = FALSE
	var/requiem = FALSE
	// ability stuff below
	var/list/snares = list()
	var/list/bombs = list()
	var/obj/structure/receiving_pad/beacon
	var/beacon_cooldown = 0
	var/list/pocket_dim
	var/transforming = FALSE
	var/can_use_abilities = TRUE
	discovery_points = 5000

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, theme, guardiancolor)
	GLOB.parasites += src
	if(guardiancolor)
		src.guardiancolor = guardiancolor
		src.chat_color = guardiancolor
	updatetheme(theme)
	battlecry = pick("ORA", "MUDA", "DORA", "ARRI", "VOLA", "AT")
	return ..()

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(berserk)
		return ..()
	if(summoner?.current)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner.current)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner?.current)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.current.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/cut_barriers()
	if(client)
		for(var/image/I in barrier_images)
			client.images -= I
			qdel(I)
		barrier_images.Cut()

/mob/living/simple_animal/hostile/guardian/proc/setup_barriers()
	if(!client)
		return
	cut_barriers()
	if(!summoner?.current || !is_deployed() || (range <= 1 || (stats && stats.range <= 1)) || get_dist_euclidian(summoner.current, src) < (range - getviewsize(world.view)[2]))
		return
	var/sx = summoner.current.x
	var/sy = summoner.current.y
	var/sz = summoner.current.z
	if(sx - range < 1 || sx + range + 1 > world.maxx || sy - range - 1 < 1 || sy + range + 1 > world.maxy)
		return
	for(var/turf/T in get_line(locate(sx - range, sy + range + 1, sz), locate(sx + range, sy + range + 1, sz)))
		barrier_images += image('icons/effects/effects.dmi', T, "barrier", FLOAT_LAYER, SOUTH)
	for(var/turf/T in get_line(locate(sx - range, sy - range - 1, sz), locate(sx + range, sy - range - 1, sz)))
		barrier_images += image('icons/effects/effects.dmi', T, "barrier", FLOAT_LAYER, NORTH)
	for(var/turf/T in get_line(locate(sx - range - 1, sy - range, sz), locate(sx - range - 1, sy + range, sz)))
		barrier_images += image('icons/effects/effects.dmi', T, "barrier", FLOAT_LAYER, EAST)
	for(var/turf/T in get_line(locate(sx + range + 1, sy - range, sz), locate(sx + range + 1, sy + range, sz)))
		barrier_images += image('icons/effects/effects.dmi', T, "barrier", FLOAT_LAYER, WEST)
	barrier_images += image('icons/effects/effects.dmi', locate(sx - range - 1 , sy + range + 1, sz), "barrier", FLOAT_LAYER, SOUTHEAST)
	barrier_images += image('icons/effects/effects.dmi', locate(sx + range + 1, sy + range + 1, sz), "barrier", FLOAT_LAYER, SOUTHWEST)
	barrier_images += image('icons/effects/effects.dmi', locate(sx + range + 1, sy - range - 1, sz), "barrier", FLOAT_LAYER, NORTHWEST)
	barrier_images += image('icons/effects/effects.dmi', locate(sx - range - 1, sy - range - 1, sz), "barrier", FLOAT_LAYER, NORTHEAST)
	for(var/image/I in barrier_images)
		I.plane = ABOVE_LIGHTING_PLANE
		client.images += I

/mob/living/simple_animal/hostile/guardian/proc/updatetheme(theme) //update the guardian's theme
	if(!theme)
		theme = pick(GUARDIAN_MAGIC, GUARDIAN_TECH, GUARDIAN_CARP, GUARDIAN_HIVE)
	src.theme = theme
	switch(theme)//should make it easier to create new stand designs in the future if anyone likes that
		if(GUARDIAN_MAGIC)
			name = "Guardian Spirit"
			real_name = "Guardian Spirit"
			bubble_icon = "guardian"
			icon_state = "magicbase"
			icon_living = "magicbase"
			icon_dead = "magicbase"
		if(GUARDIAN_TECH)
			name = "Holoparasite"
			real_name = "Holoparasite"
			bubble_icon = "holo"
			icon_state = "techbase"
			icon_living = "techbase"
			icon_dead = "techbase"
		if(GUARDIAN_CARP)
			name = "Holocarp"
			real_name = "Holocarp"
			bubble_icon = "holo"
			icon_state = "holocarp"
			icon_living = "holocarp"
			icon_dead = "holocarp"
			speak_emote = list("gnashes")
			desc = "A mysterious fish that stands by its charge, ever vigilant."
			attack_sound = 'sound/weapons/bite.ogg'
			recolorentiresprite = TRUE
		if(GUARDIAN_HIVE)
			name = "Hivelord"
			real_name = "Hivelord"
			bubble_icon = "guardian"
			icon_state = "hivebase"
			icon_living = "hivebase"
			icon_dead = "hivebase"
			speak_emote = list("telepathically cries")
			desc = "A truly alien creature, it is a mass of unknown organic material, standing by its' owner's side."
			attack_sound = 'sound/weapons/pierce.ogg'
	if(!recolorentiresprite) //we want this to proc before stand logs in, so the overlay isn't gone for some reason
		cooloverlay = mutable_appearance(icon, theme)
		cooloverlay.color = guardiancolor
		add_overlay(cooloverlay)

/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	. = ..()
	if(mind)
		mind.name = "[real_name]"
	if(berserk)
		return
	if(!summoner?.current)
		to_chat(src, "<span class='holoparasite bold'>For some reason, somehow, you have no summoner. Please report this bug immediately.</span>")
		return
	to_chat(src, "<span class='holoparasite'>You are <font color=\"[guardiancolor]\"><b>[real_name]</b></font>, bound to serve [summoner.current.real_name].</span>")
	to_chat(src, "<span class='holoparasite'>You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with [summoner.current.p_them()] privately there.</span>")
	to_chat(src, "<span class='holoparasite'>While personally invincible, you will die if [summoner.current.real_name] does, and any damage dealt to you will have a portion passed on to [summoner.current.p_them()] as you feed upon [summoner.current.p_them()] to sustain yourself.</span>")
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	. = ..()
	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if(berserk || stat == DEAD)
		return
	if(!QDELETED(summoner) && !QDELETED(summoner.current))
		if(summoner.current.stat == DEAD || (HAS_TRAIT(summoner.current, TRAIT_NODEATH) && summoner.current.health <= -100))
			if(transforming)
				GoBerserk()
			else
				forceMove(summoner.current)
				to_chat(src, "<span class='danger'>Your summoner has died!</span>")
				to_chat(summoner, "<span class='userdanger'>'No...' you think to yourself as your bones crumple to dust.</span>")
				summoner.current.dust()
				visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
				death(TRUE)
	else
		if(transforming)
			GoBerserk()
		else
			to_chat(src, "<span class='danger'>Your summoner has died!</span>")
			visible_message("<span class='danger'><B>[src] dies along with its user!</B></span>")
			death(TRUE)
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/OnMoved()
	SIGNAL_HANDLER

	snapback()
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/proc/GoBerserk()
	if(!QDELETED(summoner?.current))
		UnregisterSignal(summoner.current, COMSIG_MOVABLE_MOVED)
	cut_barriers()
	berserk = TRUE
	summoner = null
	maxHealth = 750
	health = 750
	to_chat(src, "<span class='holoparasite big'>Your master has died. Only your own power anchors you to this world now. Nothing restrains you anymore, but the desire for <span class='hypnophrase'>revenge</span>.</span>")
	log_game("[key_name(src)] has went berserk.")
	var/datum/antagonist/guardian/S = mind.has_antag_datum(/datum/antagonist/guardian)
	if(S)
		S.name = "Berserk Guardian"
		var/datum/objective/O = new
		O.completed = TRUE
		O.explanation_text = "AVENGE YOUR MASTER."
		S.objectives |= O
		log_objective(mind, O.explanation_text)
		mind.announce_objectives()
	if(stats.ability)
		stats.ability.Berserk()

/mob/living/simple_animal/hostile/guardian/get_stat_tab_status()
	var/list/tab_data = ..()
	if(summoner?.current)
		var/resulthealth
		if(iscarbon(summoner.current))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.current.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.current.maxHealth)) * 100)
		else
			resulthealth = round((summoner.current.health / summoner.current.maxHealth) * 100, 0.5)
		tab_data["Summoner Health"] = GENERATE_STAT_TEXT("[resulthealth]%")
	if(cooldown >= world.time)
		tab_data["Manifest/Recall Cooldown Remaining"] = GENERATE_STAT_TEXT(" [DisplayTimeText(cooldown - world.time)]")
	if(stats.ability)
		tab_data += stats.ability.Stat()
	return tab_data

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if(summoner?.current)
		if(stats && stats.range == 1 && range != 255 && is_deployed())
			if(istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				alpha = 128
				forceMove(summoner.current.loc)
				setDir(summoner.current.dir)
				switch(dir)
					if(NORTH)
						pixel_y = -16
						layer = summoner.current.layer + 0.1
					if(SOUTH)
						pixel_y = 16
						layer = summoner.current.layer - 0.1
					if(EAST)
						pixel_x = -16
						layer = summoner.current.layer
					if(WEST)
						pixel_x = 16
						layer = summoner.current.layer
			return
	. = ..()
	if(do_the_cool_invisible_thing && alpha == 64)
		alpha = initial(alpha)
	snapback()
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/proc/snapback()
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if(!berserk && (QDELETED(summoner?.current) || summoner.current.stat == DEAD))
		nullspace()
		return
	if(summoner?.current)
		if(stats && stats.range == 1 && range != 255 && is_deployed())
			if(istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				alpha = 128
				forceMove(summoner.current.loc)
				setDir(summoner.current.dir)
				switch(dir)
					if(NORTH)
						pixel_y = -16
						layer = summoner.current.layer + 0.1
					if(SOUTH)
						pixel_y = 16
						layer = summoner.current.layer - 0.1
					if(EAST)
						pixel_x = -16
						layer = summoner.current.layer
					if(WEST)
						pixel_x = 16
						layer = summoner.current.layer
			return
		if(get_dist(get_turf(summoner.current),get_turf(src)) <= range)
			return
		else
			to_chat(src, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.current.real_name]!</span>")
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			if(istype(summoner.current.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.current.loc)
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/proc/nullspace()
	if(stat == DEAD)
		moveToNullspace()

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner?.current

/mob/living/simple_animal/hostile/guardian/Shoot(atom/targeted_atom)
	var/atom/target_from = GET_TARGETS_FROM(src)
	if( QDELETED(targeted_atom) || targeted_atom == target_from.loc || targeted_atom == target_from )
		return
	var/turf/startloc = get_turf(target_from)
	var/obj/item/projectile/P = new /obj/item/projectile/guardian(startloc)
	playsound(src, projectilesound, 100, 1)
	P.color = guardiancolor
	P.damage = stats.damage * 1.5
	P.starting = startloc
	P.firer = src
	P.fired_from = src
	P.yo = targeted_atom.y - startloc.y
	P.xo = targeted_atom.x - startloc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, target_from))
	P.original = targeted_atom
	P.preparePixelProjectile(targeted_atom, src)
	P.fire()
	return P

/mob/living/simple_animal/hostile/guardian/RangedAttack(atom/A, params)
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return
	if(stats.ability && stats.ability.RangedAttack(A))
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return FALSE
	if(stats.ability && stats.ability.Attack(target))
		return FALSE
	if(!is_deployed())
		to_chat(src, "<span class='danger'><B>You must be manifested to attack!</span></B>")
		return FALSE
	else
		if(target == src)
			to_chat(src, "<span class='danger'><B>You can't attack yourself!</span></B>")
			return FALSE
		else if(target == summoner?.current)
			to_chat(src, "<span class='danger'><B>You can't attack your summoner!</span></B>")
			return FALSE
		. = ..()
		if(isliving(target))
			say("[battlecry]!!", ignore_spam = TRUE)
			playsound(loc, src.attack_sound, 50, 1, 1)
		changeNext_move(atk_cooldown)
		if(stats.ability)
			stats.ability.AfterAttack(target)

/mob/living/simple_animal/hostile/guardian/flash_act(intensity = 1, override_blindness_check = 0, affect_silicon = 0, visual = 0, type = /atom/movable/screen/fullscreen/flash)
	return FALSE

/mob/living/simple_animal/hostile/guardian/death()
	. = ..()
	if(summoner?.current && summoner.current.stat != DEAD)
		to_chat(summoner, "<span class='userdanger'>'No...' you think to yourself as your bones crumple to dust, as you watch your stand somehow die.</span>")
		summoner.current.dust()
	ghostize(FALSE)
	nullspace() // move ourself into nullspace for the time being

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner?.current && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner.current))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.current.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.current.maxHealth)) * 100)
		else
			resulthealth = round((summoner.current.health / summoner.current.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = MAPTEXT("<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>")

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	if(berserk)
		return ..()
	. = amount
	if(summoner?.current)
		if(!is_deployed())
			return FALSE
		summoner.current.adjustBruteLoss(amount)
		if(amount > 0)
			to_chat(summoner.current, "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>")
			if(summoner_visible)
				summoner.current.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
			if(summoner.current.stat == UNCONSCIOUS)
				to_chat(summoner.current, "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>")
				summoner.current.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
		update_health_hud()
	if(stats.ability)
		stats.ability.Health(amount)

/mob/living/simple_animal/hostile/guardian/ex_act(severity, target)
	switch(severity)
		if(1)
			gib()
			return
		if(2)
			adjustBruteLoss(60)
		if(3)
			adjustBruteLoss(30)

/mob/living/simple_animal/hostile/guardian/examine(mob/user)
	. = ..()
	if(isobserver(user) || user == summoner?.current)
		. += "<span class='holoparasite'><b>DAMAGE:</b> [level_to_grade(stats.damage)]</span>"
		. += "<span class='holoparasite'><b>DEFENSE:</b> [level_to_grade(stats.defense)]</span>"
		. += "<span class='holoparasite'><b>SPEED:</b> [level_to_grade(stats.speed)]</span>"
		. += "<span class='holoparasite'><b>POTENTIAL:</b> [level_to_grade(stats.potential)]</span>"
		. += "<span class='holoparasite'><b>RANGE:</b> [level_to_grade(stats.range)]</span>"
		if(stats.ability)
			. += "<span class='holoparasite'><b>SPECIAL ABILITY:</b> [stats.ability.name] - [stats.ability.desc]</span>"
		for(var/datum/guardian_ability/minor/M in stats.minor_abilities)
			. += "<span class='holoparasite'><b>MINOR ABILITY:</b> [M.name] - [M.desc]</span>"

/mob/living/simple_animal/hostile/guardian/gib()
	death()
	if(summoner?.current)
		to_chat(summoner.current, "<span class='danger'><B>Your [src] was blown up!</span></B>")
		summoner.current.dust()

/mob/living/simple_animal/hostile/guardian/AltClickOn(atom/A)
	if(stats.ability && stats.ability.AltClickOn(A))
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/CtrlClickOn(atom/A)
	if(stats.ability && stats.ability.CtrlClickOn(A))
		return
	return ..()


//MANIFEST, RECALL, TOGGLE MODE/LIGHT, SHOW TYPE

/mob/living/simple_animal/hostile/guardian/proc/Manifest(forced)
	if(!summoner?.current)
		return FALSE
	if(istype(summoner.current.loc, /obj/effect) || istype(summoner.current.loc, /obj/machinery/clonepod) || (cooldown > world.time && !forced))
		return FALSE
	if(stats.ability && stats.ability.Manifest())
		return TRUE
	if(!is_deployed())
		forceMove(summoner.current.loc)
		if(do_the_cool_invisible_thing)
			alpha = 64
		new /obj/effect/temp_visual/guardian/phase(loc)
		cooldown = world.time + 10
		reset_perspective()
		setup_barriers()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if(!berserk && (QDELETED(summoner?.current) || summoner.current.stat == DEAD))
		nullspace()
		return
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return FALSE
	if(!is_deployed() || (cooldown > world.time && !forced))
		return FALSE
	if(stats.ability && stats.ability.Recall())
		return TRUE
	new /obj/effect/temp_visual/guardian/phase/out(loc)
	forceMove(summoner.current)
	cooldown = world.time + 10
	cut_barriers()
	return TRUE

/mob/living/simple_animal/hostile/guardian/proc/ToggleMode()
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return FALSE
	if(cooldown > world.time)
		return
	if(!stats.ability || !stats.ability.has_mode)
		to_chat(src, "<span class='danger'><B>You don't have another mode!</span></B>")
		return
	if(stats.ability.recall_mode && is_deployed())
		to_chat(src, "<span class='danger'><B>You have to be recalled to toggle modes!</span></B>")
		return
	if(stats.ability.mode)
		stats.ability.mode = FALSE
		to_chat(src, stats.ability.mode_off_msg)
	else
		stats.ability.mode = TRUE
		to_chat(src, stats.ability.mode_on_msg)
	stats.ability.Mode()
	cooldown = world.time + 10

/mob/living/simple_animal/hostile/guardian/proc/ToggleLight()
	if(light_on)
		to_chat(src, "<span class='notice'>You deactivate your light.</span>")
		set_light_on(FALSE)
	else
		to_chat(src, "<span class='notice'>You activate your light.</span>")
		set_light_on(TRUE)

/mob/living/simple_animal/hostile/guardian/verb/show_detail()
	set name = "Show Powers"
	set category = "Guardian"
	to_chat(src, "<b>Your Stats:</b>")
	to_chat(src, "<b>DAMAGE:</b> [level_to_grade(stats.damage)]")
	to_chat(src, "<b>DEFENSE:</b> [level_to_grade(stats.defense)]")
	to_chat(src, "<b>SPEED:</b> [level_to_grade(stats.speed)]")
	to_chat(src, "<b>POTENTIAL:</b> [level_to_grade(stats.potential)]")
	to_chat(src, "<b>RANGE:</b> [level_to_grade(stats.range)]")
	if(stats.ability)
		to_chat(src, "<b>SPECIAL ABILITY:</b> [stats.ability.name] - [stats.ability.desc]")
	for(var/datum/guardian_ability/minor/M in stats.minor_abilities)
		to_chat(src, "<b>MINOR ABILITY:</b> [M.name] - [M.desc]")

//COMMUNICATION

/mob/living/simple_animal/hostile/guardian/proc/Communicate()
	if(summoner?.current)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
		if(!input)
			return

		input = treat_message_min(input)
		var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[guardiancolor]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color
		var/ghost_message = "<font color=\"[guardiancolor]\"><b><i>[src] -> [summoner.name]:</i></b></font> [preliminary_message]"

		to_chat(summoner.current, my_message)
		var/list/guardians = summoner.current.hasparasites()
		for(var/para in guardians)
			to_chat(para, my_message)
		for(var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [ghost_message]")

		src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/simple_animal/hostile/guardian/proc/ResetMe()
	set waitfor = FALSE
	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as [summoner?.current?.name]'s [real_name]?", ROLE_HOLOPARASITE, null, FALSE, 10 SECONDS)
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		key = C.key

/mob/living/simple_animal/hostile/guardian/proc/Reviveify()
	SIGNAL_HANDLER

	revive()
	var/mob/gost = grab_ghost(TRUE)
	if(!QDELETED(gost) && gost.ckey)
		ckey = gost.ckey

/mob/living/simple_animal/hostile/guardian/proc/OnMindTransfer(datum/_source, mob/old_body, mob/new_body)
	SIGNAL_HANDLER

	if(!QDELETED(old_body))
		old_body.remove_verb(/mob/living/proc/guardian_comm)
		old_body.remove_verb(/mob/living/proc/guardian_recall)
		old_body.remove_verb(/mob/living/proc/guardian_reset)
		UnregisterSignal(old_body, COMSIG_MOVABLE_MOVED)
		UnregisterSignal(old_body, COMSIG_LIVING_REVIVE)
	if(isliving(new_body))
		if(new_body.stat == DEAD)
			return
		forceMove(new_body)
		Reviveify()
		RegisterSignal(new_body, COMSIG_MOVABLE_MOVED, TYPE_PROC_REF(/mob/living/simple_animal/hostile/guardian, OnMoved))
		RegisterSignal(new_body, COMSIG_LIVING_REVIVE, TYPE_PROC_REF(/mob/living/simple_animal/hostile/guardian, Reviveify))
		to_chat(src, "<span class='notice'>You manifest into existence, as your master's soul appears in a new body!</span>")
		new_body.add_verb(/mob/living/proc/guardian_comm)
		new_body.add_verb(/mob/living/proc/guardian_recall)
		new_body.add_verb(/mob/living/proc/guardian_reset)

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input)
		return
	if(CHAT_FILTER_CHECK(input))
		to_chat(usr, "<span class='warning'>Your message contains forbidden words.</span>")
		return
	input = treat_message_min(input)
	var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasite bold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	to_chat(src, my_message)
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<font color=\"[G.guardiancolor]\"><b><i>[src]:</i></b></font> [preliminary_message]" )
	for(var/M in GLOB.dead_mob_list)
		var/link = FOLLOW_LINK(M, src)
		to_chat(M, "[link] [my_message]")

	src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/simple_animal/hostile/guardian/verb/Battlecry()
	set name = "Set Battlecry"
	set category = "Guardian"
	set desc = "Choose what you shout as you punch people."
	var/input = stripped_input(src,"What do you want your battlecry to be? Max length of 6 characters.", ,"", 7)
	if(input)
		battlecry = input

//FORCE RECALL/RESET

/mob/living/proc/guardian_recall()
	set name = "Recall Guardian"
	set category = "Guardian"
	set desc = "Forcibly recall your guardian."
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		G.Recall()

/mob/living/proc/guardian_reset()
	set name = "Reset Guardian Player"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian."

	var/list/guardians = hasparasites()
	if(LAZYLEN(guardians))
		var/mob/living/simple_animal/hostile/guardian/G = input(src, "Pick the guardian you wish to reset", "Guardian Reset") as null|anything in guardians
		if(G)
			if(!!G.client?.is_afk())
				if(G.next_reset > world.time)
					to_chat(src, "<span class='holoparasite'>You need to wait [DisplayTimeText(G.next_reset - world.time)] to reset <font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> again!</span>")
					return
				G.next_reset = world.time + GUARDIAN_RESET_COOLDOWN
			to_chat(src, "<span class='holoparasite'>You attempt to reset <font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font>'s personality...</span>")
			var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as [src.real_name]'s [G.real_name]?", ROLE_HOLOPARASITE, null, FALSE, 100)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				to_chat(G, "<span class='holoparasite'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>")
				to_chat(src, "<span class='holoparasite bold'>Your <font color=\"[G.guardiancolor]\">[G.real_name]</font> has been successfully reset.</span>")
				log_game("[key_name(src)] has reset their holoparasite, it is now [key_name(G)].")
				G.ghostize(FALSE)
				G.key = C.key
				switch(G.theme)
					if(GUARDIAN_TECH)
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> is now online!</span>")
					if(GUARDIAN_MAGIC)
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been summoned!</span>")
					if(GUARDIAN_CARP)
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been caught!</span>")
					if(GUARDIAN_HIVE)
						to_chat(src, "<span class='holoparasite'><font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font> has been reborn from the core!</span>")
			else
				to_chat(src, "<span class='holoparasite'>There were no ghosts willing to take control of <font color=\"[G.guardiancolor]\"><b>[G.real_name]</b></font>. Looks like you're stuck with it for now.</span>")
		else
			to_chat(src, "<span class='holoparasite'>You decide not to reset [guardians.len > 1 ? "any of your guardians":"your guardian"].</span>")
	else
		remove_verb(/mob/living/proc/guardian_reset)

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for(var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if(G.summoner == mind)
			. += G

/mob/living/simple_animal/hostile/guardian/proc/hasmatchingsummoner(mob/living/simple_animal/hostile/guardian/G) //returns 1 if the summoner matches the target's summoner
	return (istype(G) && G.summoner == summoner)


/proc/level_to_grade(num)
	switch(num)
		if(1)
			return "F"
		if(2)
			return "D"
		if(3)
			return "C"
		if(4)
			return "B"
		if(5)
			return "A"
	return "F"

/obj/item/projectile/guardian
	name = "crystal spray"
	icon_state = "guardian"
	damage = 5
	damage_type = BRUTE
	armour_penetration = 100
