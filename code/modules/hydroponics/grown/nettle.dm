/obj/item/seeds/nettle
	name = "pack of nettle seeds"
	desc = "These seeds grow into nettles."
	icon_state = "seed-nettle"
	species = "nettle"
	plantname = "Nettles"
	product = /obj/item/food/grown/nettle
	lifespan = 30
	endurance = 40 // tuff like a toiger
	yield = 4
	growthstages = 5
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy)
	mutatelist = list(/obj/item/seeds/nettle/death)
	reagents_add = list(/datum/reagent/toxin/acid = 0.25)

/obj/item/seeds/nettle/death
	name = "pack of death-nettle seeds"
	desc = "These seeds grow into death-nettles."
	icon_state = "seed-deathnettle"
	species = "deathnettle"
	plantname = "Death Nettles"
	product = /obj/item/food/grown/nettle/death
	endurance = 25
	maturation = 8
	yield = 2
	genes = list(/datum/plant_gene/trait/repeated_harvest, /datum/plant_gene/trait/plant_type/weed_hardy, /datum/plant_gene/trait/stinging)
	mutatelist = list()
	reagents_add = list(/datum/reagent/toxin/acid/fluacid = 0.12)
	rarity = 20

/obj/item/food/grown/nettle // "snack". yeah. try eating it, pussy
	seed = /obj/item/seeds/nettle
	name = "nettle"
	desc = "It's probably <B>not</B> wise to touch it with bare hands..."
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "nettle"
	bite_consumption_mod = 2
	lefthand_file = 'icons/mob/inhands/weapons/plants_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/plants_righthand.dmi'
	damtype = BURN
	force = 15
	hitsound = 'sound/weapons/bladeslice.ogg'
	throwforce = 5
	w_class = WEIGHT_CLASS_TINY
	throw_speed = 1
	throw_range = 3
	attack_verb_continuous = list("stings")
	attack_verb_simple = list("sting")

/obj/item/food/grown/nettle/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is eating some of [src]! It looks like [user.p_theyre()] trying to commit suicide!"))
	return (BRUTELOSS|TOXLOSS)

/obj/item/food/grown/nettle/pickup(mob/living/user)
	..()
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.gloves)
		return FALSE
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return FALSE
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, force))
			C.update_damage_overlays()
	to_chat(C, span_userdanger("The nettle burns your bare hand!"))
	return TRUE

/obj/item/food/grown/nettle/afterattack(atom/A as mob|obj, mob/user,proximity)
	. = ..()
	if(!proximity)
		return
	if(force > 0)
		force -= rand(1, (force / 3) + 1) // When you whack someone with it, leaves fall off
	else
		to_chat(usr, "All the leaves have fallen off the nettle from violent whacking.")
		qdel(src)

/obj/item/food/grown/nettle/basic
	seed = /obj/item/seeds/nettle

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/food/grown/nettle/basic)

/obj/item/food/grown/nettle/basic/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	force = round((5 + seed.potency / 5), 1)

/obj/item/food/grown/nettle/death
	seed = /obj/item/seeds/nettle/death
	name = "deathnettle"
	desc = "The " + span_danger("glowing") + " nettle incites " + span_boldannounce("rage") + " in you just from looking at it!"
	icon_state = "deathnettle"
	bite_consumption_mod = 4 // I guess if you really wanted to
	force = 25
	throwforce = 12
	discovery_points = 300

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/food/grown/nettle/death)

/obj/item/food/grown/nettle/death/Initialize(mapload, obj/item/seeds/new_seed)
	. = ..()
	force = round((5 + seed.potency / 5), 1)
	throwforce = round((2 + seed.potency / 10), 1)

/obj/item/food/grown/nettle/death/pickup(mob/living/carbon/user)
	if(..())
		if(prob(50))
			user.Paralyze(100)
			to_chat(user, span_userdanger("You are stunned by [src] as you try picking it up!"))

/obj/item/food/grown/nettle/death/attack(mob/living/M, mob/living/user)
	if(!M.can_inject(user) && user.combat_mode)
		to_chat(user, span_warning("The [src] harmlessly bounces off of [M]! They're protected from its needles!"))
		return FALSE
	else
		return ..()
