//The chests dropped by mob spawner tendrils. Also contains associated loot.

#define HIEROPHANT_CLUB_CARDINAL_DAMAGE 15


/obj/structure/closet/crate/necropolis
	name = "necropolis chest"
	desc = "It's watching you closely."
	icon_state = "necro_crate"
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	door_anim_time = 0
	///prevents bust_open to fire
	integrity_failure = 0
	/// var to check if it got opened by a key
	var/spawned_loot = FALSE

/obj/structure/closet/crate/necropolis/Initialize(mapload)
	. = ..()
	RegisterSignal(src, COMSIG_ATOM_ATTACKBY, PROC_REF(try_spawn_loot))

/obj/structure/closet/crate/necropolis/proc/try_spawn_loot(datum/source, obj/item/item, mob/user, params)
	SIGNAL_HANDLER

	if(!istype(item, /obj/item/skeleton_key) || spawned_loot)
		return FALSE
	spawned_loot = TRUE
	qdel(item)
	to_chat(user, span_notice("You disable the magic lock with the [item]."))
	return TRUE

/obj/structure/closet/crate/necropolis/tendril
	desc = "It's watching you suspiciously."

/obj/structure/closet/crate/necropolis/tendril/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot - MAY REPLACE WITH pick_weight(loot)
	var/static/list/necropolis_goodies = list(	//weights to be defined later on, for now they're all the same
		/obj/item/clothing/glasses/godeye									= 5,
		/obj/item/clothing/gloves/concussive_gauntlets						= 5,
		/obj/item/rod_of_asclepius											= 5,
		/obj/item/organ/heart/cursed/wizard						 			= 5,
		/obj/item/ship_in_a_bottle											= 5,
		/obj/item/jacobs_ladder												= 5,
		/obj/item/warp_cube/red												= 5,
		/obj/item/wisp_lantern												= 5,
		/obj/item/immortality_talisman										= 5,
		/obj/item/gun/magic/hook											= 5,
		/obj/item/book_of_babel 											= 5,
		/obj/item/clothing/neck/necklace/memento_mori						= 5,
		/obj/item/reagent_containers/cup/glass/waterbottle/relic			= 5,
		/obj/item/borg/upgrade/modkit/lifesteal								= 5,
		/obj/item/shared_storage/red										= 5,
		/obj/item/staff/storm												= 5,
	)

	if(..())
		var/necropolis_loot = pick_weight(necropolis_goodies.Copy())
		new necropolis_loot(src)

/obj/structure/closet/crate/necropolis/can_open(mob/living/user, force = FALSE)
	if(!spawned_loot)
		return FALSE
	return ..()

/obj/structure/closet/crate/necropolis/examine(mob/user)
	. = ..()
	if(!spawned_loot)
		. += span_notice("You need a skeleton key to open it.")

//Rod of Asclepius
/obj/item/rod_of_asclepius
	name = "\improper Rod of Asclepius"
	desc = "A wooden rod about the size of your forearm with a snake carved around it, winding its way up the sides of the rod. Something about it seems to inspire in you the responsibilty and duty to help others."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon_state = "asclepius_dormant"
	inhand_icon_state = "asclepius_dormant"
	custom_price = 20000
	max_demand = 5

	//Switches to true when taking the oath which also gives pacifism
	canblock = FALSE
	block_power = 100
	block_flags = BLOCKING_UNBALANCE | BLOCKING_PROJECTILE

	var/activated = FALSE
	var/usedHand

/obj/item/rod_of_asclepius/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text, damage, attack_type)
	if(!activated)
		return FALSE
	return ..()

