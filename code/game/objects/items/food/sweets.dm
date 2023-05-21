//Miscellaneous Sweets
/obj/item/food/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/sugar = 2
	)
	tastes = list("candy corn" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/candy_corn/prison
	name = "desiccated candy corn"
	desc = "If this candy corn were any harder Security would confiscate it for being a potential shiv."
	force = 1 // the description isn't lying
	throwforce = 1 // if someone manages to bust out of jail with candy corn god bless them
	tastes = list("bitter wax" = 1)
	foodtypes = JUNKFOOD | GROSS

/obj/item/food/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	bite_consumption = 3
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 5,
		/datum/reagent/consumable/sugar = 3,
		/datum/reagent/consumable/caramel = 5,
	)
	tastes = list("apple" = 2, "caramel" = 3)
	foodtypes = JUNKFOOD | FRUIT | SUGAR
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/mint
	name = "mint"
	desc = "It is only wafer thin."
	icon_state = "mint"
	bite_consumption = 1
	food_reagents = list(/datum/reagent/toxin/minttoxin = 2)
	foodtypes = TOXIC | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

//Chocolates
/obj/item/food/chocolatebar
	name = "chocolate bar"
	desc = "Such, sweet, fattening food."
	icon_state = "chocolatebar"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 2,
		/datum/reagent/consumable/sugar = 2,
		/datum/reagent/consumable/cocoa = 2,
	)
	tastes = list("chocolate" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/chococoin
	name = "chocolate coin"
	desc = "A completely edible but non-flippable festive coin."
	icon_state = "chococoin"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 4,
		/datum/reagent/consumable/cocoa = 1,
		/datum/reagent/consumable/sugar = 1,
	)
	tastes = list("chocolate" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/fudgedice
	name = "fudge dice"
	desc = "A little cube of chocolate that tends to have a less intense taste if you eat too many at once."
	icon_state = "chocodice"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/cocoa = 1,
		/datum/reagent/consumable/sugar = 1,
	)
	trash_type = /obj/item/dice/fudge
	tastes = list("fudge" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/chocoorange
	name = "chocolate orange"
	desc = "A festive chocolate orange."
	icon_state = "chocoorange"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 3,
		/datum/reagent/consumable/sugar = 1,
	)
	tastes = list("chocolate" = 3, "oranges" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_SMALL

/obj/item/food/bonbon
	name = "bon bon"
	desc = "A tiny and sweet chocolate."
	icon_state = "tiny_chocolate"
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/sugar = 1,
		/datum/reagent/consumable/cocoa = 1,
	)
	tastes = list("chocolate" = 1)
	foodtypes = DAIRY | JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	w_class = WEIGHT_CLASS_TINY

// Gum

///obj/item/food/bubblegum Need to port this some time

/obj/item/food/gumball
	name = "gumball"
	desc = "A colorful, sugary gumball."
	icon = 'icons/obj/food/lollipop.dmi'
	icon_state = "gumball"
	worn_icon_state = "bubblegum"
	food_reagents = list(
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/bicaridine = 2,
		/datum/reagent/medicine/kelotane = 2
	)	//Kek
	tastes = list("candy")
	foodtypes = JUNKFOOD
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY

/obj/item/food/gumball/Initialize(mapload)
	. = ..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

/obj/item/food/gumball/cyborg
	var/spamchecking = TRUE

/obj/item/food/gumball/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/food/gumball/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/food/gumball/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

// Lollipop
/obj/item/food/lollipop
	name = "lollipop"
	desc = "A delicious lollipop. Makes for a great Valentine's present."
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick"
	item_state = null
	food_reagents = list(
		/datum/reagent/consumable/nutriment = 1,
		/datum/reagent/consumable/nutriment/vitamin = 1,
		/datum/reagent/iron = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/omnizine = 2
	)
	tastes = list("candy" = 1)
	foodtypes = JUNKFOOD | SUGAR
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY
	var/mutable_appearance/head
	var/headcolor = rgb(0, 0, 0)
	///Essentially IsEquipped
	var/chewing = TRUE
	///Time between bites
	var/bite_frequency = 30 SECONDS
	///ID for timer
	var/timer_id

/obj/item/food/lollipop/Initialize(mapload)
	. = ..()
	head = mutable_appearance('icons/obj/lollipop.dmi', "lollipop_head")
	change_head_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))

/obj/item/food/lollipop/proc/change_head_color(C)
	headcolor = C
	cut_overlay(head)
	head.color = C
	add_overlay(head)

/obj/item/food/lollipop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..(hit_atom)
	throw_speed = 1
	throwforce = 0

/obj/item/food/lollipop/Destroy()
	if(timer_id)
		deltimer(timer_id)
	..()

/obj/item/food/lollipop/equipped(mob/user, slot)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	chewing = (slot == ITEM_SLOT_MASK ? TRUE : FALSE)
	if(chewing) //Set a timer to chew(), instead of calling chew for the convenience of being able to equip/unequip our pop
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/food/lollipop/dropped(mob/user)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/obj/item/food/lollipop/proc/chew()
	if(iscarbon(loc) && chewing)
		var/mob/living/carbon/M = loc
		if(M.health <= 0)
			return
		attack(M, M)
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/food/lollipop/long
	name = "longpop"
	desc = "Twice the size, half the flavour!"
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick_long"

/obj/item/food/lollipop/long/equipped(mob/user, slot)
	..()
	if(chewing)
		RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_trip), user)
	else
		UnregisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN)

/obj/item/food/lollipop/long/proc/on_trip(mob/living/carbon/user)
	visible_message("<span class='danger'>[user] is impaled by the [src]!</span>", "<span class='danger'>You are impaled by the [src]!</span>")
	user.adjustBruteLoss(50)
	user.adjustOxyLoss(50)

/obj/item/food/lollipop/cyborg
	var/spamchecking = TRUE

/obj/item/food/lollipop/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/food/lollipop/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/food/lollipop/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

/obj/item/food/spiderlollipop
	name = "spider lollipop"
	desc = "Still gross, but at least it has a mountain of sugar on it."
	icon_state = "spiderlollipop"
	worn_icon_state = "lollipop_stick"
	food_reagents = list(
		/datum/reagent/consumable/nutriment/protein = 2,
		/datum/reagent/toxin = 1,
		/datum/reagent/iron = 10,
		/datum/reagent/consumable/sugar = 5,
		/datum/reagent/medicine/omnizine = 2,
	) //lollipop, but vitamins = toxins
	tastes = list("cobwebs" = 1, "sugar" = 2)
	foodtypes = JUNKFOOD | SUGAR //| BUGS
	food_flags = FOOD_FINGER_FOOD
	slot_flags = ITEM_SLOT_MASK
