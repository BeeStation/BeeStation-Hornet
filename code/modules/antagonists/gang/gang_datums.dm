// Gang datums go here. If you want to create a new gang, you must be sure to edit:
// name
// color (must be a hex, "blue" isn't acceptable due to how spraycans are handled)
// inner_outfits (must be a list() with typepaths of the clothes in it. One is fine, but there is support for multiple: one will be picked at random when bought)
// outer_outfits (same as above)
// You also need to make a gang graffiti, that will go in crayondecal.dmi inside our icons(not tg's), with the same name of the gang it's assigned to. Nothing else,just the icon.
// Those are all required. If one is missed, stuff could break.

/datum/team/gang/clandestine
	name = "Pizza Hut"
	color = "#FF0000"
	inner_outfits = list(/obj/item/clothing/under/syndicate/combat)
	outer_outfits = list(/obj/item/clothing/suit/jacket)

/datum/team/gang/prima
	name = "Domino's Pizza"
	color = "#FFFF00"
	inner_outfits = list(/obj/item/clothing/under/color/yellow)
	outer_outfits = list(/obj/item/clothing/suit/hastur)

/datum/team/gang/zerog
	name = "Little Caesars"
	color = "#C0C0C0"
	inner_outfits = list(/obj/item/clothing/under/suit_jacket/white)
	outer_outfits = list(/obj/item/clothing/suit/hooded/wintercoat)

/datum/team/gang/max
	name = "Marco's Pizza"
	color = "#800000"
	inner_outfits = list(/obj/item/clothing/under/color/maroon)
	outer_outfits = list(/obj/item/clothing/suit/poncho/red)

/datum/team/gang/blasto
	name = "Papa Murphy's"
	color = "#000080"
	inner_outfits = list(/obj/item/clothing/under/suit_jacket/navy)
	outer_outfits = list(/obj/item/clothing/suit/jacket/miljacket)

/datum/team/gang/waffle
	name = "Round Table Pizza"
	color = "#808000"
	inner_outfits = list(/obj/item/clothing/under/suit_jacket/green)
	outer_outfits = list(/obj/item/clothing/suit/poncho)

/datum/team/gang/north
	name = "Pizza Ranch"
	color = "#00FF00"
	inner_outfits = list(/obj/item/clothing/under/color/green)
	outer_outfits = list(/obj/item/clothing/suit/poncho/green)

/datum/team/gang/omni
	name = "Godfather's Pizza"
	color = "#008080"
	inner_outfits = list(/obj/item/clothing/under/color/teal)
	outer_outfits = list(/obj/item/clothing/suit/chaplainsuit/studentuni)

/datum/team/gang/newton
	name = "Cici's Pizza"
	color = "#A52A2A"
	inner_outfits = list(/obj/item/clothing/under/color/brown)
	outer_outfits = list(/obj/item/clothing/suit/toggle/owlwings)

/datum/team/gang/cyber
	name = "Chuck E. Cheese Pizza"
	color = "#808000"
	inner_outfits = list(/obj/item/clothing/under/color/lightbrown)
	outer_outfits = list(/obj/item/clothing/suit/nemes)

/datum/team/gang/donk
	name = "Sbarro Pizza"
	color = "#0000FF"
	inner_outfits = list(/obj/item/clothing/under/color/darkblue)
	outer_outfits = list(/obj/item/clothing/suit/apron/overalls)
