// Radios use a large variety of predefined frequencies.

//say based modes like binary are in living/say.dm

// ------------------------------------------------------------------------------------
//
// If you update these PLEASE update [[tgui\packages\tgui-say\constants\index.tsx]]
//
// ------------------------------------------------------------------------------------

#define RADIO_CHANNEL_COMMON "Common"
#define RADIO_KEY_COMMON ";"

#define RADIO_CHANNEL_SECURITY "Security"
#define RADIO_KEY_SECURITY "s"
#define RADIO_TOKEN_SECURITY ":s"

#define RADIO_CHANNEL_ENGINEERING "Engineering"
#define RADIO_KEY_ENGINEERING "e"
#define RADIO_TOKEN_ENGINEERING ":e"

#define RADIO_CHANNEL_COMMAND "Command"
#define RADIO_KEY_COMMAND "c"
#define RADIO_TOKEN_COMMAND ":c"

#define RADIO_CHANNEL_SCIENCE "Science"
#define RADIO_KEY_SCIENCE "n"
#define RADIO_TOKEN_SCIENCE ":n"

#define RADIO_CHANNEL_MEDICAL "Medical"
#define RADIO_KEY_MEDICAL "m"
#define RADIO_TOKEN_MEDICAL ":m"

#define RADIO_CHANNEL_SUPPLY "Supply"
#define RADIO_KEY_SUPPLY "u"
#define RADIO_TOKEN_SUPPLY ":u"

#define RADIO_CHANNEL_SERVICE "Service"
#define RADIO_KEY_SERVICE "v"
#define RADIO_TOKEN_SERVICE ":v"

#define RADIO_CHANNEL_EXPLORATION "Exploration"
#define RADIO_KEY_EXPLORATION "q"
#define RADIO_TOKEN_EXPLORATION ":q"

#define RADIO_CHANNEL_AI_PRIVATE "AI Private"
#define RADIO_KEY_AI_PRIVATE "o"
#define RADIO_TOKEN_AI_PRIVATE ":o"

#define RADIO_CHANNEL_SYNDICATE "Syndicate"
#define RADIO_KEY_SYNDICATE "t"
#define RADIO_TOKEN_SYNDICATE ":t"

#define RADIO_CHANNEL_CENTCOM "CentCom"
#define RADIO_KEY_CENTCOM "y"
#define RADIO_TOKEN_CENTCOM ":y"

#define RADIO_CHANNEL_CTF_RED "Red Team"
#define RADIO_CHANNEL_CTF_BLUE "Blue Team"

#define RADIO_CHANNEL_UPLINK "Uplink"
#define RADIO_KEY_UPLINK "d"
#define RADIO_TOKEN_UPLINK ":d"

#define MIN_FREE_FREQ 65 // -------------------------------------------------
// Frequencies were reduced to range from 65 to 120 including free (syndicate) freequencies.

#define MIN_FREQ 80 // ------------------------------------------------------
// Only the 80 to 100 range is freely available for general conversation.

// Frequencies are ordered in 3 categories, by importance and how often they are used by players
// 1 - Day to Day Frequencies
#define FREQ_COMMON 85  //! Common comms frequency, dark green
#define FREQ_SUPPLY 86  //!  Supply comms frequency, light brown
#define FREQ_SERVICE 87  //! Service comms frequency, green
#define FREQ_SCIENCE 88  //! Science comms frequency, plum
#define FREQ_COMMAND 89  //! Command comms frequency, gold
#define FREQ_MEDICAL 90  //! Medical comms frequency, soft blue
#define FREQ_ENGINEERING 91  //! Engineering comms frequency, orange
#define FREQ_SECURITY 92  //! Security comms frequency, red
#define FREQ_EXPLORATION 93 //! Exploration comms frequency, cyan
#define FREQ_AI_PRIVATE 94  //! AI private comms frequency, magenta

// 2 - Special Frequencies - These, save for centcom are always after the 100-th range
#define FREQ_CENTCOM 95  //!  CentCom comms frequency, light green
#define FREQ_NAV_BEACON 105
#define FREQ_PRESSURE_PLATE 106
#define FREQ_ELECTROPACK 107
#define FREQ_MAGNETS 108
#define FREQ_LOCATOR_IMPLANT 109
#define FREQ_SIGNALER 110  //! the default for new signalers, players have 25 frequencies to play with, 10 from 110 to 120 (easy access)

// 3 - Syndicate Freequencies, these are only accessible by free frequency radios.
#define FREQ_SYNDICATE 121  //!  Nuke op comms frequency, dark brown
#define FREQ_UPLINK 140   //!  Dummy channel for headset uplink
#define FREQ_CTF_RED 130  //!  CTF red team comms frequency, red
#define FREQ_CTF_BLUE 131  //!  CTF blue team comms frequency, blue

#define FREQ_STATUS_DISPLAYS 75	// I'll be honest, I have no idea what this does exactly, but this was beyound the range of normal radios so I kept it at that

#define MAX_FREQ 120 // ------------------------------------------------------

#define MAX_FREE_FREQ 140 // -------------------------------------------------

// Transmission types.
#define TRANSMISSION_WIRE 0  //! some sort of wired connection, not used
#define TRANSMISSION_RADIO 1  //! electromagnetic radiation (default)
#define TRANSMISSION_SUBSPACE 2  //! subspace transmission (headsets only)
#define TRANSMISSION_SUPERSPACE 3  //! reaches independent (CentCom) radios only

// Filter types, used as an optimization to avoid unnecessary proc calls.
#define RADIO_SIGNALER "signaler"
#define RADIO_AIRLOCK "airlock"
#define RADIO_MAGNETS "magnets"
#define RADIO_XENOA "xenoa_radio"

#define DEFAULT_SIGNALER_CODE 30

//Requests Console
#define REQ_NO_NEW_MESSAGE 				0
#define REQ_NORMAL_MESSAGE_PRIORITY 	1
#define REQ_HIGH_MESSAGE_PRIORITY 		2
#define REQ_EXTREME_MESSAGE_PRIORITY 	3

#define REQ_DEP_TYPE_ASSISTANCE 	(1<<0)
#define REQ_DEP_TYPE_SUPPLIES 		(1<<1)
#define REQ_DEP_TYPE_INFORMATION 	(1<<2)

///give this to can_receive to specify that there is no restriction on what z level this signal is sent to
#define RADIO_NO_Z_LEVEL_RESTRICTION 0
