/obj/anomaly/singularity/factory
	name = "tear in the fabric of reality"
	desc = "Your own comprehension of reality starts bending as you stare this."
	icon = 'icons/effects/96x96.dmi'
	icon_state = "boh_tear"
	pixel_x = -32
	pixel_y = -32
	dissipate = 0
	move_self = 0
	grav_pull = 1

/obj/anomaly/singularity/factory/admin_investigate_setup()
	return

//AREAS//
//"old" means places we get in after the rune transition

/area/awaymission/factory
	teleport_restriction = TELEPORT_ALLOW_NONE

/area/awaymission/factory/secret
	name = "secrets"
	ambientsounds = list('sound/ambience/secrets.ogg','sound/ambience/ambiholy2.ogg')

/area/awaymission/factory/villageafter
	name = "The Village"
	ambientsounds = list('sound/ambience/seag1.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/seag2.ogg', 'sound/ambience/ambiodd.ogg', 'sound/ambience/ambimystery.ogg', 'sound/ambience/ambiearth.ogg', 'sound/ambience/ambiwind.ogg', 'sound/ambience/ambimine.ogg')
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE

/area/awaymission/factory/villageafter/church
	name = "The Church"
	ambience_index = AMBIENCE_HOLY

/area/awaymission/factory/villageafter/house
	ambientsounds = list('sound/ambience/ambiruin4.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambiruin7.ogg','sound/ambience/ambiruin2.ogg')

/area/awaymission/factory/villageafter/house/ritual
	ambientsounds = list('sound/ambience/antag/ecult_op.ogg','sound/ambience/ambiruin2.ogg','sound/spookoween/insane_low_laugh.ogg')
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/villageafter/house/start
	name = "The House"
	ambientsounds = list('sound/ambience/ambidet2.ogg','sound/ambience/ambiodd.ogg')

/area/awaymission/factory/villageafter/hospital
	ambientsounds = list('sound/ambience/ambiodd.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambiruin2.ogg')
	name = "The Hospital"
	requires_power = TRUE

/area/awaymission/factory/villageafter/spooky
	ambience_index = AMBIENCE_SPOOKY
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/factoryafter
	name = "The Factory"
	ambientsounds = list('sound/ambience/ambiodd.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambitech3.ogg')
	requires_power = TRUE
	always_unpowered = TRUE

/area/awaymission/factory/clownplanet
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	ambientsounds = list('sound/spookoween/scary_horn3.ogg','sound/spookoween/scary_horn.ogg','sound/spookoween/scary_horn2.ogg','sound/spookoween/scary_clown_appear.ogg')
	mood_bonus = 3
	mood_message = "<span class='nicegreen'>I hate this!\n</span>"

/area/awaymission/factory/factoryafter/down
	ambientsounds = list('sound/ambience/ambiatm1.ogg','sound/ambience/ambifac.ogg','sound/ambience/ambimaint3.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambitech3.ogg')
	requires_power = FALSE
	always_unpowered = FALSE
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/factory/factoryafter/down/maint
	ambientsounds = list('sound/ambience/ambiatm1.ogg','sound/ambience/ambimaint3.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambimaint2.ogg')

/area/awaymission/factory/factoryafter/down/batsecret
	name = "The maze"
	ambientsounds = list('sound/ambience/ambiatm1.ogg','sound/ambience/ambimaint3.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambimaint2.ogg','sound/ambience/ambibasement.ogg')

/area/awaymission/factory/factoryafter/down/leveltwo
	name = "The Factory - middle level"
	ambientsounds = list('sound/ambience/ambigen7.ogg','sound/ambience/ambifac.ogg','sound/ambience/ambireebe1.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambigen14.ogg')

/area/awaymission/factory/factoryafter/down/leveltwo/morgue
	name = "The Morgue"
	ambience_index = AMBIENCE_SPOOKY
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/factoryafter/down/leveltwo/ritual
	name = "a strange place"
	ambientsounds = list('sound/ambience/antag/ecult_op.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambireebe2.ogg','sound/spookoween/insane_low_laugh.ogg','sound/spookoween/chain_rattling.ogg')
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/factoryafter/down/levelthree
	name = "The Factory - lower level"
	ambientsounds = list('sound/ambience/ambiatm1.ogg','sound/ambience/ambitech.ogg','sound/ambience/ambitech2.ogg','sound/ambience/ambitech3.ogg','sound/ambience/ambiatmos.ogg','sound/ambience/ambiatmos2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambimaint5.ogg','sound/ambience/ambireebe3.ogg','sound/ambience/ambilava.ogg')

