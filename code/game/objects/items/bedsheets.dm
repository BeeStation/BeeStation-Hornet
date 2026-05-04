#define BEDSHEET_ABSTRACT "abstract"
#define BEDSHEET_SINGLE "single"
#define BEDSHEET_DOUBLE "double"

/obj/item/bedsheet
	name = "bedsheet"
	desc = "A surprisingly soft linen bedsheet."
	icon = 'icons/obj/beds_chairs/beds.dmi'
	lefthand_file = 'icons/mob/inhands/misc/bedsheet_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/bedsheet_righthand.dmi'
	icon_state = "sheetwhite"
	inhand_icon_state = "sheetwhite"
	slot_flags = ITEM_SLOT_NECK
	layer = MOB_LAYER
	throwforce = 0
	throw_speed = 1
	throw_range = 2
	w_class = WEIGHT_CLASS_TINY
	dying_key = DYE_REGISTRY_BEDSHEET
	resistance_flags = FLAMMABLE

	dog_fashion = /datum/dog_fashion/head/ghost
	var/list/dream_messages = list("white")

/obj/item/bedsheet/Initialize(mapload)
	. = ..()
	AddElement(/datum/element/bed_tuckable, 0, 0, 0)

/obj/item/bedsheet/attack(mob/living/M, mob/user)
	attempt_initiate_surgery(src, M, user)

/obj/item/bedsheet/attack_self(mob/user)
	if(!user.CanReach(src))		//No telekenetic grabbing.
		return
	if(!user.dropItemToGround(src))
		return
	if(layer == initial(layer))
		layer = ABOVE_MOB_LAYER
		to_chat(user, span_notice("You cover yourself with [src]."))
		pixel_x = 0
		pixel_y = 0
	else
		layer = initial(layer)
		to_chat(user, span_notice("You smooth [src] out beneath you."))
	add_fingerprint(user)
	return

/obj/item/bedsheet/attackby(obj/item/I, mob/user, params)
	if(I.tool_behaviour == TOOL_WIRECUTTER || I.get_sharpness())
		var/turf/T = get_turf(src)
		var/obj/item/stack/sheet/cotton/cloth/C = new (T, 3)
		if(QDELETED(C))
			C = locate(/obj/item/stack/sheet/cotton/cloth) in T
		if(C)
			transfer_fingerprints_to(C)
			C.add_fingerprint(user)
		qdel(src)
		to_chat(user, span_notice("You tear [src] up."))
	else
		return ..()

/obj/item/bedsheet/blue
	icon_state = "sheetblue"
	inhand_icon_state = "sheetblue"
	dream_messages = list("blue")

/obj/item/bedsheet/green
	icon_state = "sheetgreen"
	inhand_icon_state = "sheetgreen"
	dream_messages = list("green")

/obj/item/bedsheet/grey
	icon_state = "sheetgrey"
	inhand_icon_state = "sheetgrey"
	dream_messages = list("grey")

/obj/item/bedsheet/orange
	icon_state = "sheetorange"
	inhand_icon_state = "sheetorange"
	dream_messages = list("orange")

/obj/item/bedsheet/purple
	icon_state = "sheetpurple"
	inhand_icon_state = "sheetpurple"
	dream_messages = list("purple")

/obj/item/bedsheet/red
	icon_state = "sheetred"
	inhand_icon_state = "sheetred"
	dream_messages = list("red")

/obj/item/bedsheet/yellow
	icon_state = "sheetyellow"
	inhand_icon_state = "sheetyellow"
	dream_messages = list("yellow")

/obj/item/bedsheet/brown
	icon_state = "sheetbrown"
	inhand_icon_state = "sheetbrown"
	dream_messages = list("brown")

/obj/item/bedsheet/black
	icon_state = "sheetblack"
	inhand_icon_state = "sheetblack"
	dream_messages = list("black")

/obj/item/bedsheet/patriot
	name = "patriotic bedsheet"
	desc = "You've never felt more free than when sleeping on this."
	icon_state = "sheetUSA"
	inhand_icon_state = "sheetUSA"
	dream_messages = list("America", "freedom", "fireworks", "bald eagles")

/obj/item/bedsheet/rainbow
	name = "rainbow bedsheet"
	desc = "A multicolored blanket. It's actually several different sheets cut up and sewn together."
	icon_state = "sheetrainbow"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("red", "orange", "yellow", "green", "blue", "purple", "a rainbow")

/obj/item/bedsheet/mime
	name = "mime's blanket"
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."
	icon_state = "sheetmime"
	inhand_icon_state = "sheetmime"
	dream_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")