/obj/item/rod_of_asclepius/attack_self(mob/user)
	if(activated)
		return
	if(!iscarbon(user))
		to_chat(user, span_warning("The snake carving seems to come alive, if only for a moment, before returning to its dormant state, almost as if it finds you incapable of holding its oath."))
		return
	var/mob/living/carbon/itemUser = user
	usedHand = itemUser.get_held_index_of_item(src)
	if(itemUser.has_status_effect(/datum/status_effect/hippocratic_oath))
		to_chat(user, span_warning("You can't possibly handle the responsibility of more than one rod!"))
		return
	var/failText = span_warning("The snake seems unsatisfied with your incomplete oath and returns to its previous place on the rod, returning to its dormant, wooden state. You must stand still while completing your oath!")
	to_chat(itemUser, span_notice("The wooden snake that was carved into the rod seems to suddenly come alive and begins to slither down your arm! The compulsion to help others grows abnormally strong..."))
	if(do_after(itemUser, 40, target = itemUser))
		itemUser.say("I swear to fulfill, to the best of my ability and judgment, this covenant:", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 20, target = itemUser))
		itemUser.say("I will apply, for the benefit of the sick, all measures that are required, avoiding those twin traps of overtreatment and therapeutic nihilism.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("I will remember that I remain a member of society, with special obligations to all my fellow human beings, those sound of mind and body as well as the infirm.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	if(do_after(itemUser, 30, target = itemUser))
		itemUser.say("If I do not violate this oath, may I enjoy life and art, respected while I live and remembered with affection thereafter. May I always act so as to preserve the finest traditions of my calling and may I long experience the joy of healing those who seek my help.", forced = "hippocratic oath")
	else
		to_chat(itemUser, failText)
		return
	to_chat(itemUser, span_notice("The snake, satisfied with your oath, attaches itself and the rod to your forearm with an inseparable grip. Your thoughts seem to only revolve around the core idea of helping others, and harm is nothing more than a distant, wicked memory..."))
	var/datum/status_effect/hippocratic_oath/effect = itemUser.apply_status_effect(/datum/status_effect/hippocratic_oath)
	effect.hand = usedHand
	activated()
	itemUser.regenerate_icons()

/obj/item/rod_of_asclepius/proc/activated()
	item_flags = DROPDEL
	ADD_TRAIT(src, TRAIT_NODROP, CURSED_ITEM_TRAIT)
	desc = "A short wooden rod with a mystical snake inseparably gripping itself and the rod to your forearm. It flows with a healing energy that disperses amongst yourself and those around you. "
	icon_state = "asclepius_active"
	inhand_icon_state = "asclepius_active"
	activated = TRUE
	canblock = TRUE

//Memento Mori
/obj/item/clothing/neck/necklace/memento_mori
	name = "Memento Mori"
	desc = "A mysterious pendant. An inscription on it says: \"Certain death tomorrow means certain life today.\""
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "memento_mori"
	worn_icon_state = "memento"
	actions_types = list(/datum/action/item_action/hands_free/memento_mori)
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	var/mob/living/carbon/human/active_owner
	custom_price = 10000
	max_demand = 10

/obj/item/clothing/neck/necklace/memento_mori/item_action_slot_check(slot)
	return slot == ITEM_SLOT_NECK

/obj/item/clothing/neck/necklace/memento_mori/dropped(mob/user)
	..()
	if(active_owner)
		mori()

//Just in case
/obj/item/clothing/neck/necklace/memento_mori/Destroy()
	if(active_owner)
		mori()
	return ..()

/obj/item/clothing/neck/necklace/memento_mori/proc/memento(mob/living/carbon/human/user)
	if(IS_VAMPIRE(user))
		to_chat(user, span_warning("The Memento notices your undead soul, and refuses to react.."))
		return

	to_chat(user, span_warning("You feel your life being drained by the pendant..."))
	if(do_after(user, 40, target = user))
		to_chat(user, span_notice("Your lifeforce is now linked to the pendant! You feel like removing it would kill you, and yet you instinctively know that until then, you won't die."))
		ADD_TRAIT(user, TRAIT_NODEATH, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOHARDCRIT, "memento_mori")
		ADD_TRAIT(user, TRAIT_NOCRITDAMAGE, "memento_mori")
		icon_state = "memento_mori_active"
		active_owner = user

/obj/item/clothing/neck/necklace/memento_mori/proc/mori()
	icon_state = "memento_mori"
	if(!active_owner)
		return
	var/mob/living/carbon/human/H = active_owner //to avoid infinite looping when dust unequips the pendant
	active_owner = null
	to_chat(H, span_userdanger("You feel your life rapidly slipping away from you!"))
	H.dust(TRUE, TRUE)

/datum/action/item_action/hands_free/memento_mori
	check_flags = NONE
	name = "Memento Mori"
	desc = "Bind your life to the pendant."

/datum/action/item_action/hands_free/memento_mori/on_activate(mob/user, atom/target)
	var/obj/item/clothing/neck/necklace/memento_mori/MM = target
	if(!MM.active_owner)
		if(ishuman(owner))
			MM.memento(owner)
	else
		to_chat(owner, span_warning("You try to free your lifeforce from the pendant..."))
		if(do_after(owner, 40, target = owner))
			MM.mori()

//Wisp Lantern
/obj/item/wisp_lantern
	name = "spooky lantern"
	desc = "This lantern gives off no light, but is home to a friendly wisp."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "lantern-blue"
	inhand_icon_state = "lantern"
	lefthand_file = 'icons/mob/inhands/equipment/mining_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/mining_righthand.dmi'
	var/obj/effect/wisp/wisp
	custom_price = 10000
	max_demand = 10

/obj/item/wisp_lantern/attack_self(mob/user)
	if(!wisp)
		to_chat(user, span_warning("The wisp has gone missing!"))
		icon_state = "lantern"
		return

	if(wisp.loc == src)
		if(COOLDOWN_FINISHED(wisp,wisp_tired))
			to_chat(user, span_notice("You release the wisp. It begins to bob around your head."))
			icon_state = "lantern"
			wisp.orbit(user, 20)
			wisp.set_light_on(TRUE)
			SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Freed")
		else
			to_chat(user,span_warning("The wisp is tired, let it rest for bit longer."))

	else
		to_chat(user, span_notice("You return the wisp to the lantern."))
		icon_state = "lantern-blue"
		wisp.forceMove(src)
		SSblackbox.record_feedback("tally", "wisp_lantern", 1, "Returned")

/obj/item/wisp_lantern/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	. = ..()
	wisp.lighteater_act(light_eater)

/obj/item/wisp_lantern/Initialize(mapload)
	. = ..()
	wisp = new(src)
	wisp.home = src

/obj/item/wisp_lantern/Destroy()
	if(wisp)
		if(wisp.loc == src)
			QDEL_NULL(wisp)
		else
			wisp.visible_message(span_notice("[wisp] has a sad feeling for a moment, then it passes."))
	return ..()

/obj/effect/wisp
	name = "friendly wisp"
	desc = "Happy to light your way."
	icon = 'icons/obj/lighting.dmi'
	icon_state = "orb"
	light_system = MOVABLE_LIGHT
	light_range = 7
	light_flags = LIGHT_ATTACHED
	layer = ABOVE_ALL_MOB_LAYER
	var/obj/item/wisp_lantern/home
	var/sight_flags = SEE_MOBS
	var/lighting_alpha = LIGHTING_PLANE_ALPHA_MOSTLY_VISIBLE
	COOLDOWN_DECLARE(wisp_tired)
	var/time

/obj/effect/wisp/Destroy(force)
	home = null
	return ..()


/obj/effect/wisp/orbit(atom/thing, radius, clockwise, rotation_speed, rotation_segments, pre_rotation, lockinorbit)
	. = ..()
	if(ismob(thing))
		RegisterSignal(thing, COMSIG_MOB_UPDATE_SIGHT, PROC_REF(update_user_sight))
		RegisterSignal(thing, COMSIG_ATOM_LIGHTEATER_ACT, PROC_REF(on_lighteater_act))
		var/mob/being = thing
		being.update_sight()
		to_chat(thing, span_notice("The wisp enhances your vision."))

/obj/effect/wisp/stop_orbit(datum/component/orbiter/orbits)
	. = ..()
	if(ismob(orbits.parent))
		UnregisterSignal(orbits.parent, COMSIG_MOB_UPDATE_SIGHT)
		UnregisterSignal(orbits.parent, COMSIG_ATOM_LIGHTEATER_ACT)
		to_chat(orbits.parent, span_notice("Your vision returns to normal."))

/obj/effect/wisp/proc/update_user_sight(mob/user)
	SIGNAL_HANDLER

	user.sight |= sight_flags
	if(!isnull(lighting_alpha))
		user.lighting_alpha = min(user.lighting_alpha, lighting_alpha)

/obj/effect/wisp/proc/on_lighteater_act(obj/item/light_eater/light_eater)
	SIGNAL_HANDLER
	src.lighteater_act(light_eater)

/obj/effect/wisp/lighteater_act(obj/item/light_eater/light_eater, atom/parent)
	. = ..()
	if(home)
		src.forceMove(home)
		COOLDOWN_START(src,wisp_tired, 5 MINUTES)
		home.icon_state = "lantern-blue"
		set_light_on(FALSE)
	else
		stop_orbit()
		qdel(src)

// Relic water bottle
/obj/item/reagent_containers/cup/glass/waterbottle/relic
	name = "ancient bottle of unknown reagent"
	desc = "A bottle of water filled with unknown liquids. It seems to be radiating some kind of energy."
	flip_chance = 100 // FLIPP
	list_reagents = list()
	custom_price = 10000
	max_demand = 10

/obj/item/reagent_containers/cup/glass/waterbottle/relic/Initialize(mapload)
	var/reagents = volume
	while(reagents)
		var/newreagent = rand(1, min(reagents, 30))
		list_reagents += list(get_random_reagent_id(CHEMICAL_RNG_FUN) = newreagent)
		reagents -= newreagent
	. = ..()

//Red/Blue Cubes
/obj/item/warp_cube
	name = "blue cube"
	desc = "A mysterious blue cube."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "blue_cube"
	var/teleport_color = "#3FBAFD"
	var/obj/item/warp_cube/linked
	var/teleporting = FALSE

/obj/item/warp_cube/Destroy()
	if(!QDELETED(linked))
		qdel(linked)
	linked =  null
	return ..()

/obj/item/warp_cube/attack_self(mob/user)
	if(!linked)
		to_chat(user, "[src] fizzles uselessly.")
		return
	if(teleporting)
		return
	var/turf/T = get_turf(src)
	var/area/A1 = get_area(T)
	var/area/A2 = get_area(linked)
	if(A1.teleport_restriction || A2.teleport_restriction)
		to_chat(user, "[src] fizzles gently as it fails to breach the bluespace veil.")
		return
	teleporting = TRUE
	linked.teleporting = TRUE
	new /obj/effect/temp_visual/warp_cube(T, user, teleport_color, TRUE)
	SSblackbox.record_feedback("tally", "warp_cube", 1, type)
	new /obj/effect/temp_visual/warp_cube(get_turf(linked), user, linked.teleport_color, FALSE)
	var/obj/effect/warp_cube/link_holder = new /obj/effect/warp_cube(T)
	user.forceMove(link_holder) //mess around with loc so the user can't wander around
	sleep(2.5)
	if(QDELETED(user))
		qdel(link_holder)
		return
	if(QDELETED(linked))
		user.forceMove(get_turf(link_holder))
		qdel(link_holder)
		return
	do_teleport(link_holder, get_turf(linked), no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC_SELF)
	sleep(2.5)
	if(QDELETED(user))
		qdel(link_holder)
		return
	teleporting = FALSE
	if(!QDELETED(linked))
		linked.teleporting = FALSE
	user.forceMove(get_turf(link_holder))
	qdel(link_holder)

/obj/item/warp_cube/red
	name = "red cube"
	desc = "A mysterious red cube."
	icon_state = "red_cube"
	teleport_color = "#FD3F48"

/obj/item/warp_cube/red/Initialize(mapload)
	. = ..()
	if(!linked)
		var/obj/item/warp_cube/blue = new(src.loc)
		linked = blue
		blue.linked = src

/obj/effect/warp_cube
	mouse_opacity = MOUSE_OPACITY_TRANSPARENT
	anchored = TRUE

//Meat Hook
/obj/item/gun/magic/hook
	name = "meat hook"
	desc = "Mid or feed."
	ammo_type = /obj/item/ammo_casing/magic/hook
	icon_state = "hook"
	inhand_icon_state = "chain"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	fire_sound = 'sound/weapons/batonextend.ogg'
	max_charges = 1
	item_flags = NEEDS_PERMIT | ISWEAPON
	sharpness = SHARP
	force = 15
	attack_weight = 2
	custom_price = 10000
	max_demand = 10

/obj/item/gun/magic/hook/shoot_with_empty_chamber(mob/living/user)
	to_chat(user, "<span class='warning'>[src] isn't ready to fire yet!</span>")

/obj/item/ammo_casing/magic/hook
	name = "hook"
	desc = "A hook."
	projectile_type = /obj/projectile/hook
	caliber = "hook"
	firing_effect_type = /obj/effect/temp_visual/dir_setting/firing_effect/energy

/obj/projectile/hook
	name = "hook"
	icon_state = "hook"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	pass_flags = PASSTABLE
	damage = 10
	armour_penetration = 100
	damage_type = BRUTE
	hitsound = 'sound/effects/splat.ogg'
	knockdown = 30
	bleed_force = BLEED_SURFACE
	var/chain

/obj/projectile/hook/fire(setAngle)
	if(firer)
		chain = firer.Beam(src, icon_state = "chain")
	..()
	//TODO: root the firer until the chain returns

/obj/projectile/hook/on_hit(atom/target)
	. = ..()
	if(ismovable(target))
		var/atom/movable/A = target
		if(A.anchored)
			return
		A.visible_message(span_danger("[A] is snagged by [firer]'s hook!"))
		new /datum/forced_movement(A, get_turf(firer), 5, TRUE)
		//TODO: keep the chain beamed to A
		//TODO: needs a callback to delete the chain

/obj/projectile/hook/Destroy()
	qdel(chain)
	return ..()

//just a nerfed version of the real thing for the bounty hunters.
/obj/item/gun/magic/hook/bounty
	name = "hook"
	ammo_type = /obj/item/ammo_casing/magic/hook/bounty

/obj/item/ammo_casing/magic/hook/bounty
	projectile_type = /obj/projectile/hook/bounty

/obj/projectile/hook/bounty
	damage = 0
	paralyze = 20

//Immortality Talisman
/obj/item/immortality_talisman
	name = "\improper Immortality Talisman"
	desc = "A dread talisman that can render you completely invulnerable."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "talisman"
	resistance_flags = INDESTRUCTIBLE | LAVA_PROOF | FIRE_PROOF | UNACIDABLE | ACID_PROOF
	actions_types = list(/datum/action/item_action/immortality)
	var/cooldown = 0
	custom_price = 10000
	max_demand = 10

/obj/item/immortality_talisman/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/anti_magic, INNATE_TRAIT, (MAGIC_RESISTANCE|MAGIC_RESISTANCE_HOLY))

