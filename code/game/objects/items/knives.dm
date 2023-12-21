// Knife Template, should not appear in game normally //
/obj/item/knife
	name = "knife"
	icon = 'icons/obj/kitchen.dmi'
	icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	item_state = "knife"
	worn_icon_state = "knife"
	desc = "The original knife, it is said that all other knives are only copies of this one."
	flags_1 = CONDUCT_1
	force = 10
	w_class = WEIGHT_CLASS_SMALL
	throwforce = 10
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	custom_materials = list(/datum/material/iron=12000)
	attack_verb = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	//attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = IS_SHARP_ACCURATE
	armor = list(MELEE = 0, BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 50, ACID = 50)
	var/bayonet = FALSE //Can this be attached to a gun?
	//wound_bonus = 5
	//bare_wound_bonus = 15
	tool_behaviour = TOOL_KNIFE

/obj/item/knife/Initialize(mapload)
	. = ..()

	set_butchering()

/obj/item/knife/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.is_zone_selected(BODY_ZONE_PRECISE_EYES))
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			M = user
		return eyestab(M,user)
	else
		return ..()

///Adds the butchering component, used to override stats for special cases
/obj/item/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, 8 SECONDS - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/knife/suicide_act(mob/living/user)
	user.visible_message(pick("<span class='suicide'>[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide.</span>", \
						"<span class='suicide'>[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.</span>"))
	return BRUTELOSS

/obj/item/knife/ritual
	name = "ritual knife"
	desc = "The unearthly energies that once powered this blade are now dormant."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/knife/butcher
	name = "butcher's cleaver"
	icon_state = "butch"
	item_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	custom_materials = list(/datum/material/iron=18000)
	attack_verb = list("cleaved", "slashed", "stabbed", "sliced", "tore", "ripped", "diced", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = 60

/obj/item/knife/hunting
	name = "hunting knife"
	desc = "Despite its name, it's mainly used for cutting meat from dead prey rather than actual hunting."
	item_state = "huntingknife"
	icon_state = "huntingknife"
	force = 12

/obj/item/knife/poison
	name = "venom knife"
	icon_state = "poisonknife"
	force = 12
	throwforce = 15
	throw_speed = 5
	throw_range = 7
	var/amount_per_transfer_from_this = 10
	var/list/possible_transfer_amounts
	desc = "An infamous knife of syndicate design, it has a tiny hole going through the blade to the handle which stores toxins."
	custom_materials = null

/obj/item/knife/poison/Initialize(mapload)
	. = ..()
	create_reagents(40,OPENCONTAINER)
	possible_transfer_amounts = list(5, 10)

/obj/item/knife/poison/attack_self(mob/user)
	if(possible_transfer_amounts.len)
		var/i=0
		for(var/A in possible_transfer_amounts)
			i++
			if(A == amount_per_transfer_from_this)
				if(i<possible_transfer_amounts.len)
					amount_per_transfer_from_this = possible_transfer_amounts[i+1]
				else
					amount_per_transfer_from_this = possible_transfer_amounts[1]
				balloon_alert(user, "Transferring [amount_per_transfer_from_this]u.")
				to_chat(user, "<span class='notice'>[src]'s transfer amount is now [amount_per_transfer_from_this] units.</span>")
				return

/obj/item/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE, "armour_block" = 60)
	force = 20
	throwforce = 20
	attack_verb = list("slashed", "stabbed", "sliced", "tore", "ripped", "cut")
	bayonet = TRUE

/obj/item/knife/combat/survival
	name = "survival knife"
	icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10, "armour_block" = 40)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/knife/combat/bone
	name = "bone dagger"
	item_state = "bone_dagger"
	icon_state = "bone_dagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "A sharpened bone. The bare minimum in survival."
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10, "armour_block" = 40)
	force = 15
	throwforce = 15
	custom_materials = null

/obj/item/knife/combat/cyborg
	name = "cyborg knife"
	icon = 'icons/obj/items_cyborg.dmi'
	icon_state = "knife_cyborg"
	desc = "A cyborg-mounted plasteel knife. Extremely sharp and durable."

/obj/item/knife/carrotshiv
	name = "carrot shiv"
	icon_state = "carrotshiv"
	item_state = "carrotshiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	force = 8
	throwforce = 12//fuck git
	custom_materials = list()
	attack_verb = list("shanked", "shivved")
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)

// Shank - Makeshift weapon that can embed on throw
/obj/item/knife/shank
	name = "Shank"
	desc = "A crude knife fashioned by wrapping some cable around a glass shard. It looks like it could be thrown with some force.. and stick. Good to throw at someone chasing you"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "shank"
	item_state = "shank"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 8 // 3 more than base glass shard
	throwforce = 8
	throw_speed = 5 //yeets
	armour_penetration = 10 //spear has 10 armour pen, I think its fitting another glass tipped item should have it too
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 40, "embedded_fall_chance" = 5, "armour_block" = 30) // Incentive to disengage/stop chasing when stuck
	attack_verb = list("stuck", "shanked")

/obj/item/knife/shank/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shank! It looks like [user.p_theyre()] trying to commit suicide.</span>")
	return BRUTELOSS
