/datum/outfit/space
	name = "Standard Space Gear"

	uniform = /obj/item/clothing/under/color/grey
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/space
	head = /obj/item/clothing/head/helmet/space
	back = /obj/item/tank/jetpack/oxygen
	mask = /obj/item/clothing/mask/breath

/datum/outfit/tournament
	name = "tournament standard red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/black
	suit = /obj/item/clothing/suit/armor/vest
	head = /obj/item/clothing/head/helmet/thunderdome
	r_hand = /obj/item/gun/energy/pulse/destroyer
	l_hand = /obj/item/kitchen/knife
	r_pocket = /obj/item/grenade/smokebomb

/datum/outfit/tournament/green
	name = "tournament standard green"

	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament/gangster
	name = "tournament gangster"

	uniform = /obj/item/clothing/under/rank/det
	suit = /obj/item/clothing/suit/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle
	head = /obj/item/clothing/head/fedora/det_hat
	r_hand = /obj/item/gun/ballistic
	l_hand = null
	r_pocket = /obj/item/ammo_box/c10mm

/datum/outfit/tournament/janitor
	name = "tournament janitor"

	uniform = /obj/item/clothing/under/rank/janitor
	back = /obj/item/storage/backpack
	suit = null
	head = null
	r_hand = /obj/item/mop
	l_hand = /obj/item/reagent_containers/glass/bucket
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	backpack_contents = list(/obj/item/stack/tile/plasteel=6)

/datum/outfit/tournament/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/reagent_containers/glass/bucket/bucket = H.get_item_for_held_index(1)
	bucket.reagents.add_reagent(/datum/reagent/water,70)

/datum/outfit/laser_tag
	name = "Laser Tag Red"

	uniform = /obj/item/clothing/under/color/red
	shoes = /obj/item/clothing/shoes/sneakers/red
	head = /obj/item/clothing/head/helmet/redtaghelm
	gloves = /obj/item/clothing/gloves/color/red
	ears = /obj/item/radio/headset
	suit = /obj/item/clothing/suit/redtag
	back = /obj/item/storage/backpack
	suit_store = /obj/item/gun/energy/laser/redtag
	backpack_contents = list(/obj/item/storage/box=1)

/datum/outfit/laser_tag/blue
	name = "Laser Tag Blue"
	uniform = /obj/item/clothing/under/color/blue
	shoes = /obj/item/clothing/shoes/sneakers/blue
	head = /obj/item/clothing/head/helmet/bluetaghelm
	gloves = /obj/item/clothing/gloves/color/blue
	suit = /obj/item/clothing/suit/bluetag
	suit_store = /obj/item/gun/energy/laser/bluetag

/datum/outfit/pirate
	name = "Space Pirate"

	uniform = /obj/item/clothing/under/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/pirate
	head = /obj/item/clothing/head/bandana
	glasses = /obj/item/clothing/glasses/eyepatch

/datum/outfit/pirate/space
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen
	ears = /obj/item/radio/headset/syndicate
	id = /obj/item/card/id

/datum/outfit/pirate/space/captain
	head = /obj/item/clothing/head/helmet/space/pirate

/datum/outfit/pirate/post_equip(mob/living/carbon/human/H)
	H.faction |= "pirate"

	var/obj/item/radio/R = H.ears
	if(R)
		R.set_frequency(FREQ_SYNDICATE)
		R.freqlock = TRUE

	var/obj/item/card/id/W = H.wear_id
	if(W)
		W.registered_name = H.real_name
		W.update_label(H.real_name)

/datum/outfit/tunnel_clown
	name = "Tunnel Clown"

	uniform = /obj/item/clothing/under/rank/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/clown_hat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	l_pocket = /obj/item/reagent_containers/food/snacks/grown/banana
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id
	r_hand = /obj/item/twohanded/fireaxe

/datum/outfit/tunnel_clown/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.access = get_all_accesses()
	W.icon_state = "clown_op"
	W.assignment = "Tunnel Clown!"
	W.registered_name = H.real_name
	W.update_label(H.real_name)

/datum/outfit/psycho
	name = "Masked Killer"

	uniform = /obj/item/clothing/under/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/welding
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/kitchen/knife
	r_pocket = /obj/item/scalpel
	r_hand = /obj/item/twohanded/fireaxe

/datum/outfit/psycho/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	for(var/obj/item/I in H.held_items)
		I.add_mob_blood(H)
	H.regenerate_icons()

