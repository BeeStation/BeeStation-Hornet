#define ANTAG_TOKENS_MAXIMUM 255
#define ANTAG_TOKENS_MINIMUM 0

/client/proc/cmd_admin_mod_antag_tokens(client/C in GLOB.clients, var/operation)
	set category = "Adminbus"
	set name = "Modify Antagonist Tokens"

	if(!check_rights(R_ADMIN))
		return

	var/msg = ""
	var/log_text = ""

	if(operation == "zero")
		log_text = "Set to 0"
		C.set_antag_token_count(0)
	else
		var/prompt = "Please enter the amount of tokens to [operation]:"

		if(operation == "set")
			prompt = "Please enter the new token amount:"

		msg = input("Message:", prompt) as num|null

		if (!msg)
			return

		if(operation == "set")
			log_text = "Set to [num2text(msg)]"
			C.set_antag_token_count(max(ANTAG_TOKENS_MINIMUM, min(msg, ANTAG_TOKENS_MAXIMUM)))
		else if(operation == "add")
			log_text = "Added [num2text(msg)]"
			C.inc_antag_token_count(msg)
		else if(operation == "subtract")
			log_text = "Subtracted [num2text(msg)]"
			C.inc_antag_token_count(-msg)
		else
			to_chat(src, "Invalid operation for antag token modification: [operation] by user [key_name(usr)]")
			return


	log_admin("[key_name(usr)]: Modified [key_name(C)]'s antagonist tokens [log_text]")
	message_admins("<span class='adminnotice'>[key_name_admin(usr)]: Modified [key_name(C)]'s antagonist tokens ([log_text])</span>")
	SSblackbox.record_feedback("tally", "admin_verb", 1, "Modify Antagonist Tokens") //If you are copy-pasting this, ensure the 2nd parameter is unique to the new proc!
