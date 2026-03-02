// CHAPLAIN CUSTOM ARMORS //

/obj/item/clothing/suit/chaplainsuit/armor/templar/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY)

/obj/item/clothing/suit/hooded/chaplain_hoodie/leader/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY) //makes the leader hoodie immune without giving the follower hoodies immunity

/obj/item/choice_beacon/radial/holy
	name = "armaments beacon"
	desc = "Contains a set of armaments for the chaplain that have been reinforced with a silver and beryllium-bronze alloy, providing immunity to magic and its influences."

/obj/item/choice_beacon/radial/holy/canUseBeacon(mob/living/user)
	if(user.mind?.holy_role)
		return ..()
	else
		playsound(src, 'sound/machines/buzz-sigh.ogg', 40, 1)
		return FALSE

/obj/item/choice_beacon/radial/holy/generate_options(mob/living/M)
	var/list/item_list = generate_item_list()
	if(!item_list.len)
		return
	var/choice = show_radial_menu(M, src, item_list, radius = 36, require_near = TRUE, tooltips = TRUE)
	if(!QDELETED(src) && !(isnull(choice)) && !M.incapacitated && in_range(M,src))
		var/list/temp_list = typesof(/obj/item/storage/box/holy)
		for(var/V in temp_list)
			var/atom/A = V
			if(initial(A.name) == choice)
				spawn_option(A,M)
				uses--
				if(!uses)
					qdel(src)
				else
					balloon_alert(M, "[uses] use[uses > 1 ? "s" : ""] remaining")
					to_chat(M, span_notice("[uses] use[uses > 1 ? "s" : ""] remaining on the [src]."))
				return

/obj/item/choice_beacon/radial/holy/generate_item_list()
	var/static/list/item_list
	if(!item_list)
		item_list = list()
		var/list/templist = typesof(/obj/item/storage/box/holy)
		for(var/V in templist)
			var/obj/item/storage/box/holy/boxy = V
			var/image/outfit_icon = image(initial(boxy.item_icon_file), initial(boxy.item_icon_state))
			var/datum/radial_menu_choice/choice = new
			choice.image = outfit_icon
			var/info_text = "That's [icon2html(outfit_icon, usr)] "
			info_text += initial(boxy.info_text)
			choice.info = info_text
			item_list[initial(boxy.name)] = choice
	return item_list

/obj/item/choice_beacon/radial/holy/spawn_option(obj/choice,mob/living/M)
	..()
	playsound(src, 'sound/effects/pray_chaplain.ogg', 40, 1)
	SSblackbox.record_feedback("tally", "chaplain_armor", 1, "[choice]")

/obj/item/storage/box/holy
	name = "Templar Kit"
	var/icon/item_icon_file = 'icons/misc/premade_loadouts.dmi'
	var/item_icon_state = "templar"
	var/info_text = "Templar Kit, for waging a holy war against the unfaithful. \n" + span_notice("The armor can hold a variety of religious items.")

/obj/item/storage/box/holy/PopulateContents()
	new /obj/item/clothing/head/helmet/chaplain(src)
	new /obj/item/clothing/suit/chaplainsuit/armor/templar(src)

/obj/item/storage/box/holy/student
	name = "Profane Scholar Kit"
	item_icon_state = "mikolash"
	info_text = "Profane Scholar Kit, for granting the common masses the sight to the beyond. \n" + span_notice("The robe can hold a variety of religious items.")

/obj/item/storage/box/holy/student/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/templar/studentuni(src)
	new /obj/item/clothing/head/helmet/chaplain/cage(src)

/obj/item/clothing/suit/chaplainsuit/armor/templar/studentuni
	name = "student robe"
	desc = "The uniform of a bygone institute of learning."
	icon_state = "studentuni"
	inhand_icon_state = "studentuni"
	body_parts_covered = ARMS|CHEST
	allowed = list(/obj/item/storage/book/bible, /obj/item/nullrod, /obj/item/reagent_containers/cup/glass/bottle/holywater, /obj/item/storage/fancy/candle_box, /obj/item/candle, /obj/item/tank/internals/emergency_oxygen, /obj/item/tank/internals/plasmaman)

/obj/item/storage/box/holy/sentinel
	name = "Stone Sentinel Kit"
	item_icon_state = "giantdad"
	info_text = "Stone Sentinel Kit, for making a stalwart stance against herecy. \n" + span_notice("The armor can hold a variety of religious items.")

/obj/item/storage/box/holy/sentinel/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/ancient(src)
	new /obj/item/clothing/head/helmet/chaplain/ancient(src)

/obj/item/storage/box/holy/witchhunter
	name = "Witchhunter Kit"
	item_icon_state = "witchhunter"
	info_text = "Witchhunter Kit, for burning the wicked at the stake. \n" + span_notice("The garb can hold a variety of religious items. \nComes with a crucifix that wards against hexes.")

