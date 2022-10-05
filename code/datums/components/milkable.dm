// how cows and other simplemobs are able to be milked

/datum/component/milkable
	var/mob/producer
	var/obj/item/reagent_containers/intstorage
	var/max_reagents
	var/min_reagents
	var/datum/reagent/reagent_generated
	var/datum/callback/on_milked
	var/list/allowed_containers = list(/obj/item/reagent_containers/glass)

/datum/component/milkable/Initialize(_max_reagents, _starting_amount, _reagent_used, _callback_milked, _allowed_containers)
	if(!ismob(parent))
		return COMPONENT_INCOMPATIBLE
	producer = parent

	intstorage = new()
	intstorage.reagents.add_reagent(_reagent_used, CLAMP(_starting_amount, 0, _max_reagents - 1))

	reagent_generated = _reagent_used
	on_milked = _callback_milked
	if(_allowed_containers)
		allowed_containers = _allowed_containers


/datum/component/milkable/RegisterWithParent()
	RegisterSignal(parent, COMSIG_PARENT_ATTACKBY, .proc/milk_animal)
	RegisterSignal(parent, COMSIG_LIVING_REVIVE, .proc/restart_gen)
	START_PROCESSING(SSdcs, src)

/datum/component/milkable/UnregisterFromParent()
	UnregisterSignal(parent, list(
		COMSIG_PARENT_ATTACKBY,
		COMSIG_LIVING_REVIVE))
	STOP_PROCESSING(SSdcs, src)


/datum/component/milkable/process(delta_time)
	if(producer.stat == DEAD)
		return PROCESS_KILL

	if(producer.stat != CONSCIOUS || prob(90))
		return

	intstorage.reagents.add_reagent(reagent_generated, rand(5, 10) * delta_time)

/datum/component/milkable/proc/milk_animal(datum/source, obj/item/container, mob/living/user)
	SIGNAL_HANDLER

	if(!istype(container) || !is_type_in_list(container, allowed_containers) || !container.reagents || producer.stat != CONSCIOUS)
		return

	if(container.reagents.holder_full())
		to_chat(user, "<span class='danger'>[container] is full.</span>")
		return
	var/transfered = intstorage.reagents.trans_to(container, rand(5,10))
	if(transfered)
		user.visible_message("[user] milks [parent] using \the [container].", "<span class='notice'>You milk [parent] using \the [container].</span>")
	else
		to_chat(user, "<span class='danger'>The udder is dry. Wait a bit longer...</span>")

	if(on_milked)
		on_milked.Invoke()

/datum/component/milkable/proc/restart_gen()
	START_PROCESSING(SSdcs, src)
