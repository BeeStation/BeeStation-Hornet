////////////////////////////////////////
//Monster beacon
////////////////////////////////////////

/obj/item/sbeacondrop/abomachine
	desc = "A label on it reads: <i>Warning: Activating this device will send a power draining device to your location</i>."
	droptype = /obj/machinery/abomachine
	
////////////////////////////////////////
//Actual Machine
////////////////////////////////////////
	
/obj/machinery/abomachine
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g"
	name = "syndicate bomb"
	desc = "A large and menacing device. Can be bolted down with a wrench."

	anchored = FALSE
	density = FALSE
	layer = BELOW_MOB_LAYER //so people can't hide it and it's REALLY OBVIOUS
	resistance_flags = FIRE_PROOF | ACID_PROOF
	speed_process = TRUE
	interaction_flags_machine = INTERACT_MACHINE_OFFLINE

	var/has_creature = FALSE
	var/n_arms_eaten = 0
	var/n_legs_eaten = 0
	var/n_organs_eaten = 0
	var/n_ublood_eaten = 0

/obj/machinery/abomachine/proc/release_creature(premature = FALSE)
	var/mob/living/simple_animal/hostile/netherworld/blankbody/creature = new (src.loc)	//to be replaced? Blank bodies are cool too
	
	creature.name = "abomination"
	creature.desc = "a mass of limbs and organs disgustingly welded together with flesh."
	
	//life	
	creature.maxHealth = 40+max(n_organs_eaten,20)*15
	creature.health = creature.maxHealth
	if (premature)
		creature.health = creature.maxHealth/2
	
	//Limbs
	creature.speed = 5-max(n_legs_eaten,10)/2
	creature.melee_damage = 10+5*max(n_arms_eaten,10)
	creature.obj_damage = 10
	if (n_arms_eaten>=4)
		creature.obj_damage = (n_arms_eaten>=8) ? 100 : 40
	
	to_chat(user, "<span class='warning'>It lives!</span>")
	has_creature = FALSE
	return creature

/obj/machinery/abomachine/obj_break()
	release_creature(TRUE)
	..()

/obj/machinery/abomachine/obj_destruction()	//what is the difference?
	release_creature(TRUE)
	..()

/obj/machinery/abomachine/Initialize()
	. = ..()
	update_icon()
	
/obj/machinery/abomachine/update_icon()
	icon_state = has_creature ? "pod_g" : "pod_0"

/obj/machinery/abomachine/examine(mob/user)
	. = ..()
	. += {"A digital display on it reads "[seconds_remaining()]"."}

