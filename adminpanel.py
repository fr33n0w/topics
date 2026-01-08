#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Forum Admin Management Tool
Manage forum topics, replies, and users
"""

import os
import sys
import json
from datetime import datetime

base_dir = os.path.dirname(__file__)

def load_json(filename):
    filepath = os.path.join(base_dir, filename)
    if not os.path.exists(filepath):
        return []
    with open(filepath, "r", encoding="utf-8") as f:
        return json.load(f)

def save_json(filename, data):
    filepath = os.path.join(base_dir, filename)
    with open(filepath, "w", encoding="utf-8") as f:
        json.dump(data, f, indent=2, ensure_ascii=False)

def backup_all():
    """Create backup of all JSON files"""
    timestamp = datetime.now().strftime("%Y%m%d_%H%M%S")
    for filename in ["forum_topics.json", "forum_replies.json", "forum_users.json"]:
        if os.path.exists(os.path.join(base_dir, filename)):
            backup_name = f"{filename}.backup_{timestamp}"
            data = load_json(filename)
            save_json(backup_name, data)
            print(f"? Backed up {filename} to {backup_name}")

def list_topics():
    """List all topics with details"""
    topics = load_json("forum_topics.json")
    if not topics:
        print("No topics found.")
        return
    
    print("\n" + "="*100)
    print(f"{'ID':<5} {'Title':<35} {'Author':<15} {'Replies':<10} {'Likes':<10} {'Views':<10}")
    print("="*100)
    for topic in topics:
        print(f"{topic['id']:<5} {topic['title'][:33]:<35} {topic['author']:<15} {topic.get('replies', 0):<10} {topic.get('likes', 0):<10} {topic.get('views', 0):<10}")
    print("="*100 + "\n")

def delete_topic(topic_id):
    """Delete a topic and all its replies"""
    topics = load_json("forum_topics.json")
    replies = load_json("forum_replies.json")
    
    # Find and remove topic
    topic_found = False
    new_topics = []
    for topic in topics:
        if topic["id"] == topic_id:
            topic_found = True
            print(f"? Deleting topic: {topic['title']}")
        else:
            new_topics.append(topic)
    
    if not topic_found:
        print(f"? Topic ID {topic_id} not found")
        return
    
    # Remove all replies for this topic
    replies_before = len(replies)
    new_replies = [r for r in replies if r.get("topic_id") != topic_id]
    replies_deleted = replies_before - len(new_replies)
    
    save_json("forum_topics.json", new_topics)
    save_json("forum_replies.json", new_replies)
    
    print(f"? Topic deleted successfully")
    print(f"? {replies_deleted} replies also deleted")

def delete_reply(reply_id):
    """Delete a specific reply"""
    replies = load_json("forum_replies.json")
    
    reply_found = False
    new_replies = []
    for reply in replies:
        if reply["id"] == reply_id:
            reply_found = True
            print(f"? Deleting reply by {reply['author']}: {reply['content'][:50]}...")
        else:
            new_replies.append(reply)
    
    if not reply_found:
        print(f"? Reply ID {reply_id} not found")
        return
    
    save_json("forum_replies.json", new_replies)
    print(f"? Reply deleted successfully")

def list_replies(topic_id=None):
    """List all replies, optionally filtered by topic"""
    replies = load_json("forum_replies.json")
    
    if topic_id:
        replies = [r for r in replies if r.get("topic_id") == topic_id]
    
    if not replies:
        print("No replies found.")
        return
    
    print("\n" + "="*100)
    print(f"{'ID':<5} {'Topic ID':<10} {'Author':<15} {'Content':<50} {'Likes':<10}")
    print("="*100)
    for reply in replies:
        content = reply['content'][:47] + "..." if len(reply['content']) > 50 else reply['content']
        print(f"{reply['id']:<5} {reply.get('topic_id', 'N/A'):<10} {reply['author']:<15} {content:<50} {reply.get('likes', 0):<10}")
    print("="*100 + "\n")

def reset_counters():
    """Reset all view/like/reply counters to 0"""
    topics = load_json("forum_topics.json")
    replies = load_json("forum_replies.json")
    
    for topic in topics:
        topic['views'] = 0
        topic['likes'] = 0
        topic['replies'] = 0
        topic['liked_by'] = []
    
    for reply in replies:
        reply['likes'] = 0
        reply['liked_by'] = []
    
    save_json("forum_topics.json", topics)
    save_json("forum_replies.json", replies)
    
    print("? All counters reset to 0")

def reset_all():
    """Reset all data (topics, replies, users)"""
    confirm = input("??  This will DELETE ALL data. Type 'YES' to confirm: ")
    if confirm != "YES":
        print("Cancelled.")
        return
    
    backup_all()
    
    save_json("forum_topics.json", [])
    save_json("forum_replies.json", [])
    save_json("forum_users.json", [])
    
    print("? All data reset successfully")
    print("? Backups created before reset")

def list_users():
    """List all users"""
    users = load_json("forum_users.json")
    
    if not users:
        print("No users found.")
        return
    
    print("\n" + "="*100)
    print(f"{'Username':<20} {'Dest (last 8)':<15} {'Posts':<10} {'Replies':<10} {'Last Active':<25}")
    print("="*100)
    for user in users:
        dest_short = user['dest'][-8:] if user.get('dest') else 'N/A'
        print(f"{user.get('display_name', 'N/A'):<20} {dest_short:<15} {user.get('posts', 0):<10} {user.get('replies', 0):<10} {user.get('last_active', 'N/A'):<25}")
    print("="*100 + "\n")

def delete_user(username):
    """Delete a user by username"""
    users = load_json("forum_users.json")
    
    user_found = False
    new_users = []
    for user in users:
        if user.get('display_name') == username or user.get('username') == username:
            user_found = True
            print(f"? Deleting user: {user.get('display_name')}")
        else:
            new_users.append(user)
    
    if not user_found:
        print(f"? User '{username}' not found")
        return
    
    save_json("forum_users.json", new_users)
    print(f"? User deleted successfully")

def recalculate_stats():
    """Recalculate reply counts for all topics"""
    topics = load_json("forum_topics.json")
    replies = load_json("forum_replies.json")
    
    # Count replies per topic
    reply_counts = {}
    for reply in replies:
        topic_id = reply.get("topic_id")
        reply_counts[topic_id] = reply_counts.get(topic_id, 0) + 1
    
    # Update topics
    for topic in topics:
        actual_replies = reply_counts.get(topic["id"], 0)
        if topic.get("replies") != actual_replies:
            print(f"Topic #{topic['id']}: {topic.get('replies', 0)} ? {actual_replies} replies")
            topic["replies"] = actual_replies
    
    save_json("forum_topics.json", topics)
    print("? Statistics recalculated")

def show_menu():
    """Display main menu"""
    print("\n" + "="*60)
    print("         FORUM ADMIN MANAGEMENT TOOL")
    print("="*60)
    print("\nTOPIC MANAGEMENT:")
    print("  1. List all topics")
    print("  2. Delete topic by ID")
    print("  3. Reset all counters (views/likes/replies)")
    print("\nREPLY MANAGEMENT:")
    print("  4. List all replies")
    print("  5. List replies for specific topic")
    print("  6. Delete reply by ID")
    print("\nUSER MANAGEMENT:")
    print("  7. List all users")
    print("  8. Delete user by username")
    print("\nSYSTEM:")
    print("  9. Recalculate statistics")
    print(" 10. Create backup")
    print(" 11. Reset ALL data (DANGER!)")
    print("  0. Exit")
    print("="*60)

def main():
    """Main program loop"""
    while True:
        show_menu()
        choice = input("\nEnter your choice: ").strip()
        
        if choice == "1":
            list_topics()
        
        elif choice == "2":
            try:
                topic_id = int(input("Enter topic ID to delete: "))
                delete_topic(topic_id)
            except ValueError:
                print("Invalid ID")
        
        elif choice == "3":
            confirm = input("Reset all counters? (yes/no): ")
            if confirm.lower() == "yes":
                reset_counters()
        
        elif choice == "4":
            list_replies()
        
        elif choice == "5":
            try:
                topic_id = int(input("Enter topic ID: "))
                list_replies(topic_id)
            except ValueError:
                print("Invalid ID")
        
        elif choice == "6":
            try:
                reply_id = int(input("Enter reply ID to delete: "))
                delete_reply(reply_id)
            except ValueError:
                print("Invalid ID")
        
        elif choice == "7":
            list_users()
        
        elif choice == "8":
            username = input("Enter username to delete: ")
            delete_user(username)
        
        elif choice == "9":
            recalculate_stats()
        
        elif choice == "10":
            backup_all()
        
        elif choice == "11":
            reset_all()
        
        elif choice == "0":
            print("Goodbye!")
            sys.exit(0)
        
        else:
            print("Invalid choice")

if __name__ == "__main__":
    main()