/obj/item/storage/box/holy/witchhunter/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/witchhunter(src)
	new /obj/item/clothing/head/helmet/chaplain/witchunter_hat(src)
	new /obj/item/clothing/neck/crucifix(src)



/obj/item/storage/box/holy/graverobber
	name = "Grave Robber Kit"
	item_icon_state = "graverobber"
	info_text = "Grave Robber Kit, for finding the treasures of those who parted this world. \n" + span_notice("The coat can hold a variety of religious items. \nPickaxe not included.")

/obj/item/storage/box/holy/graverobber/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/templar/graverobber_coat(src)
	new /obj/item/clothing/under/rank/civilian/graverobber_under(src)
	new /obj/item/clothing/head/helmet/chaplain/graverobber_hat(src)
	new /obj/item/clothing/gloves/graverobber_gloves(src)

/obj/item/storage/box/holy/adept
	name = "Divine Adept Kit"
	item_icon_state = "crusader"
	info_text = "Divine Adept Kit, for standing stalward with unvavering faith. \n" + span_notice("The robes can hold a variety of religious items.")

/obj/item/storage/box/holy/adept/PopulateContents()
	new /obj/item/clothing/suit/chaplainsuit/armor/templar/adept(src)
	new /obj/item/clothing/head/helmet/chaplain/adept(src)

/obj/item/storage/box/holy/follower
	name = "Followers of the Chaplain Kit"
	item_icon_state = "leader"
	info_text = "Divine Adept Kit, for starting a non-heretical cult of your own. \n" + span_notice("The hoodie can hold a variety of religious items. \nComes with four follower hoodies.")

/obj/item/storage/box/holy/follower/PopulateContents()
	new /obj/item/clothing/suit/hooded/chaplain_hoodie/leader(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)
	new /obj/item/clothing/suit/hooded/chaplain_hoodie(src)


// CHAPLAIN NULLROD AND CUSTOM WEAPONS //

/obj/item/nullrod
	name = "null rod"
	desc = "A rod of pure obsidian; its very presence disrupts and dampens the powers of Nar'Sie and Ratvar's followers."
	icon_state = "nullrod"
	inhand_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'

	force = 18
	throw_speed = 3
	throw_range = 4
	throwforce = 10
	item_flags = ISWEAPON
	w_class = WEIGHT_CLASS_TINY
	obj_flags = UNIQUE_RENAME
	var/chaplain_spawnable = TRUE


/obj/item/nullrod/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, \
		_source = INNATE_TRAIT, \
		antimagic_flags = MAGIC_RESISTANCE | MAGIC_RESISTANCE_HOLY \
	)
	AddComponent(/datum/component/effect_remover, \
		success_feedback = "You disrupt the magic of %THEEFFECT with %THEWEAPON.", \
		success_forcesay = "BEGONE FOUL MAGIKS!!", \
		on_clear_callback = CALLBACK(src, PROC_REF(on_cult_rune_removed)), \
		effects_we_clear = list(/obj/effect/rune, /obj/effect/heretic_rune) \
	)

/obj/item/nullrod/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is killing [user.p_them()]self with [src]! It looks like [user.p_theyre()] trying to get closer to god!"))
	return (BRUTELOSS|FIRELOSS)

/obj/item/nullrod/attack_self(mob/user)
	. = ..()
	if(user.mind && (user.mind.holy_role) && !current_skin)
		reskin_holy_weapon(user)