/obj/machinery/abomachine/proc/feed_part(obj/item/part)
	if (istype(part, obj/item/bodypart))//can't feed non body parts		
		if (!has_creature)//no creature inside
			return FALSE
		var/obj/item/bodypart/limb = part
		if (limb.status != BODYPART_ORGANIC)
			return FALSE	//cannot feed robotic body parts either
		
		//arms 
		if (istype(limb, obj/item/bodypart/r_arm) || istype(limb, obj/item/bodypart/l_arm))		
			//if (proc(acceptchance)) 		RNG bad, use hardcap instead
				n_arms_eaten = n_arms_eaten + 1
		//legs 
		if (istype(limb, obj/item/bodypart/r_leg) || istype(limb, obj/item/bodypart/l_leg))		
				n_legs_eaten = n_legs_eaten + 1
		qdel(limb)
		return TRUE	//we done it
	
	if (istype(part, obj/item/organ))
		var/obj/item/organ/thing = part
		if (thing.status != ORGAN_ORGANIC)
			return FALSE	//cannot feed robotic body parts either
		
		if (istype(thing, obj/item/organ/heart))	//have a heart
			if (!has_creature)				
				has_creature = TRUE
			else
				n_organs_eaten = n_organs_eaten + 1
			qdel(thing)
			return TRUE	
			
		if (!has_creature)//no creature inside
			return FALSE
		
		if (istype(thing, obj/item/organ/brain))
		
			to_chat(user, "<span class='notice'>You offer [src] to [SM]...</span>")	
			var/obj/item/organ/brain/brian = thing
			
			if(brian.brainmob && brian.brainmob.mind)
			
				var/mob/creature = release_creature(FALSE)
				brainmob.mind.transfer_to(creature)
				creature.key = brian.brainmob.mind.key
				creature.mind.enslave_mind_to_creator(user)
				creature.sentience_act()
				to_chat(creature, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
				to_chat(creature, "<span class='userdanger'>You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
				creature.copy_languages(user)	
			
			var/list/candidates = pollCandidatesForMob("Do you want to play as [SM.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, SM, POLL_IGNORE_SENTIENCE_POTION)
			if(LAZYLEN(candidates))
			
				var/mob/creature = release_creature(FALSE)
				var/mob/dead/observer/C = pick(candidates)
				creature.key = C.key
				creature.mind.enslave_mind_to_creator(user)
				creature.sentience_act()
				to_chat(creature, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
				to_chat(creature, "<span class='userdanger'>You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
				creature.copy_languages(user)							
		else
			n_organs_eaten = n_organs_eaten + 1
			qdel(thing)
			return TRUE		
	return FALSE
	
/obj/machinery/abomachine/interact(mob/user)
	to_chat(src, "<span class='warning'>You start opening the [src]</span>")
	if(do_after(user, 40, src))
		var/monster = release_creature(FALSE)		
		log_game("[user] released [monster]")	//no shittery
				
/obj/machinery/abomachine/attackby(obj/item/I, mob/user, params)
	if (istype(I, obj/item/bodypart))
		if (!feed_part(I))
			//you cant attack this body part to the abomination
			to_chat(user, "<span class='notice'>[I] cannot attach on your abomination.</span>")
		else
			to_chat(user, "<span class='notice'>You feed the [I] through a small gap in [src], as it attaches to the fleshy mass.</span>")

	if(I.tool_behaviour == TOOL_WRENCH)
		if(!anchored)
			if(!isturf(loc) || isspaceturf(loc))
				to_chat(user, "<span class='notice'>[src] must be placed on solid ground to attach it.</span>")
			else
				to_chat(user, "<span class='notice'>You firmly wrench [src] to the floor.</span>")
				I.play_tool_sound(src)
				setAnchored(TRUE)
		else
			to_chat(user, "<span class='notice'>You wrench [src] from the floor.</span>")
			I.play_tool_sound(src)
			setAnchored(FALSE)
			
	else
		. = ..()

/obj/machinery/abomachine/proc/activate()
	active = TRUE
	START_PROCESSING(SSfastprocess, src)
	countdown.start()
	next_beep = world.time + 10
	detonation_timer = world.time + (timer_set * 10)
	playsound(loc, 'sound/machines/click.ogg', 30, 1)
	notify_ghosts("\A [src] has been activated at [get_area(src)]!", source = src, action = NOTIFY_ORBIT, flashwindow = FALSE, header = "Bomb Planted")

/obj/machinery/abomachine/proc/settings(mob/user)
	var/new_timer = input(user, "Please set the timer.", "Timer", "[timer_set]") as num
	if(in_range(src, user) && isliving(user)) //No running off and setting bombs from across the station
		timer_set = CLAMP(new_timer, minimum_timer, maximum_timer)
		loc.visible_message("<span class='notice'>[icon2html(src, viewers(src))] timer set for [timer_set] seconds.</span>")
	if(alert(user,"Would you like to start the countdown now?",,"Yes","No") == "Yes" && in_range(src, user) && isliving(user))
		if(!active)
			visible_message("<span class='danger'>[icon2html(src, viewers(loc))] [timer_set] seconds until detonation, please clear the area.</span>")
			activate()
			update_icon()
			add_fingerprint(user)

			if(payload && !istype(payload, /obj/item/bombcore/training))
				log_bomber(user, "has primed a", src, "for detonation (Payload: [payload.name])")
				payload.adminlog = "The [name] that [key_name(user)] had primed detonated!"
