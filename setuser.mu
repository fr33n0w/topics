#!/usr/bin/env python3
# -*- coding: utf-8 -*-
print("#!c=0")

import os
import sys
import json
from datetime import datetime

# JSON file path
base_dir = os.path.dirname(__file__)
user_file = os.path.join(base_dir, "forum_users.json")

reserved_usernames = {
    "admin", "administrator", "system", "sysop", "sys", "root", "mod", "moderator",
    "guest", "anonymous", "null", "undefined", "lxmf", "nomad", "server", "frank", "@dmin"
}

# Recover input from environment
def recover_input(key_suffix):
    for k, v in os.environ.items():
        if k.lower().endswith(key_suffix.lower()):
            return v.strip()
    return ""

def sanitize_input(text):
    """Remove backticks and micron formatting characters from user input"""
    if not text:
        return ""
    text = text.replace("`", "")
    text = text.replace("[", "")
    text = text.replace("]", "")
    text = text.replace("<", "")
    text = text.replace(">", "")
    return text

def load_users():
    if not os.path.exists(user_file):
        with open(user_file, "w", encoding="utf-8") as f:
            json.dump([], f, indent=2)
    with open(user_file, "r", encoding="utf-8") as f:
        return json.load(f)

def save_users(users):
    with open(user_file, "w", encoding="utf-8") as f:
        json.dump(users, f, indent=2)

def get_user_by_dest(dest):
    users = load_users()
    for user in users:
        if user["dest"] == dest:
            return user
    return None

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

def is_valid_username(name):
    name = name.strip()
    if len(name) < 3 or len(name) > 12:
        return False
    if name.lower() in reserved_usernames:
        return False
    forbidden = ["`", "!", "[", "<", ">", "]", "*", "|", "#", "\\", "/", "'", "="]
    return not any(code in name for code in forbidden)

def update_username(dest, new_name):
    users = load_users()
    for user in users:
        if user["dest"] == dest:
            user["username"] = new_name
            user["display_name"] = new_name
            user["last_active"] = datetime.now().isoformat(timespec="seconds")
            save_users(users)
            return True
    return False

# Get auth data
remote_identity = recover_input("remote_identity")
dest = recover_input("dest")
nickname = recover_input("field_username")

# Sanitize nickname input
if nickname:
    nickname = sanitize_input(nickname)

# Get current user
user = get_user_by_dest(dest) if dest else None
if user:
    display_name = user.get("display_name", dest[:8])
else:
    display_name = dest[:8] if dest else "Guest"

# Define nickset form
nickset = f"""

`F222`B222██`Ffff`Bfff─────`F000SET OR UPDATE YOUR USERNAME / MAX 12 CHARS ALLOWED `Ffff──────────────────────────────────────────────       ───────────────`f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                 `f`b
`F222`B222██`F222`B58c                                                                                                                             `f`b`F222`B222  `f`b
`F58c   `FfffEnter your new username: `F000`<15|username`>  `Ffff`_`!`[Save / Update Username`:/page/setuser.mu`*]`!`_ `f`b
`F222`B222██`Fddd`B58c                                                                                                                            `f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                    `f`b

`F222`B222██`F000`B222 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b

"""

# Username input and save logic
body = ""

if dest and nickname:
    nickname = nickname.strip()
    if not is_valid_username(nickname) or nickname.lower() in reserved_usernames:
        if nickname.lower() in reserved_usernames:
            body += f"\n       `Ff00Error: The username {nickname} is reserved and cannot be used. `!`_`[CLICK HERE TO RETRY!`:/page/setuser.mu]`!`_`f`b"
        else:
            body += "\n       `Ff00Error:` Invalid username. Max 12 characters, no formatting codes or symbols allowed. `!`_`[CLICK HERE TO RETRY!`:/page/setuser.mu]`!`_`f`b"
    else:
        get_or_create_user(nickname, dest, remote_identity)
        if update_username(dest, nickname):
            # Reload user data to get updated display_name
            users = load_users()
            for u in users:
                if u["dest"] == dest:
                    user = u
                    display_name = u.get("display_name", dest[:8])
                    break
            body += f"\n\n      `F0afUsername successfully set to:`   `Ffff`!{display_name}`!`f`b"
            body += f"\n\n      `F0af`B222If you want you can update your username:`! `Ffff`<15|username`>   `F0af`_`!`[Save New UserName`:/page/setuser.mu`*]`!`_ `f`b"
        else:
            body += "`Ff00Error:` Could not find user to update.`f`b"
