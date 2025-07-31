/obj/item/caution
	desc = "Caution! Wet Floor!"
	name = "wet floor sign"
	icon = 'icons/obj/janitor.dmi'
	icon_state = "caution"
	lefthand_file = 'icons/mob/inhands/equipment/custodial_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/custodial_righthand.dmi'
	force = 1
	throwforce = 3
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_SMALL
	attack_verb_continuous = list("warns", "cautions", "smashes")
	attack_verb_simple = list("warn", "caution", "smash")

/obj/item/choice_beacon
	name = "choice beacon"
	desc = "Hey, why are you viewing this?!! Please let CentCom know about this odd occurrence."
	icon = 'icons/obj/device.dmi'
	icon_state = "gangtool-blue"
	item_state = "radio"
	var/uses = 1

/obj/item/choice_beacon/attack_self(mob/user)
	if(canUseBeacon(user))
		generate_options(user)

/obj/item/choice_beacon/proc/generate_display_names() // return the list that will be used in the choice selection. entries should be in (type.name = type) fashion. see choice_beacon/hero for how this is done.
	return list()

/obj/item/choice_beacon/proc/canUseBeacon(mob/living/user)
	if(user.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return TRUE
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/proc/generate_options(mob/living/M)
	var/list/display_names = generate_display_names()
	if(!display_names.len)
		return
	var/choice = tgui_input_list(M,"Which item would you like to order?","Select an Item", sort_list(display_names))
	if(!choice || !M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	spawn_option(display_names[choice],M)
	uses--
	if(!uses)
		qdel(src)
	else
		balloon_alert(M, "[uses] use[uses > 1 ? "s" : ""] remaining")
		to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))

/obj/item/choice_beacon/proc/spawn_option(obj/choice,mob/living/M)
	var/obj/new_item = new choice()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	new_item.forceMove(pod)
	var/msg = span_danger("After making your selection, you notice a strange target on the ground. It might be best to step back!")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: [span_bold("Item request received. Your package is inbound, please stand back from the landing site.")] Message ends.\""
	to_chat(M, msg)

	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/item/choice_beacon/radial
	name = "multi-choice beacon"
	desc = "Summons a variety of items"

/obj/item/choice_beacon/radial/proc/generate_item_list()
	return list()

/obj/item/choice_beacon/radial/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."

/obj/item/choice_beacon/radial/hero/generate_options(mob/living/M)
	var/list/item_list = generate_item_list()
	if(!item_list.len)
		return
	var/choice = show_radial_menu(M, src, item_list, radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!QDELETED(src) && !(isnull(choice)) && !M.incapacitated() && in_range(M,src))
		var/list/temp_list = typesof(/obj/item/storage/box/hero)
		for(var/V in temp_list)
			var/atom/A = V
			if(initial(A.name) == choice)
				spawn_option(A,M)
				uses--
				if(!uses)
					qdel(src)
				else
					balloon_alert(M, "[uses] use[uses > 1 ? "s" : ""] remaining")
					to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))
				return

/obj/item/choice_beacon/radial/hero/generate_item_list()
	var/static/list/item_list
	if(!item_list)
		item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/hero)
		for(var/V in templist)
			var/obj/item/storage/box/hero/boxy = V
			var/image/outfit_icon = image(initial(boxy.item_icon_file), initial(boxy.item_icon_state))
			var/datum/radial_menu_choice/choice = new
			choice.image = outfit_icon
			var/info_text = "That's [icon2html(outfit_icon, usr)] "
			info_text += initial(boxy.info_text)
			choice.info = info_text
			item_list[initial(boxy.name)] = choice
	return item_list

/obj/item/storage/box/hero
	name = "Courageous Tomb Raider - 1940's."
	var/icon/item_icon_file = 'icons/misc/premade_loadouts.dmi'
	var/item_icon_state = "indiana"
	var/info_text = "Courageous Tomb Raider - 1940's. \n" + span_notice("Comes with a whip")