/obj/item/nullrod/proc/reskin_holy_weapon(mob/M)
	if(isnull(unique_reskin))
		unique_reskin = list(
			"Null Rod" = /obj/item/nullrod,
			"God Hand" = /obj/item/nullrod/godhand,
			"Red Holy Staff" = /obj/item/nullrod/staff,
			"Blue Holy Staff" = /obj/item/nullrod/staff/blue,
			"Claymore" = /obj/item/nullrod/claymore,
			"Dark Blade" = /obj/item/nullrod/claymore/darkblade,
			"Sacred Chainsaw Sword" = /obj/item/nullrod/claymore/chainsaw_sword,
			"Force Weapon" = /obj/item/nullrod/claymore/glowing,
			"Hanzo Steel" = /obj/item/nullrod/claymore/katana,
			"Extradimensional Blade" = /obj/item/nullrod/claymore/multiverse,
			"Light Energy Sword" = /obj/item/nullrod/claymore/saber,
			"Dark Energy Sword" = /obj/item/nullrod/claymore/saber/red,
			"Nautical Energy Sword" = /obj/item/nullrod/claymore/saber/pirate,
			"UNREAL SORD" = /obj/item/nullrod/sord,
			"Reaper Scythe" = /obj/item/nullrod/scythe,
			"High Frequency Blade" = /obj/item/nullrod/scythe/vibro,
			"Dormant Spellblade" = /obj/item/nullrod/scythe/spellblade,
			"Possessed Blade" = /obj/item/nullrod/scythe/talking,
			"Possessed Chainsaw Sword" = /obj/item/nullrod/scythe/talking/chainsword,
			"Relic War Hammer" = /obj/item/nullrod/hammmer,
			"Chainsaw Hand" = /obj/item/nullrod/chainsaw,
			"Clown Dagger" = /obj/item/nullrod/clown,
			"Pride-struck Hammer" = /obj/item/nullrod/pride_hammer,
			"Holy Whip" = /obj/item/nullrod/whip,
			"Atheist's Fedora" = /obj/item/nullrod/fedora,
			"Dark Blessing" = /obj/item/nullrod/armblade,
			"Unholy Blessing" = /obj/item/nullrod/armblade/tentacle,
			"Carp-Sie Plushie" = /obj/item/nullrod/carp,
			"Monk's Staff" = /obj/item/nullrod/bostaff,
			"Arrythmic Knife" = /obj/item/nullrod/tribal_knife,
			"Unholy Pitchfork" = /obj/item/nullrod/pitchfork,
			"Egyptian Staff" = /obj/item/nullrod/egyptian,
			"Hypertool" = /obj/item/nullrod/hypertool,
			"Ancient Spear" = /obj/item/nullrod/spear,
			"Rainbow Knife" = /obj/item/nullrod/rainbow_knife
		)

	if(isnull(unique_reskin_icon))
		unique_reskin_icon = list(
			"Null Rod" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "nullrod"),
			"God Hand" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "disintegrate"),
			"Red Holy Staff" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "godstaff-red"),
			"Blue Holy Staff" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "godstaff-blue"),
			"Claymore" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "claymore"),
			"Dark Blade" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "cultblade"),
			"Sacred Chainsaw Sword" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "chainswordon"),
			"Force Weapon" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "swordon"),
			"Hanzo Steel" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "katana"),
			"Extradimensional Blade" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "multiverse"),
			"Light Energy Sword" = image(icon = 'icons/obj/transforming_energy.dmi', icon_state = "swordblue"),
			"Dark Energy Sword" = image(icon = 'icons/obj/transforming_energy.dmi', icon_state = "swordred"),
			"Nautical Energy Sword" = image(icon = 'icons/obj/transforming_energy.dmi', icon_state = "cutlass1"),
			"UNREAL SORD" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "sord"),
			"Reaper Scythe" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "scythe1"),
			"High Frequency Blade" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "hfrequency1"),
			"Dormant Spellblade" = image(icon = 'icons/obj/guns/magic.dmi', icon_state = "spellblade"),
			"Possessed Blade" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "talking_sword"),
			"Possessed Chainsaw Sword" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "chainswordon"),
			"Relic War Hammer" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "hammeron"),
			"Chainsaw Hand" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "chainsaw_on"),
			"Clown Dagger" = image(icon = 'icons/obj/wizard.dmi', icon_state = "clownrender"),
			"Pride-struck Hammer" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "pride"),
			"Holy Whip" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "chain"),
			"Atheist's Fedora" = image(icon = 'icons/obj/clothing/head/hats.dmi', icon_state = "fedora"),
			"Dark Blessing" = image(icon = 'icons/obj/changeling_items.dmi', icon_state = "arm_blade"),
			"Unholy Blessing" = image(icon = 'icons/obj/changeling_items.dmi', icon_state = "tentacle"),
			"Carp-Sie Plushie" = image(icon = 'icons/obj/plushes.dmi', icon_state = "carpplush"),
			"Monk's Staff" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "bostaff0"),
			"Arrythmic Knife" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "crysknife"),
			"Unholy Pitchfork" = image(icon = 'icons/obj/items_and_weapons.dmi', icon_state = "pitchfork0"),
			"Egyptian Staff" = image(icon = 'icons/obj/guns/magic.dmi', icon_state = "pharoah_sceptre"),
			"Hypertool" = image(icon = 'icons/obj/device.dmi', icon_state = "hypertool"),
			"Ancient Spear" = image(icon = 'icons/obj/clockwork_objects.dmi', icon_state = "ratvarian_spear"),
			"Rainbow Knife" = image(icon = 'icons/obj/slimecrossing.dmi', icon_state = "rainbowknife")
		)

	var/choice = show_radial_menu(M, src, unique_reskin_icon, radius = 42, require_near = TRUE, tooltips = TRUE)
	SSblackbox.record_feedback("tally", "chaplain_weapon", 1, "[choice]") //Keeping this here just in case removing it breaks something
	if(!QDELETED(src) && choice && !current_skin && !M.incapacitated && in_range(M,src))
		qdel(src)
		var A = unique_reskin[choice]
		var/obj/item/nullrod/holy_weapon = new A
		holy_weapon.current_skin = choice
		M.put_in_active_hand(holy_weapon)


