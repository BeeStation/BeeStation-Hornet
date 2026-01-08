//defines the drill hat's yelling setting
#define DRILL_DEFAULT	"default"
#define DRILL_SHOUTING	"shouting"
#define DRILL_YELLING	"yelling"
#define DRILL_CANADIAN	"canadian"

//Chef
/obj/item/clothing/head/utility/chefhat
	name = "chef's hat"
	inhand_icon_state = "chefhat"
	icon_state = "chef"
	desc = "The commander in chef's head wear."
	strip_delay = 10
	equip_delay_other = 10
	dynamic_hair_suffix = ""

	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/utility/chefhat/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is donning [src]! It looks like [user.p_theyre()] trying to become a chef."))
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(20)
	user.visible_message(span_suicide("[user] climbs into an imaginary oven!"))
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, 1)
	return(FIRELOSS)

//Captain
/obj/item/clothing/head/hats/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	inhand_icon_state = "that"
	flags_inv = 0
	armor_type = /datum/armor/hats_caphat
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain
	dying_key = DYE_REGISTRY_CAP

//Captain: This is no longer space-worthy

/datum/armor/hats_caphat
	melee = 25
	bullet = 15
	laser = 25
	energy = 30
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30
	bleed = 30

/obj/item/clothing/head/hats/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"
	dog_fashion = null

/obj/item/clothing/head/hats/caphat/beret
	name = "captain's beret"
	desc = "For the Captains known for their sense of fashion."
	icon_state = "beret_badge"
	icon = 'icons/obj/clothing/head/beret.dmi'
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#0070B7#FFCE5B"

//Head of Personnel
/obj/item/clothing/head/hats/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor_type = /datum/armor/hats_hopcap
	dog_fashion = /datum/dog_fashion/head/hop
	dying_key = DYE_REGISTRY_CAP

//Chaplain

/datum/armor/hats_hopcap
	melee = 25
	bullet = 15
	laser = 25
	energy = 30
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30
	bleed = 15

/obj/item/clothing/head/chaplain/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/chaplain/bishopmitre
	name = "bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	icon_state = "bishopmitre"

/obj/item/clothing/head/chaplain/bishopmitre/black
	icon_state = "blackbishopmitre"

//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	armor_type = /datum/armor/fedora_det_hat
	icon_state = "detective"
	inhand_icon_state = "det_hat"
	var/candy_cooldown = 0
	var/adjusted = FALSE
	var/adjustable = TRUE
	var/aura_icon_on = "detective_aura"
	dog_fashion = /datum/dog_fashion/head/detective
	actions_types = list(/datum/action/item_action/noirmode)

/datum/armor/fedora_det_hat
	melee = 25
	bullet = 5
	laser = 25
	energy = 30
	fire = 30
	acid = 50
	stamina = 25
	bleed = 20

/obj/item/clothing/head/fedora/det_hat/Initialize(mapload)
	. = ..()

	create_storage(storage_type = /datum/storage/pockets/small/fedora/detective)

	new /obj/item/reagent_containers/cup/glass/flask/det(src)

/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += span_notice("Alt-click to take a candy corn. Control-click to adjust it.")

/obj/item/clothing/head/fedora/det_hat/AltClick(mob/user)
	. = ..()
	if(loc != user || !user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, TRUE))
		return
	if(candy_cooldown < world.time)
		var/obj/item/food/candy_corn/CC = new /obj/item/food/candy_corn(src)
		user.put_in_hands(CC)
		to_chat(user, "You slip a candy corn from your hat.")
		candy_cooldown = world.time+1200
	else
		to_chat(user, "You just took a candy corn! You should wait a couple minutes, lest you burn through your stash.")

/obj/item/clothing/head/fedora/det_hat/CtrlClick(mob/user)
	..()
	if(user.canUseTopic(src, BE_CLOSE, NO_DEXTERITY, FALSE, !iscyborg(user)))
		flip(user)

/obj/item/clothing/head/fedora/det_hat/proc/flip(mob/user)
	if(!user.incapacitated() && adjustable == TRUE)
		adjusted = !adjusted
		if(adjusted)
			worn_icon_state = aura_icon_on
			to_chat(user, span_notice("You adjust your hat to look more intimidating."))
		else
			worn_icon_state = initial(worn_icon_state)
			to_chat(user, span_notice("You return your hat to its original position."))
		user.update_worn_head()

/obj/item/clothing/head/fedora/det_hat/noir
	name = "noir fedora"
	desc = "An essential accessory for the world-weary private eye."
	icon_state = "fedora"
	dog_fashion = /datum/dog_fashion/head/noir
	aura_icon_on = "fedora_aura"