/datum/outfit/assassin
	name = "Assassin"

	uniform = /obj/item/clothing/under/suit_jacket
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	l_hand = /obj/item/storage/secure/briefcase
	id = /obj/item/card/id/syndicate
	belt = /obj/item/pda/heads

/datum/outfit/assassin/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	var/obj/item/clothing/under/U = H.w_uniform
	U.attach_accessory(new /obj/item/clothing/accessory/waistcoat(H))

	if(visualsOnly)
		return

	//Could use a type
	var/obj/item/storage/secure/briefcase/sec_briefcase = H.get_item_for_held_index(1)
	for(var/obj/item/briefcase_item in sec_briefcase)
		qdel(briefcase_item)
	for(var/i = 3 to 0 step -1)
		SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/stack/spacecash/c1000, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/gun/energy/kinetic_accelerator/crossbow, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/gun/ballistic/revolver/mateba, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/ammo_box/a357, null, TRUE, TRUE)
	SEND_SIGNAL(sec_briefcase, COMSIG_TRY_STORAGE_INSERT, new /obj/item/grenade/plastic/x4, null, TRUE, TRUE)

	var/obj/item/pda/heads/pda = H.belt
	pda.owner = H.real_name
	pda.ownjob = "Reaper"
	pda.update_label()

	var/obj/item/card/id/syndicate/W = H.wear_id
	W.access = get_all_accesses()
	W.assignment = "Reaper"
	W.registered_name = H.real_name
	W.update_label(H.real_name)

/datum/outfit/centcom_commander
	name = "CentCom Commander"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/armor/bulletproof
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/centhat
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id

/datum/outfit/centcom_commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("CentCom Commander")
	W.assignment = "CentCom Commander"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/admiral
	name = "Admiral"

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	ears = /obj/item/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/helmet/space/beret
	belt = /obj/item/gun/energy/pulse/pistol/m1911
	r_pocket = /obj/item/lighter
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id

/datum/outfit/admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")
	W.assignment = "Admiral"
	W.registered_name = H.real_name
	W.update_label()

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/cultrobes/alt/ghost
	shoes = /obj/item/clothing/shoes/cult/alt/ghost
	head = /obj/item/clothing/head/culthood/alt/ghost
	r_hand = /obj/item/melee/cultblade/ghost

/datum/outfit/wizard
	name = "Blue Wizard"

	uniform = /obj/item/clothing/under/color/lightpurple
	suit = /obj/item/clothing/suit/wizrobe
	shoes = /obj/item/clothing/shoes/sandal/magic
	ears = /obj/item/radio/headset
	head = /obj/item/clothing/head/wizard
	r_pocket = /obj/item/teleportation_scroll
	r_hand = /obj/item/spellbook
	l_hand = /obj/item/staff
	back = /obj/item/storage/backpack
	backpack_contents = list(/obj/item/storage/box=1)

/datum/outfit/wizard/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/spellbook/S = locate() in H.held_items
	if(S)
		S.owner = H

/datum/outfit/wizard/apprentice
	name = "Wizard Apprentice"
	r_hand = null
	l_hand = null
	r_pocket = /obj/item/teleportation_scroll/apprentice

/datum/outfit/wizard/red
	name = "Red Wizard"

	suit = /obj/item/clothing/suit/wizrobe/red
	head = /obj/item/clothing/head/wizard/red

/datum/outfit/wizard/weeb
	name = "Marisa Wizard"

	suit = /obj/item/clothing/suit/wizrobe/marisa
	shoes = /obj/item/clothing/shoes/sandal/marisa
	head = /obj/item/clothing/head/wizard/marisa

/datum/outfit/soviet
	name = "Soviet Admiral"

	uniform = /obj/item/clothing/under/soviet
	head = /obj/item/clothing/head/pirate/captain
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/pirate/captain
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/gun/ballistic/revolver/mateba

	id = /obj/item/card/id

/datum/outfit/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access += get_centcom_access("Admiral")
	W.assignment = "Admiral"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/mobster
	name = "Mobster"

	uniform = /obj/item/clothing/under/suit_jacket/really_black
	head = /obj/item/clothing/head/fedora
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	r_hand = /obj/item/gun/ballistic/automatic/tommygun
	id = /obj/item/card/id

/datum/outfit/mobster/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.assignment = "Assistant"
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/plasmaman
	name = "Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman
	r_hand= /obj/item/tank/internals/plasmaman/belt/full
	mask = /obj/item/clothing/mask/breath

