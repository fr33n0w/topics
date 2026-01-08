#!/usr/bin/env python3
# -*- coding: utf-8 -*-
print("#!c=0")

import os
import sys
import json
from datetime import datetime

#print("`F222`B222██`F0af`B222\[DEBUG] Environment Variables:`f`b`F222`B222  `f`b")
#for k, v in os.environ.items():
#    print(f"`F222`B222██`F0f8`B222{k} = `Ffff{v}`f`b`F222`B222  `f`b")


# Define base_dir first
base_dir = os.path.dirname(__file__)
user_file = os.path.join(base_dir, "forum_users.json")

def load_users():
    if not os.path.exists(user_file):
        with open(user_file, "w", encoding="utf-8") as f:
            json.dump([], f, indent=2)
    with open(user_file, "r", encoding="utf-8") as f:
        return json.load(f)

def save_users(users):
    with open(user_file, "w", encoding="utf-8") as f:
        json.dump(users, f, indent=2)

def get_or_create_user(display_name, dest, remote_identity):
    users = load_users()
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
    save_users(users)
    return new_user

def recover_input(key_suffix):
    for k, v in os.environ.items():
        if k.lower().endswith(key_suffix.lower()):
            return v.strip()
    return ""


remote_identity = recover_input("remote_identity")
dest = recover_input("dest")

dest_code = dest[-4:] if dest else ""
display_name = f"Guest_{dest_code}" if dest else "Guest"


# prevent duplicate links
def like_post(user, post_id):
    if post_id not in user["liked_posts"]:
        user["liked_posts"].append(post_id)
        save_users(load_users())  # reload and save to persist
        return True
    return False  # already liked

def like_reply(user, reply_id):
    if reply_id not in user["liked_replies"]:
        user["liked_replies"].append(reply_id)
        save_users(load_users())
        return True
    return False


# login
raw_username     = recover_input("username")
remote_identity  = recover_input("remote_identity")
nickname         = recover_input("field_username")
dest             = recover_input("dest")

# Fallbacks
if not raw_username and len(sys.argv) > 1:
    raw_username = sys.argv[1].strip()
if not dest and len(sys.argv) > 2:
    dest = sys.argv[2].strip()

hash_code = remote_identity[-4:] if remote_identity else ""
dest_code = dest[-4:] if dest else ""

# Display name logic
if nickname:
    display_name = nickname
elif raw_username:
    display_name = raw_username
elif dest:
    display_name = dest[:8]  # Use first 8 characters of LXMF address
else:
    display_name = "Guest"

def load_users():
    with open(os.path.join(base_dir, "forum_users.json"), "r", encoding="utf-8") as f:
        return json.load(f)

def get_user_by_dest(dest):
    users = load_users()
    for user in users:
        if user["dest"] == dest:
            return user
    return None

user = get_user_by_dest(dest)
nickname = user["display_name"] if user else ""

# Resolve path to JSON file relative to script
base_dir = os.path.dirname(__file__)
json_path = os.path.join(base_dir, "forum_topics.json")

# Load topics
with open(json_path, "r", encoding="utf-8") as f:
    topics = json.load(f)

# Format timestamp
def format_timestamp(ts):
    dt = datetime.fromisoformat(ts)
    return dt.strftime("%d %b %Y %H:%M")

# Render topic row
def render_topic_row(topic):
    icon = get_icon(topic)
    category_color = get_category_color(topic["category"])
    author_color = get_author_color(topic["author"])
    max_title_length = 30
    title = topic["title"]
    raw_title = topic["title"]
    if len(raw_title) > max_title_length:
        title = title[:max_title_length - 3] + "..."
    else:
        title = raw_title

    # Limit category to max 14 chars
    category = topic["category"]
    if len(category) > 14:
        category = category[:11] + "..."

    title_link = f"`[{title:<30}`:/page/article.mu`topic_id={topic['id']}]`"
    short_date = format_timestamp(topic['timestamp']).split()[0:3]  # Get "28 Oct 2025"
    short_date_str = " ".join(short_date)
    return f"   `Faaa#{topic['id']:<3}`Feee`b`Fffa{icon}  `Fc0f`!{title_link:<35} `{author_color}{topic['author']:<13}  `{category_color}{category:<18} `Ffff{short_date_str:<14}   `F0fa{topic['replies']:<11}`Fffa{topic['views']:<9}`Ffaa{topic['likes']:<8}`!"