/datum/action/item_action/immortality
	name = "Immortality"

/obj/item/immortality_talisman/attack_self(mob/user)
	if(cooldown < world.time)
		SSblackbox.record_feedback("amount", "immortality_talisman_uses", 1)
		cooldown = world.time + 600
		new /obj/effect/immortality_talisman(get_turf(user), user)
	else
		to_chat(user, span_warning("[src] is not ready yet!"))

/obj/effect/immortality_talisman
	name = "hole in reality"
	desc = "It's shaped an awful lot like a person."
	icon_state = "blank"
	icon = 'icons/effects/effects.dmi'
	var/vanish_description = "vanishes from reality"
	var/can_destroy = TRUE

CREATION_TEST_IGNORE_SUBTYPES(/obj/effect/immortality_talisman)

/obj/effect/immortality_talisman/Initialize(mapload, mob/new_user)
	. = ..()
	if(new_user)
		vanish(new_user)

/obj/effect/immortality_talisman/proc/vanish(mob/user)
	user.visible_message(span_danger("[user] [vanish_description], leaving a hole in [user.p_their()] place!"))

	desc = "It's shaped an awful lot like [user.name]."
	setDir(user.dir)

	user.forceMove(src)
	user.notransform = TRUE
	ADD_TRAIT(user, TRAIT_GODMODE, "[type]")

	can_destroy = FALSE

	addtimer(CALLBACK(src, PROC_REF(unvanish), user), 10 SECONDS)

/obj/effect/immortality_talisman/proc/unvanish(mob/user)
	REMOVE_TRAIT(user, TRAIT_GODMODE, "[type]")
	user.notransform = FALSE
	user.forceMove(get_turf(src))

	user.visible_message(span_danger("[user] pops back into reality!"))
	can_destroy = TRUE
	qdel(src)

/obj/effect/immortality_talisman/attackby()
	return

/obj/effect/immortality_talisman/singularity_pull(obj/anomaly/singularity/singularity, current_size)
	return

/obj/effect/immortality_talisman/Destroy(force)
	if(!can_destroy && !force)
		return QDEL_HINT_LETMELIVE
	else
		. = ..()

/obj/effect/immortality_talisman/void
	vanish_description = "is dragged into the void"

//Shared Bag

/obj/item/shared_storage
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "paradox_bag"
	worn_icon_state = "paradoxbag"
	slot_flags = ITEM_SLOT_BELT
	resistance_flags = INDESTRUCTIBLE

/obj/item/shared_storage/red
	name = "paradox bag"
	desc = "Somehow, it's in two places at once."

/obj/item/shared_storage/red/Initialize(mapload)
	. = ..()

	create_storage(max_total_storage = 60, max_slots = 21)

	new /obj/item/shared_storage/blue(drop_location(), src)

CREATION_TEST_IGNORE_SUBTYPES(/obj/item/shared_storage/blue)

/obj/item/shared_storage/blue/Initialize(mapload, atom/master)
	. = ..()
	if(!istype(master))
		return INITIALIZE_HINT_QDEL
	create_storage(max_total_storage = 60, max_slots = 21)

	atom_storage.set_real_location(master)

//Book of Babel

/obj/item/book_of_babel
	name = "Book of Babel"
	desc = "An ancient tome written in countless tongues."
	icon = 'icons/obj/library.dmi'
	icon_state = "book1"
	w_class = 2
	custom_price = 10000
	max_demand = 10

/obj/item/book_of_babel/attack_self(mob/user)
	if(!user.can_read(src))
		return FALSE
	to_chat(user, "You flip through the pages of the book, quickly and conveniently learning every language in existence. Somewhat less conveniently, the aging book crumbles to dust in the process. Whoops.")
	user.grant_all_languages(source = LANGUAGE_BABEL)
	new /obj/effect/decal/cleanable/ash(get_turf(user))
	qdel(src)


//Potion of Flight
/obj/item/reagent_containers/cup/bottle/potion
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "potionflask"

/obj/item/reagent_containers/cup/bottle/potion/flight
	name = "strange elixir"
	desc = "A flask with an almost-holy aura emitting from it. The label on the bottle says: 'erqo'hyy tvi'rf lbh jv'atf'."
	list_reagents = list(/datum/reagent/flightpotion = 5)
	custom_price = 10000
	max_demand = 10

/obj/item/reagent_containers/cup/bottle/potion/update_icon()
	if(reagents.total_volume)
		icon_state = "potionflask"
	else
		icon_state = "potionflask_empty"

