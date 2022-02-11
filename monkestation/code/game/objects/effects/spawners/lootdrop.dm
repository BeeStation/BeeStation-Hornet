/// Mail loot spawner. Some sort of random and rare building tool. No alien tech here.
/obj/effect/spawner/lootdrop/space/fancytool/engineonly
	loot = list(
		/obj/item/wrench/caravan = 1,
		/obj/item/wirecutters/caravan = 1,
		/obj/item/screwdriver/caravan = 1,
		/obj/item/crowbar/red/caravan = 1
	)

/// Mail loot spawner. Drop pool of advanced medical tools typically from research. Not endgame content.
/obj/effect/spawner/lootdrop/space/fancytool/advmedicalonly
	loot = list(
		/obj/item/scalpel/advanced = 1,
		/obj/item/retractor/advanced = 1,
		/obj/item/cautery/augment = 1
	)

/// Mail loot spawner. Some sort of random and rare surgical tool. Alien tech found here.
/obj/effect/spawner/lootdrop/space/fancytool/raremedicalonly
	loot = list(
		/obj/item/scalpel/alien = 1,
		/obj/item/hemostat/alien = 1,
		/obj/item/retractor/alien = 1,
		/obj/item/circular_saw/alien = 1,
		/obj/item/surgicaldrill/alien = 1,
		/obj/item/cautery/alien = 1
	)
