/obj/item/sharpener
	name = "whetstone"
	icon = 'icons/obj/service/kitchen.dmi'
	icon_state = "sharpener"
	desc = "A block that makes things sharp."
	force = 5
	var/used = 0
	var/increment = 4
	var/max = 30
	var/prefix = "sharpened"


/obj/item/sharpener/attackby(obj/item/I, mob/user, params)
	if(used)
		to_chat(user, span_warning("The sharpening block is too worn to use again!"))
		return
	if(I.force >= max || I.throwforce >= max)//no esword sharpening
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return
	if(!I.is_sharp())
		to_chat(user, span_warning("You can only sharpen items that are already sharp, such as knives!"))
		return
	if(is_type_in_list(I, list(/obj/item/melee/energy, /obj/item/dualsaber))) //You can't sharpen the photons in energy meelee weapons
		to_chat(user, span_warning("You don't think \the [I] will be the thing getting modified if you use it on \the [src]!"))
		return

	var/signal_out = SEND_SIGNAL(I, COMSIG_ITEM_SHARPEN_ACT, increment, max)
	if(signal_out & COMPONENT_BLOCK_SHARPEN_MAXED)
		to_chat(user, span_warning("[I] is much too powerful to sharpen further!"))
		return
	if(signal_out & COMPONENT_BLOCK_SHARPEN_BLOCKED)
		to_chat(user, span_warning("[I] is not able to be sharpened right now!"))
		return
	if((signal_out & COMPONENT_BLOCK_SHARPEN_ALREADY) || (I.force > initial(I.force) && !signal_out))
		to_chat(user, span_warning("[I] has already been refined before. It cannot be sharpened further!"))
		return
	if(!(signal_out & COMPONENT_BLOCK_SHARPEN_APPLIED))
		I.force = clamp(I.force + increment, 0, max)
	user.visible_message(span_notice("[user] sharpens [I] with [src]!"), span_notice("You sharpen [I], making it much more deadly than before."))
	playsound(src, 'sound/items/unsheath.ogg', 25, 1)
	I.bleed_force *= 1.1
	I.throwforce = clamp(I.throwforce + increment, 0, max)
	I.name = "[prefix] [I.name]"
	name = "worn out [name]"
	desc = "[desc] At least, it used to."
	used = 1
	update_icon()

/obj/item/sharpener/super
	name = "super whetstone"
	desc = "A block that will make your weapon sharper than Einstein on adderall."
	increment = 200
	max = 200
	prefix = "super-sharpened"
