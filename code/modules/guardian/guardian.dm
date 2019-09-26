
GLOBAL_LIST_EMPTY(parasites) //all currently existing/living guardians

#define GUARDIAN_HANDS_LAYER 1
#define GUARDIAN_TOTAL_LAYERS 1

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
	melee_damage_lower = 15
	melee_damage_upper = 15
	AIStatus = AI_OFF
	hud_type = /datum/hud/guardian
	var/list/barrier_images = list()
	var/custom_name = FALSE
	var/atk_cooldown = 10
	var/range = 10
	var/reset = 0 //if the summoner has reset the guardian already
	var/cooldown = 0
	var/mob/living/summoner
	var/toggle_button_type = /obj/screen/guardian/ToggleMode
	var/datum/guardianname/namedatum = new/datum/guardianname()
	var/datum/guardian_stats/stats
	var/summoner_visible = TRUE
	var/battlecry = "AT"
	var/do_the_cool_invisible_thing = TRUE
	var/erased_time = FALSE
	var/berserk = FALSE
	var/requiem = FALSE
	// ability stuff below
	var/list/snares = list()
	var/list/bombs = list()
	var/obj/structure/receiving_pad/beacon
	var/beacon_cooldown = 0
	var/list/pocket_dim
	var/transforming = FALSE

/mob/living/simple_animal/hostile/guardian/Initialize(mapload, theme)
	GLOB.parasites += src
	setthemename(theme)
	battlecry = pick("ORA", "MUDA", "DORA", "ARRI", "VOLA", "AT")
	return ..()

/mob/living/simple_animal/hostile/guardian/med_hud_set_health()
	if(berserk)
		return ..()
	if(summoner)
		var/image/holder = hud_list[HEALTH_HUD]
		holder.icon_state = "hud[RoundHealth(summoner)]"

/mob/living/simple_animal/hostile/guardian/med_hud_set_status()
	if(summoner)
		var/image/holder = hud_list[STATUS_HUD]
		var/icon/I = icon(icon, icon_state, dir)
		holder.pixel_y = I.Height() - world.icon_size
		if(summoner.stat == DEAD)
			holder.icon_state = "huddead"
		else
			holder.icon_state = "hudhealthy"

/mob/living/simple_animal/hostile/guardian/Destroy()
	GLOB.parasites -= src
	return ..()

/mob/living/simple_animal/hostile/guardian/proc/cut_barriers()
	for(var/image/I in barrier_images)
		client.images -= I
		qdel(I)
	barrier_images.Cut()

