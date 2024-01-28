/* Kitchen tools
 * Contains:
 *		Fork
 *		Kitchen knives
 *		Ritual Knife
 *		Butcher's cleaver
 *		Combat Knife
 *		Rolling Pins
 *      Poison Knife
 */

/obj/item/kitchen
	icon = 'icons/obj/kitchen.dmi'
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	item_flags = ISWEAPON

/obj/item/kitchen/fork
	name = "fork"
	desc = "Pointy."
	icon_state = "fork"
	force = 5
	w_class = WEIGHT_CLASS_TINY
	throwforce = 0
	throw_speed = 3
	throw_range = 5
	custom_materials = list(/datum/material/iron=80)
	flags_1 = CONDUCT_1
	attack_verb = list("attacked", "stabbed", "poked")
	hitsound = 'sound/weapons/bladeslice.ogg'
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 30, STAMINA = 0)
	var/datum/reagent/forkload //used to eat omelette

/obj/item/kitchen/fork/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] stabs \the [src] into [user.p_their()] chest! It looks like [user.p_theyre()] trying to take a bite out of [user.p_them()]self!</span>")
	playsound(src, 'sound/items/eatfood.ogg', 50, 1)
	return BRUTELOSS

/obj/item/kitchen/fork/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(!istype(M))
		return ..()

	if(forkload)
		if(M == user)
			M.visible_message("<span class='notice'>[user] eats a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.type, 1)
		else
			M.visible_message("<span class='notice'>[user] feeds [M] a delicious forkful of omelette!</span>")
			M.reagents.add_reagent(forkload.type, 1)
		icon_state = "fork"
		forkload = null

	else if(user.is_zone_selected(BODY_ZONE_PRECISE_EYES, simplified_probability = 30))
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()

/obj/item/knife/poison/attack(mob/living/M, mob/user)
	if (!istype(M))
		return
	. = ..()
	if (!reagents.total_volume || !M.reagents)
		return
	var/amount_inject = amount_per_transfer_from_this
	if(!M.can_inject(user, 1))
		amount_inject = 1
	var/amount = min(amount_inject/reagents.total_volume,1)
	reagents.reaction(M,INJECT,amount)
	reagents.trans_to(M,amount_inject)

/obj/item/knife/kitchen
	name = "kitchen knife"
	desc = "A general purpose Chef's Knife made by SpaceCook Incorporated. Guaranteed to stay sharp for years to come."

/obj/item/kitchen/rollingpin
	name = "rolling pin"
	desc = "Used to knock out the Bartender."
	icon_state = "rolling_pin"
	force = 8
	throwforce = 5
	throw_speed = 3
	throw_range = 7
	w_class = WEIGHT_CLASS_NORMAL
	attack_verb = list("bashed", "battered", "bludgeoned", "thrashed", "whacked")
	custom_price = 20
	tool_behaviour = TOOL_ROLLINGPIN

/obj/item/kitchen/rollingpin/suicide_act(mob/living/carbon/user)
	user.visible_message("<span class='suicide'>[user] begins flattening [user.p_their()] head with \the [src]! It looks like [user.p_theyre()] trying to commit suicide!</span>")
	return BRUTELOSS
