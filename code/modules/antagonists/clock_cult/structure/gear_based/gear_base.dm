/obj/structure/destructible/clockwork/gear_base
	name = "gear base"
	desc = "A large cog lying on the floor at feet level."
	clockwork_desc = "A large cog lying on the floor at feet level."
	anchored = FALSE
	var/default_icon_state = "gear_base"

/obj/structure/destructible/clockwork/gear_base/Initialize()
	. = ..()
	update_icon_state()

/obj/structure/destructible/clockwork/gear_base/wrench_act(mob/living/user, obj/item/I)
	if(do_after(user, 40, target=src))
		anchored = !anchored
		update_icon_state()
		return TRUE
	else
		return ..()

/obj/structure/destructible/clockwork/gear_base/update_icon_state()
	. = ..()
	icon_state = default_icon_state
	if(!anchored)
		icon_state += "_unwrenched"
