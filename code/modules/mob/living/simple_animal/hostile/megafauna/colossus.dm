/*

COLOSSUS

The colossus spawns randomly wherever a lavaland creature is able to spawn. It is powerful, ancient, and extremely deadly.
The colossus has a degree of sentience, proving this in speech during its attacks.

It acts as a melee creature, chasing down and attacking its target while also using different attacks to augment its power that increase as it takes damage.

The colossus' true danger lies in its ranged capabilities. It fires immensely damaging death bolts that penetrate all armor in a variety of ways:
	1. The colossus fires death bolts in alternating patterns: the cardinal directions and the diagonal directions.
	2. The colossus fires death bolts in a shotgun-like pattern, instantly downing anything unfortunate enough to be hit by all of them.
	3. The colossus fires a spiral of death bolts.
	At 33% health, the colossus gains an additional attack:
	4. The colossus fires two spirals of death bolts, spinning in opposite directions.

When a colossus dies, it leaves behind a chunk of glowing crystal known as a black box. Anything placed inside will carry over into future rounds.
For instance, you could place a bag of holding into the black box, and then kill another colossus next round and retrieve the bag of holding from inside.

Difficulty: Very Hard

*/

/mob/living/simple_animal/hostile/megafauna/colossus
	name = "colossus"
	desc = "A monstrous creature protected by heavy shielding."
	health = 1250
	maxHealth = 1250
	attack_verb_continuous = "judges"
	attack_verb_simple = "judge"
	attack_sound = 'sound/magic/clockwork/ratvar_attack.ogg'
	icon_state = "eva"
	icon_living = "eva"
	icon_dead = ""
	friendly_verb_continuous = "stares down"
	friendly_verb_simple = "stare down"
	icon = 'icons/mob/lavaland/96x96megafauna.dmi'
	speak_emote = list("roars")
	armour_penetration = 40
	melee_damage = 40
	speed = 10
	move_to_delay = 10
	ranged = TRUE
	pixel_x = -32
	base_pixel_x = -32
	del_on_death = TRUE
	gps_name = "Angelic Signal"
	achievement_type = /datum/award/achievement/boss/colussus_kill
	crusher_achievement_type = /datum/award/achievement/boss/colussus_crusher
	score_achievement_type = /datum/award/score/colussus_score
	loot = list(/obj/effect/spawner/lootdrop/megafaunaore, /obj/structure/closet/crate/necropolis/colossus)
	deathmessage = "disintegrates, leaving a glowing core in its wake."
	deathsound = 'sound/magic/demon_dies.ogg'
	attack_action_types = list(/datum/action/innate/megafauna_attack/spiral_attack,
							   /datum/action/innate/megafauna_attack/aoe_attack,
							   /datum/action/innate/megafauna_attack/shotgun,
							   /datum/action/innate/megafauna_attack/alternating_cardinals)
	small_sprite_type = /datum/action/small_sprite/megafauna/colossus
	var/invulnerable_finale = FALSE

/mob/living/simple_animal/hostile/megafauna/colossus/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NO_FLOATING_ANIM, ROUNDSTART_TRAIT) //we don't want this guy to float, messes up his animations.

/datum/action/innate/megafauna_attack/spiral_attack
	name = "Spiral Shots"
	icon_icon = 'icons/hud/actions/actions_items.dmi'
	button_icon_state = "sniper_zoom"
	chosen_message = span_colossus("You are now firing in a spiral.")
	chosen_attack_num = 1

/datum/action/innate/megafauna_attack/aoe_attack
	name = "All Directions"
	icon_icon = 'icons/effects/effects.dmi'
	button_icon_state = "at_shield2"
	chosen_message = span_colossus("You are now firing in all directions.")
	chosen_attack_num = 2

/datum/action/innate/megafauna_attack/shotgun
	name = "Shotgun Fire"
	icon_icon = 'icons/obj/guns/projectile.dmi'
	button_icon_state = "shotgun"
	chosen_message = span_colossus("You are now firing shotgun shots where you aim.")
	chosen_attack_num = 3

/datum/action/innate/megafauna_attack/alternating_cardinals
	name = "Alternating Shots"
	icon_icon = 'icons/obj/guns/projectile.dmi'
	button_icon_state = "pistol"
	chosen_message = span_colossus("You are now firing in alternating cardinal directions.")
	chosen_attack_num = 4

