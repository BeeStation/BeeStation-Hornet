/obj/item/stack/nanopaste
	name = "nanopaste"
	singular_name = "nanite swarm"
	desc = "A tube of paste containing swarms of repair nanites. Very effective in repairing robotic machinery."
	icon = 'icons/obj/nanopaste.dmi'
	icon_state = "tube-5"
	amount = 10
	toolspeed = 1

/obj/item/stack/nanopaste/update_icon()
	var/amount = round(get_amount() / 2)
	if(amount >= 5)
		icon_state = "tube-5"
	else if(amount > 0)
		icon_state = "tube-[amount]"
	else
		icon_state = "tube-empty"

/obj/item/stack/nanopaste/attack(mob/living/M as mob, mob/user as mob)
	if(!istype(M) || !istype(user))
		return 0
	if(istype(M,/mob/living/silicon/robot))	//Repairing cyborgs

		var/mob/living/silicon/robot/R = M
		if(R.getBruteLoss() || R.getFireLoss() )
			if(do_after(user, 50, target = R))
				R.adjustBruteLoss(-15)
				R.adjustFireLoss(-15)
				use(1)

				user.visible_message("<span class='notice'>[user] applies some [src] at [R]'s damaged areas.</span>",\
				"<span class='notice'>You apply some [src] at [R]'s damaged areas.</span>")
		else
			to_chat(user, "<span class='notice'>All [R]'s systems are nominal.</span>")

	if(istype(M,/mob/living/carbon/human))		//Repairing robolimbs
		var/mob/living/carbon/human/H = M
		var/obj/item/bodypart/BP = H.get_bodypart(user.zone_selected)

		if(BP && (BP.status & BODYPART_ROBOTIC))
			if(BP.get_damage())
				if(do_after(user, 30, target = H)) //Repairing bodyparts is slightly faster than repairing borgs
					user.visible_message("<span class='notice'>[user] applies some nanite paste to [user != M ? "[M]'s" : "their"] [BP.name] with [src].</span>",\
					"<span class='notice'>You apply some nanite paste to [user == M ? "your" : "[M]'s"] [BP.name].</span>")
					item_heal_robotic(M, user, 15, 15)
					use(1)
			else
				to_chat(user, "<span class='notice'>Nothing to fix here.</span>")
		else
			to_chat(user, "<span class='notice'>[src] won't work on that.</span>")

//Used as medical borg module
/obj/item/stack/nanopaste/cyborg
	materials = list()
	is_cyborg = 1
	cost = 750

/obj/item/stack/nanopaste/cyborg/attack(mob/living/M as mob, mob/user as mob)
	if(user == M)
		to_chat(user, "<span class='warning'>You can't use [src] on yourself!</span>")
		return
	..()