//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	icon = 'icons/obj/clothing/head/beret.dmi'
	worn_icon = 'icons/mob/clothing/head/beret.dmi'
	icon_state_preview = "beret"
	dog_fashion = /datum/dog_fashion/head/beret
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#972A2A"
	flags_1 = IS_PLAYER_COLORABLE_1

/obj/item/clothing/head/beret/color
	name = "white beret"
	greyscale_colors = "#ffffff"

/obj/item/clothing/head/beret/rainbow
	name = "rainbow beret"
	icon_state = "beret_rainbow"
	icon = 'icons/obj/clothing/head/beret_unique.dmi'
	worn_icon = 'icons/mob/clothing/head/beret_unique.dmi'
	greyscale_colors = null
	flags_1 = NONE

/obj/item/clothing/head/beret/mime
	name = "invisible beret"
	desc = "Only a very scholarly mime is able to cram enough mimery into a beret for this to happen."
	icon_state = "beret_mime"
	icon = 'icons/obj/clothing/head/beret_unique.dmi'
	worn_icon = 'icons/mob/clothing/head/beret_unique.dmi'
	greyscale_colors = null
	flags_1 = NONE

/obj/item/clothing/head/beret/clown
	name = "H.O.N.K. tactical beret"
	desc = "A tactical beret to be used during the enacting of the most dangerous of pranks."
	icon_state = "beret_clown"
	icon = 'icons/obj/clothing/head/beret_unique.dmi'
	worn_icon = 'icons/mob/clothing/head/beret_unique.dmi'
	greyscale_colors = null
	flags_1 = NONE

//Security

/obj/item/clothing/head/hats/hos
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor_type = /datum/armor/hats_hos
	strip_delay = 80
	dynamic_hair_suffix = ""
	dying_key = DYE_REGISTRY_CAP


/datum/armor/hats_hos
	melee = 40
	bullet = 30
	laser = 25
	energy = 30
	bomb = 25
	bio = 10
	fire = 50
	acid = 60
	stamina = 30
	bleed = 30

/obj/item/clothing/head/hats/hos/syndicate
	name = "syndicate cap"
	desc = "A black cap fit for a high ranking syndicate officer."

/obj/item/clothing/head/hats/hos/beret
	name = "head of security's beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "beret_badge"
	icon = 'icons/obj/clothing/head/beret.dmi'
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#39393f#f0cc8f"

/obj/item/clothing/head/hats/hos/beret/navyhos
	name = "head of security's beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	greyscale_colors = "#638799#f0cc8f"

/obj/item/clothing/head/hats/hos/beret/syndicate
	name = "syndicate beret"
	desc = "A black beret with thick armor padding inside. Stylish and robust."
	dying_key = DYE_REGISTRY_CAP

/obj/item/clothing/head/hats/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor_type = /datum/armor/hats_warden
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/hats/warden/red
	name = "warden's hat"
	desc = "A warden's red hat. Looking at it gives you the feeling of wanting to keep people in cells for as long as possible."
	icon_state = "wardenhat"

/datum/armor/hats_warden
	melee = 40
	bullet = 30
	laser = 30
	energy = 30
	bomb = 25
	fire = 30
	acid = 60
	stamina = 30
	bleed = 25

/obj/item/clothing/head/hats/warden/drill
	name = "warden's campaign hat"
	desc = "A special armored campaign hat with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "wardendrill"
	inhand_icon_state = null
	dog_fashion = null
	var/mode = DRILL_DEFAULT

/obj/item/clothing/head/hats/warden/drill/screwdriver_act(mob/living/carbon/human/user, obj/item/I)
	if(..())
		return TRUE
	switch(mode)
		if(DRILL_DEFAULT)
			to_chat(user, span_notice("You set the voice circuit to the middle position."))
			mode = DRILL_SHOUTING
		if(DRILL_SHOUTING)
			to_chat(user, span_notice("You set the voice circuit to the last position."))
			mode = DRILL_YELLING
		if(DRILL_YELLING)
			to_chat(user, span_notice("You set the voice circuit to the first position."))
			mode = DRILL_DEFAULT
		if(DRILL_CANADIAN)
			to_chat(user, span_danger("You adjust voice circuit but nothing happens, probably because it's broken."))
	return TRUE

/obj/item/clothing/head/hats/warden/drill/wirecutter_act(mob/living/user, obj/item/I)
	if(mode != DRILL_CANADIAN)
		to_chat(user, span_danger("You broke the voice circuit!"))
		mode = DRILL_CANADIAN
	return TRUE

