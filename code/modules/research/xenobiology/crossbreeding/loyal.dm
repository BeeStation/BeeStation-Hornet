/*
Loyal extracts:
	Applying this to items gives them an additional effect.
	One use per item.
*/
/obj/item/slimecross/loyal
	name = "loyal extract"
	desc = "A tiny, glowing core. It seems to be drawn to nearby objects."
	effect = "loyal"
	effect_desc = null
	icon_state = "loyal"
	var/datum/component/loyal_effect/loyaleffect

/obj/item/slimecross/loyal/afterattack(obj/item/target,mob/user,proximity)
	. = ..()
	if(!proximity || !istype(target, /obj/item) || target.GetComponent(/datum/component/loyal_effect))
		return FALSE
	var/datum/component/loyal_effect/new_effect = target.AddComponent(loyaleffect, target)
	to_chat(user, "<span class='notice'>You smear the [target] with [src], making it [new_effect.prefix]!</span>")
	target.name = "[new_effect.prefix] [target.name]"
	qdel(src)
	return TRUE

/datum/component/loyal_effect
	var/prefix = "weird"
	var/obj/item/attached

/datum/component/loyal_effect/Initialize(obj/item/attached_item)
	if(!attached_item)
		return
	attached = attached_item

/obj/item/slimecross/loyal/grey
	colour = "grey"
	effect_desc = "Makes an item very sticky."
	loyaleffect = /datum/component/loyal_effect/grey

/obj/item/slimecross/loyal/grey/afterattack(obj/item/target,mob/user,proximity)
	if(HAS_TRAIT_FROM(target, TRAIT_NODROP, GLUED_ITEM_TRAIT))
		to_chat(user, "<span class='warning'>[target] is already sticky!</span>")
		return
	if(!..()) //Is this shitcode?
		return
	ADD_TRAIT(target, TRAIT_NODROP, GLUED_ITEM_TRAIT) //Pretty much just syndie glue
	target.desc += " It looks sticky."

/datum/component/loyal_effect/grey
	prefix = "sticky"

/obj/item/slimecross/loyal/orange
	colour = "orange"
	effect_desc = "Makes an item grow nettles that burn the hands of anyone who picks it up without gloves."
	loyaleffect = /datum/component/loyal_effect/orange

/datum/component/loyal_effect/orange
	prefix = "nettling"

/datum/component/loyal_effect/orange/Initialize(obj/item/attached_item)
	. = ..()
	RegisterSignal(attached_item, COMSIG_ITEM_PICKUP, .proc/pickup_burn)

/datum/component/loyal_effect/orange/proc/pickup_burn(datum/source, mob/user)
	if(!iscarbon(user))
		return FALSE
	var/mob/living/carbon/C = user
	if(C.gloves)
		return
	if(HAS_TRAIT(C, TRAIT_PIERCEIMMUNE))
		return
	var/hit_zone = (C.held_index_to_dir(C.active_hand_index) == "l" ? "l_":"r_") + "arm"
	var/obj/item/bodypart/affecting = C.get_bodypart(hit_zone)
	if(affecting)
		if(affecting.receive_damage(0, 10))
			C.update_damage_overlays()
	to_chat(C, "<span class='userdanger'>[attached] burns your bare hand!</span>")

/obj/item/slimecross/loyal/purple
	colour = "purple"
	effect_desc = "Makes a piece of clothing heal whatever body part it is worn over."
	loyaleffect = /datum/component/loyal_effect/purple

/datum/component/loyal_effect/purple
	prefix = "medicinal"
	var/mob/living/carbon/attached_user

/datum/component/loyal_effect/purple/Initialize(obj/item/attached_item)
	. = ..()
	if(istype(attached_item, /obj/item/clothing)) //We only care if it's clothes.
		START_PROCESSING(SSobj,src)
		RegisterSignal(attached_item, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)
		var/wearer = attached_item.loc
		if(ishuman(wearer))
			attached_user = wearer //This should make it start healing if applied directly to worn clothes

/datum/component/loyal_effect/purple/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/purple/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	if(istype(user))
		attached_user = user
	else
		attached_user = null

