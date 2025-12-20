//These objects are used in the cardinal sin-themed ruins (i.e. Gluttony, Pride...)

/obj/structure/cursed_slot_machine //Greed's slot machine: Used in the Greed ruin. Deals clone damage on each use, with a successful use giving a d20 of fate.
	name = "greed's slot machine"
	desc = "High stakes, high rewards."
	icon = 'icons/obj/economy.dmi'
	icon_state = "slots1"
	anchored = TRUE
	density = TRUE
	var/win_prob = 5

/obj/structure/cursed_slot_machine/interact(mob/living/carbon/human/user)
	if(!istype(user))
		return
	if(obj_flags & IN_USE)
		return
	if(isipc(user))
		user.visible_message(span_warning(" As [user] tries to pull \the [src]'s lever, the machine seems to hesitate a bit."), span_warning("You feel as if you are trying to put at stake something you don't even have...\ You suddenly feel your mind... Suboptimal?"))
		user.adjustOrganLoss(ORGAN_SLOT_BRAIN, 10)
	else
		user.adjustCloneLoss(20)
	obj_flags |= IN_USE

	if(user.stat)
		to_chat(user, span_userdanger("No... just one more try..."))
		user.investigate_log("has been gibbed by [src].", INVESTIGATE_DEATHS)
		user.gib()
	else
		user.visible_message(span_warning("[user] pulls [src]'s lever with a glint in [user.p_their()] eyes!"), span_warning("You feel a draining as you pull the lever, but you \
		know it'll be worth it."))
	icon_state = "slots2"
	playsound(src, 'sound/lavaland/cursed_slot_machine.ogg', 50, 0)
	addtimer(CALLBACK(src, PROC_REF(determine_victor), user), 50)

/obj/structure/cursed_slot_machine/proc/determine_victor(mob/living/user)
	icon_state = "slots1"
	obj_flags &= ~IN_USE
	if(prob(win_prob))
		playsound(src, 'sound/lavaland/cursed_slot_machine_jackpot.ogg', 50, 0)
		new/obj/structure/cursed_money(get_turf(src))
		if(user)
			to_chat(user, span_boldwarning("You've hit jackpot. Laughter echoes around you as your reward appears in the machine's place."))
		qdel(src)
	else
		if(user)
			to_chat(user, span_boldwarning("Fucking machine! Must be rigged. Still... one more try couldn't hurt, right?"))


/obj/structure/cursed_money
	name = "bag of money"
	desc = "RICH! YES! YOU KNEW IT WAS WORTH IT! YOU'RE RICH! RICH! RICH!"
	icon = 'icons/obj/storage/storage.dmi'
	icon_state = "moneybag"
	anchored = FALSE
	density = TRUE

/obj/structure/cursed_money/Initialize(mapload)
	. = ..()
	addtimer(CALLBACK(src, PROC_REF(collapse)), 600)

/obj/structure/cursed_money/proc/collapse()
	visible_message(span_warning("[src] falls in on itself, canvas rotting away and contents vanishing."))
	qdel(src)

/obj/structure/cursed_money/attack_hand(mob/living/user)
	. = ..()
	if(.)
		return
	user.visible_message(span_warning("[user] opens the bag and and removes a die. The bag then vanishes."), "[span_boldwarning("You open the bag...!")]\n[span_danger("And see a bag full of dice. Confused, you take one... and the bag vanishes.")]")
	var/turf/T = get_turf(user)
	var/obj/item/dice/d20/fate/one_use/critical_fail = new(T)
	user.put_in_hands(critical_fail)
	qdel(src)

/obj/effect/gluttony //Gluttony's wall: Used in the Gluttony ruin. Only lets the overweight through.
	name = "gluttony's wall"
	desc = "Only those who truly indulge may pass."
	anchored = TRUE
	density = TRUE
	icon_state = "blob"
	icon = 'icons/mob/blob.dmi'
	color = rgb(145, 150, 0)

/obj/effect/gluttony/CanAllowThrough(atom/movable/mover, border_dir)//So bullets will fly over and stuff.
	. = ..()
	if(ishuman(mover))
		var/mob/living/carbon/human/H = mover
		if(H.nutrition >= NUTRITION_LEVEL_FAT)
			H.visible_message(span_warning("[H] pushes through [src]!"), span_notice("You've seen and eaten worse than this."))
			return TRUE
		else
			to_chat(H, span_warning("You're repulsed by even looking at [src]. Only a pig could force themselves to go through it."))
	if(istype(mover, /mob/living/simple_animal/hostile/morph))
		return TRUE

/obj/structure/mirror/magic/pride //Pride's mirror: Used in the Pride ruin.
	name = "pride's mirror"
	desc = "Pride cometh before the..."
	icon_state = "magic_mirror"

/obj/structure/mirror/magic/pride/New()
	for(var/speciestype in subtypesof(/datum/species))
		var/datum/species/S = speciestype
		if(initial(S.changesource_flags) & MIRROR_PRIDE)
			choosable_races += initial(S.id)
	..()

/obj/structure/mirror/magic/pride/curse(mob/user)
	user.visible_message(span_danger("<B>The ground splits beneath [user] as [user.p_their()] hand leaves the mirror!</B>"), \
	span_notice("Perfect. Much better! Now <i>nobody</i> will be able to resist yo-"))

	var/turf/T = get_turf(user)
	var/list/levels = SSmapping.levels_by_trait(ZTRAIT_DYNAMIC_LEVEL)
	var/turf/dest
	if (levels.len)
		dest = locate(T.x, T.y, pick(levels))

	T.ChangeTurf(/turf/open/chasm, flags = CHANGETURF_INHERIT_AIR)
	var/turf/open/chasm/C = T
	C.set_target(dest)
	C.drop(user)

//can't be bothered to do sloth right now, will make later

/obj/item/knife/envy //Envy's knife: Found in the Envy ruin. Attackers take on the appearance of whoever they strike.
	name = "envy's knife"
	desc = "Their success will be yours."
	icon = 'icons/obj/wizard.dmi'
	icon_state = "render"
	inhand_icon_state = "knife"
	lefthand_file = 'icons/mob/inhands/equipment/kitchen_lefthand.dmi'
	righthand_file = 'icons/mob/inhands/equipment/kitchen_righthand.dmi'
	force = 18
	throwforce = 10
	w_class = WEIGHT_CLASS_NORMAL
	hitsound = 'sound/weapons/bladeslice.ogg'
	custom_price = 10000
	max_demand = 10

/obj/item/knife/envy/afterattack(atom/movable/AM, mob/living/carbon/human/user, proximity)
	. = ..()
	if(!proximity)
		return
	if(!istype(user))
		return
	if(ishuman(AM))
		var/mob/living/carbon/human/H = AM
		if(user.real_name != H.dna.real_name)
			user.real_name = H.dna.real_name
			H.dna.transfer_identity(user, transfer_SE=1)
			user.updateappearance(mutcolor_update=1)
			user.domutcheck()
			user.visible_message(span_warning("[user]'s appearance shifts into [H]'s!"), \
			span_boldannounce("[H.p_They()] think[H.p_s()] [H.p_theyre()] <i>sooo</i> much better than you. Not anymore, [H.p_they()] won't."))
