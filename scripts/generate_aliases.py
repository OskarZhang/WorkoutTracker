#!/usr/bin/env python3
import csv
import re
import sys
from pathlib import Path

EQUIPMENT_PREFIX_SHORT = {
    "Barbell": "BB",
    "Dumbbell": "DB",
    "Kettlebell": "KB",
    "Smith Machine": "SM",
    "Machine": "Machine",
    "Cable": "Cable",
    "Resistance Band": "Band",
    "Bodyweight": "BW",
    "TRX": "TRX",
}

STOPWORDS_FOR_ACRONYM = {"and", "of", "the", "to", "with", "for"}
EQUIPMENT_WORDS = {"barbell", "dumbbell", "kettlebell", "smith", "machine", "resistance", "band", "bodyweight", "trx"}

def acronym(words):
    letters = [w[0] for w in words if w and w not in STOPWORDS_FOR_ACRONYM]
    return "".join(letters).upper()

def hyphen_variants(name):
    variants = set()
    if "-" in name:
        variants.add(name.replace("-", " "))
        # e.g., Pull-Up -> Pullup
        variants.add(re.sub(r"\b([A-Za-z]+)-up\b", lambda m: m.group(1)+"up", name, flags=re.IGNORECASE))
        variants.add(name.replace("-", ""))
    # common up variants even when already spaced
    variants.add(re.sub(r"\b(Pull)\s+Up\b", r"\1up", name, flags=re.IGNORECASE))
    variants.add(re.sub(r"\b(Chin)\s+Up\b", r"\1up", name, flags=re.IGNORECASE))
    return {v for v in variants if v and v != name}

def equipment_abbrev_variants(name):
    # Replace known equipment prefixes with their abbreviation
    for prefix, short in EQUIPMENT_PREFIX_SHORT.items():
        if name.startswith(prefix + " "):
            tail = name[len(prefix)+1:]
            return {f"{short} {tail}", f"{prefix} {tail}"}
    return set()

def known_synonyms(name):
    n = name.lower()
    out = set()
    if "overhead press" in n:
        out.update({"OHP", "Military Press"})
    if "bench press" in n and "close grip" not in n and "incline" not in n and "decline" not in n:
        out.add("BP")
    if "incline bench press" in n:
        out.update({"IBP", "Incline BP", "Incline Bench"})
    if "decline bench press" in n:
        out.update({"DBP", "Decline BP", "Decline Bench"})
    if "close grip bench press" in n:
        out.update({"CGBP", "Close Grip BP", "Close Grip Bench"})
    if "romanian deadlift" in n:
        out.add("RDL")
    if "deadlift" in n and "romanian" not in n and "trap bar" not in n and "sumo" not in n and "stiff" not in n:
        out.add("DL")
    if "lat pulldown" in n:
        out.update({"Lat Pull Down", "LPD", "Pulldown"})
    if "pull-up" in n or re.search(r"\bpull up\b", n):
        out.update({"Pullup"})
    if "chin-up" in n or re.search(r"\bchin up\b", n):
        out.update({"Chinup"})
    if "good morning" in n:
        out.add("GM")
    if "face pull" in n:
        out.add("FP")
    if "skullcrusher" in n:
        out.update({"Skull Crusher", "French Press"})
    if "bulgarian split squat" in n:
        out.add("BSS")
    if "t-bar row" in n:
        out.update({"T Bar Row", "T Bar", "TBR"})
    if "hanging leg raise" in n:
        out.add("HLR")
    if "tricep extension" in n:
        out.update({"Triceps Extension", "Tri Ext"})
    if "bicep curl" in n:
        out.update({"Biceps Curl"})
    if "upright row" in n:
        out.add("UR")
    if "chest supported row" in n:
        out.add("CSR")
    return out

def general_acronym(name):
    words = re.split(r"[^A-Za-z]+", name)
    words = [w for w in words if w]
    # drop equipment words when forming acronym
    filtered = [w for w in words if w.lower() not in EQUIPMENT_WORDS]
    ac = acronym(filtered)
    if len(ac) >= 2:
        return {ac}
    return set()

def generate_aliases(name):
    aliases = set()
    aliases.update(hyphen_variants(name))
    aliases.update(equipment_abbrev_variants(name))
    aliases.update(known_synonyms(name))
    aliases.update(general_acronym(name))
    # Remove exact duplicates and the original name (case-insensitive)
    aliases = {a for a in aliases if a.strip() and a.strip().lower() != name.strip().lower()}
    return aliases

def process_csv(path: Path):
    rows = []
    with path.open(newline="", encoding="utf-8") as f:
        reader = csv.reader(f)
        data = list(reader)
        if not data:
            return
        header = [h.strip() for h in data[0]]
        # Ensure at least Name,Tag
        if len(header) < 2 or header[0].lower() != "name" or header[1].lower() != "tag":
            raise SystemExit(f"Unexpected header in {path}: {header}")
        has_aliases = len(header) >= 3 and header[2].lower() == "aliases"
        new_header = ["Name", "Tag", "Aliases"]
        for row in data[1:]:
            if not row:
                continue
            name = row[0].strip()
            tag = row[1].strip() if len(row) >= 2 else ""
            current_aliases = row[2].strip() if has_aliases and len(row) >= 3 else ""
            if current_aliases:
                aliases = set([a.strip() for a in current_aliases.split(";") if a.strip()])
            else:
                aliases = set()
            aliases.update(generate_aliases(name))
            # Stable order: sort aliases by case-insensitive, then by original
            alias_list = sorted(aliases, key=lambda s: (s.lower(), s))
            rows.append([name, tag, ";".join(alias_list)])

    # Write back
    tmp_path = path.with_suffix(path.suffix + ".tmp")
    with tmp_path.open("w", newline="", encoding="utf-8") as f:
        writer = csv.writer(f)
        writer.writerow(["Name", "Tag", "Aliases"])
        writer.writerows(rows)
    tmp_path.replace(path)

def main():
    if len(sys.argv) < 2:
        print("Usage: generate_aliases.py <csv_path> [<csv_path> ...]")
        sys.exit(1)
    for p in sys.argv[1:]:
        path = Path(p)
        if not path.exists():
            print(f"Skip missing: {path}")
            continue
        print(f"Processing {path}")
        process_csv(path)
    print("Done.")

if __name__ == "__main__":
    main()


