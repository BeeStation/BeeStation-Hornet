/obj/item/reagent_containers/food/snacks/candy_corn
	name = "candy corn"
	desc = "It's a handful of candy corn. Can be stored in a detective's hat."
	icon_state = "candy_corn"
	list_reagents = list(/datum/reagent/consumable/nutriment = 4, /datum/reagent/consumable/sugar = 2)
	filling_color = "#FF8C00"
	tastes = list("candy corn" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/candy_corn/prison
	name = "desiccated candy corn"
	desc = "If this candy corn were any harder Security would confiscate it for being a potential shiv."
	force = 1 // the description isn't lying
	throwforce = 1 // if someone manages to bust out of jail with candy corn god bless them
	tastes = list("bitter wax" = 1)
	foodtype = GROSS

/obj/item/reagent_containers/food/snacks/candiedapple
	name = "candied apple"
	desc = "An apple coated in sugary sweetness."
	icon_state = "candiedapple"
	bitesize = 3
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 3)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/caramel = 5)
	filling_color = "#FF4500"
	tastes = list("apple" = 2, "caramel" = 3)
	foodtype = JUNKFOOD | FRUIT | SUGAR

/obj/item/reagent_containers/food/snacks/mint
	name = "mint"
	desc = "It is only wafer thin."
	icon_state = "mint"
	bitesize = 1
	trash = /obj/item/trash/plate
	list_reagents = list(/datum/reagent/toxin/minttoxin = 2)
	filling_color = "#800000"
	foodtype = TOXIC | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/chocolatebar
	name = "chocolate bar"
	desc = "Such sweet, fattening food."
	icon_state = "chocolatebar"
	list_reagents = list(/datum/reagent/consumable/nutriment = 2, /datum/reagent/consumable/sugar = 2, /datum/reagent/consumable/cocoa = 2)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/chococoin
	name = "chocolate coin"
	desc = "A completely edible but nonflippable festive coin."
	icon_state = "chococoin"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/cocoa = 1)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/fudgedice
	name = "fudge dice"
	desc = "A little cube of chocolate that tends to have a less intense taste if you eat too many at once."
	icon_state = "chocodice"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/cocoa = 1)
	filling_color = "#A0522D"
	trash = /obj/item/dice/fudge
	tastes = list("fudge" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/chocoorange
	name = "chocolate orange"
	desc = "A festive chocolate orange."
	icon_state = "chocoorange"
	bonus_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 1)
	list_reagents = list(/datum/reagent/consumable/nutriment = 3, /datum/reagent/consumable/sugar = 1)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 3, "oranges" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_SMALL

/obj/item/reagent_containers/food/snacks/tinychocolate
	name = "chocolate"
	desc = "A tiny and sweet chocolate."
	icon_state = "tiny_chocolate"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/sugar = 1, /datum/reagent/consumable/cocoa = 1)
	filling_color = "#A0522D"
	tastes = list("chocolate" = 1)
	foodtype = JUNKFOOD | SUGAR

// Gum

///obj/item/food/bubblegum Need to port this some time

/obj/item/reagent_containers/food/snacks/gumball
	name = "gumball"
	desc = "A colorful, sugary gumball."
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "gumball"
	list_reagents = list(/datum/reagent/consumable/sugar = 5, /datum/reagent/medicine/bicaridine = 2, /datum/reagent/medicine/kelotane = 2)	//Kek
	tastes = list("candy")
	foodtype = JUNKFOOD
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_TINY

/obj/item/reagent_containers/food/snacks/gumball/Initialize(mapload)
	. = ..()
	color = rgb(rand(0, 255), rand(0, 255), rand(0, 255))

/obj/item/reagent_containers/food/snacks/gumball/cyborg
	var/spamchecking = TRUE

/obj/item/reagent_containers/food/snacks/gumball/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/reagent_containers/food/snacks/gumball/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/reagent_containers/food/snacks/gumball/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

