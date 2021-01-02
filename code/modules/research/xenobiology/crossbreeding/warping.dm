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
	var/warp_charge = 1
	///max number of charge, might be different depending on the crossbreed
	var/max_charge = 1
	///time it takes to store the rune back into the crossbreed
	var/storing_time = 15
	///time it takes to draw the rune
	var/drawing_time = 5 SECONDS

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
	var/storing_time = 5
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
		space_crystal.amount--
		playsound(src, 'sound/effects/phasein.ogg', 20, TRUE)

		if(space_crystal.amount <= 0)
			qdel(space_crystal)


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
		if(warp_charge >= max_charge)
			to_chat(user, "<span class='warning'>[src] is already full!</span>")
			return

		else if(do_after(user, storing_time,target = target) && warp_charge < max_charge)
			warping_crossbreed_absorb(target, user)
			return

	if(warp_charge < 1) //check if we have at least 1 charge left.
		to_chat(user, "<span class='warning'>[src] is empty!</span>")
		return

	if(do_after(user, drawing_time,target = target))
		if(warp_charge >= 1 && !locate(/obj/effect/warped_rune) in target) //check one last time if a rune has been drawn during the do_after and if there's enough charges left
			warping_crossbreed_spawn(target,user)


///spawns the rune, taking away one rune charge
/obj/item/slimecross/warping/proc/warping_crossbreed_spawn(atom/target, mob/user)
	playsound(target, 'sound/effects/slosh.ogg', 20, TRUE)
	warp_charge--
	new runepath(target)
	to_chat(user, "<span class='notice'>You carefully draw the rune with [src].</span>")


///absorb the rune into the crossbreed adding one more charge to the crossbreed.
/obj/item/slimecross/warping/proc/warping_crossbreed_absorb(atom/target, mob/user)
	to_chat(user, "<span class='notice'>You store the rune in [src].</span>")
	qdel(target)
	warp_charge++
	return
/*
/obj/effect/warped_rune/proc/check_cd(user)
	if(world.time < cooldown)
		if(user)
			to_chat(user, "<span class='warning'>[src] is recharging energy.</span>")
		return FALSE
	return TRUE

/obj/effect/warped_rune/proc/make_cd()
	cooldown = world.time + max_cooldown
*/
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

/obj/item/slimecross/warping/grey
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
				..()
				break
		else
			to_chat(user, "<span class='warning'>Requires a [extractype ? "[extractype] extracts" : "slime extract"].</span>")


/*The orange rune warp basically ignites whoever walks on it,the fire will teleport you at random as long as you are on fire*/
/obj/item/slimecross/warping/orange
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

/obj/item/slimecross/warping/purple
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

/obj/item/slimecross/warping/blue
	colour = "blue"
	runepath = /obj/effect/warped_rune/cyanspace //we'll call the blue rune cyanspace to not mix it up with actual bluespace rune
	effect_desc = ""

/obj/effect/warped_rune/cyanspace
	icon_state = "rune_blue"

/obj/effect/warped_rune/cyanspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(3, src))
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
	drawing_time = 50 //Longer to draw like most griefing runes
	storing_time = 25
	max_charge = 4 //higher to allow a wider degree of fuckery, still takes a long ass time to draw but you can draw multiple ones at once.
	warp_charge = 4

//It's a wall what do you want from me
/obj/effect/warped_rune/metalspace
	desc = "Words are powerful things, they can stop someone dead in their tracks if used in the right way"
	icon_state = "rune_metal"
	density = TRUE

/obj/effect/warped_rune/metalspace/do_effect(mob/user)
	for(var/turf/open/T in RANGE_TURFS(3, src))
		new /obj/effect/forcefield/mime(T)
	. = ..()

/obj/item/slimecross/warping/yellow
	colour = "yellow"
	runepath = /obj/effect/warped_rune/yellowspace
	effect_desc = ""


