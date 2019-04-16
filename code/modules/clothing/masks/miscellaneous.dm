/obj/item/clothing/mask/muzzle
	name = "muzzle"
	desc = "To stop that awful noise."
	icon_state = "muzzle"
	item_state = "blindfold"
	flags_cover = MASKCOVERSMOUTH
	w_class = WEIGHT_CLASS_SMALL
	gas_transfer_coefficient = 0.9
	equip_delay_other = 20

/obj/item/clothing/mask/muzzle/attack_paw(mob/user)
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if(src == C.wear_mask)
			to_chat(user, "<span class='warning'>You need help taking this off!</span>")
			return
	..()

/obj/item/clothing/mask/surgical
	name = "sterile mask"
	desc = "A sterile mask designed to help prevent the spread of diseases."
	icon_state = "sterile"
	item_state = "sterile"
	w_class = WEIGHT_CLASS_TINY
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH
	visor_flags_inv = HIDEFACE
	visor_flags_cover = MASKCOVERSMOUTH
	gas_transfer_coefficient = 0.9
	permeability_coefficient = 0.01
	armor = list("melee" = 0, "bullet" = 0, "laser" = 0,"energy" = 0, "bomb" = 0, "bio" = 25, "rad" = 0, "fire" = 0, "acid" = 0)
	actions_types = list(/datum/action/item_action/adjust)

/obj/item/clothing/mask/surgical/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/fakemoustache
	name = "fake moustache"
	desc = "Warning: moustache is fake."
	icon_state = "fake-moustache"
	flags_inv = HIDEFACE

/obj/item/clothing/mask/fakemoustache/italian
	name = "italian moustache"
	desc = "Made from authentic Italian moustache hairs. Gives the wearer an irresistable urge to gesticulate wildly."

/obj/item/clothing/mask/fakemoustache/italian/speechModification(M)
	if(copytext(M, 1, 2) != "*")
		M = " [M]"
		var/list/italian_words = strings("italian_replacement.json", "italian")

		for(var/key in italian_words)
			var/value = italian_words[key]
			if(islist(value))
				value = pick(value)

			M = replacetextEx(M, " [uppertext(key)]", " [uppertext(value)]")
			M = replacetextEx(M, " [capitalize(key)]", " [capitalize(value)]")
			M = replacetextEx(M, " [key]", " [value]")

		if(prob(3))
			M += pick(" Ravioli, ravioli, give me the formuoli!"," Mamma-mia!"," Mamma-mia! That's a spicy meat-ball!", " La la la la la funiculi funicula!")
	return trim(M)

/obj/item/clothing/mask/joy
	name = "joy mask"
	desc = "Express your happiness or hide your sorrows with this laughing face with crying tears of joy cutout."
	icon_state = "joy"

/obj/item/clothing/mask/pig
	name = "pig mask"
	desc = "A rubber pig mask with a builtin voice modulator."
	icon_state = "pig"
	item_state = "pig"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = VOICEBOX_TOGGLABLE
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/pig/speechModification(message)
	. = message
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		. = pick("Oink!","Squeeeeeeee!","Oink Oink!")

/obj/item/clothing/mask/pig/cursed
	name = "pig face"
	desc = "It looks like a mask, but closer inspection reveals it's melded onto this persons face!"
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/pig/cursed/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/pighead_curse.ogg', 50, 1)

///frog mask - reeee!!
/obj/item/clothing/mask/frog
	name = "frog mask"
	desc = "An ancient mask carved in the shape of a frog.<br> Sanity is like gravity, all it needs is a push."
	icon_state = "frog"
	item_state = "frog"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE

/obj/item/clothing/mask/frog/speechModification(message) //whenever you speak
	. = message
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		if(prob(5)) //sometimes, the angry spirit finds others words to speak.
			. = pick("HUUUUU!!","SMOOOOOKIN'!!","Hello my baby, hello my honey, hello my rag-time gal.", "Feels bad, man.", "GIT DIS GUY OFF ME!!" ,"SOMEBODY STOP ME!!", "NORMIES, GET OUT!!")
		else
			. = pick("Ree!!", "Reee!!","REEE!!","REEEEE!!") //but its usually just angry gibberish,

