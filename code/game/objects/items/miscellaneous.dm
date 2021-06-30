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
	attack_verb = list("warned", "cautioned", "smashed")

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
	var/choice = input(M,"Which item would you like to order?","Select an Item") as null|anything in sortList(display_names)
	if(!choice || !M.canUseTopic(src, BE_CLOSE, FALSE, NO_TK))
		return

	spawn_option(display_names[choice],M)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, "<span class='notice'>[uses] use[uses > 1 ? "s" : ""] remaining on the [src].</span>")

/obj/item/choice_beacon/proc/spawn_option(obj/choice,mob/living/M)
	var/obj/new_item = new choice()
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	pod.explosionSize = list(0,0,0,0)
	new_item.forceMove(pod)
	var/msg = "<span class=danger>After making your selection, you notice a strange target on the ground. It might be best to step back!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: <span class='bold'>Item request received. Your package is inbound, please stand back from the landing site.</span> Message ends.\""
	to_chat(M, msg)

	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/item/choice_beacon/hero
	name = "heroic beacon"
	desc = "To summon heroes from the past to protect the future."

/obj/item/choice_beacon/hero/generate_display_names()
	var/static/list/hero_item_list
	if(!hero_item_list)
		hero_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/hero) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			hero_item_list[initial(A.name)] = A
	return hero_item_list

/obj/item/storage/box/hero
	name = "Courageous Tomb Raider - 1940's."

/obj/item/storage/box/hero/PopulateContents()
	new /obj/item/clothing/head/fedora/curator(src)
	new /obj/item/clothing/suit/curator(src)
	new /obj/item/clothing/under/rank/civilian/curator/treasure_hunter(src)
	new /obj/item/clothing/shoes/workboots/mining(src)
	new /obj/item/melee/curator_whip(src)

/obj/item/storage/box/hero/astronaut
	name = "First Man on the Moon - 1960's."

/obj/item/storage/box/hero/astronaut/PopulateContents()
	new /obj/item/clothing/suit/space/nasavoid(src)
	new /obj/item/clothing/head/helmet/space/nasavoid(src)
	new /obj/item/tank/internals/oxygen(src)
	new /obj/item/gps(src)

/obj/item/storage/box/hero/scottish
	name = "Braveheart, the Scottish rebel - 1300's."

/obj/item/storage/box/hero/scottish/PopulateContents()
	new /obj/item/clothing/under/costume/kilt(src)
	new /obj/item/claymore/weak/ceremonial(src)
	new /obj/item/toy/crayon/spraycan(src)
	new /obj/item/clothing/shoes/sandal(src)

/obj/item/storage/box/hero/ghostbuster
	name = "Spectre Inspector - 1980's."

/obj/item/storage/box/hero/ghostbuster/PopulateContents()
	new /obj/item/clothing/glasses/welding/ghostbuster(src)
	new /obj/item/storage/belt/fannypack/bustin(src)
	new /obj/item/clothing/gloves/color/black(src)
	new /obj/item/clothing/shoes/jackboots(src)
	new /obj/item/clothing/under/color/khaki/buster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)
	new /obj/item/grenade/chem_grenade/ghostbuster(src)

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
	to_chat(M, "You hear something crackle from the beacon for a moment before a voice speaks.  \"Please stand by for a message from S.E.L.F. Message as follows: <span class='bold'>Item request received. Your package has been transported, use the autosurgeon supplied to apply the upgrade.</span> Message ends.\"")

/obj/item/choice_beacon/magic
	name = "beacon of summon magic"
	desc = "Not actually magical."

/obj/item/choice_beacon/magic/generate_display_names()
	var/static/list/magic_item_list
	if(!magic_item_list)
		magic_item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/magic) //we have to convert type = name to name = type, how lovely!
		for(var/V in templist)
			var/atom/A = V
			magic_item_list[initial(A.name)] = A
	return magic_item_list

/obj/item/storage/box/magic
	name = "Tele-Gloves"

/obj/item/storage/box/magic/PopulateContents()
	new /obj/item/clothing/gloves/color/white/magic(src)

/obj/item/storage/box/magic/cloak
	name = "Invisibility Cloak"

/obj/item/storage/box/magic/cloak/PopulateContents()
	new /obj/item/shadowcloak/magician(src)

/obj/item/storage/box/magic/hat
	name = "Bottomless Top Hat"

/obj/item/storage/box/magic/hat/PopulateContents()
	new /obj/item/clothing/head/that/bluespace(src)

/obj/item/clothing/head/that/bluespace //code shamelessly ripped from bluespace body bags, cuz that's basically what this is
	var/itemheld = FALSE
	var/capacity = 2
	var/maximum_size = 2 //one human, two pets, unlimited tiny mobs, but no big boys like megafauna
	var/kidnappingcoefficient = 1

/obj/item/clothing/head/that/bluespace/attackby(obj/item/W, mob/user, params)
	. = ..()
	if(istype(W, /obj/item/upgradewand))
		var/obj/item/upgradewand/wand = W
		if(!wand.used && kidnappingcoefficient == initial(kidnappingcoefficient))
			wand.used = TRUE
			kidnappingcoefficient = 0.5
			capacity = 4
			maximum_size = 4
			to_chat(user, "<span_class='notice'>You upgrade the [src] with the [wand].</span>")
			playsound(user, 'sound/weapons/emitter2.ogg', 25, 1, -1)

