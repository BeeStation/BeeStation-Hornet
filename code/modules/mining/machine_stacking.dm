/**********************Mineral stacking unit console**************************/

/obj/machinery/mineral/stacking_unit_console
	name = "stacking machine console"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "console"
	desc = "Controls a stacking machine... in theory."
	density = FALSE
	circuit = /obj/item/circuitboard/machine/stacking_unit_console
	var/obj/machinery/mineral/stacking_machine/machine
	var/machinedir = SOUTHEAST
	var/link_id

/obj/machinery/mineral/stacking_unit_console/Initialize(mapload)
	. = ..()
	if(link_id)
		return INITIALIZE_HINT_LATELOAD
	else
		machine = locate(/obj/machinery/mineral/stacking_machine, get_step(src, machinedir))
		if (machine)
			machine.console = src

// Only called if mappers set an ID
/obj/machinery/mineral/stacking_unit_console/LateInitialize()
	for(var/obj/machinery/mineral/stacking_machine/SM in GLOB.machines)
		if(SM.link_id == link_id)
			machine = SM
			machine.console = src
			return

/obj/machinery/mineral/stacking_unit_console/Destroy()
	if(machine)
		machine.console = null
		machine = null
	return ..()

/obj/machinery/mineral/stacking_unit_console/ui_interact(mob/user)
	. = ..()

	if(!machine)
		to_chat(user, "<span class='notice'>[src] is not linked to a machine!</span>")
		return

	var/obj/item/stack/sheet/s
	var/dat

	dat += "<b>Stacking unit console</b><br><br>"

	for(var/O in machine.stack_list)
		s = machine.stack_list[O]
		if(s.amount > 0)
			dat += "[capitalize(s.name)]: [s.amount] <A href='?src=[REF(src)];release=[s.type]'>Release</A><br>"

	dat += "<br>Stacking: [machine.stack_amt]<br><br>"

	user << browse(dat, "window=console_stacking_machine")

REGISTER_BUFFER_HANDLER(/obj/machinery/mineral/stacking_unit_console)

DEFINE_BUFFER_HANDLER(/obj/machinery/mineral/stacking_unit_console)
	if(istype(buffer, /obj/machinery/mineral/stacking_machine))
		var/obj/machinery/mineral/stacking_machine/stacking_machine = buffer
		stacking_machine.console = src
		machine = stacking_machine
		to_chat(user, "<span class='notice'>You link [src] to the console in [buffer_parent]'s buffer.</span>")
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You store linkage information in [buffer_parent]'s buffer.</span>")
	return COMPONENT_BUFFER_RECIEVED

/obj/machinery/mineral/stacking_unit_console/Topic(href, href_list)
	if(..())
		return
	usr.set_machine(src)
	src.add_fingerprint(usr)
	if(href_list["release"])
		if(!(text2path(href_list["release"]) in machine.stack_list))
			return //someone tried to spawn materials by spoofing hrefs
		var/obj/item/stack/sheet/inp = machine.stack_list[text2path(href_list["release"])]
		var/obj/item/stack/sheet/out = new inp.type(null, inp.amount)
		inp.amount = 0
		machine.unload_mineral(out)

	src.updateUsrDialog()
	return


/**********************Mineral stacking unit**************************/


/obj/machinery/mineral/stacking_machine
	name = "stacking machine"
	icon = 'icons/obj/machines/mining_machines.dmi'
	icon_state = "stacker"
	desc = "A machine that automatically stacks acquired materials. Controlled by a nearby console."
	density = TRUE
	circuit = /obj/item/circuitboard/machine/stacking_machine
	input_dir = EAST
	output_dir = WEST
	var/obj/machinery/mineral/stacking_unit_console/console
	var/stk_types = list()
	var/stk_amt   = list()
	var/stack_list[0] //Key: Type.  Value: Instance of type.
	var/stack_amt = 50 //amount to stack before releassing
	var/datum/component/remote_materials/materials
	var/force_connect = FALSE
	var/link_id = null

/obj/machinery/mineral/stacking_machine/Initialize(mapload)
	. = ..()
	proximity_monitor = new(src, 1)
	materials = AddComponent(/datum/component/remote_materials, "stacking", mapload, FALSE, mapload && force_connect)

/obj/machinery/mineral/stacking_machine/Destroy()
	if(console)
		console.machine = null
		console = null
	materials = null
	return ..()

/obj/machinery/mineral/stacking_machine/HasProximity(atom/movable/AM)
	if(QDELETED(AM))
		return
	if(istype(AM, /obj/item/stack/sheet) && AM.loc == get_step(src, input_dir))
		var/obj/effect/portal/P = locate() in AM.loc
		if(P)
			visible_message("<span class='warning'>[src] attempts to stack the portal!</span>")
			message_admins("Stacking machine exploded via [P.creator ? key_name(P.creator) : "UNKNOWN"]'s portal at [AREACOORD(src)]")
			log_game("Stacking machine exploded via [P.creator ? key_name(P.creator) : "UNKNOWN"]'s portal at [AREACOORD(src)]")
			explosion(src.loc, 0, 1, 2, 3)
			if(!QDELETED(src))
				qdel(src)
		else
			process_sheet(AM)

REGISTER_BUFFER_HANDLER(/obj/machinery/mineral/stacking_machine)

DEFINE_BUFFER_HANDLER(/obj/machinery/mineral/stacking_machine)
	if(istype(buffer, /obj/machinery/mineral/stacking_unit_console))
		console = buffer
		console.machine = src
		to_chat(user, "<span class='notice'>You link [src] to the console in [buffer_parent]'s buffer.</span>")
	else if (TRY_STORE_IN_BUFFER(buffer_parent, src))
		to_chat(user, "<span class='notice'>You store linkage information in [buffer_parent]'s buffer.</span>")
	return COMPONENT_BUFFER_RECIEVED

/obj/machinery/mineral/stacking_machine/proc/process_sheet(obj/item/stack/sheet/inp)
	if(QDELETED(inp))
		return
	var/key = inp.merge_type
	var/obj/item/stack/sheet/storage = stack_list[key]
	if(!storage) //It's the first of this sheet added
		stack_list[key] = storage = new inp.type(src, 0)
	storage.amount += inp.amount //Stack the sheets
	qdel(inp)

	if(materials.silo && !materials.on_hold()) //Dump the sheets to the silo
		var/matlist = storage.materials & materials.mat_container.materials
		if (length(matlist))
			var/inserted = materials.mat_container.insert_stack(storage)
			materials.silo_log(src, "collected", inserted, "sheets", matlist)
			if (QDELETED(storage))
				stack_list -= key
			return

	while(storage.amount >= stack_amt) //Get rid of excessive stackage
		var/obj/item/stack/sheet/out = new inp.type(null, stack_amt)
		unload_mineral(out)
		storage.amount -= stack_amt
