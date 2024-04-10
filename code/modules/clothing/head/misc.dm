

/obj/item/clothing/head/that
	name = "top-hat"
	desc = "It's an amish looking hat."
	icon_state = "tophat"
	item_state = "that"
	dog_fashion = /datum/dog_fashion/head
	throwforce = 1

/obj/item/clothing/head/fedora
	name = "fedora"
	icon_state = "fedora"
	item_state = "fedora"
	desc = "A really cool hat if you're a mobster. A really lame hat if you're not."
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small

/obj/item/clothing/head/fedora/suicide_act(mob/living/user)
	if(user.gender == FEMALE)
		return
	var/mob/living/carbon/human/H = user
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like [user.p_theyre()] trying to be nice to girls.</span>")
	user.say("M'lady.", forced = "fedora suicide")
	sleep(10)
	H.facial_hair_style = "Neckbeard"
	return BRUTELOSS

/obj/item/clothing/head/sombrero
	name = "sombrero"
	icon_state = "sombrero"
	item_state = "sombrero"
	desc = "You can practically taste the fiesta."
	flags_inv = HIDEHAIR

	dog_fashion = /datum/dog_fashion/head/sombrero

/obj/item/clothing/head/sombrero/green
	name = "green sombrero"
	icon_state = "greensombrero"
	item_state = "greensombrero"
	desc = "As elegant as a dancing cactus."
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero
	name = "shamebrero"
	icon_state = "shamebrero"
	item_state = "shamebrero"
	desc = "Once it's on, it never comes off."
	dog_fashion = null

/obj/item/clothing/head/sombrero/shamebrero/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, SHAMEBRERO_TRAIT)

/obj/item/clothing/head/cone
	desc = "This cone is trying to warn you of something!"
	name = "warning cone"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "cone"
	item_state = "cone"
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb = list("warned", "cautioned", "smashed")
	resistance_flags = NONE
	dynamic_hair_suffix = ""

/obj/item/clothing/head/papersack
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes. Useful for hiding one's identity or ugliness."
	icon_state = "papersack"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT
	clothing_flags = SNUG_FIT

/obj/item/clothing/head/papersack/smiley
	name = "paper sack hat"
	desc = "A paper sack with crude holes cut out for eyes and a sketchy smile drawn on the front. Not creepy at all."
	icon_state = "papersack_smile"
	flags_inv = HIDEHAIR|HIDEFACE|HIDEEARS|HIDESNOUT

/obj/item/clothing/head/crown
	name = "crown"
	desc = "A crown fit for a king, a petty king maybe."
	icon_state = "crown"
	armor = list(MELEE = 15,  BULLET = 0, LASER = 0, ENERGY = 15, BOMB = 0, BIO = 0, RAD = 0, FIRE = 100, ACID = 50, STAMINA = 40)
	resistance_flags = FIRE_PROOF
	dynamic_hair_suffix = ""

/obj/item/clothing/head/crown/fancy
	name = "magnificent crown"
	desc = "A crown worn by only the highest emperors of the <s>land</s> space."
	icon_state = "fancycrown"

/obj/item/clothing/head/frenchberet
	name = "french beret"
	desc = "A quality beret, infused with the aroma of chain-smoking, wine-swilling Parisians. You feel less inclined to engage military conflict, for some reason."
	icon_state = "beret"
	dynamic_hair_suffix = ""
	dying_key = DYE_REGISTRY_BERET

/obj/item/clothing/head/frenchberet/equipped(mob/M, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/dropped(mob/M)
	. = ..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/frenchberet/proc/handle_speech(datum/source, mob/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		message = " [message]"
		var/list/french_words = strings(FRENCH_TALK_FILE, "french")

		for(var/key in french_words)
			var/value = french_words[key]
			if(islist(value))
				value = pick(value)

			message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
			message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
			message = replacetextEx(message, " [key]", " [value]")

		if(prob(3))
			message += pick(" Honh honh honh!"," Honh!"," Zut Alors!")
	speech_args[SPEECH_MESSAGE] = trim(message)

/obj/item/clothing/head/flowercrown
	name = "generic flower crown"
	desc = "You should not be seeing this"
	icon_state = "lily_crown"
	dynamic_hair_suffix = ""
	attack_verb = list("crowned")

/obj/item/clothing/head/flowercrown/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_HEAD)
		SEND_SIGNAL(user, COMSIG_ADD_MOOD_EVENT, "flower_crown_worn", /datum/mood_event/flower_crown_worn, src)

/obj/item/clothing/head/flowercrown/dropped(mob/living/carbon/user)
	..()
	if(user.head != src)
		return
	else
		SEND_SIGNAL(user, COMSIG_CLEAR_MOOD_EVENT, "flower_crown_worn")

/obj/item/clothing/head/flowercrown/rainbowbunch
	name = "rainbow flower crown"
	desc = "A flower crown made out of the flowers of the rainbow bunch plant."
	icon_state_preview = "rainbow_bunch_crown_1"

/obj/item/clothing/head/flowercrown/rainbowbunch/Initialize(mapload)
	. = ..()
	var/crown_type = rand(1,4)
	switch(crown_type)
		if(1)
			desc += " This one has red, yellow and white flowers."
			icon_state = "rainbow_bunch_crown_1"
		if(2)
			desc += " This one has blue, yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_2"
		if(3)
			desc += " This one has red, blue, purple and pink flowers."
			icon_state = "rainbow_bunch_crown_3"
		if(4)
			desc += " This one has yellow, green and white flowers."
			icon_state = "rainbow_bunch_crown_4"

/obj/item/clothing/head/flowercrown/sunflower
	name = "sunflower crown"
	desc = "A bright flower crown made out sunflowers that is sure to brighten up anyone's day!"
	icon_state = "sunflower_crown"

/obj/item/clothing/head/flowercrown/poppy
	name = "poppy crown"
	desc = "A flower crown made out of a string of bright red poppies."
	icon_state = "poppy_crown"

/obj/item/clothing/head/flowercrown/lily
	name = "lily crown"
	desc = "A leafy flower crown with a cluster of large white lilies at at the front."
	icon_state = "lily_crown"

/obj/item/clothing/head/cowboy
	name = "ranching hat"
	desc = "King of the plains, the half cow half man mutant, the cowboy."
	icon_state = "cowboy_alt"

/obj/item/clothing/head/cowboy_science
	name = "slime ranching hat"
	desc = "King of the labs, the half slime half man mutant, the slimeboy."
	icon_state = "cowboy_alt_science"

/////////////////
//DONATOR ITEMS//
/////////////////

/obj/item/clothing/head/gangsterwig
	name = "gangstar wig"
	desc = "Like father like son."
	icon_state = "gangster_wig"
	flags_inv = HIDEHAIR

/obj/item/clothing/head/oldhat
	name = "old man hat"
	desc = "OH MY GOD."
	icon_state = "oldmanhat"

/obj/item/clothing/head/marine
	name = "mariner hat"
	desc = "There's nothing quite like the ocean breeze in the morning."
	icon_state = "marine"

/obj/item/clothing/head/costume/chicken_head_retro
	name = "chicken head"
	desc = "Looks just like a real one."
	icon_state = "chicken"
	flags_inv = HIDEHAIR
