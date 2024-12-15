
///all the corpses meant as mob drops yes, these definitely could be sorted properly. i invite (you) to do it!!

/obj/effect/mob_spawn/corpse/human/syndicatesoldier
	name = "Syndicate Operative"
	id_job = "Operative"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatesoldiercorpse

/datum/outfit/syndicatesoldiercorpse
	name = "Syndicate Operative Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/old
	head = /obj/item/clothing/head/helmet/swat
	back = /obj/item/storage/backpack
	id = /obj/item/card/id/syndicate

/obj/effect/mob_spawn/corpse/human/syndicatecommando
	name = "Syndicate Commando"
	id_job = "Operative"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatecommandocorpse

/datum/outfit/syndicatecommandocorpse
	name = "Syndicate Commando Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen
	r_pocket = /obj/item/tank/internals/emergency_oxygen
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/corpse/human/syndicatestormtrooper
	name = "Syndicate Stormtrooper"
	id_job = "Operative"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	outfit = /datum/outfit/syndicatestormtroopercorpse

/datum/outfit/syndicatestormtroopercorpse
	name = "Syndicate Stormtrooper Corpse"
	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/syndicate
	back = /obj/item/tank/jetpack/oxygen/harness
	id = /obj/item/card/id/syndicate


/obj/effect/mob_spawn/human/clown/corpse
	skin_tone = "caucasian1"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/obj/effect/mob_spawn/corpse/human/pirate
	name = "Pirate"
	skin_tone = "caucasian1" //all pirates are white because it's easier that way
	outfit = /datum/outfit/piratecorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/piratecorpse
	name = "Pirate Corpse"
	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/jackboots
	glasses = /obj/item/clothing/glasses/eyepatch
	head = /obj/item/clothing/head/costume/pirate/bandana


/obj/effect/mob_spawn/corpse/human/pirate/ranged
	name = "Pirate Gunner"
	outfit = /datum/outfit/piratecorpse/ranged

/datum/outfit/piratecorpse/ranged
	name = "Pirate Gunner Corpse"
	suit = /obj/item/clothing/suit/costume/pirate
	head = /obj/item/clothing/head/costume/pirate


/obj/effect/mob_spawn/corpse/human/russian
	name = "Russian"
	outfit = /datum/outfit/russiancorpse
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/russiancorpse
	name = "Russian Corpse"
	uniform = /obj/item/clothing/under/costume/soviet
	shoes = /obj/item/clothing/shoes/jackboots
	head = /obj/item/clothing/head/costume/bearpelt
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/old



/obj/effect/mob_spawn/corpse/human/russian/ranged
	outfit = /datum/outfit/russiancorpse/ranged

/datum/outfit/russiancorpse/ranged
	name = "Ranged Russian Corpse"
	head = /obj/item/clothing/head/costume/ushanka


/obj/effect/mob_spawn/corpse/human/russian/ranged/trooper
	outfit = /datum/outfit/russiancorpse/ranged/trooper

/datum/outfit/russiancorpse/ranged/trooper
	name = "Ranged Russian Trooper Corpse"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/helmet/alt
	mask = /obj/item/clothing/mask/balaclava


/obj/effect/mob_spawn/corpse/human/russian/ranged/officer
	name = "Russian Officer"
	outfit = /datum/outfit/russiancorpse/officer

/datum/outfit/russiancorpse/officer
	name = "Russian Officer Corpse"
	uniform = /obj/item/clothing/under/costume/russian_officer
	suit = /obj/item/clothing/suit/jacket/officer/tan
	shoes = /obj/item/clothing/shoes/combat
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/costume/ushanka


/obj/effect/mob_spawn/corpse/human/wizard
	name = "Space Wizard Corpse"
	outfit = /datum/outfit/wizardcorpse
	hairstyle = "Bald"
	facial_hairstyle = "Long Beard"
	skin_tone = "caucasian1"

/datum/outfit/wizardcorpse
	name = "Space Wizard Corpse"
	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	head = /obj/item/clothing/head/wizard


/obj/effect/mob_spawn/corpse/human/nanotrasensoldier
	name = "\improper Nanotrasen Private Security Officer"
	id_job = "Private Security Force"
	id_access = JOB_NAME_SECURITYOFFICER
	outfit = /datum/outfit/nanotrasensoldiercorpse2
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"