/obj/item/clothing/head/that/bluespace/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!proximity_flag)
		return
	if(isliving(target))
		var/mob/living/M = target
		var/kidnaptime = max(10, (M.health * (M.mob_size / 2)))
		if(iscarbon(target))
			kidnaptime += 100
		if(target == user)
			kidnaptime = 10
		M.visible_message("<span class='warning'>[user] starts pulling [src] over [M]'s head!</span>", "<span class='userdanger'>[user] starts pulling [src] over your head!</span>")
		if(do_after_mob(user, M, kidnaptime * kidnappingcoefficient))
			if(M == user)
				M.drop_all_held_items()
				if(HAS_TRAIT(src, TRAIT_NODROP))
					return
			if(M.mob_size <= capacity)
				src.contents += M
				capacity -= M.mob_size
				user.visible_message("<span class='warning'>[user] stuffs [M] into the [src]!</span>")
				to_chat(M, "<span class='userdanger'>[user] stuffs you into the [src]!</span>")
			else
				to_chat(user, "[M] will not fit in the tophat!")
	else if (isitem(target))
		var/obj/item/I = target
		if(I in user.contents)
			return
		if(!itemheld)
			src.contents += I
			itemheld = TRUE
			user.visible_message("<span class='warning'>[user] stuffs [I] into the [src]!</span>")
		else
			to_chat(user, "[I] will not fit in the tophat!")

/obj/item/clothing/head/that/bluespace/attack_self(mob/user)
	. = ..()
	capacity = maximum_size
	itemheld = FALSE
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		user.visible_message("<span class='warning'>[user] pulls [A] out of the hat!</span>")
		if(isliving(A))
			to_chat(A, "<span class='notice'>You suddenly feel air around you! You're free!</span>")
		if(isitem(A))
			var/obj/item/I = A
			user.put_in_hands(I)

/obj/item/clothing/head/that/bluespace/examine(mob/user)
	. = ..()
	if(contents.len)
		. += "<span class='notice'>You can make out [contents.len] object\s in the hat.</span>"

/obj/item/clothing/head/that/bluespace/Destroy()
	for(var/atom/movable/A in contents)
		A.forceMove(get_turf(src))
		if(isliving(A))
			to_chat(A, "<span class='notice'>You suddenly feel the space around you tear apart! You're free!</span>")
	return ..()

/obj/item/clothing/head/that/bluespace/container_resist(mob/living/user)
	if(user.incapacitated())
		to_chat(user, "<span class='warning'>You can't get out while you're restrained like this!</span>")
		return
	user.changeNext_move(CLICK_CD_BREAKOUT)
	user.last_special = world.time + CLICK_CD_BREAKOUT
	to_chat(user, "<span class='notice'>You claw at the fabric of [src], trying to tear it open...</span>")
	to_chat(loc, "<span class='warning'>Someone starts trying to break free of [src]!</span>")
	if(!do_after(user, 100, target = src))
		to_chat(loc, "<span class='warning'>The pressure subsides. It seems that they've stopped resisting...</span>")
		return
	loc.visible_message("<span class='warning'>[user] suddenly appears in front of [loc]!</span>", "<span class='userdanger'>[user] breaks free of [src]!</span>")
	user.forceMove(get_turf(src))
	capacity += user.mob_size

/obj/item/skub
	desc = "It's skub."
	name = "skub"
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "skub"
	w_class = WEIGHT_CLASS_BULKY
	attack_verb = list("skubbed")

/obj/item/skub/suicide_act(mob/living/user)
	user.visible_message("<span class='suicide'>[user] has declared themself as anti-skub! The skub tears them apart!</span>")

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
	var/mob_choice = /mob/living/simple_animal/pet/dog/corgi/exoticcorgi

/obj/item/choice_beacon/pet/generate_options(mob/living/M)
	var/input_name = stripped_input(M, "What would you like your new pet to be named?", "New Pet Name", default_name, MAX_NAME_LEN)
	if(!input_name)
		return
	spawn_mob(M,input_name)
	uses--
	if(!uses)
		qdel(src)
	else
		to_chat(M, "<span class='notice'>[uses] use[uses > 1 ? "s" : ""] remaining on the [src].</span>")

/obj/item/choice_beacon/pet/proc/spawn_mob(mob/living/M,name)
	var/obj/structure/closet/supplypod/bluespacepod/pod = new()
	var/mob/your_pet = new mob_choice(pod)
	pod.explosionSize = list(0,0,0,0)
	your_pet.name = name
	your_pet.real_name = name
	var/msg = "<span class=danger>After making your selection, you notice a strange target on the ground. It might be best to step back!</span>"
	if(ishuman(M))
		var/mob/living/carbon/human/H = M
		if(istype(H.ears, /obj/item/radio/headset))
			msg = "You hear something crackle in your ears for a moment before a voice speaks.  \"Please stand by for a message from Central Command.  Message as follows: <span class='bold'>One pet delivery straight from Central Command. Stand clear!</span> Message ends.\""
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
	mob_choice = /mob/living/simple_animal/pet/dog/corgi

/obj/item/choice_beacon/pet/hamster
	name = "hamster delivery beacon"
	default_name = "Doctor"
	mob_choice = /mob/living/simple_animal/pet/hamster

/obj/item/choice_beacon/pet/pug
	name = "pug delivery beacon"
	default_name = "Silvestro"
	mob_choice = /mob/living/simple_animal/pet/dog/pug

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
