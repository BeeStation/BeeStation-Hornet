/*
Warping extracts crossbreed
put up a rune with bluespace effects, lots of those runes are fluff or act as a passive buff, others are just griefing tools
*/

/obj/item/slimecross/warping
	name = "warped extract"
	desc = "It just won't stay in place."
	icon_state = "warping"
	effect = "warping"
	colour = "grey"
	///what runes will be drawn depending on the crossbreed color
	var/obj/effect/warped_rune/runepath
	/// the number of "charge" a bluespace crossbreed start with
	var/warp_charge = INFINITY
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 5 SECONDS
	///time it takes to draw the rune
	var/drawing_time = 5 SECONDS
	var/max_cooldown = 30 SECONDS
	var/cooldown = 0

/obj/effect/warped_rune
	name = "warped rune"
	desc = "An unstable rune born of the depths of bluespace"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "greyspace_rune"
	move_resist = INFINITY //here to avoid the rune being moved since it only sets it's turf once when it's drawn. doesn't include admin fuckery.
	anchored = TRUE
	layer = MID_TURF_LAYER
	resistance_flags = FIRE_PROOF
	var/activated = FALSE
	///is only used for bluespace crystal erasing as of now
	var/storing_time = 5 SECONDS
	///Nearly all runes needs to know which turf they are on
	var/turf/rune_turf
	var/deleteme = TRUE

/obj/item/slimecross/warping/examine()
	. = ..()
	. += "It has [warp_charge] charge left"

///runes can also be deleted by bluespace crystals relatively fast as an alternative to cleaning them.
/obj/effect/warped_rune/attackby(obj/item/used_item, mob/user)
	. = ..()
	if(!istype(used_item,/obj/item/stack/sheet/bluespace_crystal) && !istype(used_item,/obj/item/stack/ore/bluespace_crystal))
		return

	var/obj/item/stack/space_crystal = used_item
	if(do_after(user, storing_time,target = src)) //the time it takes to nullify it depends on the rune too
		to_chat(user, "<span class='notice'>You nullify the effects of the rune with the bluespace crystal!</span>")
		qdel(src)
		space_crystal.use(1)
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)

/obj/effect/warped_rune/acid_act()
	. = ..()
	visible_message("<span class='warning'>[src] has been dissolved by the acid</span>")
	playsound(src, 'sound/items/welder.ogg', 150, TRUE)
	qdel(src)


///nearly all runes use their turf in some way so we set rune_turf to their turf automatically, the rune also start on cooldown if it uses one.
/obj/effect/warped_rune/Initialize()
	. = ..()
	rune_turf = get_turf(src)
	RegisterSignal(rune_turf, COMSIG_COMPONENT_CLEAN_ACT, .proc/clean_rune)

/obj/effect/warped_rune/proc/clean_rune()
	qdel(src)

///using the extract on the floor will "draw" the rune.
/obj/item/slimecross/warping/afterattack(atom/target, mob/user, proximity)
	. = ..()
	if(!proximity)
		return

	if(isturf(target) && locate(/obj/effect/warped_rune) in target) //check if the target is a floor and if there's a rune on said floor
		to_chat(user, "<span class='warning'>There is already a bluespace rune here!</span>")
		return

	if(!istype(target,/turf/open/floor) && !istype(target, runepath))
		to_chat(user, "<span class='warning'>you cannot draw a rune here!</span>")
		return

	if(istype(target, runepath)) //checks if the target is a rune and then if you can store it
		if(do_after(user, storing_time,target = target) && warp_charge)
			warping_crossbreed_absorb(target, user)
			return

	if(warp_charge < 1) //check if we have at least 1 charge left.
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(!check_cd(user))
		return

	if(do_after(user, drawing_time,target = target))
		if(warp_charge >= 1 && !locate(/obj/effect/warped_rune) in target) //check one last time if a rune has been drawn during the do_after and if there's enough charges left
			if(!check_cd(user))
				return
			warping_crossbreed_spawn(target,user)
			make_cd()


///spawns the rune, taking away one rune charge
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	warp_charge--
	new runepath(target)
	to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")