/obj/item/clothing/head/hats/warden/drill/equipped(mob/M, slot)
	. = ..()
	if (slot == ITEM_SLOT_HEAD)
		RegisterSignal(M, COMSIG_MOB_SAY, PROC_REF(handle_speech))
	else
		UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/hats/warden/drill/dropped(mob/M)
	..()
	UnregisterSignal(M, COMSIG_MOB_SAY)

/obj/item/clothing/head/hats/warden/drill/proc/handle_speech(datum/source, list/speech_args)
	SIGNAL_HANDLER

	var/message = speech_args[SPEECH_MESSAGE]
	if(message[1] != "*")
		switch(mode)
			if(DRILL_SHOUTING)
				message = replacetextEx(message, ".", "!", length(message))
			if(DRILL_YELLING)
				message = replacetextEx(message, ".", "!!", length(message))
			if(DRILL_CANADIAN)
				message = "[message]"
				var/list/canadian_words = strings(CANADIAN_TALK_FILE, "words")

				for(var/key in canadian_words)
					var/value = canadian_words[key]
					if(islist(value))
						value = pick(value)

					message = replacetextEx(message, " [uppertext(key)]", " [uppertext(value)]")
					message = replacetextEx(message, " [capitalize(key)]", " [capitalize(value)]")
					message = replacetextEx(message, " [key]", " [value]")

				if(prob(30))
					message = replacetextEx(message, ".", pick(", eh?", ", EH?"), length(message))
		speech_args[SPEECH_MESSAGE] = message

#undef DRILL_DEFAULT
#undef DRILL_SHOUTING
#undef DRILL_YELLING
#undef DRILL_CANADIAN

/obj/item/clothing/head/beret/corpwarden
	name = "corporate warden beret"
	desc = "A special black beret with the Warden's insignia in the middle. This one is commonly worn by wardens of the corporation."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#3f3c40#ACACAC"
	armor_type = /datum/armor/beret_corpwarden
	flags_1 = NONE

/datum/armor/beret_corpwarden
	melee = 40
	bullet = 30
	laser = 30
	energy = 30
	bomb = 25
	fire = 30
	acid = 60
	stamina = 30
	bleed = 25

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A robust beret with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#972A2A#F2F2F2"
	armor_type = /datum/armor/beret_sec
	strip_delay = 60
	dog_fashion = null
	flags_1 = NONE
	custom_price = 50

/datum/armor/beret_sec
	melee = 35
	bullet = 30
	laser = 30
	energy = 40
	bomb = 25
	fire = 50
	acid = 50
	stamina = 30
	bleed = 25

/obj/item/clothing/head/beret/corpsec
	name = "corporate security beret"
	desc = "A special black beret for the mundane life of a corporate security officer."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#3f3c40#FF0000"
	armor_type = /datum/armor/beret_corpsec
	flags_1 = NONE

/datum/armor/beret_corpsec
	melee = 40
	bullet = 30
	laser = 30
	energy = 30
	bomb = 25
	fire = 20
	acid = 50
	stamina = 30
	bleed = 25

/obj/item/clothing/head/beret/spacepol
	name = "spacepol officer beret"
	desc = "A special black beret for the mundane life of a SpacePol officer."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#3f3c40#FF0000"
	armor_type = /datum/armor/beret_spacepol
	flags_1 = NONE

/datum/armor/beret_spacepol
	melee = 40
	bullet = 30
	laser = 30
	energy = 30
	bomb = 25
	fire = 20
	acid = 50
	stamina = 30
	bleed = 25

/obj/item/clothing/head/beret/sec/navywarden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	greyscale_colors = "#3C485A#00AEEF"
	armor_type = /datum/armor/sec_navywarden
	strip_delay = 60


/datum/armor/sec_navywarden
	melee = 40
	bullet = 30
	laser = 30
	energy = 10
	bomb = 25
	fire = 30
	acid = 50
	stamina = 30
	bleed = 25

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "A special beret with the security insignia emblazoned on it. For officers with class."
	greyscale_colors = "#3C485A#FF0000"

//Science

/obj/item/clothing/head/beret/science
	name = "science beret"
	desc = "A purple beret with the science insignia emblazoned on it. It has that authentic burning plasma smell."
	armor_type = /datum/armor/beret_sci
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#A04BD9#FFFFFF"
	flags_1 = NONE

/datum/armor/beret_sci
	bomb = 5
	bio = 5
	fire = 5
	acid = 10

//Medical

