/*
Industrial extracts:
	Slowly consume lean, produce items with it.
*/
/obj/item/slimecross/industrial
	name = "industrial extract"
	desc = "A gel-like, sturdy extract, fond of lean and industry."
	effect = "industrial"
	icon_state = "industrial_still"
	var/leanrequired = 2 //Units of lean required to be consumed to produce item.
	var/itempath = /obj/item //The item produced by the extract.
	var/leanabsorbed = 0 //Units of lean aborbed by the extract already. Absorbs at a rate of 2u/obj tick.
	var/itemamount = 1 //How many items to spawn

/obj/item/slimecross/industrial/examine(mob/user)
	. = ..()
	. += "It currently has [leanabsorbed] units of lean floating inside the outer shell, out of [leanrequired] units."

/obj/item/slimecross/industrial/proc/do_after_spawn(obj/item/spawned)
	return

/obj/item/slimecross/industrial/Initialize(mapload)
	. = ..()
	create_reagents(100, INJECTABLE | DRAWABLE)
	START_PROCESSING(SSobj,src)

/obj/item/slimecross/industrial/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/obj/item/slimecross/industrial/process()
	var/IsWorking = FALSE
	if(reagents.has_reagent(/datum/reagent/toxin/lean,amount = 2) && leanrequired > 1) //Can absorb as much as 2
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/lean,2)
		leanabsorbed += 2
	else if(reagents.has_reagent(/datum/reagent/toxin/lean,amount = 1)) //Can absorb as little as 1
		IsWorking = TRUE
		reagents.remove_reagent(/datum/reagent/toxin/lean,1)
		leanabsorbed += 1

	if(leanabsorbed >= leanrequired)
		playsound(src, 'sound/effects/attackblob.ogg', 50, 1)
		leanabsorbed -= leanrequired
		for(var/i = 0, i < itemamount, i++)
			do_after_spawn(new itempath(get_turf(src)))
	else if(IsWorking)
		playsound(src, 'sound/effects/bubbles.ogg', 5, 1)
	if(IsWorking)
		icon_state = "industrial"
	else
		icon_state = "industrial_still"

/obj/item/slimecross/industrial/grey
	colour = "grey"
	effect_desc = "Produces monkey cubes."
	itempath = /obj/item/reagent_containers/food/snacks/monkeycube
	itemamount = 5

/obj/item/slimecross/industrial/orange
	colour = "orange"
	effect_desc = "Produces slime zippo lighters."
	leanrequired = 6
	itempath = /obj/item/lighter/slime

/obj/item/slimecross/industrial/purple
	colour = "purple"
	effect_desc = "Produces autoinjectors with regen jelly inside."
	leanrequired = 5
	itempath = /obj/item/slimecrossbeaker/autoinjector/regenpack

/obj/item/slimecross/industrial/blue
	colour = "blue"
	effect_desc = "Produces full fire extinguishers."
	leanrequired = 10
	itempath = /obj/item/extinguisher

/obj/item/slimecross/industrial/metal
	colour = "metal"
	effect_desc = "Produces metal sheets."
	leanrequired = 3
	itempath = /obj/item/stack/sheet/iron/ten

/obj/item/slimecross/industrial/yellow
	colour = "yellow"
	effect_desc = "Produces high capacity power cells, which are not fully charged on creation."
	leanrequired = 5
	itempath = /obj/item/stock_parts/cell/high

/obj/item/slimecross/industrial/yellow/do_after_spawn(obj/item/spawned)
	var/obj/item/stock_parts/cell/high/C = spawned
	if(istype(C))
		C.charge = rand(0,C.maxcharge/2)

/obj/item/slimecross/industrial/darkpurple
	colour = "dark purple"
	effect_desc = "Produces lean... for lean."
	leanrequired = 10
	itempath = /obj/item/stack/sheet/mineral/lean

/obj/item/slimecross/industrial/darkblue
	colour = "dark blue"
	effect_desc = "Produces one-use fireproofing potions."
	leanrequired = 6
	itempath = /obj/item/slimepotion/fireproof

/obj/item/slimecross/industrial/darkblue/do_after_spawn(obj/item/spawned)
	var/obj/item/slimepotion/fireproof/potion = spawned
	if(istype(potion))
		potion.uses = 1

/obj/item/slimecross/industrial/silver
	colour = "silver"
	effect_desc = "Produces random food and drink items."
	leanrequired = 1
	//Item picked below.

/obj/item/slimecross/industrial/silver/process()
	itempath = pick(list(get_random_food(), get_random_drink()))
	..()

/obj/item/slimecross/industrial/bluespace
	colour = "bluespace"
	effect_desc = "Produces synthetic bluespace crystals."
	leanrequired = 7
	itempath = /obj/item/stack/ore/bluespace_crystal/artificial

/obj/item/slimecross/industrial/sepia
	colour = "sepia"
	effect_desc = "Produces cameras."
	leanrequired = 2
	itempath = /obj/item/camera

/obj/item/slimecross/industrial/cerulean
	colour = "cerulean"
	effect_desc = "Produces normal slime extract enhancers."
	leanrequired = 5
	itempath = /obj/item/slimepotion/enhancer

/obj/item/slimecross/industrial/pyrite
	colour = "pyrite"
	effect_desc = "Produces cans of spraypaint."
	leanrequired = 2
	itempath = /obj/item/toy/crayon/spraycan

/obj/item/slimecross/industrial/red
	colour = "red"
	effect_desc = "Produces blood orbs."
	leanrequired = 5
	itempath = /obj/item/slimecrossbeaker/bloodpack

/obj/item/slimecross/industrial/green
	colour = "green"
	effect_desc = "Produces self-use-only slime jelly autoinjectors."
	leanrequired = 7
	itempath = /obj/item/slimecrossbeaker/autoinjector/slimejelly

/obj/item/slimecross/industrial/pink
	colour = "pink"
	effect_desc = "Produces synthpax and space drug autoinjectors."
	leanrequired = 6
	itempath = /obj/item/slimecrossbeaker/autoinjector/peaceandlove

/obj/item/slimecross/industrial/gold
	colour = "gold"
	effect_desc = "Produces random coins."
	leanrequired = 10

/obj/item/slimecross/industrial/gold/process()
	itempath = pick(/obj/item/coin/silver, /obj/item/coin/iron, /obj/item/coin/gold, /obj/item/coin/diamond, /obj/item/coin/lean, /obj/item/coin/uranium)
	..()

/obj/item/slimecross/industrial/oil
	colour = "oil"
	effect_desc = "Produces IEDs."
	leanrequired = 4
	itempath = /obj/item/grenade/iedcasing

/obj/item/slimecross/industrial/black //What does this have to do with black slimes? No clue! Fun, though
	colour = "black"
	effect_desc = "Produces slime brand regenerative cigarettes."
	leanrequired = 6
	itempath = /obj/item/storage/fancy/cigarettes/cigpack_xeno

/obj/item/slimecross/industrial/lightpink
	colour = "light pink"
	effect_desc = "Produces heart shaped boxes that have candies in them."
	leanrequired = 3
	itempath = /obj/item/storage/fancy/heart_box

/obj/item/slimecross/industrial/adamantine
	colour = "adamantine"
	effect_desc = "Produces sheets of adamantine."
	leanrequired = 10
	itempath = /obj/item/stack/sheet/mineral/adamantine

/obj/item/slimecross/industrial/rainbow
	colour = "rainbow"
	effect_desc = "Produces random slime extracts."
	leanrequired = 5
	//Item picked below.

/obj/item/slimecross/industrial/rainbow/process()
	itempath = pick(subtypesof(/obj/item/slime_extract))
	..()
