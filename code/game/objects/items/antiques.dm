#define NO_GOD 0
#define GOD_CAUTERIZE 1
#define GOD_MEND 2
#define GOD_CLEANSE 3
#define GOD_ELDRITCH 4
#define GOD_STONE 5
#define GOD_SIGHT 6
#define GOD_MUTE 7
#define GOD_PARALIZE 8
#define GOD_FORCE 9
#define GOD_NETHER 10
#define GODS_MAX 10

/obj/item/artifact
	name = "antique"
	desc = "An antique item of some sort..."
	icon = 'icons/obj/fluff.dmi'
	icon_state = "paperstack"
	var/inUse = FALSE
	var/deity = NO_GOD
	var/last_use = 0
	var/godname = "Anime"
	var/activated = FALSE

/obj/item/artifact/Initialize()
	..()
	switch(rand(1,3))
		if (1)
			name = "Locket"
			desc = "A precious container for someone's cherished memories."
			icon_state = "alocket"
		if (2)
			name = "Homeworld"
			desc = "A miniature representation of someone's home planet."
			icon_state = "aplanet"
		if (3)
			name = "Porcelain Doll"
			desc = "A precious porcelain doll resembling an harlequin."
			icon_state = "adoll"

/obj/item/artifact/posessed/Initialize()
	..()
	if (prob(33))
		deity = rand(1,GODS_MAX)
		switch (deity)
			if (GOD_NETHER)
				godname = "Lobon"
			if (GOD_SIGHT)
				godname = "Nath-Horthath"
			if (GOD_STONE)
				godname = "Oukranos"
			if (GOD_CLEANSE)
				godname = "Tamash"
			if (GOD_MEND)
				godname = "Karakal"
			if (GOD_CAUTERIZE)
				godname = "D’endrrah"
			if (GOD_MUTE)
				godname = "Abhoth"
			if (GOD_FORCE)
				godname = "Ialdagorth"
			if (GOD_PARALIZE)
				godname = "C'thalpa"
			if (GOD_ELDRITCH)
				godname = "Yomagn'tho"	

/obj/item/artifact/examine(mob/user)
	. = ..()
	if (deity == NO_GOD)
		return .
	var/boon_type = deity < GOD_ELDRITCH ? "curse" : "blessing"
	
	var/mob/living/carbon/C = user
	var/datum/antagonist/heretic/heretic_user = user.mind.has_antag_datum(/datum/antagonist/heretic)	
	if (heretic_user || (istype(C) && C.job == "Curator"))		
		if (activated)
			var/boon = "The [name] bestows the [boon_type] of [godname], "			
			switch (deity)
				if (GOD_MEND)
					boon += "mending burns on the target."
				if (GOD_CAUTERIZE)
					boon += "healing bruises on the target."
				if (GOD_CLEANSE)
					boon += "flushing toxins from the target."
				if (GOD_NETHER)
					boon += "sending a hostile creature on the target."
				if (GOD_SIGHT)
					boon += "blinding the target."
				if (GOD_STONE)
					boon += "petrifying the target."
				if (GOD_MUTE)
					boon += "preventing the target from speaking"
				if (GOD_FORCE)
					boon += "pushing the target away."
				if (GOD_PARALIZE)
					boon += "paralyzing the target."
				if (GOD_ELDRITCH)
					boon += "healing Heretics and damages others."				
			. += boon
		else if (heretic_user)
			. += "Use it while holding a Codex Cicatrix in your other hand to perform a ritual of admration for [godname], and infuse this [src] with a magical effect."			
		if (!heretic_user?.has_deity(deity))
			. += "Performing a ritual of admration for [godname] will grant you a charge to your Codex Cicatrix."

/obj/item/artifact/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	..()
	if(world.time > last_use && proximity_flag)
		to_chat(user,"<span class='warning'>You try to hex [target] with the [src]!</span>")
		if (HAS_TRAIT(target,TRAIT_WARDED))
			to_chat(user,"<span class='warning'>[target] is warded against your hex!</span>")
			to_chat(target,"<span class='warning'>Your crucifix protects you against [user]'s hex!</span>")
		else 
			infuse_blessing(user,target)
		last_use = world.time + 300 SECONDS

