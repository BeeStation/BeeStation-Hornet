/obj/item/ammo_box/magazine/internal
	desc = "Oh god, this shouldn't be here"
	flags_1 = CONDUCT_1
	item_flags = PSEUDO_ITEM
	multiload = TRUE
	abstract_type = /obj/item/ammo_box/magazine/internal

//internals magazines are accessible, so replace spent ammo if full when trying to put a live one in
/obj/item/ammo_box/magazine/internal/give_round(obj/item/ammo_casing/R)
	return ..(R,1)
