/datum/spellbook_entry
	var/name = "Entry Name"

	var/spell_type = null
	var/desc = ""
	var/category = "Offensive"
	var/cost = 2
	var/times = 0
	var/refundable = TRUE
	var/obj/effect/proc_holder/spell/S = null //Since spellbooks can be used by only one person anyway we can track the actual spell
	var/buy_word = "Learn"
	var/cooldown
	var/clothes_req = FALSE
	var/limit //used to prevent a spellbook_entry from being bought more than X times with one wizard spellbook
	var/list/no_coexistence_typecache //Used so you can't have specific spells together
	var/no_random = FALSE // This is awful one to be a part of randomness - i.e.) soul tap
	var/disabled = FALSE // Is this item disabled due to having issues? Must provide an issue reference and description of issue.

/datum/spellbook_entry/New()
	..()
	no_coexistence_typecache = typecacheof(no_coexistence_typecache)

/datum/spellbook_entry/proc/IsAvailable(obj/item/spellbook/book) // For config prefs / gamemode restrictions - these are round applied
	return TRUE

/datum/spellbook_entry/proc/CanBuy(mob/living/carbon/human/user,obj/item/spellbook/book) // Specific circumstances
	if (disabled)
		return FALSE
	if(book.uses<cost || limit == 0)
		return FALSE
	for(var/spell in user.mind.spell_list)
		if(is_type_in_typecache(spell, no_coexistence_typecache) && !book.bypass_lock)
			return FALSE
	return TRUE

/datum/spellbook_entry/proc/Buy(mob/living/carbon/human/user,obj/item/spellbook/book) //return TRUE on success
	if(!S || QDELETED(S))
		S = new spell_type()
	//Check if we got the spell already
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name)) // Not using directly in case it was learned from one spellbook then upgraded in another
			if(aspell.spell_level >= aspell.level_max)
				to_chat(user,  "<span class='warning'>This spell cannot be improved further.</span>")
				return FALSE
			else
				aspell.name = initial(aspell.name)
				aspell.spell_level++
				aspell.charge_max = round(initial(aspell.charge_max) - aspell.spell_level * (initial(aspell.charge_max) - aspell.cooldown_min)/ aspell.level_max)
				if(aspell.charge_max < aspell.charge_counter)
					aspell.charge_counter = aspell.charge_max
				var/newname = "ERROR"
				switch(aspell.spell_level)
					if(1)
						to_chat(user, "<span class='notice'>You have improved [aspell.name] into Efficient [aspell.name].</span>")
						newname = "Efficient [aspell.name]"
					if(2)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Quickened [aspell.name].</span>")
						newname = "Quickened [aspell.name]"
					if(3)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Free [aspell.name].</span>")
						newname = "Free [aspell.name]"
					if(4)
						to_chat(user, "<span class='notice'>You have further improved [aspell.name] into Instant [aspell.name].</span>")
						newname = "Instant [aspell.name]"
				aspell.name = newname
				if(aspell.spell_level >= aspell.level_max)
					to_chat(user, "<span class='notice'>This spell cannot be strengthened any further.</span>")
				//we'll need to update the cooldowns for the spellbook
				GetInfo()
				book.update_static_data(user) // updates "times" var
				SSblackbox.record_feedback("nested tally", "wizard_spell_improved", 1, list("[name]", "[aspell.spell_level]"))
				return TRUE
	//debug handling
	if(book.everything_robeless)
		SSblackbox.record_feedback("tally", "debug_wizard_spell_learned", 1, name)
		S.clothes_req = FALSE // You'd want no cloth req if you learned spells from a debug spellbook
	else
		SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)

	//No same spell found - just learn it
	user.mind.AddSpell(S)
	to_chat(user, "<span class='notice'>You have learned [S.name].</span>")
	return TRUE

/datum/spellbook_entry/proc/CanRefund(mob/living/carbon/human/user,obj/item/spellbook/book)
	if(!refundable)
		return FALSE
	if(!S)
		S = new spell_type()
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			return TRUE
	return FALSE

