/// Helper that allows for atoms to recieve buffer information
#define REGISTER_BUFFER_HANDLER(TYPEPATH) ##TYPEPATH/ComponentInitialize() {\
		. = ..();\
		RegisterSignal(src, COMSIG_PARENT_RECIEVE_BUFFER, PROC_REF(_buffer_handler));\
	}\

#define DEFINE_BUFFER_HANDLER(TYPEPATH) ##TYPEPATH/proc/_buffer_handler(datum/source, mob/user, atom/buffer, obj/item/buffer_parent)

#define TRY_STORE_IN_BUFFER(target, buffer_item) (SEND_SIGNAL(target, COMSIG_ITEM_PUSH_BUFFER, buffer_item) & COMPONENT_BUFFER_STORE_SUCCESS)

#define STORE_IN_BUFFER(target, buffer_item) SEND_SIGNAL(target, COMSIG_ITEM_PUSH_BUFFER, buffer_item)

#define FLUSH_BUFFER(target) SEND_SIGNAL(target, COMSIG_ITEM_FLUSH_BUFFER)

/datum/component/buffer
	var/datum/target

/datum/component/buffer/Initialize(...)
	. = ..()

	RegisterSignal(parent, COMSIG_ITEM_PRE_ATTACK, PROC_REF(intercept_attack))
	RegisterSignal(parent, COMSIG_ITEM_ATTACK_SELF, PROC_REF(self_flush_buffer))
	RegisterSignal(parent, COMSIG_ITEM_FLUSH_BUFFER, PROC_REF(self_flush_buffer))
	RegisterSignal(parent, COMSIG_ITEM_PUSH_BUFFER, PROC_REF(populate_buffer))
	RegisterSignal(parent, COMSIG_PARENT_EXAMINE, PROC_REF(examine))

/datum/component/buffer/proc/intercept_attack(datum/source, atom/attack_target, mob/user, params)
	SIGNAL_HANDLER
	if ((SEND_SIGNAL(attack_target, COMSIG_PARENT_RECIEVE_BUFFER, user, target, parent) & COMPONENT_BUFFER_RECIEVED))
		return COMPONENT_NO_ATTACK
	return NONE

/datum/component/buffer/proc/examine(datum/source, mob/user, list/examine_list)
	SIGNAL_HANDLER
	if(target)
		examine_list += "<span class='notice'>Its buffer contains [target].</span>"

/datum/component/buffer/proc/self_flush_buffer(datum/source, mob/user)
	SIGNAL_HANDLER
	if (!target)
		return NONE
	flush_buffer()
	if (user)
		to_chat(user, "<span class='notice'>You flush the buffer of [source]!</span>")
	return COMPONENT_NO_INTERACT

/datum/component/buffer/proc/populate_buffer(datum/source, datum/buffer_entity)
	SIGNAL_HANDLER
	if (target)
		UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = buffer_entity
	if (target)
		RegisterSignal(target, COMSIG_PARENT_QDELETING, PROC_REF(flush_buffer))
		return COMPONENT_BUFFER_STORE_SUCCESS
	return NONE

/datum/component/buffer/proc/flush_buffer()
	SIGNAL_HANDLER
	if (!target)
		return
	UnregisterSignal(target, COMSIG_PARENT_QDELETING)
	target = null
