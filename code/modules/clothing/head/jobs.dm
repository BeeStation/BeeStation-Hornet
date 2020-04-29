//defines the drill hat's yelling setting
#define DRILL_DEFAULT	"default"
#define DRILL_SHOUTING	"shouting"
#define DRILL_YELLING	"yelling"
#define DRILL_CANADIAN	"canadian"

//Chef
/obj/item/clothing/head/chefhat
	name = "chef's hat"
	item_state = "chef"
	icon_state = "chef"
	desc = "The commander in chef's head wear."
	strip_delay = 10
	equip_delay_other = 10
	dynamic_hair_suffix = ""
	dog_fashion = /datum/dog_fashion/head/chef

/obj/item/clothing/head/chefhat/suicide_act(mob/user)
	user.visible_message("<span class='suicide'>[user] is donning [src]! It looks like [user.p_theyre()] trying to become a chef.</span>")
	user.say("Bork Bork Bork!", forced = "chef hat suicide")
	sleep(20)
	user.visible_message("<span class='suicide'>[user] climbs into an imaginary oven!</span>")
	user.say("BOOORK!", forced = "chef hat suicide")
	playsound(user, 'sound/machines/ding.ogg', 50, 1)
	return(FIRELOSS)

//Captain
/obj/item/clothing/head/caphat
	name = "captain's hat"
	desc = "It's good being the king."
	icon_state = "captain"
	item_state = "that"
	flags_inv = 0
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/captain

//Captain: This is no longer space-worthy
/obj/item/clothing/head/caphat/parade
	name = "captain's parade cap"
	desc = "Worn only by Captains with an abundance of class."
	icon_state = "capcap"

	dog_fashion = null


//Head of Personnel
/obj/item/clothing/head/hopcap
	name = "head of personnel's cap"
	icon_state = "hopcap"
	desc = "The symbol of true bureaucratic micromanagement."
	armor = list("melee" = 25, "bullet" = 15, "laser" = 25, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 50, "acid" = 50)
	dog_fashion = /datum/dog_fashion/head/hop

//Chaplain
/obj/item/clothing/head/nun_hood
	name = "nun hood"
	desc = "Maximum piety in this star system."
	icon_state = "nun_hood"
	flags_inv = HIDEHAIR
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/bishopmitre
	name = "bishop mitre"
	desc = "An opulent hat that functions as a radio to God. Or as a lightning rod, depending on who you ask."
	icon_state = "bishopmitre"

//Detective
/obj/item/clothing/head/fedora/det_hat
	name = "detective's fedora"
	desc = "There's only one man who can sniff out the dirty stench of crime, and he's likely wearing this hat."
	armor = list("melee" = 25, "bullet" = 5, "laser" = 25, "energy" = 30, "bomb" = 0, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50)
	icon_state = "detective"
	var/candy_cooldown = 0
	pocket_storage_component_path = /datum/component/storage/concrete/pockets/small/detective
	dog_fashion = /datum/dog_fashion/head/detective

/obj/item/clothing/head/fedora/det_hat/Initialize()
	. = ..()
	new /obj/item/reagent_containers/food/drinks/flask/det(src)

/obj/item/clothing/head/fedora/det_hat/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Alt-click to take a candy corn.</span>"

/obj/item/clothing/head/fedora/det_hat/AltClick(mob/user)
	if(user.canUseTopic(src, BE_CLOSE, ismonkey(user)))
		..()
		if(loc == user)
			if(candy_cooldown < world.time)
				var/obj/item/reagent_containers/food/snacks/candy_corn/CC = new /obj/item/reagent_containers/food/snacks/candy_corn(src)
				user.put_in_hands(CC)
				to_chat(user, "You slip a candy corn from your hat.")
				candy_cooldown = world.time+1200
			else
				to_chat(user, "You just took a candy corn! You should wait a couple minutes, lest you burn through your stash.")


//Mime
/obj/item/clothing/head/beret
	name = "beret"
	desc = "A beret, a mime's favorite headwear."
	icon_state = "beret"
	dog_fashion = /datum/dog_fashion/head/beret
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"

/obj/item/clothing/head/beret/vintage
	name = "vintage beret"
	desc = "A well-worn beret."
	icon_state = "vintageberet"
	dog_fashion = null

/obj/item/clothing/head/beret/archaic
	name = "archaic beret"
	desc = "An absolutely ancient beret, allegedly worn by the first mime to ever step foot on a NanoTrasen station."
	icon_state = "archaicberet"
	dog_fashion = null

/obj/item/clothing/head/beret/black
	name = "black beret"
	desc = "A black beret, perfect for war veterans and dark, brooding, anti-hero mimes."
	icon_state = "beretblack"

/obj/item/clothing/head/beret/highlander
	desc = "That was white fabric. <i>Was.</i>"
	dog_fashion = null //THIS IS FOR SLAUGHTER, NOT PUPPIES

/obj/item/clothing/head/beret/highlander/Initialize()
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HIGHLANDER)