/datum/spellbook_entry/proc/Refund(mob/living/carbon/human/user,obj/item/spellbook/book) //return point value or -1 for failure
	var/area/wizard_station/A = GLOB.areas_by_type[/area/wizard_station]
	if(!(user in A.contents))
		to_chat(user, "<span class='warning'>You can only refund spells at the wizard lair</span>")
		return -1
	if(!S)
		S = new spell_type()
	var/spell_levels = 0
	for(var/obj/effect/proc_holder/spell/aspell in user.mind.spell_list)
		if(initial(S.name) == initial(aspell.name))
			spell_levels = aspell.spell_level
			user.mind.spell_list.Remove(aspell)
			name = initial(name)
			qdel(S)
			return cost * (spell_levels+1)
	return -1

/datum/spellbook_entry/proc/GetInfo()
	if(!spell_type)
		return
	if(!S)
		S = new spell_type()
	if(S.charge_type == "recharge")
		cooldown = S.charge_max/10
	if(S.clothes_req)
		clothes_req = TRUE
	if(!desc)
		desc = S.desc

/datum/spellbook_entry/fireball
	name = "Fireball"
	desc = "Fires an explosive fireball at a target. Considered a classic among all wizards."
	spell_type = /obj/effect/proc_holder/spell/aimed/fireball

/datum/spellbook_entry/spell_cards
	name = "Spell Cards"
	desc = "Blazing hot rapid-fire homing cards. Send your foes to the shadow realm with their mystical power!"
	spell_type = /obj/effect/proc_holder/spell/aimed/spell_cards
	cost = 1

/datum/spellbook_entry/rod_form
	name = "Rod Form"
	desc = "Take on the form of an immovable rod, destroying all in your path. Purchasing this spell multiple times will also increase the rod's damage and travel range."
	spell_type = /obj/effect/proc_holder/spell/targeted/rod_form

/datum/spellbook_entry/magicm
	name = "Magic Missile"
	desc = "Fires several, slow moving, magic projectiles at nearby targets."
	spell_type = /obj/effect/proc_holder/spell/targeted/projectile/magic_missile
	category = "Defensive"

/datum/spellbook_entry/disintegrate
	name = "Disintegrate"
	desc = "Charges your hand with an unholy energy that can be used to cause a touched victim to violently explode."
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/disintegrate

/datum/spellbook_entry/disabletech
	name = "Disable Tech"
	desc = "Disables all weapons, cameras and most other technology in range."
	spell_type = /obj/effect/proc_holder/spell/targeted/emplosion/disable_tech
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/repulse
	name = "Repulse"
	desc = "Throws everything around the user away."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/repulse
	category = "Defensive"

/datum/spellbook_entry/lightningPacket
	name = "Lightning bolt!  Lightning bolt!"
	desc = "Forged from eldrich energies, a packet of pure power, known as a spell packet will appear in your hand, that when thrown will stun the target."
	spell_type = /obj/effect/proc_holder/spell/targeted/conjure_item/spellpacket
	category = "Defensive"

/datum/spellbook_entry/timestop
	name = "Time Stop"
	desc = "Stops time for everyone except for you, allowing you to move freely while your enemies and even projectiles are frozen."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/timestop
	category = "Defensive"

/datum/spellbook_entry/smoke
	name = "Smoke"
	desc = "Spawns a cloud of choking smoke at your location."
	spell_type = /obj/effect/proc_holder/spell/targeted/smoke
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blind
	name = "Blind"
	desc = "Temporarily blinds a single target."
	spell_type = /obj/effect/proc_holder/spell/targeted/blind
	cost = 1

/datum/spellbook_entry/mindswap
	name = "Mindswap"
	desc = "Allows you to switch bodies with a target next to you. You will both fall asleep when this happens, and it will be quite obvious that you are the target's body if someone watches you do it."
	spell_type = /obj/effect/proc_holder/spell/targeted/mind_transfer
	category = "Mobility"

/datum/spellbook_entry/forcewall
	name = "Force Wall"
	desc = "Create a magical barrier that only you can pass through."
	spell_type = /obj/effect/proc_holder/spell/targeted/forcewall
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/blink
	name = "Blink"
	desc = "Randomly teleports you a short distance."
	spell_type = /obj/effect/proc_holder/spell/targeted/turf_teleport/blink
	category = "Mobility"

/datum/spellbook_entry/teleport
	name = "Teleport"
	desc = "Teleports you to an area of your selection."
	spell_type = /obj/effect/proc_holder/spell/targeted/area_teleport/teleport
	category = "Mobility"

/datum/spellbook_entry/mutate
	name = "Mutate"
	desc = "Causes you to turn into a hulk and gain laser vision for a short while."
	spell_type = /obj/effect/proc_holder/spell/targeted/genetic/mutate