/mob/living/simple_animal/hostile/guardian/proc/setup_barriers()
	cut_barriers()
	if(!is_deployed() || (range <= 1 || (stats && stats.range <= 1)) || !summoner || get_dist_euclidian(summoner, src) < (range - world.view))
		return
	var/sx = summoner.x
	var/sy = summoner.y
	var/sz = summoner.z
	for(var/turf/T in getline(locate(sx - range, sy + range + 1, sz), locate(sx + range, sy + range + 1, sz)))
		barrier_images += image('hippiestation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, EAST)
	for(var/turf/T in getline(locate(sx - range, sy - range - 1, sz), locate(sx + range, sy - range - 1, sz)))
		barrier_images += image('hippiestation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, EAST)
	for(var/turf/T in getline(locate(sx - range - 1, sy - range, sz), locate(sx - range - 1, sy + range, sz)))
		barrier_images += image('hippiestation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, NORTH)
	for(var/turf/T in getline(locate(sx + range + 1, sy - range, sz), locate(sx + range + 1, sy + range, sz)))
		barrier_images += image('hippiestation/icons/effects/effects.dmi', T, "barrier", ABOVE_LIGHTING_LAYER, NORTH)
	barrier_images += image('hippiestation/icons/effects/effects.dmi', locate(sx - range - 1 , sy + range + 1, sz), "barrier", ABOVE_LIGHTING_LAYER, SOUTHEAST)
	barrier_images += image('hippiestation/icons/effects/effects.dmi', locate(sx + range + 1, sy + range + 1, sz), "barrier", ABOVE_LIGHTING_LAYER, SOUTHWEST)
	barrier_images += image('hippiestation/icons/effects/effects.dmi', locate(sx + range + 1, sy - range - 1, sz), "barrier", ABOVE_LIGHTING_LAYER, NORTHWEST)
	barrier_images += image('hippiestation/icons/effects/effects.dmi', locate(sx - range - 1, sy - range - 1, sz), "barrier", ABOVE_LIGHTING_LAYER, NORTHEAST)
	for(var/image/I in barrier_images)
		I.layer = ABOVE_LIGHTING_LAYER
		I.plane = ABOVE_LIGHTING_PLANE
		client.images += I

/mob/living/simple_animal/hostile/guardian/proc/setthemename(pickedtheme) //set the guardian's theme to something cool!
	if(!pickedtheme)
		pickedtheme = pick("magic", "tech", "carp")
	var/list/possible_names = list()
	switch(pickedtheme)
		if("magic")
			for(var/type in (subtypesof(/datum/guardianname/magic) - namedatum.type))
				possible_names += new type
		if("tech")
			for(var/type in (subtypesof(/datum/guardianname/tech) - namedatum.type))
				possible_names += new type
		if("carp")
			for(var/type in (subtypesof(/datum/guardianname/carp) - namedatum.type))
				possible_names += new type
	namedatum = pick(possible_names)
	updatetheme(pickedtheme)

/mob/living/simple_animal/hostile/guardian/proc/updatetheme(theme) //update the guardian's theme to whatever its datum is; proc for adminfuckery
	name = "[namedatum.prefixname] [namedatum.suffixcolour]"
	real_name = "[name]"
	icon_living = "[namedatum.parasiteicon]"
	icon_state = "[namedatum.parasiteicon]"
	icon_dead = "[namedatum.parasiteicon]"
	bubble_icon = "[namedatum.bubbleicon]"

	if (namedatum.stainself)
		add_atom_colour(namedatum.colour, FIXED_COLOUR_PRIORITY)

	//Special case holocarp, because #snowflake code
	if(theme == "carp")
		speak_emote = list("gnashes")
		desc = "A mysterious fish that stands by its charge, ever vigilant."

		attacktext = "bites"
		attack_sound = 'sound/weapons/bite.ogg'


/mob/living/simple_animal/hostile/guardian/Login() //if we have a mind, set its name to ours when it logs in
	..()
	if(mind)
		mind.name = "[real_name]"
	if(!summoner)
		to_chat(src, "<span class='holoparasite bold'>For some reason, somehow, you have no summoner. Please report this bug immediately.</span>")
		return
	to_chat(src, "<span class='holoparasite'>You are <font color=\"[namedatum.colour]\"><b>[real_name]</b></font>, bound to serve [summoner.real_name].</span>")
	to_chat(src, "<span class='holoparasite'>You are capable of manifesting or recalling to your master with the buttons on your HUD. You will also find a button to communicate with [summoner.p_them()] privately there.</span>")
	to_chat(src, "<span class='holoparasite'>While personally invincible, you will die if [summoner.real_name] does, and any damage dealt to you will have a portion passed on to [summoner.p_them()] as you feed upon [summoner.p_them()] to sustain yourself.</span>")
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/Life() //Dies if the summoner dies
	. = ..()
	update_health_hud() //we need to update all of our health displays to match our summoner and we can't practically give the summoner a hook to do it
	med_hud_set_health()
	med_hud_set_status()
	if(berserk)
		return
	if(!QDELETED(summoner))
		if(summoner.stat == DEAD)
			if(transforming)
				GoBerserk()
			else
				forceMove(summoner.loc)
				to_chat(src, "<span class='danger'>Your summoner has died!</span>")
				visible_message("<span class='danger'><B>\The [src] dies along with its user!</B></span>")
				summoner.visible_message("<span class='danger'><B>[summoner]'s body is completely consumed by the strain of sustaining [src]!</B></span>")
				for(var/obj/item/W in summoner)
					if(!summoner.dropItemToGround(W))
						qdel(W)
				summoner.dust()
				death(TRUE)
				qdel(src)
	else
		if(transforming)
			GoBerserk()
		else
			to_chat(src, "<span class='danger'>Your summoner has died!</span>")
			visible_message("<span class='danger'><B>[src] dies along with its user!</B></span>")
			death(TRUE)
			qdel(src)
	snapback()

/mob/living/simple_animal/hostile/guardian/proc/OnMoved()
	snapback()
	setup_barriers()

/mob/living/simple_animal/hostile/guardian/proc/GoBerserk()
	UnregisterSignal(summoner, COMSIG_MOVABLE_MOVED)
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
		mind.announce_objectives()
	if(stats.ability)
		stats.ability.Berserk()

/mob/living/simple_animal/hostile/guardian/Stat()
	..()
	if(statpanel("Status"))
		if(summoner)
			var/resulthealth
			if(iscarbon(summoner))
				resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
			else
				resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
			stat(null, "Summoner Health: [resulthealth]%")
		if(cooldown >= world.time)
			stat(null, "Manifest/Recall Cooldown Remaining: [DisplayTimeText(cooldown - world.time)]")
		if(stats.ability)
			stats.ability.Stat()

/mob/living/simple_animal/hostile/guardian/Move() //Returns to summoner if they move out of range
	pixel_x = initial(pixel_x)
	pixel_y = initial(pixel_y)
	layer = initial(layer)
	if(stats && stats.range == 1 && range != 255 && is_deployed())
		if(istype(summoner.loc, /obj/effect))
			Recall(TRUE)
		else
			alpha = 128
			forceMove(summoner.loc)
			setDir(summoner.dir)
			switch(dir)
				if(NORTH)
					pixel_y = -16
					layer = summoner.layer + 0.1
				if(SOUTH)
					pixel_y = 16
					layer = summoner.layer - 0.1
				if(EAST)
					pixel_x = -16
					layer = summoner.layer
				if(WEST)
					pixel_x = 16
					layer = summoner.layer
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
	if(summoner)
		if(stats && stats.range == 1 && range != 255 && is_deployed())
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				alpha = 128
				forceMove(summoner.loc)
				setDir(summoner.dir)
				switch(dir)
					if(NORTH)
						pixel_y = -16
						layer = summoner.layer + 0.1
					if(SOUTH)
						pixel_y = 16
						layer = summoner.layer - 0.1
					if(EAST)
						pixel_x = -16
						layer = summoner.layer
					if(WEST)
						pixel_x = 16
						layer = summoner.layer
			return
		if(get_dist(get_turf(summoner),get_turf(src)) <= range)
			return
		else
			to_chat(src, "<span class='holoparasite'>You moved out of range, and were pulled back! You can only move [range] meters from [summoner.real_name]!</span>")
			visible_message("<span class='danger'>\The [src] jumps back to its user.</span>")
			if(istype(summoner.loc, /obj/effect))
				Recall(TRUE)
			else
				new /obj/effect/temp_visual/guardian/phase/out(loc)
				forceMove(summoner.loc)
				new /obj/effect/temp_visual/guardian/phase(loc)

/mob/living/simple_animal/hostile/guardian/canSuicide()
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/is_deployed()
	return loc != summoner

/mob/living/simple_animal/hostile/guardian/Shoot(atom/targeted_atom)
	if( QDELETED(targeted_atom) || targeted_atom == targets_from.loc || targeted_atom == targets_from )
		return
	var/turf/startloc = get_turf(targets_from)
	var/obj/item/projectile/P = new /obj/item/projectile/guardian(startloc)
	playsound(src, projectilesound, 100, 1)
	if(namedatum)
		P.color = namedatum.colour
	P.damage = stats.damage * 1.5
	P.starting = startloc
	P.firer = src
	P.fired_from = src
	P.yo = targeted_atom.y - startloc.y
	P.xo = targeted_atom.x - startloc.x
	if(AIStatus != AI_ON)//Don't want mindless mobs to have their movement screwed up firing in space
		newtonian_move(get_dir(targeted_atom, targets_from))
	P.original = targeted_atom
	P.preparePixelProjectile(targeted_atom, src)
	P.fire()
	return P

/mob/living/simple_animal/hostile/guardian/RangedAttack(atom/A, params)
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return
	if(erased_time)
		to_chat(src, "<span class='danger'>There is no time, and you cannot intefere!</span>")
		return
	if(stats.ability && stats.ability.RangedAttack(A))
		return
	return ..()

/mob/living/simple_animal/hostile/guardian/AttackingTarget()
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return FALSE
	if(erased_time)
		to_chat(src, "<span class='danger'>There is no time, and you cannot intefere!</span>")
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
		else if(target == summoner)
			to_chat(src, "<span class='danger'><B>You can't attack your summoner!</span></B>")
			return FALSE
		. = ..()
		if(isliving(target))
			say("[battlecry]!!", ignore_spam = TRUE)
			playsound(loc, src.attack_sound, 50, 1, 1)
		changeNext_move(atk_cooldown)
		if(stats.ability)
			stats.ability.AfterAttack(target)

/*/mob/living/simple_animal/hostile/guardian/CanMobAutoclick(object, location, params)
	if(istype(object, /obj/screen) || istype(object, /obj/effect))
		return FALSE
	if(erased_time)
		return FALSE
	return atk_cooldown*/

/mob/living/simple_animal/hostile/guardian/death()
	..()
	if(summoner)
		to_chat(summoner, "<span class='danger'><B>Your [name] died somehow!</span></B>")
		summoner.death()

/mob/living/simple_animal/hostile/guardian/update_health_hud()
	if(summoner && hud_used && hud_used.healths)
		var/resulthealth
		if(iscarbon(summoner))
			resulthealth = round((abs(HEALTH_THRESHOLD_DEAD - summoner.health) / abs(HEALTH_THRESHOLD_DEAD - summoner.maxHealth)) * 100)
		else
			resulthealth = round((summoner.health / summoner.maxHealth) * 100, 0.5)
		hud_used.healths.maptext = "<div align='center' valign='middle' style='position:relative; top:0px; left:6px'><font color='#efeeef'>[resulthealth]%</font></div>"

/mob/living/simple_animal/hostile/guardian/adjustHealth(amount, updating_health = TRUE, forced = FALSE) //The spirit is invincible, but passes on damage to the summoner
	if(berserk)
		return ..()
	. = amount
	if(summoner)
		if(loc == summoner)
			return FALSE
		summoner.adjustBruteLoss(amount)
		if(amount > 0)
			to_chat(summoner, "<span class='danger'><B>Your [name] is under attack! You take damage!</span></B>")
			if(summoner_visible)
				summoner.visible_message("<span class='danger'><B>Blood sprays from [summoner] as [src] takes damage!</B></span>")
			if(summoner.stat == UNCONSCIOUS)
				to_chat(summoner, "<span class='danger'><B>Your body can't take the strain of sustaining [src] in this condition, it begins to fall apart!</span></B>")
				summoner.adjustCloneLoss(amount * 0.5) //dying hosts take 50% bonus damage as cloneloss
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

/mob/living/simple_animal/hostile/guardian/gib()
	if(summoner)
		to_chat(summoner, "<span class='danger'><B>Your [src] was blown up!</span></B>")
		summoner.gib()
	ghostize()
	qdel(src)

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
	if(istype(summoner.loc, /obj/effect) || (cooldown > world.time && !forced))
		return FALSE
	if(stats.ability && stats.ability.Manifest())
		return TRUE
	if(loc == summoner)
		forceMove(summoner.loc)
		if(do_the_cool_invisible_thing)
			alpha = 64
		new /obj/effect/temp_visual/guardian/phase(loc)
		cooldown = world.time + 10
		reset_perspective()
		setup_barriers()
		return TRUE
	return FALSE

/mob/living/simple_animal/hostile/guardian/proc/Recall(forced)
	if(transforming)
		to_chat(src, "<span class='holoparasite italics'>No... no... you can't!</span>")
		return FALSE
	if(!summoner || loc == summoner || (cooldown > world.time && !forced))
		return FALSE
	if(stats.ability && stats.ability.Recall())
		return TRUE
	new /obj/effect/temp_visual/guardian/phase/out(loc)
	forceMove(summoner)
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
	if(stats.ability.recall_mode && (loc != summoner))
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
	if(light_range<3)
		to_chat(src, "<span class='notice'>You activate your light.</span>")
		set_light(3)
	else
		to_chat(src, "<span class='notice'>You deactivate your light.</span>")
		set_light(0)

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
	if(summoner)
		var/input = stripped_input(src, "Please enter a message to tell your summoner.", "Guardian", "")
		if(!input)
			return

		var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
		var/my_message = "<font color=\"[namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" //add source, color source with the guardian's color

		to_chat(summoner, my_message)
		var/list/guardians = summoner.hasparasites()
		for(var/para in guardians)
			to_chat(para, my_message)
		for(var/M in GLOB.dead_mob_list)
			var/link = FOLLOW_LINK(M, src)
			to_chat(M, "[link] [my_message]")

		src.log_talk(input, LOG_SAY, tag="guardian")

/mob/living/proc/guardian_comm()
	set name = "Communicate"
	set category = "Guardian"
	set desc = "Communicate telepathically with your guardian."
	var/input = stripped_input(src, "Please enter a message to tell your guardian.", "Message", "")
	if(!input)
		return

	var/preliminary_message = "<span class='holoparasite bold'>[input]</span>" //apply basic color/bolding
	var/my_message = "<span class='holoparasite bold'><i>[src]:</i> [preliminary_message]</span>" //add source, color source with default grey...

	to_chat(src, my_message)
	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/G = para
		to_chat(G, "<font color=\"[G.namedatum.colour]\"><b><i>[src]:</i></b></font> [preliminary_message]" )
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
	set name = "Reset Guardian Player (One Use)"
	set category = "Guardian"
	set desc = "Re-rolls which ghost will control your Guardian. One use per Guardian."

	var/list/guardians = hasparasites()
	for(var/para in guardians)
		var/mob/living/simple_animal/hostile/guardian/P = para
		if(P.reset)
			guardians -= P //clear out guardians that are already reset
	if(guardians.len)
		var/mob/living/simple_animal/hostile/guardian/G = input(src, "Pick the guardian you wish to reset", "Guardian Reset") as null|anything in guardians
		if(G)
			to_chat(src, "<span class='holoparasite'>You attempt to reset <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>'s personality...</span>")
			var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as [src.real_name]'s [G.real_name]?", ROLE_HOLOPARASITE, null, FALSE, 100)
			if(LAZYLEN(candidates))
				var/mob/dead/observer/C = pick(candidates)
				to_chat(G, "<span class='holoparasite'>Your user reset you, and your body was taken over by a ghost. Looks like they weren't happy with your performance.</span>")
				to_chat(src, "<span class='holoparasite bold'>Your <font color=\"[G.namedatum.colour]\">[G.real_name]</font> has been successfully reset.</span>")
				log_game("[key_name(src)] has reset their holoparasite, it is now [key_name(G)].")
				G.ghostize(0)
				if(!G.custom_name)
					G.setthemename(G.namedatum.theme) //give it a new color, to show it's a new person
				G.key = C.key
				G.reset = TRUE
				switch(G.namedatum.theme)
					if("tech")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> is now online!</span>")
					if("magic")
						to_chat(src, "<span class='holoparasite'><font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font> has been summoned!</span>")
				guardians -= G
				if(!guardians.len)
					verbs -= /mob/living/proc/guardian_reset
			else
				to_chat(src, "<span class='holoparasite'>There were no ghosts willing to take control of <font color=\"[G.namedatum.colour]\"><b>[G.real_name]</b></font>. Looks like you're stuck with it for now.</span>")
		else
			to_chat(src, "<span class='holoparasite'>You decide not to reset [guardians.len > 1 ? "any of your guardians":"your guardian"].</span>")
	else
		verbs -= /mob/living/proc/guardian_reset

////////parasite tracking/finding procs

/mob/living/proc/hasparasites() //returns a list of guardians the mob is a summoner for
	. = list()
	for(var/P in GLOB.parasites)
		var/mob/living/simple_animal/hostile/guardian/G = P
		if(G.summoner == src)
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