///absorb the rune into the crossbreed adding one more charge to the crossbreed.
/obj/item/slimecross/warping/proc/warping_crossbreed_absorb(atom/target, mob/user)
	//to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
	qdel(target)
	warp_charge++
	return

/obj/item/slimecross/warping/proc/check_cd(user)
	if(world.time < cooldown)
		if(user)
			to_chat(user, "<span class='warning'>[src] is recharging energy.</span>")
		return FALSE
	return TRUE

/obj/item/slimecross/warping/proc/make_cd()
	cooldown = world.time + max_cooldown

/obj/effect/warped_rune/attack_hand(mob/living/user)
	. = ..()
	do_effect(user)

/obj/effect/warped_rune/proc/do_effect(mob/user)
	SHOULD_CALL_PARENT(TRUE)
	if(deleteme)
		to_chat(user, ("<span class='notice'>[src] fades.</span>"))
		qdel(src)

/obj/effect/warped_rune/Crossed(atom/movable/AM, oldloc)
	SHOULD_CALL_PARENT(TRUE)
	. = ..()
	if(deleteme && activated)
		visible_message("<span class='notice'>[src] fades.</span>")
		qdel(src)

/obj/item/slimecross/warping/grey//done
	name = "greyspace crossbreed"
	colour = "grey"
	effect_desc = "Creates a rune. Extracts that are on the rune are absorbed, 8 extracts produces an adult slime of that color."
	runepath = /obj/effect/warped_rune/greyspace

/obj/effect/warped_rune/greyspace
	name = "greyspace rune"
	desc = "Death is merely a setback, anything can be rebuilt given the right components"
	icon_state = "rune_grey"
	///extractype is used to remember the type of the extract on the rune
	var/extractype
	var/req_extracts = 8

/obj/effect/warped_rune/greyspace/examine(mob/user)
	. = ..()
	to_chat(user, "<span class='notice'>Requires absorbing [req_extracts] [extractype ? "[extractype] extracts" : "slime extracts"].</span>")

///Makes a slime of the color of the extract that was put on the rune.can only take one type of extract between slime spawning.
/obj/effect/warped_rune/greyspace/do_effect(mob/user)
	for(var/obj/item/slime_extract/extract in rune_turf)
		if(extract.color_slime == extractype || !extractype) //check if the extract is the first one or of the right color.
			extractype = extract.color_slime
			qdel(extract) //vores the slime extract
			playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
			req_extracts--
			if(req_extracts <= 0)
				playsound(rune_turf, 'sound/effects/splat.ogg', 20, TRUE)
				new /mob/living/simple_animal/slime (rune_turf, extractype) //spawn a slime from the extract's color
				req_extracts = initial(req_extracts)
				extractype = null // reset extractype to FALSE to allow a new extract type
				. = ..()
				break
		else
			to_chat(user, "<span class='warning'>Requires a [extractype ? "[extractype] extracts" : "slime extract"].</span>")


/*The orange rune warp basically ignites whoever walks on it,the fire will teleport you at random as long as you are on fire*/
/obj/item/slimecross/warping/orange//done
	colour = "orange"
	runepath = /obj/effect/warped_rune/orangespace
	effect_desc = "Create a rune that can summon a bonfire that burns with an undying flame."

/obj/effect/warped_rune/orangespace
	desc = "Can summon a bonfire that burns with an undying flame."
	icon_state = "rune_orange"

/obj/effect/warped_rune/orangespace/do_effect(mob/user)
	var/obj/structure/bonfire/bluespace/B = new (rune_turf)
	B.StartBurning()
	. = ..()

/obj/item/slimecross/warping/purple//done
	colour = "purple"
	runepath = /obj/effect/warped_rune/purplespace
	effect_desc = ""//temp

/obj/effect/warped_rune/purplespace
	desc = ""//temp_desc
	icon_state = "rune_purple"

