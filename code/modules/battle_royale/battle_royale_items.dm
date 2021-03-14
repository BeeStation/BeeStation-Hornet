//=====
// Heal
//=====

/obj/item/battle_royale_healing
	name = "bandage"
	icon = 'icons/obj/stack_objects.dmi'
	icon_state = "gauze"
	desc = "Looks handy around these parts."
	var/application_time = 30
	var/heal_amount = 15

/obj/item/battle_royale_healing/examine(mob/user)
	. = ..()
	. += "<span class='notice'>Left-Click your sprite to apply.</span>"

/obj/item/battle_royale_healing/attack(mob/living/M, mob/living/user)
	if(M == user && ishuman(user))
		user.visible_message("<span class='notice'>Starts using [src]...</span>")
		if(do_after(user, application_time, target=get_turf(user)))
			to_chat(user, "<span class='warning'>You use [src]!</span>")
			var/mob/living/carbon/human/H = user
			H.suppress_bloodloss(1800)
			H.heal_overall_damage(heal_amount, heal_amount)
			qdel(src)
		else
			to_chat(user, "<span class='warning'>You fail to use [src]!</span>")
			. = ..()
	else
		. = ..()

/obj/item/battle_royale_healing/medkit
	name = "Medical Kit"
	icon = 'icons/obj/surgery.dmi'
	icon_state = "legion_soul"
	application_time = 100
	heal_amount = 80
