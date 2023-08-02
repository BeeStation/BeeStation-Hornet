/obj/item/deployablemine
	name = "deployable mine"
	desc = "An unarmed landmine. It can be planted to arm it."
	icon_state = "uglymine"
	var/mine_type = /obj/effect/mine
	var/arming_time = 30

/obj/item/deployablemine/stun
	desc = "An unarmed stun mine. It can be planted to arm it."
	mine_type = /obj/effect/mine/stun

/obj/item/deployablemine/smartstun
	name = "deployable smart mine"
	desc = "An unarmed smart stun mine. It can be planted to arm it."
	mine_type = /obj/effect/mine/stun/smart

/obj/item/deployablemine/rapid
	name = "deployable rapid smart mine"
	desc = "An unarmed smart stun mine designed to be rapidly placeable."
	mine_type = /obj/effect/mine/stun/smart/adv
	arming_time = 10
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployablemine/heavy
	name = "deployable sledgehammer smart mine"
	desc = "An unarmed smart heavy stun mine designed to be hard to disarm."
	mine_type = /obj/effect/mine/stun/smart/heavy
	arming_time = 50

/obj/item/deployablemine/explosive
	mine_type = /obj/effect/mine/explosive

/obj/item/deployablemine/honk
	name = "deployable honkblaster 1000"
	desc = "An advanced pranking landmine for clowns, honk! Delivers an extra loud HONK to the head when triggered. It can be planted to arm it, or have its sound customised with a sound synthesiser."
	mine_type = /obj/effect/mine/sound

/obj/item/deployablemine/traitor
	name = "exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm."
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	mine_type = /obj/effect/mine/explosive/traitor
	w_class = WEIGHT_CLASS_SMALL

/obj/item/deployablemine/traitor/bigboom
	name = "high yield exploding rubber duck"
	desc = "A pressure activated explosive disguised as a rubber duck. Plant it to arm. This version is fitted with high yield X4 for a larger blast."
	mine_type = /obj/effect/mine/explosive/traitor/bigboom

/obj/item/deployablemine/gas
	name = "oxygen gas mine"
	desc = "An unarmed mine that releases oxygen into the air when triggered. Pretty pointless huh."
	mine_type = /obj/effect/mine/gas

/obj/item/deployablemine/plasma
	name = "incendiary mine"
	desc = "An unarmed mine that releases plasma into the air when triggered, then ignites it."
	mine_type = /obj/effect/mine/gas/plasma

/obj/item/deployablemine/sleepy
	name = "knockout mine"
	desc = "An unarmed mine that releases N2O into the air when triggered. Nighty Night!"
	mine_type = /obj/effect/mine/gas/n2o

/obj/item/deployablemine/afterattack(atom/plantspot, mob/user, proximity)
	if(!proximity)
		return

	if(!istype(plantspot,/turf/open)) // you can't plant a mine inside a wall or on a mob
		return

	if(isspaceturf(plantspot))
		to_chat(user, "<span class='warning'>you cannot plant a mine in space!</span>")
		return

	if((istype(plantspot,/turf/open/lava)) || (istype(plantspot,/turf/open/chasm)))
		to_chat(user, "<span class='warning'>You can't plant the mine here!</span>")
		return

	to_chat(user, "<span class='notice'>You start arming the [src]...</span>")
	if(do_after(user, arming_time, target = src))
		new mine_type(plantspot)
		to_chat(user, "<span class='notice'>You plant and arm the [src].</span>")
		log_combat(user, src, "planted and armed")
		qdel(src)

/obj/effect/mine
	name = "dummy mine"
	desc = "Better stay away from that thing."
	density = FALSE
	anchored = TRUE
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "uglymine"
	var/triggered = FALSE
	var/smartmine = 0
	var/disarm_time = 200
	var/disarm_product = /obj/item/deployablemine // ie what drops when the mine is disarmed
	///if this has a value, the explosion of the mine will be delayed slightly for dramatic effect while the sound plays
	var/dramatic_sound

/obj/effect/mine/Initialize(mapload)
	. = ..()
	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/mine/attackby(obj/I, mob/user, params)
	if(istype(I, /obj/item/multitool))
		to_chat(user, "<span class='notice'>You begin to disarm the [src]...</span>")
		if(do_after(user, disarm_time, target = src))
			to_chat(user, "<span class='notice'>You disarm the [src].</span>")
			new disarm_product(src.loc)
			qdel(src)

/obj/effect/mine/proc/mineEffect(mob/victim)
	to_chat(victim, "<span class='danger'>*click*</span>")

