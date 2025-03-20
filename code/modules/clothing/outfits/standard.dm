/datum/outfit/debug //Debug objs plus hardsuit
	name = "Debug outfit"
	uniform = /obj/item/clothing/under/misc/patriotsuit
	suit = /obj/item/clothing/suit/space/hardsuit/debug
	mask = /obj/item/clothing/mask/gas/welding/up
	gloves = /obj/item/clothing/gloves/combat
	belt = /obj/item/storage/belt/utility/chief/full
	shoes = /obj/item/clothing/shoes/magboots/advance
	id = /obj/item/card/id/syndicate/debug
	suit_store = /obj/item/tank/internals/emergency_oxygen/magic_oxygen
	internals_slot = ITEM_SLOT_SUITSTORE
	glasses = /obj/item/clothing/glasses/hud/debug
	ears = /obj/item/radio/headset/headset_cent/debug
	box = /obj/item/storage/box/debugtools
	back = /obj/item/storage/backpack/debug
	backpack_contents = list(/obj/item/gun/magic/wand/resurrection/debug=1,\
		/obj/item/melee/transforming/energy/axe=1,\
		/obj/item/storage/part_replacer/bluespace/tier4=1,\
		/obj/item/debug/human_spawner=1,\
		/obj/item/debug/omnitool=1,\
		/obj/item/xenoartifact_labeler/debug=1,\
		/obj/item/map_template_diver=1,\
		/obj/item/debug/orb_of_power=1
		)

/datum/outfit/debug/pre_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	if(isplasmaman(H))
		suit_store = /obj/item/tank/internals/plasmaman/belt/full/debug

/datum/outfit/debug/post_equip(mob/living/carbon/human/H, visualsOnly)
	. = ..()
	var/obj/item/clothing/shoes/magboots/boots = H.shoes
	boots.toggle()


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
	l_hand = /obj/item/knife/kitchen
	r_pocket = /obj/item/grenade/smokebomb

/datum/outfit/tournament/green
	name = "tournament standard green"

	uniform = /obj/item/clothing/under/color/green

/datum/outfit/tournament/gangster
	name = "tournament gangster"

	uniform = /obj/item/clothing/under/rank/security/detective
	suit = /obj/item/clothing/suit/jacket/det_suit
	glasses = /obj/item/clothing/glasses/thermal/monocle
	head = /obj/item/clothing/head/fedora/det_hat
	r_hand = /obj/item/gun/ballistic
	l_hand = null
	r_pocket = /obj/item/ammo_box/c10mm

/datum/outfit/tournament/janitor
	name = "tournament janitor"

	uniform = /obj/item/clothing/under/rank/civilian/janitor
	back = /obj/item/storage/backpack
	suit = null
	head = null
	r_hand = /obj/item/mop
	l_hand = /obj/item/reagent_containers/cup/bucket
	r_pocket = /obj/item/grenade/chem_grenade/cleaner
	l_pocket = /obj/item/grenade/chem_grenade/cleaner
	backpack_contents = list(/obj/item/stack/tile/iron=6)

/datum/outfit/tournament/janitor/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/reagent_containers/cup/bucket/bucket = H.get_item_for_held_index(1)
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
	backpack_contents = list(/obj/item/storage/box/survival=1)

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

	uniform = /obj/item/clothing/under/costume/pirate
	shoes = /obj/item/clothing/shoes/sneakers/brown
	suit = /obj/item/clothing/suit/costume/pirate
	head = /obj/item/clothing/head/costume/pirate/bandana
	glasses = /obj/item/clothing/glasses/eyepatch

/datum/outfit/pirate/space
	suit = /obj/item/clothing/suit/space/pirate
	head = /obj/item/clothing/head/helmet/space/pirate/bandana
	ears = /obj/item/radio/headset/syndicate/alt
	id = /obj/item/card/id/pirate

/datum/outfit/pirate/space/captain
	head = /obj/item/clothing/head/helmet/space/pirate
	ears = /obj/item/radio/headset/syndicate/alt/leader