/obj/effect/warped_rune/purplespace/do_effect(mob/user)
	var/list/medical = list(
		/obj/item/stack/medical/gauze,
		/obj/item/reagent_containers/hypospray/medipen,
		/obj/item/stack/medical/bruise_pack,
		/obj/item/stack/medical/ointment,
		/obj/item/reagent_containers/pill/oxandrolone,
		/obj/item/storage/pill_bottle/charcoal,
		/obj/item/reagent_containers/pill/mutadone,
		/obj/item/reagent_containers/pill/antirad,
		/obj/item/reagent_containers/pill/patch/styptic,
		/obj/item/reagent_containers/pill/patch/synthflesh,
		/obj/item/reagent_containers/pill/patch/silver_sulf,
		/obj/item/healthanalyzer,
		/obj/item/surgical_drapes,
		/obj/item/scalpel,
		/obj/item/hemostat,
		/obj/item/cautery,
		/obj/item/circular_saw,
		/obj/item/surgicaldrill,
		/obj/item/retractor,
		/obj/item/blood_filter)

	for(var/i in 1 to 2)
		var/path = pick_n_take(medical)
		new path(rune_turf)
	. = ..()

/obj/item/slimecross/warping/blue//done
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = ""

/obj/effect/warped_rune/cyanspace//done
	icon_state = "rune_blue"

/obj/effect/warped_rune/cyanspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		T.MakeSlippery(TURF_WET_PERMAFROST, 1 MINUTES)
	. = ..()

/obj/effect/warped_rune/cyanspace/ComponentInitialize()
	. = ..()
	AddComponent(/datum/component/slippery, 30)

/obj/effect/warped_rune/cyanspace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		activated = TRUE
	. = ..()

/obj/item/slimecross/warping/metal
	colour = "metal"
	runepath = /obj/effect/warped_rune/metalspace
	effect_desc = "Draws a rune that prevents passage above it, takes longer to store and draw than other runes."

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "Words are powerful things, they can stop someone dead in their tracks if used in the right way"
	icon_state = "rune_metal"
	density = TRUE

/obj/effect/warped_rune/metalspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		new /obj/effect/forcefield/mime(T)
	. = ..()

/obj/item/slimecross/warping/yellow//done
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = ""

/obj/effect/warped_rune/yellowspace//done
	desc = ""
	icon_state = "rune_yellow"

/obj/effect/warped_rune/yellowspace/Crossed(atom/movable/AM, oldloc)
	var/obj/item/stock_parts/cell/C = AM.get_cell()
	if(!C && isliving(AM))
		var/mob/living/L = AM
		for(var/obj/item/I in L.GetAllContents())
			C = I.get_cell()
			if(C && C.charge)
				break
	if(C && C.charge)
		do_sparks(5,FALSE,C)
		for(var/mob/living/L in rune_turf)
			electrocute_mob(L, C, src)
		C.use(C.charge)
		activated = TRUE
	. = ..()


/* Dark purple crossbreed, Fill up any beaker like container with 50 unit of plasma dust every 30 seconds */
/obj/item/slimecross/warping/darkpurple//done
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = ""


/obj/effect/warped_rune/darkpurplespace//done
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rune_dark_purple"
	desc = ""

/obj/effect/warped_rune/darkpurplespace/do_effect(mob/user)
	if(locate(/obj/item/stack/sheet/mineral/plasma) in rune_turf)
		var/amt = 0
		for(var/obj/item/stack/sheet/mineral/plasma/P in rune_turf)
			amt += P.amount
			qdel(P)
		var/path_material = pick(subtypesof(/obj/item/stack/sheet/mineral) - /obj/item/stack/sheet/mineral/plasma)
		new path_material(rune_turf, amt)
		. = ..()
	else
		to_chat(user, "msg debug")


/* makes a rune that absorb food, whenever someone step on the rune the nutrition come back to them until they are full.*/
/obj/item/slimecross/warping/silver//done
	colour = "silver"
	effect_desc = "Draws a rune that will absorb nutriment from foods that are above it and then redistribute it to anyone passing by."
	runepath = /obj/effect/warped_rune/silverspace


/obj/effect/warped_rune/silverspace//done
	desc = ""
	icon_state = "rune_silver"
	///Used to remember how much food/nutriment has been absorbed by the rune
	var/nutriment = 0

/obj/effect/warped_rune/silverspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/consumable/nutriment, 100)
		activated = TRUE
	. = ..()

