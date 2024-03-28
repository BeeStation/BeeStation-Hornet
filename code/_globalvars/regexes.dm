//These are a bunch of regex datums for use /((any|every|no|some|head|foot)where(wolf)?\sand\s)+(\.[\.\s]+\s?where\?)?/i
GLOBAL_DATUM_INIT(is_http_protocol, /regex, regex("^https?://"))

GLOBAL_DATUM_INIT(is_website, /regex, regex("http|www.|\[a-z0-9_-]+.(com|org|net|mil|edu)+", "i"))
GLOBAL_DATUM_INIT(is_email, /regex, regex("\[a-z0-9_-]+@\[a-z0-9_-]+.\[a-z0-9_-]+", "i"))
GLOBAL_DATUM_INIT(is_alphanumeric, /regex, regex("\[a-z0-9]+", "i"))
GLOBAL_DATUM_INIT(is_punctuation, /regex, regex("\[.!?]+", "i"))
GLOBAL_DATUM_INIT(is_color, /regex, regex("^#\[0-9a-fA-F]{6}$"))
GLOBAL_DATUM_INIT(is_color_nocrunch, /regex, regex("^\[0-9a-fA-F]{6}$"))

//All characters forbidden by filenames: ", \, \n, \t, /, ?, %, *, :, |, <, >, ..
GLOBAL_DATUM_INIT(filename_forbidden_chars, /regex, regex(@{""|[\\\n\t/?%*:|<>]|\.\."}, "g"))
GLOBAL_PROTECT(filename_forbidden_chars)

//Banning panel inputs
GLOBAL_DATUM_INIT(is_all_numbers, /regex, regex("^\[0-9]+$"))
GLOBAL_DATUM_INIT(is_ip_address, /regex, regex("^\[0-9]{1,3}.\[0-9]{1,3}.\[0-9]{1,3}.\[0-9]{1,3}$"))
