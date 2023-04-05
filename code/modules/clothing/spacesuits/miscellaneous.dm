//miscellaneous spacesuits
/*
Contains:
 - Captain's spacesuit
 - Death squad's hardsuit
 - SWAT suit
 - Officer's beret/spacesuit
 - NASA Voidsuit
 - Father Christmas' magical clothes
 - Pirate's spacesuit
 - ERT hardsuit: command, sec, engi, med, janitor
 - EVA spacesuit
 - Freedom's spacesuit (freedom from vacuum's oppression)
 - Carp hardsuit
 - Bounty hunter hardsuit
 - Emergency skinsuit
*/

	//Death squad armored space suits, not hardsuits!
/obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	name = "MK.III SWAT Helmet"
	desc = "An advanced tactical space helmet."
	icon_state = "deathsquad"
	item_state = "deathsquad"
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/deathsquad/attack_self(mob/user)
	return

/obj/item/clothing/suit/space/hardsuit/deathsquad
	name = "MK.III SWAT Suit"
	desc = "A prototype designed to replace the ageing MK.II SWAT suit. Based on the streamlined MK.II model, the traditional ceramic and graphene plate construction was replaced with plasteel, allowing superior armor against most threats. There's room for some kind of energy projection device on the back."
	icon_state = "deathsquad"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/deathsquad
	dog_fashion = /datum/dog_fashion/back/deathsquad
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

	//NEW SWAT suit
/obj/item/clothing/suit/space/swat
	name = "MK.I SWAT Suit"
	desc = "A tactical space suit first developed in a joint effort by the defunct IS-ERI and Nanotrasen in 20XX for military space operations. A tried and true workhorse, it is very difficult to move in but offers robust protection against all threats!"
	icon_state = "heavy"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(MELEE = 40,  BULLET = 30, LASER = 30, ENERGY = 30, BOMB = 50, BIO = 90, RAD = 20, FIRE = 100, ACID = 100, STAMINA = 60)
	strip_delay = 120
	resistance_flags = FIRE_PROOF | ACID_PROOF
	move_sound = list('sound/effects/suitstep1.ogg', 'sound/effects/suitstep2.ogg')

/obj/item/clothing/head/helmet/space/beret
	name = "officer's beret"
	desc = "An armored beret commonly used by special operations officers. Uses advanced force field technology to protect the head from space."
	icon_state = "dsberet"
	dynamic_hair_suffix = "+generic"
	dynamic_fhair_suffix = "+generic"
	flags_inv = 0
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/suit/space/officer
	name = "officer's jacket"
	desc = "An armored, space-proof jacket used in special operations."
	icon_state = "specops"
	item_state = "specops"
	blood_overlay_type = "coat"
	slowdown = 0
	flags_inv = 0
	w_class = WEIGHT_CLASS_NORMAL
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 80,  BULLET = 80, LASER = 50, ENERGY = 50, BOMB = 100, BIO = 100, RAD = 100, FIRE = 100, ACID = 100, STAMINA = 100)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF | ACID_PROOF

	//NASA Voidsuit
/obj/item/clothing/head/helmet/space/nasavoid
	name = "NASA Void Helmet"
	desc = "An old, NASA CentCom branch designed, dark red space suit helmet."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid
	name = "NASA Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "An old, NASA CentCom branch designed, dark red space suit."
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

/obj/item/clothing/head/helmet/space/nasavoid/old
	name = "Engineering Void Helmet"
	desc = "A CentCom engineering dark red space suit helmet. While old and dusty, it still gets the job done."
	icon_state = "void"
	item_state = "void"

/obj/item/clothing/suit/space/nasavoid/old
	name = "Engineering Voidsuit"
	icon_state = "void"
	item_state = "void"
	desc = "A CentCom engineering dark red space suit. Age has degraded the suit making is difficult to move around in."
	slowdown = 4
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)

	//Space santa outfit suit
/obj/item/clothing/head/helmet/space/santahat
	name = "Santa's hat"
	desc = "Ho ho ho. Merrry X-mas!"
	icon_state = "santahat"
	flags_cover = HEADCOVERSEYES

	dog_fashion = /datum/dog_fashion/head/santa

/obj/item/clothing/suit/space/santa
	name = "Santa's suit"
	desc = "Festive!"
	icon_state = "santa"
	item_state = "santa"
	slowdown = 0
	allowed = list(/obj/item) //for stuffing exta special presents


	//Space pirate outfit