/obj/item/bedsheet/clown
	name = "clown's blanket"
	desc = "A rainbow blanket with a clown mask woven in. It smells faintly of bananas."
	icon_state = "sheetclown"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")

/obj/item/bedsheet/captain
	name = "captain's bedsheet"
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."
	icon_state = "sheetcaptain"
	inhand_icon_state = "sheetcaptain"
	dream_messages = list("authority", "a golden ID", "sunglasses", "a green disc", "an antique gun", "the captain")

/obj/item/bedsheet/rd
	name = "research director's bedsheet"
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."
	icon_state = "sheetrd"
	inhand_icon_state = "sheetrd"
	dream_messages = list("authority", "a silvery ID", "a bomb", "a mech", "a facehugger", "maniacal laughter", "the research director")

// for Free Golems.
/obj/item/bedsheet/rd/royal_cape
	name = "Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/bedsheet/medical
	name = "medical blanket"
	desc = "It's a sterilized* blanket commonly used in the Medbay.  <i>*Sterilization is voided if a virologist is present onboard the station.</i>"
	icon_state = "sheetmedical"
	inhand_icon_state = "sheetmedical"
	dream_messages = list("healing", "life", "surgery", "a doctor")

/obj/item/bedsheet/cmo
	name = "chief medical officer's bedsheet"
	desc = "It's a sterilized blanket that has a cross emblem. There's some cat fur on it, likely from Runtime."
	icon_state = "sheetcmo"
	inhand_icon_state = "sheetcmo"
	dream_messages = list("authority", "a silvery ID", "healing", "life", "surgery", "a cat", "the chief medical officer")

/obj/item/bedsheet/hos
	name = "head of security's bedsheet"
	desc = "It is decorated with a shield emblem. While crime doesn't sleep, you do, but you are still THE LAW!"
	icon_state = "sheethos"
	inhand_icon_state = "sheethos"
	dream_messages = list("authority", "a silvery ID", "handcuffs", "a baton", "a flashbang", "sunglasses", "the head of security")

/obj/item/bedsheet/hop
	name = "head of personnel's bedsheet"
	desc = "It is decorated with a key emblem. For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."
	icon_state = "sheethop"
	inhand_icon_state = "sheethop"
	dream_messages = list("authority", "a silvery ID", "obligation", "a computer", "an ID", "a corgi", "the head of personnel")

/obj/item/bedsheet/ce
	name = "chief engineer's bedsheet"
	desc = "It is decorated with a wrench emblem. It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."
	icon_state = "sheetce"
	inhand_icon_state = "sheetce"
	dream_messages = list("authority", "a silvery ID", "the engine", "power tools", "an APC", "a parrot", "the chief engineer")

/obj/item/bedsheet/qm
	name = "quartermaster's bedsheet"
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."
	icon_state = "sheetqm"
	inhand_icon_state = "sheetqm"
	dream_messages = list("a grey ID", "a shuttle", "a crate", "a sloth", "the quartermaster")

/obj/item/bedsheet/magician
	name = "magician's cape"
	desc = "A magician never reveals his secrets."
	icon_state = "sheetmagician"
	inhand_icon_state = "sheetmagician"
	dream_messages = list("trickery", "crime", "a gullible mark", "an angry wizard", "pixie dust")

/obj/item/bedsheet/centcom
	name = "\improper CentCom bedsheet"
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."
	icon_state = "sheetcentcom"
	inhand_icon_state = "sheetcentcom"
	dream_messages = list("a unique ID", "authority", "artillery", "an ending")

/obj/item/bedsheet/syndie
	name = "syndicate bedsheet"
	desc = "It has a syndicate emblem and it has an aura of evil."
	icon_state = "sheetsyndie"
	inhand_icon_state = "sheetsyndie"
	dream_messages = list("a green disc", "a red crystal", "a glowing blade", "a wire-covered ID")

/obj/item/bedsheet/cult
	name = "cultist's bedsheet"
	desc = "You might dream of Nar'Sie if you sleep with this. It seems rather tattered and glows of an eldritch presence."
	icon_state = "sheetcult"
	inhand_icon_state = "sheetcult"
	dream_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")

/obj/item/bedsheet/wiz
	name = "wizard's bedsheet"
	desc = "A special fabric enchanted with magic so you can have an enchanted night. It even glows!"
	icon_state = "sheetwiz"
	inhand_icon_state = "sheetwiz"
	dream_messages = list("a book", "an explosion", "lightning", "a staff", "a skeleton", "a robe", "magic")