# Render preview line
def render_preview(topic):
    return f"          `FffaPreview: `Fccc{topic['content'][:100]}..."

# category colorization and icons
def get_icon(topic):
    cat = topic["category"].lower()
    if "reticulum" in cat: return "🧬"
    if "nomadnet" in cat: return "🛰️"
    if "rbrowser" in cat: return "🌐"
    if "rmap" in cat: return "🗺️"
    if "rnode" in cat: return "🧱"
    if "tools" in cat: return "🧰"
    if "guide" in cat or "manual" in cat: return "📘"
    if "general" in cat or "talk" in cat: return "💬"
    if "announcement" in cat: return "📢"
    if "hardware" in cat: return "🔧"
    if "networking" in cat: return "🌍"
    if "meta" in cat: return "🧭"
    if "performance" in cat: return "⚡"
    if "security" in cat: return "🔐"
    if "software" in cat: return "💻"
    return "💬"

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
    return "Fccc"  # fallback soft gray

# author colorization

author_colors = [
    "F0af", "F0f8", "F0fc", "Ffa8", "Ffc0", "F0a8", "Fccf",
    "Ff88", "Ffb0", "F0ff", "Faaa", "Fff8", "F088", "F08f",
    "F0fa", "F0c0", "F0f4", "Ffa0", "F0e8", "F0b8", "F0d0",
    "F0f2", "F0f6", "F0f9", "F0fe", "F0fb", "F0fd", "F0f1",
    "F0ee", "F0dd", "F0cc", "F0bb", "F0aa", "F0a0", "F099"
]

def get_author_color(author):
    seed = sum(ord(c) for c in author)
    return author_colors[seed % len(author_colors)]


banner = f"""
                                                                                                                                 `f`b
`F222`B222                                                                                                                                 `b
`Ffff`Bfff                                                                                                                                 `b
`F222`B58c                                                                                                                                 `b
`Ffff`B58c`!//     TOPICS! - THE NOMAD FORUM      //                YOUR FREE PLACE TO ASK AND SHARE!                                        `b`!
`Fddd`B58c                                                                                                                                 `b
"""

# login status detector
if not dest or not remote_identity:
    display_name = "Guest"
    login_status_line = "`Bddd`F000You are logged as: `!Guest User`!    Status:  `!Read Only Mode`!  // Identify or Fingerprint to write new Posts!`f`b"
elif dest and remote_identity and not nickname:
    display_name = dest[:8]
    login_status_line = f"`Bddd`F000You are logged as: `!{display_name}`!   Status:  `!`_`[Click Here To Set Your Username`:/page/setuser.mu]`!`_  //  Set username to start posting and replying!`f`b"
else:
    display_name = nickname
    login_status_line = f"`Bddd`F000You are logged as: `!{display_name}`!   Status: `!Read & Write Enabled!`! //  Ready to post on the forum!  // `!`_`[POST NEW ARTICLE!`:/page/newtopic.mu]`!`_`f`b"


