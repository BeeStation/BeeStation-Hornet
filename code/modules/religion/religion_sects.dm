/**
  * # Religious Sects
  *
  * Religious Sects are a way to convert the fun of having an active 'god' (admin) to code-mechanics so you aren't having to press adminwho.
  *
  * Sects are not meant to overwrite the fun of choosing a custom god/religion, but meant to enhance it.
  * The idea is that Space Jesus (or whoever you worship) can be an evil bloodgod who takes the lifeforce out of people, a nature lover, or all things righteous and good. You decide!
  *
  */
/datum/religion_sect
	/// Name of the religious sect
	var/name = "Religious Sect Base Type"
	/// Flavorful quote given about the sect, used in tgui
	var/quote = "Hail Coderbus! Coderbus #1! Fuck the playerbase!"
	/// Opening message when someone gets converted
	var/desc = "Oh My! What Do We Have Here?!!?!?!?"
	/// Tgui icon used by this sect - https://fontawesome.com/icons/
	var/tgui_icon = "bug"
	/// holder for alignments.
	var/alignment = ALIGNMENT_GOOD
	/// Does this require something before being available as an option?
	var/starter = TRUE
	/// species traits that block you from picking
	var/invalidating_qualities = NONE
	/// The Sect's 'Mana'
	var/favor = 0 //MANA!
	/// The max amount of favor the sect can have
	var/max_favor = 1000
	/// The default value for an item that can be sacrificed
	var/default_item_favor = 5
	/// Turns into 'desired_items_typecache', and is optionally assoc'd to sacrifice instructions if needed.
	var/list/desired_items
	/// Autopopulated by `desired_items`
	var/list/desired_items_typecache
	/// Lists of rites by type. Converts itself into a list of rites with "name - desc (favor_cost)" = type
	var/list/rites_list
	/// Changes the Altar of Gods icon
	var/altar_icon
	/// Changes the Altar of Gods icon_state
	var/altar_icon_state
	/// Currently Active (non-deleted) rites
	var/list/active_rites
	/// Whether the structure has CANDLE OVERLAYS!
	var/candle_overlay = TRUE


/datum/religion_sect/New()
	. = ..()
	if(desired_items)
		desired_items_typecache = typecacheof(desired_items)
	on_select()

/// Activates once selected
/datum/religion_sect/proc/on_select()
	SHOULD_CALL_PARENT(TRUE)
	SSblackbox.record_feedback("text", "sect_chosen", 1, name)

/// Activates once selected and on newjoins, oriented around people who become holy.
/datum/religion_sect/proc/on_conversion(mob/living/chap)
	SHOULD_CALL_PARENT(TRUE)
	to_chat(chap, "<span class='bold notice'>\"[quote]\"</span>")
	to_chat(chap, "<span class='notice'>[desc]</span>")

/// Returns TRUE if the item can be sacrificed. Can be modified to fit item being tested as well as person offering. Returning TRUE will stop the attackby sequence and proceed to on_sacrifice.
/datum/religion_sect/proc/can_sacrifice(obj/item/I, mob/living/chap)
	. = TRUE
	if(chap.mind.holy_role == HOLY_ROLE_DEACON)
		to_chat(chap, "<span class='warning'>You are merely a deacon of [GLOB.deity], and therefore cannot perform rites.")
		return
	if(!is_type_in_typecache(I,desired_items_typecache))
		return FALSE

/// Activates when the sect sacrifices an item. This proc has NO bearing on the attackby sequence of other objects when used in conjunction with the religious_tool component.
/datum/religion_sect/proc/on_sacrifice(obj/item/I, mob/living/chap)
	return adjust_favor(default_item_favor,chap)

/// Returns a description for religious tools
/datum/religion_sect/proc/tool_examine(mob/living/holy_creature)
	return "You are currently at [round(favor)] favor with [GLOB.deity]."

/// Adjust Favor by a certain amount. Can provide optional features based on a user. Returns actual amount added/removed
/datum/religion_sect/proc/adjust_favor(amount = 0, mob/living/chap)
	. = amount
	if(favor + amount < 0)
		. = favor //if favor = 5 and we want to subtract 10, we'll only be able to subtract 5
	if((favor + amount > max_favor))
		. = (max_favor-favor) //if favor = 5 and we want to add 10 with a max of 10, we'll only be able to add 5
	favor = clamp(0,max_favor, favor+amount)

/// Sets favor to a specific amount. Can provide optional features based on a user.
/datum/religion_sect/proc/set_favor(amount = 0, mob/living/chap)
	favor = clamp(0,max_favor,amount)
	return favor

/// Activates when an individual uses a rite. Can provide different/additional benefits depending on the user.
/datum/religion_sect/proc/on_riteuse(mob/living/user, atom/religious_tool)

