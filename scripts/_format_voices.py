"""Pretty-print Cartesia voices JSON from stdin. Used by cartesia-voices.sh."""
import sys
import json


def main() -> None:
    d = json.load(sys.stdin)
    voices = d.get("data", d) if isinstance(d, dict) else d
    print("{} voices\n".format(len(voices)))
    for v in voices:
        desc = (v.get("description") or "").replace("\n", " ")
        line = "  |  ".join([
            str(v.get("id", "")),
            str(v.get("name", "")),
            str(v.get("gender", "")),
            str(v.get("language", "")),
        ])
        print(line)
        if desc:
            print("    " + desc[:140])


if __name__ == "__main__":
    main()
