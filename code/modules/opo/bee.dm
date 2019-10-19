//all names in this are WIP please send better names other than Buzz Trooper

/obj/item/clothing/head/helmet/space/hardsuit/bee
	name = "/improper BRT Hardsuit Helmet"
	desc = "You feel faintly buzzed, and it isn't the omega weed..."
	icon = 'code/modules/opo/opo.dmi'
	icon_state = "bteamhelmet"
	item_state = "bteamhelmet"
	item_color = "bee"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30,"energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)


/obj/item/clothing/suit/space/hardsuit/bee
	name = "/improper BRT Hardsuit"
	desc = "You feel faintly buzzed, and it isn't the omega weed..."
	icon = 'code/modules/opo/opo.dmi'
	item_state = "bteamhardsuit"
	icon_state = "bteamhardsuit"
	armor = list("melee" = 35, "bullet" = 15, "laser" = 30, "energy" = 10, "bomb" = 10, "bio" = 100, "rad" = 50, "fire" = 75, "acid" = 75)
	helmettype = /obj/item/clothing/head/helmet/space/hardsuit/bee

//outfit code

/datum/antagonist/ert/commander/bee
	outfit = /datum/outfit/ert/commander/bee

/datum/antagonist/ert/security/bee
	outfit = /datum/outfit/ert/security/bee

/datum/outfit/ert/security/bee
	name = "Buzz Trooper"

	suit = /obj/item/clothing/suit/space/hardsuit/bee

	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/storage/box/handcuffs=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun/stun=1,
		/obj/item/melee/baton/loaded=1,
		/obj/item/construction/rcd/loaded=1)

/datum/outfit/ert/commander/bee
	name = "Buzz Leader"
	r_hand = /obj/item/nullrod/scythe/talking/chainsword
	suit = /obj/item/clothing/suit/space/hardsuit/bee
	backpack_contents = list(/obj/item/storage/box/engineer=1,
		/obj/item/clothing/mask/gas/sechailer=1,
		/obj/item/gun/energy/e_gun=1)

//create antagonists

/datum/ert/janitor
	roles = list(/datum/antagonist/ert/security/bee)
	leader_role = /datum/antagonist/ert/commander/bee
	teamsize = 5
	opendoors = FALSE
	rename_team = "BeeRT"
	mission = "Buzz it up."
	polldesc = "the B Team"
