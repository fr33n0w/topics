#!/usr/bin/env python3
# -*- coding: utf-8 -*-
print("#!c=0")

import os
import sys
import json
from datetime import datetime

# ═══════════════════════════════════════════════════════════════════════════════
# HELPER FUNCTIONS
# ═══════════════════════════════════════════════════════════════════════════════

base_dir = os.path.dirname(__file__)

def recover_input(key_suffix):
    """Get environment variable by suffix (case-insensitive)"""
    for k, v in os.environ.items():
        if k.lower().endswith(key_suffix.lower()):
            return v.strip()
    return ""

def load_json(filename):
    """Load JSON file from base directory"""
    filepath = os.path.join(base_dir, filename)
    if not os.path.exists(filepath):
        return []
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(filename, data):
    """Save JSON file to base directory"""
    filepath = os.path.join(base_dir, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def get_user_by_dest(dest):
    """Get user data by destination address"""
    users = load_json("forum_users.json")
    for user in users:
        if user.get("dest") == dest:
            return user
    return None

def sanitize_input(text):
    """Remove backticks and micron formatting characters from user input"""
    if not text:
        return ""
    # Remove backticks
    text = text.replace("`", "")
    # Remove square brackets (used in links)
    text = text.replace("[", "")
    text = text.replace("]", "")
    # Remove angle brackets (used in forms)
    text = text.replace("<", "")
    text = text.replace(">", "")
    return text

# ═══════════════════════════════════════════════════════════════════════════════
# USER AUTHENTICATION
# ═══════════════════════════════════════════════════════════════════════════════

remote_identity = recover_input("remote_identity")
dest = recover_input("dest")

# Determine display name
if dest:
    user = get_user_by_dest(dest)
    display_name = user["display_name"] if user and user.get("display_name") else dest[:8]
else:
    display_name = "Guest"
    user = None

is_logged_in = bool(dest and remote_identity)
can_post = is_logged_in and user and user.get("display_name")

# ═══════════════════════════════════════════════════════════════════════════════
# GET FORM DATA
# ═══════════════════════════════════════════════════════════════════════════════

title = recover_input("text") or recover_input("field_text")
content = recover_input("content") or recover_input("field_content")
category = recover_input("category") or recover_input("field_category") or "General Talks"

# ═══════════════════════════════════════════════════════════════════════════════
# GET EXISTING CATEGORIES
# ═══════════════════════════════════════════════════════════════════════════════

topics = load_json("forum_topics.json")
existing_categories = sorted(set([t["category"] for t in topics]))

# ═══════════════════════════════════════════════════════════════════════════════
# PROCESS SUBMISSION
# ═══════════════════════════════════════════════════════════════════════════════

error_message = ""
success_message = ""
new_topic_id = None

if title or content:
    if not can_post:
        if not is_logged_in:
            error_message = "You must be logged in to create topics. Please identify or fingerprint to NomadNet."
        else:
            error_message = "You need to set a username before posting."
    else:
        # Validate inputs
        title = sanitize_input(title.strip())
        content = sanitize_input(content.strip())
        category = sanitize_input(category.strip())
        
        if len(title) < 3:
            error_message = "Title must be at least 3 characters long."
        elif len(title) > 50:
            error_message = "Title must be no more than 50 characters long."
        elif len(content) < 20:
            error_message = "Content must be at least 20 characters long."
        elif not category:
            error_message = "Category is required."
        else:
            # Create new topic
            
            # Generate new ID
            max_id = max([t["id"] for t in topics], default=0)
            new_topic = {
                "id": max_id + 1,
                "title": title,
                "author": display_name,
                "category": category,
                "content": content,
                "timestamp": datetime.now().isoformat(timespec="seconds"),
                "posts": 1,
                "replies": 0,
                "views": 0,
                "likes": 0,
                "visits": 0,
                "liked_by": []
            }
            
            topics.append(new_topic)
            save_json("forum_topics.json", topics)
            
            # Update user post count
            if user:
                user["posts"] = user.get("posts", 0) + 1
                user["last_active"] = datetime.now().isoformat(timespec="seconds")
                users = load_json("forum_users.json")
                for i, u in enumerate(users):
                    if u["dest"] == dest:
                        users[i] = user
                        break
                save_json("forum_users.json", users)
            
            success_message = f"Topic created successfully!"
            new_topic_id = new_topic['id']

# ═══════════════════════════════════════════════════════════════════════════════
# RENDER PAGE
# ═══════════════════════════════════════════════════════════════════════════════

header = """
`F222`B222                                                                                                                                 `b
`Ffff`B222                                                ┏┓┳┓┏┓┏┓┏┳┓┏┓  ┳┓┏┓┓ ┏  ┏┓┏┓┏┓┏┳┓                                                `b
`Ffff`B222                                                ┃ ┣┫┣ ┣┫ ┃ ┣   ┃┃┣ ┃┃┃  ┃┃┃┃┗┓ ┃                                                 `b
`Ffff`B222                                                ┗┛┛┗┗┛┛┗ ┻ ┗┛  ┛┗┗┛┗┻┛  ┣┛┗┛┗┛ ┻                                                 `b
`F222`B222                                                                                                                                 `b
#`F222`B222                                                                                                                                 `f`b
`F222`B222██`F222`B58c                                                                                                                            `f`b
`F222`B222██`F58c`B58c  `Ffff`B58c`!//     THE NOMAD FORUM      //`!              A PLACE TO ASK AND SHARE                                                     `f`b
`F222`B222██`Fddd`B58c                                                                                                                            `f`b
#`F222`B222                                                                                                                                    `f`b
#`F222`B222██`F000`B222 ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b
`F222`B222██`Ffff`Bfff────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b
"""

print(header)

# Show success or error message
if success_message:
    print(f"`F222`B222██`F0f8`B222✓ {success_message}`f`b")
    print(f"`F222`B222██`Ffff`B222`[View your topic`:/page/article.mu`topic_id={new_topic_id}]  or  `[Return to Forum`:/page/index.mu]`f`b")
    print(f"`F222`B222██`F000`B222────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b")
elif error_message:
    print(f"`F222`B222██`Ff00`B222✗ Error: {error_message}`f`b")
    print(f"`F222`B222██`F000`B222────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b")

# Show login status
if not can_post:
    if not is_logged_in:
        print(f"`F222`B222██`Ff88`B222You must be logged in to create topics.`f`b")
    else:
        print(f"`F222`B222██`Ff88`B222You need to set a username before posting. `[Click here to set your username`:/page/setuser.mu]`f`b")
    print(f"`F222`B222██`F000`B222────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b")

# Form
categories_list = ", ".join(existing_categories) if existing_categories else "No categories yet"

body = f"""
`F222`B222██`Ffff`Bfff─────`F000CREATE A NEW ARTICLE / TOPIC`Ffff──────────────────────────────────────────────────────────────             ───────────────`f`b
   `F222`B222██`F0af`B222  New Article / Topic Guidelines:  `Ffff - Title must be 3–50 characters                                     `f`b
   `F222`B222██`Ffff`B222                                   `Ffff - Content must be at least 20 characters                         `f`b
   `F222`B222██`Ffff`B222                                   `Ffff - Choose existing category or create your own                   `f`b
   `F222`B222██`Ffff`B222                                   `Ffff - Emoji are allowed in content                                  `f`b
#`F222`B222██`F222`B58c                                                                                                                             `f`b`F222`B222  `f`b
`F58c   `FfffEnter your topic title:` 
   `F000`<50|text`Enter your topic title here>`f`b

`F58c   `FfffSelect or enter category:` 
   `F000`<30|category`Category name>`f`b
   `F58c   `FaaaExisting categories: `Ffff{categories_list}`f`b

`F58c   `FfffWrite your article content:` 
   `F000`<80|content`Write your article here>`f`b

  `Ffff`_`!`[▶ Publish The New Article! ◀`:/page/newtopic.mu`*]`!`_`f`b

`F58c   
`F222`B222██`Fddd`B58c                                                                                                                            `f`b`F222`B222  `f`b
"""

backtohome = "`F222`B222██`Ffff`B222 `[Return to main Forum Page`:/page/index.mu]`f`b"

print(body)
print(backtohome)