GLOBAL_DATUM_INIT(blue_storage, /obj/item/storage/backpack/holding/bluespace, new)

/obj/item/storage/backpack/holding/bluespace
	name = "warped rune"
	anchored = TRUE
	armor = list("melee" = 100, "bullet" = 100, "laser" = 100, "energy" = 100, "bomb" = 100, "bio" = 100, "rad" = 100, "fire" = 100, "acid" = 100)
	invisibility = INVISIBILITY_ABSTRACT
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF

/* Bluespace rune,reworked so that the last person that walked on the rune will swap place with the next person stepping on it*/
/obj/item/slimecross/warping/bluespace//done
	colour = "bluespace"
	runepath = /obj/effect/warped_rune/bluespace
	effect_desc = ""

/obj/effect/warped_rune/bluespace//done
	desc = ""
	icon_state = "rune_bluespace"
	deleteme = FALSE

/obj/effect/warped_rune/bluespace/do_effect(mob/user)
	if(!GLOB.blue_storage)
		GLOB.blue_storage = new
	GLOB.blue_storage.loc = loc
	var/datum/component/storage/STR = GLOB.blue_storage.GetComponent(/datum/component/storage)
	STR.show_to(user)
	. = ..()

/obj/item/slimecross/warping/sepia//done
	colour = "sepia"
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = ""

/obj/effect/warped_rune/sepiaspace//done
	desc = ""
	icon_state = "rune_sepia"

/obj/effect/warped_rune/sepiaspace/Crossed(atom/movable/AM, oldloc)
	new /obj/effect/timestop(rune_turf, null, null, null)
	activated = TRUE
	. = ..()

/obj/item/slimecross/warping/cerulean//done
	colour = "cerulean"
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = ""

/obj/effect/warped_rune/ceruleanspace//done
	desc = "A shadow of what once passed these halls, a memory perhaps?"
	icon_state = "rune_cerulean"
	deleteme = FALSE
	///hologram that will be spawned by the rune
	var/obj/effect/overlay/holotile
	///mob the hologram will copy
	var/mob/living/holo_host
	///used to remember the recent speech of the holo_host
	var/list/recent_speech
	///used to remember the timer ID that activates holo_talk