elif dest:
    body += nickset
else:
    display_name = "Guest"
    body += f"\n\n\n     `Ff00Fingerprint not detected. Please identify before setting a username.`f`b\n\n"

# Login status line - AFTER username update
if not dest or not remote_identity:
    login_status_line = "`F222`B222   `Bddd`F000You are logged as: `!Guest User`!    Status:  `!Read Only Mode!`!  // Identify or Fingerprint to write new Posts!         `Ffff`B222     `f`b"
elif user and user.get("display_name"):
    login_status_line = f"`F222`B222     `Bddd`F000You are logged as: `!{display_name}`!    Status:  `!Read & Write Enabled!`! //    Ready to post on the forum!  `Ffff`B222    `f`b"
else:
    login_status_line = f"`F222`B222     `Bddd`F000You are logged as: `!{display_name}`!    Status:  `!Set Your Username`!  //   Set username to start posting and replying!            `Ffff`B222     `f`b"

# Header block
header = f"""
`F222`B222                                                                                                                                 `b
`Ffff`B222                                                    ┳┳┏┓┏┓┳┓  ┏┓┏┓┏┳┓┏┳┓┳┳┓┏┓┏┓                                                  `b
`Ffff`B222                                                    ┃┃┗┓┣ ┣┫  ┗┓┣  ┃  ┃ ┃┃┃┃┓┗┓                                                  `b
`Ffff`B222                                                    ┗┛┗┛┗┛┛┗  ┗┛┗┛ ┻  ┻ ┻┛┗┗┛┗┛                                                  `b
`F222`B222                                                                                                                                 `b

`F222`B222                                                                                                                                 `f`b
`F222`B222██`Ffff`Bfff────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                 `f`b
`F222`B222██`F222`B58c                                                                                                                            `f`b`F222`B222  `f`b
`F222`B222██`F58c`B58c  `Ffff`B58c`!//     TOPICS! -THE NOMAD FORUM      //                       `_`[BACK TO FORUM HOMEPAGE`:/page/index.mu`*]`!`_                                     `F222`B222  `f`b
`F222`B222██`Fddd`B58c                                                                                                                            `f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                    `f`b
#`F222`B222██`F000`B222 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
`c                                                                                                                         `f`b
{login_status_line}
`a
`l
#`F222`B222██`F000`B222────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                    `f`b
#`F222`B000"""

username_rules = """     `F222`B222██    `F0af`B222* Username Rules:                                                    `f`b
     `F222`B222██    `Ffff`B222- Must be between 3 and 12 characters!                               `f`b
     `F222`B222██    `Ffff`B222- No special characters allowed.                                     `f`b
     `F222`B222██    `Ffff`B222- No micron formatting codes or backticks                            `f`b
     `F222`B222██    `Ffff`B222- Can be UPPER case, lower case, or a combo of both.                 `f`b
     `F222`B222██    `Ffff`B222- Letters and numbers only — keep it clean and readable!             `f`b"""

backtohome = """

`F222`B222██`Ffff`Bfff────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                 `f`b
`F222`B222██`F222`B58c                                                                                                                            `f`b`F222`B222  `f`b
`F222`B222██`F58c`B58c  `Ffff`B58c`!//     TOPICS! -THE NOMAD FORUM      //                       `_`[BACK TO FORUM HOMEPAGE`:/page/index.mu`*]`!`_                                     `F222`B222  `f`b
`F222`B222██`Fddd`B58c                                                                                                                            `f`b`F222`B222  `f`b
#`F222`B222                                                                                                                                    `f`b
#`F222`B222██`F000`B222 ───────────────────────────────────────────────────────────────────────────────────────────────────────────────────────────`f`b`F222`B222  `f`b

"""
# Final output
print(header)
print(body)
print(username_rules)
print(backtohome)