/obj/item/clothing/mask/frog/cursed
	clothing_flags = NONE

/obj/item/clothing/mask/frog/cursed/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP, CURSED_MASK_TRAIT)

/obj/item/clothing/mask/frog/cursed/equipped(mob/user, slot)
	var/mob/living/carbon/C = user
	if(C.wear_mask == src && has_trait(TRAIT_NODROP, CURSED_MASK_TRAIT))
		to_chat(user, "<span class='userdanger'>[src] was cursed! Ree!!</span>")
	return ..()

/obj/item/clothing/mask/cowmask
	name = "cow mask"
	icon = 'icons/mob/mask.dmi'
	icon_state = "cowmask"
	item_state = "cowmask"
	clothing_flags = VOICEBOX_TOGGLABLE
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/cowmask/speechModification(message)
	. = message
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		. = pick("Moooooooo!","Moo!","Moooo!")

/obj/item/clothing/mask/cowmask/cursed
	name = "cow face"
	desc = "It looks like a cow mask, but closer inspection reveals it's melded onto this persons face!"
	flags_inv = HIDEFACIALHAIR
	clothing_flags = NONE

/obj/item/clothing/mask/cowmask/cursed/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/cowhead_curse.ogg', 50, 1)

/obj/item/clothing/mask/horsehead
	name = "horse head mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a horse."
	icon_state = "horsehead"
	item_state = "horsehead"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR|HIDEEYES|HIDEEARS
	w_class = WEIGHT_CLASS_SMALL
	clothing_flags = VOICEBOX_TOGGLABLE

/obj/item/clothing/mask/horsehead/speechModification(message)
	. = message
	if(!CHECK_BITFIELD(clothing_flags, VOICEBOX_DISABLED))
		. = pick("NEEIIGGGHHHH!", "NEEEIIIIGHH!", "NEIIIGGHH!", "HAAWWWWW!", "HAAAWWW!")

/obj/item/clothing/mask/horsehead/cursed
	name = "horse face"
	desc = "It initially looks like a mask, but it's melded into the poor person's face."
	clothing_flags = NONE
	flags_inv = HIDEFACIALHAIR

/obj/item/clothing/mask/horsehead/cursed/Initialize()
	. = ..()
	add_trait(TRAIT_NODROP, CURSED_MASK_TRAIT)
	playsound(get_turf(src), 'sound/magic/horsehead_curse.ogg', 50, 1)

/obj/item/clothing/mask/rat
	name = "rat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a rat."
	icon_state = "rat"
	item_state = "rat"
	flags_inv = HIDEFACE
	flags_cover = MASKCOVERSMOUTH

/obj/item/clothing/mask/rat/fox
	name = "fox mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a fox."
	icon_state = "fox"
	item_state = "fox"

/obj/item/clothing/mask/rat/bee
	name = "bee mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bee."
	icon_state = "bee"
	item_state = "bee"

/obj/item/clothing/mask/rat/bear
	name = "bear mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bear."
	icon_state = "bear"
	item_state = "bear"

/obj/item/clothing/mask/rat/bat
	name = "bat mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a bat."
	icon_state = "bat"
	item_state = "bat"

/obj/item/clothing/mask/rat/raven
	name = "raven mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a raven."
	icon_state = "raven"
	item_state = "raven"

/obj/item/clothing/mask/rat/jackal
	name = "jackal mask"
	desc = "A mask made of soft vinyl and latex, representing the head of a jackal."
	icon_state = "jackal"
	item_state = "jackal"

/obj/item/clothing/mask/rat/tribal
	name = "tribal mask"
	desc = "A mask carved out of wood, detailed carefully by hand."
	icon_state = "bumba"
	item_state = "bumba"

/obj/item/clothing/mask/bandana
	name = "botany bandana"
	desc = "A fine bandana with nanotech lining and a hydroponics pattern."
	w_class = WEIGHT_CLASS_TINY
	flags_cover = MASKCOVERSMOUTH
	flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_inv = HIDEFACE|HIDEFACIALHAIR
	visor_flags_cover = MASKCOVERSMOUTH
	slot_flags = ITEM_SLOT_MASK
	adjusted_flags = ITEM_SLOT_HEAD
	icon_state = "bandbotany"