/obj/item/storage/box/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/suit/jacket/curator(src)
	new /obj/item/clothing/under/rank/civilian/curator/treasure_hunter(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/box/hero/astronaut
	name = "First Man on the Moon - 1960's."
	item_icon_state = "voidsuit"
	info_text = "First Man on the Moon - 1960's. \n" + span_notice("Comes with an air tank and a GPS")

/obj/item/storage/box/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/box/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."
	item_icon_state = "scottsman"
	info_text = "Braveheart, the Scottish rebel - 1300's. \n" + span_notice("Comes with a claymore and a spraycan")

/obj/item/storage/box/hero/scottish/PopulateContents()
	new /obj/item/clothing/under/costume/kilt(src)
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/toy/crayon/spraycan(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/hero/ghostbuster
	name = "Spectre Inspector - 1980's."
	item_icon_state = "ghostbuster"
	info_text = "Spectre Inspector - 1980's. \n" + span_notice("Comes with some anti-spectre grenades")

/obj/item/storage/box/hero/ghostbuster/PopulateContents()
	new /obj/item/clothing/glasses/welding/ghostbuster(src)
	new /obj/item/storage/belt/fannypack/bustin(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/under/color/khaki/buster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)

/obj/item/storage/box/hero/carphunter
	name = "Carp Hunter, Wildlife Expert - 2506."
	item_icon_state = "carp"
	info_text = "Carp Hunter, Wildlife Expert - 2506. \n" + span_notice("Comes with a hunting knife")

/obj/item/storage/box/hero/carphunter/PopulateContents()
	new /obj/item/clothing/suit/hooded/carp_costume/spaceproof/old(src)
	new /obj/item/clothing/mask/gas/carp(src)
	new /obj/item/knife/hunting(src)

/obj/item/storage/box/hero/ronin
	name = "Sword Saint, Wandering Vagabond - 1600's."
	item_icon_state = "samurai"
	info_text = "Sword Saint, Wandering Vagabond - 1600's. \n" + span_notice("Comes with a replica katana")

/obj/item/storage/box/hero/ronin/PopulateContents()
	new /obj/item/clothing/under/costume/kamishimo(src)
	new /obj/item/clothing/head/costume/rice_hat(src)
	new /obj/item/katana/weak/curator(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/choice_beacon/augments
	name = "augment beacon"
	desc = "Summons augmentations. Can be used 3 times!"
	uses = 3

/obj/item/choice_beacon/augments/generate_display_names()
	var/static/list/augment_list
	if(!augment_list)
		augment_list = list()
		var/list/templist = list(
		/obj/item/organ/cyberimp/brain/anti_drop,
		/obj/item/organ/cyberimp/arm/toolset,
		/obj/item/organ/cyberimp/arm/surgery,
		/obj/item/organ/cyberimp/chest/thrusters,
		/obj/item/organ/lungs/cybernetic/upgraded,
		/obj/item/organ/liver/cybernetic/upgraded) //cyberimplants range from a nice bonus to fucking broken bullshit so no subtypesof
		for(var/V in templist)
			var/atom/A = V
			augment_list[initial(A.name)] = A
	return augment_list

/obj/item/choice_beacon/augments/spawn_option(obj/choice,mob/living/M)
	new choice(get_turf(M))
	to_chat(M, "You hear something crackle from the beacon for a moment before a voice speaks.  \"Please stand by for a message from S.E.L.F. Message as follows: [span_bold("Item request received. Your package has been transported, use the autosurgeon supplied to apply the upgrade.")] Message ends.\"")

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("skubs")
	attack_verb_simple = list("skub")

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] has declared themself as anti-skub! The skub tears them apart!"))

	user.gib()
	playsound(src, 'sound/items/eatfood.ogg', 50, 1, -1)
	return MANUAL_SUICIDE

/obj/item/choice_beacon/ouija
	name = "spirit board delivery beacon"
	desc = "Ghost communication on demand! It is unclear how this thing is still operational."

/obj/item/choice_beacon/ouija/generate_display_names()
	var/static/list/ouija_spaghetti_list
	if(!ouija_spaghetti_list)
		ouija_spaghetti_list = list()
		var/list/templist = list(/obj/structure/spirit_board)
		for(var/V in templist)
			var/atom/A = V
			ouija_spaghetti_list[initial(A.name)] = A
	return ouija_spaghetti_list

/obj/item/upgradewand
	desc = "A wand laced with nanotech calibration devices, used to enhance gear commonly used by modern stage magicians."
	name = "Upgrade Wand"
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "nothingwand"
	item_state = "wand"
	w_class = WEIGHT_CLASS_SMALL
	var/used = FALSE

/obj/item/choice_beacon/pet
	name = "animal delivery beacon"
	desc = "There are no faster ways, only more humane."
	var/default_name = "Bacon"
	var/mob_choice = /mob/living/basic/pet/dog/corgi/exoticcorgi

/obj/item/choice_beacon/pet/generate_options(mob/living/M)
	var/input_name = tgui_input_text(M, "What would you like your new pet to be named?", "New Pet Name", default_name, MAX_NAME_LEN)
	if(!input_name) // no input
		to_chat(M, span_warning("You must enter a name for your pet!"))
		return
	if(CHAT_FILTER_CHECK(input_name)) // check for forbidden words
		to_chat(M, span_warning("Your pet name contains a forbidden word."))
		return
	spawn_mob(M,input_name)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))