/obj/item/nullrod/proc/on_cult_rune_removed(obj/effect/target, mob/living/user)
	if(!istype(target, /obj/effect/rune))
		return

	var/obj/effect/rune/target_rune = target
	if(target_rune.log_when_erased)
		log_game("[target_rune.cultist_name] rune erased by [key_name(user)] using a null rod.")
		message_admins("[ADMIN_LOOKUPFLW(user)] erased a [target_rune.cultist_name] rune with a null rod.")
	SSshuttle.shuttle_purchase_requirements_met[SHUTTLE_UNLOCK_NARNAR] = TRUE

/obj/item/nullrod/godhand
	icon_state = "disintegrate"
	inhand_icon_state = "disintegrate"
	lefthand_file = 'icons/mob/inhands/misc/touchspell_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/misc/touchspell_righthand.dmi'
	name = "god hand"
	desc = "This hand of yours glows with an awesome power!"
	item_flags = ABSTRACT | DROPDEL
	w_class = WEIGHT_CLASS_HUGE
	hitsound = 'sound/weapons/sear.ogg'
	damtype = BURN
	attack_verb_continuous = list("punches", "cross counters", "pummels")
	attack_verb_simple = list("punch", "cross counter", "pummel")


/obj/item/nullrod/godhand/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)

/obj/item/nullrod/staff
	icon_state = "godstaff-red"
	inhand_icon_state = "godstaff-red"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	name = "red holy staff"
	desc = "It has a mysterious, protective aura when you channel the staff"
	w_class = WEIGHT_CLASS_HUGE
	force = 5
	armour_penetration = 100 //Just like wizard staves, but it only does 5 damage. It's magical.
	slot_flags = ITEM_SLOT_BACK

	//Keep in mind it can only block once once per cooldown. This staff's whole purpose is defense so it's good at it when it does
	canblock = TRUE
	block_flags = BLOCKING_ACTIVE | BLOCKING_PROJECTILE | BLOCKING_UNBALANCE | BLOCKING_UNBLOCKABLE
	block_power = 100 //No stamina damage for this one
	var/shield_icon = "shield-red"

/obj/item/nullrod/staff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=5, force_wielded=5, block_power_unwielded=100, block_power_wielded=100)

/obj/item/nullrod/staff/worn_overlays(mutable_appearance/standing, isinhands = FALSE, icon_file, item_layer, atom/origin)
	. = ..()
	if(isinhands)
		. += mutable_appearance('icons/effects/effects.dmi', shield_icon, MOB_SHIELD_LAYER)

/obj/item/nullrod/staff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(ISWIELDED(src))
		return ..()
	return FALSE

/obj/item/nullrod/staff/blue
	name = "blue holy staff"
	icon_state = "godstaff-blue"
	inhand_icon_state = "godstaff-blue"
	shield_icon = "shield-old"

/obj/item/nullrod/claymore
	name = "holy claymore"
	desc = "A weapon fit for a crusade!"
	icon_state = "claymore"
	inhand_icon_state = "claymore"
	worn_icon_state = "claymore"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	slot_flags = ITEM_SLOT_BACK | ITEM_SLOT_BELT
	block_flags = BLOCKING_NASTY | BLOCKING_ACTIVE
	canblock = TRUE
	block_power = 25
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/nullrod/claymore/darkblade
	name = "dark blade"
	desc = "Spread the glory of the dark gods!"
	icon_state = "cultblade"
	inhand_icon_state = "cultblade"
	worn_icon_state = "cultblade"
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/hallucinations/growl1.ogg'

/obj/item/nullrod/claymore/chainsaw_sword
	name = "sacred chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsaw_hit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 1.5 //slower than a real saw

/obj/item/nullrod/claymore/glowing
	name = "force weapon"
	desc = "The blade glows with the power of faith. Or possibly a battery."
	icon_state = "swordon"
	inhand_icon_state = "swordon"
	worn_icon_state = "swordon"
	slot_flags = ITEM_SLOT_BELT

/obj/item/nullrod/claymore/katana
	name = "\improper Hanzo steel"
	desc = "Capable of cutting clean through a holy claymore."
	icon_state = "katana"
	inhand_icon_state = "katana"
	worn_icon_state = "katana"
	slot_flags = ITEM_SLOT_BELT | ITEM_SLOT_BACK

/obj/item/nullrod/claymore/multiverse
	name = "extradimensional blade"
	desc = "Once the harbinger of an interdimensional war, its sharpness fluctuates wildly."
	icon_state = "multiverse"
	inhand_icon_state = "multiverse"
	worn_icon_state = "multiverse"
	slot_flags = ITEM_SLOT_BACK