/datum/component/loyal_effect/purple/process()
	if(attached_user)
		var/slotflags = attached.slot_flags
		switch(slotflags) //Time for long code
			if(ITEM_SLOT_OCLOTHING || ITEM_SLOT_ICLOTHING)
				var/obj/item/bodypart/chest = attached_user.get_bodypart(BODY_ZONE_CHEST)
				if(chest.heal_damage(1,1)) //These values are kinda arbitrary
					attached_user.update_damage_overlays()
			if(ITEM_SLOT_HEAD || ITEM_SLOT_MASK)
				var/obj/item/bodypart/head = attached_user.get_bodypart(BODY_ZONE_HEAD)
				if(head.heal_damage(1,1))
					attached_user.update_damage_overlays()
			if(ITEM_SLOT_GLOVES)
				var/obj/item/bodypart/larm = attached_user.get_bodypart(BODY_ZONE_L_ARM) //Pretty sure gloves can't be worn without both arms
				var/obj/item/bodypart/rarm = attached_user.get_bodypart(BODY_ZONE_R_ARM) //So it's safe to assume they both exist
				if(larm.heal_damage(1,1))
					attached_user.update_damage_overlays()
				if(rarm.heal_damage(1,1))
					attached_user.update_damage_overlays()
			if(ITEM_SLOT_FEET)
				var/obj/item/bodypart/lleg = attached_user.get_bodypart(BODY_ZONE_L_LEG) //Pretty sure shoes can't be worn without both legs
				var/obj/item/bodypart/rleg = attached_user.get_bodypart(BODY_ZONE_R_LEG) //So it's safe to assume they both exist
				if(lleg.heal_damage(1,1))
					attached_user.update_damage_overlays()
				if(rleg.heal_damage(1,1))
					attached_user.update_damage_overlays()
			if(ITEM_SLOT_EARS)
				var/obj/item/organ/ears/ears = attached_user.getorganslot(ORGAN_SLOT_EARS)
				if(!ears)
					return
				ears.deaf = max(ears.deaf - 0.5, 0) //Can cure deafness
				ears.damage = max(ears.damage - 0.05, 0)
			if(ITEM_SLOT_EYES)
				var/obj/item/organ/eyes/eyes = attached_user.getorganslot(ORGAN_SLOT_EYES)
				if(!eyes)
					return
				eyes.applyOrganDamage(-1)
				if(HAS_TRAIT_FROM(attached_user, TRAIT_BLIND, EYE_DAMAGE)) //This is just copied from oculine code for healing eye afflictions
					if(prob(20))
						to_chat(attached_user, "<span class='warning'>Your vision slowly returns...</span>")
						attached_user.cure_blind(EYE_DAMAGE)
						attached_user.cure_nearsighted(EYE_DAMAGE)
						attached_user.blur_eyes(35)
				else if(HAS_TRAIT_FROM(attached_user, TRAIT_NEARSIGHT, EYE_DAMAGE))
					to_chat(attached_user, "<span class='warning'>The blackness in your peripheral vision fades.</span>")
					attached_user.cure_nearsighted(EYE_DAMAGE)
					attached_user.blur_eyes(10)
				else if(attached_user.eye_blind || attached_user.eye_blurry)
					attached_user.set_blindness(0)
					attached_user.set_blurriness(0)

/obj/item/slimecross/loyal/blue
	colour = "blue"
	effect_desc = "Makes an item self-cleaning."
	loyaleffect = /datum/component/loyal_effect/blue

/datum/component/loyal_effect/blue
	prefix = "clean"

/datum/component/loyal_effect/blue/Initialize(obj/item/attached_item)
	. = ..()
	START_PROCESSING(SSobj,src)

/datum/component/loyal_effect/blue/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/blue/process()
	SEND_SIGNAL(attached, COMSIG_COMPONENT_CLEAN_ACT, CLEAN_GOD) //The CLEANEST

/obj/item/slimecross/loyal/metal
	colour = "metal"
	effect_desc = "Makes an item more resistance to brute attacks."
	loyaleffect = /datum/component/loyal_effect/metal

/datum/component/loyal_effect/metal
	prefix = "metallic"

/datum/component/loyal_effect/metal/Initialize(obj/item/attached_item)
	. = ..()
	attached_item.armor = attached_item.armor.attachArmor(list("melee" = 10, "bullet" = 5, "bomb" = 5))

/obj/item/slimecross/loyal/yellow
	colour = "yellow"
	effect_desc = "Makes an item glow."
	loyaleffect = /datum/component/loyal_effect/yellow

/datum/component/loyal_effect/yellow
	prefix = "glowing"

/datum/component/loyal_effect/yellow/Initialize(obj/item/attached_item)
	. = ..()
	var/datum/light_source/newlight = new(attached_item, attached_item)
	newlight.light_power = 1
	newlight.light_range = 5
	newlight.light_color = "FFFFA0" //Off yellow
	//attached_item.set_light(l_range = 5, l_power = 1) //A bit wider than a flashlight

