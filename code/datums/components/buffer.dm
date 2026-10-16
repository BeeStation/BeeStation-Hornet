/// Helper that allows for atoms to receive buffer information
#define REGISTER_BUFFER_HANDLER(TYPEPATH) ##TYPEPATH/Initialize(mapload) {\
		. = ..();\
		RegisterSignal(src, COMSIG_PARENT_RECEIVE_BUFFER, PROC_REF(_buffer_handler));\
	}\

#define DEFINE_BUFFER_HANDLER(TYPEPATH) ##TYPEPATH/proc/_buffer_handler(datum/source, mob/user, datum/buffer, obj/item/buffer_parent)

#define TRY_STORE_IN_BUFFER(target, buffer_item) (SEND_SIGNAL(target, COMSIG_ITEM_PUSH_BUFFER, buffer_item) & COMPONENT_BUFFER_STORE_SUCCESS)

#define STORE_IN_BUFFER(target, buffer_item) SEND_SIGNAL(target, COMSIG_ITEM_PUSH_BUFFER, buffer_item)

#define FLUSH_BUFFER(target) SEND_SIGNAL(target, COMSIG_ITEM_FLUSH_BUFFER)

#define GET_BUFFER(target) SEND_SIGNAL(target, COMSIG_ITEM_GET_BUFFER)

/datum/component/buffer
	/// The buffer contained by this component. Private to prevent people from manually assigning it.
	VAR_PRIVATE/datum/contained_buffer

/datum/component/buffer/Initialize(...)
	. = ..()
	RegisterSignal(parent, COMSIG_ITEM_INTERACTING_WITH_ATOM, PROC_REF(on_interaction))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(self_flush_buffer))
	RegisterSignal(parent, COMSIG_ITEM_FLUSH_BUFFER, PROC_REF(self_flush_buffer))
	RegisterSignal(parent, COMSIG_ITEM_PUSH_BUFFER, PROC_REF(populate_buffer))
	RegisterSignal(parent, COMSIG_ITEM_GET_BUFFER, PROC_REF(get_buffer))
	RegisterSignal(parent, COMSIG_ATOM_EXAMINE, PROC_REF(examine))

/datum/component/buffer/proc/on_interaction(datum/source, mob/living/user, atom/target, list/modifiers)
	SIGNAL_HANDLER
	if ((SEND_SIGNAL(target, COMSIG_PARENT_RECEIVE_BUFFER, user, contained_buffer, parent) & COMPONENT_BUFFER_RECEIVED))
		return ITEM_INTERACT_SUCCESS
	return NONE

/datum/component/buffer/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(contained_buffer)
		examine_list += span_notice("Its buffer contains [contained_buffer].")

/datum/component/buffer/proc/self_flush_buffer(datum/source, mob/user)
	SIGNAL_HANDLER
	if (!contained_buffer)
		return NONE
	flush_buffer()
	if (user)
		to_chat(user, span_notice("You flush the buffer of [source]!"))
	return COMPONENT_CANCEL_ATTACK_CHAIN

/datum/component/buffer/proc/populate_buffer(datum/source, datum/buffer_entity)
	SIGNAL_HANDLER
	if (contained_buffer)
		UnregisterSignal(contained_buffer, COMSIG_QDELETING)
	contained_buffer = buffer_entity
	if (contained_buffer)
		RegisterSignal(contained_buffer, COMSIG_QDELETING, PROC_REF(flush_buffer))
		return COMPONENT_BUFFER_STORE_SUCCESS
	return NONE

/datum/component/buffer/proc/flush_buffer()
	SIGNAL_HANDLER
	if (!contained_buffer)
		return
	UnregisterSignal(contained_buffer, COMSIG_QDELETING)
	contained_buffer = null

/datum/component/buffer/proc/get_buffer()
	SIGNAL_HANDLER
	return contained_buffer