/obj/item/clothing/head/helmet/space/pirate
	name = "pirate hat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	armor = list(MELEE = 30,  BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75, STAMINA = 20)
	flags_inv = HIDEHAIR
	strip_delay = 40
	equip_delay_other = 20
	flags_cover = HEADCOVERSEYES

/obj/item/clothing/head/helmet/space/pirate/bandana
	name = "pirate bandana"
	icon_state = "bandana"
	item_state = "bandana"

/obj/item/clothing/suit/space/pirate
	name = "pirate coat"
	desc = "Yarr."
	icon_state = "pirate"
	item_state = "pirate"
	w_class = WEIGHT_CLASS_NORMAL
	flags_inv = 0
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/melee/transforming/energy/sword/pirate, /obj/item/clothing/glasses/eyepatch, /obj/item/reagent_containers/food/drinks/bottle/rum)
	slowdown = 0
	armor = list(MELEE = 30,  BULLET = 50, LASER = 30, ENERGY = 15, BOMB = 30, BIO = 30, RAD = 30, FIRE = 60, ACID = 75, STAMINA = 20)
	strip_delay = 40
	equip_delay_other = 20

	//Emergency Response Team suits
/obj/item/clothing/head/helmet/space/hardsuit/ert
	name = "emergency response team commander helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has blue highlights."
	icon_state = "hardsuit0-ert_commander"
	item_state = "hardsuit0-ert_commander"
	armor = list(MELEE = 65,  BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80, STAMINA = 70)
	strip_delay = 130
	light_range = 7
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list(
		/datum/action/item_action/toggle_helmet_light,
		/datum/action/item_action/toggle_beacon_hud
	)
	var/beacon_colour = "#4b48ec"

/obj/item/clothing/head/helmet/space/hardsuit/ert/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)
	//Link
	if(istype(loc, /obj/item/clothing/suit/space/hardsuit/ert))
		var/obj/linkedsuit = loc
		//NOTE FOR COPY AND PASTING: BEACON MUST BE MADE FIRST
		//Add the monitor (Default to null - No tracking)
		var/datum/component/tracking_beacon/component_beacon = linkedsuit.AddComponent(/datum/component/tracking_beacon, "cent", null, null, TRUE, beacon_colour)
		//Add the monitor (Default to null - No tracking)
		component_beacon.attached_monitor = AddComponent(/datum/component/team_monitor, "cent", null, component_beacon)
	else
		AddComponent(/datum/component/team_monitor, "cent", null)

/obj/item/clothing/head/helmet/space/hardsuit/ert/ui_action_click(mob/user, datum/action)
	switch(action.type)
		if(/datum/action/item_action/toggle_helmet_light)
			toggle_helmlight()
		if(/datum/action/item_action/toggle_beacon_hud)
			toggle_hud(user)

/obj/item/clothing/head/helmet/space/hardsuit/ert/proc/toggle_hud(mob/user)
	var/datum/component/team_monitor/monitor = GetComponent(/datum/component/team_monitor)
	if(!monitor)
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
		return
	monitor.toggle_hud(!monitor.hud_visible, user)
	if(monitor.hud_visible)
		to_chat(user, "<span class='notice'>You toggle the heads up display of your suit.</span>")
	else
		to_chat(user, "<span class='warning'>You disable the heads up display of your suit.</span>")

/obj/item/clothing/suit/space/hardsuit/ert
	name = "emergency response team commander hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has blue highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_command"
	item_state = "ert_command"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 65,  BULLET = 50, LASER = 50, ENERGY = 50, BOMB = 50, BIO = 100, RAD = 100, FIRE = 80, ACID = 80, STAMINA = 70)
	slowdown = 0
	strip_delay = 130
	resistance_flags = FIRE_PROOF
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	jetpack = /obj/item/tank/jetpack/suit
	actions_types = list(
		/datum/action/item_action/toggle_helmet,
		/datum/action/item_action/toggle_beacon,
		/datum/action/item_action/toggle_beacon_frequency
	)

/obj/item/clothing/suit/space/hardsuit/ert/ui_action_click(mob/user, datum/actiontype)
	switch(actiontype.type)
		if(/datum/action/item_action/toggle_helmet)
			ToggleHelmet()
		if(/datum/action/item_action/toggle_beacon)
			toggle_beacon(user)
		if(/datum/action/item_action/toggle_beacon_frequency)
			set_beacon_freq(user)