/obj/item/clothing/mask/bandana/attack_self(mob/user)
	adjustmask(user)

/obj/item/clothing/mask/bandana/AltClick(mob/user)
	. = ..()
	if(iscarbon(user))
		var/mob/living/carbon/C = user
		if((C.get_item_by_slot(SLOT_HEAD == src)) || (C.get_item_by_slot(SLOT_WEAR_MASK) == src))
			to_chat(user, "<span class='warning'>You can't tie [src] while wearing it!</span>")
			return
	if(slot_flags & ITEM_SLOT_HEAD)
		to_chat(user, "<span class='warning'>You must undo [src] before you can tie it into a neckerchief!</span>")
	else
		if(user.is_holding(src))
			var/obj/item/clothing/neck/neckerchief/nk = new(src)
			nk.name = "[name] neckerchief"
			nk.desc = "[desc] It's tied up like a neckerchief."
			nk.icon_state = icon_state
			nk.sourceBandanaType = src.type
			var/currentHandIndex = user.get_held_index_of_item(src)
			user.transferItemToLoc(src, null)
			user.put_in_hand(nk, currentHandIndex)
			user.visible_message("<span class='notice'>You tie [src] up like a neckerchief.</span>", "<span class='notice'>[user] ties [src] up like a neckerchief.</span>")
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You must be holding [src] in order to tie it!")

/obj/item/clothing/mask/bandana/red
	name = "red bandana"
	desc = "A fine red bandana with nanotech lining."
	icon_state = "bandred"

/obj/item/clothing/mask/bandana/blue
	name = "blue bandana"
	desc = "A fine blue bandana with nanotech lining."
	icon_state = "bandblue"

/obj/item/clothing/mask/bandana/green
	name = "green bandana"
	desc = "A fine green bandana with nanotech lining."
	icon_state = "bandgreen"

/obj/item/clothing/mask/bandana/gold
	name = "gold bandana"
	desc = "A fine gold bandana with nanotech lining."
	icon_state = "bandgold"

/obj/item/clothing/mask/bandana/black
	name = "black bandana"
	desc = "A fine black bandana with nanotech lining."
	icon_state = "bandblack"

/obj/item/clothing/mask/bandana/skull
	name = "skull bandana"
	desc = "A fine black bandana with nanotech lining and a skull emblem."
	icon_state = "bandskull"

/obj/item/clothing/mask/bandana/durathread
	name = "durathread bandana"
	desc =  "A bandana made from durathread, you wish it would provide some protection to its wearer, but it's far too thin..."
	icon_state = "banddurathread"

/obj/item/clothing/mask/mummy
	name = "mummy mask"
	desc = "Ancient bandages."
	icon_state = "mummy_mask"
	item_state = "mummy_mask"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/mask/scarecrow
	name = "sack mask"
	desc = "A burlap sack with eyeholes."
	icon_state = "scarecrow_sack"
	item_state = "scarecrow_sack"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR

/obj/item/clothing/mask/gondola
	name = "gondola mask"
	desc = "Genuine gondola fur."
	icon_state = "gondola"
	item_state = "gondola"
	flags_inv = HIDEFACE|HIDEHAIR|HIDEFACIALHAIR
	w_class = WEIGHT_CLASS_SMALL

/obj/item/clothing/mask/gondola/speechModification(M)
	if(copytext(M, 1, 2) != "*")
		M = " [M]"
		var/list/spurdo_words = strings("spurdo_replacement.json", "spurdo")
		for(var/key in spurdo_words)
			var/value = spurdo_words[key]
			if(islist(value))
				value = pick(value)
			M = replacetextEx(M,regex(uppertext(key),"g"), "[uppertext(value)]")
			M = replacetextEx(M,regex(capitalize(key),"g"), "[capitalize(value)]")
			M = replacetextEx(M,regex(key,"g"), "[value]")
	return trim(M)
