
//BeanieStation13 Redux

//Plus a bobble hat, lets be inclusive!!

/*
	Contents:

		White, black, red, green, dark blue, purple, yellow, orange and cyan beanies.

		Christmas, striped, red striped, blue striped, green striped, durathread beanies.

		Red striped bobble hat (waldo hat), rastacap.

*/

/obj/item/clothing/head/beanie
	name = "beanie"
	desc = "A stylish beanie. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their heads."
	icon_state = "beanie"
	custom_price = PAYCHECK_MINIMAL * 1.2
	greyscale_colors = "#EEEEEE#EEEEEE"
	greyscale_config = /datum/greyscale_config/beanie
	greyscale_config_worn = /datum/greyscale_config/beanie_worn
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/beanie/black
	name = "black beanie"
	greyscale_colors = "#4A4A4B#4A4A4B"

/obj/item/clothing/head/beanie/red
	name = "red beanie"
	greyscale_colors = "#D91414#D91414"

/obj/item/clothing/head/beanie/green
	name = "green beanie"
	greyscale_colors = "#5C9E54#5C9E54"

/obj/item/clothing/head/beanie/purple
	name = "purple beanie"
	greyscale_colors = "#9557C5#9557C5"

/obj/item/clothing/head/beanie/cyan
	name = "cyan beanie"
	greyscale_colors = "#54A3CE#54A3CE"

/obj/item/clothing/head/beanie/darkblue
	name = "dark blue beanie"
	greyscale_colors = "#1E85BC#1E85BC"

/obj/item/clothing/head/beanie/yellow
	name = "yellow beanie"
	icon_state = "beanie"
	greyscale_colors = "#E0C14F#E0C14F"

/obj/item/clothing/head/beanie/orange
	name = "orange beanie"
	icon_state = "beanie"
	greyscale_colors = "#C67A4B#C67A4B"

//Striped Beanies have unique sprites

/obj/item/clothing/head/beanie/striped
	name = "striped beanie"
	icon_state = "beanie"
	greyscale_colors = "#ffffff#000000"

/obj/item/clothing/head/beanie/stripedred
	name = "striped beanie"
	icon_state = "beanie"
	greyscale_colors = "#ffffff#ff0000"

/obj/item/clothing/head/beanie/stripedblue
	name = "striped beanie"
	icon_state = "beanie"
	greyscale_colors = "#ffffff#0a1df5"

/obj/item/clothing/head/beanie/stripedgreen
	name = "striped beanie"
	icon_state = "beanie"
	greyscale_colors = "#ffffff#20fc08"

/obj/item/clothing/head/beanie/christmas
	name = "christmas beanie"
	greyscale_colors = "#038000#960000"

/obj/item/clothing/head/beanie/durathread
	name = "durathread beanie"
	desc = "A beanie made from durathread, its resilient fibres provide some protection to the wearer."
	greyscale_colors = "#8291A1#8291A1"
	armor = list("melee" = 15, "bullet" = 5, "laser" = 15, "energy" = 5, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5, "stamina" = 20)

/obj/item/clothing/head/waldo
	name = "red striped bobble hat"
	desc = "If you're going on a worldwide hike, you'll need some cold protection."
	icon_state = "waldo_hat"

/obj/item/clothing/head/rasta
	name = "rastacap"
	desc = "Perfect for tucking in those dreadlocks."
	icon_state = "beanierasta"
