/// Prepares a text to be used for maptext. Use this so it doesn't look hideous.
#define MAPTEXT(text) {"<span class='maptext'>[##text]</span>"}

/// Macro from Lummox used to get height from a MeasureText proc
#define WXH_TO_HEIGHT(x) text2num(copytext(x, findtextEx(x, "x") + 1))

#define CENTER(text) {"<center>[##text]</center>"}

#define SANITIZE_FILENAME(text) (GLOB.filename_forbidden_chars.Replace(text, ""))

///Base layer of chat elements
#define CHAT_LAYER 1
///Highest possible layer of chat elements
#define CHAT_LAYER_MAX 2
/// Maximum precision of float before rounding errors occur (in this context)
#define CHAT_LAYER_Z_STEP 0.0001
/// The number of z-layer 'slices' usable by the chat message layering
#define CHAT_LAYER_MAX_Z (CHAT_LAYER_MAX - CHAT_LAYER) / CHAT_LAYER_Z_STEP
