/obj/item/clothing/neck
	name = "necklace"
	icon = 'icons/obj/clothing/neck.dmi'
	body_parts_covered = NECK
	slot_flags = ITEM_SLOT_NECK
	strip_delay = 40
	equip_delay_other = 40

/obj/item/clothing/neck/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(isinhands)
		return

	if(body_parts_covered & HEAD)
		if(damaged_clothes)
			. += mutable_appearance('icons/effects/item_damage.dmi', "damagedmask", item_layer)
		if(GET_ATOM_BLOOD_DNA_LENGTH(src))
			. += mutable_appearance('icons/effects/blood.dmi', "maskblood", item_layer)

/obj/item/clothing/neck/tie
	name = "tie"
	desc = "A neosilk clip-on tie."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bluetie"
	inhand_icon_state = ""	//no inhands
	worn_icon = 'icons/mob/clothing/neck.dmi'
	worn_icon_state = "bluetie"
	w_class = WEIGHT_CLASS_SMALL
	slot_flags = ITEM_SLOT_NECK
	custom_price = 15

/obj/item/clothing/neck/tie/examine(mob/user)
	. = ..()
	if (slot_flags & ITEM_SLOT_NECK)
		. += span_notice("Alt-click the tie to loosen it, to fit around your head.")
	else
		. += span_notice("Alt-click the tie to tighten it, to fit around your neck.")

/obj/item/clothing/neck/tie/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		var/matrix/widen = matrix()
		if(!user.is_holding(src))
			if(C.get_item_by_slot(ITEM_SLOT_HEAD) == src)
				to_chat(user, span_warning("You must be holding [src] in order to loosen it!"))
			if(C.get_item_by_slot(ITEM_SLOT_NECK) == src)
				to_chat(user, span_warning("You must be holding [src] in order to tighten it!"))
			return
		if((C.get_item_by_slot(ITEM_SLOT_HEAD) == src) || (C.get_item_by_slot(ITEM_SLOT_NECK) == src))
			to_chat(user, span_warning("You can't adjust [src] while wearing it!"))
			return
		if(slot_flags & ITEM_SLOT_NECK)
			slot_flags = ITEM_SLOT_HEAD
			worn_icon_state += "_head"
			widen.Scale(1.25, 1)
			transform = widen
			user.visible_message(span_notice("[user] loosens [src]'s knot."), span_notice("You loosen [src]'s knot to fit around your head."))
		else
			slot_flags = initial(slot_flags)
			worn_icon_state = initial(worn_icon_state)
			transform = initial(transform)
			user.visible_message(span_notice("[user] tightnens [src]'s knot."), span_notice("You tighten [src]'s knot to fit around your neck."))

/obj/item/clothing/neck/tie/blue
	name = "blue tie"
	icon_state = "bluetie"
	worn_icon_state = "bluetie"

/obj/item/clothing/neck/tie/red
	name = "red tie"
	icon_state = "redtie"
	worn_icon_state = "redtie"

/obj/item/clothing/neck/tie/black
	name = "black tie"
	icon_state = "blacktie"
	worn_icon_state = "blacktie"

/obj/item/clothing/neck/tie/horrible
	name = "horrible tie"
	desc = "A neosilk clip-on tie. This one is disgusting."
	icon_state = "horribletie"
	worn_icon_state = "horribletie"

/obj/item/clothing/neck/tie/detective
	name = "loose tie"
	desc = "A loosely tied necktie, a perfect accessory for the over-worked detective."
	icon_state = "detective"
	worn_icon_state = "detective"

/obj/item/clothing/neck/maid
	name = "maid neck cover"
	desc = "A neckpiece for a maid costume, it smells faintly of disappointment."
	icon_state = "maid_neck"

/obj/item/clothing/neck/stethoscope
	name = "stethoscope"
	desc = "An outdated medical apparatus for listening to the sounds of the human body. It also makes you look like you know what you're doing."
	icon_state = "stethoscope"

/obj/item/clothing/neck/stethoscope/suicide_act(mob/living/carbon/user)
	user.visible_message(span_suicide("[user] puts \the [src] to [user.p_their()] chest! It looks like [user.p_they()] wont hear much!"))
	return OXYLOSS