/obj/item/clothing/head/beret/durathread
	name = "durathread beret"
	desc =  "A beret made from durathread, its resilient fibres provide some protection to the wearer."
	icon_state = "beretdurathread"
	item_color = null
	armor = list("melee" = 15, "bullet" = 5, "laser" = 15, "energy" = 20, "bomb" = 10, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 5)

//Security

/obj/item/clothing/head/HoS
	name = "head of security cap"
	desc = "The robust standard-issue cap of the Head of Security. For showing the officers who's in charge."
	icon_state = "hoscap"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 25, "energy" = 30, "bomb" = 25, "bio" = 10, "rad" = 0, "fire" = 50, "acid" = 60)
	strip_delay = 80
	dynamic_hair_suffix = ""

/obj/item/clothing/head/HoS/syndicate
	name = "syndicate cap"
	desc = "A black cap fit for a high ranking syndicate officer."

/obj/item/clothing/head/HoS/beret
	name = "head of security beret"
	desc = "A robust beret for the Head of Security, for looking stylish while not sacrificing protection."
	icon_state = "hosberetblack"

/obj/item/clothing/head/HoS/beret/syndicate
	name = "syndicate beret"
	desc = "A black beret with thick armor padding inside. Stylish and robust."

/obj/item/clothing/head/warden
	name = "warden's police hat"
	desc = "It's a special armored hat issued to the Warden of a security force. Protects the head from impacts."
	icon_state = "policehelm"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 60)
	strip_delay = 60
	dog_fashion = /datum/dog_fashion/head/warden

/obj/item/clothing/head/warden/drill
	name = "warden's campaign hat"
	desc = "A special armored campaign hat with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "wardendrill"
	item_state = "wardendrill"
	dog_fashion = null
	var/mode = DRILL_DEFAULT

/obj/item/clothing/head/warden/drill/screwdriver_act(mob/living/carbon/human/user, obj/item/I)
	if(..())
		return TRUE
	switch(mode)
		if(DRILL_DEFAULT)
			to_chat(user, "<span class='notice'>You set the voice circuit to the middle position.</span>")
			mode = DRILL_SHOUTING
		if(DRILL_SHOUTING)
			to_chat(user, "<span class='notice'>You set the voice circuit to the last position.</span>")
			mode = DRILL_YELLING
		if(DRILL_YELLING)
			to_chat(user, "<span class='notice'>You set the voice circuit to the first position.</span>")
			mode = DRILL_DEFAULT
		if(DRILL_CANADIAN)
			to_chat(user, "<span class='danger'>You adjust voice circuit but nothing happens, probably because it's broken.</span>")
	return TRUE

/obj/item/clothing/head/warden/drill/wirecutter_act(mob/living/user, obj/item/I)
	if(mode != DRILL_CANADIAN)
		to_chat(user, "<span class='danger'>You broke the voice circuit!</span>")
		mode = DRILL_CANADIAN
	return TRUE

/obj/item/clothing/head/warden/drill/speechModification(M)
	if(copytext(M, 1, 2) != "*")
		if(mode == DRILL_DEFAULT)
			M = " [M]"
			return trim(M)
		if(mode == DRILL_SHOUTING)
			M = " [M]!"
			return trim(M)
		if(mode ==  DRILL_YELLING)
			M = " [M]!!"
			return trim(M)
		if(mode == DRILL_CANADIAN)
			M = " [M]"
			var/list/canadian_words = strings("canadian_replacement.json", "canadian")

			for(var/key in canadian_words)
				var/value = canadian_words[key]
				if(islist(value))
					value = pick(value)

				M = replacetextEx(M, " [uppertext(key)]", " [uppertext(value)]")
				M = replacetextEx(M, " [capitalize(key)]", " [capitalize(value)]")
				M = replacetextEx(M, " [key]", " [value]")

			if(prob(30))
				M += pick(", eh?", ", EH?")
		return trim(M)

/obj/item/clothing/head/beret/corpwarden
	name = "corporate warden beret"
	desc = "A special black beret with a Warden's insignia in the middle. This one is commonly warn by wardens of the corporation."
	icon_state = "beret_corporate_warden"
	armor = list(melee = 40, bullet = 30, laser = 30, energy = 30, bomb = 25, bio = 0, rad = 0, fire = 30, acid = 60)
	strip_delay = 60

/obj/item/clothing/head/beret/sec
	name = "security beret"
	desc = "A robust beret with the security insignia emblazoned on it. Uses reinforced fabric to offer sufficient protection."
	icon_state = "beret_badge"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30,"energy" = 30, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 20, "acid" = 50)
	strip_delay = 60
	dog_fashion = null