/obj/item/nullrod/claymore/multiverse/attack(mob/living/carbon/M, mob/living/carbon/user)
	force = rand(1, 30)
	..()

/obj/item/nullrod/claymore/saber
	name = "light energy sword"
	desc = "If you strike me down, I shall become more robust than you can possibly imagine."
	icon = 'icons/obj/transforming_energy.dmi'
	icon_state = "e_sword_on_blue"
	inhand_icon_state = "e_sword_on_blue"
	worn_icon_state = "swordblue"
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/blade1.ogg'
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY | BLOCKING_UNBLOCKABLE

/obj/item/nullrod/claymore/saber/red
	name = "dark energy sword"
	desc = "Woefully ineffective when used on steep terrain." //Anakin used his BLUE lightsaber in episode IV, FOOL
	icon_state = "e_sword_on_red"
	inhand_icon_state = "e_sword_on_red"
	worn_icon_state = "swordred"

/obj/item/nullrod/claymore/saber/pirate
	name = "nautical energy sword"
	desc = "Convincing HR that your religion involved piracy was no mean feat."
	icon_state = "e_cutlass_on"
	inhand_icon_state = "e_cutlass_on"
	worn_icon_state = "swordred"

/obj/item/nullrod/sord
	name = "\improper UNREAL SORD"
	desc = "This thing is so unspeakably HOLY you are having a hard time even holding it."
	icon_state = "sord"
	inhand_icon_state = "sord"
	worn_icon_state = "sord"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	force = 4.13
	throwforce = 1
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	block_flags = BLOCKING_ACTIVE
	canblock = TRUE

/obj/item/nullrod/sord/on_block(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	. = ..()
	owner.attackby(src, owner)
	owner.visible_message(span_danger("[owner] can't get a grip, and stabs himself with [src] while trying to parry the [hitby]!"))

/obj/item/nullrod/scythe
	name = "reaper scythe"
	desc = "Ask not for whom the bell tolls..."
	icon_state = "scythe1"
	inhand_icon_state = "scythe1"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	w_class = WEIGHT_CLASS_BULKY
	armour_penetration = 35
	canblock = TRUE
	block_power = 50
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK
	slot_flags = ITEM_SLOT_BACK
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("chops", "slices", "cuts", "reaps")
	attack_verb_simple = list("chop", "slice", "cut", "reap")

/obj/item/nullrod/scythe/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/butchering, 70, 110) //the harvest gives a high bonus chance

/obj/item/nullrod/scythe/vibro
	name = "high frequency blade"
	desc = "Bad references are the DNA of the soul."
	icon_state = "hfrequency0"
	inhand_icon_state = "hfrequency1"
	worn_icon_state = "hfrequency0"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	attack_verb_continuous = list("chops", "slices", "cuts", "zandatsu's")
	attack_verb_simple = list("chop", "slice", "cut", "zandatsu")
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/spellblade
	name = "dormant spellblade"
	desc = "The blade grants the wielder nearly limitless power...if they can figure out how to turn it on, that is."
	icon_state = "spellblade"
	inhand_icon_state = "spellblade"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "spellblade"
	icon = 'icons/obj/guns/magic.dmi'
	hitsound = 'sound/weapons/rapierhit.ogg'

/obj/item/nullrod/scythe/talking
	name = "possessed blade"
	desc = "When the station falls into chaos, it's nice to have a friend by your side."
	icon_state = "talking_sword"
	inhand_icon_state = "talking_sword"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "talking_sword"
	attack_verb_continuous = list("chops", "slices", "cuts")
	attack_verb_simple= list("chop", "slice", "cut")
	hitsound = 'sound/weapons/rapierhit.ogg'
	var/possessed = FALSE

/obj/item/nullrod/scythe/talking/relaymove(mob/living/user, direction)
	return //stops buckled message spam for the ghost.

/obj/item/nullrod/scythe/talking/attack_self(mob/living/user)
	if(possessed)
		return
	if(!(GLOB.ghost_role_flags & GHOSTROLE_STATION_SENTIENCE))
		to_chat(user, span_notice("Anomalous otherworldly energies block you from awakening the blade!"))
		return

	to_chat(user, "You attempt to wake the spirit of the blade...")

	possessed = TRUE

	var/datum/poll_config/config = new()
	config.question = "Do you want to play as the spirit of [user.real_name]'s blade?"
	config.check_jobban = ROLE_SPECTRAL_BLADE
	config.poll_time = 10 SECONDS
	config.ignore_category = POLL_IGNORE_SPECTRAL_BLADE
	config.jump_target = user
	config.role_name_text = "blade spirit"
	config.alert_pic = user
	var/mob/dead/observer/candidate = SSpolling.poll_ghosts_for_target(config, user)

	if(candidate)
		var/mob/living/simple_animal/shade/S = new(src)
		S.ckey = candidate.ckey
		S.fully_replace_character_name(null, "The spirit of [name]")
		ADD_TRAIT(S, TRAIT_GODMODE, TRAIT_GENERIC)
		S.copy_languages(user, LANGUAGE_MASTER)	//Make sure the sword can understand and communicate with the user.
		S.get_language_holder().omnitongue = TRUE //Grants omnitongue
		var/input = sanitize_name(stripped_input(S,"What are you named?", ,"", MAX_NAME_LEN))

		if(src && input)
			name = input
			S.fully_replace_character_name(null, "The spirit of [input]")
	else
		to_chat(user, "The blade is dormant. Maybe you can try again later.")
		possessed = FALSE

