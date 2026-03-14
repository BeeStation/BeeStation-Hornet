// Banana
/obj/item/food/grown/banana
	seed = /obj/item/plant_seeds/preset/banana
	name = "banana"
	desc = "It's an excellent prop for a clown."
	icon_state = "banana"
	inhand_icon_state = "banana"
	trash_type = /obj/item/grown/bananapeel
	bite_consumption_mod = 3
	foodtypes = FRUIT
	juice_typepath = /datum/reagent/consumable/banana
	distill_reagent = /datum/reagent/consumable/ethanol/bananahonk
	dying_key = DYE_REGISTRY_BANANA

/* Wounds
/obj/item/food/grown/banana/generate_trash(atom/location)
	. = ..()
	var/obj/item/grown/bananapeel/peel = .
	if(istype(peel))
		peel.grind_results = list(/datum/reagent/medicine/coagulant/banana_peel = seed.potency * 0.2)
		peel.juice_typepath = /datum/reagent/medicine/coagulant/banana_peel
*/

/obj/item/food/grown/banana/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is aiming [src] at [user.p_them()]self! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/items/bikehorn.ogg', 50, 1, -1)
	sleep(25)
	if(!user)
		return OXYLOSS
	user.say("BANG!", forced = /datum/reagent/consumable/banana)
	sleep(25)
	if(!user)
		return OXYLOSS
	user.visible_message("<B>[user]</B> laughs so hard they begin to suffocate!")
	return OXYLOSS

//Banana Peel
/obj/item/grown/bananapeel
	name = "banana peel"
	desc = "A peel from a banana."
	lefthand_file = 'icons/mob/inhands/misc/food_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/food_righthand.dmi'
	icon_state = "banana_peel"
	inhand_icon_state = "banana_peel"
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 7
	dying_key = DYE_REGISTRY_PEEL

/obj/item/grown/bananapeel/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is deliberately slipping on [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	playsound(loc, 'sound/misc/slip.ogg', 50, 1, -1)
	return BRUTELOSS


// Mimana - invisible sprites are totally a feature!
/obj/item/food/grown/banana/mime
	name = "mimana"
	desc = "It's an excellent prop for a mime."
	icon_state = "mimana"
	trash_type = /obj/item/grown/bananapeel/mimanapeel
	distill_reagent = /datum/reagent/consumable/ethanol/silencer
	discovery_points = 300

/obj/item/grown/bananapeel/mimanapeel
	name = "mimana peel"
	desc = "A mimana peel."
	icon_state = "mimana_peel"
	inhand_icon_state = "mimana_peel"

// Bluespace Banana
/obj/item/food/grown/banana/bluespace
	name = "bluespace banana"
	icon_state = "banana_blue"
	inhand_icon_state = "bluespace_peel"
	trash_type = /obj/item/grown/bananapeel/bluespace
	tastes = list("banana" = 1)
	wine_power = 60
	wine_flavor = "slippery hypercubes"
	discovery_points = 300

/obj/item/grown/bananapeel/bluespace
	name = "bluespace banana peel"
	desc = "A peel from a bluespace banana."
	icon_state = "banana_peel_blue"

// Other
/obj/item/grown/bananapeel/specialpeel //used by /obj/item/clothing/shoes/clown_shoes/banana_shoes
	name = "synthesized banana peel"
	desc = "A synthetic banana peel."

/obj/item/grown/bananapeel/specialpeel/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/slippery, 40)
