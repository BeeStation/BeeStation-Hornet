///Has no special properties.
/datum/material/iron
	name = "iron"
	desc = "Common iron ore often found in sedimentary and igneous layers of the crust."
	color = "#878687"
	greyscale_colors = "#878687"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/iron
	value_per_unit = 0.0025

///Breaks extremely easily but is transparent.
/datum/material/glass
	name = "glass"
	desc = "Glass forged by melting sand."
	color = "#88cdf1"
	greyscale_colors = "#88cdf196"
	alpha = 150
	categories = list(MAT_CATEGORY_RIGID = TRUE/*, MAT_CATEGORY_BASE_RECIPES = TRUE*/) //Excluding glass for now
	integrity_modifier = 0.1
	sheet_type = /obj/item/stack/sheet/glass
	shard_type = /obj/item/shard
	value_per_unit = 0.0025

/*
Color matrices are like regular colors but unlike with normal colors, you can go over 255 on a channel.
Unless you know what you're doing, only use the first three numbers. They're in RGB order.
*/

///Has no special properties. Could be good against vampires in the future perhaps.
/datum/material/silver
	name = "silver"
	desc = "Silver"
	color = list(255/255, 284/255, 302/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#e3f1f8"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/silver
	value_per_unit = 0.025

///Slight force increase
/datum/material/gold
	name = "gold"
	desc = "Gold"
	color = list(340/255, 240/255, 50/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //gold is shiny, but not as bright as bananium
	greyscale_colors = "#dbdd4c"
	strength_modifier = 1.2
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/gold
	value_per_unit = 0.0625

///Has no special properties
/datum/material/diamond
	name = "diamond"
	desc = "Highly pressurized carbon"
	color = list(48/255, 272/255, 301/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#71c8f784"
	alpha = 132
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE/*, MAT_CATEGORY_BASE_RECIPES = TRUE*/)
	sheet_type = /obj/item/stack/sheet/mineral/diamond
	value_per_unit = 0.25

///Is slightly radioactive
/datum/material/uranium
	name = "uranium"
	desc = "Uranium"
	color = rgb(48, 237, 26)
	greyscale_colors = rgb(48, 237, 26)
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/uranium
	value_per_unit = 0.05

/datum/material/uranium/on_applied(atom/source, amount, material_flags)
	. = ..()
	// Uranium structures should irradiate, but not items, because item irradiation is a lot more annoying.
	// For example, consider picking up uranium as a miner.
	if(isitem(source))
		return

	source.AddElement(/datum/element/radioactive, chance = URANIUM_IRRADIATION_INTENSITY)

/datum/material/uranium/on_removed(atom/source, amount, material_flags)
	. = ..()
	if(isitem(source))
		return
	source.RemoveElement(/datum/element/radioactive, chance = URANIUM_IRRADIATION_INTENSITY)

///Adds firestacks on hit (Still needs support to turn into gas on destruction)
/datum/material/plasma
	name = "plasma"
	desc = "Isn't plasma a state of matter? Oh whatever."
	color = list(298/255, 46/255, 352/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#c162ec"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/plasma
	value_per_unit = 0.1
	//beauty_modifier = 0.15

/datum/material/plasma/on_applied(atom/source, amount, material_flags)
	. = ..()
	if(ismovable(source))
		source.AddElement(/datum/element/firestacker, amount=1)
		source.AddComponent(/datum/component/explodable, 0, 0, amount / 1000, amount / 500, delete_after = EXPLODABLE_DELETE_PARENT)

/datum/material/plasma/on_removed(atom/source, amount, material_flags)
	. = ..()
	source.RemoveElement(/datum/element/firestacker, amount=1)
	qdel(source.GetComponent(/datum/component/explodable))

///Can cause bluespace effects on use. (Teleportation) (Not yet implemented)
/datum/material/bluespace
	name = "bluespace crystal"
	desc = "Crystals with bluespace properties"
	color = list(119/255, 217/255, 396/255,0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0)
	greyscale_colors = "#4e7dffC8"
	alpha = 200
	categories = list(MAT_CATEGORY_ORE = TRUE)
	//beauty_modifier = 0.5
	sheet_type = /obj/item/stack/ore/bluespace_crystal/refined
	value_per_unit = 0.15

///Honks and slips
/datum/material/bananium
	name = "bananium"
	desc = "Material with hilarious properties"
	color = list(460/255, 464/255, 0, 0, 0,0,0,0, 0,0,0,0, 0,0,0,1, 0,0,0,0) //obnoxiously bright yellow
	greyscale_colors = "#ffff00"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/bananium
	value_per_unit = 0.5
	//beauty_modifier = 0.5

/datum/material/bananium/on_applied(atom/source, amount, material_flags)
	. = ..()
	source.LoadComponent(/datum/component/squeak, list('sound/items/bikehorn.ogg'=1), 50)
	source.AddComponent(/datum/component/slippery, min(amount / 10, 80))

/datum/material/bananium/on_removed(atom/source, amount, material_flags)
	. = ..()
	qdel(source.GetComponent(/datum/component/slippery))
	qdel(source.GetComponent(/datum/component/squeak))


///Mediocre force increase
/datum/material/titanium
	name = "titanium"
	desc = "Titanium"
	color = "#b3c0c7"
	greyscale_colors = "#b3c0c7"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/titanium
	value_per_unit = 0.0625
	//beauty_modifier = 0.05
	//armor_modifiers = list(MELEE = 1.35, BULLET = 1.3, LASER = 1.3, ENERGY = 1.25, BOMB = 1.25, BIO = 1, FIRE = 0.7, ACID = 1)

/*
/datum/material/runite
	name = "runite"
	desc = "Runite"
	color = "#3F9995"
	greyscale_colors = "#3F9995"
	strength_modifier = 1.3
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/runite
	value_per_unit = 0.3
*/

///Force decrease
/datum/material/plastic
	name = "plastic"
	desc = "Plastic"
	color = "#caccd9"
	greyscale_colors = "#caccd9"
	strength_modifier = 0.85
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/plastic
	value_per_unit = 0.0125

///Force decrease and mushy sound effect. (Not yet implemented)
/datum/material/biomass
	name = "biomass"
	desc = "Organic matter"
	color = "#735b4d"
	greyscale_colors = "#735b4d"
	strength_modifier = 0.8
	value_per_unit = 0.025

/datum/material/wood
	name = "wood"
	desc = "Flexible, durable, but flamable. Hard to come across in space."
	color = "#bb8e53"
	greyscale_colors = "#bb8e53"
	strength_modifier = 0.5
	sheet_type = /obj/item/stack/sheet/wood
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	value_per_unit = 0.01
	//beauty_modifier = 0.1
	//armor_modifiers = list(MELEE = 1.1, BULLET = 1.1, LASER = 0.4, ENERGY = 0.4, BOMB = 1, BIO = 0.2, ACID = 0.3)
	texture_layer_icon_state = "woodgrain"

/datum/material/wood/on_applied_obj(obj/source, amount, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/wooden = source
		wooden.resistance_flags |= FLAMMABLE

/datum/material/wood/on_removed_obj(obj/source, amount, material_flags)
	. = ..()
	if(material_flags & MATERIAL_AFFECT_STATISTICS)
		var/obj/wooden = source
		wooden.resistance_flags &= ~FLAMMABLE

///Stronk force increase
/datum/material/adamantine
	name = "adamantine"
	desc = "A powerful material made out of magic, I mean science!"
	color = "#6d7e8e"
	greyscale_colors = "#6d7e8e"
	strength_modifier = 1.5
	categories = list(MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/adamantine
	value_per_unit = 0.25
	//beauty_modifier = 0.4

/datum/material/copper
	name = "copper"
	desc = "Copper is a soft, malleable, and ductile metal with very high thermal and electrical conductivity."
	color = "#d95802"
	greyscale_colors = "#d95802"
	categories = list(MAT_CATEGORY_ORE = TRUE, MAT_CATEGORY_RIGID = TRUE, MAT_CATEGORY_BASE_RECIPES = TRUE)
	sheet_type = /obj/item/stack/sheet/mineral/copper
