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

/obj/item/weaponcrafting/leatherstring
	name = "leather bow string"
	desc = "A bow string made out of leather."
	icon_state = "leatherstring"

/obj/item/weaponcrafting/energy_crystal
	name = "energy crystal"
	desc = "An energy crystal made out of uranium used in the construction of energy weaponry. A warning lable reads 'Warning: Do Not Ingest'."
	custom_materials = list(/datum/material/uranium = MINERAL_MATERIAL_AMOUNT * 1)
	material_flags = MATERIAL_EFFECTS
	icon_state = "crystal"

/obj/item/weaponcrafting/energy_crystal/syndicate

// ATTACHMENTS //

/obj/item/weaponcrafting/attachment

/obj/item/weaponcrafting/attachment/bowfangs
	name = "bow fangs"
	desc = "Fangs that can be attached to a bow to make it more suitable for hand to hand combat. It decreases accuracy, however."
	icon_state = "bow_fangs"

/obj/item/weaponcrafting/attachment/bowfangs/bone
	name = "bone bow fangs"
	desc = "Fangs made out of bone that can be attached to a bow to make it more suitable for hand to hand combat. It decreases accuracy, however."
	icon_state = "bow_fangs_bone"

/obj/item/weaponcrafting/attachment/scope
	name = "scope"
	desc = "A scope that can be added to a weapon or bow to improve accuracy."
	icon_state = "scope"

/obj/item/weaponcrafting/attachment/accelerators
	name = "accelerators"
	desc = "Cogs meant to accelerate the velocity of a weapons projectiles."
	icon_state = "accelerators"