/mob/living/simple_animal/hostile/megafauna/colossus/OpenFire()
	ranged_cooldown = world.time + 600 //prevents abilities from being spammed by AttackingTarget() while an attack is already underway.
	anger_modifier = clamp(((maxHealth - health)/20),0,20)

	if(client) //Player controlled handled a bit differently.
		switch(chosen_attack)
			if(1)
				if(health <= maxHealth/10)
					final_attack()
				else
					telegraph()
					say("Judgment")
					visible_message(span_colossus("\"<b>Judgment</b>\""))
					select_spiral_attack()
					ranged_cooldown = world.time + 30
			if(2)
				telegraph()
				say("Wrath")
				visible_message(span_colossus("\"<b>Wrath</b>\""))
				random_shots()
				ranged_cooldown = world.time + 30
			if(3)
				telegraph()
				say("Retribution")
				visible_message(span_colossus("\"<b>Retribution</b>\""))
				blast()
				ranged_cooldown = world.time + 30
			if(4)
				telegraph()
				say("Lament")
				visible_message(span_colossus("\"<b>Lament</b>\""))
				alternating_dir_shots()
				ranged_cooldown = world.time + 30
		return

	if(enrage(target))
		if(move_to_delay == initial(move_to_delay))
			visible_message(span_colossus("\"<b>You can't dodge.</b>\""))
		telegraph()
		dir_shots(GLOB.alldirs)
		move_to_delay = 3
		return
	else
		move_to_delay = initial(move_to_delay)

	switch(random_attack_num)
		if(1)
			select_spiral_attack()
		if(2)
			random_shots()
		if(3)
			blast()
		if(4)
			alternating_dir_shots()
		if(5)
			final_attack()

	if(health <= maxHealth/10) 					//Ultimate attack guaranteed at below 10% HP
		say("Die..")
		visible_message(span_colossus("\"<b>Die..</b>\""))
		random_attack_num = 5
	else if(prob(20+anger_modifier))			//If more than 10% HP, determine next attack randomly
		say("Judgment")
		visible_message(span_colossus("\"<b>Judgment</b>\""))
		random_attack_num = 1
	else
		switch(rand(1, 3))
			if(1)
				say("Wrath")
				visible_message(span_colossus("\"<b>Wrath</b>\""))
				random_attack_num = 2
			if(2)
				say("Retribution")
				visible_message(span_colossus("\"<b>Retribution</b>\""))
				random_attack_num = 3
			if(3)
				say("Lament")
				visible_message(span_colossus("\"<b>Lament</b>\""))
				random_attack_num = 4
	telegraph()
	ranged_cooldown = world.time + 30

/mob/living/simple_animal/hostile/megafauna/colossus/proc/enrage(mob/living/L)
	if(ishuman(L))
		var/mob/living/carbon/human/H = L
		if(H.mind)
			if(istype(H.mind.martial_art, /datum/martial_art/the_sleeping_carp))
				. = TRUE

/mob/living/simple_animal/hostile/megafauna/colossus/proc/alternating_dir_shots()
	dir_shots(GLOB.diagonals)
	sleep(10)
	dir_shots(GLOB.cardinals)
	sleep(10)
	dir_shots(GLOB.diagonals)
	sleep(10)
	dir_shots(GLOB.cardinals)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/select_spiral_attack()
	if(health <= maxHealth/3)
		return double_spiral()
	return spiral_shoot()

/mob/living/simple_animal/hostile/megafauna/colossus/proc/double_spiral()
	SLEEP_CHECK_DEATH(10)
	INVOKE_ASYNC(src, PROC_REF(spiral_shoot), FALSE, 16)
	spiral_shoot(FALSE, 8)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/final_attack() //not actually necessarily the final attack, but has a very long cooldown.
	var/finale_counter = 10
	var/turf/U = get_turf(src)
	invulnerable_finale = TRUE
	for(var/i in 1 to 20)
		if(finale_counter > 4)
			telegraph()
			say("Die!!")
			visible_message(span_colossus("\"<b>Die!</b>\""))
			blast()
		if(finale_counter > 1)
			finale_counter--
		for(var/T in RANGE_TURFS(12, U) - U)
			if(prob(min(finale_counter, 2)))
				shoot_projectile(T)
		sleep(finale_counter + 1)
	for(var/ii in 1 to 3)
		telegraph()
		say("Die")
		visible_message(span_colossus("\"<b>Die..</b>\""))
		random_shots()
		finale_counter += 6
		sleep(finale_counter)
	for(var/iii in 1 to 4)
		telegraph()
		say("Die..")
		visible_message(span_colossus("\"<b>Die..</b>\""))
		invulnerable_finale = FALSE
		sleep(30) //Long cooldown (total 15 seconds with one last 30 applied in ) after this attack finally concludes