/obj/effect/mine/proc/on_entered(datum/source, atom/movable/AM)
	SIGNAL_HANDLER

	if(!isturf(loc) || AM.throwing || (AM.movement_type & (FLYING | FLOATING)) || !AM.has_gravity() || triggered)
		return
	if(ismob(AM))
		checksmartmine(AM)
	else
		triggered = TRUE	//ensures multiple explosions aren't queued if/while the mine is delayed
		INVOKE_ASYNC(src, PROC_REF(triggermine), AM)

/obj/effect/mine/proc/checksmartmine(mob/living/target)
	if(target)
		if(smartmine && target.has_mindshield_hud_icon())
			return
		else if(dramatic_sound)
			triggered = TRUE
			playsound(loc, dramatic_sound, 100, 1)
			target.Paralyze(30, TRUE, TRUE) //"Trip" the mine if you will. Ignores stun immunity.
			addtimer(CALLBACK(src, PROC_REF(triggermine), target), 10)
			return
		else
			triggered = 1
			triggermine(target)


/obj/effect/mine/proc/triggermine(mob/living/victim)
	visible_message("<span class='danger'>[victim] sets off [icon2html(src, viewers(src))] [src]!</span>")
	var/datum/effect_system/spark_spread/s = new /datum/effect_system/spark_spread
	s.set_up(3, 1, src)
	s.start()
	mineEffect(victim)
	SEND_SIGNAL(src, COMSIG_MINE_TRIGGERED, victim)
	qdel(src)

/obj/effect/mine/take_damage(damage_amount, damage_type, damage_flag, sound_effect, attack_dir)
	. = ..()
	triggermine()

/obj/effect/mine/explosive
	name = "explosive mine"
	var/range_devastation = 0
	var/range_heavy = 1
	var/range_light = 2
	var/range_flash = 3
	disarm_product = /obj/item/deployablemine/explosive

/obj/effect/mine/explosive/traitor
	name = "rubber ducky"
	desc = "Rubber ducky you're so fine, you make bathtime lots of fuuun. Rubber ducky I'm awfully fooooond of yooooouuuu~"
	icon = 'icons/obj/watercloset.dmi'
	icon_state = "rubberducky"
	dramatic_sound = 'sound/items/bikehorn.ogg'
	range_heavy = 2
	range_light = 3
	range_flash = 4
	disarm_time = 400
	disarm_product = /obj/item/deployablemine/traitor

/obj/effect/mine/explosive/traitor/bigboom
	range_devastation = 2
	range_heavy = 4
	range_light = 8
	range_flash = 6
	disarm_product = /obj/item/deployablemine/traitor/bigboom

/obj/effect/mine/explosive/mineEffect(mob/victim)
	explosion(loc, range_devastation, range_heavy, range_light, range_flash)

/obj/effect/mine/stun
	name = "stun mine"
	var/stun_time = 150
	var/damage = 0
	disarm_product = /obj/item/deployablemine/stun

/obj/effect/mine/stun/smart
	name = "smart stun mine"
	desc = "An advanced mine with IFF features, capable of ignoring people with mindshield implants."
	smartmine = 1
	disarm_time = 250
	disarm_product = /obj/item/deployablemine/smartstun

/obj/effect/mine/stun/smart/adv
	name = "rapid smart mine"
	disarm_time = 120
	disarm_product = /obj/item/deployablemine/rapid

/obj/effect/mine/stun/smart/heavy
	name = "sledgehammer smart mine"
	disarm_time = 350
	stun_time = 230
	damage = 40
	disarm_product = /obj/item/deployablemine/heavy



/obj/effect/mine/stun/mineEffect(mob/living/victim)
	if(isliving(victim))
		victim.adjustStaminaLoss(stun_time)
		victim.adjustBruteLoss(damage)

/obj/effect/mine/shrapnel
	name = "shrapnel mine"
	var/shrapnel_type = /obj/projectile/bullet/shrapnel
	var/shrapnel_magnitude = 3

/obj/effect/mine/shrapnel/mineEffect(mob/victim)
	AddComponent(/datum/component/pellet_cloud, projectile_type=shrapnel_type, magnitude=shrapnel_magnitude)

/obj/effect/mine/shrapnel/sting
	name = "stinger mine"
	shrapnel_type = /obj/projectile/bullet/pellet/stingball

/obj/effect/mine/kickmine
	name = "kick mine"

/obj/effect/mine/kickmine/mineEffect(mob/victim)
	if(isliving(victim) && victim.client)
		to_chat(victim, "<span class='userdanger'>You have been kicked FOR NO REISIN!</span>")
		qdel(victim.client)


/obj/effect/mine/gas
	name = "oxygen mine"
	var/gas_amount = 360
	var/gas_type = "o2"
	disarm_product = /obj/item/deployablemine/gas

/obj/effect/mine/gas/mineEffect(mob/victim)
	atmos_spawn_air("[gas_type]=[gas_amount]")


