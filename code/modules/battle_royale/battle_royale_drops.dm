//Global lists so they can be editted by admins
GLOBAL_LIST_INIT(battle_royale_basic_loot, list(
		/obj/item/soap,
		/obj/item/kitchen/knife,
		/obj/item/kitchen/knife/combat,
		/obj/item/kitchen/knife/poison,
		/obj/item/throwing_star,
		/obj/item/syndie_glue,
		/obj/item/book_of_babel,
		/obj/item/card/emag,
		/obj/item/storage/box/emps,
		/obj/item/storage/box/lethalshot,
		/obj/item/storage/box/gorillacubes,
		/obj/item/storage/box/teargas,
		/obj/item/storage/box/security/radio,
		/obj/item/storage/box/medsprays,
		/obj/item/storage/toolbox/syndicate,
		/obj/item/storage/box/syndie_kit/bee_grenades,
		/obj/item/storage/box/syndie_kit/centcom_costume,
		/obj/item/storage/box/syndie_kit/chameleon,
		/obj/item/storage/box/syndie_kit/chemical,
		/obj/item/storage/box/syndie_kit/emp,
		/obj/item/storage/box/syndie_kit/imp_adrenal,
		/obj/item/storage/box/syndie_kit/imp_freedom,
		/obj/item/storage/box/syndie_kit/imp_radio,
		/obj/item/storage/box/syndie_kit/imp_stealth,
		/obj/item/storage/box/syndie_kit/imp_storage,
		/obj/item/storage/box/syndie_kit/imp_uplink,
		/obj/item/storage/box/syndie_kit/origami_bundle,
		/obj/item/storage/box/syndie_kit/throwing_weapons,
		/obj/item/storage/box/syndicate/bundle_A,
		/obj/item/storage/box/syndicate/bundle_B,
		/obj/item/gun/ballistic/automatic/pistol,
		/obj/item/gun/energy/disabler,
		/obj/item/construction/rcd,
		/obj/item/clothing/glasses/chameleon/flashproof,
		/obj/item/clothing/glasses/clockwork/wraith_spectacles,
		/obj/item/clothing/glasses/sunglasses/advanced,
		/obj/item/clothing/glasses/thermal/eyepatch,
		/obj/item/clothing/glasses/thermal/syndi,
		/obj/item/clothing/suit/space,
		/obj/item/clothing/suit/armor/riot,
		/obj/item/clothing/suit/armor/vest,
		/obj/item/clothing/suit/armor/vest/russian_coat,
		/obj/item/clothing/suit/armor/hos/trenchcoat,
		/obj/item/clothing/mask/chameleon,
		/obj/item/clothing/head/centhat,
		/obj/item/clothing/head/crown,
		/obj/item/clothing/head/HoS/syndicate,
		/obj/item/clothing/head/helmet,
		/obj/item/clothing/head/helmet/clockcult,
		/obj/item/clothing/head/helmet/space,
		/obj/item/clothing/head/helmet/sec,
		/obj/item/clothing/under/syndicate,
		/obj/item/clothing/gloves/combat,
		/obj/item/deployablemine/stun,
		/obj/item/switchblade,
		/obj/item/club/tailclub,
		/obj/item/nullrod/tribal_knife,
		/obj/item/nullrod/fedora,
		/obj/item/nullrod/godhand,
		/obj/item/melee/baton/loaded,
		/obj/item/melee/chainofcommand/tailwhip/kitty,
		/obj/item/melee/classic_baton,
		/obj/item/melee/ghost_sword,
		/obj/item/melee/powerfist,
		/obj/item/storage/firstaid/advanced,
		/obj/item/storage/firstaid/brute,
		/obj/item/storage/firstaid/fire,
		/obj/item/storage/firstaid/medical,
		/obj/item/storage/firstaid/tactical,
		/obj/item/gun/energy/ionrifle,
		/obj/item/organ/regenerative_core/battle_royale
	))

GLOBAL_LIST_INIT(battle_royale_good_loot, list(
		/obj/item/hand_tele,
		/obj/item/gun/ballistic/bow/clockbolt,
		/obj/item/gun/ballistic/rifle/boltaction,
		/obj/item/gun/ballistic/shotgun/doublebarrel,
		/obj/item/gun/energy/laser/captain,
		/obj/item/gun/ballistic/revolver/mateba,
		/obj/item/gun/ballistic/automatic/c20r,
		/obj/item/ammo_box/magazine/smgm45,
		/obj/item/ammo_box/magazine/pistolm9mm,
		/obj/item/katana,
		/obj/item/melee/transforming/energy/sword,
		/obj/item/twohanded/dualsaber,
		/obj/item/twohanded/fireaxe,
		/obj/item/stack/telecrystal/five,
		/obj/item/stack/telecrystal/twenty,
		/obj/item/clothing/suit/space/hardsuit/syndi
	))

GLOBAL_LIST_INIT(battle_royale_insane_loot, list(
		/obj/item/gun/ballistic/automatic/l6_saw/unrestricted,
		/obj/item/energy_katana,
		/obj/item/clothing/suit/space/hardsuit/shielded/syndi,
		/obj/item/his_grace,
		/obj/mecha/combat/marauder/mauler/loaded,
		/obj/item/guardiancreator/tech,
		/obj/item/twohanded/mjollnir,
		/obj/item/pneumatic_cannon/pie/selfcharge,
		/obj/item/uplink/nuclear
	))

//==================================
// EVENTS / DROPS
//==================================

/datum/battle_royale_controller/proc/generate_basic_loot(amount=1)
	for(var/i in 1 to amount)
		send_item(pick(GLOB.battle_royale_basic_loot))
		CHECK_TICK

/datum/battle_royale_controller/proc/generate_good_drop()
	var/list/good_drops = list()
	for(var/i in 1 to rand(1,3))
		good_drops += pick(GLOB.battle_royale_good_loot)
	send_item(good_drops, announce = "Incomming extended supply materials.", force_time = 600)

/datum/battle_royale_controller/proc/generate_endgame_drop()
	var/obj/item = pick(GLOB.battle_royale_insane_loot)
	send_item(item, announce = "We found a weird looking package in the back of our warehouse. We have no idea what is in it, but it is marked as incredibily dangerous and could be a superweapon.", force_time = 9000)

/datum/battle_royale_controller/proc/send_item(item_path, style = STYLE_BOX, announce=FALSE, force_time = 0)
	if(!item_path)
		return
	var/turf/target = get_safe_random_station_turf()
	var/obj/structure/closet/supplypod/battleroyale/pod = new()
	if(islist(item_path))
		for(var/thing in item_path)
			new thing(pod)
	else
		new item_path(pod)
	if(force_time)
		pod.fallDuration = force_time
	new /obj/effect/DPtarget(target, pod)
	if(announce)
		priority_announce("[announce] \nExpected Drop Location: [get_area(target)]\n ETA: [force_time/10] Seconds.", "High Command Supply Control")
