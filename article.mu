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

def format_timestamp(ts):
    """Format ISO timestamp to readable format"""
    try:
        dt = datetime.fromisoformat(ts)
        return dt.strftime("%d %b %Y %H:%M")
    except:
        return ts

def get_user_by_dest(dest):
    """Get user data by destination address"""
    users = load_json("forum_users.json")
    for user in users:
        if user.get("dest") == dest:
            return user
    return None

def get_or_create_user(display_name, dest):
    """Get existing user or create new one"""
    users = load_json("forum_users.json")
    for user in users:
        if user["dest"] == dest:
            return user
    new_user = {
        "username": display_name,
        "display_name": display_name,
        "dest": dest,
        "lxmf_address": f"LXMF:{dest}",
        "posts": 0,
        "replies": 0,
        "last_active": datetime.now().isoformat(timespec="seconds"),
        "liked_posts": [],
        "liked_replies": []
    }
    users.append(new_user)
    save_json("forum_users.json", users)
    return new_user

def get_author_color(author):
    """Generate consistent color for author based on username"""
    author_colors = [
        "F0af", "F0f8", "F0fc", "Ffa8", "Ffc0", "F0a8", "Fccf",
        "Ff88", "Ffb0", "F0ff", "Faaa", "Fff8", "F088", "F08f",
        "F0fa", "F0c0", "F0f4", "Ffa0", "F0e8", "F0b8", "F0d0"
    ]
    seed = sum(ord(c) for c in author)
    return author_colors[seed % len(author_colors)]

def get_category_color(category):
    cat = category.lower()
    if "reticulum" in cat: return "F0f8"
    if "nomadnet" in cat: return "F0fc"
    if "rbrowser" in cat: return "F0ff"
    if "rmap" in cat: return "Faaf"
    if "rnode" in cat: return "Ffa8"
    if "tools" in cat: return "Ffc0"
    if "guide" in cat or "manual" in cat: return "F0a8"
    if "general" in cat or "talk" in cat: return "Fccf"
    if "announcement" in cat: return "Ff88"
    if "hardware" in cat: return "Ffb0"
    if "networking" in cat: return "F0ff"
    if "meta" in cat: return "Faaa"
    if "performance" in cat: return "Fff8"
    if "security" in cat: return "F088"
    if "software" in cat: return "F08f"
    return "Fccc"

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
raw_username = recover_input("username")
nickname = recover_input("field_username")

# Determine display name
dest_code = dest[-4:] if dest else ""
if dest:
    user = get_user_by_dest(dest)
    display_name = user["display_name"] if user and user.get("display_name") else dest[:8]
else:
    display_name = "Guest"

is_logged_in = bool(dest and remote_identity)
can_post = is_logged_in and user and user.get("display_name")

# ═══════════════════════════════════════════════════════════════════════════════
# GET PARAMETERS
# ═══════════════════════════════════════════════════════════════════════════════

topic_id = recover_input("topic_id") or recover_input("var_topic_id")
like_action = recover_input("like") or recover_input("var_like")
reply_text = recover_input("reply") or recover_input("field_reply")
like_reply_id = recover_input("like_reply") or recover_input("var_like_reply")

# ═══════════════════════════════════════════════════════════════════════════════
# LOAD DATA
# ═══════════════════════════════════════════════════════════════════════════════

topics = load_json("forum_topics.json")
replies = load_json("forum_replies.json")

# Find the topic
topic = next((t for t in topics if str(t["id"]) == str(topic_id)), None)

if not topic:
    print("`F222`B222██`Ff00`B222ERROR: Topic not found`f`b")
    print("`F222`B222██`F000`B222`[← Return to Forum`:/page/index.mu]`f`b")
    sys.exit(0)

# ═══════════════════════════════════════════════════════════════════════════════
# HANDLE ACTIONS
# ═══════════════════════════════════════════════════════════════════════════════

# Handle topic like
if like_action == "1" and dest and can_post:
    if "liked_by" not in topic:
        topic["liked_by"] = []
    if dest not in topic["liked_by"]:
        topic["likes"] = topic.get("likes", 0) + 1
        topic["liked_by"].append(dest)
        # Update user's liked posts
        if user:
            if "liked_posts" not in user:
                user["liked_posts"] = []
            if topic_id not in user["liked_posts"]:
                user["liked_posts"].append(int(topic_id))
                users = load_json("forum_users.json")
                for i, u in enumerate(users):
                    if u["dest"] == dest:
                        users[i] = user
                        break
                save_json("forum_users.json", users)
        save_json("forum_topics.json", topics)

