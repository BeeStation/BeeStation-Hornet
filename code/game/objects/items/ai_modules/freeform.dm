/* CONTAINS:
 * /obj/item/ai_module/core/freeformcore
 * /obj/item/ai_module/supplied/freeform
**/

/obj/item/ai_module/core/freeformcore
	name = "'Freeform' Core AI Module"
	laws = list("")

/obj/item/ai_module/core/freeformcore/attack_self(mob/user)
	var/new_law = tgui_input_text(user, "Enter a new core law for the AI.", "Freeform Law Entry", laws[1], max_length = CONFIG_GET(number/max_law_len), multiline = TRUE)
	if(!new_law || !user.is_holding(src))
		return
	if(CHAT_FILTER_CHECK(new_law))
		to_chat(user, span_warning("Error: Law contains invalid text."))
		return
	laws[1] = new_law
	..()

/obj/item/ai_module/core/freeformcore/transmit_laws(datum/ai_laws/law_datum, mob/sender, overflow)
	..()
	return laws[1]

/obj/item/ai_module/supplied/freeform
	name = "'Freeform' AI Module"
	lawpos = 15
	laws = list("")

/obj/item/ai_module/supplied/freeform/attack_self(mob/user)
	var/newpos = tgui_input_number(user, "Please enter the priority for your new law. Can only write to law sectors 15 and above.", "Law Priority ", lawpos, 50, 15)
	if(!newpos || !user.is_holding(src))
		return
	lawpos = newpos
	var/new_law = tgui_input_text(user, "Enter a new law for the AI.", "Freeform Law Entry", laws[1], max_length = CONFIG_GET(number/max_law_len), multiline = TRUE)
	if(!new_law || !user.is_holding(src))
		return
	if(CHAT_FILTER_CHECK(new_law))
		to_chat(user, span_warning("Error: Law contains invalid text."))
		return
	laws[1] = new_law
	..()

/obj/item/ai_module/supplied/freeform/transmit_laws(datum/ai_laws/law_datum, mob/sender, overflow)
	if(!overflow)
		..()
	else if(law_datum.owner)
		law_datum.owner.replace_random_law(laws[1], list(LAW_SUPPLIED), LAW_SUPPLIED)
	else
		law_datum.replace_random_law(laws[1], list(LAW_SUPPLIED), LAW_SUPPLIED)
	return laws[1]

/obj/item/ai_module/supplied/freeform/install(datum/ai_laws/law_datum, mob/user)
	if(laws[1] == "")
		to_chat(user, span_alert("No law detected on module, please create one."))
		return 0
	..()