/datum/spellbook_entry/jaunt
	name = "Ethereal Jaunt"
	desc = "Turns your form ethereal, temporarily making you invisible and able to pass through walls."
	spell_type = /obj/effect/proc_holder/spell/targeted/ethereal_jaunt
	category = "Mobility"

/datum/spellbook_entry/knock
	name = "Knock"
	desc = "Opens nearby doors and closets."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/knock
	category = "Mobility"
	cost = 1

/datum/spellbook_entry/fleshtostone
	name = "Flesh to Stone"
	desc = "Charges your hand with the power to turn victims into inert statues for a long period of time."
	spell_type = /obj/effect/proc_holder/spell/targeted/touch/flesh_to_stone

/datum/spellbook_entry/summonitem
	name = "Summon Item"
	desc = "Recalls a previously marked item to your hand from anywhere in the universe."
	spell_type = /obj/effect/proc_holder/spell/targeted/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/lichdom
	name = "Bind Soul"
	desc = "A dark necromantic pact that can forever bind your soul to an \
	item of your choosing. So long as both your body and the item remain \
	intact and on the same plane you can revive from death, though the time \
	between reincarnations grows steadily with use, along with the weakness \
	that the new skeleton body will experience upon 'birth'. Note that \
	becoming a lich destroys all internal organs except the brain."
	spell_type = /obj/effect/proc_holder/spell/targeted/lichdom
	category = "Defensive"
	cost = 3
	no_random = WIZARD_NORANDOM_WILDAPPRENTICE

/datum/spellbook_entry/teslablast
	name = "Tesla Blast"
	desc = "Charge up a tesla arc and release it at a random nearby target! You can move freely while it charges. The arc jumps between targets and can knock them down."
	spell_type = /obj/effect/proc_holder/spell/targeted/tesla

/datum/spellbook_entry/lightningbolt
	name = "Lightning Bolt"
	desc = "Fire a lightning bolt at your foes! It will jump between targets, but can't knock them down."
	spell_type = /obj/effect/proc_holder/spell/aimed/lightningbolt

/datum/spellbook_entry/lightningbolt/Buy(mob/living/carbon/human/user,obj/item/spellbook/book) //return TRUE on success
	. = ..()
	user.flags_1 |= TESLA_IGNORE_1

/datum/spellbook_entry/infinite_guns
	name = "Lesser Summon Guns"
	desc = "Why reload when you have infinite guns? Summons an unending stream of bolt action rifles that deal little damage, but will knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Arcane Barrage."
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun
	cost = 3
	no_coexistence_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage

/datum/spellbook_entry/arcane_barrage
	name = "Arcane Barrage"
	desc = "Fire a torrent of arcane energy at your foes with this (powerful) spell. Deals much more damage than Lesser Summon Guns, but won't knock targets down. Requires both hands free to use. Learning this spell makes you unable to learn Lesser Summon Gun."
	spell_type = /obj/effect/proc_holder/spell/targeted/infinite_guns/arcane_barrage
	no_coexistence_typecache = /obj/effect/proc_holder/spell/targeted/infinite_guns/gun

/datum/spellbook_entry/barnyard
	name = "Barnyard Curse"
	desc = "This spell dooms an unlucky soul to possess the speech and facial attributes of a barnyard animal."
	spell_type = /obj/effect/proc_holder/spell/targeted/barnyardcurse

/datum/spellbook_entry/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	spell_type = /obj/effect/proc_holder/spell/targeted/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	spell_type = /obj/effect/proc_holder/spell/targeted/shapeshift
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	spell_type = /obj/effect/proc_holder/spell/self/tap
	category = "Assistance"
	cost = 1
	no_random = WIZARD_NORANDOM_WILDAPPRENTICE

/datum/spellbook_entry/spacetime_dist
	name = "Spacetime Distortion"
	desc = "Entangle the strings of space-time in an area around you, randomizing the layout and making proper movement impossible. The strings vibrate..."
	spell_type = /obj/effect/proc_holder/spell/spacetime_dist
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/the_traps
	name = "The Traps!"
	desc = "Summon a number of traps around you. They will damage and enrage any enemies that step on them."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/the_traps
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/bees
	name = "Lesser Summon Bees"
	desc = "This spell magically kicks a transdimensional beehive, instantly summoning a swarm of bees to your location. These bees are NOT friendly to anyone."
	spell_type = /obj/effect/proc_holder/spell/aoe_turf/conjure/creature/bee
	category = "Defensive"