/obj/item/slimecross/loyal/darkpurple
	colour = "dark purple"
	effect_desc = "Makes an item combustible like plasma."
	loyaleffect = /datum/component/loyal_effect/darkpurple

/datum/component/loyal_effect/darkpurple
	prefix = "combustible"

/datum/component/loyal_effect/darkpurple/Initialize(obj/item/attached_item)
	. = ..()
	RegisterSignal(attached_item, COMSIG_ATOM_FIRE_ACT, .proc/fire_act_loyal)
	RegisterSignal(attached_item, COMSIG_PARENT_ATTACKBY, .proc/hot_check)
	attached_item.resistance_flags |= FLAMMABLE
	attached_item.resistance_flags &= !FIRE_PROOF //There's gotta be a better way to bitwise this

/datum/component/loyal_effect/darkpurple/proc/fire_act_loyal(datum/source, exposed_temperature, exposed_volume)
	burn_up(exposed_temperature)

/datum/component/loyal_effect/darkpurple/proc/hot_check(datum/source, obj/item/I, mob/user, params)
	if(!I)
		return
	var/hotness = I.is_hot()
	if(hotness)
		burn_up(hotness)

/datum/component/loyal_effect/darkpurple/proc/burn_up(exposed_temperature)
	attached.atmos_spawn_air("plasma=[attached.w_class*30];TEMP=[exposed_temperature]") //Same as plasma sheets. bigger items make more plasma.
	qdel(attached)

/obj/item/slimecross/loyal/darkblue
	colour = "dark blue"
	effect_desc = "Makes an item fireproof and colder. If clothing, it will cool down whoever wears it. Hitting someone with this will make them quite chilly."
	loyaleffect = /datum/component/loyal_effect/darkblue

/datum/component/loyal_effect/darkblue
	prefix = "cryonic"
	var/mob/living/carbon/attached_user

/datum/component/loyal_effect/darkblue/Initialize(obj/item/attached_item)
	. = ..()
	attached_item.resistance_flags |= FIRE_PROOF
	RegisterSignal(attached_item,COMSIG_ITEM_ATTACK,.proc/cryo_attack)
	if(istype(attached_item, /obj/item/clothing))
		RegisterSignal(attached_item, list(COMSIG_ITEM_EQUIPPED, COMSIG_ITEM_DROPPED), .proc/equippedChanged)
		START_PROCESSING(SSobj,src)

/datum/component/loyal_effect/darkblue/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/darkblue/process()
	if(!attached_user)
		return
	if(attached_user.bodytemperature > BODYTEMP_NORMAL) //Stolen from leporazine code
		attached_user.adjust_bodytemperature(-40 * TEMPERATURE_DAMAGE_COEFFICIENT, BODYTEMP_NORMAL)

/datum/component/loyal_effect/darkblue/proc/cryo_attack(datum/source, mob/living/carbon/C, mob/user)
	C.adjust_bodytemperature(150 - C.bodytemperature) //Stolen from cryo projectile code

/datum/component/loyal_effect/darkblue/proc/equippedChanged(datum/source, mob/living/carbon/user, slot)
	if(istype(user))
		attached_user = user
	else
		attached_user = null

/obj/item/slimecross/loyal/silver
	colour = "silver"
	effect_desc = "Makes an item edible. Bon appetite!"
	loyaleffect = /datum/component/loyal_effect/silver

/datum/component/loyal_effect/silver
	prefix = "delicious"

/datum/component/loyal_effect/silver/Initialize(obj/item/attached_item)
	. = ..()
	RegisterSignal(attached_item, COMSIG_ITEM_PRE_ATTACK, .proc/eat)

/datum/component/loyal_effect/silver/proc/eat(datum/source, atom/target, mob/user, params)
	if(user.a_intent != INTENT_HARM || iscarbon(target))
		var/mob/M = target
		var/obj/item/reagent_containers/food/snacks/silver_temporary/newfood = new
		newfood.name = attached.name
		if(newfood.attack(M, user))
			var/datum/reagents/new_reagents = attached.reagents
			if(new_reagents)
				//newfood.reagents.maximum_volume = new_reagents.total_volume + 10
				newfood.volume = new_reagents.total_volume + 10
				newfood.bitesize = new_reagents.total_volume + 10
				new_reagents.trans_to(newfood, new_reagents.total_volume, transfered_by = user)
			qdel(attached)
		qdel(newfood)

/obj/item/reagent_containers/food/snacks/silver_temporary
	name = "temporary loyal silver snack item"
	desc = "If you're reading this it means I messed up."
	bitesize = 10
	list_reagents = list(/datum/reagent/consumable/nutriment = 10)
	tastes = list("a melt-in-your-mouth sensation" = 1)