/obj/item/bedsheet/nanotrasen
	name = "\improper Nanotrasen bedsheet"
	desc = "It has the Nanotrasen logo on it and has an aura of duty."
	icon_state = "sheetNT"
	inhand_icon_state = "sheetNT"
	dream_messages = list("authority", "an ending")

/obj/item/bedsheet/ian
	name = "Ian's bedsheet"
	desc = "The HoP's beloved pet, now in bedsheet format."
	icon_state = "sheetian"
	inhand_icon_state = "sheetian"
	dream_messages = list("a dog", "a corgi", "woof", "bark", "arf")

/obj/item/bedsheet/cosmos
	name = "cosmic space bedsheet"
	desc = "Made from the dreams of those who wonder at the stars."
	icon_state = "sheetcosmos"
	inhand_icon_state = "sheetcosmos"
	dream_messages = list("the infinite cosmos", "Hans Zimmer music", "a flight through space", "the galaxy", "being fabulous", "shooting stars")
	light_power = 2
	light_range = 1.4
	light_system = MOVABLE_LIGHT

/obj/item/bedsheet/random
	icon_state = "random_bedsheet"
	name = "random bedsheet"
	desc = "If you're reading this description ingame, something has gone wrong! Honk!"
	item_flags = ABSTRACT

/obj/item/bedsheet/random/Initialize(mapload)
	..()
	var/type = pick(typesof(/obj/item/bedsheet) - typesof(/obj/item/bedsheet/double) -/obj/item/bedsheet/random)
	new type(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/bedsheet/dorms
	icon_state = "random_bedsheet"
	name = "random dorms bedsheet"
	desc = "If you're reading this description ingame, something has gone wrong! Honk!"
	item_flags = ABSTRACT
	slot_flags = null

/obj/item/bedsheet/dorms/Initialize(mapload)
	..()
	var/type = pick_weight(list("Colors" = 80, "Special" = 20))
	switch(type)
		if("Colors")
			type = pick(list(/obj/item/bedsheet,
				/obj/item/bedsheet/blue,
				/obj/item/bedsheet/green,
				/obj/item/bedsheet/grey,
				/obj/item/bedsheet/orange,
				/obj/item/bedsheet/purple,
				/obj/item/bedsheet/red,
				/obj/item/bedsheet/yellow,
				/obj/item/bedsheet/brown,
				/obj/item/bedsheet/black))
		if("Special")
			type = pick(list(/obj/item/bedsheet/patriot,
				/obj/item/bedsheet/rainbow,
				/obj/item/bedsheet/ian,
				/obj/item/bedsheet/cosmos,
				/obj/item/bedsheet/nanotrasen))
	new type(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/bedsheet/double
	icon_state = "double_sheetwhite"
	dying_key = DYE_REGISTRY_DOUBLE_BEDSHEET

/obj/item/bedsheet/double/Initialize(mapload)
	. = ..()
	desc += " This one is double."

/obj/item/bedsheet/double/blue
	icon_state = "double_sheetblue"
	inhand_icon_state = "sheetblue"
	dream_messages = list("blue")

/obj/item/bedsheet/double/green
	icon_state = "double_sheetgreen"
	inhand_icon_state = "sheetgreen"
	dream_messages = list("green")

/obj/item/bedsheet/double/grey
	icon_state = "double_sheetgrey"
	inhand_icon_state = "sheetgrey"
	dream_messages = list("grey")

/obj/item/bedsheet/double/orange
	icon_state = "double_sheetorange"
	inhand_icon_state = "sheetorange"
	dream_messages = list("orange")

/obj/item/bedsheet/double/purple
	icon_state = "double_sheetpurple"
	inhand_icon_state = "sheetpurple"
	dream_messages = list("purple")

/obj/item/bedsheet/double/red
	icon_state = "double_sheetred"
	inhand_icon_state = "sheetred"
	dream_messages = list("red")

/obj/item/bedsheet/double/yellow
	icon_state = "double_sheetyellow"
	inhand_icon_state = "sheetyellow"
	dream_messages = list("yellow")

/obj/item/bedsheet/double/brown
	icon_state = "double_sheetbrown"
	inhand_icon_state = "sheetbrown"
	dream_messages = list("brown")

/obj/item/bedsheet/double/black
	icon_state = "double_sheetblack"
	inhand_icon_state = "sheetblack"
	dream_messages = list("black")

/obj/item/bedsheet/double/patriot
	name = "double patriotic bedsheet"
	icon_state = "double_sheetUSA"
	inhand_icon_state = "sheetUSA"
	dream_messages = list("America", "freedom", "fireworks", "bald eagles")
	desc = "You've never felt more free than when sleeping on this."

/obj/item/bedsheet/double/rainbow
	name = "double rainbow bedsheet"
	icon_state = "double_sheetrainbow"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("red", "orange", "yellow", "green", "blue", "purple", "a rainbow")
	desc = "A multicolored blanket. It's actually several different sheets cut up and sewn together."

/obj/item/bedsheet/double/mime
	name = "double mime's blanket"
	icon_state = "double_sheetmime"
	inhand_icon_state = "sheetmime"
	dream_messages = list("silence", "gestures", "a pale face", "a gaping mouth", "the mime")
	desc = "A very soothing striped blanket.  All the noise just seems to fade out when you're under the covers in this."

/obj/item/bedsheet/double/clown
	name = "double clown's blanket"
	icon_state = "double_sheetclown"
	inhand_icon_state = "sheetrainbow"
	dream_messages = list("honk", "laughter", "a prank", "a joke", "a smiling face", "the clown")
	desc = "A rainbow blanket with a clown mask woven in. It smells faintly of bananas."

/obj/item/bedsheet/double/captain
	name = "double captain's bedsheet"
	icon_state = "double_sheetcaptain"
	inhand_icon_state = "sheetcaptain"
	dream_messages = list("authority", "a golden ID", "sunglasses", "a green disc", "an antique gun", "the captain")
	desc = "It has a Nanotrasen symbol on it, and was woven with a revolutionary new kind of thread guaranteed to have 0.01% permeability for most non-chemical substances, popular among most modern captains."

/obj/item/bedsheet/double/rd
	name = "double research director's bedsheet"
	icon_state = "double_sheetrd"
	inhand_icon_state = "sheetrd"
	dream_messages = list("authority", "a silvery ID", "a bomb", "a mech", "a facehugger", "maniacal laughter", "the research director")
	desc = "It appears to have a beaker emblem, and is made out of fire-resistant material, although it probably won't protect you in the event of fires you're familiar with every day."

// for double Free Golems.
/obj/item/bedsheet/rd/royal_cape
	name = "Double Royal Cape of the Liberator"
	desc = "Majestic."
	dream_messages = list("mining", "stone", "a golem", "freedom", "doing whatever")

/obj/item/bedsheet/double/medical
	name = "double medical blanket"
	icon_state = "double_sheetmedical"
	inhand_icon_state = "sheetmedical"
	dream_messages = list("healing", "life", "surgery", "a doctor")
	desc = "It's a sterilized* blanket commonly used in the Medbay.  <i>*Sterilization is voided if a virologist is present onboard the station.</i>"

/obj/item/bedsheet/double/cmo
	name = "double chief medical officer's bedsheet"
	icon_state = "double_sheetcmo"
	inhand_icon_state = "sheetcmo"
	dream_messages = list("authority", "a silvery ID", "healing", "life", "surgery", "a cat", "the chief medical officer")
	desc = "It's a sterilized blanket that has a cross emblem. There's some cat fur on it, likely from Runtime."

/obj/item/bedsheet/double/hos
	name = "double head of security's bedsheet"
	icon_state = "double_sheethos"
	inhand_icon_state = "sheethos"
	dream_messages = list("authority", "a silvery ID", "handcuffs", "a baton", "a flashbang", "sunglasses", "the head of security")
	desc = "It is decorated with a shield emblem. While crime doesn't sleep, you do, but you are still THE LAW!"

/obj/item/bedsheet/double/hop
	name = "double head of personnel's bedsheet"
	icon_state = "double_sheethop"
	inhand_icon_state = "sheethop"
	dream_messages = list("authority", "a silvery ID", "obligation", "a computer", "an ID", "a corgi", "the head of personnel")
	desc = "It is decorated with a key emblem. For those rare moments when you can rest and cuddle with Ian without someone screaming for you over the radio."

/obj/item/bedsheet/double/ce
	name = "double chief engineer's bedsheet"
	icon_state = "double_sheetce"
	inhand_icon_state = "sheetce"
	dream_messages = list("authority", "a silvery ID", "the engine", "power tools", "an APC", "a parrot", "the chief engineer")
	desc = "It is decorated with a wrench emblem. It's highly reflective and stain resistant, so you don't need to worry about ruining it with oil."

/obj/item/bedsheet/double/qm
	name = "double quartermaster's bedsheet"
	icon_state = "double_sheetqm"
	inhand_icon_state = "sheetqm"
	dream_messages = list("a grey ID", "a shuttle", "a crate", "a sloth", "the quartermaster")
	desc = "It is decorated with a crate emblem in silver lining.  It's rather tough, and just the thing to lie on after a hard day of pushing paper."

/obj/item/bedsheet/double/centcom
	name = "\improper double CentCom bedsheet"
	icon_state = "double_sheetcentcom"
	inhand_icon_state = "sheetcentcom"
	dream_messages = list("a unique ID", "authority", "artillery", "an ending")
	desc = "Woven with advanced nanothread for warmth as well as being very decorated, essential for all officials."

/obj/item/bedsheet/double/syndie
	name = "double syndicate bedsheet"
	icon_state = "double_sheetsyndie"
	inhand_icon_state = "sheetsyndie"
	dream_messages = list("a green disc", "a red crystal", "a glowing blade", "a wire-covered ID")
	desc = "It has a syndicate emblem and it has an aura of evil."

/obj/item/bedsheet/double/cult
	name = "double cultist's bedsheet"
	icon_state = "double_sheetcult"
	inhand_icon_state = "sheetcult"
	dream_messages = list("a tome", "a floating red crystal", "a glowing sword", "a bloody symbol", "a massive humanoid figure")
	desc = "You might dream of Nar'Sie if you sleep with this. It seems rather tattered and glows of an eldritch presence."

/obj/item/bedsheet/double/wiz
	name = "double wizard's bedsheet"
	icon_state = "double_sheetwiz"
	inhand_icon_state = "sheetwiz"
	dream_messages = list("a book", "an explosion", "lightning", "a staff", "a skeleton", "a robe", "magic")
	desc = "A special fabric enchanted with magic so you can have an enchanted night. It even glows!"

/obj/item/bedsheet/double/nanotrasen
	name = "\improper double Nanotrasen bedsheet"
	icon_state = "double_sheetNT"
	inhand_icon_state = "sheetNT"
	dream_messages = list("authority", "an ending")
	desc = "It has the Nanotrasen logo on it and has an aura of duty."

/obj/item/bedsheet/double/ian
	name = "double Ian's bedsheet"
	icon_state = "double_sheetian"
	inhand_icon_state = "sheetian"
	dream_messages = list("a dog", "a corgi", "woof", "bark", "arf")
	desc = "The HoP's beloved pet, now in bedsheet format."


/obj/item/bedsheet/double/cosmos
	name = "double cosmic space bedsheet"
	icon_state = "double_sheetcosmos"
	inhand_icon_state = "sheetcosmos"
	dream_messages = list("the infinite cosmos", "Hans Zimmer music", "a flight through space", "the galaxy", "being fabulous", "shooting stars")
	desc = "Made from the dreams of those who wonder at the stars."
	light_power = 2.1
	light_range = 1.8
	light_system = MOVABLE_LIGHT

/obj/item/bedsheet/double/random
	name = "random double bedsheet"
	icon_state = "random_doublesheet"
	desc = "If you're reading this description ingame, something has gone wrong twice! Honk!"
	item_flags = ABSTRACT

/obj/item/bedsheet/double/random/Initialize(mapload)
	..()
	var/type = pick(typesof(/obj/item/bedsheet/double) - /obj/item/bedsheet/double/random)
	new type(loc)
	return INITIALIZE_HINT_QDEL

/obj/item/bedsheet/double/dorms
	name = "random double dorms bedsheet"
	icon_state = "random_doublesheet"
	desc = "If you're reading this description ingame, something has gone wrong! Honk!"
	item_flags = ABSTRACT

/obj/item/bedsheet/double/dorms/Initialize(mapload)
	..()
	var/type = pick_weight(list("Colors" = 80, "Special" = 20))
	switch(type)
		if("Colors")
			type = pick(list(/obj/item/bedsheet/double,
				/obj/item/bedsheet/double/blue,
				/obj/item/bedsheet/double/green,
				/obj/item/bedsheet/double/grey,
				/obj/item/bedsheet/double/orange,
				/obj/item/bedsheet/double/purple,
				/obj/item/bedsheet/double/red,
				/obj/item/bedsheet/double/yellow,
				/obj/item/bedsheet/double/brown,
				/obj/item/bedsheet/double/black))
		if("Special")
			type = pick(list(/obj/item/bedsheet/double/patriot,
				/obj/item/bedsheet/double/rainbow,
				/obj/item/bedsheet/double/ian,
				/obj/item/bedsheet/double/cosmos,
				/obj/item/bedsheet/double/nanotrasen))
	new type(loc)
	return INITIALIZE_HINT_QDEL

#undef BEDSHEET_ABSTRACT
#undef BEDSHEET_SINGLE
#undef BEDSHEET_DOUBLE