/datum/spellbook_entry/item
	name = "Buy Item"
	refundable = FALSE
	buy_word = "Summon"
	var/item_path= null


/datum/spellbook_entry/item/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	new item_path(get_turf(user))
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	return TRUE

/datum/spellbook_entry/item/staffchange
	name = "Staff of Change"
	desc = "An artefact that spits bolts of coruscating energy which cause the target's very form to reshape itself."
	item_path = /obj/item/gun/magic/staff/change

/datum/spellbook_entry/item/staffanimation
	name = "Staff of Animation"
	desc = "An arcane staff capable of shooting bolts of eldritch energy which cause inanimate objects to come to life. This magic doesn't affect machines."
	item_path = /obj/item/gun/magic/staff/animate
	category = "Assistance"

/datum/spellbook_entry/item/staffchaos
	name = "Staff of Chaos"
	desc = "A caprious tool that can fire all sorts of magic without any rhyme or reason. Using it on people you care about is not recommended."
	item_path = /obj/item/gun/magic/staff/chaos

/datum/spellbook_entry/item/spellblade
	name = "Spellblade"
	desc = "A sword capable of firing blasts of energy which rip targets limb from limb."
	item_path = /obj/item/gun/magic/staff/spellblade

/datum/spellbook_entry/item/staffdoor
	name = "Staff of Door Creation"
	desc = "A particular staff that can mold solid walls into ornate doors. Useful for getting around in the absence of other transportation. Does not work on glass."
	item_path = /obj/item/gun/magic/staff/door
	cost = 1
	category = "Mobility"

/datum/spellbook_entry/item/staffhealing
	name = "Staff of Healing"
	desc = "An altruistic staff that can heal the lame and raise the dead."
	item_path = /obj/item/gun/magic/staff/healing
	cost = 1
	category = "Defensive"

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

/datum/spellbook_entry/item/soulstones
	name = "Soulstone Shard Kit"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. =..()
	if(.)
		user.mind.AddSpell(new /obj/effect/proc_holder/spell/aoe_turf/conjure/construct(null))
	return .

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	category = "Assistance"

/datum/spellbook_entry/item/wands
	name = "Wand Assortment"
	desc = "A collection of wands that allow for a wide variety of utility. Wands have a limited number of charges, so be conservative with their use. Comes in a handy belt."
	item_path = /obj/item/storage/belt/wands/full
	category = "Defensive"

/datum/spellbook_entry/item/armor
	name = "Mastercrafted Armor Set"
	desc = "An artefact suit of armor that allows you to cast spells while providing more protection against attacks and the void of space."
	item_path = /obj/item/clothing/suit/space/hardsuit/wizard
	category = "Defensive"

/datum/spellbook_entry/item/armor/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	. = ..()
	if(.)
		new /obj/item/clothing/shoes/sandal/magic(get_turf(user)) //In case they've lost them.
		new /obj/item/clothing/gloves/color/purple(get_turf(user))//To complete the outfit
		new /obj/item/clothing/mask/breath(get_turf(user)) // so the air gets to your mouth. Just an average mask.
		new /obj/item/tank/internals/emergency_oxygen/magic_oxygen(get_turf(user)) // so you have something to actually breathe. Near infinite.

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/antag_spawner/contract
	category = "Assistance"

/datum/spellbook_entry/item/guardian
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/holoparasite_creator/wizard
	category = "Assistance"

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will attract extradimensional \
		beings when broken. Be careful though, the kinds of creatures summoned by blood magic are \
		indiscriminate in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 1
	category = "Assistance"

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but they do not permamently kill \
		their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	limit = 1
	category = "Assistance"

/datum/spellbook_entry/item/mjolnir
	name = "Mjolnir"
	desc = "A mighty hammer on loan from Thor, God of Thunder. It crackles with barely contained power."
	item_path = /obj/item/mjolnir

/datum/spellbook_entry/item/singularity_hammer
	name = "Singularity Hammer"
	desc = "A hammer that creates an intensely powerful field of gravity where it strikes, pulling everything nearby to the point of impact."
	item_path = /obj/item/singularityhammer

/datum/spellbook_entry/item/battlemage
	name = "Battlemage Armour"
	desc = "An ensorceled suit of armour, protected by a powerful shield. The shield can completely negate sixteen attacks before being permanently depleted."
	item_path = /obj/item/clothing/suit/space/hardsuit/shielded/wizard
	limit = 1
	category = "Defensive"

