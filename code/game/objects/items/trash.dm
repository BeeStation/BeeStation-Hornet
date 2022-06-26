//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	desc = "This is rubbish."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/trash/raisins
	name = "\improper 4no raisins"
	icon_state= "4no_raisins"

/obj/item/trash/candy
	name = "candy"
	icon_state= "candy"

/obj/item/trash/cheesie
	name = "cheesie honkers"
	icon_state = "cheesie_honkers"

/obj/item/trash/chips
	name = "chips"
	icon_state = "chips"

/obj/item/trash/boritos
	name = "boritos bag"
	icon_state = "boritos"
	grind_results = list(/datum/reagent/aluminium = 1) //from the mylar bag

/obj/item/trash/popcorn
	name = "popcorn"
	icon_state = "popcorn"

/obj/item/trash/sosjerky
	name = "\improper Scaredy's Private Reserve Beef Jerky"
	icon_state = "sosjerky"

/obj/item/trash/syndi_cakes
	name = "syndi-cakes"
	icon_state = "syndi_cakes"

/obj/item/trash/energybar
	name = "energybar wrapper"
	icon_state = "energybar"

/obj/item/trash/waffles
	name = "waffles tray"
	icon_state = "waffles"

/obj/item/trash/pistachios
	name = "pistachios pack"
	icon_state = "pistachios_pack"

/obj/item/trash/semki
	name = "semki pack"
	icon_state = "semki_pack"

/obj/item/trash/tray
	name = "tray"
	icon_state = "tray"
	resistance_flags = NONE

/obj/item/trash/candle
	name = "candle"
	icon = 'icons/obj/candle.dmi'
	icon_state = "candle4"

/obj/item/trash/can
	name = "crushed can"
	icon_state = "cola"
	resistance_flags = NONE
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/can/food/peaches
	name = "canned peaches"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "peachcan_empty"

/obj/item/trash/can/food/peaches/maint
	name = "Maintenance Peaches"
	icon_state = "peachcanmaint_empty"

/obj/item/trash/can/food/beefbroth
	name = "canned beef broth"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "beefcan_empty"

/obj/item/trash/can/food/beans
	name = "tin of beans"
	icon = 'icons/obj/food/food.dmi'
	icon_state = "beans_empty"

/obj/item/trash/can/Initialize(mapload)
	. = ..()
	pixel_x = rand(-4,4)
	pixel_y = rand(-4,4)

// Monkestation Change Start

/obj/item/trash/attack(mob/M, mob/user, def_zone) //Just hooks into the moth clothing eating. Trash shouldn't taste good.
	if(!ishuman(M))
		return
	var/mob/living/carbon/human/H = M
	if(user.a_intent != INTENT_HARM && HAS_TRAIT(H, TRAIT_TRASH_EATER)) //Added via the goat.dm disease symptom
		var/obj/item/food/clothing/clothing_as_food = new
		clothing_as_food.name = name
		if(clothing_as_food.attack(M, user, def_zone))
			take_damage(15, sound_effect=FALSE)
		qdel(clothing_as_food)
	else
		return ..()

// Monkestation Change End

/obj/item/trash/coal
	name = "lump of coal"
	icon = 'icons/obj/mining.dmi'
	icon_state = "slag"
	desc = "Someone's gotten on the naughty list."
	grind_results = list(/datum/reagent/carbon = 20)

/obj/item/trash/coal/burn()
	visible_message("[src] fuses into a diamond! Someone wasn't so naughty after all...")
	new /obj/item/stack/ore/diamond(loc)
	qdel(src)

/obj/item/trash/peanuts
	name = "\improper Gallery peanuts packet"
	desc = "This thread is trash!"
	icon_state = "peanuts"

/obj/item/trash/cnds
	name = "\improper C&Ds packet"
	icon_state = "cnds"