# Handle reply like
if like_reply_id and dest and can_post:
    for i, reply in enumerate(replies):
        if str(reply["id"]) == str(like_reply_id):
            if "liked_by" not in reply:
                reply["liked_by"] = []
            if dest not in reply["liked_by"]:
                reply["likes"] = reply.get("likes", 0) + 1
                reply["liked_by"].append(dest)
                replies[i] = reply  # Update the reply in the list
                save_json("forum_replies.json", replies)
            break

# Handle new reply (only if NOT liking a reply)
if reply_text and dest and can_post and not like_reply_id:
    reply_text = sanitize_input(reply_text.strip())
    if len(reply_text) > 0:
        # Generate new reply ID
        max_id = max([r["id"] for r in replies], default=0)
        new_reply = {
            "id": max_id + 1,
            "topic_id": int(topic_id),
            "author": display_name,
            "author_dest": dest,
            "content": reply_text,
            "timestamp": datetime.now().isoformat(timespec="seconds"),
            "likes": 0,
            "liked_by": []
        }
        replies.append(new_reply)
        save_json("forum_replies.json", replies)
        
        # Update topic reply count
        topic["replies"] = topic.get("replies", 0) + 1
        save_json("forum_topics.json", topics)
        
        # Update user reply count
        if user:
            user["replies"] = user.get("replies", 0) + 1
            user["last_active"] = datetime.now().isoformat(timespec="seconds")
            users = load_json("forum_users.json")
            for i, u in enumerate(users):
                if u["dest"] == dest:
                    users[i] = user
                    break
            save_json("forum_users.json", users)

# Update view count
if "views" not in topic:
    topic["views"] = 0
topic["views"] += 1
save_json("forum_topics.json", topics)

# Login status detector (add this after user authentication section, before RENDER PAGE)
if not dest or not remote_identity:
    display_name = "Guest"
    login_status_line = "`Bddd`F000You are logged as: `!Guest User`!    Status:  `!Read Only Mode`!  // Identify or Fingerprint to write new Posts!`f`b"
elif dest and remote_identity and not user:
    display_name = dest[:8]
    login_status_line = f"`Bddd`F000You are logged as: `!{display_name}`!   Status:  `!`_`[Click Here To Set Your Username`:/page/setuser.mu]`!`_  //  Set username to start posting and replying!`f`b"
elif dest and remote_identity and user and not user.get("display_name"):
    display_name = dest[:8]
    login_status_line = f"`Bddd`F000You are logged as: `!{display_name}`!   Status:  `!`_`[Click Here To Set Your Username`:/page/setuser.mu]`!`_  //  Set username to start posting and replying!`f`b"
else:
    display_name = user.get("display_name", dest[:8])
    login_status_line = f"`Bddd`F000You are logged as: `!{display_name}`!   Status: `!Read & Write Enabled!`! //  Ready to post on the forum!  // `!`[POST NEW ARTICLE`:/page/newtopic.mu]`!`f`b"

# ═══════════════════════════════════════════════════════════════════════════════
# RENDER PAGE
# ═══════════════════════════════════════════════════════════════════════════════

# Header
print(f"""
`F222`B222                                                                                                                                  `b
`Ffff`B222                                      ┏┳┓┏┓┏┓┳┏┓┏┓╻      ┏┳┓┓┏┏┓  ┳┓┏┓┳┳┓┏┓┳┓  ┏┓┏┓┳┓┳┳┳┳┓                                        `b
`Ffff`B222                                       ┃ ┃┃┃┃┃┃ ┗┓┃  ━━   ┃ ┣┫┣   ┃┃┃┃┃┃┃┣┫┃┃  ┣ ┃┃┣┫┃┃┃┃┃                                        `b
`Ffff`B222                                       ┻ ┗┛┣┛┻┗┛┗┛•       ┻ ┛┗┗┛  ┛┗┗┛┛ ┗┛┗┻┛  ┻ ┗┛┛┗┗┛┛ ┗                                        `b
`F222`B222                                                                                                                                  `f`b
#         `Bddd`F000Logged in as: `!{display_name}`!    //   Ready to read, like and post replies                     `!`[Back to Forum Page`:/page/index.mu]`! `f`b
`c
{login_status_line}`f`b
`a
`l
#`F222`B222                                                                                                                                 `f`b
""")