/obj/effect/warped_rune/ceruleanspace/proc/holo_talk()
	if(holotile && length(recent_speech)) //the proc should'nt be called if the list is empty in the first place but we might as well make sure.
		holotile.say(recent_speech[pick(recent_speech)]) //say one of the 10 latest sentence said by the holo_host
		addtimer(CALLBACK(src, .proc/holo_talk), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

///makes a hologram of the mob stepping on the tile, any new person stepping in will replace it with a new hologram
/obj/effect/warped_rune/ceruleanspace/Crossed(atom/movable/AM, oldloc)
	. = ..()
	if(isliving(AM) && !holo_host)
		holo_host = AM

/obj/effect/warped_rune/ceruleanspace/do_effect(mob/user)
	. = ..()
	if(holo_host && !holotile)
		holo_creation()
		deleteme = TRUE

/obj/effect/warped_rune/ceruleanspace/proc/holo_creation()
	addtimer(CALLBACK(src, .proc/holo_talk), 10 SECONDS, TIMER_OVERRIDE|TIMER_UNIQUE)

	if(locate(holotile) in rune_turf)//here to delete the previous hologram,
		QDEL_NULL(holotile)

	holotile = new(rune_turf) //setting up the hologram to look like the person that just stepped in
	holotile.icon = holo_host.icon
	holotile.icon_state = holo_host.icon_state
	holotile.alpha = 200
	holotile.name = "[holo_host.name] (Hologram)"
	holotile.add_atom_colour("#77abff", FIXED_COLOUR_PRIORITY)
	holotile.copy_overlays(holo_host, TRUE)
	holotile.anchored = TRUE
	holotile.density = FALSE

	//the code that follows is basically the code that changeling use to get people's last spoken sentences with a few tweaks.
	recent_speech = list() //resets the list from its previous sentences
	var/list/say_log = list()
	var/log_source = holo_host.logging
	for(var/log_type in log_source)
		var/nlog_type = text2num(log_type)
		if(nlog_type & LOG_SAY)
			var/list/reversed = log_source[log_type] //reverse the list so we get the last sentences instead of the first
			if(islist(reversed))
				say_log = reverseRange(reversed.Copy())
				break

	if(length(say_log) > 10) //we're going to get up to the last 10 sentences spoken by the holo_host
		recent_speech = say_log.Copy(say_log.len - 11, 0)
	else
		for(var/spoken_memory in say_log)
			if(recent_speech.len >= 10)
				break
			recent_speech[spoken_memory] = say_log[spoken_memory]

	if(!length(recent_speech)) //lazy lists don't work here for whatever reason so we set it to null manually if the list is empty.
		recent_speech = null
		return

///destroys the hologram with the rune
/obj/effect/warped_rune/ceruleanspace/Destroy()
	QDEL_NULL(holotile)
	holo_host = null
	recent_speech = null
	return ..()

/obj/item/slimecross/warping/pyrite//done
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it"

/obj/effect/warped_rune/pyritespace//done - SPRITE
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "rune_red"//icon_state = ""rune_pyrite"//missing sprite// EVAN,REVIEW IT
	var/colour = "#FFFFFF"

/obj/effect/warped_rune/pyritespace/Initialize()
	. = ..()
	switch(rand(1,8))
		if(1)
			colour = "#FF0000"
		if(2)
			colour = "#FFA500"
		if(3)
			colour = "#FFFF00"
		if(4)
			colour = "#00FF00"
		if(5)
			colour = "#0000FF"
		if(6)
			colour = "#4B0082"
		if(7)
			colour = "#FF00FF"

/obj/effect/warped_rune/pyritespace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		AM.add_atom_colour(colour, WASHABLE_COLOUR_PRIORITY)
		activated = TRUE
		playsound(src, 'sound/items/bikehorn.ogg', 50, TRUE)
	. = ..()

/obj/item/slimecross/warping/red//done
	colour = "red"
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = ""

/obj/effect/warped_rune/redspace//done
	desc = ""
	icon_state = "rune_red"

/obj/effect/warped_rune/redspace/Crossed(atom/movable/AM, oldloc)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		add_blood_DNA(list("Non-human DNA" = random_blood_type()))
		for(var/obj/item/I in H.get_equipped_items(TRUE))
			I.add_blood_DNA(return_blood_DNA())
			I.update_icon()
		for(var/obj/item/I in H.held_items)
			I.add_blood_DNA(return_blood_DNA())
			I.update_icon()
		playsound(src, 'sound/effects/blobattack.ogg', 50, TRUE)
		activated = TRUE
	. = ..()

/obj/item/slimecross/warping/green//done
	colour = "green"
	effect_desc = "The rune will transform plasma sheets into xenomorph resin when used."
	runepath = /obj/effect/warped_rune/greenspace

/obj/effect/warped_rune/greenspace//done
	desc = "We will build walls out of our fallen foes, they shall fear our very buildings."
	icon_state = "rune_green"

/obj/effect/warped_rune/greenspace/Crossed(atom/movable/AM, oldloc)
	if(ishuman(AM))
		randomize_human(AM)
		activated = TRUE
	. = ..()

/* pink rune, makes people slightly happier after walking on it*/
/obj/item/slimecross/warping/pink//done
	colour = "pink"
	effect_desc = "Draws a rune that makes people happier!"
	runepath = /obj/effect/warped_rune/pinkspace

/obj/effect/warped_rune/pinkspace//done
	desc = "Love is the only reliable source of happiness we have left. But like everything, it comes with a price."
	icon_state = "rune_pink"

///adds the jolly mood effect along with hug sound effect.
/obj/effect/warped_rune/pinkspace/Crossed(atom/movable/AM, oldloc)
	if(istype(AM, /mob/living/carbon/human))
		playsound(rune_turf, "sound/weapons/thudswoosh.ogg", 50, TRUE)
		SEND_SIGNAL(AM, COMSIG_ADD_MOOD_EVENT,"jolly", /datum/mood_event/jolly)
		to_chat(AM, "<span class='notice'>You feel happier.</span>")
		activated = TRUE
	. = ..()

//oil
/obj/item/slimecross/warping/oil//done
	colour = "oil"
	runepath = /obj/effect/warped_rune/oilspace
	effect_desc = ""

/obj/effect/warped_rune/oilspace//done
	icon_state = "rune_oil"
	desc = ""

/obj/effect/warped_rune/oilspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		var/amt = rand(4,12)
		C.reagents.add_reagent(/datum/reagent/water, amt)
		C.reagents.add_reagent(/datum/reagent/potassium, amt)
		activated = TRUE
	. = ..()

/* black rune. Revive suicided/soulless corpses by yeeting a willing soul into it via a ghost poll*/
/obj/item/slimecross/warping/black
	colour = "black"
	runepath = /obj/effect/warped_rune/blackspace
	effect_desc = "draws a rune that will attempt to repair a soulless humanoid corpse in the hope of bringing them back to life."

/obj/effect/warped_rune/blackspace
	icon_state = "rune_black"
	desc = "Souls are like any other material, you just have to find the right place to manufacture them."

/obj/effect/warped_rune/blackspace/do_effect(mob/user)
	for(var/mob/living/carbon/human/host in rune_turf)
		if(host.key) //checks if the ghost and brain's there
			to_chat(user, "<span class='warning'>This body can't be fixed by the rune in this state!</span>")
			return

		to_chat(user, "<span class='warning'>The rune is trying to repair [host.name]'s soul!</span>")
		var/list/candidates = pollCandidatesForMob("Do you want to replace the soul of [host.name]?", ROLE_SENTIENCE, null, ROLE_SENTIENCE, 50, host, POLL_IGNORE_SHADE)//todo: fix desc

		if(length(candidates) && !host.key) //check if anyone wanted to play as the dead person and check if no one's in control of the body one last time.
			var/mob/dead/observer/ghost = pick(candidates)

			host.mind.memory = "" //resets the memory since it's a new soul inside.
			host.key = ghost.key
			var/mob/living/simple_animal/shade/S = host.change_mob_type(/mob/living/simple_animal/shade , rune_turf, "Shade", FALSE)
			S.maxHealth = 1
			S.health = 1
			S.faction = host.faction
			S.copy_languages(host, LANGUAGE_MIND)
			QDEL_NULL(host)
			playsound(host, "sound/magic/castsummon.ogg", 50, TRUE)
			activated = TRUE
			return ..()

		to_chat(user, "<span class='warning'>The rune failed! Maybe you should try again later.</span>")


/obj/item/slimecross/warping/lightpink//done
	colour = "light pink"
	runepath = /obj/effect/warped_rune/lightpinkspace
	effect_desc = ""

/obj/effect/warped_rune/lightpinkspace//done
	desc = ""
	icon_state = "rune_light_pink"

/obj/effect/warped_rune/lightpinkspace/Crossed(atom/movable/AM, oldloc)
	if(iscarbon(AM))
		var/mob/living/carbon/C = AM
		C.reagents.add_reagent(/datum/reagent/pax, 10)
		activated = TRUE
	. = ..()

/obj/item/slimecross/warping/adamantine//done
	colour = "adamantine"
	runepath = /obj/effect/warped_rune/adamantinespace
	effect_desc = "draws a rune capable of copying the ores of nearby mineral rocks."

/obj/effect/warped_rune/adamantinespace//done
	desc = "The universe's ressource are nothing but tools for us to use and abuse."
	icon_state = "rune_adamantine"

/obj/effect/warped_rune/adamantinespace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(1, src) - rune_turf)
		var/obj/structure/reflector/box/anchored/D = new (T)
		D.setAngle(dir2angle(get_dir(src, D)))
		D.admin = TRUE
		QDEL_IN(D, 300)
	activated = TRUE
	. = ..()