/obj/item/reagent_containers/food/snacks/lollipop
	name = "lollipop"
	desc = "A delicious lollipop. Makes for a great Valentine's present."
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/consumable/nutriment/vitamin = 1, /datum/reagent/iron = 10, /datum/reagent/consumable/sugar = 5, /datum/reagent/medicine/omnizine = 2)	//Honk
	var/mutable_appearance/head
	var/headcolor = rgb(0, 0, 0)
	tastes = list("candy" = 1)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	slot_flags = ITEM_SLOT_MASK
	w_class = WEIGHT_CLASS_TINY
	///Essentially IsEquipped
	var/chewing = TRUE
	///Time between bites
	var/bite_frequency = 30 SECONDS
	///ID for timer
	var/timer_id

/obj/item/reagent_containers/food/snacks/lollipop/Initialize(mapload)
	. = ..()
	head = mutable_appearance('icons/obj/lollipop.dmi', "lollipop_head")
	change_head_color(rgb(rand(0, 255), rand(0, 255), rand(0, 255)))

/obj/item/reagent_containers/food/snacks/lollipop/proc/change_head_color(C)
	headcolor = C
	cut_overlay(head)
	head.color = C
	add_overlay(head)

/obj/item/reagent_containers/food/snacks/lollipop/throw_impact(atom/hit_atom, datum/thrownthing/throwingdatum)
	..(hit_atom)
	throw_speed = 1
	throwforce = 0

/obj/item/reagent_containers/food/snacks/lollipop/Destroy()
	if(timer_id)
		deltimer(timer_id)
	..()

/obj/item/reagent_containers/food/snacks/lollipop/equipped(mob/user, slot)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null
	chewing = (slot == ITEM_SLOT_MASK ? TRUE : FALSE)
	if(chewing) //Set a timer to chew(), instead of calling chew for the convenience of being able to equip/unequip our pop
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/reagent_containers/food/snacks/lollipop/dropped(mob/user)
	. = ..()
	if(timer_id)
		deltimer(timer_id)
		timer_id = null

/obj/item/reagent_containers/food/snacks/lollipop/proc/chew()
	if(iscarbon(loc) && chewing)
		var/mob/living/carbon/M = loc
		if(M.health <= 0)
			return
		attack(M, M)
		timer_id = addtimer(CALLBACK(src, PROC_REF(chew)), bite_frequency, TIMER_STOPPABLE)

/obj/item/reagent_containers/food/snacks/lollipop/long
	name = "longpop"
	desc = "Twice the size, half the flavour!"
	icon = 'icons/obj/lollipop.dmi'
	icon_state = "lollipop_stick_long"

/obj/item/reagent_containers/food/snacks/lollipop/long/equipped(mob/user, slot)
	..()
	if(chewing)
		RegisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN, PROC_REF(on_trip), user)
	else
		UnregisterSignal(user, COMSIG_LIVING_STATUS_KNOCKDOWN)

/obj/item/reagent_containers/food/snacks/lollipop/long/proc/on_trip(mob/living/carbon/user)
	visible_message("<span class='danger'>[user] is impailed by the [src]!</span>", "<span class='danger'>You are impaled by the [src]!</span>")
	user.adjustBruteLoss(50)
	user.adjustOxyLoss(50)

/obj/item/reagent_containers/food/snacks/lollipop/cyborg
	var/spamchecking = TRUE

/obj/item/reagent_containers/food/snacks/lollipop/cyborg/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(spamcheck)), 1200)

/obj/item/reagent_containers/food/snacks/lollipop/cyborg/equipped(mob/living/user, slot)
	. = ..(user, slot)
	spamchecking = FALSE

/obj/item/reagent_containers/food/snacks/lollipop/cyborg/proc/spamcheck()
	if(spamchecking)
		qdel(src)

/obj/item/reagent_containers/food/snacks/spiderlollipop
	name = "spider lollipop"
	desc = "Still gross, but at least it has a mountain of sugar on it."
	icon_state = "spiderlollipop"
	list_reagents = list(/datum/reagent/consumable/nutriment = 1, /datum/reagent/toxin = 1, /datum/reagent/iron = 10, /datum/reagent/consumable/sugar = 5, /datum/reagent/medicine/omnizine = 2) //lollipop, but vitamins = toxins
	filling_color = "#00800"
	tastes = list("cobwebs" = 1, "sugar" = 2)
	foodtype = JUNKFOOD | SUGAR
	/*food_flags = FOOD_FINGER_FOOD*/
	w_class = WEIGHT_CLASS_TINY