# Static header
header = f"""
`F222`B222                                                                                                                                  `b
`Ffff`B222                                      ┏┳┓┏┓┏┓┳┏┓┏┓╻      ┏┳┓┓┏┏┓  ┳┓┏┓┳┳┓┏┓┳┓  ┏┓┏┓┳┓┳┳┳┳┓                                        `b
`Ffff`B222                                       ┃ ┃┃┃┃┃┃ ┗┓┃  ━━   ┃ ┣┫┣   ┃┃┃┃┃┃┃┣┫┃┃  ┣ ┃┃┣┫┃┃┃┃┃                                        `b
`Ffff`B222                                       ┻ ┗┛┣┛┻┗┛┗┛•       ┻ ┛┗┗┛  ┛┗┗┛┛ ┗┛┗┻┛  ┻ ┗┛┛┗┗┛┛ ┗                                        `b
`F222`B222                                                                                                                                  `b
#
`c
#`F000`B222 ─────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`b
{login_status_line}
`a

`l
#`F222`B222                                                                                                                                    `f`b
#`F222`B000                                                                                                                                    `f`b
#`F222`B222   `F000`B222───────────────────────────────────────────────────────────────────────────────────────────────────────────────────   ───`f`b`F222`B222  `f`b
`F222`B222   `F222`B58c                                                                                                                             `f`b
`Bfff`F000   #     `!ARTICLE TOPIC / TITLE         AUTHOR            CATEGORY           DATE       REPLIES     VIEWS    LIKES            `f`b`!
#`F222`B222   `F000`B222 ────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
#`F222`B222   `Ffff`B222 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
#`F222`B222   `F222`B222                                                                                                                            `f`b`F222`B222  `f`b
#
"""

#!/usr/bin/env python3
# -*- coding: utf-8 -*-

import json
import os
from datetime import datetime

base_dir = os.path.dirname(__file__)

def load_json(filename):
    filepath = os.path.join(base_dir, filename)
    if not os.path.exists(filepath):
        return {}
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(filename, data):
    filepath = os.path.join(base_dir, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

# Load or create stats file
stats = load_json("forum_stats.json")

if not stats:
    stats = {
        "total_views": 0,
        "unique_visitors": [],
        "last_reset": datetime.now().isoformat(timespec="seconds")
    }

# Increment page view
stats["total_views"] = stats.get("total_views", 0) + 1

# Track unique visitor (by dest if available)
dest = os.environ.get("dest", "")
if dest and dest not in stats.get("unique_visitors", []):
    if "unique_visitors" not in stats:
        stats["unique_visitors"] = []
    stats["unique_visitors"].append(dest)

save_json("forum_stats.json", stats)

# Load forum data for statistics
topics = load_json("forum_topics.json")
replies = load_json("forum_replies.json")
users = load_json("forum_users.json")

# Calculate statistics
total_topics = len(topics) if isinstance(topics, list) else 0
total_replies = len(replies) if isinstance(replies, list) else 0
total_users = len(users) if isinstance(users, list) else 0
total_views = stats.get("total_views", 0)
unique_visitors = len(stats.get("unique_visitors", []))

# Calculate total likes
total_topic_likes = sum(t.get("likes", 0) for t in topics) if isinstance(topics, list) else 0
total_reply_likes = sum(r.get("likes", 0) for r in replies) if isinstance(replies, list) else 0
total_likes = total_topic_likes + total_reply_likes

# Find most active user
most_active_user = "None"
if users and isinstance(users, list):
    max_activity = 0
    for user in users:
        activity = user.get("posts", 0) + user.get("replies", 0)
        if activity > max_activity:
            max_activity = activity
            most_active_user = user.get("display_name", "Unknown")

# Generate statistics footer
stats_footer = f"""

`F222`B222                                                  `F0af━━━ FORUM STATISTICS ━━━ `F222`B222                                                      `f`b
 `Faaa📊 Total Topics: `Ffff{total_topics}`f`b - `Faaa💬 Total Replies: `Ffff{total_replies}`f`b - `Faaa👥 Registered Users: `Ffff{total_users}`f`b `Faaa👁️  Visits: `Ffff{total_views}`f`b - `Faaa❤️  Total Likes: `Ffff{total_likes}`f`b - `Faaa🏆 Most Active User: `Ffff{most_active_user}`f`b
`F000`B222──────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b
"""




# Separator and footer
separator = "   `F58c`b────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b"
footer = "`F222`B222██`F222`B222                                                                                                                            `f`b`F222`B222  `f`b"

# Render full page
def render_forum_page():
    print(header)
    for i, topic in enumerate(topics):
        #print(separator)
        print(render_topic_row(topic))
        print(render_preview(topic))
        if i < len(topics) - 1:
            print(separator)
    print(separator)
    #print(footer)
    print(stats_footer)
    #print(banner)

# Run
if __name__ == "__main__":
    render_forum_page()