/obj/item/slimecross/loyal/bluespace
	colour = "bluespace"
	effect_desc = "Makes an item able to be compressed and decompressed. The item is unusable when compressed."
	loyaleffect = /datum/component/loyal_effect/bluespace

/datum/component/loyal_effect/bluespace
	prefix = "telescopic"
	var/compressed = FALSE
	var/obj/item/telescopic_item/compressed_item

/datum/component/loyal_effect/bluespace/Initialize(obj/item/attached_item)
	. = ..()
	attached_item.verbs += /obj/item/proc/Compress
	compressed_item = new /obj/item/telescopic_item
	compressed_item.name = attached_item.name
	compressed_item.desc = attached_item.desc
	compressed_item.icon = attached_item.icon
	compressed_item.icon_state = attached_item.icon_state
	compressed_item.original = attached_item
	compressed_item.forceMove(attached_item)

/obj/item/proc/Compress(mob/user)
	if(user.get_active_held_item() != src) //It's gotta be the active item
		return
	var/datum/component/loyal_effect/bluespace/compression_component = GetComponent(/datum/component/loyal_effect/bluespace)
	if(!compression_component) //Inspired by compressionkit code
		return
	var/obj/item/compressed = compression_component.compressed_item
	if(!compressed)
		return
	if(GetComponent(/datum/component/storage))
		to_chat(user, "<span class='notice'>You can't make this item any smaller without compromising its storage functions!.</span>")
		return
	to_chat(user,"<span class='notice'>You begin compressing [src]...</span>")
	if(do_mob(user, src, 20))
		src.forceMove(compressed.loc)
		user.put_in_hands(compressed)
		to_chat(user, "<span class='notice'>You successfully compress [src]!</span>")

/obj/item/telescopic_item
	name = "compressed item"
	desc = "If you're seeing this, dingo-dongler screwed up. Report this and mention him."
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	var/obj/item/original

/obj/item/telescopic_item/examine(mob/user)
	. = ..()
	. += "<span class='notice'>It's compressed!</span>"

/obj/item/telescopic_item/attack_self(mob/user)
	to_chat(user,"<span class='notice'>You begin uncompressing [src]...</span>")
	if(do_mob(user,src,20))
		src.forceMove(original.loc)
		user.put_in_hands(original)
		to_chat(user, "<span class='notice'>You uncompress [src]!</span>")

/obj/item/slimecross/loyal/sepia
	colour = "sepia"
	effect_desc = "Makes an item able to be summoned by whoever applied this extract, with a long cooldown."
	loyaleffect = /datum/component/loyal_effect/sepia

/obj/item/slimecross/loyal/sepia/afterattack(obj/item/target,mob/user,proximity)
	if(!..())
		return
	var/obj/effect/proc_holder/spell/targeted/summonitem/sepiasummon/oldsummon = locate() in user.mind.spell_list //Checking if we already have a waybound item
	if(oldsummon)
		var/obj/item/oldmarked = oldsummon.marked_item
		oldsummon.marked_item = target
		if(oldmarked)
			to_chat(user,"<span class='notice'> [target] becomes waybound to you, but you can no longer summon [oldmarked].</span>")
		else
			to_chat(user,"<span class='notice'> [target] becomes waybound to you, and can be summoned!</span>")
	else
		var/obj/effect/proc_holder/spell/targeted/summonitem/sepiasummon/S = new
		to_chat(user,"<span class='notice'> [target] becomes waybound to you, and can be summoned!</span>")
		S.marked_item = target
		user.mind.AddSpell(S)

/datum/component/loyal_effect/sepia
	prefix = "waybound"

/obj/effect/proc_holder/spell/targeted/summonitem/sepiasummon
	name = "Waybound Summon"
	desc = "This spell can be used to summon a waybound item back to you."
	cooldown_min = 1200 //Deciseconds, so this is 2 minutes. Not as good as regular summons, but still an extra security for the disk.
	charge_max = 1200
	invocation = "Return to me!" //Less wizardry, more inanimate loyalty.

