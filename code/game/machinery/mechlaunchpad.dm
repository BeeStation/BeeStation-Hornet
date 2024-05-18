/obj/machinery/mechpad
	name = "orbital mech pad"
	desc = "A slab of heavy plating designed to withstand orbital-drop impacts. Through some sort of advanced bluespace tech, this one seems able to send and receive Mechs. Requires linking to a console to function."
	icon = 'icons/obj/telescience.dmi'
	icon_state = "mechpad"
	circuit = /obj/item/circuitboard/machine/mechpad
	///ID of the console, used for linking up
	var/id = "roboticsmining"
	///Name of the mechpad in a mechpad console
	var/display_name = "Orbital Pad"
	///The console the pad is linked to
	var/obj/machinery/computer/mechpad/connected_console
	///List of consoles that can access the pad
	var/list/obj/machinery/computer/mechpad/consoles

/obj/machinery/mechpad/Initialize()
	. = ..()
	display_name = "Orbital Pad - [get_area_name(src)]"
	GLOB.mechpad_list += src

/obj/machinery/mechpad/Destroy()
	if(connected_console)
		connected_console.connected_mechpad = null
		connected_console = null
	for(var/obj/machinery/computer/mechpad/console in consoles)
		console.mechpads -= src
	return ..()

/obj/machinery/mechpad/screwdriver_act(mob/user, obj/item/tool)
	. = ..()
	if(!.)
		return default_deconstruction_screwdriver(user, "mechpad-o", "mechpad", tool)

/obj/machinery/medipen_refiller/crowbar_act(mob/user, obj/item/tool)
	..()
	default_deconstruction_crowbar(tool)
	return TRUE

REGISTER_BUFFER_HANDLER(/obj/machinery/mechpad)

DEFINE_BUFFER_HANDLER(/obj/machinery/mechpad)
	if(!panel_open)
		to_chat(user, "<span class='warning'>\The [src]'s panel must be open in order to add it to \the [buffer_parent]'s buffer.</span>")
		return
	if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You save the data in the [buffer_parent.name]'s buffer.</span>")
		balloon_alert(user, "saved in buffer")
		return COMPONENT_BUFFER_RECIEVED
	return NONE

/**
  * Spawns a special supply pod whitelisted to only accept mechs and have its drop off location be another mechpad
  * Arguments:
  * * where - where the supply pod will land after grabbing the mech
  */
/obj/machinery/mechpad/proc/launch(obj/machinery/mechpad/where)
	var/obj/structure/closet/supplypod/mechpod/pod = new()
	var/turf/target_turf = get_turf(where)
	pod.reverse_dropoff_coords = list(target_turf.x, target_turf.y, target_turf.z)
	new /obj/effect/pod_landingzone(get_turf(src), pod)

/obj/structure/closet/supplypod/mechpod
	style = STYLE_SEETHROUGH
	explosionSize = list(0,0,0,0)
	reversing = TRUE
	reverse_option_list = list("Mobs"=FALSE,"Objects"=FALSE,"Anchored"=FALSE,"Underfloor"=FALSE,"Wallmounted"=FALSE,"Floors"=FALSE,"Walls"=FALSE,"Mecha"=TRUE)
	delays = list(POD_TRANSIT = 0, POD_FALLING = 4, POD_OPENING = 0, POD_LEAVING = 0)
	effectOrgans = TRUE
	effectQuiet = TRUE
	leavingSound = 'sound/vehicles/rocketlaunch.ogg'
	close_sound = null
	pod_flags = FIRST_SOUNDS
