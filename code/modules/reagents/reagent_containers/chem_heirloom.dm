//Chemist's heirloom
#define CHEM_H_VOL 100

/obj/item/reagent_containers/glass/chem_heirloom
	volume = CHEM_H_VOL //Set this to 0 in init. Doing otherwise breaks add_reagent
	spillable = FALSE
	reagent_flags = NONE
	icon = 'icons/obj/chemical.dmi'
	icon_state = "hard_locked_closed"
	item_state = "hard_locked_closed"
	var/locked = TRUE
	var/datum/reagent/rand_cont //Reagent of choice
	var/datum/callback/roundend_callback

/obj/item/reagent_containers/glass/chem_heirloom/Initialize(mapload, vol)
	..()
	volume = 0
	update_icon()
	roundend_callback = CALLBACK(src, PROC_REF(unlock))
	SSticker.OnRoundend(roundend_callback)
	update_name() //Negative.dm will call this again if it adds the heirloom component.

/obj/item/reagent_containers/glass/chem_heirloom/examine(mob/living/carbon/user)
	//Add, then remove, reagent contents for examine.
	. = ..() //This makes the text out of order, but it's hardly noticeable
	if(!locked)
		return
	var/smartguy
	if(user.can_see_reagents())
		smartguy = TRUE
	. += "It contains:\n100 units of [smartguy ? initial(rand_cont.name) : "various reagents"]" //Luckily science goggles say nothing if there's no reagents

/obj/item/reagent_containers/glass/chem_heirloom/update_name() //This has to be done after init, since the heirloom component is added after.
	. = ..()
	rand_cont = get_random_reagent_id(CHEMICAL_RNG_FUN)
	name ="hard locked bottle of [initial(rand_cont.name)]"
	var/datum/component/heirloom/H = GetComponent(/datum/component/heirloom)
	desc = H ? "[ishuman(H.owner) ? "The [H.family_name]" : "[H.owner.name]'s"] family's long-cherished wish is to open this bottle and get its chemical outside. Can you make that wish come true?" : "A hard locked bottle of [initial(rand_cont.name)]."

/obj/item/reagent_containers/glass/chem_heirloom/proc/unlock()
	if(!locked) //A little bird said this would be an issue if a goober-min tried to call this twice.
		return
	if(isliving(loc))
		var/mob/living/M = loc
		to_chat(M, "<span class='notice'>The [src] unlocks!</span>")
	desc = "An opened bottle of [initial(rand_cont.name)]."
	name = "bottle of [initial(rand_cont.name)]"
	volume = CHEM_H_VOL
	item_state = "hard_locked_open"
	icon_state = "hard_locked_open"
	locked = FALSE
	spillable = TRUE
	reagent_flags = OPENCONTAINER
	reagents.add_reagent(rand_cont, volume) //Add reagents

/obj/item/reagent_containers/glass/chem_heirloom/Destroy()
	. = ..()
	LAZYREMOVE(SSticker.round_end_events, roundend_callback)
	roundend_callback = null