/obj/item/artifact/attack_self(mob/living/user)
	. = ..()
	if (deity != NO_GOD || inUse)
		return .
	
	//activate ritual
	if (!activated && IS_HERETIC(user))			
		//check for book
		var/obj/item/forbidden_book/book = null
		for(var/X in user.held_items)
			if(!istype(X,/obj/item/forbidden_book))
				continue
			book = X
			break
		if (!book)
			to_chat(user,"<span class='notice'>You need to hold a Codex Cicatrix to perform a ritual!</span>")
			return FALSE
			
		inUse = TRUE
		to_chat(user,"<span class='notice'>You begin chanting the ritual!</span>")
		while (do_after(user,3 SECONDS) && !activated)
			if (prob(15))
				var/datum/antagonist/heretic/ritualist = user.mind.has_antag_datum(/datum/antagonist/heretic)
				var/result = "[godname] grants you their blessing!"
				if (!activated)
					result += ". The [src] is now blessed"
				if (!ritualist.has_deity(deity))
					result += " and you have gained the favor of [godname]"
					book.charge += 1
				to_chat(user,"<span class='notice'>[result].</span>")
				activated = TRUE
				ritualist.gain_deity(deity)
			user.whisper(pick("hypnos","celephalis","azathoth","dagon","yig","ex oblivione","nyarlathotep","nathicana","arcadia","astrophobos"), language = /datum/language/rlyehian, forced = "eldritch invocation")		
	else 
		infuse_blessing(user,user)
	inUse = FALSE

/obj/item/artifact/proc/infuse_blessing(mob/living/user,mob/living/carbon/human/target)
	if (!activated || !istype(target))
		return FALSE
	switch (deity)
		// Beneficial?
		if (GOD_CAUTERIZE)
			target.adjustBruteLoss(-30)
			to_chat(target,"<span class='notice'>Your bruises heal up!</span>")	
		if (GOD_MEND)
			target.adjustFireLoss(-30)
			to_chat(target,"<span class='notice'>You burns recover!</span>")	
		if (GOD_CLEANSE)
			target.adjustToxLoss(-30)
			to_chat(target,"<span class='notice'>You body recovers!</span>")	
			
		//Harmful	
		if (GOD_ELDRITCH)			
			target.reagents.add_reagent(/datum/reagent/eldritch, 10)	
			to_chat(target,"<span class='warning'>Your abdomen hurts!</span>")	
		if (GOD_STONE)			
			target.petrify(10 SECONDS)
			to_chat(target,"<span class='warning'>Your skin turns to stone!</span>")			
		if (GOD_SIGHT)
			target.blind_eyes(3)
			target.blur_eyes(9)
			to_chat(target,"<span class='warning'>You suddenly cannot see!</span>")
		if (GOD_MUTE)
			target.silent = max(target.silent,3 SECONDS)
			to_chat(target,"<span class='warning'>You suddenly cannot talk!</span>")
		if (GOD_PARALIZE)
			target.adjustStaminaLoss(50)
			to_chat(target,"<span class='warning'>You suddenly feel tired!</span>")
		if (GOD_FORCE)
			target.Knockdown(2 SECONDS)
			var/atom/throw_target = get_edge_target_turf(target, user.dir)
			if(!target.anchored)
				target.throw_at(throw_target, rand(4,8), 14, user)
			to_chat(target,"<span class='warning'>A powerful force pushes you away!</span>")
		if (GOD_NETHER)				
			var/mob/living/simple_animal/hostile/netherworld/blankbody/spawninstance = new /mob/living/simple_animal/hostile/netherworld/blankbody(get_turf(target))
			spawninstance.target = target
			to_chat(target,"<span class='warning'>[spawninstance] materializes and looks at you with hate!</span>")
	return TRUE

#undef NO_GOD
#undef GOD_CAUTERIZE
#undef GOD_MEND
#undef GOD_CLEANSE
#undef GOD_ELDRITCH
#undef GOD_STONE
#undef GOD_SIGHT
#undef GOD_MUTE
#undef GOD_PARALIZE
#undef GOD_FORCE
#undef GOD_NETHER
#undef GODS_MAX
