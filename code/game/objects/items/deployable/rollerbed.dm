/obj/item/rollerbed
	name = "roller bed"
	desc = "A collapsed roller bed that can be carried around."
	icon = 'icons/obj/beds_chairs/rollerbed.dmi'
	icon_state = "folded"
	w_class = WEIGHT_CLASS_NORMAL // No more excuses, stop getting blood everywhere

/obj/item/rollerbed/ComponentInitialize()
	. = ..()
	DeployableInitialize()

/obj/item/rollerbed/proc/DeployableInitialize()
	AddComponent(/datum/component/deployable, /obj/structure/bed/roller, ignores_mob_density = TRUE)

/obj/item/rollerbed/robo //ROLLER ROBO DA!
	name = "roller bed dock"
	desc = "A collapsed roller bed that can be ejected for emergency use. Must be collected or replaced after use."

/obj/item/rollerbed/robo/DeployableInitialize()
	AddComponent(/datum/component/deployable, /obj/structure/bed/roller, ignores_mob_density = TRUE, consumed = FALSE, loaded = TRUE, empty_icon = "folded_unloaded", reload_type = /obj/structure/bed/roller)

/obj/item/rollerbed/robo/update_icon()
	icon_state = "folded"
	return ..()