/obj/effect/proc_holder/spell/targeted/summonitem/sepiasummon/cast(list/targets,mob/user = usr) //A few things need to be different, like no unbinding
	for(var/mob/living/L in targets)
		var/list/hand_items = list(L.get_active_held_item(),L.get_inactive_held_item())
		var/message

		if(!marked_item) //waybound item was destroyed or something
			message = "<span class>='notice'You call out, but nothing is waybound to you!</notice>"
		else if(marked_item && (marked_item in hand_items))
			message = "<span class='notice'>[marked_item] is already in your possession.</span>"
		else if(marked_item && QDELETED(marked_item)) //the item was destroyed at some point
			message = "<span class='warning'>You sense your marked item has been destroyed!</span>"
			marked_item = null

		else	//Getting previously marked item
			var/obj/item_to_retrieve = marked_item
			var/infinite_recursion = 0 //I don't want to know how someone could put something inside itself but these are wizards so let's be safe

			if(!item_to_retrieve.loc)
				if(isorgan(item_to_retrieve)) // Organs are usually stored in nullspace
					var/obj/item/organ/organ = item_to_retrieve
					if(organ.owner)
						// If this code ever runs I will be happy
						log_combat(L, organ.owner, "magically removed [organ.name] from", addition="INTENT: [uppertext(L.a_intent)]")
						organ.Remove(organ.owner)
			else
				while(!isturf(item_to_retrieve.loc) && infinite_recursion < 10) //if it's in something you get the whole thing.
					if(isitem(item_to_retrieve.loc))
						var/obj/item/I = item_to_retrieve.loc
						if(I.item_flags & ABSTRACT) //Being able to summon abstract things because your item happened to get placed there is a no-no
							break
					if(ismob(item_to_retrieve.loc)) //If its on someone, properly drop it
						var/mob/M = item_to_retrieve.loc

						if(issilicon(M)) //Items in silicons warp the whole silicon
							M.loc.visible_message("<span class='warning'>[M] suddenly disappears!</span>")
							M.forceMove(L.loc)
							M.loc.visible_message("<span class='caution'>[M] suddenly appears!</span>")
							break
						M.dropItemToGround(item_to_retrieve)

						if(iscarbon(M)) //Edge case housekeeping
							var/mob/living/carbon/C = M
							for(var/X in C.bodyparts)
								var/obj/item/bodypart/part = X
								if(item_to_retrieve in part.embedded_objects)
									part.embedded_objects -= item_to_retrieve
									to_chat(C, "<span class='warning'>The [item_to_retrieve] that was embedded in your [L] has mysteriously vanished. How fortunate!</span>")
									if(!C.has_embedded_objects())
										C.clear_alert("embeddedobject")
										SEND_SIGNAL(C, COMSIG_CLEAR_MOOD_EVENT, "embedded")
									break

					else
						if(istype(item_to_retrieve.loc, /obj/machinery/portable_atmospherics/)) //Edge cases for moved machinery
							var/obj/machinery/portable_atmospherics/P = item_to_retrieve.loc
							P.disconnect()
							P.update_icon()

						item_to_retrieve = item_to_retrieve.loc

					infinite_recursion += 1

			if(!item_to_retrieve)
				return

			if(item_to_retrieve.loc)
				item_to_retrieve.loc.visible_message("<span class='warning'>The [item_to_retrieve.name] suddenly disappears!</span>")
			if(!L.put_in_hands(item_to_retrieve))
				item_to_retrieve.forceMove(L.drop_location())
				item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears!</span>")
				playsound(get_turf(L), 'sound/magic/summonitems_generic.ogg', 50, 1)
			else
				item_to_retrieve.loc.visible_message("<span class='caution'>The [item_to_retrieve.name] suddenly appears in [L]'s hand!</span>")
				playsound(get_turf(L), 'sound/magic/summonitems_generic.ogg', 50, 1)

		if(message)
			to_chat(L, message)

/obj/item/slimecross/loyal/cerulean
	colour = "cerulean"
	effect_desc = "Makes a fake duplicate of an item, that will turn to dust when used in any way."
	loyaleffect = /datum/component/loyal_effect/cerulean

/datum/component/loyal_effect/cerulean
	prefix = "duplicated"

/datum/component/loyal_effect/cerulean/Initialize(obj/item/attached_item)
	if(!attached_item)
		return
	var/obj/item/cerulean_duplicate/duplicate = new /obj/item/cerulean_duplicate(get_turf(attached_item)) //This goes before parent call, so the duplicate has the original name
	duplicate.name = attached_item.name
	duplicate.desc = attached_item.desc
	duplicate.icon = attached_item.icon
	duplicate.icon_state = attached_item.icon_state
	. = ..()

/obj/item/cerulean_duplicate
	name = "cerulean duplicate"
	desc = "a duplicate of... something?"
	max_integrity = 50

/obj/item/cerulean_duplicate/attack_self(mob/user)
	dust()