/datum/outfit/death_commando
	name = "Death Commando"

	uniform = /obj/item/clothing/under/rank/centcom_commander
	suit = /obj/item/clothing/suit/space/hardsuit/deathsquad
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	mask = /obj/item/clothing/mask/gas/sechailer/swat
	glasses = /obj/item/clothing/glasses/hud/toggle/thermal
	back = /obj/item/storage/backpack/security
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	r_pocket = /obj/item/shield/energy
	suit_store = /obj/item/tank/internals/emergency_oxygen/double
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_hand = /obj/item/gun/energy/pulse/loyalpin
	id = /obj/item/card/id
	ears = /obj/item/radio/headset/headset_cent/alt

	backpack_contents = list(/obj/item/storage/box=1,\
		/obj/item/ammo_box/a357=1,\
		/obj/item/storage/firstaid/regular=1,\
		/obj/item/storage/box/flashbangs=1,\
		/obj/item/flashlight=1,\
		/obj/item/grenade/plastic/x4=1)

/datum/outfit/death_commando/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/radio/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

	var/obj/item/implant/mindshield/L = new/obj/item/implant/mindshield(H)//Here you go Deuryn
	L.implant(H, null, 1)


	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()//They get full station access.
	W.access += get_centcom_access("Death Commando")//Let's add their alloted CentCom access.
	W.assignment = "Death Commando"
	W.registered_name = H.real_name
	W.update_label(W.registered_name, W.assignment)

/datum/outfit/death_commando/officer
	name = "Death Commando Officer"
	head = /obj/item/clothing/head/helmet/space/beret

/datum/outfit/death_commando/doomguy
	name = "The Juggernaut"

	suit = /obj/item/clothing/suit/space/hardsuit/shielded/doomguy
	shoes = /obj/item/clothing/shoes/jackboots/fast
	gloves = /obj/item/clothing/gloves/krav_maga/combatglovesplus
	mask = /obj/item/clothing/mask/gas/sechailer
	suit_store = /obj/item/gun/energy/pulse/destroyer
	belt = /obj/item/storage/belt/grenade/full/webbing
	back = /obj/item/storage/backpack/hammerspace
	l_pocket = /obj/item/kitchen/knife/combat
	r_pocket = /obj/item/tank/internals/emergency_oxygen/double
	r_hand = /obj/item/reagent_containers/hypospray/combat/supersoldier
	backpack_contents = list(/obj/item/storage/box/engineer=1,\
		/obj/item/reagent_containers/hypospray/combat,\
		/obj/item/radio=1,\
		/obj/item/twohanded/required/chainsaw/energy/doom=1,\
		/obj/item/gun/ballistic/automatic/sniper_rifle=1,\
		/obj/item/gun/grenadelauncher=1,\
		/obj/item/gun/ballistic/automatic/ar=1)

/datum/outfit/chrono_agent
	name = "Timeline Eradication Agent"
	uniform = /obj/item/clothing/under/color/white
	suit = /obj/item/clothing/suit/space/chronos
	back = /obj/item/chrono_eraser
	head = /obj/item/clothing/head/helmet/space/chronos
	mask = /obj/item/clothing/mask/breath
	suit_store = /obj/item/tank/internals/oxygen

/datum/outfit/joker
	name = "Joker"
	uniform = /obj/item/clothing/under/joker
	suit = /obj/item/clothing/suit/joker
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	id = /obj/item/card/id/job/clown
	ears = /obj/item/radio/headset/headset_srv

/datum/outfit/debug //Debug objs plus hardsuit
	name = "Debug outfit"
	uniform = /obj/item/clothing/under/patriotsuit
	suit = /obj/item/clothing/suit/space/hardsuit/syndi/elite
	shoes = /obj/item/clothing/shoes/magboots/advance
	suit_store = /obj/item/tank/internals/oxygen
	mask = /obj/item/clothing/mask/gas/welding
	belt = /obj/item/storage/belt/utility/chief/full
	gloves = /obj/item/clothing/gloves/combat
	id = /obj/item/card/id/ert
	glasses = /obj/item/clothing/glasses/meson/night
	ears = /obj/item/radio/headset/headset_cent/commander
	back = /obj/item/storage/backpack/holding
	backpack_contents = list(/obj/item/card/emag=1,\
		/obj/item/flashlight/emp/debug=1,\
		/obj/item/construction/rcd/combat=1,\
		/obj/item/gun/magic/wand/resurrection/debug=1,\
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1)