/obj/item/clothing/suit/space/hardsuit/ert/proc/toggle_beacon(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
		return
	beacon.toggle_visibility(!beacon.visible)
	if(beacon.visible)
		to_chat(user, "<span class='notice'>You enable the tracking beacon on [src]. Anybody on the same frequency will now be able to track your location.</span>")
	else
		to_chat(user, "<span class='warning'>You disable the tracking beacon on [src].</span>")

/obj/item/clothing/suit/space/hardsuit/ert/proc/set_beacon_freq(mob/user)
	var/datum/component/tracking_beacon/beacon = GetComponent(/datum/component/tracking_beacon)
	if(!beacon)
		to_chat(user, "<span class='notice'>The suit is not fitted with a tracking beacon.</span>")
		return
	beacon.change_frequency(user)

	//ERT Security
/obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	name = "emergency response team security helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has red highlights."
	icon_state = "hardsuit0-ert_security"
	item_state = "hardsuit0-ert_security"
	beacon_colour = "#ec4848"

/obj/item/clothing/suit/space/hardsuit/ert/sec
	name = "emergency response team security hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has red highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_security"
	item_state = "ert_security"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/sec
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Engineering
/obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	name = "emergency response team engineering helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has orange highlights."
	icon_state = "hardsuit0-ert_engineer"
	item_state = "hardsuit0-ert_engineer"
	beacon_colour = "#ecaa48"

/obj/item/clothing/suit/space/hardsuit/ert/engi
	name = "emergency response team engineering hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has orange highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_engineer"
	item_state = "ert_engineer"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/engi
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Medical
/obj/item/clothing/head/helmet/space/hardsuit/ert/med
	name = "emergency response team medical helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has white highlights."
	icon_state = "hardsuit0-ert_medical"
	item_state = "hardsuit0-ert_medical"
	beacon_colour = "#88ecec"

/obj/item/clothing/suit/space/hardsuit/ert/med
	name = "emergency response team medical hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has white highlights. Offers superb protection against environmental hazards."
	icon_state = "ert_medical"
	item_state = "ert_medical"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/med
	jetpack = /obj/item/tank/jetpack/suit

	//ERT Janitor
/obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	name = "emergency response team janitorial helmet"
	desc = "The integrated helmet of an ERT hardsuit, this one has purple highlights."
	icon_state = "hardsuit0-ert_janitor"
	item_state = "hardsuit0-ert_janitor"
	beacon_colour = "#be43ce"

/obj/item/clothing/suit/space/hardsuit/ert/jani
	name = "emergency response team janitorial hardsuit"
	desc = "The standard issue hardsuit of the ERT, this one has purple highlights. Offers superb protection against environmental hazards. This one has extra clips for holding various janitorial tools."
	icon_state = "ert_janitor"
	item_state = "ert_janitor"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/jani
	allowed = list(/obj/item/storage/bag/trash, /obj/item/melee/flyswatter, /obj/item/mop, /obj/item/holosign_creator/janibarrier, /obj/item/reagent_containers/glass/bucket, /obj/item/reagent_containers/spray/chemsprayer/janitor)

/obj/item/clothing/suit/space/eva
	name = "EVA suit"
	icon_state = "space"
	item_state = "eva_suit"
	desc = "A lightweight space suit with the basic ability to protect the wearer from the vacuum of space during emergencies."
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 20, FIRE = 50, ACID = 65, STAMINA = 0)

/obj/item/clothing/head/helmet/space/eva
	name = "EVA helmet"
	icon_state = "space"
	item_state = "eva_helmet"
	desc = "A lightweight space helmet with the basic ability to protect the wearer from the vacuum of space during emergencies."
	flash_protect = 0
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 20, FIRE = 50, ACID = 65, STAMINA = 0)

/obj/item/clothing/head/helmet/space/freedom
	name = "eagle helmet"
	desc = "An advanced, space-proof helmet. It appears to be modeled after an old-world eagle."
	icon_state = "griffinhat"
	item_state = "griffinhat"
	armor = list(MELEE = 20,  BULLET = 40, LASER = 30, ENERGY = 25, BOMB = 100, BIO = 100, RAD = 100, FIRE = 80, ACID = 80, STAMINA = 10)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF

/obj/item/clothing/suit/space/freedom
	name = "eagle suit"
	desc = "An advanced, light suit, fabricated from a mixture of synthetic feathers and space-resistant material. A gun holster appears to be integrated into the suit and the wings appear to be stuck in 'freedom' mode."
	icon_state = "freedom"
	item_state = "freedom"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals)
	armor = list(MELEE = 20,  BULLET = 40, LASER = 30, ENERGY = 25, BOMB = 100, BIO = 100, RAD = 100, FIRE = 80, ACID = 80, STAMINA = 10)
	strip_delay = 130
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = ACID_PROOF | FIRE_PROOF
	slowdown = 0

