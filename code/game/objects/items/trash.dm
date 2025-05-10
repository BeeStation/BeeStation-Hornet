//Added by Jack Rost
/obj/item/trash
	icon = 'icons/obj/janitor.dmi'
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	desc = "This is rubbish."
	w_class = WEIGHT_CLASS_TINY
	resistance_flags = FLAMMABLE

/obj/item/trash/attack(mob/M, mob/living/user)
	return

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

/obj/item/trash/can/Initialize(mapload)
	. = ..()
	if(!pixel_y && !pixel_x)
		pixel_x = rand(-4,4)
		pixel_y = rand(-4,4)

///canned foods

/obj/item/trash/canned
	name = "unknown tin"
	icon = 'icons/obj/food/canned.dmi'
	icon_state = "air_empty"
	resistance_flags = NONE
	var/maint = FALSE
	var/maint_overlay = ""
	grind_results = list(/datum/reagent/aluminium = 10)

/obj/item/trash/canned/Initialize(mapload)
	. = ..()
	if(!pixel_y && !pixel_x)
		pixel_x = rand(-4,4)
		pixel_y = rand(-4,4)
	if(maint)
		maint_overlay = "can_maint"
		add_overlay(maint_overlay)
		name = "maintenance [name]"

/obj/item/trash/canned/maint
	maint = TRUE

/obj/item/trash/canned/beans
	name = "can of beans"
	icon_state = "beans_empty"

/obj/item/trash/canned/beans/maint
	maint = TRUE

/obj/item/trash/canned/peaches
	name = "canned peaches"
	icon_state = "peaches_empty"

/obj/item/trash/canned/peaches/maint
	maint = TRUE

/obj/item/trash/canned/beefbroth
	name = "can of beef stew"
	icon_state = "beef_empty"

/obj/item/trash/canned/beefbroth/maint
	maint = TRUE