/area/awaymission/factory/factoryafter/down/levelthree/engine
	name = "The reality engine"
	ambientsounds = list('sound/ambience/singulambience.ogg','sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg','sound/ambience/antag/assimilation.ogg')
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>Uhm... Ok?... I guess...\n</span>"

/area/awaymission/factory/factoryduring
	name = "The old Factory"
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambifac.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiatm1.ogg','sound/ambience/ambiatmos.ogg')

/area/awaymission/factory/factoryduring/down/levelthree
	name = "The old Factory - lower level"
	ambientsounds = list('sound/ambience/ambiatm1.ogg','sound/ambience/ambitech.ogg','sound/ambience/ambitech2.ogg','sound/ambience/ambitech3.ogg','sound/ambience/ambiatmos.ogg','sound/ambience/ambiatmos2.ogg','sound/ambience/signal.ogg','sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiruin2.ogg')

/area/awaymission/factory/factoryduring/down/levelthree/engine
	name = "The reality engine"
	mood_bonus = 1
	mood_message = "<span class='nicegreen'>Uhm... Ok?... I guess...\n</span>"
	ambientsounds = list('sound/ambience/singulambience.ogg','sound/ambience/ambisin1.ogg','sound/ambience/ambisin2.ogg','sound/ambience/ambisin3.ogg','sound/ambience/ambisin4.ogg','sound/ambience/antag/assimilation.ogg','sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg')

/area/awaymission/factory/factoryduring/down/leveltwo
	name = "The old Factory - middle level"
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambifac.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiruin5.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambigen1.ogg','sound/ambience/ambigen3.ogg')

/area/awaymission/factory/factoryduring/down/leveltwo/ritual
	name = "a strange place"
	ambientsounds = list('sound/ambience/antag/ecult_op.ogg','sound/spookoween/insane_low_laugh.ogg','sound/spookoween/spookywind.ogg')

/area/awaymission/factory/factoryduring/down/leveltwo/morgue
	name = "The old Morgue"
	ambience_index = AMBIENCE_SPOOKY
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/factoryduring/down/leveltwo/asylum
	name = "The sector of mentally disordered"
	ambientsounds = list('sound/ambience/ambimo2.ogg','sound/ambience/ambiodd.ogg','sound/ambience/ambitech.ogg','sound/ambience/ambireebe1.ogg')

/area/awaymission/factory/factoryduring/down
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambitech3.ogg','sound/ambience/ambiatm1.ogg')

/area/awaymission/factory/factoryduring/down/maint
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiatm1.ogg','sound/ambience/ambimaint3.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambimaint2.ogg')

/area/awaymission/factory/villageduring
	name = "The old village"
	dynamic_lighting = DYNAMIC_LIGHTING_DISABLED
	requires_power = FALSE
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiearthduring.ogg','sound/ambience/ambiwind.ogg','sound/ambience/ambimine.ogg')

/area/awaymission/factory/villageduring/house
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiearthduring.ogg','sound/ambience/ambiwind.ogg','sound/ambience/ambimine.ogg','sound/ambience/ambiruin4.ogg','sound/ambience/ambiruin6.ogg','sound/ambience/ambiruin7.ogg','sound/ambience/ambiruin2.ogg','sound/ambience/signal.ogg')

/area/awaymission/factory/villageduring/house/ritual
	ambientsounds = list('sound/ambience/antag/ecult_op.ogg','sound/ambience/ambiruin2.ogg','sound/spookoween/insane_low_laugh.ogg')
	mood_bonus = -2
	mood_message = "<span class='nicegreen'>It smells like death in here!\n</span>"

/area/awaymission/factory/villageduring/church
	name = "The old Church"
	ambience_index = AMBIENCE_HOLY

/area/awaymission/factory/villageduring/church/leveltwo
	name = "The old Church - 2nd floor"
	ambientsounds = list('sound/ambience/ambimystery.ogg','sound/ambience/ambiodd.ogg','sound/ambience/signal.ogg','sound/ambience/ambiwind.ogg','sound/ambience/ambicha2.ogg','sound/ambience/ambiholy3.ogg')

/area/awaymission/factory/villageduring/basement
	name = "The old basement"
	ambientsounds = list('sound/ambience/ambibasement.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambiodd.ogg')
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED

/area/awaymission/factory/villageduring/house/start
	name = "The old House"
	ambientsounds = list('sound/ambience/ambidet2.ogg')