/datum/outfit/nanotrasensoldiercorpse2
	name = "NT Private Security Officer Corpse"
	uniform = /obj/item/clothing/under/rank/security/officer
	suit = /obj/item/clothing/suit/armor/vest
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	head = /obj/item/clothing/head/helmet/swat/nanotrasen
	back = /obj/item/storage/backpack/security
	id = /obj/item/card/id/job/security_officer

/obj/effect/mob_spawn/corpse/human/cat_butcher
	name = "The Cat Surgeon"
	id_job = "Cat Surgeon"
	id_access_list = list(ACCESS_AWAY_GENERAL, ACCESS_AWAY_MAINT)
	hairstyle = "Cut Hair"
	facial_hairstyle = "Watson Mustache"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/cat_butcher

/datum/outfit/cat_butcher
	name = "Cat Butcher Uniform"
	uniform = /obj/item/clothing/under/rank/medical/doctor/green
	suit = /obj/item/clothing/suit/apron/surgical
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex/nitrile
	ears = /obj/item/radio/headset
	back = /obj/item/storage/backpack/satchel/med
	id = /obj/item/card/id
	glasses = /obj/item/clothing/glasses/hud/health

/obj/effect/mob_spawn/corpse/human/bee_terrorist
	name = "BLF Operative"
	outfit = /datum/outfit/bee_terrorist

/datum/outfit/bee_terrorist
	name = "BLF Operative"
	uniform = /obj/item/clothing/under/color/yellow
	suit = /obj/item/clothing/suit/hooded/bee_costume
	shoes = /obj/item/clothing/shoes/sneakers/yellow
	gloves = /obj/item/clothing/gloves/color/yellow
	ears = /obj/item/radio/headset
	belt = /obj/item/storage/belt/fannypack/yellow/bee_terrorist
	id = /obj/item/card/id
	l_pocket = /obj/item/paper/fluff/bee_objectives
	mask = /obj/item/clothing/mask/rat/bee

/obj/effect/mob_spawn/corpse/human/psychost
	name = "Psycho"
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	skin_tone = "caucasian1"
	brute_damage = 100
	outfit = /datum/outfit/straightjacket

/datum/outfit/straightjacket
	name = "Straight jacket"
	suit = /obj/item/clothing/suit/jacket/straight_jacket

/obj/effect/mob_spawn/corpse/human/psychost/muzzle
	name = "Muzzled psycho"
	outfit = /datum/outfit/straightmuz

/datum/outfit/straightmuz
	name = "Straight jacket and a muzzle"
	suit = /obj/item/clothing/suit/jacket/straight_jacket
	mask = /obj/item/clothing/mask/muzzle

/obj/effect/mob_spawn/corpse/human/psychost/trap
	name = "Trapped psycho"
	outfit = /datum/outfit/straighttrap

/datum/outfit/straighttrap
	name = "Straight jacket and a reverse bear trap"
	suit = /obj/item/clothing/suit/jacket/straight_jacket
	head = /obj/item/reverse_bear_trap

/obj/effect/mob_spawn/corpse/human/zombie
	name = "zombie"
	mob_species = /datum/species/zombie
	brute_damage = 100

/obj/effect/mob_spawn/corpse/human/sniper
	name = "Sniper"
	outfit = /datum/outfit/sniper
	skin_tone = "caucasian1"
	hairstyle = "Bald"
	id_job = JOB_NAME_WARDEN

/datum/outfit/sniper
	name = "Sniper"
	uniform = /obj/item/clothing/under/syndicate/camo
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/military/assault
	mask = /obj/item/clothing/mask/cigarette/cigar
	head = /obj/item/clothing/head/beret/corpwarden
	glasses = /obj/item/clothing/glasses/hud/security/sunglasses/eyepatch
	back = /obj/item/storage/backpack/satchel/sec
	id = /obj/item/card/id/job/warden

/obj/effect/mob_spawn/corpse/human/heavy
	name = "Heavy gunner"
	brute_damage = 300
	hairstyle = "Bald"
	facial_hairstyle = "Shaved"
	skin_tone = "caucasian1"
	outfit = /datum/outfit/minigunheavy

/datum/outfit/minigunheavy
	name = "Heavy gunner"
	uniform = /obj/item/clothing/under/rank/security/head_of_security/alt
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat/emagged
	suit = /obj/item/clothing/suit/armor/heavy
	//back = /obj/item/minigunpack - you REALLY wish you could snag a minigun backpack off them don't you?
	head = /obj/item/clothing/head/helmet/swat