/obj/item/clothing/neck/stethoscope/attack(mob/living/carbon/human/M, mob/living/user)
	if(ishuman(M) && isliving(user))
		if(!user.combat_mode)
			var/heart_strength = span_danger("no")
			var/lung_strength = span_danger("no")

			var/obj/item/organ/heart/heart = M.get_organ_slot(ORGAN_SLOT_HEART)
			var/obj/item/organ/lungs/lungs = M.get_organ_slot(ORGAN_SLOT_LUNGS)

			if(!(M.stat == DEAD || (HAS_TRAIT(M, TRAIT_FAKEDEATH))))
				if(heart && istype(heart))
					heart_strength = span_danger("an unstable")
					if(heart.beating)
						heart_strength = "a healthy"
				if(lungs && istype(lungs))
					lung_strength = span_danger("strained")
					if(!(M.failed_last_breath || M.losebreath))
						lung_strength = "healthy"

			if(M.stat == DEAD && heart && world.time - M.timeofdeath < DEFIB_TIME_LIMIT * 10)
				heart_strength = span_boldannounce("a faint, fluttery")

			var/diagnosis = (user.is_zone_selected(BODY_ZONE_CHEST) ? "You hear [heart_strength] pulse and [lung_strength] respiration." : "You faintly hear [heart_strength] pulse.")
			var/bodypart = parse_zone(user.is_zone_selected(BODY_ZONE_CHEST) ? BODY_ZONE_CHEST : user.get_combat_bodyzone(M))
			user.visible_message("[user] places [src] against [M]'s [bodypart] and listens attentively.", span_notice("You place [src] against [M]'s [bodypart]. [diagnosis]"))
			return
	return ..(M,user)

///////////
//SCARVES//
///////////

/obj/item/clothing/neck/scarf //Default white color, same functionality as beanies.
	name = "white scarf"
	icon_state = "scarf"
	icon_preview = 'icons/obj/previews.dmi'
	icon_state_preview = "scarf_cloth"
	desc = "A stylish scarf. The perfect winter accessory for those with a keen fashion sense, and those who just can't handle a cold breeze on their necks."
	dog_fashion = /datum/dog_fashion/head
	custom_price = 10

/obj/item/clothing/neck/scarf/black
	name = "black scarf"
	icon_state = "scarf"
	color = "#4A4A4B" //Grey but it looks black

/obj/item/clothing/neck/scarf/pink
	name = "pink scarf"
	icon_state = "scarf"
	color = "#F699CD" //Pink

/obj/item/clothing/neck/scarf/red
	name = "red scarf"
	icon_state = "scarf"
	color = "#D91414" //Red

/obj/item/clothing/neck/scarf/green
	name = "green scarf"
	icon_state = "scarf"
	color = "#5C9E54" //Green

/obj/item/clothing/neck/scarf/darkblue
	name = "dark blue scarf"
	icon_state = "scarf"
	color = "#1E85BC" //Blue

/obj/item/clothing/neck/scarf/purple
	name = "purple scarf"
	icon_state = "scarf"
	color = "#9557C5" //Purple

/obj/item/clothing/neck/scarf/yellow
	name = "yellow scarf"
	icon_state = "scarf"
	color = "#E0C14F" //Yellow

/obj/item/clothing/neck/scarf/orange
	name = "orange scarf"
	icon_state = "scarf"
	color = "#C67A4B" //Orange

/obj/item/clothing/neck/scarf/cyan
	name = "cyan scarf"
	icon_state = "scarf"
	color = "#54A3CE" //Cyan


//Striped scarves get their own icons

/obj/item/clothing/neck/scarf/zebra
	name = "zebra scarf"
	icon_state = "zebrascarf"

/obj/item/clothing/neck/scarf/christmas
	name = "christmas scarf"
	icon_state = "christmasscarf"

//The three following scarves don't have the scarf subtype
//This is because Ian can equip anything from that subtype
//However, these 3 don't have corgi versions of their sprites
/obj/item/clothing/neck/stripedredscarf
	name = "striped red scarf"
	icon_state = "stripedredscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedgreenscarf
	name = "striped green scarf"
	icon_state = "stripedgreenscarf"
	custom_price = 10

/obj/item/clothing/neck/stripedbluescarf
	name = "striped blue scarf"
	icon_state = "stripedbluescarf"
	custom_price = 10

/obj/item/clothing/neck/petcollar  // adding an OOC restriction to an IC action, like wearing a collar, is gay.
	name = "pet collar"
	desc = "It's for pets. You probably shouldn't wear it yourself unless you want to be ridiculed."
	icon_state = "petcollar"
	var/tagname = null

/obj/item/clothing/neck/petcollar/attack_self(mob/user)
	tagname = stripped_input(user, "Would you like to change the name on the tag?", "Name your new pet", "Spot", MAX_NAME_LEN)
	name = "[initial(name)] - [tagname]"

//////////////
//DOPE BLING//
//////////////

/obj/item/clothing/neck/necklace/dope
	name = "dope gold necklace"
	desc = "Damn, it feels good to be a gangster."
	icon = 'icons/obj/clothing/neck.dmi'
	icon_state = "bling"

/obj/item/clothing/neck/necklace/dope/cross
	name = "gold cross necklace"
	desc = "In nomine Patris, et Filii, et Spiritus Sancti."
	icon_state = "cross"

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/neck/bizzarescarf
	name = "bizzare scarf"
	desc = "Your next line is-"
	icon_state = "bizzare"

/obj/item/clothing/neck/conductivescarf
	name = "conductive scarf"
	desc = "Made out of 30,000 scarabs. Use with caution."
	icon_state = "conductive"