/area/awaymission/factory/villageduring/hospital
	ambientsounds = list('sound/ambience/ambidanger.ogg','sound/ambience/ambidanger2.ogg','sound/ambience/ambiatmos.ogg','sound/ambience/ambimystery.ogg','sound/ambience/ambimaint.ogg','sound/ambience/ambiruin2.ogg')
	name = "The Hospital"

/area/awaymission/factory/transition
	name = "Beyond the time"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	ambientsounds = list('sound/ambience/shipambience.ogg','sound/ambience/ambiatmos.ogg','sound/ambience/antag/malf.ogg','sound/ambience/signal.ogg','sound/ambience/ambimalf.ogg')

//ITEMS//

/obj/item/statuebust/toy
	name = "aesthetic bust"
	desc = "A priceless ancient marble bust, the kind that belongs in a museum. Looks like this one has some differences."
	var/cooldown = 0

/obj/item/statuebust/toy/attack_self(mob/user)
	if (cooldown < world.time)
		cooldown = world.time + 450
		user.visible_message("<span class='warning'>[user] activates \the [src].</span>", "<span class='notice'>You activate \the [src]!</span>", "<span class='italics'>You hear a music playing.</span>")
		playsound(src, 'sound/ambience/ambivapor1.ogg', 50, 0)
	else
		to_chat(user, "<span class='alert'>Nothing happens!</span>")

/obj/item/clothing/glasses/hud/terminator
	name = "T-80 tactical sunglasses"
	desc = "Strangely ancient technology used to help provide rudimentary eye cover. Also shows information about criminals and their condition. Has enhanced shielding which blocks flashes."
	icon_state = "t80sunglasses"
	darkness_view = 1
	clothing_flags = SCAN_REAGENTS
	vision_flags = SEE_MOBS
	flash_protect = 1
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_INVISIBLE
	hud_type = list(DATA_HUD_SECURITY_ADVANCED, DATA_HUD_DIAGNOSTIC_BASIC, DATA_HUD_MEDICAL_ADVANCED)
	hud_trait = list(TRAIT_SECURITY_HUD, TRAIT_MEDICAL_HUD)

//MOBS//

/mob/living/simple_animal/hostile/proc/summon_backup_nosound(distance, exact_faction_match)
	do_alert_animation(src)
	for(var/mob/living/simple_animal/hostile/M in oview(distance, GET_TARGETS_FROM(src)))
		if(faction_check_mob(M, TRUE))
			if(M.AIStatus == AI_OFF)
				return
			else
				M.Goto(src,M.move_to_delay,M.minimum_distance)

/mob/living/simple_animal/hostile/factory
	name = "Guard"
	desc = "An armed officer. Looks like they prefer to shoot rather than asking questions."
	speak = list("Stop resisting!","I need backup!","Die, freak!","It's getting away!")
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "nanotrasen"
	icon_living = "nanotrasen"
	icon_dead = null
	icon_gib = "syndicate_gib"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 5
	speak_chance = 5
	del_on_death = TRUE
	do_footstep = TRUE
	environment_smash = ENVIRONMENT_SMASH_STRUCTURES
	search_objects = 1
	a_intent = INTENT_HARM
	attack_sound = 'sound/weapons/cqchit2.ogg'
	attacktext = "punches"
	robust_searching = 1
	melee_damage = 12
	speed = 0
	maxHealth = 100
	health = 100
	melee_damage = 12
	stat_attack = UNCONSCIOUS
	faction = list("nanotrasenprivate")
	status_flags = CANPUSH
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 10
	loot = list(/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)
	response_help = "pokes"
	response_disarm = "shoves"
	response_harm = "hits"
	var/cooldown = 0

