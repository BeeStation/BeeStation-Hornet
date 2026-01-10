// Knife Template, should not appear in game normally //
/obj/item/knife
	name = "knife"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	inhand_icon_state = "knife"
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
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	sharpness = SHARP
	bleed_force = BLEED_CUT
	armor_type = /datum/armor/item_knife
	custom_price = 50 // Adding this here because some knives were not covered by the export datum
	var/bayonet = FALSE //Can this be attached to a gun?
	//wound_bonus = 5
	//bare_wound_bonus = 15
	tool_behaviour = TOOL_KNIFE

	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY
	block_power = 0

/datum/armor/item_knife
	fire = 50
	acid = 50

/obj/item/knife/Initialize(mapload)
	. = ..()

	set_butchering()

/obj/item/knife/attack(mob/living/carbon/M, mob/living/carbon/user)
	if(user.is_zone_selected(BODY_ZONE_PRECISE_EYES, precise_only = TRUE) || user.is_zone_selected(BODY_GROUP_CHEST_HEAD))
		if(HAS_TRAIT(user, TRAIT_CLUMSY) && prob(50))
			M = user
		if (eyestab(M, user, src, silent = user.is_zone_selected(BODY_GROUP_CHEST_HEAD)))
			return TRUE
	return ..()

///Adds the butchering component, used to override stats for special cases
/obj/item/knife/proc/set_butchering()
	AddComponent(/datum/component/butchering, 8 SECONDS - force, 100, force - 10) //bonus chance increases depending on force

/obj/item/knife/suicide_act(mob/living/user)
	user.visible_message(pick(span_suicide("[user] is slitting [user.p_their()] wrists with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] throat with the [src.name]! It looks like [user.p_theyre()] trying to commit suicide."), \
						span_suicide("[user] is slitting [user.p_their()] stomach open with the [src.name]! It looks like [user.p_theyre()] trying to commit seppuku.")))
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
	inhand_icon_state = "butch"
	desc = "A huge thing used for chopping and chopping up meat. This includes clowns and clown by-products."
	flags_1 = CONDUCT_1
	force = 15
	throwforce = 10
	custom_materials = list(/datum/material/iron=18000)
	attack_verb_continuous = list("cleaves", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("cleave", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	w_class = WEIGHT_CLASS_NORMAL
	custom_price = 60
	sharpness = SHARP_DISMEMBER //This is a big boy knife

/obj/item/knife/hunting
	name = "hunting knife"
	desc = "Despite its name, it's mainly used for cutting meat from dead prey rather than actual hunting."
	inhand_icon_state = "huntingknife"
	icon_state = "huntingknife"
	icon = 'icons/obj/knives.dmi'
	force = 12

/obj/item/knife/venom
	name = "venom knife"
	icon_state = "poisonknife"
	icon = 'icons/obj/knives.dmi'
	force = 20
	throwforce = 20
	throw_speed = 5
	throw_range = 7
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "cut")
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE, "armour_block" = 60)
	var/amount_per_transfer_from_this = 10
	var/list/possible_transfer_amounts
	desc = "An infamous knife of syndicate design, it has a tiny hole going through the blade to the handle which stores toxins."
	custom_materials = null

/obj/item/knife/venom/embedded(atom/target)
	. = ..()
	if(!reagents.total_volume)
		return

	if(isliving(target))
		var/mob/living/M = target
		if(!M.reagents)
			return

		//If they were willing to throw the knife on a base 65% embed chance, give their target the entire payload
		reagents.expose(M, INJECT, reagents.total_volume)
		reagents.trans_to(M, reagents.total_volume)

/obj/item/knife/venom/attack(mob/living/M, mob/user)
	. = ..()
	if (!istype(M))
		return
	if (!reagents.total_volume || !M.reagents)
		return
	//Get our preferred transfer amount
	var/amount_to_inject = amount_per_transfer_from_this

	//If the target is protected from injections, we will still inject anyway because it's a knife not a syringe, but a reduced amount.
	if(!M.can_inject(user, user.get_combat_bodyzone(), INJECT_CHECK_PENETRATE_THICK))
		amount_to_inject = amount_to_inject / 3

	//Finally we need to make sure we actually have whatever our injection amount is left in the knife, and if not we use whatever is left
	amount_to_inject = min(reagents.total_volume, amount_to_inject)
	reagents.expose(M, INJECT, amount_to_inject)
	reagents.trans_to(M, amount_to_inject)

/obj/item/knife/venom/Initialize(mapload)
	. = ..()
	create_reagents(40,OPENCONTAINER)
	possible_transfer_amounts = list(5, 10)

/obj/item/knife/venom/attack_self(mob/user)
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
				to_chat(user, span_notice("[src]'s transfer amount is now [amount_per_transfer_from_this] units."))
				return

/obj/item/knife/combat
	name = "combat knife"
	icon_state = "buckknife"
	icon = 'icons/obj/knives.dmi'
	desc = "A military combat utility survival knife."
	embedding = list("pain_mult" = 4, "embed_chance" = 65, "fall_chance" = 10, "ignore_throwspeed_threshold" = TRUE, "armour_block" = 60)
	force = 20
	throwforce = 20
	attack_verb_continuous = list("slashes", "stabs", "slices", "tears", "lacerates", "rips", "cuts")
	attack_verb_simple = list("slash", "stab", "slice", "tear", "lacerate", "rip", "cut")
	bayonet = TRUE
	custom_price = 100

/obj/item/knife/combat/survival
	name = "survival knife"
	icon = 'icons/obj/knives.dmi'
	icon_state = "survivalknife"
	embedding = list("pain_mult" = 4, "embed_chance" = 35, "fall_chance" = 10, "armour_block" = 40)
	desc = "A hunting grade survival knife."
	force = 15
	throwforce = 15
	bayonet = TRUE

/obj/item/knife/combat/bone
	name = "bone dagger"
	inhand_icon_state = "bone_dagger"
	icon_state = "bone_dagger"
	icon = 'icons/obj/knives.dmi'
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

/obj/item/knife/shiv
	name = "glass shiv"
	desc = "A crude knife fashioned by wrapping some cable around a glass shard. It looks like it could be thrown with some force.. and stick. Good to throw at someone chasing you"
	icon = 'icons/obj/knives.dmi'
	icon_state = "shank"
	inhand_icon_state = "shank"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	force = 8 // 3 more than base glass shard
	throwforce = 8
	throw_speed = 5 //yeets
	armour_penetration = 10 //spear has 10 armour pen, I think its fitting another glass tipped item should have it too
	embedding = list("embedded_pain_multiplier" = 6, "embed_chance" = 40, "embedded_fall_chance" = 5, "armour_block" = 30) // Incentive to disengage/stop chasing when stuck
	attack_verb_continuous = list("sticks", "shanks")
	attack_verb_simple = list("stuck", "shank")
	custom_materials = list(/datum/material/glass=400)

/obj/item/knife/shiv/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is slitting [user.p_their()] [pick("wrists", "throat")] with the shank! It looks like [user.p_theyre()] trying to commit suicide."))
	return BRUTELOSS

/obj/item/knife/shiv/carrot
	name = "carrot shiv"
	icon_state = "carrotshiv"
	inhand_icon_state = "carrotshiv"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	desc = "Unlike other carrots, you should probably keep this far away from your eyes."
	force = 8
	throwforce = 12//fuck git
	custom_materials = list()
	attack_verb_continuous = list("shanks", "shivs")
	attack_verb_simple = list("shank", "shiv")
	armor_type = /datum/armor/none
