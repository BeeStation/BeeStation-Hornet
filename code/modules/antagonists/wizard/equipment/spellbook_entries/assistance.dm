// Wizard spells that assist the caster in some way
/datum/spellbook_entry/summonitem
	name = "Summon Item"
	desc = "Recalls a previously marked item to your hand from anywhere in the universe."
	spell_type = /datum/action/spell/summonitem
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/item/glasses_of_truesight
	name = "Glasses of Truesight"
	desc = "A pair of glasses that allows you to see those that would hide from you"
	item_path = /obj/item/clothing/glasses/red/wizard
	category = "Assistance"

/datum/spellbook_entry/raise_skeleton
	name = "Raise Lesser Skeleton"
	desc = "Lets you command an unlimited number of loyal skeletons, but they are not always able to reach their fullest potential and may attack enemies mindlessly."
	spell_type = /datum/action/spell/touch/raise_skeleton
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/charge
	name = "Charge"
	desc = "This spell can be used to recharge a variety of things in your hands, from magical artifacts to electrical components. A creative wizard can even use it to grant magical power to a fellow magic user."
	spell_type = /datum/action/spell/charge
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/shapeshift
	name = "Wild Shapeshift"
	desc = "Take on the shape of another for a time to use their natural abilities. Once you've made your choice it cannot be changed."
	spell_type = /datum/action/spell/shapeshift/wizard
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/tap
	name = "Soul Tap"
	desc = "Fuel your spells using your own soul!"
	spell_type = /datum/action/spell/tap
	category = "Assistance"
	cost = 1
	no_random = WIZARD_NORANDOM_WILDAPPRENTICE

/datum/spellbook_entry/item/soulstones
	name = "Soulstone Shard Kit"
	desc = "Soul Stone Shards are ancient tools capable of capturing and harnessing the spirits of the dead and dying. \
		The spell Artificer allows you to create arcane machines for the captured souls to pilot."
	item_path = /obj/item/storage/belt/soulstone/full
	category = "Assistance"

/datum/spellbook_entry/item/soulstones/try_equip_item(mob/living/carbon/human/user, obj/item/to_equip)
	var/was_equipped = user.equip_to_slot_if_possible(to_equip, ITEM_SLOT_BELT, disable_warning = TRUE)
	to_chat(user, ("<span class='notice'>\A [to_equip.name] has been summoned [was_equipped ? "on your waist" : "at your feet"].</span>"))

/datum/spellbook_entry/item/soulstones/buy_spell(mob/living/carbon/human/user, obj/item/spellbook/book)
	. =..()
	if(!.)
		return

	var/datum/action/spell/conjure/construct/bonus_spell = new(user.mind || user)
	bonus_spell.Grant(user)

/datum/spellbook_entry/item/necrostone
	name = "A Necromantic Stone"
	desc = "A Necromantic stone is able to resurrect three dead individuals as armed skeletal thralls for you to command."
	item_path = /obj/item/necromantic_stone
	category = "Assistance"

/datum/spellbook_entry/item/contract
	name = "Contract of Apprenticeship"
	desc = "A magical contract binding an apprentice wizard to your service, using it will summon them to your side."
	item_path = /obj/item/antag_spawner/contract
	category = "Assistance"
	refundable = TRUE

/datum/spellbook_entry/item/guardian
	name = "Guardian Deck"
	desc = "A deck of guardian tarot cards, capable of binding a personal guardian to your body. There are multiple types of guardian available, but all of them will transfer some amount of damage to you. \
	It would be wise to avoid buying these with anything capable of causing you to swap bodies with others."
	item_path = /obj/item/holoparasite_creator/wizard
	category = "Assistance"

/datum/spellbook_entry/item/blood_contract
	name = "Blood Contract"
	desc = "A magical contract sends its victim spiraling into bloodthirsty madness, causing them to see all of their old friends as demonic forces. Surely one person can't kill everyone they know without dying first?"
	item_path = /obj/item/blood_contract
	category = "Assistance"
	refundable = TRUE //Consumed on use
	limit = 1

/datum/spellbook_entry/item/bloodbottle
	name = "Bottle of Blood"
	desc = "A bottle of magically infused blood, the smell of which will \
		attract extradimensional beings when broken. Be careful though, \
		the kinds of creatures summoned by blood magic are indiscriminate \
		in their killing, and you yourself may become a victim."
	item_path = /obj/item/antag_spawner/slaughter_demon
	limit = 3
	category = "Assistance"
	refundable = TRUE

/datum/spellbook_entry/item/hugbottle
	name = "Bottle of Tickles"
	desc = "A bottle of magically infused fun, the smell of which will \
		attract adorable extradimensional beings when broken. These beings \
		are similar to slaughter demons, but they do not permanently kill \
		their victims, instead putting them in an extradimensional hugspace, \
		to be released on the demon's death. Chaotic, but not ultimately \
		damaging. The crew's reaction to the other hand could be very \
		destructive."
	item_path = /obj/item/antag_spawner/slaughter_demon/laughter
	cost = 1 //non-destructive; it's just a jape, sibling!
	limit = 3
	category = "Assistance"
	refundable = TRUE

/datum/spellbook_entry/item/staffpotential
	name = "Staff of Latent Potential"
	desc = "This staff can awaken the hidden potential within a person, provided they're willing to put up with some side-effects."
	item_path = /obj/item/gun/magic/staff/potential
	cost = 1
	category = "Assistance"

/datum/spellbook_entry/item/animation_wand
	name = "Wand of Animation"
	desc = "A wand that can animate ordinary objects into aggressively loyal minions for a short while."
	item_path = /obj/item/gun/magic/wand/animation
	category = "Assistance"
	cost = 1

/datum/spellbook_entry/item/nutrition_wand
	name = "Wand of Nutrition"
	desc = "A wand that can end universal hunger... and then some."
	item_path = /obj/item/gun/magic/wand/nutrition
	category = "Assistance"
	cost = 1