/datum/reagent/flightpotion
	name = "Flight Potion"
	description = "Strange mutagenic compound of unknown origins."
	reagent_state = LIQUID
	process_flags = ORGANIC | SYNTHETIC
	color = "#FFEBEB"
	chemical_flags = CHEMICAL_RNG_FUN | CHEMICAL_RNG_BOTANY

/datum/reagent/flightpotion/expose_mob(mob/living/M, method=TOUCH, reac_volume, show_message = 1)
	if(iscarbon(M) && M.stat != DEAD)
		var/mob/living/carbon/C = M
		var/holycheck = ishumanbasic(C)
		if(reac_volume < 5) // implying xenohumans are holy //as with all things,
			if(method == INGEST && show_message)
				to_chat(C, span_notice("<i>You feel nothing but a terrible aftertaste.</i>"))
			return ..()
		if(ishuman(C))
			var/mob/living/carbon/human/H = C
			var/obj/item/organ/wings/wings = H.get_organ_slot(ORGAN_SLOT_WINGS)
			if(H.get_organ_by_type(/obj/item/organ/wings))
				if(wings.flight_level <= WINGS_FLIGHTLESS)
					wings.flight_level += 1 //upgrade the flight level
					wings.Refresh(H) //they need to insert to get the flight emote
			else
				if(H.mob_biotypes & MOB_ROBOTIC)
					var/obj/item/organ/wings/cybernetic/newwings = new()
					newwings.Insert(H)
				else if(holycheck)
					var/obj/item/organ/wings/angel/newwings = new()
					newwings.Insert(H)
				else
					var/obj/item/organ/wings/dragon/newwings = new()
					newwings.Insert(H)
				to_chat(C, span_userdanger("A terrible pain travels down your back as wings burst out!"))
				playsound(C.loc, 'sound/items/poster_ripped.ogg', 50, TRUE, -1)
				C.adjustBruteLoss(20)
				C.emote("scream")
		if(holycheck)
			to_chat(C, span_notice("You feel blessed!"))
			C.AddComponent(/datum/component/anti_magic, SPECIES_TRAIT, MAGIC_RESISTANCE_HOLY)
	..()


/obj/item/jacobs_ladder
	name = "jacob's ladder"
	desc = "A celestial ladder that violates the laws of physics."
	icon = 'icons/obj/structures.dmi'
	icon_state = "ladder00"

/obj/item/jacobs_ladder/attack_self(mob/user)
	var/turf/T = get_turf(src)
	var/ladder_x = T.x
	var/ladder_y = T.y
	to_chat(user, span_notice("You unfold the ladder. It extends much farther than you were expecting."))
	var/last_ladder = null
	for(var/i in 1 to world.maxz)
		if(is_centcom_level(i) || is_reserved_level(i) || is_reebe(i) || is_away_level(i) || is_debug_level(i))
			continue
		var/turf/T2 = locate(ladder_x, ladder_y, i)
		last_ladder = new /obj/structure/ladder/unbreakable/jacob(T2, null, last_ladder)
	qdel(src)

// Inherit from unbreakable but don't set ID, to suppress the default Z linkage
/obj/structure/ladder/unbreakable/jacob
	name = "jacob's ladder"
	desc = "An indestructible celestial ladder that violates the laws of physics."

/obj/item/clothing/gloves/concussive_gauntlets
	name = "concussive gauntlets"
	desc = "Pickaxes... for your hands!"
	icon_state = "concussive_gauntlets"
	worn_icon_state = "concussive_gauntlets"
	inhand_icon_state = "combatgloves"
	toolspeed = 0.1 //Sonic jackhammer, but only works on minerals.
	strip_delay = 40
	equip_delay_other = 20
	cold_protection = HANDS
	min_cold_protection_temperature = GLOVES_MIN_TEMP_PROTECT
	heat_protection = HANDS
	max_heat_protection_temperature = GLOVES_MAX_TEMP_PROTECT
	resistance_flags = LAVA_PROOF | FIRE_PROOF //they are from lavaland after all
	armor_type = /datum/armor/gloves_concussive_gauntlets


/datum/armor/gloves_concussive_gauntlets
	melee = 15
	bullet = 35
	laser = 35
	energy = 20
	bomb = 35
	bio = 35
	stamina = 20
	bleed = 20

/obj/item/clothing/gloves/concussive_gauntlets/equipped(mob/user, slot)
	. = ..()
	if(slot == ITEM_SLOT_GLOVES)
		tool_behaviour = TOOL_MINING
		RegisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK, PROC_REF(rocksmash))
		RegisterSignal(user, COMSIG_MOVABLE_BUMP, PROC_REF(rocksmash))
	else
		stopmining(user)

/obj/item/clothing/gloves/concussive_gauntlets/dropped(mob/user)
	. = ..()
	stopmining(user)

/obj/item/clothing/gloves/concussive_gauntlets/proc/stopmining(mob/user)
	tool_behaviour = initial(tool_behaviour)
	UnregisterSignal(user, COMSIG_HUMAN_EARLY_UNARMED_ATTACK)
	UnregisterSignal(user, COMSIG_MOVABLE_BUMP)

/obj/item/clothing/gloves/concussive_gauntlets/proc/rocksmash(mob/living/carbon/human/user, atom/rocks, proximity)
	if(!ismineralturf(rocks))
		return
	rocks.attackby(src, user)

///Bosses

//Legion

/obj/structure/closet/crate/necropolis/legion
	name = "legion chest"

/obj/structure/closet/crate/necropolis/legion/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		var/list/choices = subtypesof(/obj/machinery/anomalous_crystal)
		var/random_crystal = pick(choices)
		new random_crystal(src)

//Miniboss Miner

/obj/structure/closet/crate/necropolis/bdm
	name = "blood-drunk miner chest"

/obj/structure/closet/crate/necropolis/bdm/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		new /obj/item/melee/cleaving_saw(src)
		new /obj/item/crusher_trophy/miner_eye(src)

/obj/item/melee/cleaving_saw
	name = "cleaving saw"
	desc = "This saw, effective at drawing the blood of beasts, transforms into a long cleaver that makes use of centrifugal force."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	icon_state = "cleaving_saw"
	inhand_icon_state = "cleaving_saw"
	worn_icon_state = "cleaving_saw"
	attack_verb_continuous = list("attacks", "saws", "slices", "tears", "lacerates", "rips", "dices", "cuts")
	attack_verb_simple = list("attack", "saw", "slice", "tear", "lacerate", "rip", "dice", "cut")
	force = 8
	throwforce = 20
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BELT
	hitsound = 'sound/weapons/bladeslice.ogg'
	w_class = WEIGHT_CLASS_BULKY
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	custom_price = 40000
	max_demand = 2
	/// List of factions we deal bonus damage to
	var/list/nemesis_factions = list(FACTION_MINING, FACTION_BOSS)
	/// Amount of damage we deal to the above factions
	var/faction_bonus_force = 45
	/// Whether the cleaver is actively AoE swiping something.
	var/swiping = FALSE
	/// Amount of bleed stacks gained per hit
	var/bleed_stacks_per_hit = 3
	/// Force when the saw is opened.
	var/open_force = 15
	/// Throwforce when the saw is opened.
	var/open_throwforce = 20

/obj/item/melee/cleaving_saw/Initialize(mapload)
	. = ..()
	AddComponent( \
		/datum/component/transforming, \
		transform_cooldown_time = (CLICK_CD_MELEE * 0.50), \
		force_on = open_force, \
		throwforce_on = open_throwforce, \
		sharpness_on = sharpness, \
		hitsound_on = hitsound, \
		w_class_on = w_class, \
		attack_verb_continuous_on = list("cleaves", "swipes", "slashes", "chops"), \
		attack_verb_simple_on = list("cleave", "swipe", "slash", "chop"), \
	)
	RegisterSignal(src, COMSIG_TRANSFORMING_ON_TRANSFORM, PROC_REF(on_transform))

