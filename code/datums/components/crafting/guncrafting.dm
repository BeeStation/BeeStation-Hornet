//Gun crafting parts til they can be moved elsewhere

// PARTS //
/obj/item/weaponcrafting
	name = "weapon part"
	icon = 'icons/obj/improvised.dmi'
	icon_state = "receiver"

/obj/item/weaponcrafting/receiver
	name = "modular receiver"
	desc = "A prototype modular receiver and trigger assembly for a firearm."

/obj/item/weaponcrafting/stock
	name = "rifle stock"
	desc = "A classic rifle stock that doubles as a grip, roughly carved out of wood."
	custom_materials = list(/datum/material/wood = MINERAL_MATERIAL_AMOUNT * 6)
	icon_state = "riflestock"

/obj/item/weaponcrafting/silkstring
	name = "silkstring"
	desc = "A long piece of Silk that looks like a cable coil."
	icon_state = "silkstring"

/obj/item/weaponcrafting/energy_crystal
	name = "energy crystal"
	desc = "An energy crystal made out of uranium used in the construction of energy weaponry. A warning lable reads 'Warning: Do Not Ingest'."
	custom_materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT * 1)
	material_flags = MATERIAL_EFFECTS
	icon_state = "crystal"

/obj/item/weaponcrafting/energy_crystal/syndicate

/obj/item/weaponcrafting/energy_crystal/disabler
	name = "disabler energy crystal"
	desc = "An energy crystal used in non-lethal security force bows."
	custom_materials = list(/datum/material/diamond = MINERAL_MATERIAL_AMOUNT * 0.5)
	icon_state = "crystal_disabler"

// ATTACHMENTS //

/obj/item/weaponcrafting/attachment

/obj/item/weaponcrafting/attachment/bowfangs
	name = "Bow Fangs"
	desc = "Fangs that can be attached to a bow to make it more suitable for hand to hand combat."
	icon_state = "bow_fangs"

/obj/item/weaponcrafting/attachment/bowfangs/bone
	name = "Bone Bow Fangs"
	desc = "Fangs made out of bone that can be attached to a bow to make it more suitable for hand to hand combat."
	icon_state = "bow_fangs_bone"