# Topic content
author_color = get_author_color(topic["author"])
category_color = get_category_color(topic["category"])
print(f"""
  `F000`B58c                                                                                                                           `f`b
`Bfff`F000`!Title:  `F000{topic['title']} `f  `F000Author: `F000{topic['author']}`f    `F000Posted the: `F000{format_timestamp(topic['timestamp'])}`f    `F000Category: `F000{topic['category']}`f      `!`f`b
`F000`B222                                                                                                                                `f`b

`!`Ffff{topic['title']} `f`b`!
""")

print(f"`Ffff{topic['content']}`f`b\n")
print(f"`F000`B222                                                                                                                                 `f`b")
print(f"                                      `Ffff  👁️  {topic.get('views', 0)} Views  -  💬  {topic.get('replies', 0)} Replies  -  ❤️  {topic.get('likes', 0)} Like", end="")


# Like button next to likes count
if can_post:
    if "liked_by" in topic and dest in topic["liked_by"]:
        print(f" `F0a8✓`f`b")
    else:
        print(f" `F0af`[👍`:/page/article.mu`topic_id={topic_id}|like=1]`f`b")
else:
    print(f"`f`b")
print(f"`F000`B222                                                                                                                                 `f`b")

# Replies section
topic_replies = [r for r in replies if str(r.get("topic_id")) == str(topic_id)]
topic_replies.sort(key=lambda x: x.get("timestamp", ""))

if topic_replies:
    #print(f"\n\n  `F222`B58c                                                                                                                             `f`b")
    print(f"`F000`Bfff`!━━━ ARTICLE REPLIES: ({len(topic_replies)}) ━━━                                                                                                    `!`f`b\n")
    #print(f"`F222`B222   `F000`B222─────────────────────────────────────────────────────────────────────────────────────────── ────────`f`b")
    
    for reply in topic_replies:
        reply_author_color = get_author_color(reply["author"])
        print(f"`F000`B222                                                                                                                                 `f`b")
        print(f"Author: `{reply_author_color}{reply['author']}`f`b  `Faaa· Posted: {format_timestamp(reply['timestamp'])}`f`b  `Faaa· ❤️  {reply.get('likes', 0)}", end="")
        
        # Like button next to likes count
        if can_post:
            if "liked_by" in reply and dest in reply["liked_by"]:
                print(f" `F0a8✓`f`b")
            else:
                print(f" `F0af`[👍`:/page/article.mu`topic_id={topic_id}|like_reply={reply['id']}]`f`b")
        else:
            print(f"`f`b")
        
        print(f"Reply:  `Ffff{reply['content']}`f`b")
        #print(f"`F222`B222   `F58c                                                                                                                `f`b")
else:
    print(f"\n`FaaaNo replies yet. Be the first to reply!`f`b")
    #print(f"`F000`B222───────────────────────────────────────────────────────────────────────────────────────────────`f`b")

# Reply form
#print(f"`F222`B222                                                                                                                                    `f`b")
if can_post:
    #print(f"\n\n  `F222`B58c                                                                                                                             `f`b")
    print(f"\n`Bfff`F000`!━━━ POST A REPLY ━━━`!                                                                                                          `f`b`F222`B222  `f`b")
    print(f"\n`FfffWrite your reply: `F000`<90|reply`>`f`b `F0af`[📮 Post Reply`:/page/article.mu`topic_id={topic_id}|*]`f`b")
elif is_logged_in:
    print(f"`Ff88You need to set a username before posting. `[Click here to set your username`:/page/setuser.mu]`f`b")
else:
    print(f"\n`Ff11You must be logged in to post replies. Please identify or fingerprint to NomadNet.`f`b")

# Footer
print(f"""
#`F222`B222   `F000`B222─────────────────────────────────────────────────────────────────────────────────────────────────────────────────── ────────`f`b
#`F222`B222                                                                                                                                  `f`b
\n\n`F222`B222   `F0af`B222`[← Back to Forum`:/page/index.mu]`f`b`
#`F222`B222                                                                                                                              `f`b
#`F222`B222██`F222`B222                                                                                                                            `f`b
""")
