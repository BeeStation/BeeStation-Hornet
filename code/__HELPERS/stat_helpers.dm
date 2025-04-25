
#define GENERATE_STAT_TEXT(text_value) list(text=text_value,type=STAT_TEXT)

#define GENERATE_STAT_DIVIDER (list(type=STAT_DIVIDER))

#define GENERATE_STAT_BLANK (list(type=STAT_BLANK))

#define GENERATE_STAT_BUTTON(desired_text, desired_action) (list(\
		text = desired_text,\
		type = STAT_BUTTON,\
		action = desired_action,\
	))
