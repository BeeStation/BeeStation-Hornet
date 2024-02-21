/datum/gang_item
	var/name
	var/desc
	var/item_path
	var/category = "item category"
	var/cost
	var/list/gang_whitelist = list()
	var/list/gang_blacklist = list()
	var/list/gang_items


/datum/gang_item/proc/purchase(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool, check_canbuy = TRUE)
	if(check_canbuy && !can_buy(user, gang, gangtool))
		return FALSE
	if(!spawn_item(user, gang, gangtool))
		gang.adjust_influence(-cost)
		to_chat(user, "<span class='notice'>You bought \the [name].</span>")
		return TRUE

/datum/gang_item/proc/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool) // If this returns anything other than null, something fucked up and influence won't lower.
	if(item_path)
		var/obj/item/O = new item_path(user.loc)
		user.put_in_hands(O)
	else
		return TRUE

/datum/gang_item/proc/can_buy(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	return gang && (gang.influence >= cost)


///////////////////
//Essential Gang Tools
///////////////////

/datum/gang_item/essentials
	category = "Essential Items"


/datum/gang_item/essentials/gangtool
	name = "Gangtool"
	cost = 50
	item_path = /obj/item/device/gangtool
	desc = "Spare gangtool to keep stashed in case of arrest."


/datum/gang_item/essentials/uniform
	name = "Gang Uniform"
	cost = 5
	desc = "Full outfit of your gangs uniform, increases your influence and reputation if worn by members, reduces it if not worn at all."

/datum/gang_item/essentials/uniform/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/storage/box/uniform_box = new (get_turf(user))

	new gang.outfit(uniform_box)
	new gang.suit(uniform_box)
	new gang.hat(uniform_box)

	user.put_in_hands(uniform_box)
	to_chat(user, "<span class='notice'> This is your gang's official uniform, wearing it will increase your influence.")
	return TRUE


///////////////////
//WEAPONS
///////////////////

/datum/gang_item/weapon
	category = "Weapons"

/datum/gang_item/weapon/emp
	name = "EMP Grenade"
	cost = 50
	item_path = /obj/item/grenade/empgrenade

/datum/gang_item/weapon/switchblade
	name = "Switchblade"
	desc = "A sharp, concealable, spring-loaded knife with a long blade."
	cost = 100
	item_path = /obj/item/switchblade

/datum/gang_item/weapon/shuriken
	name = "Shuriken box"
	cost = 150
	item_path = /obj/item/storage/box/shuriken_box

/obj/item/storage/box/shuriken_box
	name = "shuriken Box"

/obj/item/storage/box/shuriken_box/PopulateContents()
	for (var/i in 1 to 4)
		new /obj/item/throwing_star(src)

/datum/gang_item/weapon/pistol
	name = "10mm Pistol"
	desc = "A small, easily concealable 10mm handgun. Has a threaded barrel for suppressors."
	cost = 500
	item_path = /obj/item/gun/ballistic/automatic/pistol

/datum/gang_item/weapon/pistol_ammo
	name = "10mm Ammo"
	desc = "A magazine for 10mm pistols."
	cost = 50
	item_path = /obj/item/ammo_box/magazine/m10mm

/datum/gang_item/weapon/uzi
	name = "Uzi SMG"
	desc = "A lightweight submachine gun, for when you really want someone dead. Uses 9mm rounds."
	cost = 700
	item_path = /obj/item/gun/ballistic/automatic/mini_uzi

/datum/gang_item/weapon/uzi_ammo
	name = "Uzi Ammo"
	desc = "A 9mm magazine intended for use with Uzi SMGs."
	cost = 70
	item_path = /obj/item/ammo_box/magazine/uzim9mm

/datum/gang_item/weapon/laser
	name = "Laser Gun"
	desc = "An older model of the basic lasergun, no longer used by Nanotrasen's private security or military forces. Nevertheless, it is still quite deadly and easy to maintain, making it a favorite amongst pirates and other outlaws."
	cost = 500
	item_path = /obj/item/gun/energy/laser/retro

///////////////////
//EQUIPMENT
///////////////////

/datum/gang_item/support
	category = "Support Equipment"

/datum/gang_item/support/healcigs
	name = "Healing Cigs"
	desc = "A pack of omnizine laced syndicate cigarettes."
	cost = 20
	item_path = /obj/item/storage/fancy/cigarettes/cigpack_syndicate

/datum/gang_item/support/maintpass
	name = "Maintenance Access Pass"
	desc = "A small card, that when used on an ID, will grant basic maintenance access."
	cost = 10
	item_path = /obj/item/card/id/pass/maintenance

/datum/gang_item/support/medkit
	name = "Basic Medical Kit"
	desc = "A small card, that when used on an ID, will grant basic maintenance access."
	cost = 30
	item_path = /obj/item/storage/firstaid/regular

/datum/gang_item/support/smuggler
	name = "Smuggler's Satchel"
	desc = "A small satchel, able to fit into tight spaces such as backpacks or under the floor boards."
	cost = 50
	item_path = /obj/item/storage/backpack/satchel/flat

/datum/gang_item/infrep
	category = "Influence & Reputation"

/datum/gang_item/infrep/drugs
	name = "Illicit Drug Dispenser"
	desc = "Dispenses various kinds of narcotics, including formaltenamine, which grants influence and reputation when consumed by non gangsters."
	cost = 100
	item_path = /obj/item/sbeacondrop/drugs

/datum/gang_item/infrep/drugs/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/sbeacondrop/drugs/O = new item_path(user.loc)
	user.put_in_hands(O)
	O.g = gang


/datum/gang_item/infrep/spraycan
	name = "Territory Spraycan"
	desc = "Modified spraycan used to claiming specific territories for your gang, increasing your influence. Also serves to increase your Reputation, but losing territory will decrease it instead."
	cost = 20
	item_path = /obj/item/toy/crayon/spraycan/gang

/datum/gang_item/infrep/spraycan/spawn_item(mob/living/carbon/user, datum/team/gang/gang, obj/item/device/gangtool/gangtool)
	var/obj/item/toy/crayon/spraycan/gang/O = new item_path(user.loc)
	user.put_in_hands(O)
	O.gang = gang
	O.paint_color = gang.color
	O.update_icon()