//Carpsuit, bestsuit, lovesuit
/obj/item/clothing/head/helmet/space/hardsuit/carp
	name = "carp helmet"
	desc = "Spaceworthy and it looks like a space carp's head, smells like one too."
	icon_state = "carp_helm"
	item_state = "syndicate"
	armor = list(MELEE = 20,  BULLET = 10, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 75, FIRE = 60, ACID = 75, STAMINA = 40)
	light_system = NO_LIGHT_SUPPORT
	light_range = 0 //luminosity when on
	actions_types = list()

/obj/item/clothing/head/helmet/space/hardsuit/carp/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, LOCKED_HELMET_TRAIT)

/obj/item/clothing/suit/space/hardsuit/carp
	name = "carp space suit"
	desc = "A slimming piece of dubious space carp technology."
	icon_state = "carp_suit"
	item_state = "space_suit_syndicate"
	slowdown = 0	//Space carp magic, never stop believing
	armor = list(MELEE = 20,  BULLET = 10, LASER = 20, ENERGY = 20, BOMB = 30, BIO = 100, RAD = 75, FIRE = 60, ACID = 75, STAMINA = 40)
	allowed = list(/obj/item/tank/internals, /obj/item/pneumatic_cannon/speargun, /obj/item/toy/plush/carpplushie/dehy_carp, /obj/item/toy/plush/carpplushie, /obj/item/reagent_containers/food/snacks/carpmeat)	//I'm giving you a hint here
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp

/obj/item/clothing/head/helmet/space/hardsuit/carp/equipped(mob/living/carbon/human/user, slot)
	..()
	if (slot == ITEM_SLOT_HEAD)
		user.faction |= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/dropped(mob/living/carbon/human/user)
	..()
	if (user.head == src)
		user.faction -= "carp"

/obj/item/clothing/head/helmet/space/hardsuit/carp/old
	name = "battered carp helmet"
	desc = "It's covered in bite marks and scratches, yet seems to be still perfectly functional."
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 80, ACID = 70, STAMINA = 10)

/obj/item/clothing/suit/space/hardsuit/carp/old
	name = "battered carp space suit"
	desc = "It's covered in bite marks and scratches, yet seems to be still perfectly functional."
	slowdown = 1
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 100, RAD = 50, FIRE = 80, ACID = 70, STAMINA = 10)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals, /obj/item/multitool)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/carp/old

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	name = "paranormal response team helmet"
	desc = "A helmet worn by those who deal with paranormal threats for a living."
	icon_state = "hardsuit0-prt"
	item_state = "hardsuit0-prt"
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	actions_types = list()
	resistance_flags = FIRE_PROOF
	beacon_colour = "#9ddb56"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal
	name = "paranormal response team hardsuit"
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats."
	icon_state = "knight_grey"
	item_state = "knight_grey"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal
	max_heat_protection_temperature = FIRE_IMMUNITY_MAX_TEMP_PROTECT
	resistance_flags = FIRE_PROOF

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, TRUE, TRUE)

//Lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland
	desc = "Powerful wards are built into this hardsuit, protecting the user from all manner of paranormal threats with armor designed specifically for low pressures."
	high_pressure_multiplier = 0.4

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland
	high_pressure_multiplier = 0.4

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "champion's hardsuit"
	desc = "Voices echo from the hardsuit, driving the user insane."
	icon_state = "hardsuit-beserker"
	item_state = "hardsuit-beserker"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/beserker
	name = "champion's helmet"
	desc = "Peering into the eyes of the helmet is enough to seal damnation."
	icon_state = "hardsuit0-beserker"
	item_state = "hardsuit0-beserker"

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	item_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/lavaland/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	item_state = "hardsuit0-inq"

//End lavaland suits

/obj/item/clothing/suit/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's hardsuit"
	icon_state = "hardsuit-inq"
	item_state = "hardsuit-inq"
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor

/obj/item/clothing/head/helmet/space/hardsuit/ert/paranormal/inquisitor
	name = "inquisitor's helmet"
	icon_state = "hardsuit0-inq"
	item_state = "hardsuit0-inq"

/obj/item/clothing/head/helmet/space/fragile
	name = "emergency space helmet"
	desc = "A bulky, air-tight helmet meant to protect the user during emergency situations. It doesn't look very durable."
	icon_state = "syndicate-helm-orange"
	item_state = "syndicate-helm-orange"
	armor = list(MELEE = 5,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 10, FIRE = 0, ACID = 0, STAMINA = 0)
	strip_delay = 65
	flash_protect = 0

