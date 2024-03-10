/obj/item/melee/nadefist
	name = "grenade gauntlet"
	desc = "A fist operated grenade launch platform, not often used with high explosives unless you are brave, bold and stupid"
	icon_state = "chemfist_0"
	item_state = "powerfist"
	lefthand_file = 'icons/mob/inhands/weapons/melee_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/weapons/melee_righthand.dmi'
	attack_verb = list("whacked", "fisted", "punched")
	force = 10
	throwforce = 8
	throw_range = 4
	w_class = WEIGHT_CLASS_NORMAL
	item_flags = ISWEAPON
	armor = list(MELEE = 0,  BULLET = 0, LASER = 0, ENERGY = 0, BOMB = 100, BIO = 0, RAD = 0, FIRE = 100, ACID = 100, STAMINA = 0)
	resistance_flags = FIRE_PROOF | ACID_PROOF
	var/obj/item/grenade/grenade = null //The grenade inside the fist
	var/strapped = FALSE //is the gauntlet strapped onto the user?

/obj/item/melee/nadefist/examine(mob/user)
	. = ..()
	if(!in_range(user, src))
		. += "<span class='notice'>You'll need to get closer to see any more.</span>"
		return
	if(grenade)
		. += "<span class='notice'>[icon2html(grenade, user)] It has \a [grenade] mounted onto it.</span>"
	if(strapped)
		. += "<span class ='notice'>Use inhand to remove the strap</span>"
	else
		. += "<span class ='notice'>Use inhand to put the strap on your arm</span>"

/obj/item/melee/nadefist/afterattack(atom/movable/AM, mob/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(grenade)
		grenade.forceMove(AM)
		grenade.prime(user)
		grenade = null
		icon_state = "chemfist_0"

/obj/item/melee/nadefist/attackby(obj/item/W, mob/user, params)
	if(istype(W, /obj/item/grenade))
		addNade(W, user)
	if(W.tool_behaviour == TOOL_SCREWDRIVER)
		removeNade(user)

/obj/item/melee/nadefist/proc/addNade(obj/item/grenade/newnade, mob/living/carbon/human/user)
	if(grenade)
		to_chat(user, "<span class='warning'>\The [src] already has a grenade.</span>")
		return
	if(!user.transferItemToLoc(newnade, src))
		return
	to_chat(user, "<span class='notice'>You attach \the [newnade] to \the [src].</span>")
	grenade = newnade
	icon_state = "chemfist_1"

/obj/item/melee/nadefist/proc/removeNade(mob/living/carbon/human/user)
	if(!grenade)
		to_chat(user, "<span class='notice'>\The [src] currently has no grenade attached to it.</span>")
		return
	to_chat(user, "<span class='notice'>You detach \the [grenade] from \the [src].</span>")
	playsound(loc, 'sound/items/screwdriver.ogg', 50, 1)
	grenade.forceMove(get_turf(user))
	user.put_in_hands(grenade)
	grenade = null
	icon_state = "chemfist_0"

/obj/item/melee/nadefist/attack_self(mob/user)
	. = ..()
	if(!strapped)
		ADD_TRAIT(src, TRAIT_NODROP, "strap")
		to_chat(user, "<span class='notice'>You strap \the [src] your arm.</span>")
	else
		REMOVE_TRAIT(src, TRAIT_NODROP, "strap")
		to_chat(user, "<span class='notice'>You remove the strap from \the [src].</span>")
	strapped = !strapped