/* Used to teleport anything over it to a unique room similar to hilbert's hotel.*/


/obj/item/slimecross/warping/rainbow
	colour = "rainbow"
	effect_desc = "draws a rune that will teleport anything above it "
	runepath = /obj/effect/warped_rune/rainbowspace


/obj/effect/warped_rune/rainbowspace
	icon_state = "rune_rainbow"
	desc = "This is where I go when I want to be alone. Yet they keep clawing at the walls until everything crumbles."
	deleteme = FALSE
	///current x,y,z location of the reserved space for the rune room
	var/datum/turf_reservation/room_reservation
	///the template of the warped_room map
	var/datum/map_template/warped_room/rune_room
	///list of people that teleported into the rune_room. The room will dissapear if the list is empty and the rune is destroyed.
	var/list/customer_list


/obj/effect/warped_room_exit
	name = "warped_rune"
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rune_rainbow"
	desc = "Use this rune if you want to leave this place. You will have to leave eventually."
	move_resist = INFINITY
	anchored = TRUE
	///where the rune will teleport you back.
	var/turf/exit_turf
	///rune linked to the exit rune
	var/obj/effect/warped_rune/rainbowspace/enter_rune


/obj/effect/warped_room_exit/Destroy() //reminder that the exit rune is destroyed when the room is destroyed too
	if(!locate(enter_rune) in exit_turf)
		exit_turf = null
		enter_rune = null
	else if(!QDELETED(enter_rune))
		QDEL_NULL(enter_rune) //here to avoid having a useless rune teleporting you to the void
	return ..()