/obj/item/nullrod/scythe/talking/Destroy()
	for(var/mob/living/simple_animal/shade/S in contents)
		to_chat(S, "You were destroyed!")
		qdel(S)
	return ..()

/obj/item/nullrod/scythe/talking/chainsword
	name = "possessed chainsaw sword"
	desc = "Suffer not a heretic to live."
	icon_state = "chainswordon"
	inhand_icon_state = "chainswordon"
	worn_icon_state = "chainswordon"
	chaplain_spawnable = FALSE
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsaw_hit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 0.5 //faster than normal saw

/obj/item/nullrod/hammmer
	name = "relic war hammer"
	desc = "This war hammer cost the chaplain forty thousand space dollars."
	icon_state = "hammeron"
	inhand_icon_state = "hammeron"
	worn_icon_state = "hammeron"
	lefthand_file = 'icons/mob/inhands/weapons/hammers_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/hammers_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	w_class = WEIGHT_CLASS_HUGE
	attack_verb_continuous = list("smashes", "bashes", "hammers", "crunches")
	attack_verb_simple = list("smash", "bash", "hammer", "crunch")
	attack_weight = 2

/obj/item/nullrod/chainsaw
	name = "chainsaw hand"
	desc = "Good? Bad? You're the guy with the chainsaw hand."
	icon_state = "chainsaw_on"
	inhand_icon_state = "mounted_chainsaw"
	lefthand_file = 'icons/mob/inhands/weapons/chainsaw_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/chainsaw_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	item_flags = ABSTRACT | ISWEAPON
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("saws", "tears", "lacerates", "cuts", "chops", "dices")
	attack_verb_simple = list("saw", "tear", "lacerate", "cut", "chop", "dice")
	hitsound = 'sound/weapons/chainsaw_hit.ogg'
	tool_behaviour = TOOL_SAW
	toolspeed = 2 //slower than a real saw
	attack_weight = 2



/obj/item/nullrod/chainsaw/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
	AddComponent(/datum/component/butchering, 30, 100, 0, hitsound)

/obj/item/nullrod/clown
	name = "clown dagger"
	desc = "Used for absolutely hilarious sacrifices."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "clownrender"
	inhand_icon_state = "cultdagger"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	worn_icon_state = "render"
	hitsound = 'sound/items/bikehorn.ogg'
	sharpness = SHARP
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")

/obj/item/nullrod/pride_hammer
	name = "Pride-struck Hammer"
	desc = "It resonates an aura of Pride."
	icon_state = "pride"
	worn_icon_state = "pride"
	force = 16
	throwforce = 15
	w_class = 4
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("attacks", "smashes", "crushes", "splatters", "cracks")
	attack_verb_simple = list("attack", "smash", "crush", "splatter", "crack")
	hitsound = 'sound/weapons/blade1.ogg'
	attack_weight = 2