/obj/item/melee/cleaving_saw/examine(mob/user)
	. = ..()
	. += span_notice("It is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "open, will cleave enemies in a wide arc and deal additional damage to fauna":"closed, and can be used for rapid consecutive attacks that cause fauna to bleed"].")
	. += span_notice("Both modes will build up existing bleed effects, doing a burst of high damage if the bleed is built up high enough.")
	. += span_notice("Transforming it immediately after an attack causes the next attack to come out faster.")

/obj/item/melee/cleaving_saw/suicide_act(mob/living/user)
	user.visible_message(span_suicide("[user] is [HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE) ? "closing [src] on [user.p_their()] neck" : "opening [src] into [user.p_their()] chest"]! It looks like [user.p_theyre()] trying to commit suicide!"))
	attack_self(user)
	return BRUTELOSS

/obj/item/melee/cleaving_saw/melee_attack_chain(mob/user, atom/target, params)
	. = ..()
	if(!HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE))
		user.changeNext_move(CLICK_CD_MELEE * 0.5) //when closed, it attacks very rapidly

/obj/item/melee/cleaving_saw/attack(mob/living/target, mob/living/carbon/human/user)
	var/is_open = HAS_TRAIT(src, TRAIT_TRANSFORM_ACTIVE)
	if(!is_open || swiping || !target.density || get_turf(target) == get_turf(user))
		if(!is_open)
			faction_bonus_force = 0
		var/is_nemesis_faction = FALSE
		for(var/found_faction in target.faction)
			if(found_faction in nemesis_factions)
				is_nemesis_faction = TRUE
				force += faction_bonus_force
				nemesis_effects(user, target)
				break
		. = ..()
		if(is_nemesis_faction)
			force -= faction_bonus_force
		if(!is_open)
			faction_bonus_force = initial(faction_bonus_force)
	else
		var/turf/user_turf = get_turf(user)
		var/dir_to_target = get_dir(user_turf, get_turf(target))
		swiping = TRUE
		var/static/list/cleaving_saw_cleave_angles = list(0, -45, 45) //so that the animation animates towards the target clicked and not towards a side target
		for(var/i in cleaving_saw_cleave_angles)
			var/turf/turf = get_step(user_turf, turn(dir_to_target, i))
			for(var/mob/living/living_target in turf)
				if(user.Adjacent(living_target) && living_target.body_position != LYING_DOWN)
					melee_attack_chain(user, living_target)
		swiping = FALSE

/*
 * If we're attacking [target]s in our nemesis list, apply unique effects.
 *
 * user - the mob attacking with the saw
 * target - the mob being attacked
 */
/obj/item/melee/cleaving_saw/proc/nemesis_effects(mob/living/user, mob/living/target)
	if(istype(target, /mob/living/simple_animal/hostile/asteroid/elite))
		return
	var/datum/status_effect/stacking/saw_bleed/existing_bleed = target.has_status_effect(/datum/status_effect/stacking/saw_bleed)
	if(existing_bleed)
		existing_bleed.add_stacks(bleed_stacks_per_hit)
	else
		target.apply_status_effect(/datum/status_effect/stacking/saw_bleed, bleed_stacks_per_hit)

/*
 * Signal proc for [COMSIG_TRANSFORMING_ON_TRANSFORM].
 *
 * Gives feedback and makes the nextmove after transforming much quicker.
 */
/obj/item/melee/cleaving_saw/proc/on_transform(obj/item/source, mob/user, active)
	SIGNAL_HANDLER

	user.changeNext_move(CLICK_CD_MELEE * 0.25)
	if(user)
		balloon_alert(user, "[active ? "opened" : "closed"] [src]")
	playsound(src, 'sound/magic/clockwork/fellowship_armory.ogg', 35, TRUE, frequency = 90000 - (active * 30000))
	return COMPONENT_NO_DEFAULT_MESSAGE

//Dragon

/obj/structure/closet/crate/necropolis/dragon
	name = "drake chest"

/obj/structure/closet/crate/necropolis/dragon/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		new /obj/item/dragons_blood(src)
		new /obj/item/clothing/suit/hooded/cloak/drake(src)	 //Drake armor crafted only by Ashwalkers now, but still available as drop for miners
		new /obj/item/crusher_trophy/tail_spike(src)
	//new /obj/item/book/granter/action/spell/sacredflame(src) It's supposed to drop from the dragon but idk if you guys want it like that tell me in the review code


// Ghost Sword - left in for other references and admin shenanigans

/obj/item/melee/ghost_sword
	name = "\improper spectral blade"
	desc = "A rusted and dulled blade. It doesn't look like it'd do much damage. It glows weakly."
	icon_state = "spectral"
	inhand_icon_state = "spectral"
	lefthand_file = 'icons/mob/inhands/weapons/swords_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/swords_righthand.dmi'
	flags_1 = CONDUCT_1
	sharpness = SHARP_DISMEMBER
	bleed_force = BLEED_CUT
	w_class = WEIGHT_CLASS_BULKY
	force = 1
	throwforce = 1
	custom_price = 10000
	max_demand = 10

	canblock = TRUE
	//This increases with the number of ghosts
	block_power = 0
	block_flags = BLOCKING_ACTIVE | BLOCKING_NASTY

	hitsound = 'sound/effects/ghost2.ogg'
	attack_verb_continuous = list("attacks", "slashes", "stabs", "slices", "tears", "lacerates", "rips", "dices", "rends")
	attack_verb_simple = list("attack", "slash", "stab", "slice", "tear", "lacerate", "rip", "dice", "rend")
	var/summon_cooldown = 0
	var/list/mob/dead/observer/spirits

/obj/item/melee/ghost_sword/Initialize(mapload)
	. = ..()
	spirits = list()
	START_PROCESSING(SSobj, src)
	AddElement(/datum/element/point_of_interest)
	AddComponent(/datum/component/butchering, 150, 90)

/obj/item/melee/ghost_sword/Destroy()
	for(var/mob/dead/observer/G in spirits)
		G.invisibility = GLOB.observer_default_invisibility
	spirits.Cut()
	STOP_PROCESSING(SSobj, src)
	. = ..()

/obj/item/melee/ghost_sword/attack_self(mob/user)
	if(summon_cooldown > world.time)
		to_chat(user, "You just recently called out for aid. You don't want to annoy the spirits.")
		return
	to_chat(user, "You call out for aid, attempting to summon spirits to your side.")

	notify_ghosts("[user] is raising [user.p_their()] [src], calling for your help!",
		enter_link="<a href='byond://?src=[REF(src)];orbit=1'>(Click to help)</a>",
		source = user, action=NOTIFY_ORBIT, ignore_key = POLL_IGNORE_SPECTRAL_BLADE, header = "Spectral blade")

	summon_cooldown = world.time + 600

/obj/item/melee/ghost_sword/Topic(href, href_list)
	if(href_list["orbit"])
		var/mob/dead/observer/ghost = usr
		if(istype(ghost))
			ghost.check_orbitable(src)

/obj/item/melee/ghost_sword/process()
	ghost_check()

/obj/item/melee/ghost_sword/proc/ghost_check()
	var/ghost_counter = 0
	var/turf/T = get_turf(src)
	var/list/contents = T.GetAllContents()
	var/mob/dead/observer/current_spirits = list()
	for(var/thing in contents)
		var/atom/A = thing
		A.transfer_observers_to(src)

	for(var/i in orbit_datum?.current_orbiters)
		if(!isobserver(i))
			continue
		var/mob/dead/observer/G = i
		ghost_counter++
		G.invisibility = 0
		current_spirits |= G

	for(var/mob/dead/observer/G in spirits - current_spirits)
		G.invisibility = GLOB.observer_default_invisibility

	spirits = current_spirits

	return ghost_counter

