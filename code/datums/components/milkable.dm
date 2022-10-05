// how cows and other simplemobs are able to be milked

/datum/component/milkable
	var/max_reagents
	var/min_reagents
	var/datum/reagent/reagent_generated
	var/datum/callback/on_milked
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass)

/datum/component/milkable/Initialize(_max_reagents, _starting_amount, _reagent_used, _callback_milked, _allowed_containers)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE

	create_reagents(_max_reagents)
	reagents.add_reagent(_reagent_used, CLAMP(_starting_amount, 0, _max_reagents - 1))

	reagent_generated = _reagent_used
	on_milked = _callback_milked
	if(_allowed_containers)
		allowed_containers = _allowed_containers

	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/milk_animal)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/restart_gen)
	START_PROCESSING(SSdcs, src)

/datum/component/milkable/process(delta_time)
	if(parent.stat == DEAD)
		return PROCESS_KILL

	if(parent.stat != CONSCIOUS || prob(90))
		return

	reagents.add_reagent(_reagent_used, rand(5, 10) * delta_time)

/datum/component/milkable/proc/milk_animal(datum/source, obj/item/container, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(container) || !is_type_in_list(container, allowed_containers) || !container.reagents || parent.stat != CONSCIOUS)
		return

	if(container.reagents.total_volume >= container.volume)
		to_chat(user, "<span class='danger'>[container] is full.</span>")
		return
	var/transfered = reagents.trans_to(container, rand(5,10))
	if(transfered)
		user.visible_message("[user] milks [src] using \the [container].", "<span class='notice'>You milk [src] using \the [container].</span>")
	else
		to_chat(user, "<span class='danger'>The udder is dry. Wait a bit longer...</span>")

	if(on_milked)
		on_milked.Invoke()

/datum/component/milkable/proc/restart_gen()
	START_PROCESSING(SSdcs, src)
