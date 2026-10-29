// Pineapple!
/obj/item/food/grown/pineapple
	seed = /obj/item/plant_seeds/preset/pineapple
	name = "pineapples"
	desc = "Blorble."
	icon_state = "pineapple"
	bite_consumption_mod = 2
	force = 4
	throwforce = 8
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("stings", "pines")
	attack_verb_simple = list("sting", "pine")
	throw_speed = 1
	throw_range = 5
	w_class = WEIGHT_CLASS_NORMAL
	foodtypes = FRUIT | PINEAPPLE
	juice_typepath = /datum/reagent/consumable/pineapplejuice
	tastes = list("pineapple" = 1)
	wine_power = 40

/obj/item/food/grown/pineapple/make_processable()
	AddElement(/datum/element/processable, TOOL_KNIFE, /obj/item/food/pineappleslice, 3, 15, screentip_verb = "Cut")