/obj/item/melee/ghost_sword/attack(mob/living/target, mob/living/carbon/human/user)
	force = 0
	var/ghost_counter = ghost_check()

	force = clamp((ghost_counter * 4), 0, 75)
	user.visible_message(span_danger("[user] strikes with the force of [ghost_counter] vengeful spirits!"))
	..()

/obj/item/melee/ghost_sword/hit_reaction(mob/living/carbon/human/owner, atom/movable/hitby, attack_text = "the attack", damage = 0, attack_type = MELEE_ATTACK)
	var/ghost_counter = ghost_check()
	if(ghost_counter)
		block_power = min((ghost_counter * 20), 100)
		owner.visible_message(span_danger("[owner] is protected by a ring of [ghost_counter] ghosts!"))
	return ..()

//Blood

/obj/item/dragons_blood
	name = "bottle of dragons blood"
	desc = "You're not actually going to drink this, are you?"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	custom_price = 10000
	max_demand = 10

/obj/item/dragons_blood/attack_self(mob/living/carbon/human/user)
	if(!istype(user))
		return

	var/mob/living/carbon/human/H = user
	var/random = rand(1,3)

	switch(random)
		if(1)
			to_chat(user, span_danger("Your appearance morphs to that of a very small humanoid ash dragon! You get to look like a freak without the cool abilities."))
			H.dna.features = list(
				"body_size" = "Normal",
				"mcolor" = "A02720",
				"tail_lizard" = "Dark Tiger",
				"tail_human" = "None",
				"snout" = "Sharp",
				"horns" = "Curled",
				"ears" = "None",
				"wings" = "None",
				"frills" = "None",
				"spines" = "Long",
				"body_markings" = "Dark Tiger Body",
				"legs" = DIGITIGRADE_LEGS,
			)
			H.eye_color = "fee5a3"
			H.set_species(/datum/species/lizard)
		if(2)
			to_chat(user, span_danger("Your flesh begins to melt! Miraculously, you seem fine otherwise."))
			H.set_species(/datum/species/skeleton)
		if(3)
			to_chat(user, span_danger("You feel like you could walk straight through lava now."))
			ADD_TRAIT(H, TRAIT_LAVA_IMMUNE, type)

	playsound(user.loc,'sound/items/drink.ogg', rand(10,50), 1)
	qdel(src)

/datum/disease/transformation/dragon
	name = "dragon transformation"
	cure_text = "nothing"
	cures = list(/datum/reagent/medicine/adminordrazine)
	agent = "dragon's blood"
	desc = "What do dragons have to do with Space Station 13?"
	stage_prob = 10
	danger = DISEASE_BIOHAZARD
	visibility_flags = 0
	stage1	= list("Your bones ache.")
	stage2	= list("Your skin feels scaly.")
	stage3	= list(span_danger("You have an overwhelming urge to terrorize some peasants."), span_danger("Your teeth feel sharper."))
	stage4	= list(span_danger("Your blood burns."))
	stage5	= list(span_danger("You're a fucking dragon. However, any previous allegiances you held still apply. It'd be incredibly rude to eat your still human friends for no reason."))
	new_form = /mob/living/simple_animal/hostile/megafauna/dragon/lesser


//Lava Staff

/obj/item/lava_staff
	name = "staff of lava"
	desc = "The power to manipulate lava. What more could you want out of life?"
	icon_state = "staffofstorms"
	inhand_icon_state = "staffofstorms"
	lefthand_file = 'icons/mob/inhands/weapons/staves_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/staves_righthand.dmi'
	icon = 'icons/obj/guns/magic.dmi'
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 15
	damtype = BURN
	resistance_flags = LAVA_PROOF | FIRE_PROOF | ACID_PROOF
	hitsound = 'sound/weapons/sear.ogg'
	item_flags = ISWEAPON
	custom_price = 10000
	max_demand = 10
	var/turf_type = /turf/open/lava/smooth
	var/transform_string = "lava"
	var/reset_turf_type = /turf/open/floor/plating/asteroid/basalt
	var/reset_string = "basalt"
	var/create_cooldown = 100
	var/create_delay = 30
	var/reset_cooldown = 50
	var/timer = 0
	var/static/list/banned_turfs = typecacheof(list(
		/turf/closed,
	))
	var/static/list/allowed_areas = typecacheof(list(
		/area/lavaland/surface/outdoors,
	))

/obj/item/lava_staff/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!is_mining_level(user.z))
		to_chat(user, span_warning("The staff's power is too dim to function this far from the necropolis"))
		return
	if(timer > world.time)
		to_chat(user, span_warning("The staff is still recharging!"))
		return
	var/area/target_area = get_area(target)
	if(is_type_in_typecache(target, banned_turfs) || !(target_area.type in allowed_areas))
		to_chat(user, span_warning("You can only use this out in an open area"))
		return
	if(user in viewers(user.client.view, get_turf(target)))
		var/turf/open/T = get_turf(target)
		if(!istype(T))
			return
		if(!istype(T, turf_type))
			var/obj/effect/temp_visual/lavastaff/L = new /obj/effect/temp_visual/lavastaff(T)
			L.alpha = 0
			animate(L, alpha = 255, time = create_delay)
			user.visible_message(span_danger("[user] points [src] at [T]!"))
			timer = world.time + create_delay + 1
			if(do_after(user, create_delay, target = T))
				var/old_name = T.name
				if(T.TerraformTurf(turf_type, flags = CHANGETURF_INHERIT_AIR))
					user.visible_message(span_danger("[user] turns \the [old_name] into [transform_string]!"))
					message_admins("[ADMIN_LOOKUPFLW(user)] fired the lava staff at [ADMIN_VERBOSEJMP(T)]")
					log_game("[key_name(user)] fired the lava staff at [AREACOORD(T)].")
					timer = world.time + create_cooldown
					playsound(T,'sound/magic/fireball.ogg', 200, 1)
			else
				timer = world.time
			qdel(L)
		else
			var/old_name = T.name
			if(T.TerraformTurf(reset_turf_type, flags = CHANGETURF_INHERIT_AIR))
				user.visible_message(span_danger("[user] turns \the [old_name] into [reset_string]!"))
				timer = world.time + reset_cooldown
				playsound(T,'sound/magic/fireball.ogg', 200, 1)

/obj/effect/temp_visual/lavastaff
	icon_state = "lavastaff_warn"
	duration = 50

//Bubblegum
/obj/structure/closet/crate/necropolis/bubblegum
	name = "bubblegum chest"

/obj/structure/closet/crate/necropolis/bubblegum/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		new /obj/item/clothing/suit/hooded/hostile_environment(src)
		new /obj/item/crusher_trophy/demon_claws(src)

/obj/item/mayhem
	name = "mayhem in a bottle"
	desc = "A magically infused bottle of blood, the scent of which will drive anyone nearby into a murderous frenzy."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "vial"
	custom_price = 40000
	max_demand = 2

/obj/item/mayhem/attack_self(mob/user)
	for(var/mob/living/carbon/human/H in range(7,user))
		var/obj/effect/mine/pickup/bloodbath/B = new(H)
		INVOKE_ASYNC(B, TYPE_PROC_REF(/obj/effect/mine/pickup/bloodbath, mineEffect), H)
	to_chat(user, span_notice("You shatter the bottle!"))
	playsound(user.loc, 'sound/effects/glassbr1.ogg', 100, 1)
	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(user)] has activated a bottle of mayhem!"))
	log_combat(user, null, "activated a bottle of mayhem", src)
	qdel(src)

/obj/item/blood_contract
	name = "blood contract"
	icon = 'icons/obj/wizard.dmi'
	icon_state = "scroll2"
	color = "#FF0000"
	desc = "Mark your target for death."
	custom_price = 40000
	max_demand = 2
	var/used = FALSE