/obj/item/cerulean_duplicate/AltClick(mob/user)
	dust()

/obj/item/cerulean_duplicate/pre_attack(atom/A, mob/user, params)
	dust()

/obj/item/cerulean_duplicate/proc/dust()
	new /obj/effect/decal/cleanable/ash(loc)
	visible_message("<span class='danger'>[src] crumbles into dust!</span>")
	qdel(src)

/obj/item/slimecross/loyal/pyrite
	colour = "pyrite"
	effect_desc = "Makes an item change colors."
	loyaleffect = /datum/component/loyal_effect/pyrite

/datum/component/loyal_effect/pyrite
	prefix = "flashy"
	var/color = "FFA500"
	var/colorlist = list("#FFA500", //All the colors of the slimes!
						 "#B19CD9",
						 "#ADD8E6",
						 "#7E7E7E",
						 "#FFFF00",
						 "#551A8B",
						 "#0000FF",
						 "#D3D3D3",
						 "#32CD32",
						 "#704214",
						 "#2956B2",
						 "#FAFAD2",
						 "#FF0000",
						 "#00FF00",
						 "#FF69B4",
						 "#FFD700",
						 "#505050",
						 "#000000",
						 "#FFB6C1",
						 "#008B8B"
						)

/datum/component/loyal_effect/pyrite/Initialize(obj/item/attached_item)
	. = ..()
	START_PROCESSING(SSobj,src)

/datum/component/loyal_effect/pyrite/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/pyrite/process()
	attached.add_atom_colour(pick(colorlist), FIXED_COLOUR_PRIORITY)

/obj/item/slimecross/loyal/red
	colour = "red"
	effect_desc = "Makes an item stronger when thrown, if it is covered in blood."
	loyaleffect = /datum/component/loyal_effect/red

/datum/component/loyal_effect/red
	prefix = "blooded"
	var/bloody = FALSE

/datum/component/loyal_effect/red/Initialize(obj/item/attached_item)
	. = ..()
	START_PROCESSING(SSobj,src)

/datum/component/loyal_effect/red/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/red/process()
	if(attached.blood_DNA_length() && !bloody) //This would be much nicer if making something bloody was done through comsignals
		change_blood()
	else if(!attached.blood_DNA_length() && bloody)
		change_blood()

/datum/component/loyal_effect/red/proc/change_blood()
	if(bloody)
		bloody = FALSE
		attached.throwforce -= 2
	else
		bloody = TRUE
		attached.throwforce += 2

/obj/item/slimecross/loyal/green
	colour = "green"
	effect_desc = "Makes an item able to be disguised as another item."
	loyaleffect = /datum/component/loyal_effect/green

/datum/component/loyal_effect/green
	prefix = "disguised"

/datum/component/loyal_effect/green/Initialize(obj/item/attached_item)
	. = ..()
	attached_item.verbs += /obj/item/proc/Disguise

/obj/item/proc/Disguise(mob/user)
	if(user.get_active_held_item() != src)
		return
	var/disguise_list //Possible disguises. If there is a common file of items by weight, let me know.
	switch(w_class)
		if(WEIGHT_CLASS_TINY)
			disguise_list = list(/obj/item/pen, //things that are odd, but not immediately suspicious.
								 /obj/item/lipstick, //Things that are Bond-like
								 /obj/item/candle, //Because disguising vital things as mundane things
								 /obj/item/soap //Is a very Bond thing to do
								)
		if(WEIGHT_CLASS_SMALL)
			disguise_list = list(/obj/item/wrench,
								 /obj/item/toy/cards/deck,
								 /obj/item/camera,
								 /obj/item/instrument/harmonica
								)
		if(WEIGHT_CLASS_NORMAL)
			disguise_list = list(/obj/item/reagent_containers/food/snacks/grown/pineapple,
								 /obj/item/mop,
								 /obj/item/roller,
								 /obj/item/extinguisher
								)
		if(WEIGHT_CLASS_BULKY)
			disguise_list = list(/obj/item/storage/toolbox,
								 /obj/item/shield/riot,
								 /obj/item/storage/briefcase,
								 /obj/item/gun/ballistic/shotgun/doublebarrel
								)
		if(WEIGHT_CLASS_HUGE)
			disguise_list = list(/obj/item/katana, //Not quite mundane anymore.
								 /obj/item/melee/baseball_bat,
								 /obj/item/electropack,
								 /obj/item/chair
								)
		if(WEIGHT_CLASS_GIGANTIC)
			disguise_list = list(/obj/item/mecha_parts/part/honker_head, //There's barely anything of this size
								 /obj/item/his_grace //Disguising as this is more of a laugh than a strategy
								)
	var/obj/item/disguise_type = pick(disguise_list)
	var/obj/item/disguise = new disguise_type
	to_chat(user,"<span class='notice'>You begin disguising [src] as a [disguise.name]...</span>")
	if(do_mob(user, src, 20))
		to_chat(user,"<span class='notice'>You disguise [src] as a [disguise.name]!</span>")
		var/obj/item/disguised_item/disguised_item = new
		disguised_item.name = disguise.name
		disguised_item.desc = disguise.desc
		disguised_item.icon = disguise.icon
		disguised_item.icon_state = disguise.icon_state
		disguised_item.w_class = disguise.w_class
		disguised_item.throw_range = src.throw_range //The veil slips
		disguised_item.throw_speed = src.throw_speed
		disguised_item.original = src
		src.forceMove(disguised_item)
		disguised_item.forceMove(src)
		user.put_in_hands(disguised_item)
	qdel(disguise)

