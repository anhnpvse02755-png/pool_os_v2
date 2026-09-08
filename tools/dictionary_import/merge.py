"""Upsert the dictionary articles into assets/knowledge/knowledge.json.

Existing articles with a matching id are replaced in place (keeping their
position in the file); new ones are appended. The 102 granular V1 articles
(bridge.*, safety.*, mental.*, pattern.*) are never touched — they remain the
detail layer beneath these canonical entries.

Run from the repo root:

    python -m tools.dictionary_import.merge
"""

import json
import pathlib
import sys

from .sections_01_06 import ITEMS as SECTIONS_01_06
from .sections_aiming import ITEMS as SECTIONS_AIMING
from .sections_07_13 import ITEMS as SECTIONS_07_13
from .sections_14_23 import ITEMS as SECTIONS_14_23
from .sections_24_30 import ITEMS as SECTIONS_24_30

REPO_ROOT = pathlib.Path(__file__).resolve().parents[2]
KNOWLEDGE_JSON = REPO_ROOT / "assets" / "knowledge" / "knowledge.json"

DICTIONARY_ITEMS = (
    SECTIONS_01_06
    + SECTIONS_AIMING
    + SECTIONS_07_13
    + SECTIONS_14_23
    + SECTIONS_24_30
)


def main():
    items = json.loads(KNOWLEDGE_JSON.read_text(encoding="utf-8"))
    before = len(items)

    index = {item["id"]: pos for pos, item in enumerate(items)}
    replaced, added = [], []

    for article in DICTIONARY_ITEMS:
        article_id = article["id"]
        if article_id in index:
            items[index[article_id]] = article
            replaced.append(article_id)
        else:
            index[article_id] = len(items)
            items.append(article)
            added.append(article_id)

    # Fail loudly rather than writing a knowledge base with broken links.
    known = {item["id"] for item in items}
    dangling = [
        "{} -> {}".format(item["id"], ref)
        for item in items
        for ref in item.get("relatedKnowledgeIds", [])
        if ref not in known
    ]
    if dangling:
        sys.exit("Dangling relatedKnowledgeIds:\n  " + "\n  ".join(dangling))

    slugs = [item["slug"] for item in items]
    duplicate_slugs = {s for s in slugs if slugs.count(s) > 1}
    if duplicate_slugs:
        sys.exit("Duplicate slugs: {}".format(sorted(duplicate_slugs)))

    KNOWLEDGE_JSON.write_text(
        json.dumps(items, ensure_ascii=False, indent=2) + "\n",
        encoding="utf-8",
    )

    print("knowledge.json: {} -> {} articles".format(before, len(items)))
    print("  replaced {}: {}".format(len(replaced), ", ".join(sorted(replaced))))
    print("  added    {}: {}".format(len(added), ", ".join(sorted(added))))


if __name__ == "__main__":
    main()