/datum/outfit/pirate/post_equip(mob/living/carbon/human/H)
	H.faction |= FACTION_PIRATE

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

	uniform = /obj/item/clothing/under/rank/civilian/clown
	shoes = /obj/item/clothing/shoes/clown_shoes
	gloves = /obj/item/clothing/gloves/color/black
	mask = /obj/item/clothing/mask/gas/clown_hat
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/hooded/chaplain_hoodie
	l_pocket = /obj/item/food/grown/banana
	r_pocket = /obj/item/bikehorn
	id = /obj/item/card/id
	r_hand = /obj/item/fireaxe

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

	uniform = /obj/item/clothing/under/misc/overalls
	shoes = /obj/item/clothing/shoes/sneakers/white
	gloves = /obj/item/clothing/gloves/color/latex
	mask = /obj/item/clothing/mask/surgical
	head = /obj/item/clothing/head/utility/welding
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/thermal/monocle
	suit = /obj/item/clothing/suit/apron
	l_pocket = /obj/item/knife/kitchen
	r_pocket = /obj/item/scalpel
	r_hand = /obj/item/fireaxe

/datum/outfit/psycho/post_equip(mob/living/carbon/human/H)
	for(var/obj/item/carried_item in H.get_equipped_items(TRUE))
		carried_item.add_mob_blood(H)//Oh yes, there will be blood...
	for(var/obj/item/I in H.held_items)
		I.add_mob_blood(H)
	H.regenerate_icons()

/datum/outfit/assassin
	name = "Assassin"

	uniform = /obj/item/clothing/under/suit/black
	shoes = /obj/item/clothing/shoes/sneakers/black
	gloves = /obj/item/clothing/gloves/color/black
	ears = /obj/item/radio/headset
	glasses = /obj/item/clothing/glasses/sunglasses/advanced
	l_pocket = /obj/item/melee/transforming/energy/sword/saber
	l_hand = /obj/item/storage/secure/briefcase
	id = /obj/item/card/id/syndicate
	belt = /obj/item/modular_computer/tablet/pda/heads

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
		sec_briefcase.contents += new /obj/item/stack/spacecash/c1000
	sec_briefcase.contents += new /obj/item/gun/energy/recharge/ebow
	sec_briefcase.contents += new /obj/item/gun/ballistic/revolver/mateba
	sec_briefcase.contents += new /obj/item/ammo_box/a357
	sec_briefcase.contents += new /obj/item/grenade/plastic/x4

	var/obj/item/modular_computer/tablet/pda/heads/pda = H.belt
	pda.saved_identification = H.real_name
	pda.saved_job = "Reaper"

	var/obj/item/card/id/syndicate/W = H.wear_id
	W.access = get_all_accesses()
	W.assignment = "Reaper"
	W.registered_name = H.real_name
	W.update_label(H.real_name)

/datum/outfit/centcom/commander
	name = JOB_CENTCOM_COMMANDER

	uniform = /obj/item/clothing/under/rank/centcom/commander
	suit = /obj/item/clothing/suit/armor/centcom_formal
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	ears = /obj/item/radio/headset/headset_cent/commander
	glasses = /obj/item/clothing/glasses/eyepatch
	mask = /obj/item/clothing/mask/cigarette/cigar/cohiba
	head = /obj/item/clothing/head/hats/centcom_cap
	belt = /obj/item/gun/ballistic/revolver/mateba
	r_pocket = /obj/item/lighter
	l_pocket = /obj/item/ammo_box/a357
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom

/datum/outfit/centcom/commander/plasmaman
	name = "CentCom Commander Plasmaman"

	mask = /obj/item/clothing/mask/gas/sechailer
	head = /obj/item/clothing/head/helmet/space/plasmaman/commander
	uniform = /obj/item/clothing/under/plasmaman/commander