/mob/living/simple_animal/hostile/megafauna/colossus/proc/spiral_shoot(negative = pick(TRUE, FALSE), counter_start = 8)
	var/turf/start_turf = get_step(src, pick(GLOB.alldirs))
	var/counter = counter_start
	for(var/i in 1 to 80)
		if(negative)
			counter--
		else
			counter++
		if(counter > 16)
			counter = 1
		if(counter < 1)
			counter = 16
		shoot_projectile(start_turf, counter * 22.5)
		playsound(get_turf(src), 'sound/magic/clockwork/invoke_general.ogg', 20, 1)
		sleep(1)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/shoot_projectile(turf/marker, set_angle)
	if(!isnum_safe(set_angle) && (!marker || marker == loc))
		return
	var/turf/startloc = get_turf(src)
	var/obj/projectile/P = new /obj/projectile/colossus(startloc)
	P.preparePixelProjectile(marker, startloc)
	P.firer = src
	if(target)
		P.original = target
	P.fire(set_angle)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/random_shots()
	var/turf/U = get_turf(src)
	playsound(U, 'sound/magic/clockwork/invoke_general.ogg', 300, 1, 5)
	for(var/T in RANGE_TURFS(12, U) - U)
		if(prob(5))
			shoot_projectile(T)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/blast(set_angle)
	var/turf/target_turf = get_turf(target)
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	newtonian_move(get_dir(target_turf, src))
	var/angle_to_target = get_angle(src, target_turf)
	if(isnum_safe(set_angle))
		angle_to_target = set_angle
	var/static/list/colossus_shotgun_shot_angles = list(12.5, 7.5, 2.5, -2.5, -7.5, -12.5)
	for(var/i in colossus_shotgun_shot_angles)
		shoot_projectile(target_turf, angle_to_target + i)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/dir_shots(list/dirs)
	if(!islist(dirs))
		dirs = GLOB.alldirs.Copy()
	playsound(src, 'sound/magic/clockwork/invoke_general.ogg', 200, 1, 2)
	for(var/d in dirs)
		var/turf/E = get_step(src, d)
		shoot_projectile(E)

/mob/living/simple_animal/hostile/megafauna/colossus/proc/telegraph()
	for(var/mob/M in range(10,src))
		if(M.client)
			flash_color(M.client, "#C80000", 1)
			shake_camera(M, 4, 3)
	playsound(src, 'sound/magic/clockwork/narsie_attack.ogg', 200, 1)

/obj/effect/temp_visual/at_shield
	name = "anti-toolbox field"
	desc = "A shimmering forcefield protecting the colossus."
	icon = 'icons/effects/effects.dmi'
	icon_state = "at_shield2"
	layer = FLY_LAYER
	light_system = MOVABLE_LIGHT
	light_range = 2
	duration = 8
	var/target

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/temp_visual/at_shield)

/obj/effect/temp_visual/at_shield/Initialize(mapload, new_target)
	. = ..()
	target = new_target
	INVOKE_ASYNC(src, /atom/movable/proc/orbit, target, 0, FALSE, 0, 0, FALSE, TRUE)

/mob/living/simple_animal/hostile/megafauna/colossus/bullet_act(obj/projectile/P)
	if(!stat)
		var/obj/effect/temp_visual/at_shield/AT = new /obj/effect/temp_visual/at_shield(loc, src)
		var/random_x = rand(-32, 32)
		AT.pixel_x += random_x

		var/random_y = rand(0, 72)
		AT.pixel_y += random_y
	return ..()

/obj/projectile/colossus
	name ="death bolt"
	icon_state= "chronobolt"
	damage = 25
	armour_penetration = 100
	speed = 2
	eyeblur = 0
	damage_type = BRUTE
	pass_flags = PASSTABLE

/obj/projectile/colossus/on_hit(atom/target, blocked = FALSE)
	. = ..()
	if(isturf(target) || isobj(target))
		if(isobj(target))
			SSexplosions.med_mov_atom += target
		else
			SSexplosions.medturf += target


//There can only ever be one blackbox, and we want to know if there already is one when we spawn
GLOBAL_DATUM(blackbox, /obj/machinery/smartfridge/black_box)

//Black Box

/obj/machinery/smartfridge/black_box
	name = "black box"
	desc = "A completely indestructible chunk of crystal, rumoured to predate the start of this universe. It looks like you could store things inside it."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blackbox"
	light_range = 8
	max_n_of_items = INFINITY
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	pixel_y = -4
	use_power = NO_POWER_USE
	opacity = FALSE
	base_build_path = /obj/machinery/smartfridge/black_box
	var/memory_saved = FALSE
	var/list/stored_items = list()
	var/list/blacklist = list()

/obj/machinery/smartfridge/black_box/update_icon()
	return

