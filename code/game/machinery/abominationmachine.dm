////////////////////////////////////////
//Monster beacon
////////////////////////////////////////

/obj/item/sbeacondrop/abomachine
	desc = "A label on it reads: <i>Warning: Activating this device will send an abomination chamber to your location</i>."
	droptype = /obj/machinery/abomachine
	
////////////////////////////////////////
//Actual Machine
////////////////////////////////////////
	
/obj/machinery/abomachine
	icon = 'icons/obj/machines/cloning.dmi'
	icon_state = "pod_g"
	name = "abomination chamber"
	desc = "A horrible machine that uses modern science to weld humans into horrible abominations."

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
	
/obj/machinery/abomachine/examine(mob/user)
	. = ..()
	if (has_creature)
		. += {"Looks like something is inside. It's twirling, squirming and begging for escape... Should I?"}

/obj/machinery/abomachine/proc/release_creature(premature = FALSE)
	var/mob/living/simple_animal/hostile/abomination/creature = new (src.loc)	//to be replaced? Blank bodies are cool too
	if (creature==null)
		return	//uh oh something went rogue
	
	if (creature_name!="")
		creature.name = creature_name
	
	//life	
	n_ublood_eaten = reagents.get_reagent_amount(datum/reagent/medicine/synthflesh)*3 + reagents.get_reagent_amount(datum/reagent/liquidgibs) * 2+ reagents.get_reagent_amount(datum/reagent/blood)
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
		
	//mutations
	var/can_mutate = reagents.get_reagent_amount(datum/reagent/medicine/mutagen)>10 // tresspass mutagen
		creature.mutate_random()
	
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

/obj/machinery/abomachine/proc/birth_sentience(key, user)	// ???
	var/mob/creature = release_creature(FALSE)
	
	creature.mind.enslave_mind_to_creator(user)
	creature.sentience_act()
	to_chat(creature, "<span class='warning'>What happened? Where is my beautiful body! What is this?!</span>")
	to_chat(creature, "<span class='userdanger'>You are trapped in the body of [creature] and, while you may or may not be angry at [user.real_name] for enslaving you, you cannot help but follow [user.p_their()] every command. You cannot remember your past, all you know is that [user.real_name] brought you to life to assist [user.p_them()] in completing [user.p_their()] goals at any cost.</span>")
	creature.copy_languages(user)
	
	return creature

/obj/machinery/abomachine/obj_destruction()	
	release_creature(TRUE)
	..()

/obj/machinery/abomachine/Initialize()
	. = ..()
	create_reagents(300, OPENCONTAINER)
	update_icon()
	
/obj/machinery/abomachine/update_icon()
	icon_state = has_creature ? "pod_g" : "pod_0"

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
		
			to_chat(user, "<span class='notice'>You offer [thing] to [src]...</span>")	
			var/obj/item/organ/brain/brian = thing
			
			if(brian.brainmob && brian.brainmob.mind) //enslave the current mind into the creature
			
				var/mob/creature = birth_sentience(brian.brainmob.mind.key,user)
				brainmob.mind.transfer_to(creature)
			
			else //create a ghostpoll
				var/list/candidates = pollCandidatesForMob("Do you want to play as [SM.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, SM, POLL_IGNORE_SENTIENCE_POTION)
				if(LAZYLEN(candidates))
				
					var/mob/dead/observer/C = pick(candidates)
					birth_sentience(C.key,user)
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
	
////////////////////////////////////////
//Custom Monster
////////////////////////////////////////

/mob/living/simple_animal/hostile/abomination
	name = "abomination"
	desc = "a mass of limbs and organs disgustingly welded together"
	deathmessage = "shrieks, as it melts down into flesh."
	icon = 'icons/mob/mob.dmi'
	icon_state = "horror"
	icon_living = "horror"
	health = 80
	maxHealth = 80
	obj_damage = 15
	melee_damage = 35
	attacktext = "claws"
	attack_sound = 'sound/weapons/bladeslice.ogg'
	faction = list("creature")
	speak_emote = list("gurgles")
	atmos_requirements = list("min_oxy" = 0, "max_oxy" = 0, "min_tox" = 0, "max_tox" = 0, "min_co2" = 0, "max_co2" = 0, "min_n2" = 0, "max_n2" = 0)
	minbodytemp = 0
	hardattacks = TRUE
	gold_core_spawnable = NO_SPAWN
	del_on_death = 1
	loot = list(/obj/effect/gibspawner/generic)
	
/mob/living/simple_animal/hostile/abomination/proc/mutate_random()
	switch (rand(1,100))
		if(0 to 20)		//speedy boy
			speed = speed*2
			health = health/2
			maxHealth = maxHealth/2
			obj_damage = 15
			desc = desc + " into a slim, agile silhouette."
		if(20 to 40)	//chunkeh boye
			speed = speed/2
			health = health*3
			maxHealth = maxHealth*3
			desc = desc + " into huge mass of flesh."
		if(40 to 60)	//sus boye
			melee_damage = melee_damage*2/3
			obj_damage = obj_damage/3
			health = health*2/3
			maxHealth = maxHealth*2/3
			ventcrawler = VENTCRAWLER_ALWAYS
			desc = desc + " into a little ball of flesh."
		if(60 to 70)	//spidy boy
			ranged = 1
			ranged_cooldown_time = 60
			projectiletype = /obj/item/projectile/mega_arachnid
			projectilesound = 'sound/weapons/pierce.ogg'
			health = health*2/3
			maxHealth = maxHealth*2/3
			desc = desc + " into a spider like creature."
		if(70 to 80)	//toxin boy
			ranged = 1
			projectiletype = /obj/item/projectile/bullet/neurotoxin
			projectilesound = 'sound/weapons/pierce.ogg'
			health = health*2/3
			maxHealth = maxHealth*2/3
			desc = desc + " into a toxin spewing tumor."
		if(80 to 90)	//bullet boy
			ranged = 1
			rapid = 3
			projectilesound = 'sound/weapons/gunshot.ogg'
			projectiletype = /obj/item/projectile/hivebotbullet
			health = health/2
			maxHealth = maxHealth/2
			melee_damage = melee_damage/2
			obj_damage = obj_damage/3
			desc = desc + " into a bone hurling monster."
		if(90 to 100)	//brainiac
			ranged = 1
			ranged_cooldown_time = 20
			projectiletype = /obj/item/projectile/beam/mindflayer
			fire_sound = 'sound/weapons/laser.ogg'
			health = health*2/3
			maxHealth = maxHealth*2/3
			melee_damage = melee_damage*2/3
			obj_damage = obj_damage/3
			speak_emote = list("smugly declares")
			desc = desc + " into what looks like a crawling brain."