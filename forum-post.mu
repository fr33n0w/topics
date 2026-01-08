#!/usr/bin/env python3
# -*- coding: utf-8 -*-
print("#!c=0")

import os
import json
from datetime import datetime

# Resolve path to JSON file
base_dir = os.path.dirname(__file__)
json_path = os.path.join(base_dir, "forum_topics.json")

# Load existing topics
try:
    with open(json_path, "r", encoding="utf-8") as f:
        topics = json.load(f)
except FileNotFoundError:
    topics = []

# Prompt user for input
print("`F222`B222¦¦`Ffff`B222 Enter new topic details:`f`b`F222`B222¦¦`f`b")
title = input("Title: ").strip()
category = input("Category: ").strip()
content = input("Message content: ").strip()
author = input("Author name: ").strip()

# Validate input
if not title or not content or not author:
    print("`F222`B222¦¦`Ff88`B222 Error: Title, content, and author are required.`f`b`F222`B222¦¦`f`b")
    exit()

# Create new topic entry
new_topic = {
    "id": max([t["id"] for t in topics], default=0) + 1,
    "title": title,
    "category": category or "General",
    "content": content,
    "author": author,
    "timestamp": datetime.now().isoformat(timespec="seconds"),
    "visits": 0,
    "views": 0,
    "posts": 1,
    "replies": 0,
    "likes": 0,
    "dislikes": 0
}

# Append and save
topics.append(new_topic)
with open(json_path, "w", encoding="utf-8") as f:
    json.dump(topics, f, indent=2, ensure_ascii=False)

# Confirmation
print("`F222`B222¦¦`F0f0`B222 Topic posted successfully! Return to forum.mu to view it.`f`b`F222`B222¦¦`f`b")