/obj/item/clothing/head/beret/corpsec
	name = "corporate security beret"
	desc = "A special black beret for the mundane life of a corporate security officer."
	icon_state = "beret_corporate_officer"
	armor = list(melee = 40, bullet = 30, laser = 30,energy = 30, bomb = 25, bio = 0, rad = 0, fire = 20, acid = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyhos
	name = "head of security's beret"
	desc = "A special beret with the Head of Security's insignia emblazoned on it. A symbol of excellence, a badge of courage, a mark of distinction."
	icon_state = "hosberet"

/obj/item/clothing/head/beret/sec/navywarden
	name = "warden's beret"
	desc = "A special beret with the Warden's insignia emblazoned on it. For wardens with class."
	icon_state = "wardenberet"
	armor = list("melee" = 40, "bullet" = 30, "laser" = 30, "energy" = 10, "bomb" = 25, "bio" = 0, "rad" = 0, "fire" = 30, "acid" = 50)
	strip_delay = 60

/obj/item/clothing/head/beret/sec/navyofficer
	desc = "A special beret with the security insignia emblazoned on it. For officers with class."
	icon_state = "officerberet"

//Curator
/obj/item/clothing/head/fedora/curator
	name = "treasure hunter's fedora"
	desc = "You got red text today kid, but it doesn't mean you have to like it."
	icon_state = "curator"

/obj/item/clothing/head/beret/eng
	name = "engineering beret"
	desc = "A beret with the engineering insignia emblazoned on it. For engineers that are more inclined towards style than safety."
	icon_state = "beret_engineering"
	armor = list(rad = 10, fire = 10)
	strip_delay = 60

/obj/item/clothing/head/beret/atmos
	name = "atmospherics beret"
	desc = "A beret for those who have shown immaculate proficienty in piping. Or plumbing."
	icon_state = "beret_atmospherics"
	armor = list(rad = 10, fire = 10)
	strip_delay = 60

/obj/item/clothing/head/beret/ce
	name = "chief engineer beret"
	desc = "A white beret with the engineering insignia emblazoned on it. Its owner knows what they're doing. Probably."
	icon_state = "beret_ce"
	armor = list(rad = 20, fire = 30)
	strip_delay = 60

/obj/item/clothing/head/beret/sci
	name = "science beret"
	desc = "A purple beret with the science insignia emblazoned on it. It has that authentic burning plasma smell."
	icon_state = "beret_sci"
	armor = list(bomb = 5, bio = 5, fire = 5, acid = 10)
	strip_delay = 60

/obj/item/clothing/head/beret/supply
	name = "supply beret"
	desc = "A brown beret with the supply insignia emblazoned on it. You can't help but wonder how much it'd sell for."
	icon_state = "beret_supply"
	armor = list(rad = 10, fire = 10)
	strip_delay = 60

//Medical
/obj/item/clothing/head/beret/med
	name = "medical beret"
	desc = "A white beret with a blue cross finely threaded into it. It has that sterile smell about it."
	icon_state = "beret_med"
	armor = list(bio = 20)
	strip_delay = 60

/obj/item/clothing/head/beret/cmo
	name = "chief medical officer beret"
	desc = "A baby blue beret with the insignia of Medistan. It smells very sterile."
	icon_state = "beret_cmo"
	armor = list(bio = 30, acid = 20)
	strip_delay = 60

//Centcom
/obj/item/clothing/head/beret/cccaptain
	name = "central command captain beret"
	desc = "A pure white beret with a Captain insignia of Central Command."
	icon_state = "beret_centcom_captain"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80)
	strip_delay = 120

/obj/item/clothing/head/beret/ccofficer
	name = "central command officer beret"
	desc = "A black Central Command Officer beret with matching insignia."
	icon_state = "beret_centcom_officer"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80)
	strip_delay = 120

/obj/item/clothing/head/beret/ccofficernavy
	name = "central command naval officer beret"
	desc = "A Navy beret commonly worn by Central Command Naval Officers."
	icon_state = "beret_centcom_officer_navy"
	armor = list(melee = 80, bullet = 80, laser = 80, energy = 80, bomb = 80, bio = 80, rad = 80, fire = 80, acid = 80)
	strip_delay = 120

//For blueshields, but those aren't in so I renamed them to centcom guards
/obj/item/clothing/head/beret/ccguard
	name = "officer beret"
	desc = "A black Centcom guard's beret."
	icon_state = "beret_centcom_officer"
	armor = list(melee = 40, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 5, rad = 5, fire = 5, acid = 30)
	strip_delay = 60

/obj/item/clothing/head/beret/ccguardnavy
	name = "navy officer beret"
	desc = "A navy Centcom guard's beret."
	icon_state = "beret_centcom_officer_navy"
	armor = list(melee = 40, bullet = 20, laser = 10, energy = 10, bomb = 10, bio = 5, rad = 5, fire = 5, acid = 30)
	strip_delay = 60

/obj/item/clothing/head/beret/captain
	name = "captain beret"
	desc = "A lovely blue Captain beret with a gold and white insignia."
	icon_state = "beret_captain"
	armor = list(melee = 50, bullet = 30, laser = 20, energy = 30, bomb = 15, bio = 10, rad = 10, fire = 10, acid = 60)
	strip_delay = 90

#undef DRILL_DEFAULT
#undef DRILL_SHOUTING
#undef DRILL_YELLING
#undef DRILL_CANADIAN
