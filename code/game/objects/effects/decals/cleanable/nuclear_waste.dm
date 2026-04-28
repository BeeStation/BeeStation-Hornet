/obj/effect/decal/cleanable/nuclear_waste
	name = "plutonium sludge"
	desc = "A writhing pool of heavily irradiated, spent reactor fuel. You probably shouldn't step through this..."
	icon = 'icons/obj/machines/rbmkparts.dmi'
	icon_state = "nuclearwaste"
	alpha = 150
	light_color = LIGHT_COLOR_CYAN
	color = "#ff9eff"

/obj/effect/decal/cleanable/nuclear_waste/Initialize(mapload)
	. = ..()
	set_light(3)

	var/static/list/loc_connections = list(
		COMSIG_ATOM_ENTERED = PROC_REF(on_entered),
	)
	AddElement(/datum/element/connect_loc, loc_connections)

/obj/effect/decal/cleanable/nuclear_waste/ex_act(severity, target)
	if(severity != EXPLODE_DEVASTATE)
		return
	qdel(src)

/obj/effect/decal/cleanable/nuclear_waste/on_entered(datum/source, atom/movable/entered_mob)
	if(isliving(entered_mob))
		var/mob/living/L = entered_mob
		playsound(loc, 'sound/effects/gib_step.ogg', HAS_TRAIT(L, TRAIT_LIGHT_STEP) ? 20 : 50, 1)

	radiation_pulse(src, max_range = 1, threshold = RAD_EXTREME_INSULATION, intensity = 15)

/obj/effect/decal/cleanable/nuclear_waste/attackby(obj/item/tool, mob/user)
	if(tool.tool_behaviour == TOOL_SHOVEL)
		radiation_pulse(src, max_range = 1, threshold = RAD_EXTREME_INSULATION, intensity = 20)
		to_chat(user, span_notice("You start to clear [src]..."))
		if(tool.use_tool(src, user, 50, volume=100))
			to_chat(user, span_notice("You clear [src]. "))
			qdel(src)
			return
	. = ..()
