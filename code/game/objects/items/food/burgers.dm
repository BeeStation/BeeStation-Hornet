/obj/item/food/burger
	icon = 'icons/obj/food/burgerbread.dmi'
	icon_state = "hburger"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1
		)
	tastes = list("bun" = 2, "beef patty" = 4)
	foodtypes = GRAIN | MEAT //lettuce doesn't make burger a vegetable.
	eat_time = 15 //Quick snack
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/burger/plain
	name = "burger"
	desc = "The cornerstone of every nutritious breakfast."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/plain/Initialize(mapload)
	. = ..()
	if(prob(1))
		new/obj/effect/particle_effect/smoke(get_turf(src))
		playsound(src, 'sound/effects/smoke.ogg', 50, TRUE)
		visible_message("<span class='warning'>Oh, ye gods! [src] is ruined! But what if...?</span>")
		name = "steamed ham"
		desc = pick("Ahh, Head of Personnel, welcome. I hope you're prepared for an unforgettable luncheon!",
		"And you call these steamed hams despite the fact that they are obviously microwaved?",
		"Aurora Station 13? At this time of shift, in this time of year, in this sector of space, localized entirely within your freezer?",
		"You know, these hamburgers taste quite similar to the ones they have at the Maltese Falcon.")
		tastes = list("fast food hamburger" = 1)

/obj/item/food/burger/human
	name = "human burger"
	desc = "A bloody burger."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 5
	)
	tastes = list("bun" = 2, "long pig" = 4)
	foodtypes = MEAT | GRAIN | GORE
	var/subjectname = ""
	var/subjectjob = null

/obj/item/food/burger/human/CheckParts(list/parts_list)
	..()
	var/obj/item/food/meat/M = locate(/obj/item/food/meat/steak/plain/human) in contents
	if(M)
		subjectname = M.subjectname
		subjectjob = M.subjectjob
		if(subjectname)
			name = "[subjectname] burger"
		else if(subjectjob)
			name = "[subjectjob] burger"
		qdel(M)


/obj/item/food/burger/corgi
	name = "corgi burger"
	desc = "You monster."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | MEAT | GORE

/obj/item/food/burger/appendix
	name = "appendix burger"
	desc = "Tastes like appendicitis."
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	icon_state = "appendixburger"
	tastes = list("bun" = 4, "grass" = 2)
	foodtypes = GRAIN | MEAT | GORE

/obj/item/food/burger/fish
	name = "fillet -o- carp sandwich"
	desc = "Almost like a carp is yelling somewhere... Give me back that fillet -o- carp, give me that carp."
	icon_state = "fishburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bun" = 4, "fish" = 4)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/tofu
	name = "tofu burger"
	desc = "What.. is that meat?"
	icon_state = "tofuburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 6,
		/datum/reagent/consumable/nutriment/vitamin = 3
	)
	tastes = list("bun" = 4, "tofu" = 4)
	foodtypes = GRAIN | VEGETABLES

/obj/item/food/burger/roburger
	name = "roburger"
	desc = "The lettuce is the only organic component. Beep."
	icon_state = "roburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/nanomachines = 7,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtypes = GRAIN | TOXIC

/obj/item/food/burger/roburgerbig
	name = "roburger"
	desc = "This massive patty looks like poison. Beep."
	icon_state = "roburger"
	max_volume = 120
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 11,
		/datum/reagent/nanomachines = 140,
		/datum/reagent/consumable/nutriment/vitamin = 15
	)
	tastes = list("bun" = 4, "lettuce" = 2, "sludge" = 1)
	foodtypes = GRAIN | TOXIC

/obj/item/food/burger/xeno
	name = "xenoburger"
	desc = "Smells caustic. Tastes like heresy."
	icon_state = "xburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	tastes = list("bun" = 4, "acid" = 4)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/bearger
	name = "bearger"
	desc = "Best served rawr."
	icon_state = "bearger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 8,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/clown
	name = "clown burger"
	desc = "This tastes funny..."
	icon_state = "clownburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 12,
		/datum/reagent/medicine/mannitol = 11,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | FRUIT

/obj/item/food/burger/mime
	name = "mime burger"
	desc = "Its taste defies language."
	icon_state = "mimeburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7,
		/datum/reagent/consumable/nothing = 6
	)
	foodtypes = GRAIN

/obj/item/food/burger/brain
	name = "brainburger"
	desc = "A strange looking burger. It looks almost sentient."
	icon_state = "brainburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 12,
		/datum/reagent/medicine/mannitol = 11,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	tastes = list("bun" = 4, "brains" = 2)
	foodtypes = GRAIN | MEAT | GORE