/obj/effect/warped_rune/yellowspace
	desc = ""
	icon_state = "rune_yellow"

/obj/effect/warped_rune/yellowspace/Crossed(atom/movable/AM, oldloc)
	var/obj/item/stock_parts/cell/C = AM.get_cell()
	if(!C && isliving(AM))
		var/mob/living/L = AM
		for(var/obj/item/I in L.GetAllContents())
			C = AM.get_cell()
			if(C)
				break
	if(C)
		do_sparks(5,FALSE,C)
		for(var/mob/living/L in rune_turf)
			electrocute_mob(L, C, src)
		C.use(C.charge)
		activated = TRUE
	. = ..()


/* Dark purple crossbreed, Fill up any beaker like container with 50 unit of plasma dust every 30 seconds */
/obj/item/slimecross/warping/darkpurple
	colour = "dark purple"
	runepath = /obj/effect/warped_rune/darkpurplespace
	effect_desc = "Makes a rune that will periodically create plasma dust,to harvest it simply put a beaker of some kind over the rune."


/obj/effect/warped_rune/darkpurplespace//done
	icon = 'icons/obj/slimecrossing.dmi'
	icon_state = "rune_dark_purple"
	desc = "The purple ocean would only grow bigger with time."

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
/obj/item/slimecross/warping/silver
	colour = "silver"
	effect_desc = "Draws a rune that will absorb nutriment from foods that are above it and then redistribute it to anyone passing by."
	runepath = /obj/effect/warped_rune/silverspace


/obj/effect/warped_rune/silverspace//done
	desc = "Feed me and I will feed you back, such is the deal."
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
/obj/item/slimecross/warping/bluespace
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

/obj/item/slimecross/warping/sepia
	colour = "sepia"
	runepath = /obj/effect/warped_rune/sepiaspace
	effect_desc = "Draws a rune that make people grow older and slower until they eventually wither away."

/obj/effect/warped_rune/sepiaspace
	desc = "The clock is ticking, but in what direction?"
	icon_state = "rune_sepia"

/obj/effect/warped_rune/sepiaspace/Crossed(atom/movable/AM, oldloc)
	new /obj/effect/timestop(rune_turf, null, null, null)
	activated = TRUE
	. = ..()

/obj/item/slimecross/warping/cerulean
	colour = "cerulean"
	runepath = /obj/effect/warped_rune/ceruleanspace
	effect_desc = ""

/obj/effect/warped_rune/ceruleanspace
	desc = ""
	icon_state = "rune_cerulean"
	var/mob/living/last_mob

/obj/effect/warped_rune/ceruleanspace/Crossed(atom/movable/AM, oldloc)
	if(isliving(AM))
		last_mob = AM
	..()

/obj/effect/warped_rune/ceruleanspace/do_effect(mob/user)
	if(last_mob)
		DuplicateObject(last_mob, TRUE, FALSE, rune_turf)
	. = ..()

/obj/item/slimecross/warping/pyrite
	colour = "pyrite"
	runepath = /obj/effect/warped_rune/pyritespace
	effect_desc = "draws a rune that will randomly color whatever steps on it"

/obj/effect/warped_rune/pyritespace
	desc = "Who shall we be today? they asked, but not even the canvas would answer."
	icon_state = "rune_pyrite"
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

/obj/item/slimecross/warping/red
	colour = "red"
	runepath = /obj/effect/warped_rune/redspace
	effect_desc = "Draws a rune giving your fists the ability to hurt the very soul of whoever you punch, healing you in the process."

/obj/effect/warped_rune/redspace
	desc = "Progress is made through adversity, power is obtained through violence"
	icon_state = "rage_rune"

/obj/effect/warped_rune/redspace/Crossed(atom/movable/AM, oldloc)
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		for(var/obj/item/I in H.get_equipped_items())
		I.AddElement(/datum/element/decal/blood)
		playsound(src, 'sound/effects/blobattack.ogg', 50, TRUE)
	. = ..()