/obj/machinery/smartfridge/black_box/accept_check(obj/item/O)
	if(!istype(O))
		return FALSE
	if(blacklist[O])
		visible_message(span_boldwarning("[src] ripples as it rejects [O]. The device will not accept items that have been removed from it."))
		return FALSE
	return TRUE

/obj/machinery/smartfridge/black_box/Initialize(mapload)
	. = ..()
	if(GLOB.blackbox != src)
		return INITIALIZE_HINT_QDEL
	GLOB.blackbox = src
	ReadMemory()

/obj/machinery/smartfridge/black_box/process()
	..()
	if(!memory_saved && SSticker.current_state == GAME_STATE_FINISHED)
		WriteMemory()
		memory_saved = TRUE

/obj/machinery/smartfridge/black_box/proc/WriteMemory()
	var/json_file = file("data/npc_saves/Blackbox.json")
	stored_items = list()

	for(var/obj/O in (contents-component_parts))
		stored_items += O.type
	var/list/file_data = list()
	file_data["data"] = stored_items
	fdel(json_file)
	WRITE_FILE(json_file, json_encode(file_data))

/obj/machinery/smartfridge/black_box/proc/ReadMemory()
	if(fexists("data/npc_saves/Blackbox.sav")) //legacy compatability to convert old format to new
		var/savefile/S = new /savefile("data/npc_saves/Blackbox.sav")
		S["stored_items"] >> stored_items
		fdel("data/npc_saves/Blackbox.sav")
	else
		var/json_file = file("data/npc_saves/Blackbox.json")
		if(!fexists(json_file))
			return
		var/list/json = json_decode(rustg_file_read(json_file))
		stored_items = json["data"]
	if(isnull(stored_items))
		stored_items = list()

	for(var/item in stored_items)
		create_item(item)

//in it's own proc to avoid issues with items that nolonger exist in the code base.
//try catch doesn't always prevent byond runtimes from halting a proc,
/obj/machinery/smartfridge/black_box/proc/create_item(item_type)
	var/obj/O = new item_type(src)
	blacklist[O] = TRUE

/obj/machinery/smartfridge/black_box/Destroy(force = FALSE)
	if(force)
		if(GLOB.blackbox == src)
			GLOB.blackbox = null
		for(var/thing in src)
			qdel(thing)
		return ..()
	else
		return QDEL_HINT_LETMELIVE


//No taking it apart

/obj/machinery/smartfridge/black_box/default_deconstruction_screwdriver()
	return

/obj/machinery/smartfridge/black_box/exchange_parts()
	return


/obj/machinery/smartfridge/black_box/default_pry_open()
	return


/obj/machinery/smartfridge/black_box/default_unfasten_wrench()
	return

/obj/machinery/smartfridge/black_box/default_deconstruction_crowbar()
	return

///Anomolous Crystal///

#define ACTIVATE_TOUCH "touch"
#define ACTIVATE_SPEECH "speech"
#define ACTIVATE_HEAT "heat"
#define ACTIVATE_BULLET "bullet"
#define ACTIVATE_ENERGY "energy"
#define ACTIVATE_BOMB "bomb"
#define ACTIVATE_MOB_BUMP "bumping"
#define ACTIVATE_WEAPON "weapon"
#define ACTIVATE_MAGIC "magic"

/obj/machinery/anomalous_crystal
	name = "anomalous crystal"
	desc = "A strange chunk of crystal, being in the presence of it fills you with equal parts excitement and dread."
	var/observer_desc = "Anomalous crystals have descriptions that only observers can see. But this one hasn't been changed from the default."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "anomaly_crystal"
	light_range = 8
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	use_power = NO_POWER_USE
	anchored = FALSE
	density = TRUE
	var/activation_method
	var/list/possible_methods = list(ACTIVATE_TOUCH, ACTIVATE_SPEECH, ACTIVATE_HEAT, ACTIVATE_BULLET, ACTIVATE_ENERGY, ACTIVATE_BOMB, ACTIVATE_MOB_BUMP, ACTIVATE_WEAPON, ACTIVATE_MAGIC)

	var/activation_damage_type = null
	var/last_use_timer = 0
	var/cooldown_add = 30
	var/list/affected_targets = list()
	var/activation_sound = 'sound/effects/break_stone.ogg'

/obj/machinery/anomalous_crystal/Initialize(mapload)
	. = ..()
	if(!activation_method)
		activation_method = pick(possible_methods)
	become_hearing_sensitive(trait_source = ROUNDSTART_TRAIT)

/obj/machinery/anomalous_crystal/examine(mob/user)
	. = ..()
	if(isobserver(user))
		. += observer_desc
		. += "It is activated by [activation_method]."