/obj/item/blood_contract/attack_self(mob/user)
	if(used)
		return
	used = TRUE

	var/list/da_list = list()
	for(var/I in GLOB.alive_mob_list & GLOB.player_list)
		var/mob/living/L = I
		da_list[L.real_name] = L

	var/choice = input(user,"Who do you want dead?","Choose Your Victim") as null|anything in sort_names(da_list)

	choice = da_list[choice]

	if(!choice)
		used = FALSE
		return
	if(!(isliving(choice)))
		to_chat(user, "[choice] is already dead!")
		used = FALSE
		return
	if(choice == user)
		to_chat(user, "You feel like writing your own name into a cursed death warrant would be unwise.")
		used = FALSE
		return

	var/mob/living/L = choice

	message_admins(span_adminnotice("[ADMIN_LOOKUPFLW(L)] has been marked for death by [ADMIN_LOOKUPFLW(user)]!"))

	var/datum/antagonist/blood_contract/A = new
	L.mind.add_antag_datum(A)

	log_combat(user, L, "took out a blood contract on", src)
	qdel(src)

//Colossus
/obj/structure/closet/crate/necropolis/colossus
	name = "colossus chest"

/obj/structure/closet/crate/necropolis/colossus/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		new /obj/item/organ/vocal_cords/colossus(src)
		new /obj/item/crusher_trophy/blaster_tubes(src)

//Hierophant

/obj/structure/closet/crate/necropolis/hierophant
	name = "hierophant chest"

/obj/structure/closet/crate/necropolis/hierophant/try_spawn_loot(datum/source, obj/item/item, mob/user, params) ///proc that handles key checking and generating loot
	if(..())
		new /obj/item/hierophant_club(src)
		new /obj/item/crusher_trophy/vortex_talisman(src)

/obj/item/hierophant_club
	name = "hierophant club"
	desc = "The strange technology of this large club allows various nigh-magical feats. It used to beat you, but now you can set the beat."
	icon_state = "hierophant_club_ready_beacon"
	inhand_icon_state = "hierophant_club_ready_beacon"
	icon = 'icons/obj/lavaland/artefacts.dmi'
	lefthand_file = 'icons/mob/inhands/64x64_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/64x64_righthand.dmi'
	inhand_x_dimension = 64
	inhand_y_dimension = 64
	slot_flags = ITEM_SLOT_BACK
	w_class = WEIGHT_CLASS_BULKY
	force = 5 //Melee attacks also invoke a 15 burn damage AoE, for a total of 20 damage
	attack_verb_continuous = list("clubs", "beats", "pummels")
	attack_verb_simple = list("club", "beat", "pummel")
	hitsound = 'sound/weapons/sonic_jackhammer.ogg'
	actions_types = list(/datum/action/item_action/vortex_recall, /datum/action/item_action/toggle_unfriendly_fire)
	custom_price = 40000
	max_demand = 2
	var/power = 15 //Damage of the magic tiles
	var/cooldown_time = 20 //how long the cooldown between non-melee ranged attacks is
	var/chaser_cooldown = 81 //how long the cooldown between firing chasers at mobs is
	var/chaser_timer = 0 //what our current chaser cooldown is
	var/chaser_speed = 0.8 //how fast our chasers are
	var/timer = 0 //what our current cooldown is
	var/blast_range = 13 //how long the cardinal blast's walls are
	var/obj/effect/hierophant/beacon //the associated beacon we teleport to
	var/teleporting = FALSE //if we ARE teleporting
	var/friendly_fire_check = FALSE //if the blasts we make will consider our faction against the faction of hit targets

/obj/item/hierophant_club/examine(mob/user)
	. = ..()
	. += "[span_hierophantwarning("The[beacon ? " beacon is not currently":"re is a beacon"] attached.")]"

/obj/item/hierophant_club/suicide_act(mob/living/user)
	say("Xverwpsgexmrk...", forced = "hierophant club suicide")
	user.visible_message(span_suicide("[user] holds [src] into the air! It looks like [user.p_theyre()] trying to commit suicide!"))
	new/obj/effect/temp_visual/hierophant/telegraph(get_turf(user))
	playsound(user,'sound/machines/airlockopen.ogg', 75, TRUE)
	user.visible_message("[span_hierophantwarning("[user] fades out, leaving [user.p_their()] belongings behind!")]")
	for(var/obj/item/I in user)
		if(I != src)
			user.dropItemToGround(I)
	for(var/turf/T as() in RANGE_TURFS(1, user))
		var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, TRUE)
		B.damage = 0
	user.dropItemToGround(src) //Drop us last, so it goes on top of their stuff
	qdel(user)

/obj/item/hierophant_club/afterattack(atom/target, mob/user, proximity_flag, click_parameters)
	. = ..()
	if(!is_mining_level(user.z))
		power = 5
		to_chat(user, span_warning("[name] is too far from the source of its power!"))
	else
		power = 15
	if(HAS_TRAIT_FROM(user, TRAIT_NOGUNS, SLEEPING_CARP_TRAIT))
		to_chat(user, span_warning("To use this weapon would bring dishonor to the clan."))
		return
	var/turf/T = get_turf(target)
	if(!T || timer > world.time)
		return
	calculate_anger_mod(user)
	timer = world.time + CLICK_CD_MELEE //by default, melee attacks only cause melee blasts, and have an accordingly short cooldown
	if(proximity_flag)
		INVOKE_ASYNC(src, PROC_REF(aoe_burst), T, user, power)
		log_combat(user, target, "fired 3x3 blast at", src)
	else
		if(ismineralturf(target) && get_dist(user, target) < 6) //target is minerals, we can hit it(even if we can't see it)
			INVOKE_ASYNC(src, PROC_REF(cardinal_blasts), T, user)
			timer = world.time + cooldown_time
		else if(user in viewers(5, get_turf(target))) //if the target is in view, hit it
			timer = world.time + cooldown_time
			if(isliving(target) && chaser_timer <= world.time) //living and chasers off cooldown? fire one!
				chaser_timer = world.time + chaser_cooldown
				var/obj/effect/temp_visual/hierophant/chaser/C = new(get_turf(target), user, target, chaser_speed, friendly_fire_check)
				C.damage = power
				C.monster_damage_boost = FALSE
				log_combat(user, target, "fired a chaser at", src)
			INVOKE_ASYNC(src, PROC_REF(cardinal_blasts), T, user)
			log_combat(user, target, "fired cardinal blast at", src)
		else
			to_chat(user, span_warning("That target is out of range!") )
			timer = world.time
	INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))

/obj/item/hierophant_club/proc/calculate_anger_mod(mob/user) //we get stronger as the user loses health
	chaser_cooldown = initial(chaser_cooldown)
	cooldown_time = initial(cooldown_time)
	chaser_speed = initial(chaser_speed)
	blast_range = initial(blast_range)
	if(isliving(user))
		var/mob/living/L = user
		var/health_percent = L.health / L.maxHealth
		chaser_cooldown += round(health_percent * 20) //two tenths of a second for each missing 10% of health
		cooldown_time += round(health_percent * 10) //one tenth of a second for each missing 10% of health
		chaser_speed = max(chaser_speed + health_percent, 0.5) //one tenth of a second faster for each missing 10% of health
		blast_range -= round(health_percent * 10) //one additional range for each missing 10% of health

/obj/item/hierophant_club/update_icon()
	icon_state = "hierophant_club[timer <= world.time ? "_ready":""][(beacon && !QDELETED(beacon)) ? "":"_beacon"]"
	inhand_icon_state = icon_state
	if(ismob(loc))
		var/mob/M = loc
		M.update_held_items()
		M.update_worn_back()

/obj/item/hierophant_club/proc/prepare_icon_update()
	update_icon()
	sleep(timer - world.time)
	update_icon()

