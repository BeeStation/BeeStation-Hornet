//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldstation
	name = "old cryogenics pod"
	desc = "A humming cryo pod. You can barely recognise a uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an ancient crewman"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper"
	roundstart = FALSE
	death = FALSE
	random = TRUE
	mob_species = /datum/species/human
	short_desc = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	flavour_text = "You vaguely recall rushing into a cryogenics pod due to an oncoming radiation storm. \
		The last thing you remember is the station's Artificial Program telling you that you would only be asleep for eight hours. \
		As you open your eyes, everything seems rusted and broken, a dark feeling swells in your gut as you climb out of your pod. \
		Work as a team with your fellow survivors and do not abandon them."
	assignedrole = "Ancient Crew"
	use_cooldown = TRUE
	banType = ROLE_ANCIENT_CREW

/obj/effect/mob_spawn/human/oldstation/Destroy()
	new/obj/structure/showcase/machinery/oldpod/used(drop_location())
	return ..()

//Ancient cryogenic sleepers. Players become NT crewmen from a hundred year old space station, now on the verge of collapse.
/obj/effect/mob_spawn/human/oldstation/sec
	desc = "A humming cryo pod. You can barely recognise a security uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a security officer"
	short_desc = "You are a security officer working for Nanotrasen, stationed onboard a state of the art research station."
	outfit = /datum/outfit/oldsec

/datum/outfit/oldsec
	name = "Ancient Security"
	id = /obj/item/card/id/away/old/sec
	uniform = /obj/item/clothing/under/rank/security/officer
	shoes = /obj/item/clothing/shoes/jackboots
	l_pocket = /obj/item/assembly/flash/handheld
	r_pocket = /obj/item/restraints/handcuffs

/obj/effect/mob_spawn/human/oldstation/eng
	desc = "A humming cryo pod. You can barely recognise an engineering uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "an engineer"
	short_desc = "You are an engineer working for Nanotrasen, stationed onboard a state of the art research station."
	outfit = /datum/outfit/oldeng

/datum/outfit/oldeng
	name = "Ancient Engineer"
	id = /obj/item/card/id/away/old/eng
	uniform = /obj/item/clothing/under/rank/engineering/engineer
	gloves = /obj/item/clothing/gloves/color/fyellow/old
	shoes = /obj/item/clothing/shoes/workboots
	l_pocket = /obj/item/tank/internals/emergency_oxygen

/datum/outfit/oldeng/mod
	name = "Ancient Engineer (MODsuit)"
	suit_store = /obj/item/tank/internals/oxygen
	back = /obj/item/mod/control/pre_equipped/prototype
	mask = /obj/item/clothing/mask/breath
	internals_slot = ITEM_SLOT_SUITSTORE

/obj/effect/mob_spawn/human/oldstation/sci
	desc = "A humming cryo pod. You can barely recognise a science uniform underneath the built up ice. The machine is attempting to wake up its occupant."
	mob_name = "a scientist"
	short_desc = "You are a scientist working for Nanotrasen, stationed onboard a state of the art research station."
	outfit = /datum/outfit/oldsci

/datum/outfit/oldsci
	name = "Ancient Scientist"
	id = /obj/item/card/id/away/old/sci
	uniform = /obj/item/clothing/under/rank/rnd/scientist
	shoes = /obj/item/clothing/shoes/laceup
	l_pocket = /obj/item/stack/medical/bruise_pack

//Space Hotel Staff
/obj/effect/mob_spawn/human/hotel_staff //not free antag u little shits
	name = "staff sleeper"
	desc = "A sleeper designed for long-term stasis between guest visits."
	mob_name = "hotel staff member"
	icon = 'icons/obj/machines/sleeper.dmi'
	icon_state = "sleeper_s"
	objectives = "Cater to visiting guests with your fellow staff. Do not leave your assigned hotel and always remember: The customer is always right!"
	death = FALSE
	roundstart = FALSE
	random = TRUE
	outfit = /datum/outfit/hotelstaff
	short_desc = "You are a staff member of a top-of-the-line space hotel!"
	flavour_text = "You are a staff member of a top-of-the-line space hotel! Cater to guests and make sure the manager doesn't fire you."
	important_info = "DON'T leave the hotel"
	assignedrole = "Hotel Staff"
	use_cooldown = TRUE
	banType = ROLE_HOTEL_STAFF

/datum/outfit/hotelstaff
	name = "Hotel Staff"
	uniform = /obj/item/clothing/under/misc/assistantformal
	shoes = /obj/item/clothing/shoes/laceup
	r_pocket = /obj/item/radio/off
	back = /obj/item/storage/backpack
	implants = list(/obj/item/implant/mindshield, /obj/item/implant/exile/hotel)

/obj/effect/mob_spawn/human/hotel_staff/security
	name = "hotel security sleeper"
	mob_name = "hotel security member"
	outfit = /datum/outfit/hotelstaff/security
	short_desc = "You are a peacekeeper."
	flavour_text = "You have been assigned to this hotel to protect the interests of the company while keeping the peace between \
		guests and the staff."
	important_info = "Do NOT leave the hotel, as that is grounds for contract termination."
	objectives = "Do not leave your assigned hotel. Try and keep the peace between staff and guests, non-lethal force heavily advised if possible."

/datum/outfit/hotelstaff/security
	name = "Hotel Security"
	uniform = /obj/item/clothing/under/rank/security/officer/blueshirt
	shoes = /obj/item/clothing/shoes/jackboots
	suit = /obj/item/clothing/suit/armor/vest/blueshirt
	head = /obj/item/clothing/head/helmet/blueshirt
	back = /obj/item/storage/backpack/security
	belt = /obj/item/storage/belt/security/full

/obj/effect/mob_spawn/human/hotel_staff/Destroy()
	new/obj/structure/fluff/empty_sleeper/syndicate(get_turf(src))
	..()