/obj/item/choice_beacon/pet/proc/spawn_mob(mob/living/M,name)
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	var/mob/your_pet = new mob_choice(pod)
	pod.explosionSize = list(0,0,0,0)
	your_pet.name = name
	your_pet.real_name = name
	var/msg = span_danger("After making your selection, you notice a strange target on the ground. It might be best to step back!")
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: [span_bold("One pet delivery straight from Central Command. Stand clear!")] Message ends.\""
	to_chat(M, msg)
	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/item/choice_beacon/pet/cat
	name = "cat delivery beacon"
	default_name = "Tom"
	mob_choice = /mob/living/simple_animal/pet/cat

/obj/item/choice_beacon/pet/mouse
	name = "mouse delivery beacon"
	default_name = "Jerry"
	mob_choice = /mob/living/simple_animal/mouse

/obj/item/choice_beacon/pet/corgi
	name = "corgi delivery beacon"
	default_name = "Tosha"
	mob_choice = /mob/living/basic/pet/dog/corgi

/obj/item/choice_beacon/pet/hamster
	name = "hamster delivery beacon"
	default_name = "Doctor"
	mob_choice = /mob/living/simple_animal/pet/hamster

/obj/item/choice_beacon/pet/pug
	name = "pug delivery beacon"
	default_name = "Silvestro"
	mob_choice = /mob/living/basic/pet/dog/pug

/obj/item/choice_beacon/pet/ems
	name = "emotional support animal delivery beacon"
	default_name = "Hugsie"
	mob_choice = /mob/living/simple_animal/pet/cat/kitten

/obj/item/choice_beacon/pet/pingu
	name = "penguin delivery beacon"
	default_name = "Pingu"
	mob_choice = /mob/living/simple_animal/pet/penguin/baby

/obj/item/choice_beacon/pet/clown
	name = "living lube delivery beacon"
	default_name = "Offensive"
	mob_choice = /mob/living/simple_animal/hostile/retaliate/clown/lube

/obj/item/choice_beacon/pet/goat
	name = "goat delivery beacon"
	default_name = "Billy"
	mob_choice = /mob/living/simple_animal/hostile/retaliate/goat

/obj/item/choice_beacon/janicart
	name = "janicart delivery beacon"
	desc = "Summons a pod containing one (1) pimpin ride."

/obj/item/choice_beacon/janicart/generate_display_names()
	return list("janitor cart" = /obj/vehicle/ridden/janicart/upgraded/keyless)