/datum/spellbook_entry/item/battlemage_charge
	name = "Battlemage Armour Charges"
	desc = "A powerful defensive rune, it will grant eight additional charges to a suit of battlemage armour."
	item_path = /obj/item/wizard_armour_charge
	category = "Defensive"
	cost = 1

/datum/spellbook_entry/item/warpwhistle
	name = "Warp Whistle"
	desc = "A strange whistle that will transport you to a distant safe place on the station. There is a window of vulnerability at the beginning of every use."
	item_path = /obj/item/warpwhistle
	category = "Mobility"
	cost = 1

//THESE ARE NOT PURCHASABLE SPELLS! They're references to old spells that got removed + shit that sounds stupid but fun so we can painfully lock behind a dimmer component

/datum/spellbook_entry/challenge
	name = "Take the Challenge"
	refundable = FALSE
	category = "Challenges"
	buy_word = "Accept"

/datum/spellbook_entry/challenge/multiverse
	name = "Multiverse Sword"
	desc = "The Station gets a multiverse sword to stop you. Can you withstand the hordes of multiverse realities?"

/datum/spellbook_entry/challenge/antiwizard
	name = "Friendly Wizard Scum"
	desc = "A \"Friendly\" Wizard will protect the station, and try to kill you. They get a spellbook much like you, but will use it for \"GOOD\"."

/// How much threat we need to let these rituals happen on dynamic
#define MINIMUM_THREAT_FOR_RITUALS 85

/datum/spellbook_entry/summon
	name = "Summon Stuff"
	category = "Rituals"
	refundable = FALSE
	buy_word = "Cast"
	var/ritual_invocation // This does nothing. This is a flavor to ghosts observing a wizard.

/datum/spellbook_entry/summon/CanBuy(mob/living/carbon/human/user,obj/item/spellbook/book)
	return ..() && !times

/datum/spellbook_entry/summon/proc/say_invocation(mob/living/carbon/human/user)
	if(ritual_invocation)
		user.say(ritual_invocation, forced = "spell")

/datum/spellbook_entry/summon/ghosts
	name = "Summon Ghosts"
	desc = "Spook the crew out by making them see dead people. Be warned, ghosts are capricious and occasionally vindicative, and some will use their incredibly minor abilities to frustrate you."
	cost = 0
	ritual_invocation = "ALADAL DESINARI ODORI'IN TUUR'IS OVOR'E POR"

/datum/spellbook_entry/summon/ghosts/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	new /datum/round_event/wizard/ghost()
	times++
	to_chat(user, "<span class='notice'>You have cast summon ghosts!</span>")
	playsound(get_turf(user), 'sound/effects/ghost2.ogg', 50, 1)
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/guns
	name = "Summon Guns"
	desc = "Nothing could possibly go wrong with arming a crew of lunatics just itching for an excuse to kill you. There is a good chance that they will shoot each other first."
	ritual_invocation = "ALADAL DESINARI ODORI'IN DOL'G FLAM OVOR'E POR"

/datum/spellbook_entry/summon/guns/IsAvailable(obj/item/spellbook/book)
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(book.bypass_lock)
		return TRUE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_guns)

/datum/spellbook_entry/summon/guns/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_GUNS, user, 10)
	times++
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have cast summon guns!</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/magic
	name = "Summon Magic"
	desc = "Share the wonders of magic with the crew and show them why they aren't to be trusted with it at the same time."
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX SPERMITA OVOR'E POR"

/datum/spellbook_entry/summon/magic/IsAvailable(obj/item/spellbook/book)
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(book.bypass_lock)
		return TRUE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_magic)

/datum/spellbook_entry/summon/magic/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	rightandwrong(SUMMON_MAGIC, user, 10)
	times++
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have cast summon magic!</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/events
	name = "Summon Events"
	desc = "Give Murphy's law a little push and replace all events with special wizard ones that will confound and confuse everyone. Multiple castings increase the rate of these events."
	ritual_invocation = "ALADAL DESINARI ODORI'IN IDO'LEX MANAG'ROKT OVOR'E POR"