/// Replaces the bible's bless mechanic. Return TRUE if you want to not do the brain hit.
/datum/religion_sect/proc/sect_bless(mob/living/target, mob/living/chap)
	if(!ishuman(target))
		return FALSE
	var/mob/living/carbon/human/blessed = target
	for(var/obj/item/bodypart/bodypart as anything in blessed.bodyparts)
		if(!IS_ORGANIC_LIMB(bodypart))
			to_chat(chap, "<span class='warning'>[GLOB.deity] refuses to heal this metallic taint!</span>")
			return TRUE

	var/heal_amt = 10
	var/list/hurt_limbs = blessed.get_damaged_bodyparts(1, 1, null, BODYTYPE_ORGANIC)

	if(hurt_limbs.len)
		for(var/X in hurt_limbs)
			var/obj/item/bodypart/affecting = X
			if(affecting.heal_damage(heal_amt, heal_amt, null, BODYTYPE_ORGANIC))
				blessed.update_damage_overlays()
		blessed.visible_message("<span class='notice'>[chap] heals [blessed] with the power of [GLOB.deity]!</span>")
		to_chat(blessed, "<span class='boldnotice'>May the power of [GLOB.deity] compel you to be healed!</span>")
		playsound(chap, "punch", 25, TRUE, -1)
		SEND_SIGNAL(blessed, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/**** Nanotrasen Approved God ****/

/datum/religion_sect/puritanism
	name = "Nanotrasen Approved God"
	desc = "Your run-of-the-mill sect, there are no benefits or boons associated."
	quote = "Nanotrasen Recommends!"
	tgui_icon = "bible"

/**** Technophile Sect ****/

/datum/religion_sect/technophile
	name = "Technophile"
	quote = "May you find peace in a metal shell."
	desc = "Bibles now recharge cyborgs and heal robotic limbs if targeted, but they \
	do not heal organic limbs. You can now sacrifice cells, with favor depending on their charge."
	tgui_icon = "robot"
	alignment = ALIGNMENT_NEUT
	desired_items = list(/obj/item/stock_parts/cell = "with battery charge")
	rites_list = list(/datum/religion_rites/synthconversion, /datum/religion_rites/machine_blessing, /datum/religion_rites/machine_implantation)
	altar_icon_state = "convertaltar-blue"
	max_favor = 5000

/datum/religion_sect/technophile/sect_bless(mob/living/target, mob/living/chap)
	if(iscyborg(target))
		var/mob/living/silicon/robot/R = target
		var/charge_amt = 50
		if(target.mind?.holy_role == HOLY_ROLE_HIGHPRIEST)
			charge_amt *= 2
		R.cell?.charge += charge_amt
		R.visible_message("<span class='notice'>[chap] charges [R] with the power of [GLOB.deity]!</span>")
		to_chat(R, "<span class='boldnotice'>You are charged by the power of [GLOB.deity]!</span>")
		SEND_SIGNAL(R, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
		playsound(chap, 'sound/effects/bang.ogg', 25, TRUE, -1)
		return TRUE
	if(!ishuman(target))
		return
	var/mob/living/carbon/human/blessed = target

	//first we determine if we can charge them
	var/did_we_charge = FALSE
	var/obj/item/organ/stomach/battery/ethereal/eth_stomach = blessed.getorganslot(ORGAN_SLOT_STOMACH)
	if(istype(eth_stomach))
		eth_stomach.adjust_charge(60)
		did_we_charge = TRUE

	//if we're not targetting a robot part we stop early
	var/obj/item/bodypart/bodypart = blessed.get_bodypart(chap.zone_selected)
	if(!IS_ORGANIC_LIMB(bodypart))
		if(!did_we_charge)
			to_chat(chap, "<span class='warning'>[GLOB.deity] scoffs at the idea of healing such fleshy matter!</span>")
		else
			blessed.visible_message("<span class='notice'>[chap] charges [blessed] with the power of [GLOB.deity]!</span>")
			to_chat(blessed, "<span class='boldnotice'>You feel charged by the power of [GLOB.deity]!</span>")
			SEND_SIGNAL(blessed, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
			playsound(chap, 'sound/machines/synth_yes.ogg', 25, TRUE, -1)
		return TRUE

	//charge(?) and go
	if(bodypart.heal_damage(5,5,null,BODYTYPE_ROBOTIC))
		blessed.update_damage_overlays()

	blessed.visible_message("<span class='notice'>[chap] [did_we_charge ? "repairs" : "repairs and charges"] [blessed] with the power of [GLOB.deity]!</span>")
	to_chat(blessed, "<span class='boldnotice'>The inner machinations of [GLOB.deity] [did_we_charge ? "repairs" : "repairs and charges"] you!</span>")
	playsound(chap, 'sound/effects/bang.ogg', 25, TRUE, -1)
	SEND_SIGNAL(blessed, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/technophile/on_sacrifice(obj/item/I, mob/living/chap)
	var/obj/item/stock_parts/cell/the_cell = I
	if(!istype(the_cell)) //how...
		return
	if(the_cell.charge < 300)
		to_chat(chap,"<span class='notice'>[GLOB.deity] does not accept pity amounts of power.</span>")
		return
	adjust_favor(round(the_cell.charge/100), chap)
	to_chat(chap, "<span class='notice'>You offer [the_cell]'s power to [GLOB.deity], pleasing them.</span>")
	qdel(I)
	return TRUE

/**** Ever-Burning Candle sect ****/

/datum/religion_sect/candle_sect
	name = "Ever-Burning Candle"
	desc = "Sacrificing burning corpses with a lot of burn damage and candles grants you favor."
	quote = "It must burn! The primal energy must be respected."
	tgui_icon = "fire-alt"
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/candle = "already lit")
	rites_list = list(/datum/religion_rites/fireproof, /datum/religion_rites/burning_sacrifice, /datum/religion_rites/infinite_candle)
	altar_icon_state = "convertaltar-red"

//candle sect bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/candle_sect/sect_bless(mob/living/target, mob/living/chap)
	return TRUE

/datum/religion_sect/candle_sect/on_sacrifice(obj/item/candle/offering, mob/living/user)
	if(!istype(offering))
		return
	if(!offering.lit)
		to_chat(user, "<span class='notice'>The candle needs to be lit to be offered!</span>")
		return
	to_chat(user, "<span class='notice'>[GLOB.deity] is pleased with your sacrifice.</span>")
	adjust_favor(20, user) //it's not a lot but hey there's a pacifist favor option at least
	qdel(offering)
	return TRUE

/**** Necromantic Sect ****/

/datum/religion_sect/necro_sect
	name = "Necromancy"
	desc = "A sect dedicated to the revival and summoning of the dead. Sacrificing living animals grants you favor."
	quote = "An undead army is a must have!"
	tgui_icon = "skull"
	alignment = ALIGNMENT_EVIL
	max_favor = 10000
	desired_items = list(/obj/item/organ/)
	rites_list = list(/datum/religion_rites/raise_dead, /datum/religion_rites/living_sacrifice, /datum/religion_rites/raise_undead, /datum/religion_rites/create_lesser_lich)
	altar_icon_state = "convertaltar-green"

//Necro bibles don't heal or do anything special apart from the standard holy water blessings
/datum/religion_sect/necro_sect/sect_bless(mob/living/blessed, mob/living/user)
	return TRUE

/datum/religion_sect/necro_sect/on_sacrifice(obj/item/N, mob/living/L)
	if(!istype(N, /obj/item/organ))
		return
	adjust_favor(10, L)
	to_chat(L, "<span class='notice'>You offer [N] to [GLOB.deity], pleasing them and gaining 10 favor in the process.</span>")
	qdel(N)
	return TRUE



/**** Carp Sect ****/

/datum/religion_sect/carp_sect
	name = "Followers of the Great Carp"
	desc = "A sect dedicated to the space carp and carp'sie, Offer the gods meat for favor."
	quote = "Drown the station in fish and water."
	tgui_icon = "fish"
	alignment = ALIGNMENT_NEUT
	max_favor = 10000
	desired_items = list(/obj/item/reagent_containers/food/snacks/meat/slab)
	rites_list = list(/datum/religion_rites/summon_carp, /datum/religion_rites/flood_area, /datum/religion_rites/summon_carpsuit)
	altar_icon_state = "convertaltar-blue"

//Carp bibles give people the carp faction!
/datum/religion_sect/carp_sect/sect_bless(mob/living/L, mob/living/user)
	if(!isliving(L))
		return FALSE
	L.faction |= "carp"
	user.visible_message("<span class='notice'>[user] blessed [L] with the power of [GLOB.deity]! They are now protected from Space Carps, Although carps will still fight back if attacked.</span>")
	SEND_SIGNAL(L, COMSIG_ADD_MOOD_EVENT, "blessing", /datum/mood_event/blessing)
	return TRUE

/datum/religion_sect/carp_sect/on_sacrifice(obj/item/N, mob/living/L) //and this
	var/obj/item/reagent_containers/food/snacks/meat/meat = N
	if(!istype(meat)) //how...
		return
	adjust_favor(20, L)
	to_chat(L, "<span class='notice'>You offer [meat] to [GLOB.deity], pleasing them and gaining 20 favor in the process.</span>")
	qdel(N)
	return TRUE