/obj/item/disguised_item
	name = "disguised item"
	desc = "If you're seeing this, dingo-dongler screwed up. Report this and mention him."
	throwforce = 0
	w_class = WEIGHT_CLASS_TINY
	throw_range = 1
	throw_speed = 1
	var/obj/item/original

/obj/item/disguised_item/attack_self(mob/user)
	to_chat(user,"<span class='notice'>You begin removing the disguise of [src]...</span>")
	if(do_mob(user,src,20))
		src.forceMove(original) //Just to get it out of our hands
		user.put_in_hands(original)
		to_chat(user, "<span class='notice'>You reveal [original]!</span>")
		qdel(src)

/obj/item/slimecross/loyal/pink
	colour = "pink"
	effect_desc = "Makes an item very pleasing to have, and improves the holder's mood."
	loyaleffect = /datum/component/loyal_effect/pink

/datum/component/loyal_effect/pink
	prefix = "soothing"

/datum/component/loyal_effect/pink/Initialize(obj/item/attached_item)
	. = ..()
	START_PROCESSING(SSobj,src)

/datum/component/loyal_effect/pink/Destroy()
	STOP_PROCESSING(SSobj,src)
	return ..()

/datum/component/loyal_effect/pink/process()
	var/humanfound = null //Copied from stabilized extract. Which is uh, questionable.
	if(ishuman(attached.loc))
		humanfound = attached.loc
	if(ishuman(attached.loc.loc)) //Check if in backpack.
		humanfound = (attached.loc.loc)
	if(!humanfound)
		return
	var/mob/living/carbon/human/H = humanfound
	SEND_SIGNAL(H, COMSIG_ADD_MOOD_EVENT, "soothing", /datum/mood_event/soothing, attached)

/obj/item/slimecross/loyal/gold
	colour = "gold"
	effect_desc = "Makes an item responsive to hand motions, and able to be commanded to approach."
	loyaleffect = /datum/component/loyal_effect/gold

/datum/component/loyal_effect/gold
	prefix = "responsive"

/datum/component/loyal_effect/gold/Initialize(obj/item/attached_item)
	. = ..()
	RegisterSignal(attached_item, COMSIG_CLICK, .proc/fling_to_user)

/datum/component/loyal_effect/gold/proc/fling_to_user(datum/source, location, control, params, mob/user)
	if(user.canUseTopic(attached, BE_CLOSE))
		return
	var/list/modifiers = params2list(params)
	if(modifiers["shift"] || modifiers["ctrl"] || modifiers["alt"] || modifiers["middle"]) //There's probably a better way to do this
		return
	attached.throw_at(user, 6, 2)

/obj/item/slimecross/loyal/oil
	colour = "oil"
	effect_desc = "Makes an item slippery."
	loyaleffect = /datum/component/loyal_effect/oil

/datum/component/loyal_effect/oil
	prefix = "slippery"

/datum/component/loyal_effect/oil/Initialize(obj/item/attached_item)
	. = ..()
	if(attached_item)
		attached_item.AddComponent(/datum/component/slippery, 80) //It's just soap

/obj/item/slimecross/loyal/black
	colour = "black"
	effect_desc = "Summons an obediant black slime, and places the target item inside. Upon death, the slime will drop the object."
	loyaleffect = /datum/component/loyal_effect/black

/obj/item/slimecross/loyal/black/afterattack(obj/item/target,mob/user,proximity)
	if(!..())
		return
	var/mob/living/simple_animal/slime/transformedslime/holding_slime = new(get_turf(user),"black",TRUE) //Transformed so it can't reproduce
	holding_slime.Friends[user] = 10 //This should be obediant enough
	target.forceMove(holding_slime)
	target.RegisterSignal(holding_slime, COMSIG_MOB_DEATH, /obj/item.proc/loyalblack_drop)