/obj/item/food/burger/ghost
	name = "ghost burger"
	desc = "Too Spooky!"
	icon_state = "ghostburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 7,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 13,
		/datum/reagent/consumable/sodiumchloride = 5
	)
	tastes = list("bun" = 2, "ectoplasm" = 4)
	foodtypes = GRAIN
	alpha = 170
	verb_say = "moans"
	verb_yell = "wails"

/obj/item/food/burger/ghost/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)

/obj/item/food/burger/ghost/process()
	if(!isturf(loc)) //no floating out of bags
		return
	var/paranormal_activity = rand(100)
	switch(paranormal_activity)
		if(97 to 100)
			audible_message("[src] rattles a length of chain.")
			playsound(loc,'sound/spookoween/chain_rattling.ogg', 300, TRUE)
		if(91 to 96)
			say(pick("OoOoOoo.", "OoooOOooOoo!!"))
		if(84 to 90)
			dir = pick(NORTH, SOUTH, EAST, WEST, NORTHEAST, NORTHWEST, SOUTHEAST, SOUTHWEST)
			step(src, dir)
		if(71 to 83)
			step(src, dir)
		if(65 to 70)
			var/obj/machinery/light/L = locate(/obj/machinery/light) in view(4, src)
			if(L)
				L.flicker()
		if(62 to 64)
			playsound(loc,pick('sound/hallucinations/i_see_you1.ogg', 'sound/hallucinations/i_see_you2.ogg'), 50, TRUE, ignore_walls = FALSE)
		if(61)
			visible_message("[src] spews out a glob of ectoplasm!")
			new /obj/effect/decal/cleanable/greenglow/ecto(loc)
			playsound(loc,'sound/effects/splat.ogg', 200, TRUE)

		//If i was less lazy i would make the burger forcefeed itself to a nearby mob here.

/obj/item/food/burger/ghost/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/food/burger/red
	name = "red burger"
	desc = "Perfect for hiding the fact it's burnt to a crisp."
	icon_state = "cburger"
	color = COLOR_RED
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/red = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/orange
	name = "orange burger"
	desc = "Contains 0% juice."
	icon_state = "cburger"
	color = COLOR_ORANGE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/orange = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/yellow
	name = "yellow burger"
	desc = "Bright to the last bite."
	icon_state = "cburger"
	color = COLOR_YELLOW
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/yellow = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/green
	name = "green burger"
	desc = "It's not tainted meat, it's painted meat!"
	icon_state = "cburger"
	color = COLOR_GREEN
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/green = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/blue
	name = "blue burger"
	desc = "Is this blue rare?"
	icon_state = "cburger"
	color = COLOR_BLUE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/blue = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/purple
	name = "purple burger"
	desc = "Regal and low class at the same time."
	icon_state = "cburger"
	color = COLOR_PURPLE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/purple = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/black
	name = "black burger"
	desc = "This is overcooked."
	icon_state = "cburger"
	color = COLOR_ALMOST_BLACK
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/black = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/white
	name = "white burger"
	desc = "Delicous Titanium!"
	icon_state = "cburger"
	color = COLOR_WHITE
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6,
		/datum/reagent/colorful_reagent/powder/white = 10
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/spell
	name = "spell burger"
	desc = "This is absolutely Ei Nath."
	icon_state = "spellburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 8,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 11
	)
	tastes = list("bun" = 4, "magic" = 2)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/bigbite
	name = "big bite burger"
	desc = "Forget the Big Mac. THIS is the future!"
	icon_state = "bigbiteburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 7
	)
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = GRAIN | MEAT | DAIRY

/obj/item/food/burger/jelly
	name = "jelly burger"
	desc = "Culinary delight..?"
	icon_state = "jellyburger"
	tastes = list("bun" = 4, "jelly" = 2)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/jelly/slime
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/toxin/slimejelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | TOXIC

/obj/item/food/burger/jelly/cherry
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 6,
		/datum/reagent/consumable/cherryjelly = 10,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | FRUIT

/obj/item/food/burger/superbite
	name = "super bite burger"
	desc = "This is a mountain of a burger. FOOD!"
	icon_state = "superbiteburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 25,
		/datum/reagent/consumable/nutriment/protein = 42,
		/datum/reagent/consumable/nutriment/vitamin = 15
	)
	w_class = WEIGHT_CLASS_NORMAL
	bite_consumption = 7
	max_volume = 100
	tastes = list("bun" = 4, "type two diabetes" = 10)
	foodtypes = GRAIN | MEAT | DAIRY