/obj/effect/mine/gas/plasma
	name = "incendiary mine"
	gas_type = "plasma"
	disarm_product = /obj/item/deployablemine/plasma


/obj/effect/mine/gas/n2o
	name = "knockout mine"
	gas_type = "n2o"
	disarm_product = /obj/item/deployablemine/sleepy

/obj/effect/mine/sound
	name = "honkblaster 1000"
	var/sound = 'sound/items/bikehorn.ogg'
	var/volume = 100
	disarm_time = 1200 // very long disarm time to expand the annoying factor
	disarm_product = /obj/item/deployablemine/honk

/obj/effect/mine/sound/mineEffect(mob/victim)
	playsound(loc, sound, volume, 1)

/obj/effect/mine/sound/attackby(obj/item/soundsynth/J, mob/user, params)
	if(istype(J, /obj/item/soundsynth))
		to_chat(user, "<span class='notice'>You change the sound settings of the [src].</span>")
		sound = J.selected_sound


/obj/effect/mine/sound/bwoink
	name = "bwoink mine"
	sound = 'sound/effects/adminhelp.ogg'

/obj/effect/mine/pickup
	name = "pickup"
	desc = "pick me up"
	icon = 'icons/effects/effects.dmi'
	icon_state = "electricity2"
	density = FALSE
	var/duration = 0

/obj/effect/mine/pickup/Initialize(mapload)
	. = ..()
	animate(src, pixel_y = 4, time = 20, loop = -1)

/obj/effect/mine/pickup/triggermine(mob/victim)
	if(triggered)
		return
	triggered = 1
	invisibility = INVISIBILITY_ABSTRACT
	mineEffect(victim)
	qdel(src)


/obj/effect/mine/pickup/bloodbath
	name = "Red Orb"
	desc = "You feel angry just looking at it."
	duration = 1200 //2min
	color = "#FF0000"
	var/mob/living/doomslayer
	var/obj/item/chainsaw/doomslayer/chainsaw

/obj/effect/mine/pickup/bloodbath/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='reallybig redtext'>RIP AND TEAR</span>")

	spawn(0)
		new /datum/hallucination/delusion(victim, TRUE, "demon",duration,0)

	chainsaw = new(victim.loc)
	victim.log_message("entered a blood frenzy", LOG_ATTACK)

	ADD_TRAIT(chainsaw, TRAIT_NODROP, CHAINSAW_FRENZY_TRAIT)
	victim.drop_all_held_items()
	victim.put_in_hands(chainsaw, forced = TRUE)
	chainsaw.attack_self(victim)
	victim.reagents.add_reagent(/datum/reagent/medicine/adminordrazine,25)
	to_chat(victim, "<span class='warning'>KILL, KILL, KILL! YOU HAVE NO ALLIES ANYMORE, KILL THEM ALL!</span>")

	var/datum/client_colour/colour = victim.add_client_colour(/datum/client_colour/bloodlust)
	QDEL_IN(colour, 11)
	doomslayer = victim
	RegisterSignal(src, COMSIG_PARENT_QDELETING, PROC_REF(end_blood_frenzy))
	QDEL_IN(WEAKREF(src), duration)

/obj/effect/mine/pickup/bloodbath/proc/end_blood_frenzy()
	SIGNAL_HANDLER

	if(doomslayer)
		to_chat(doomslayer, "<span class='notice'>Your bloodlust seeps back into the bog of your subconscious and you regain self control.</span>")
		doomslayer.log_message("exited a blood frenzy", LOG_ATTACK)
	if(chainsaw)
		qdel(chainsaw)

/obj/effect/mine/pickup/healing
	name = "Blue Orb"
	desc = "You feel better just looking at it."
	color = "#0000FF"

/obj/effect/mine/pickup/healing/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel great!</span>")
	victim.revive(full_heal = 1, admin_revive = 1)

/obj/effect/mine/pickup/speed
	name = "Yellow Orb"
	desc = "You feel faster just looking at it."
	color = "#FFFF00"
	duration = 300

/obj/effect/mine/pickup/speed/mineEffect(mob/living/carbon/victim)
	if(!victim.client || !istype(victim))
		return
	to_chat(victim, "<span class='notice'>You feel fast!</span>")
	victim.add_movespeed_modifier(MOVESPEED_ID_YELLOW_ORB, update=TRUE, priority=100, multiplicative_slowdown=-2, blacklisted_movetypes=(FLYING|FLOATING))
	addtimer(CALLBACK(src, PROC_REF(finish_effect), victim), duration)

/obj/effect/mine/pickup/speed/proc/finish_effect(mob/living/carbon/victim)
	victim.remove_movespeed_modifier(MOVESPEED_ID_YELLOW_ORB)
	to_chat(victim, "<span class='notice'>You slow down.</span>")