/obj/machinery/anomalous_crystal/Hear(message, atom/movable/speaker, message_langs, raw_message, radio_freq, spans, list/message_mods = list())
	..()
	if(isliving(speaker))
		ActivationReaction(speaker, ACTIVATE_SPEECH)

/obj/machinery/anomalous_crystal/attack_hand(mob/user, list/modifiers)
	. = ..()
	if(.)
		return
	ActivationReaction(user, ACTIVATE_TOUCH)

/obj/machinery/anomalous_crystal/attackby(obj/item/I, mob/user, params)
	if(I.is_hot())
		ActivationReaction(user, ACTIVATE_HEAT)
	else
		ActivationReaction(user, ACTIVATE_WEAPON)
	..()

/obj/machinery/anomalous_crystal/bullet_act(obj/projectile/P, def_zone)
	. = ..()
	if(istype(P, /obj/projectile/magic))
		ActivationReaction(P.firer, ACTIVATE_MAGIC, P.damage_type)
		return
	ActivationReaction(P.firer, P.armor_flag, P.damage_type)

/obj/machinery/anomalous_crystal/proc/ActivationReaction(mob/user, method, damtype)
	if(world.time < last_use_timer)
		return FALSE
	if(activation_damage_type && activation_damage_type != damtype)
		return FALSE
	if(method != activation_method)
		return FALSE
	last_use_timer = (world.time + cooldown_add)
	playsound(user, activation_sound, 100, 1)
	return TRUE

/obj/machinery/anomalous_crystal/Bumped(atom/movable/AM)
	..()
	if(ismob(AM))
		ActivationReaction(AM, ACTIVATE_MOB_BUMP)

/obj/machinery/anomalous_crystal/ex_act()
	ActivationReaction(null, ACTIVATE_BOMB)

/obj/machinery/anomalous_crystal/honk //Strips and equips you as a clown. I apologize for nothing
	observer_desc = "This crystal strips and equips its targets as clowns."
	possible_methods = list(ACTIVATE_MOB_BUMP, ACTIVATE_SPEECH)
	activation_sound = 'sound/items/bikehorn.ogg'

/obj/machinery/anomalous_crystal/honk/ActivationReaction(mob/user)
	if(..() && ishuman(user) && !(user in affected_targets))
		var/mob/living/carbon/human/H = user
		for(var/obj/item/W in H)
			H.dropItemToGround(W)
		var/datum/job/C = SSjob.GetJob(JOB_NAME_CLOWN)
		C.equip(H)
		affected_targets.Add(H)

/obj/machinery/anomalous_crystal/theme_warp //Warps the area you're in to look like a new one
	observer_desc = "This crystal warps the area around it to a theme."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 200
	var/terrain_theme = "winter"
	var/NewTerrainFloors
	var/NewTerrainWalls
	var/NewTerrainChairs
	var/NewTerrainTables
	var/list/NewFlora = list()
	var/florachance = 8

/obj/machinery/anomalous_crystal/theme_warp/Initialize(mapload)
	. = ..()
	terrain_theme = pick("lavaland","winter","jungle","ayy lmao")
	observer_desc = "This crystal changes the area around it to match the theme of \"[terrain_theme]\"."

	switch(terrain_theme)
		if("lavaland")//Depressurizes the place... and free cult metal, I guess.
			NewTerrainFloors = /turf/open/floor/grass/snow/basalt
			NewTerrainWalls = /turf/closed/wall/mineral/cult
			NewFlora = list(/mob/living/simple_animal/hostile/asteroid/goldgrub)
			florachance = 1
		if("winter") //Snow terrain is slow to move in and cold! Get the assistants to shovel your driveway.
			NewTerrainFloors = /turf/open/floor/grass/snow
			NewTerrainWalls = /turf/closed/wall/mineral/wood
			NewTerrainChairs = /obj/structure/chair/wood/normal
			NewTerrainTables = /obj/structure/table/glass
			NewFlora = list(/obj/structure/flora/grass/green, /obj/structure/flora/grass/brown, /obj/structure/flora/grass/both)
		if("jungle") //Beneficial due to actually having breathable air. Plus, monkeys and bows and arrows.
			NewTerrainFloors = /turf/open/floor/grass
			NewTerrainWalls = /turf/closed/wall/mineral/sandstone
			NewTerrainChairs = /obj/structure/chair/wood
			NewTerrainTables = /obj/structure/table/wood
			NewFlora = list(/obj/structure/flora/ausbushes/sparsegrass, /obj/structure/flora/ausbushes/fernybush, /obj/structure/flora/ausbushes/leafybush,
							/obj/structure/flora/ausbushes/grassybush, /obj/structure/flora/ausbushes/sunnybush, /obj/structure/flora/tree/palm, /mob/living/carbon/monkey)
			florachance = 20
		if("ayy lmao") //Beneficial, turns stuff into alien alloy which is useful to cargo and research. Also repairs atmos.
			NewTerrainFloors = /turf/open/floor/plating/abductor
			NewTerrainWalls = /turf/closed/wall/mineral/abductor
			NewTerrainChairs = /obj/structure/bed/abductor //ayys apparently don't have chairs. An entire species of people who only recline.
			NewTerrainTables = /obj/structure/table/abductor