/obj/item/nullrod/pride_hammer/afterattack(atom/A as mob|obj|turf|area, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(prob(30) && ishuman(A))
		var/mob/living/carbon/human/H = A
		user.reagents.trans_to(H, user.reagents.total_volume, 1, 1, 0, transfered_by = user)
		to_chat(user, span_notice("Your pride reflects on [H]."))
		to_chat(H, span_userdanger("You feel insecure, taking on [user]'s burden."))

/obj/item/nullrod/whip
	name = "holy whip"
	desc = "What a terrible night to be on Space Station 13."
	icon_state = "chain"
	inhand_icon_state = "chain"
	worn_icon_state = "whip"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	attack_verb_continuous = list("whips", "lashes")
	attack_verb_simple = list("whip", "lash")
	hitsound = 'sound/weapons/chainhit.ogg'

/obj/item/nullrod/fedora
	name = "atheist's fedora"
	desc = "The brim of the hat is as sharp as your wit. The edge would hurt almost as much as disproving the existence of God."
	icon_state = "fedora"
	inhand_icon_state = "fedora"
	slot_flags = ITEM_SLOT_HEAD
	icon = 'icons/obj/clothing/head/hats.dmi'
	worn_icon = 'icons/mob/clothing/head/hats.dmi'
	force = 0
	throw_speed = 4
	throw_range = 7
	throwforce = 30
	sharpness = SHARP
	bleed_force = BLEED_CUT
	attack_verb_continuous = list("enlightens", "redpills")
	attack_verb_simple = list("enlighten", "redpill")

/obj/item/nullrod/armblade
	name = "dark blessing"
	desc = "Particularly twisted deities grant gifts of dubious value."
	icon = 'icons/obj/changeling_items.dmi'
	icon_state = "arm_blade"
	inhand_icon_state = "arm_blade"
	lefthand_file = 'icons/mob/inhands/antag/changeling_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/changeling_righthand.dmi'
	slot_flags = null
	item_flags = ABSTRACT | ISWEAPON
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT

/obj/item/nullrod/armblade/Initialize(mapload)
	. = ..()
	ADD_TRAIT(src, TRAIT_NODROP, HAND_REPLACEMENT_TRAIT)
//	ADD_TRAIT(src, TRAIT_DOOR_PRYER, INNATE_TRAIT)	//uncomment if you want chaplains to have AA as a null rod option. The armblade will behave even more like a changeling one then!
	AddComponent(/datum/component/butchering, 80, 70)

/obj/item/nullrod/armblade/tentacle
	name = "unholy blessing"
	icon_state = "tentacle"
	inhand_icon_state = "tentacle"

/obj/item/nullrod/carp
	name = "carp-sie plushie"
	desc = "An adorable stuffed toy that resembles the god of all carp. The teeth look pretty sharp. Activate it to receive the blessing of Carp-Sie."
	icon = 'icons/obj/plushes.dmi'
	icon_state = "map_plushie_carp"
	greyscale_config = /datum/greyscale_config/plush_carp
	greyscale_colors = "#cc99ff#000000"
	inhand_icon_state = "carp_plushie"
	worn_icon_state = "nullrod"
	lefthand_file = 'icons/mob/inhands/items_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/items_righthand.dmi'
	force = 15
	attack_verb_continuous = list("bites", "eats", "fin slaps")
	attack_verb_simple = list("bite", "eat", "fin slap")
	hitsound = 'sound/weapons/bite.ogg'
	var/used_blessing = FALSE

/obj/item/nullrod/carp/attack_self(mob/living/user)
	if(used_blessing)
	else if(user.mind && (user.mind.holy_role))
		to_chat(user, "You are blessed by Carp-Sie. Wild space carp will no longer attack you.")
		user.faction |= FACTION_CARP
		used_blessing = TRUE

/obj/item/nullrod/bostaff
	name = "monk's staff"
	desc = "A long, tall staff made of polished wood. Traditionally used in ancient old-Earth martial arts, it is now used to harass the clown."
	w_class = WEIGHT_CLASS_BULKY
	force = 10
	throwforce = 20
	throw_speed = 2
	slot_flags = ITEM_SLOT_BACK
	sharpness = BLUNT
	hitsound = 'sound/effects/woodhit.ogg'
	attack_verb_continuous = list("smashes", "slams", "whacks", "thwacks")
	attack_verb_simple = list("smash", "slam", "whack", "thwack")
	icon = 'icons/obj/items_and_weapons.dmi'
	icon_state = "bostaff0"
	inhand_icon_state = null
	worn_icon_state = "bostaff0"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'

	canblock = TRUE
	block_power = 75
	block_flags = BLOCKING_ACTIVE | BLOCKING_COUNTERATTACK | BLOCKING_UNBALANCE

/obj/item/nullrod/bostaff/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/two_handed, force_unwielded=10, force_wielded=14, block_power_unwielded=75, block_power_wielded=75, icon_wielded="bostaff1")

/obj/item/nullrod/bostaff/update_icon_state()
	icon_state = "bostaff0"
	..()

/obj/item/nullrod/bostaff/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	if(ISWIELDED(src))
		return ..()
	return FALSE

/obj/item/nullrod/tribal_knife
	name = "arrhythmic knife"
	desc = "They say fear is the true mind killer, but stabbing them in the head works too. Honour compels you to not sheathe it once drawn."
	icon_state = "crysknife"
	inhand_icon_state = "crysknife"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	w_class = WEIGHT_CLASS_HUGE
	sharpness = SHARP
	bleed_force = BLEED_CUT
	slot_flags = null
	hitsound = 'sound/weapons/bladeslice.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "cut")
	item_flags = SLOWS_WHILE_IN_HAND

/obj/item/nullrod/tribal_knife/Initialize(mapload)
	. = ..()
	START_PROCESSING(SSobj, src)
	AddComponent(/datum/component/butchering, 50, 100, null, null, TRUE)

/obj/item/nullrod/tribal_knife/Destroy()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/nullrod/tribal_knife/process()
	slowdown = rand(-10, 10)/10
	if(iscarbon(loc))
		var/mob/living/carbon/wielder = loc
		if(wielder.is_holding(src))
			wielder.update_equipment_speed_mods()