/mob/living/simple_animal/hostile/factory/death(gibbed)
	var/chosen_sound = pick('sound/creatures/guarddeath.ogg','sound/creatures/guarddeath2.ogg','sound/creatures/guarddeath3.ogg','sound/creatures/guarddeath4.ogg')
	playsound(get_turf(src), chosen_sound, 100, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/factory/Aggro()
	..()
	var/list/possible_sounds = list('sound/effects/radio1.ogg','sound/effects/radio2.ogg','sound/effects/radio3.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time) // So we don't repeat the sound and the phrase every time we get hit and do it at least each 30 seconds
		cooldown = world.time + 300
		summon_backup_nosound(10)
		playsound(get_turf(src), chosen_sound, 100, 0, 0)
		var/list/possible_phrases = list("Anomaly spotted! Send backup!","Intruder over here!","Hostile spotted, get them!")
		var/chosen_phrase = pick(possible_phrases)
		say(chosen_phrase)
	else
		return

/mob/living/simple_animal/hostile/factory/ranged
	icon_state = "nanotrasenranged"
	icon_living = "nanotrasenranged"
	ranged_cooldown_time = 15
	ranged = 1
	retreat_distance = 3
	minimum_distance = 5
	casingtype = /obj/item/ammo_casing/c45
	projectilesound = 'sound/weapons/gunshot.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/pistol/m1911,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)

/mob/living/simple_animal/hostile/factory/ranged/lmg
	desc = "This one is carrying a bigger gun. Seek for cover."
	icon_state = "nanotrasenrangedlmg"
	icon_living = "nanotrasenrangedlmg"
	projectilesound = 'sound/weapons/rifleshot.ogg'
	sidestep_per_cycle = 0
	check_friendly_fire = 1
	minimum_distance = 6
	approaching_target = FALSE
	rapid = 8
	rapid_fire_delay = 2
	casingtype = /obj/item/ammo_casing/mm712x82
	ranged_cooldown_time = 80
	vision_range = 12
	aggro_vision_range = 12
	retreat_distance = 1
	move_to_delay = 4
	speed = 12
	health = 150
	maxHealth = 150
	loot = list(/obj/item/gun/ballistic/automatic/l6_saw/unrestricted,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)

/mob/living/simple_animal/hostile/factory/ranged/shotgun
	icon_state = "nanotrasenrangedshot"
	icon_living = "nanotrasenrangedshot"
	rapid = 2
	rapid_fire_delay = 5
	casingtype = /obj/item/ammo_casing/shotgun/buckshot
	projectilesound = 'sound/weapons/shotgunshot.ogg'
	ranged_cooldown_time = 25
	loot = list(/obj/item/gun/ballistic/shotgun/automatic/combat,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)

/mob/living/simple_animal/hostile/factory/ranged/smg
	icon_state = "nanotrasenrangedsmg"
	icon_living = "nanotrasenrangedsmg"
	rapid = 3
	casingtype = /obj/item/ammo_casing/c46x30mm
	projectilesound = 'sound/weapons/gunshot_smg.ogg'
	loot = list(/obj/item/gun/ballistic/automatic/wt550,
				/obj/effect/mob_spawn/human/corpse/nanotrasensoldier)

/mob/living/simple_animal/hostile/syndicate/factory
	gender = MALE
	faction = list("nanotrasenprivate")
	speak_chance = 5
	speak = list("Come get me!","You can't get away!","Die!")

/mob/living/simple_animal/hostile/syndicate/factory/sniper
	name = "The Warden"
	desc = "One of the best snipers. Take cover or get shot"
	icon_state = "fsniper"
	icon_living = "fsniper"
	ranged = TRUE
	speed = 1
	dodge_prob = 40
	ranged_cooldown_time = 40
	check_friendly_fire = 1
	sidestep_per_cycle = 3
	minimum_distance = 4
	turns_per_move = 6
	melee_queue_distance = 2
	health = 250
	maxHealth = 250
	melee_damage = 20
	rapid_melee = 3
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit3.ogg'
	projectilesound = 'sound/weapons/sniper_shot.ogg'
	speak_chance = 2
	var/cooldown = 0
	speak = list("You're pretty good.","You can't dodge everything!","Fall down already!")
	loot = list(/obj/item/gun/ballistic/sniper_rifle,
					/obj/effect/mob_spawn/human/corpse/sniper,
					/obj/item/ammo_box/magazine/sniper_rounds,
					/obj/item/ammo_box/magazine/sniper_rounds/penetrator,
					/obj/item/ammo_box/magazine/sniper_rounds/soporific)

/mob/living/simple_animal/hostile/syndicate/factory/sniper/Aggro()
	..()
	ranged_cooldown = 30
	if (cooldown < world.time)
		cooldown = world.time + 150
		summon_backup_nosound(10)
		playsound(get_turf(src), 'sound/weapons/sniper_rack.ogg', 80, TRUE)
		say("I've got you in my scope.")

/mob/living/simple_animal/hostile/syndicate/factory/sniper/Shoot()
	var/allowed_projectile_types = list(/obj/item/ammo_casing/p50, /obj/item/ammo_casing/p50/penetrator)
	casingtype = pick(allowed_projectile_types)
	..()

/mob/living/simple_animal/hostile/syndicate/factory/sniper/death(gibbed)
	playsound(get_turf(src), 'sound/creatures/wardendeath.ogg', 100, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho
	name = "Psycho"
	desc = "They're wearing a pretty uncomfortable jacket."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "psycho"
	icon_living = "psycho"
	attacktext = "bites"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	turns_per_move = 0
	del_on_death = TRUE
	response_help = "pokes"
	response_disarm = "touches"
	response_harm = "hits"
	speak_chance = 5
	attack_sound = 'sound/weapons/bite.ogg'
	speak = list("I'm not mad!","What insanity?","Kill")
	speed = -2
	maxHealth = 100
	health = 100
	atmos_requirements = list("min_oxy" = 5, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 1, "min_co2" = 0, "max_co2" = 5, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 5
	faction = list("psycho")
	move_to_delay = 3
	rapid_melee = 2
	in_melee = TRUE
	approaching_target = TRUE
	environment_smash = ENVIRONMENT_SMASH_NONE
	obj_damage = 5
	sidestep_per_cycle = 0
	stat_attack = UNCONSCIOUS
	melee_damage = 15
	lose_patience_timeout = 350
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost)

/mob/living/simple_animal/hostile/psycho/regular
	var/cooldown = 0
	var/static/list/idle_sounds

/mob/living/simple_animal/hostile/psycho/regular/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psycidle1.ogg','sound/creatures/psycidle2.ogg','sound/creatures/psycidle3.ogg')

/mob/living/simple_animal/hostile/psycho/regular/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, FALSE)

/mob/living/simple_animal/hostile/psycho/regular/Aggro()
	..()
	var/list/possible_sounds = list('sound/hallucinations/growl1.ogg','sound/hallucinations/growl2.ogg','sound/hallucinations/growl3.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/regular/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psycdeath1.ogg','sound/creatures/psycdeath2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/fast
	move_to_delay = 2
	speed = -5
	maxHealth = 70
	health = 70

/mob/living/simple_animal/hostile/psycho/muzzle
	icon_state = "psychomuzzle"
	icon_living = "psychomuzzle"
	attacktext = "headbutts"
	attack_sound = null
	speak_chance = 0
	melee_damage = 9
	var/cooldown = 0
	var/static/list/idle_sounds
	speed = 0
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost/muzzle)

/mob/living/simple_animal/hostile/psycho/muzzle/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psychidle.ogg','sound/creatures/psychidle2.ogg')

/mob/living/simple_animal/hostile/psycho/muzzle/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psychdeath.ogg','sound/creatures/psychdeath2.ogg',)
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/muzzle/Aggro()
	..()
	var/list/possible_sounds = list('sound/creatures/psychsight.ogg','sound/creatures/psychsight2.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/muzzle/AttackingTarget()
	..()
	playsound(get_turf(src), 'sound/creatures/psychattack1.ogg', 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/muzzle/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, TRUE)

/mob/living/simple_animal/hostile/psycho/trap
	desc = "This one has a strange device on his head."
	icon_state = "psychotrap"
	icon_living = "psychotrap"
	speak_chance = 0
	speed = -3
	move_to_delay = 2
	melee_damage = 15
	attack_sound = null
	attacktext = "headbutts"
	loot = list(/obj/effect/mob_spawn/human/corpse/psychost/trap)
	var/cooldown = 0
	var/static/list/idle_sounds

/mob/living/simple_animal/hostile/psycho/trap/Aggro()
	..()
	var/list/possible_sounds = list('sound/creatures/psychsight.ogg','sound/creatures/psychsight2.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 70, TRUE, 0)

/mob/living/simple_animal/hostile/psycho/trap/Initialize(mapload)
	. = ..()
	idle_sounds = list('sound/creatures/psychidle.ogg','sound/creatures/psychidle2.ogg')

/mob/living/simple_animal/hostile/psycho/trap/Life()
	..()
	if(Aggro() || stat)
		return
	if(prob(20))
		var/chosen_sound = pick(idle_sounds)
		playsound(src, chosen_sound, 50, FALSE)
	if(health < maxHealth)
		playsound(src, 'sound/machines/beep.ogg', 80, FALSE)
		addtimer(CALLBACK(src, PROC_REF(death)), 200)

/mob/living/simple_animal/hostile/psycho/trap/AttackingTarget()
	var/list/possible_sounds = list('sound/creatures/psychhead.ogg','sound/creatures/psychhead2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 100, TRUE, 0)
	..()

/mob/living/simple_animal/hostile/psycho/trap/death(gibbed)
	var/list/possible_sounds = list('sound/creatures/psychdeath.ogg','sound/creatures/psychdeath2.ogg')
	var/chosen_sound = pick(possible_sounds)
	playsound(get_turf(src), chosen_sound, 70, 0, 0)
	playsound(get_turf(src), 'sound/effects/snap.ogg', 75, TRUE, 0)
	playsound(get_turf(src), 'sound/effects/splat.ogg', 90, TRUE, 0)
	visible_message("<span class='boldwarning'>The device activates!</span>")
	..()

/mob/living/simple_animal/hostile/syndicate/factory/heavy
	name = "Heavy gunner"
	desc = "They didn't get that backpack for nothing."
	icon_state = "Heavy"
	icon_living = "Heavy"
	sidestep_per_cycle = 0
	minimum_distance = 5
	approaching_target = TRUE
	ranged = TRUE
	rapid = 65
	rapid_fire_delay = 0.5
	projectiletype = /obj/item/projectile/beam
	ranged_cooldown_time = 110
	vision_range = 9
	speak_chance = 0
	speak = null
	aggro_vision_range = 9
	attacktext = "hits"
	attack_sound = 'sound/weapons/genhit3.ogg'
	retreat_distance = 2
	melee_queue_distance = 1
	melee_damage = 25
	move_to_delay = 4
	projectilesound = null
	speed = 15
	health = 300
	maxHealth = 300
	loot = list(/obj/effect/mob_spawn/human/corpse/heavy)
	var/cooldown = 0

/mob/living/simple_animal/hostile/syndicate/factory/heavy/Initialize(mapload)
	..()

/mob/living/simple_animal/hostile/syndicate/factory/heavy/Aggro()
	..()
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), 'sound/creatures/heavysight1.ogg', 80, 0, 0)

/mob/living/simple_animal/hostile/syndicate/factory/heavy/OpenFire(atom/A)
	playsound(get_turf(src), 'sound/weapons/heavyminigunstart.ogg', 80, 0, 0)
	move_to_delay = 6//slowdown when shoot
	speed = 30
	sleep(15)
	playsound(get_turf(src), 'sound/weapons/heavyminigunshoot.ogg', 90, 0, 0)
	if(CheckFriendlyFire(A))
		return
	if(!(simple_mob_flags & SILENCE_RANGED_MESSAGE))
		visible_message("<span class='danger'><b>[src]</b> [ranged_message] at [A]!</span>")
	if(rapid > 1)
		var/datum/callback/cb = CALLBACK(src, PROC_REF(Shoot), A)
		for(var/i in 1 to rapid)
			addtimer(cb, (i - 1)*rapid_fire_delay)
	else
		Shoot(A)
	ranged_cooldown = world.time + ranged_cooldown_time
	playsound(get_turf(src), 'sound/weapons/heavyminigunstop.ogg', 80, 0, 0)
	move_to_delay = initial(move_to_delay)//restore speed
	speed = initial(speed)

/mob/living/simple_animal/hostile/syndicate/factory/heavy/death(gibbed)
	playsound(get_turf(src), 'sound/creatures/heavydeath1.ogg', 80, TRUE, 0)
	..()

/obj/item/clothing/mask/gas/sechailer/swat/emagged
	safety = FALSE

/mob/living/simple_animal/hostile/zombie_suicide
	name = "aggressive corpse"
	desc = "This corpse is holding a grenade without a pin in it..."
	icon = 'icons/mob/simple_human.dmi'
	icon_state = "suicidezombie"
	icon_living = "suicidezombie"
	mob_biotypes = list(MOB_ORGANIC, MOB_HUMANOID)
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	status_flags = CANPUSH
	health = 100
	maxHealth = 100
	move_to_delay = 2
	speed = 0
	melee_damage = null
	attack_sound = null
	del_on_death = TRUE
	stat_attack = UNCONSCIOUS
	a_intent = INTENT_HARM
	var/det_time = 30
	var/active = 0
	var/cooldown = 0
	loot = list(/obj/effect/mob_spawn/human/corpse/suicidezombie, /obj/item/grenade/syndieminibomb/concussion/frag/activated)
	do_footstep = TRUE
	hardattacks = TRUE

/mob/living/simple_animal/hostile/zombie_suicide/Aggro()
	..()
	var/list/possible_sounds = list('sound/creatures/szombiesight.ogg','sound/creatures/szombiesight2.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 50, TRUE, 0)

/mob/living/simple_animal/hostile/zombie_suicide/AttackingTarget()
	if(!active)
		active = TRUE
		playsound(src, 'sound/weapons/armbomb.ogg', 100, TRUE)
		var/list/possible_sounds = list('sound/creatures/szombiesight.ogg','sound/creatures/szombiesight2.ogg')
		var/chosen_sound = pick(possible_sounds)
		playsound(get_turf(src), chosen_sound, 50, TRUE, 0)
		visible_message("<span class='danger'>[src] primes the grenade!.</span>")
		addtimer(CALLBACK(src, PROC_REF(prime)), det_time)

/mob/living/simple_animal/hostile/zombie_suicide/proc/prime()
	explosion(src,0, 2, 3, flame_range = 3)
	new /obj/effect/gibspawner/generic(get_turf(src), src)
	qdel(src)

/mob/living/simple_animal/hostile/zombie_suicide/death(gibbed)
	playsound(src, 'sound/creatures/szombiedeath.ogg', 60, TRUE)
	..()

/obj/item/grenade/syndieminibomb/concussion/frag/activated
	det_time = 30

/obj/item/grenade/syndieminibomb/concussion/frag/activated/Initialize(mapload)
	..()
	preprime()

/mob/living/simple_animal/hostile/syndicate/factory/boss
	name = "The Director"
	desc = "This thing looks more like a machine than human."
	maxHealth = 500
	health = 500
	icon_state = "facboss"
	icon_living = "facboss"
	see_in_dark = 13
	vision_range = 12
	aggro_vision_range = 12
	search_objects = 1
	minbodytemp = 0
	speak = null
	dodging = FALSE
	mob_biotypes = list(MOB_ROBOTIC)
	obj_damage = 100
	move_force = MOVE_FORCE_EXTREMELY_STRONG
	move_resist = MOVE_FORCE_EXTREMELY_STRONG
	pull_force = MOVE_FORCE_EXTREMELY_STRONG
	hardattacks = TRUE
	melee_damage = 50
	speed = 5
	move_to_delay = 3
	ranged = TRUE
	hud_possible = list(ANTAG_HUD)
	approaching_target = TRUE
	ranged_ignores_vision = TRUE
	environment_smash = ENVIRONMENT_SMASH_RWALLS
	ranged_cooldown_time = 30
	check_friendly_fire = 1
	turns_per_move = 2
	spacewalk = TRUE
	rapid_melee = 0
	lose_patience_timeout = 400
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	unsuitable_atmos_damage = 0
	attack_sound = 'sound/weapons/sonic_jackhammer.ogg'
	projectilesound = 'sound/weapons/shotgunshot.ogg'
	var/cooldown = 0
	loot = list(/obj/item/gun/ballistic/shotgun/lever_action,
				/obj/effect/mob_spawn/human/corpse/facboss)

/mob/living/simple_animal/hostile/syndicate/factory/boss/Shoot()
	var/static/list/allowed_projectile_types = list(/obj/item/ammo_casing/shotgun/beanbag,
										 /obj/item/ammo_casing/shotgun, /obj/item/ammo_casing/shotgun/incendiary,
										 /obj/item/ammo_casing/shotgun/dragonsbreath,
										 /obj/item/ammo_casing/shotgun/meteorslug,
										 /obj/item/ammo_casing/shotgun/pulseslug,
										 /obj/item/ammo_casing/shotgun/frag12,
										 /obj/item/ammo_casing/shotgun/buckshot,
										 /obj/item/ammo_casing/shotgun/rubbershot,
										 /obj/item/ammo_casing/shotgun/incapacitate,
										 /obj/item/ammo_casing/shotgun/improvised,
										 /obj/item/ammo_casing/shotgun/ion,
										 /obj/item/ammo_casing/shotgun/laserslug,
										 /obj/item/ammo_casing/shotgun/breacher)
	casingtype = pick(allowed_projectile_types)
	..()
	sleep(5)
	playsound(get_turf(src), 'sound/weapons/shotgunpump.ogg', 50, 0, 0)

/mob/living/simple_animal/hostile/syndicate/factory/boss/Aggro()
	..()
	var/list/possible_sounds = list('sound/voice/ed209_20sec.ogg','sound/creatures/bosssight.ogg','sound/creatures/bosssight2.ogg','sound/voice/complionator/harry.ogg','sound/weapons/leveractionrack.ogg')
	var/chosen_sound = pick(possible_sounds)
	if (cooldown < world.time)
		cooldown = world.time + 300
		playsound(get_turf(src), chosen_sound, 80, TRUE, 0)
		say("Target!")

/mob/living/simple_animal/hostile/syndicate/factory/boss/Life()
	..()
	if(health <= 300)
		icon_state = "facboss2"
		icon_living = "facboss2"
		ranged_cooldown_time = 20//less health - faster shooting
		return
	if(health <= 150)
		if(prob(5) && Aggro())//change to insult the target on low health
			playsound(get_turf(src), 'sound/voice/beepsky/insult.ogg', 100, 0, 0)
			visible_message("<font color='red' size='4'><b>FUCK YOUR CUNT YOU SHIT EATING COCKSTORM AND EAT A DONG FUCKING ASS RAMMING SHIT FUCK EAT PENISES IN YOUR FUCK FACE AND SHIT OUT ABORTIONS OF FUCK AND POO AND SHIT IN YOUR ASS YOU COCK FUCK SHIT MONKEY FUCK ASS WANKER FROM THE DEPTHS OF SHIT.</b></font>")
		icon_state = "facboss3"
		icon_living = "facboss3"
		ranged_cooldown_time = 10//even faster

/mob/living/simple_animal/hostile/syndicate/factory/boss/updatehealth()
	..()
	if(health <= 300)
		var/list/possible_sounds = list('sound/creatures/bosspain.ogg','sound/creatures/bosspain2.ogg')
		var/chosen_sound = pick(possible_sounds)
		playsound(get_turf(src), chosen_sound, 60, TRUE, 0)

/mob/living/simple_animal/hostile/syndicate/factory/boss/death(gibbed)
	playsound(get_turf(src), 'sound/voice/borg_deathsound.ogg', 80, TRUE, 0)
	visible_message("<span class='boldwarning'>\the [src] activates its self-destruct system!.</span>")
	speed = 15
	move_to_delay = 20
	ranged_cooldown = 300
	ranged_cooldown_time = 300
	INVOKE_ASYNC(src, PROC_REF(explosion), src.loc, 0, 3, 4, null, null, FALSE, 2)
	..()

//GUNS//

/obj/item/gun/ballistic/shotgun/lever_action
	name = "lever action shotgun"
	desc = "A really old shotgun with five shell capacity. This one can fit in a backpack."
	w_class = WEIGHT_CLASS_NORMAL
	dual_wield_spread = 0
	fire_sound_volume = 60    //tried on 90 my eardrums said goodbye
	item_state = "leveraction"
	icon_state = "leveraction"
	rack_sound = "sound/weapons/leveractionrack.ogg"
	fire_sound = "sound/weapons/leveractionshot.ogg"
	vary_fire_sound = FALSE
	rack_sound_vary = FALSE
	recoil = 1
	mag_type = /obj/item/ammo_box/magazine/internal/shot/lever
	pb_knockback = 5

/obj/item/gun/ballistic/shotgun/lever_action/examine(mob/user)
	. = ..()
	. += "<span class='info'>You will instantly reload it after a shot if you have another hand free.</span>"

/obj/item/gun/ballistic/shotgun/lever_action/shoot_live_shot(mob/living/user, pointblank = 0, atom/pbtarget = null, message = 1)
	..()
	if(user.get_inactive_held_item())
		return
	else
		rack()

/obj/item/gun/ballistic/shotgun/lever_action/rack(mob/user = null)
	if (user)
		to_chat(user, "<span class='notice'>You rack the [bolt_wording] of \the [src].</span>")
	process_chamber(!chambered, FALSE)
	playsound(src, rack_sound, rack_sound_volume, rack_sound_vary)
	update_icon()
	if(user.get_inactive_held_item() && prob(50) && chambered)
		user.visible_message("<span class='rose'>With a single move of [user.p_their()] arm, [user] flips \the [src] and loads the chamber with a shell.</span>")

/obj/item/gun/ballistic/automatic/pistol/deagle/sound
	desc = "A robust .50 AE handgun. This one looks even more robust."
	rack_sound = "sound/weapons/deaglerack.ogg"
	bolt_drop_sound = "sound/weapons/deagleslidedrop.ogg"
	lock_back_sound = "sound/weapons/deaglelock.ogg"
	lock_back_sound_vary = FALSE
	rack_sound_vary = FALSE
	load_sound_vary = FALSE
	eject_sound_vary = FALSE
	fire_sound = "sound/weapons/deagleshot.ogg"
	vary_fire_sound = TRUE
	fire_rate = 5
	force = 18

//MISC//

/obj/effect/trap/nexus/trickyspawner/clowns
	mobs = 5
	spawned = /mob/living/simple_animal/hostile/retaliate/clown