/obj/machinery/anomalous_crystal/theme_warp/ActivationReaction(mob/user, method)
	if(..())
		var/area/A = get_area(src)
		if(!A.outdoors && !(A in affected_targets))
			for(var/atom/Stuff in A)
				if(isturf(Stuff))
					var/turf/T = Stuff
					if((isspaceturf(T) || isfloorturf(T)) && NewTerrainFloors)
						var/turf/open/O = T.ChangeTurf(NewTerrainFloors, flags = CHANGETURF_INHERIT_AIR)
						if(prob(florachance) && NewFlora.len && !O.is_blocked_turf(TRUE))
							var/atom/Picked = pick(NewFlora)
							new Picked(O)
						continue
					if(iswallturf(T) && NewTerrainWalls)
						T.ChangeTurf(NewTerrainWalls)
						continue
				if(istype(Stuff, /obj/structure/chair) && NewTerrainChairs)
					var/obj/structure/chair/Original = Stuff
					var/obj/structure/chair/C = new NewTerrainChairs(Original.loc)
					C.setDir(Original.dir)
					qdel(Stuff)
					continue
				if(istype(Stuff, /obj/structure/table) && NewTerrainTables)
					new NewTerrainTables(Stuff.loc)
					continue
			affected_targets += A

/obj/machinery/anomalous_crystal/emitter //Generates a projectile when interacted with
	observer_desc = "This crystal generates a projectile when activated."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 50
	var/obj/projectile/generated_projectile = /obj/projectile/beam/emitter

/obj/machinery/anomalous_crystal/emitter/Initialize(mapload)
	. = ..()
	generated_projectile = pick(/obj/projectile/colossus)

	var/proj_name = initial(generated_projectile.name)
	observer_desc = "This crystal generates \a [proj_name] when activated."

/obj/machinery/anomalous_crystal/emitter/ActivationReaction(mob/user, method)
	if(..())
		var/obj/projectile/P = new generated_projectile(get_turf(src))
		P.setDir(dir)
		switch(dir)
			if(NORTH)
				P.yo = 20
				P.xo = 0
			if(EAST)
				P.yo = 0
				P.xo = 20
			if(WEST)
				P.yo = 0
				P.xo = -20
			else
				P.yo = -20
				P.xo = 0
		P.fire()

/obj/machinery/anomalous_crystal/dark_reprise //Revives anyone nearby, but turns them into shadowpeople and renders them uncloneable, so the crystal is your only hope of getting up again if you go down.
	observer_desc = "When activated, this crystal revives anyone nearby, but turns them into Shadowpeople and makes them unclonable, making the crystal their only hope of getting up again."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/hallucinations/growl1.ogg'

/obj/machinery/anomalous_crystal/dark_reprise/ActivationReaction(mob/user, method)
	if(..())
		for(var/i in range(1, src))
			if(isturf(i))
				new /obj/effect/temp_visual/cult/sparks(i)
				continue
			if(ishuman(i))
				var/mob/living/carbon/human/H = i
				if(H.stat == DEAD)
					H.set_species(/datum/species/shadow, 1)
					H.regenerate_limbs()
					H.regenerate_organs()
					H.revive(1,0)
					ADD_TRAIT(H, TRAIT_BADDNA, MAGIC_TRAIT) //Free revives, but significantly limits your options for reviving except via the crystal
					H.grab_ghost(force = TRUE)

/obj/machinery/anomalous_crystal/helpers //Lets ghost spawn as helpful creatures that can only heal people slightly. Incredibly fragile and they can't converse with humans
	observer_desc = "This crystal allows ghosts to turn into a fragile creature that can heal people."
	activation_method = ACTIVATE_TOUCH
	activation_sound = 'sound/effects/ghost2.ogg'
	var/ready_to_deploy = FALSE

/obj/machinery/anomalous_crystal/helpers/ActivationReaction(mob/user, method)
	if(..() && !ready_to_deploy)
		AddElement(/datum/element/point_of_interest)
		ready_to_deploy = TRUE
		notify_ghosts("An anomalous crystal has been activated in [get_area(src)]! This crystal can always be used by ghosts hereafter.", enter_link = "<a href='byond://?src=[REF(src)];ghostjoin=1'>(Click to enter)</a>", ghost_sound = 'sound/effects/ghost2.ogg', source = src, action = NOTIFY_ATTACK, header = "Anomalous crystal activated")