/obj/item/clothing/head/beret/medical
	name = "medical beret"
	desc = "A white beret with a blue cross finely threaded into it. It has that sterile smell about it."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#E1E1E1#EDCC6A"
	armor_type = /datum/armor/beret_med
	flags_1 = NONE

/datum/armor/beret_med
	bio = 20

/obj/item/clothing/head/beret/medical/paramedic
	name = "paramedic beret"
	desc = "For finding corpses in style!"
	greyscale_colors = "#2C3A4E#FFFFFF"

/obj/item/clothing/head/beret/medical/cmo
	name = "chief medical officer beret"
	desc = "A baby blue beret with the insignia of Medistan. It smells very sterile."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#73B1D7#FFFFFF"
	armor_type = /datum/armor/beret_cmo

/datum/armor/beret_cmo
	bio = 30
	acid = 20

//Engineering
/obj/item/clothing/head/beret/engi
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	armor_type = /datum/armor/beret_eng
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#FFBC30#FFFFFF"
	flags_1 = NONE

/datum/armor/beret_eng
	fire = 10

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "A beret for those who have shown immaculate proficiency in piping. Or plumbing."
	armor_type = /datum/armor/beret_atmos
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#E56A0A#FFFFFF"
	flags_1 = NONE

/datum/armor/beret_atmos
	fire = 10

/obj/item/clothing/head/beret/ce
	name = "chief engineer beret"
	desc = "A white beret with the engineering insignia emblazoned on it. Its owner knows what they're doing. Probably."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#E1E1E1#EDCC6A"
	armor_type = /datum/armor/beret_ce
	flags_1 = NONE

/datum/armor/beret_ce
	fire = 30

/obj/item/clothing/head/beret/cargo
	name = "cargo beret"
	desc = "A brown beret with the supply insignia emblazoned on it. You can't help but wonder how much it'd sell for."
	armor_type = /datum/armor/beret_supply
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#63400E#9AA10B"
	flags_1 = NONE

//Curator
/obj/item/clothing/head/fedora/curator
	name = "treasure hunter's fedora"
	desc = "You got red text today kid, but it doesn't mean you have to like it."
	icon_state = "curator"

//Medical

/datum/armor/beret_supply
	fire = 10

/obj/item/clothing/head/beret/sergeant
	name = "spacepol sergeant beret"
	desc = "A navy SpacePol sergeant's beret."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#39393f#BBBBBB"
	armor_type = /datum/armor/beret_sergeant

/datum/armor/beret_sergeant
	melee = 40
	bullet = 20
	laser = 10
	energy = 10
	bomb = 10
	bio = 5
	fire = 5
	acid = 30
	stamina = 30
	bleed = 20

//CentCom

/datum/armor/beret_captain
	melee = 50
	bullet = 30
	laser = 20
	energy = 30
	bomb = 15
	bio = 10
	fire = 10
	acid = 60
	stamina = 40
	bleed = 20


//Miscellaneous

/obj/item/clothing/head/beret/black
	name = "black beret"
	desc = "A black beret, perfect for war veterans and dark, brooding, anti-hero mimes."
	icon_state = "beret"
	greyscale_config = /datum/greyscale_config/beret
	greyscale_config_worn = /datum/greyscale_config/beret/worn
	greyscale_colors = "#3f3c40"

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc =  "A beret made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#C5D4F3#ECF1F8"
	armor_type = /datum/armor/beret_durathread

/datum/armor/beret_durathread
	melee = 15
	bullet = 25
	laser = 15
	energy = 20
	bomb = 10
	fire = 30
	acid = 5
	stamina = 20
	bleed = 45

/obj/item/clothing/head/beret/highlander
	desc = "That was white fabric. <i>Was.</i>"
	dog_fashion = null //THIS IS FOR SLAUGHTER, NOT PUPPIES

/obj/item/clothing/head/beret/highlander/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)


//CentCom

/obj/item/clothing/head/beret/centcom_formal
	name = "\improper CentCom Formal Beret"
	desc = "Sometimes, a compromise between fashion and defense needs to be made. Thanks to Central Command's most recent nano-fabric durability enhancements, this time, it's not the case."
	icon_state = "beret_badge"
	greyscale_config = /datum/greyscale_config/beret_badge
	greyscale_config_worn = /datum/greyscale_config/beret_badge/worn
	greyscale_colors = "#46b946#f2c42e"
	armor_type = /datum/armor/beret_centcom_formal
	strip_delay = 10 SECONDS

/datum/armor/beret_centcom_formal
	melee = 80
	bullet = 80
	laser = 50
	energy = 50
	bomb = 100
	bio = 100
	fire = 100
	acid = 90