/obj/item/proc/loyalblack_drop(datum/source, gibbed)
	var/mob/deadslime = src.loc
	if(!deadslime)
		return
	forceMove(get_turf(deadslime))

/datum/component/loyal_effect/black
	prefix = "transformative"

/datum/component/loyal_effect/black/Initialize(obj/item/attached_item)
	. = ..()
	RegisterSignal(attached_item)

/obj/item/slimecross/loyal/lightpink
	colour = "light pink"
	effect_desc = "Makes an item able to be possessed by an unknown force."
	loyaleffect = /datum/component/loyal_effect/lightpink
	var/being_used = FALSE

/obj/item/slimecross/loyal/lightpink/afterattack(obj/item/target,mob/user,proximity)
	if(being_used || !istype(target, /obj/item) || !proximity || target.GetComponent(/datum/component/loyal_effect))
		return //Can't use parent call because it'll qdel the extract regardless of success
	to_chat(user, "<span class='notice'>You offer [src] to [target]...</span>")
	being_used = TRUE

	var/list/mob/dead/observer/candidates = pollGhostCandidates("Do you want to play as the possessed [target.name]?", ROLE_PAI, null, FALSE, 100, POLL_IGNORE_POSSESSED_BLADE) // see poll_ignore.dm
	if(LAZYLEN(candidates))
		var/mob/dead/observer/C = pick(candidates)
		var/mob/living/simple_animal/shade/S = new(target)
		S.ckey = C.ckey
		S.status_flags |= GODMODE
		S.copy_languages(user, LANGUAGE_MASTER)	//Make sure the sword can understand and communicate with the user.
		S.update_atom_languages()
		target.grant_all_languages(FALSE, FALSE, TRUE)	//Grants omnitongue
		var/datum/component/loyal_effect/new_effect = target.AddComponent(loyaleffect, target)
		to_chat(user, "<span class='notice'>You smear the [target] with [src], making it [new_effect.prefix]!</span>")
		target.name = "[new_effect.prefix] [target.name]"
		S.fully_replace_character_name(null, "[target.name]")
		var/obj/effect/proc_holder/spell/aimed/throw_self/throwspell = new
		throwspell.item_self = target
		S.mind.AddSpell(throwspell)
		qdel(src)
	else
		to_chat(user, "<span class='notice'>[target] vibrates for a moment, but then settles back down. Maybe you should try again later.</span>")
		being_used = FALSE

/datum/component/loyal_effect/lightpink
	prefix = "possessed"

/obj/effect/proc_holder/spell/aimed/throw_self
	name = "Throw Yourself"
	desc = "Throws yourself. Should bust you out of bags or other containers."
	charge_max = 100
	clothes_req = FALSE
	range = 3
	cooldown_min = 60
	projectile_type = null //Shouldn't need this with the fire_projectile override
	base_icon_state = "repulse"
	action_icon_state = "repulse"
	active_msg = "You prepare to throw yourself!"
	deactive_msg = "You settle back down."
	active = FALSE
	var/obj/item/item_self //The thing the shade is within

/obj/effect/proc_holder/spell/aimed/throw_self/fire_projectile(mob/living/user, atom/target)
	if(!item_self)
		return
	item_self.throw_at(target, 3, 3)

/obj/item/slimecross/loyal/adamantine
	colour = "adamantine"
	effect_desc = "Makes an item fireproof, and more resistant to burn effects."
	loyaleffect = /datum/component/loyal_effect/adamantine

/datum/component/loyal_effect/adamantine
	prefix = "crystal"

/datum/component/loyal_effect/adamantine/Initialize(obj/item/attached_item)
	. = ..()
	attached_item.resistance_flags |= FIRE_PROOF
	attached_item.armor = attached_item.armor.attachArmor(list("laser" = 10, "energy" = 10, "fire" = 50, "acid" = 20))

/obj/item/slimecross/loyal/rainbow
	colour = "rainbow"
	effect_desc = "Makes an item able to nullify any magic effects."
	loyaleffect = /datum/component/loyal_effect/rainbow

/datum/component/loyal_effect/rainbow
	prefix = "pure"

/datum/component/loyal_effect/rainbow/Initialize(obj/item/attached_item)
	. = ..()
	if(attached_item)
		attached_item.AddComponent(/datum/component/anti_magic, TRUE, TRUE)