/obj/item/nullrod/pitchfork
	name = "unholy pitchfork"
	desc = "Holding this makes you look absolutely devilish."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "pitchfork0"
	inhand_icon_state = "pitchfork0"
	lefthand_file = 'icons/mob/inhands/weapons/polearms_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/polearms_righthand.dmi'
	worn_icon_state = "pitchfork0"
	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("pokes", "impales", "pierces", "jabs")
	attack_verb_simple = list("poke", "impale", "pierce", "jab")
	hitsound = 'sound/weapons/bladeslice.ogg'
	sharpness = SHARP
	bleed_force = BLEED_CUT

/obj/item/nullrod/egyptian
	name = "egyptian staff"
	desc = "A tutorial in mummification is carved into the staff. You could probably craft the wraps if you had some cloth."
	icon = 'icons/obj/guns/magic.dmi'
	icon_state = "pharoah_sceptre"
	inhand_icon_state = "pharoah_sceptre"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	worn_icon_state = "pharoah_sceptre"
	w_class = WEIGHT_CLASS_LARGE
	slot_flags = ITEM_SLOT_BACK
	attack_verb_continuous = list("bashes", "smacks", "whacks")
	attack_verb_simple = list("bash", "smack", "whack")

/obj/item/nullrod/hypertool
	name = "hypertool"
	desc = "A tool so powerful even you cannot perfectly use it."
	icon = 'icons/obj/device.dmi'
	icon_state = "hypertool"
	inhand_icon_state = "hypertool"
	worn_icon_state = "hypertool"
	lefthand_file = 'icons/mob/inhands/equipment/tools_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/tools_righthand.dmi'
	slot_flags = ITEM_SLOT_BELT
	armour_penetration = 35
	damtype = BRAIN
	attack_verb_continuous = list("pulses", "mends", "cuts")
	attack_verb_simple = list("pulse", "mend", "cut")
	hitsound = 'sound/effects/sparks4.ogg'

/obj/item/nullrod/spear
	name = "ancient spear"
	desc = "An ancient spear made of brass, I mean gold, I mean bronze. It looks highly mechanical."
	icon = 'icons/obj/weapons/spear.dmi'
	icon_state = "ratvarian_spear"
	inhand_icon_state = "ratvarian_spear"
	lefthand_file = 'icons/mob/inhands/antag/clockwork_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/antag/clockwork_righthand.dmi'
	icon = 'icons/obj/clockwork_objects.dmi'
	slot_flags = ITEM_SLOT_BELT
	armour_penetration = 10
	sharpness = SHARP
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_BULKY
	attack_verb_continuous = list("stabs", "pokes", "slashes", "clocks")
	attack_verb_simple = list("stab", "poke", "slash", "clock")
	hitsound = 'sound/weapons/bladeslice.ogg'

/obj/item/nullrod/rainbow_knife
	name = "rainbow knife"
	desc = "A strange, transparent knife which constantly shifts color. This one glitters with a holy aura."
	icon = 'icons/obj/knives.dmi'
	icon_state = "rainbowknife"
	inhand_icon_state = "rainbowknife"
	force = 15
	throwforce = 15
	damtype = BRUTE
	hitsound = 'sound/weapons/bladeslice.ogg'
	throw_speed = 3
	throw_range = 6
	tool_behaviour = TOOL_KNIFE
	sharpness = SHARP
	w_class = WEIGHT_CLASS_SMALL

/obj/item/nullrod/rainbow_knife/afterattack(atom/O, mob/user, proximity)
	if(proximity && istype(O, /mob/living))
		damtype = pick(BRUTE, BURN, TOX, OXY, CLONE)
	switch(damtype)
		if(BRUTE)
			hitsound = 'sound/weapons/bladeslice.ogg'
			attack_verb_continuous = list("slashes", "slices", "cuts")
			attack_verb_simple = list("slash", "slice", "cut")
		if(BURN)
			hitsound = 'sound/weapons/sear.ogg'
			attack_verb_continuous = list("burns", "singes", "heats")
			attack_verb_simple = list("burn", "singe", "heat")
		if(TOX)
			hitsound = 'sound/weapons/pierce.ogg'
			attack_verb_continuous = list("poisons", "doses", "toxifies")
			attack_verb_simple = list("poison", "dose", "toxify")
		if(OXY)
			hitsound = 'sound/effects/space_wind.ogg'
			attack_verb_continuous = list("suffocates", "winds", "vacuums")
			attack_verb_simple = list("suffocate", "wind", "vacuum")
		if(CLONE)
			hitsound = 'sound/items/geiger/ext1.ogg'
			attack_verb_continuous = list("irradiates", "mutates", "maligns")
			attack_verb_simple = list("irradiate", "mutate", "malign")
	return ..()