/datum/spellbook_entry/summon/events/IsAvailable(obj/item/spellbook/book)
	if(!SSticker.mode) // In case spellbook is placed on map
		return FALSE
	if(book.bypass_lock)
		return TRUE
	if(istype(SSticker.mode, /datum/game_mode/dynamic)) // Disable events on dynamic
		var/datum/game_mode/dynamic/mode = SSticker.mode
		if(mode.threat_level < MINIMUM_THREAT_FOR_RITUALS)
			return FALSE
	return !CONFIG_GET(flag/no_summon_events)

/datum/spellbook_entry/summon/events/Buy(mob/living/carbon/human/user,obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	summonevents()
	times++
	playsound(get_turf(user), 'sound/magic/castsummon.ogg', 50, 1)
	to_chat(user, "<span class='notice'>You have cast summon events.</span>")
	say_invocation(user)
	return TRUE

/datum/spellbook_entry/summon/events/GetInfo()
	if(times>0)
		. += "You cast it [times] times.<br>"
	return .

/datum/spellbook_entry/summon/curse_of_madness
	name = "Curse of Madness"
	desc = "Curses the station, warping the minds of everyone inside, causing lasting traumas. Warning: this spell can affect you if not cast from a safe distance."
	cost = 4
	ritual_invocation = "ALADAL DESINARI ODORI'IN PORES ENHIDO'LEN MORI MAKA TU"

/datum/spellbook_entry/summon/curse_of_madness/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	times++
	var/message
	while(!message)
		message = stripped_input(user, "Whisper a secret truth to drive your victims to madness.", "Whispers of Madness")
	curse_of_madness(user, message)
	to_chat(user, "<span class='notice'>You have cast the curse of insanity!</span>")
	playsound(user, 'sound/magic/mandswap.ogg', 50, 1)
	return TRUE

/datum/spellbook_entry/summon/wild_magic
	name = "Wild Magic Manipulation"
	desc = "multiply your remaining spell points by 70%(round down) and expand all of them to Wild Magic Manipulation. \
		You purchase random spells and items upto the spell points you expanded. Spells from this ritual will no longer be refundable even if you learned it manually, but also the book will no longer accept items to refund."
	cost = 0
	ritual_invocation = "ALADAL DESINARI ODORI'IN A'EN SPERMITEN G'ATUA H'UN OVORA DUN SPERMITUN"

/datum/spellbook_entry/summon/wild_magic/Buy(mob/living/carbon/human/user, obj/item/spellbook/book)
	if(!book.uses)
		to_chat(user, "<span class='notice'>You have no spell points for this ritual.</span>") // You can cast it again as long as you get more spell points somehow
		return FALSE
	SSblackbox.record_feedback("tally", "wizard_spell_learned", 1, name)
	book.uses = round(book.uses*WIZARD_WILDMAGIC_SPELLPOINT_MULTIPLIER) // more spell points
	book.refuses_refund = TRUE
	book.desc = "An unearthly tome that once had a great power."
	while(book.uses)
		var/datum/spellbook_entry/target = pick(book.entries)
		if(istype(target, /datum/spellbook_entry/summon/wild_magic))
			continue // Too lucky to get more spell points, but no.
		if(target.CanBuy(user,book))
			if(target.Buy(user,book))
				book.uses -= target.cost
				target.refundable = FALSE
	say_invocation(user)
	return TRUE


#undef MINIMUM_THREAT_FOR_RITUALS

/obj/item/spellbook
	name = "spell book"
	desc = "An unearthly tome that glows with power."
	icon = 'icons/obj/library.dmi'
	icon_state ="book"
	throw_speed = 2
	throw_range = 5
	w_class = WEIGHT_CLASS_TINY
	var/uses = 10
	var/temp = null
	var/refuses_refund = FALSE
	/// The mind that first used the book. Automatically assigned when a wizard spawns.
	var/datum/mind/owner
	var/list/entries = list()
	var/everything_robeless = FALSE //! if TRUE, all spells you learn become robeless. Ask admin.
	var/bypass_lock = FALSE //! bypasses some locked ritual & spell combinations. Ask admin.

/obj/item/spellbook/examine(mob/user)
	. = ..()
	if(owner)
		. += "There is a small signature on the front cover: \"[owner]\"."
	else
		. += "It appears to have no author."

/obj/item/spellbook/Initialize(mapload)
	. = ..()
	prepare_spells()

/obj/item/spellbook/attack_self(mob/user)
	if(!owner)
		if(!user.mind)
			return
		to_chat(user, "<span class='notice'>You bind the spellbook to yourself.</span>")
		owner = user.mind
		return
	if(user.mind != owner)
		if(user.mind.special_role == "apprentice")
			to_chat(user, "If you got caught sneaking a peek from your teacher's spellbook, you'd likely be expelled from the Wizard Academy. Better not.")
		else
			to_chat(user, "<span class='warning'>The [name] does not recognize you as its owner and refuses to open!</span>")
		return
	return ..()

/obj/item/spellbook/attackby(obj/item/O, mob/user, params)
	if(refuses_refund)
		to_chat(user, "<span class='warning'>Your book is powerless because of Wild Magic Manipulation ritual. The book doesn't accept the item.</span>")
		return
	if(istype(O, /obj/item/antag_spawner/contract))
		var/obj/item/antag_spawner/contract/contract = O
		if(contract.used)
			to_chat(user, "<span class='warning'>The contract has been used, you can't get your points back now!</span>")
		else
			to_chat(user, "<span class='notice'>You feed the contract back into the spellbook, refunding your points.</span>")
			uses += 2
			for(var/datum/spellbook_entry/item/contract/CT in entries)
				if(!isnull(CT.limit))
					CT.limit++
			qdel(O)
	else if(istype(O, /obj/item/antag_spawner/slaughter_demon))
		to_chat(user, "<span class='notice'>On second thought, maybe summoning a demon is a bad idea. You refund your points.</span>")
		if(istype(O, /obj/item/antag_spawner/slaughter_demon/laughter))
			uses += 1
			for(var/datum/spellbook_entry/item/hugbottle/HB in entries)
				if(!isnull(HB.limit))
					HB.limit++
		else
			uses += 2
			for(var/datum/spellbook_entry/item/bloodbottle/BB in entries)
				if(!isnull(BB.limit))
					BB.limit++
		qdel(O)

/obj/item/spellbook/proc/prepare_spells()
	var/entry_types = subtypesof(/datum/spellbook_entry) - /datum/spellbook_entry/item - /datum/spellbook_entry/summon - /datum/spellbook_entry/challenge
	for(var/type in entry_types)
		var/datum/spellbook_entry/possible_entry = new type
		if(possible_entry.IsAvailable(src))
			possible_entry.GetInfo() //loads up things for the entry that require checking spell instance.
			entries |= possible_entry
		else
			qdel(possible_entry)

/obj/item/spellbook/ui_interact(mob/user, datum/tgui/ui)
	ui = SStgui.try_update_ui(user, src, ui)
	if(!ui)
		ui = new(user, src, "Spellbook")
		ui.open()

/obj/item/spellbook/ui_data(mob/user)
	var/list/data = list()
	data["owner"] = owner
	data["points"] = uses
	return data

//This is a MASSIVE amount of data, please be careful if you remove it from static.
/obj/item/spellbook/ui_static_data(mob/user)
	var/list/data = list()
	var/list/entry_data = list()
	for(var/datum/spellbook_entry/entry as anything in entries)
		var/list/individual_entry_data = list()
		individual_entry_data["name"] = entry.name
		individual_entry_data["desc"] = entry.desc
		individual_entry_data["ref"] = REF(entry)
		individual_entry_data["clothes_req"] = entry.clothes_req
		individual_entry_data["cost"] = entry.cost
		individual_entry_data["times"] = entry.times
		individual_entry_data["cooldown"] = entry.cooldown
		individual_entry_data["cat"] = entry.category
		individual_entry_data["refundable"] = entry.refundable
		individual_entry_data["limit"] = entry.limit
		individual_entry_data["buyword"] = entry.buy_word
		entry_data += list(individual_entry_data)
	data["entries"] = entry_data
	return data

/obj/item/spellbook/ui_act(action, params)
	. = ..()
	if(.)
		return
	var/mob/living/carbon/human/wizard = usr
	if(!istype(wizard))
		to_chat(wizard, "<span class='warning'>The book doesn't seem to listen to lower life forms.</span>")
		return

	switch(action)
		if("purchase")
			var/datum/spellbook_entry/entry = locate(params["spellref"]) in entries
			if(entry?.CanBuy(wizard,src))
				if(entry.Buy(wizard,src))
					if(entry.limit)
						entry.limit--
					uses -= entry.cost
			return TRUE
		if("refund")
			var/datum/spellbook_entry/entry = locate(params["spellref"]) in entries
			if(entry?.refundable)
				var/result = entry.Refund(wizard,src)
				if(result > 0)
					if(!isnull(entry.limit))
						entry.limit += result
					uses += result
			return TRUE
	//actions that are only available if you have full spell points
	if(uses < initial(uses))
		to_chat(wizard, "<span class='warning'>You need to have all your spell points to do this!</span>")
		return
	switch(action)
		if("semirandomize")
			semirandomize(wizard)
			update_static_data(wizard) //update statics!
		if("randomize")
			randomize(wizard)
			update_static_data(wizard) //update statics!
		if("purchase_loadout")
			wizard_loadout(wizard, params["id"])
			update_static_data(wizard) //update statics!

/obj/item/spellbook/proc/wizard_loadout(mob/living/carbon/human/wizard, loadout)
	var/list/wanted_spell_names
	switch(loadout)
		if(WIZARD_LOADOUT_CLASSIC) //(Fireball>2, MM>2, Disintegrate>2, Jauntx2>4) = 10
			wanted_spell_names = list("Fireball" = 1, "Magic Missile" = 1, "Disintegrate" = 1, "Ethereal Jaunt" = 2)
		if(WIZARD_LOADOUT_MJOLNIR) //(Mjolnir>2, Summon Item>1, Mutate>2, Force Wall>1, Blink>2, Repusle>2) = 10
			wanted_spell_names = list("Mjolnir" = 1, "Summon Item" = 1, "Mutate" = 1, "Force Wall" = 1, "Blink" = 1, "Repulse" = 1)
		if(WIZARD_LOADOUT_WIZARMY) //(Soulstones>2, Staff of Change>2, A Necromantic Stone>2, Teleport>2, Ethereal Jaunt>2) = 10
			wanted_spell_names = list("Soulstone Shard Kit" = 1, "Staff of Change" = 1, "A Necromantic Stone" = 1, "Teleport" = 1, "Ethereal Jaunt" = 1)
		if(WIZARD_LOADOUT_SOULTAP) //(Soul Tap>1, Disintegrate>2, Flesh to Stone>2, Mindswap>2, Knock>1, Teleport>2) = 10
			wanted_spell_names = list("Soul Tap" = 1, "Disintegrate" = 1, "Flesh to Stone" = 1, "Mindswap" = 1, "Knock" = 1, "Teleport" = 1)
	for(var/datum/spellbook_entry/entry as anything in entries)
		if(!(entry.name in wanted_spell_names))
			continue
		if(entry.CanBuy(wizard,src))
			var/purchase_count = wanted_spell_names[entry.name]
			wanted_spell_names -= entry.name
			for(var/i in 1 to purchase_count)
				entry.Buy(wizard,src)
				if(entry.limit)
					entry.limit--
				uses -= entry.cost
			entry.refundable = FALSE //once you go loading out, you never go back
		if(!length(wanted_spell_names))
			break

	if(length(wanted_spell_names))
		stack_trace("Wizard Loadout \"[loadout]\" could not find valid spells to buy in the spellbook. Either you input a name that doesn't exist, or you overspent")
	if(uses)
		stack_trace("Wizard Loadout \"[loadout]\" does not use 10 wizard spell slots. Stop scamming players out.")

/obj/item/spellbook/proc/semirandomize(mob/living/carbon/human/wizard)
	var/list/needed_cats = list("Offensive", "Mobility")
	var/list/shuffled_entries = shuffle(entries)
	for(var/i in 1 to 2)
		for(var/datum/spellbook_entry/entry as anything in shuffled_entries)
			if(!(entry.category in needed_cats))
				continue
			if(entry?.CanBuy(wizard,src))
				if(entry.Buy(wizard,src))
					needed_cats -= entry.category //so the next loop doesn't find another offense spell
					entry.refundable = FALSE //once you go random, you never go back
					if(entry.limit)
						entry.limit--
					uses -= entry.cost
				break
	//we have given two specific category spells to the wizard. the rest are completely random!
	randomize(wizard)

/obj/item/spellbook/proc/randomize(mob/living/carbon/human/wizard)
	var/list/entries_copy = entries.Copy()
	while(uses > 0)
		var/datum/spellbook_entry/entry = pick_n_take(entries_copy)
		if(istype(entry, /datum/spellbook_entry/summon/wild_magic))
			continue
		if(entry?.CanBuy(wizard,src))
			if(entry.Buy(wizard,src))
				entry.refundable = FALSE //once you go random, you never go back
				if(entry.limit)
					entry.limit--
				uses -= entry.cost