/datum/outfit/centcom/commander/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	if(isplasmaman(H))
		H.open_internals(H.get_item_for_held_index(2))

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access |= get_centcom_access(JOB_CENTCOM_COMMANDER)
	W.assignment = JOB_CENTCOM_COMMANDER
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/admiral
	name = JOB_CENTCOM_ADMIRAL

	uniform = /obj/item/clothing/under/syndicate
	suit = /obj/item/clothing/suit/space/officer
	shoes = /obj/item/clothing/shoes/combat/swat
	gloves = /obj/item/clothing/gloves/combat
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	ears = /obj/item/radio/headset/headset_cent/commander
	mask = /obj/item/clothing/mask/cigarette/cigar/havana
	head = /obj/item/clothing/head/hats/centhat
	belt = /obj/item/gun/energy/pulse/pistol/m1911
	r_pocket = /obj/item/lighter
	back = /obj/item/storage/backpack/satchel/leather
	id = /obj/item/card/id/centcom
	r_hand = /obj/item/megaphone/command

/datum/outfit/admiral/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access |= get_centcom_access(JOB_CENTCOM_ADMIRAL)
	W.assignment = JOB_CENTCOM_ADMIRAL
	W.registered_name = H.real_name
	W.update_label()

	var/obj/item/radio/headset/R = H.ears
	R.set_frequency(FREQ_CENTCOM)
	R.freqlock = TRUE

/datum/outfit/ghost_cultist
	name = "Cultist Ghost"

	uniform = /obj/item/clothing/under/color/black/ghost
	suit = /obj/item/clothing/suit/hooded/cultrobes/alt/ghost
	shoes = /obj/item/clothing/shoes/cult/alt/ghost
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
	shoes = /obj/item/clothing/shoes/sneakers/marisa
	head = /obj/item/clothing/head/wizard/marisa

/datum/outfit/soviet
	name = "Soviet Admiral"

	uniform = /obj/item/clothing/under/costume/soviet
	head = /obj/item/clothing/head/costume/pirate/captain
	shoes = /obj/item/clothing/shoes/combat
	gloves = /obj/item/clothing/gloves/tackler/combat
	ears = /obj/item/radio/headset/headset_cent
	glasses = /obj/item/clothing/glasses/thermal/eyepatch
	suit = /obj/item/clothing/suit/costume/pirate/captain
	back = /obj/item/storage/backpack/satchel/leather
	belt = /obj/item/gun/ballistic/revolver/mateba

	id = /obj/item/card/id/silver

/datum/outfit/soviet/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/silver/W = H.wear_id
	W.icon_state = "centcom"
	W.access = get_all_accesses()
	W.access |= get_centcom_access(JOB_CENTCOM_ADMIRAL)
	W.assignment = JOB_CENTCOM_ADMIRAL
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/mobster
	name = "Mobster"

	uniform = /obj/item/clothing/under/suit/black_really
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
	W.assignment = JOB_NAME_ASSISTANT
	W.registered_name = H.real_name
	W.update_label()

/datum/outfit/plasmaman
	var/list/helmet_variants = list(HELMET_MK2 = /obj/item/clothing/head/helmet/space/plasmaman/mark2,
									HELMET_PROTECTIVE = /obj/item/clothing/head/helmet/space/plasmaman/protective)

	name = "Plasmaman"

	head = /obj/item/clothing/head/helmet/space/plasmaman
	uniform = /obj/item/clothing/under/plasmaman
	r_hand= /obj/item/tank/internals/plasmaman/belt/full

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
	uniform = /obj/item/clothing/under/costume/joker
	suit = /obj/item/clothing/suit/costume/joker
	shoes = /obj/item/clothing/shoes/laceup
	gloves = /obj/item/clothing/gloves/color/white
	id = /obj/item/card/id/job/clown
	ears = /obj/item/radio/headset/headset_srv


/datum/outfit/joker/post_equip(mob/living/carbon/human/H, visualsOnly = FALSE)
	if(visualsOnly)
		return

	var/obj/item/card/id/I = H.wear_id
	I.assignment = "Joker"
	I.registered_name = H.real_name
	I.update_label()