/obj/item/food/burger/fivealarm
	name = "five alarm burger"
	desc = "HOT! HOT!"
	icon_state = "fivealarmburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/capsaicin = 5,
		/datum/reagent/consumable/condensedcapsaicin = 5,
		/datum/reagent/consumable/nutriment/vitamin = 6
	)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/rat
	name = "rat burger"
	desc = "Pretty much what you'd expect..."
	icon_state = "ratburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | MEAT | GORE

/obj/item/food/burger/baseball
	name = "home run baseball burger"
	desc = "It's still warm. The steam coming off of it looks like baseball."
	icon_state = "baseball"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | GROSS

/obj/item/food/burger/baconburger
	name = "bacon burger"
	desc = "The perfect combination of all things American."
	icon_state = "baconburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 11,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	tastes = list("bacon" = 4, "bun" = 2)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/empoweredburger
	name = "empowered burger"
	desc = "It's shockingly good, if you live off of electricity that is."
	icon_state = "empoweredburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 10,
		/datum/reagent/consumable/nutriment/protein = 5,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/liquidelectricity = 5
	)
	tastes = list("bun" = 2, "pure electricity" = 4)
	foodtypes = GRAIN | TOXIC

/obj/item/food/burger/crab
	name = "crab burger"
	desc = "A delicious patty of the crabby kind, slapped in between a bun."
	icon_state = "crabburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bun" = 2, "crab meat" = 4)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/soylent
	name = "soylent burger"
	desc = "An eco-friendly burger made using upcycled low value biomass."
	icon_state = "soylentburger"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/nutriment/protein = 9,
		/datum/reagent/consumable/nutriment/vitamin = 4
	)
	tastes = list("bun" = 2, "assistant" = 4)
	foodtypes = GRAIN | MEAT | DAIRY

/obj/item/food/burger/rib
	name = "mcrib"
	desc = "An elusive rib shaped burger with limited availablity across the galaxy. Not as good as you remember it."
	icon_state = "mcrib"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 4,
		/datum/reagent/consumable/bbqsauce = 1
	)
	tastes = list("bun" = 2, "pork patty" = 4)
	foodtypes = GRAIN | MEAT

/obj/item/food/burger/mcguffin
	name = "mcguffin"
	desc = "A cheap and greasy imitation of an eggs benedict."
	icon_state = "mcguffin"
	tastes = list("muffin" = 2, "bacon" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/eggyolk = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1
	)
	foodtypes = GRAIN | MEAT | BREAKFAST

/obj/item/food/burger/chicken
	name = "chicken sandwich" //Apparently the proud people of Americlapstan object to this thing being called a burger. Apparently McDonald's just calls it a burger in Europe as to not scare and confuse us.
	desc = "The so-called classic poultry bread cage. Considering how processed this is, the taste holds up pretty well."
	icon_state = "chickenburger"
	tastes = list("bun" = 2, "chicken" = 4)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/mayonnaise = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/consumable/cooking_oil = 2
	)
	foodtypes = GRAIN | MEAT | FRIED

/obj/item/food/burger/cheese
	name = "cheese burger"
	desc = "This noble burger stands proudly clad in golden cheese."
	icon_state = "cheeseburger"
	tastes = list("bun" = 2, "beef patty" = 4, "cheese" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/nutriment/protein = 7,
		/datum/reagent/consumable/nutriment/vitamin = 2
	)
	foodtypes = GRAIN | MEAT | DAIRY

/obj/item/food/burger/cheese/Initialize(mapload)
	. = ..()
	if(prob(33))
		icon_state = "cheeseburgeralt"

/obj/item/food/burger/crazy
	name = "crazy hamburger"
	desc = "Crazy hamburger! It is horrible!"
	icon_state = "crazyhamburger"
	tastes = list("bread made in turkey" = 2, "horse meat" = 4, "cheese from sao paulo from brazil" = 3, "red hot chili peppers" = 3, "oil from iraq" = 2, "grass of death" = 3)
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/nutriment/protein = 2,
	)
	foodtypes = GRAIN | MEAT | DAIRY | TOXIC | GROSS | FRUIT
	w_class = WEIGHT_CLASS_NORMAL // The crazy hamburger in the video was bigger than joker's hand therefore i think this weight class is adequate.

/* When custom food is supported again

// empty burger you can customize
/obj/item/food/burger/empty
	name = "burger"
	desc = "A crazy, custom burger made by a mad cook."
	icon_state = "custburg"
	tastes = list("bun")
	foodtypes = GRAIN

*/
