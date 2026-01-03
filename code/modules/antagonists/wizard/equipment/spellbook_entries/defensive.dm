// Defensive wizard spells
/datum/spellbook_entry/magicm
	name = "Magic Missile"
	desc = "Fires several, slow moving, magic projectiles at nearby targets."
	spell_type = /datum/action/spell/aoe/magic_missile
	category = "Defensive"

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	desc = "Disables all weapons, cameras and most other technology in range."
	spell_type = /datum/action/spell/emp/disable_tech
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	desc = "Throws everything around the user away."
	spell_type = /datum/action/spell/aoe/repulse/wizard
	category = "Defensive"

/datum/spellbook_entry/lightning_packet
	name = "Thrown Lightning"
	desc = "Forged from eldrich energies, a packet of pure power, \
		known as a spell packet will appear in your hand, that when thrown will stun the target."
	spell_type = /datum/action/spell/conjure_item/spellpacket
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	desc = "Stops time for everyone except for you, allowing you to move freely \
		while your enemies and even projectiles are frozen."
	spell_type = /datum/action/spell/timestop
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	desc = "Spawns a cloud of choking smoke at your location."
	spell_type = /datum/action/spell/smoke
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	desc = "Create a magical barrier that only you can pass through."
	spell_type = /datum/action/spell/forcewall
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an item of your choosing, \
		turning you into an immortal Lich. So long as the item remains intact, you will revive from death, \
		no matter the circumstances. Be wary - with each revival, your body will become weaker, and \
		it will become easier for others to find your item of power."
	spell_type =  /datum/action/spell/lichdom
	category = "Defensive"
	no_random = WIZARD_NORANDOM_WILDAPPRENTICE

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, \
		randomizing the layout and making proper movement impossible. The strings vibrate..."
	spell_type = /datum/action/spell/spacetime_dist
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	spell_type = /datum/action/spell/conjure/the_traps
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	desc = "This spell magically kicks a transdimensional beehive, \
		instantly summoning a swarm of bees to your location. These bees are NOT friendly to anyone."
	spell_type = /datum/action/spell/conjure/bee
	category = "Defensive"

//Essentially a lesser version of the locker staff that doesn't require a staff and is cheaper
/datum/spellbook_entry/arcane_prison
	name = "Arcane Prison"
	desc = "Fires a sphere of magical energy that captures the first living target it hits inside for a short time."
	spell_type = /datum/action/spell/pointed/projectile/arcane_prison
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/lockerstaff
	name = "Staff of the Locker"
	desc = "A staff that shoots lockers. It eats anyone it hits on its way, leaving a welded locker with your victims behind."
	item_path = /obj/item/gun/magic/staff/locker
	category = "Defensive"

/datum/spellbook_entry/item/scryingorb
	name = "Scrying Orb"
	desc = "An incandescent orb of crackling energy. Using it will allow you to release your ghost while alive, allowing you to spy upon the station and talk to the deceased. In addition, buying it will permanently grant you X-ray vision."
	item_path = /obj/item/scrying
	category = "Defensive"

/datum/spellbook_entry/item/rewind_camera
	name = "Rewind Camera"
	desc = "A camera that reverts the subject of a photo back to when the photo was taken, after a time. Restores limbs and injuries, but not death. Refillable with film, and comes with three shots."
	item_path = /obj/item/camera/rewind
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/rewind_camera/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	new /obj/item/camera_film(get_turf(user)) //the camera only natively has one shot, so we'll give some reloads until they can raid the library
	new /obj/item/camera_film(get_turf(user))
	new /obj/item/camera_film(get_turf(user))
	. = ..()

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armour Set"
	desc = "An artefact suit of armour that allows you to cast spells while providing more protection against attacks and the void of space."
	item_path = /obj/item/mod/control/pre_equipped/enchanted
	category = "Defensive"

/datum/spellbook_entry/item/armor/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/obj/item/mod/control/mod = to_equip
	var/obj/item/mod/module/storage/storage = locate() in mod.modules
	var/obj/item/back = user.back
	if(back)
		if(!user.dropItemToGround(back))
			return
		for(var/obj/item/item as anything in back.contents)
			item.forceMove(storage)
	if(!user.equip_to_slot_if_possible(mod, mod.slot_flags, qdel_on_fail = FALSE, disable_warning = TRUE))
		return
	if(!user.dropItemToGround(user.wear_suit) || !user.dropItemToGround(user.head))
		return
	mod.quick_activation()

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant 300 additional integrity to a battlemage shield."
	item_path = /obj/item/wizard_armour_charge
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/healing_wand
	name = "Wand of Healing"
	desc = "A wand that can close any wound, though it cannot restore limbs or organs. You can use it on yourself."
	item_path = /obj/item/gun/magic/wand/healing
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/ice_wand
	name = "Wand of Icy Blast"
	desc = "This wand will chill your enemies to the bone, and the ground beneath their feet too!"
	item_path = /obj/item/gun/magic/wand/icy_blast
	category = "Defensive"
	cost = 1
