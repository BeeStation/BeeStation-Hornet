/**
 * # Server
 *
 * Immobile (but not dense) shells that can interact with
 * world.
 */
/obj/structure/server
	name = "server"
	icon = 'icons/obj/wiremod.dmi'
	desc = "A server shell able to host advanced circuits. Needs to be secured to work."
	icon_state = "setup_stationary"

	density = TRUE
	light_system = MOVABLE_LIGHT
	light_range = 0

/obj/structure/server/Initialize(mapload)
	. = ..()
	AddComponent(/datum/component/shell, null, SHELL_CAPACITY_VERY_LARGE, SHELL_FLAG_REQUIRE_ANCHOR|SHELL_FLAG_USB_PORT)

/obj/structure/server/wrench_act(mob/living/user, obj/item/tool)
	default_unfasten_wrench(user, tool)
	return TRUE
