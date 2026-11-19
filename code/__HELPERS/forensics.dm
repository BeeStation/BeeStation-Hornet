/// Returns the fingerprints on this atom
#define GET_ATOM_FINGERPRINTS(atom) atom.forensics?.fingerprints
/// Returns the hidden prints on this atom
#define GET_ATOM_HIDDENPRINTS(atom) atom.forensics?.hiddenprints
/// Returns the blood dna on this atom
#define GET_ATOM_BLOOD_DNA(atom) atom.forensics?.blood_DNA
/// Returns visible blood dna on this atom
#define GET_ATOM_BLOOD_DECALS(atom) atom.forensics?.get_visible_blood()
/// Returns the fibers on this atom
#define GET_ATOM_FIBRES(atom) atom.forensics?.fibers
/// Returns the souls on this atom
#define GET_ATOM_SOULS(atom) atom.forensics?.souls

/// Returns the number of unique blood dna sources on this atom
#define GET_ATOM_BLOOD_DNA_LENGTH(atom) (isnull(atom.forensics) ? 0 : length(atom.forensics.blood_DNA))
/// Returns the number of *visible* blood dna on this atom
#define GET_ATOM_BLOOD_DECAL_LENGTH(atom) (isnull(atom.forensics) ? 0 : length(atom.forensics.get_visible_blood()))

/// Helper for easily adding blood from INSIDE a mob to an atom (NOT blood ON the mob)
#define add_mob_blood(from_who) add_blood_DNA(from_who.get_blood_dna_list(), from_who.get_static_viruses())
