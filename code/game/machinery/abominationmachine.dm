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
	var/creature_name = ""
	var/n_arms_eaten = 0
	var/n_legs_eaten = 0
	var/n_organs_eaten = 0
	var/n_ublood_eaten = 0

/obj/machinery/abomachine/proc/release_creature(premature = FALSE)
	var/mob/living/simple_animal/hostile/netherworld/blankbody/creature = new (src.loc)	//to be replaced? Blank bodies are cool too
	
	creature.name = "abomination"
	if (creature_name!="")
		creature.name = creature_name
	creature.desc = "a mass of limbs and organs disgustingly welded together with flesh."
	
	//life	
	n_ublood_eaten = reagents.get_reagent_amount(datum/reagent/medicine/synthflesh)*3 + reagents.get_reagent_amount(datum/reagent/blood)
	creature.maxHealth = 40+max(n_organs_eaten*20 + n_ublood_eaten * 2,200)
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
	
	//Reset the machine
	has_creature = FALSE
	n_arms_eaten = 0
	n_legs_eaten = 0
	n_organs_eaten = 0
	n_ublood_eaten = 0
	creature_name = ""
	reagents.clear_reagents()
	update_icon()
	
	return creature

/obj/machinery/abomachine/obj_destruction()	//what is the difference?
	release_creature(TRUE)
	..()

/obj/machinery/abomachine/Initialize()
	. = ..()
	create_reagents(300, OPENCONTAINER)
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
				update_icon()
			else
				n_organs_eaten = n_organs_eaten + 1
			qdel(thing)
			return TRUE	
			
		if (!has_creature)//no creature inside
			return FALSE
		
		if (istype(thing, obj/item/organ/brain))
		
			to_chat(user, "<span class='notice'>You offer [src] to [SM]...</span>")	
			var/obj/item/organ/brain/brian = thing
			
			if(brian.brainmob && brian.brainmob.mind) //enslave the current mind into the creature
			
				var/mob/creature = release_creature(FALSE)
				brainmob.mind.transfer_to(creature)
				creature.key = brian.brainmob.mind.key
				creature.mind.enslave_mind_to_creator(user)
				creature.sentience_act()
				to_chat(creature, "<span class='warning'>All at once it makes sense: you know what you are and who you are! Self awareness is yours!</span>")
				to_chat(creature, "<span class='userdanger'>You are grateful to be self aware and owe [user.real_name] a great debt. Serve [user.real_name], and assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
				creature.copy_languages(user)	
			
			else //create a ghostpoll
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
			if (!has_creature)
				to_chat(user, "<span class='notice'>There is no creature inside of the [src].</span>")
			else
				to_chat(user, "<span class='notice'>You feed the [I] through a small gap in [src], as it attaches to the fleshy mass.</span>")
				
	if(default_unfasten_wrench(user, I))
		return
	
	if (istype(I, /obj/item/pen))
		var/input = stripped_input(user,"What will your horror be named?", ,"", MAX_NAME_LEN)
		if(QDELETED(I) || !user.canUseTopic(I, BE_CLOSE))
			return
		creature_name = input
	..()