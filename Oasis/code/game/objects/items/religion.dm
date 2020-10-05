/obj/item/banner/clown
	name = "Honkmother banner"
	desc = "The banner of the Honkmother. Make her proud!"
	icon_state = "banner_clown"
	item_state = "banner_clown"
	lefthand_file = 'icons/mob/inhands/equipment/banners_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/banners_righthand.dmi'
	job_loyalties = list("Clown")
	warcry = "Honk!"

/obj/item/banner/clown/mundane
	inspiration_available = FALSE

/datum/crafting_recipe/clown_banner
	name = "Honkmother banner"
	result = /obj/item/banner/clown/mundane
	time = 40
	reqs = list(/obj/item/stack/rods = 2,
				/obj/item/clothing/shoes/clown_shoes= 1)
	category = CAT_MISC