/obj/item/hierophant_club/ui_action_click(mob/user, action)
	if(istype(action, /datum/action/item_action/toggle_unfriendly_fire)) //toggle friendly fire...
		var/datum/action/toggle = action
		friendly_fire_check = !friendly_fire_check
		toggle.update_buttons()
		to_chat(user, span_warning("You toggle friendly fire [friendly_fire_check ? "off":"on"]!"))
		return
	if(timer > world.time)
		return
	if(!user.is_holding(src)) //you need to hold the staff to teleport
		to_chat(user, span_warning("You need to hold the club in your hands to [beacon ? "teleport with it":"detach the beacon"]!"))
		return
	if(!beacon || QDELETED(beacon))
		if(isturf(user.loc))
			user.visible_message("[span_hierophantwarning("[user] starts fiddling with [src]'s pommel...")]", \
			span_notice("You start detaching the hierophant beacon..."))
			timer = world.time + 51
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			if(do_after(user, 50, target = user) && !beacon)
				var/turf/T = get_turf(user)
				playsound(T,'sound/magic/blind.ogg', 200, 1, -4)
				new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
				beacon = new/obj/effect/hierophant(T)
				user.update_action_buttons_icon()
				user.visible_message("[span_hierophantwarning("[user] places a strange machine beneath [user.p_their()] feet!")]", \
				"[span_hierophant("You detach the hierophant beacon, allowing you to teleport yourself and any allies to it at any time!")]\n\
				[span_notice("You can remove the beacon to place it again by striking it with the club.")]")
			else
				timer = world.time
				INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
		else
			to_chat(user, span_warning("You need to be on solid ground to detach the beacon!"))
		return
	if(get_dist(user, beacon) <= 2) //beacon too close abort
		to_chat(user, span_warning("You are too close to the beacon to teleport to it!"))
		return
	var/turf/beacon_turf = get_turf(beacon)
	if(beacon_turf?.is_blocked_turf(TRUE))
		to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
		return
	if(!isturf(user.loc))
		to_chat(user, span_warning("You don't have enough space to teleport from here!"))
		return
	teleporting = TRUE //start channel
	user.update_action_buttons_icon()
	user.visible_message("[span_hierophantwarning("[user] starts to glow faintly...")]")
	timer = world.time + 50
	INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
	beacon.icon_state = "hierophant_tele_on"
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE1 = new /obj/effect/temp_visual/hierophant/telegraph/edge(user.loc)
	var/obj/effect/temp_visual/hierophant/telegraph/edge/TE2 = new /obj/effect/temp_visual/hierophant/telegraph/edge(beacon.loc)
	if(do_after(user, 40, target = user) && user && beacon)
		var/turf/T = get_turf(beacon)
		var/turf/source = get_turf(user)
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			beacon.icon_state = "hierophant_tele_off"
			return
		new /obj/effect/temp_visual/hierophant/telegraph(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph(source, user)
		playsound(T,'sound/magic/wand_teleport.ogg', 200, 1)
		playsound(source,'sound/machines/airlockopen.ogg', 200, 1)
		if(!do_after(user, 3, target = user) || !user || !beacon || QDELETED(beacon)) //no walking away shitlord
			teleporting = FALSE
			if(user)
				user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			if(beacon)
				beacon.icon_state = "hierophant_tele_off"
			return
		if(T.is_blocked_turf(TRUE))
			teleporting = FALSE
			to_chat(user, span_warning("The beacon is blocked by something, preventing teleportation!"))
			user.update_action_buttons_icon()
			timer = world.time
			INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
			beacon.icon_state = "hierophant_tele_off"
			return
		user.log_message("teleported self from [AREACOORD(source)] to [beacon]", LOG_GAME)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(T, user)
		new /obj/effect/temp_visual/hierophant/telegraph/teleport(source, user)
		for(var/turf/t as() in RANGE_TURFS(1, T))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //blasts produced will not hurt allies
			B.damage = 30
		for(var/turf/t as() in RANGE_TURFS(1, source))
			var/obj/effect/temp_visual/hierophant/blast/B = new /obj/effect/temp_visual/hierophant/blast(t, user, TRUE) //but absolutely will hurt enemies
			B.damage = 30
		for(var/mob/living/L in hearers(1, source))
			INVOKE_ASYNC(src, PROC_REF(teleport_mob), source, L, T, user) //regardless, take all mobs near us along
		sleep(6) //at this point the blasts detonate
		if(beacon)
			beacon.icon_state = "hierophant_tele_off"
	else
		qdel(TE1)
		qdel(TE2)
		timer = world.time
		INVOKE_ASYNC(src, PROC_REF(prepare_icon_update))
	if(beacon)
		beacon.icon_state = "hierophant_tele_off"
	teleporting = FALSE
	if(user)
		user.update_action_buttons_icon()

/obj/item/hierophant_club/proc/teleport_mob(turf/source, mob/M, turf/target, mob/user)
	var/turf/turf_to_teleport_to = get_step(target, get_dir(source, M)) //get position relative to caster
	if(!turf_to_teleport_to || turf_to_teleport_to.is_blocked_turf(TRUE))
		return
	animate(M, alpha = 0, time = 2, easing = EASE_OUT) //fade out
	sleep(1)
	if(!M)
		return
	M.visible_message("[span_hierophantwarning("[M] fades out!")]")
	sleep(2)
	if(!M)
		return
	do_teleport(M, turf_to_teleport_to, no_effects = TRUE, channel = TELEPORT_CHANNEL_MAGIC_SELF)
	sleep(1)
	if(!M)
		return
	animate(M, alpha = 255, time = 2, easing = EASE_IN) //fade IN
	sleep(1)
	if(!M)
		return
	M.visible_message("[span_hierophantwarning("[M] fades in!")]")
	if(user != M)
		log_combat(user, M, "teleported", null, "from [AREACOORD(source)]")

/obj/item/hierophant_club/proc/cardinal_blasts(turf/T, mob/living/user) //fire cardinal cross blasts with a delay
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph/cardinal(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	var/obj/effect/temp_visual/hierophant/blast/B = new(T, user, friendly_fire_check)
	B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
	B.monster_damage_boost = FALSE
	for(var/d in GLOB.cardinals)
		INVOKE_ASYNC(src, PROC_REF(blast_wall), T, d, user)

/obj/item/hierophant_club/proc/blast_wall(turf/T, dir, mob/living/user) //make a wall of blasts blast_range tiles long
	if(!T)
		return
	var/range = blast_range
	var/turf/previousturf = T
	var/turf/J = get_step(previousturf, dir)
	for(var/i in 1 to range)
		if(!J)
			return
		var/obj/effect/temp_visual/hierophant/blast/B = new(J, user, friendly_fire_check)
		B.damage = HIEROPHANT_CLUB_CARDINAL_DAMAGE
		B.monster_damage_boost = FALSE
		previousturf = J
		J = get_step(previousturf, dir)

/obj/item/hierophant_club/proc/aoe_burst(turf/T, mob/living/user, power = 15) //make a 3x3 blast around a target
	if(!T)
		return
	new /obj/effect/temp_visual/hierophant/telegraph(T, user)
	playsound(T,'sound/effects/bin_close.ogg', 200, 1)
	sleep(2)
	for(var/t in RANGE_TURFS(1, T))
		var/obj/effect/temp_visual/hierophant/blast/B = new(t, user, friendly_fire_check)
		B.damage = power

/obj/structure/closet/crate/necropolis/tendril/puzzle
	name = "puzzling chest"

/obj/item/skeleton_key
	name = "skeleton key"
	desc = "An artifact usually found in the hands of the natives of lavaland, which NT now holds a monopoly on."
	icon = 'icons/obj/lavaland/artefacts.dmi'
	icon_state = "skeleton_key"
	w_class = WEIGHT_CLASS_SMALL

#undef HIEROPHANT_CLUB_CARDINAL_DAMAGE