/obj/item/clothing/suit/space/fragile
	name = "emergency space suit"
	desc = "A bulky, air-tight suit meant to protect the user during emergency situations. It doesn't look very durable."
	var/torn = FALSE
	icon_state = "syndicate-orange"
	item_state = "syndicate-orange"
	slowdown = 2
	armor = list(MELEE = 5,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 10, FIRE = 0, ACID = 0, STAMINA = 0)
	strip_delay = 65
	w_class = WEIGHT_CLASS_NORMAL

/obj/item/clothing/suit/space/fragile/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", final_block_chance = 0, damage = 0, attack_type = MELEE_ATTACK)
	if(!torn && prob(50))
		to_chat(owner, "<span class='warning'>\The [src] tears from the damage, breaking the air-tight seal!</span>")
		clothing_flags &= ~STOPSPRESSUREDAMAGE
		name = "torn [src]"
		desc = "A bulky suit meant to protect the user during emergency situations, at least until someone tore a hole in the suit."
		torn = TRUE
		playsound(loc, 'sound/weapons/slashmiss.ogg', 50, 1)
		playsound(loc, 'sound/effects/refill.ogg', 50, 1)

/obj/item/clothing/suit/space/hunter
	name = "bounty hunting suit"
	desc = "A custom version of the MK.II SWAT suit, modified to look rugged and tough. Works as a space suit, if you can find a helmet."
	icon_state = "hunter"
	item_state = "swat_suit"
	allowed = list(/obj/item/gun, /obj/item/ammo_box, /obj/item/ammo_casing, /obj/item/melee/baton, /obj/item/restraints/handcuffs, /obj/item/tank/internals, /obj/item/kitchen/knife/combat)
	armor = list(melee = 60, bullet = 40, laser = 40, energy = 50, bomb = 100, bio = 100, rad = 100, fire = 100, acid = 100, stamina = 70)
	strip_delay = 130
	resistance_flags = FIRE_PROOF | ACID_PROOF

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit
	name = "skinsuit helmet"
	icon = 'icons/obj/clothing/hats.dmi'
	worn_icon = 'icons/mob/clothing/head.dmi'
	icon_state = "skinsuit_helmet"
	item_state = "skinsuit_helmet"
	max_integrity = 200
	desc = "An airtight helmet meant to protect the wearer during emergency situations."
	permeability_coefficient = 0.01
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 20, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	min_cold_protection_temperature = EMERGENCY_HELM_MIN_TEMP_PROTECT
	heat_protection = NONE
	flash_protect = 0
	bang_protect = 0
	flags_inv = HIDEMASK|HIDEEARS|HIDEEYES|HIDEHAIR|HIDEFACIALHAIR
	clothing_flags = STOPSPRESSUREDAMAGE | SNUG_FIT
	max_heat_protection_temperature = 100
	actions_types = null

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/attack_self(mob/user)
	return

/obj/item/clothing/head/helmet/space/hardsuit/skinsuit/emp_act(severity)
	return

/obj/item/clothing/suit/space/hardsuit/skinsuit
	name = "skinsuit"
	desc = "A slim, compression-based spacesuit meant to protect the user during emergency situations. It's only a little warmer than your uniform."
	icon = 'icons/obj/clothing/suits.dmi'
	worn_icon = 'icons/mob/clothing/suit.dmi'
	icon_state = "skinsuit"
	item_state = "s_suit"
	max_integrity = 200
	slowdown = 3 //Higher is slower
	clothing_flags = STOPSPRESSUREDAMAGE
	gas_transfer_coefficient = 0.5
	permeability_coefficient = 0.5
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 0, BIO = 10, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 0)
	allowed = list(/obj/item/flashlight, /obj/item/tank/internals)
	min_cold_protection_temperature = EMERGENCY_SUIT_MIN_TEMP_PROTECT
	heat_protection = NONE
	max_heat_protection_temperature = 100
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/skinsuit

/obj/item/clothing/suit/space/hardsuit/skinsuit/attackby(obj/item/I, mob/user, params)
	return

/obj/item/clothing/head/helmet/space/hunter
	name = "bounty hunting helmet"
	desc = "A custom tactical space helmet with decals added."
	icon_state = "hunter"
	item_state = "hunter"
	resistance_flags = FIRE_PROOF | ACID_PROOF
	armor = list(MELEE = 5,  BULLET = 5, LASER = 5, ENERGY = 0, BOMB = 0, BIO = 0, RAD = 0, FIRE = 0, ACID = 0, STAMINA = 20)