/obj/machinery/anomalous_crystal/helpers/attack_ghost(mob/dead/observer/user)
	. = ..()
	if(.)
		return
	if(ready_to_deploy)
		var/be_helper = alert("Become a Lightgeist? (Warning, You can no longer be cloned!)",,"Yes","No")
		if(be_helper == "Yes" && !QDELETED(src) && isobserver(user))
			var/mob/living/simple_animal/hostile/lightgeist/W = new /mob/living/simple_animal/hostile/lightgeist(get_turf(loc))
			W.key = user.key


/obj/machinery/anomalous_crystal/helpers/Topic(href, href_list)
	if(href_list["ghostjoin"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			attack_ghost(ghost)

/mob/living/simple_animal/hostile/lightgeist
	name = "lightgeist"
	desc = "This small floating creature is a completely unknown form of life... being near it fills you with a sense of tranquility."
	icon_state = "lightgeist"
	icon_living = "lightgeist"
	icon_dead = "butterfly_dead"
	turns_per_move = 1
	response_help_continuous = "waves away"
	response_help_simple = "wave away"
	response_disarm_continuous = "brushes aside"
	response_disarm_simple = "brush aside"
	response_harm_continuous = "disrupts"
	response_harm_simple = "disrupt"
	speak_emote = list("oscillates")
	maxHealth = 2
	health = 2
	friendly_verb_continuous = "mends"
	friendly_verb_simple = "mend"
	density = FALSE
	is_flying_animal = TRUE
	pass_flags = PASSTABLE | PASSGRILLE | PASSMOB
	ventcrawler = VENTCRAWLER_ALWAYS
	mob_size = MOB_SIZE_TINY
	gold_core_spawnable = HOSTILE_SPAWN
	verb_say = "warps"
	verb_ask = "floats inquisitively"
	verb_exclaim = "zaps"
	verb_yell = "bangs"
	initial_language_holder = /datum/language_holder/lightbringer
	damage_coeff = list(BRUTE = 1, BURN = 1, TOX = 0, CLONE = 0, STAMINA = 0, OXY = 0)
	light_range = 4
	faction = list(FACTION_NEUTRAL)
	del_on_death = TRUE
	unsuitable_atmos_damage = 0
	minbodytemp = 0
	maxbodytemp = 1500
	obj_damage = 0
	environment_smash = ENVIRONMENT_SMASH_NONE
	AIStatus = AI_OFF
	stop_automated_movement = TRUE
	var/heal_power = 5

/mob/living/simple_animal/hostile/lightgeist/Initialize(mapload)
	. = ..()
	remove_verb(/mob/living/verb/pulled)
	remove_verb(/mob/verb/me_verb)
	var/datum/atom_hud/medsensor = GLOB.huds[DATA_HUD_MEDICAL_ADVANCED]
	medsensor.add_hud_to(src)

/mob/living/simple_animal/hostile/lightgeist/AttackingTarget()
	. = ..()
	if(isliving(target) && target != src)
		var/mob/living/L = target
		if(L.stat != DEAD)
			L.heal_overall_damage(heal_power, heal_power)
			new /obj/effect/temp_visual/heal(get_turf(target), "#80F5FF")

/mob/living/simple_animal/hostile/lightgeist/ghostize(can_reenter_corpse, sentience_retention)
	. = ..()
	if(.)
		death()

/mob/living/simple_animal/hostile/lightgeist/slime
	name = "crystalline lightgeist"

/obj/machinery/anomalous_crystal/refresher //Deletes and recreates a copy of the item, "refreshing" it.
	observer_desc = "This crystal \"refreshes\" items that it affects, rendering them as new."
	activation_method = ACTIVATE_TOUCH
	cooldown_add = 50
	activation_sound = 'sound/magic/timeparadox2.ogg'
	var/static/list/banned_items_typecache = typecacheof(list(
		/obj/item/storage,
		/obj/item/implant,
		/obj/item/implanter,
		/obj/item/disk/nuclear,
		/obj/projectile,
		/obj/item/spellbook,
		/obj/item/dice/d20/fate
	))

/obj/machinery/anomalous_crystal/refresher/ActivationReaction(mob/user, method)
	if(..())
		var/list/L = list()
		var/turf/T = get_step(src, dir)
		new /obj/effect/temp_visual/emp/pulse(T)
		for(var/i in T)
			if(isitem(i) && !is_type_in_typecache(i, banned_items_typecache))
				var/obj/item/W = i
				if(!(W.flags_1 & ADMIN_SPAWNED_1) && !(W.flags_1 & HOLOGRAM_1) && !(W.item_flags & ABSTRACT))
					L += W
		if(L.len)
			var/obj/item/CHOSEN = pick(L)
			new CHOSEN.type(T)
			qdel(CHOSEN)

/obj/machinery/anomalous_crystal/possessor //Allows you to bodyjack small animals, then exit them at your leisure, but you can only do this once per activation. Because they blow up. Also, if the bodyjacked animal dies, SO DO YOU.
	observer_desc = "When activated, this crystal allows you to take over small animals, and then exit them at the possessors leisure. Exiting the animal kills it, and if you die while possessing the animal, you die as well."
	activation_method = ACTIVATE_TOUCH

/obj/machinery/anomalous_crystal/possessor/ActivationReaction(mob/user, method)
	if(..())
		if(ishuman(user))
			var/mobcheck = FALSE
			for(var/mob/living/simple_animal/A in viewers(1, src))
				if(A.melee_damage > 5 || A.mob_size >= MOB_SIZE_LARGE || A.ckey || A.stat)
					break
				var/obj/structure/closet/stasis/S = new /obj/structure/closet/stasis(A)
				user.forceMove(S)
				mobcheck = TRUE
				break
			if(!mobcheck)
				new /mob/living/basic/cockroach(get_step(src,dir)) //Just in case there aren't any animals on the station, this will leave you with a terrible option to possess if you feel like it

/obj/structure/closet/stasis
	name = "quantum entanglement stasis warp field"
	desc = "You can hardly comprehend this thing... which is why you can't see it."
	icon_state = null //This shouldn't even be visible, so if it DOES show up, at least nobody will notice
	density = TRUE
	anchored = TRUE
	resistance_flags = FIRE_PROOF | ACID_PROOF | INDESTRUCTIBLE
	var/mob/living/simple_animal/holder_animal

/obj/structure/closet/stasis/process()
	if(holder_animal)
		if(holder_animal.stat == DEAD)
			dump_contents()
			holder_animal.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
			holder_animal.gib()
			return

/obj/structure/closet/stasis/Initialize(mapload)
	. = ..()
	if(isanimal_or_basicmob(loc))
		holder_animal = loc
	START_PROCESSING(SSobj, src)

/obj/structure/closet/stasis/Entered(atom/movable/arrived, atom/old_loc, list/atom/old_locs)
	. = ..()
	if(isliving(arrived) && holder_animal)
		var/mob/living/L = arrived
		L.notransform = 1
		ADD_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags |= GODMODE
		L.mind.transfer_to(holder_animal)
		var/datum/action/exit_possession/P = new /datum/action/exit_possession
		P.Grant(holder_animal)
		holder_animal.remove_verb(/mob/living/verb/pulled)

/obj/structure/closet/stasis/dump_contents(kill = TRUE)
	STOP_PROCESSING(SSobj, src)
	for(var/mob/living/L in src)
		REMOVE_TRAIT(L, TRAIT_MUTE, STASIS_MUTE)
		L.status_flags &= ~GODMODE
		L.notransform = 0
		if(holder_animal)
			var/datum/action/exit_possession/P = new /datum/action/exit_possession
			P.Remove(holder_animal)
			holder_animal.mind.transfer_to(L)
		if(kill || !isanimal(loc))
			L.investigate_log("has died from [src].", INVESTIGATE_DEATHS)
			L.death(FALSE)
	..()

/obj/structure/closet/stasis/emp_act()
	return

/obj/structure/closet/stasis/ex_act()
	return

/datum/action/exit_possession
	name = "Exit Possession"
	desc = "Exits the body you are possessing. They will explode violently when this occurs."
	icon_icon = 'icons/hud/actions/actions_spells.dmi'
	button_icon_state = "exit_possession"

/datum/action/exit_possession/is_available()
	return ..() && isfloorturf(owner.loc)

/datum/action/exit_possession/on_activate(mob/user, atom/target)
	var/obj/structure/closet/stasis/stasis = locate() in owner
	if(!stasis)
		CRASH("[type] did not find a stasis closet thing in the owner.")

	stasis.dump_contents(FALSE)
	qdel(stasis)
	qdel(src)


#undef ACTIVATE_TOUCH
#undef ACTIVATE_SPEECH
#undef ACTIVATE_HEAT
#undef ACTIVATE_BULLET
#undef ACTIVATE_ENERGY
#undef ACTIVATE_BOMB
#undef ACTIVATE_MOB_BUMP
#undef ACTIVATE_WEAPON
#undef ACTIVATE_MAGIC