/datum/map_template/warped_room
	name = "Warped room"
	mappath = '_maps/templates/warped_room.dmm'

/area/warped_room
	name = "warped room"
	icon_state = "yellow"
	dynamic_lighting = DYNAMIC_LIGHTING_FORCED
	requires_power = FALSE
	has_gravity = TRUE
	noteleport = TRUE


///creates the warped room and place an exit rune to exit the room
/obj/effect/warped_rune/rainbowspace/Initialize()
	. = ..()
	rune_room = new()
	room_reservation = SSmapping.RequestBlockReservation(rune_room.width, rune_room.height) //monkey sees valid location
	rune_room.load(locate(room_reservation.bottom_left_coords[1], room_reservation.bottom_left_coords[2], room_reservation.bottom_left_coords[3]))//monkey room activate
	var/obj/effect/warped_room_exit/exit_rune = new(locate(room_reservation.bottom_left_coords[1] + 3, room_reservation.bottom_left_coords[2] + 6, room_reservation.bottom_left_coords[3]))
	exit_rune.exit_turf = rune_turf
	exit_rune.enter_rune = src


///here to check if anyone's being transported in or out of the room with the user.
/obj/effect/warped_rune/rainbowspace/proc/customer_check(atom/person_checked, smuggle_in)
	var/list/hidden_customers = person_checked.GetAllContents(/mob/living/carbon/human)
	if(!LAZYLEN(hidden_customers))
		return
	for(var/mob/living/carbon/human/customer in hidden_customers)
		if(smuggle_in)
			LAZYADD(customer_list, customer) //if they enter the room
		else
			LAZYREMOVE(customer_list, customer) //if they exit the room


/obj/effect/warped_rune/rainbowspace/do_effect(mob/user)
	. = ..()
	for(var/mob/living/carbon/human/customer in rune_turf)
		customer.forceMove(locate(room_reservation.bottom_left_coords[1] + 3, room_reservation.bottom_left_coords[2] + 6, room_reservation.bottom_left_coords[3]))
		customer_check(customer, TRUE)


///Will delete the room when the rune is destroyed if no customer is left in the room.
/obj/effect/warped_rune/rainbowspace/Destroy()
	if(!LAZYLEN(customer_list))
		QDEL_NULL(room_reservation)
		customer_list = null
		rune_room = null
	return ..()


///anyone on the exit rune when it is used will be teleported to the rune that was used to teleport to the warped room
/obj/effect/warped_room_exit/attack_hand(mob/living/user)
	. = ..()
	for(var/mob/living/carbon/human/customer in get_turf(src))
		customer.forceMove(exit_turf)
		do_sparks(3, FALSE, get_turf(src))
		enter_rune.customer_check(customer, FALSE)

	if(!LAZYLEN(enter_rune.customer_list) && !locate(enter_rune) in exit_turf) //deletes the room if the rune doesn't exist anymore and all customers have left
		qdel(enter_rune.room_reservation)

