/// Does 4 spaces. Used as a makeshift tabulator.
#define FOURSPACES "&nbsp;&nbsp;&nbsp;&nbsp;"

/// Standard maptext
/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/**
 * Pixel-perfect scaled fonts for use in the MAP element as defined in skin.dmf
 *
 * Four sizes to choose from, use the sizes as mentioned below.
 * Between the variations and a step there should be an option that fits your use case.
 * BYOND uses pt sizing, different than px used in TGUI. Using px will make it look blurry due to poor antialiasing.
 *
 * Default sizes are prefilled in the macro for ease of use and a consistent visual look.
 * To use a step other than the default in the macro, specify it in a span style.
 * For example: MAPTEXT_PIXELLARI("<span style='font-size: 24pt'>Some large maptext here</span>")
 */
/// Large size (ie: context tooltips) - Size options: 12pt 24pt.
#define MAPTEXT_PIXELLARI(text) {"<span style='font-family: \"Pixellari\"; font-size: 12pt; -dm-text-outline: 1px black'>[##text]</span>"}

/// Standard size (ie: normal runechat) - Size options: 6pt 12pt 18pt.
#define MAPTEXT_GRAND9K(text) {"<span style='font-family: \"Grand9K Pixel\"; font-size: 6pt; -dm-text-outline: 1px black'>[##text]</span>"}

/// Small size. (ie: context subtooltips, spell delays) - Size options: 12pt 24pt.
#define MAPTEXT_TINY_UNICODE(text) {"<span style='font-family: \"TinyUnicode\"; font-size: 12pt; line-height: 0.75; -dm-text-outline: 1px black'>[##text]</span>"}

/// Smallest size. (ie: whisper runechat) - Size options: 6pt 12pt 18pt.
#define MAPTEXT_SPESSFONT(text) {"<span style='font-family: \"Spess Font\"; font-size: 6pt; line-height: 1.4; -dm-text-outline: 1px black'>[##text]</span>"}

/**
 * Prepares a text to be used for maptext, using a variable size font.
 *
 * More flexible but doesn't scale pixel perfect to BYOND icon resolutions.
 * (May be blurry.) Can use any size in pt or px.
 *
 * You MUST Specify the size when using the macro
 * For example: MAPTEXT_VCR_OSD_MONO("<span style='font-size: 24pt'>Some large maptext here</span>")
 */
/// Prepares a text to be used for maptext, using a variable size font.
/// Variable size font. More flexible but doesn't scale pixel perfect to BYOND icon resolutions. (May be blurry.) Can use any size in pt or px.
#define MAPTEXT_VCR_OSD_MONO(text) {"<span style='font-family: \"VCR OSD Mono\"'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

#define CENTER(text) {"<center>[##text]</center>"}

#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

#define COLOR_TEXT(color, text) "<font color=\"[color]\">[text]</font>"

/// type of a chat to send discord servers
#define CHAT_TYPE_OOC "chat_ooc"
#define CHAT_TYPE_DEADCHAT "chat_dead"

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP

// which strip method 'stripped_input()' proc will use?
#define BYOND_ENCODE "byond_encode"
#define STRIP_HTML "strip_html"
#define STRIP_HTML_SIMPLE "strip_html_simple"
#define SANITIZE "sanitize"
#define SANITIZE_SIMPLE "sanitize_simple"
#define ADMIN_SCRUB "admin_scrub"

/// Removes everything enclose in < and > inclusive of the bracket, and limits the length of the message.
#define STRIP_HTML_FULL(text, limit) (sanitize(GLOB.html_tags.Replace(copytext(text, 1, limit), ""), limit))

/// BYOND's string procs don't support being used on datum references (as in it doesn't look for a name for stringification)
/// We just use this macro to ensure that we will only pass strings to this BYOND-level function without developers needing to really worry about it.
#define LOWER_TEXT(thing) lowertext(UNLINT("[thing]"))
