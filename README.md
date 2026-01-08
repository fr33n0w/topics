# Topics! - The Nomad Forum

A feature-rich forum system for NomadNet/Reticulum mesh networks, built with micron pages.

## Features

- 📝 **Create & Reply** - Post topics and engage in discussions
- ❤️ **Like System** - Like topics and replies
- 👤 **User Profiles** - Set custom usernames, track posts/replies
- 📊 **Statistics** - View counts, user activity, and forum stats
- 🎨 **Rich Formatting** - Colorized categories, authors, and UI elements
- 🔐 **Authentication** - Identity-based posting with guest read-only mode

## Screenshots
<img width="1920" height="1080" alt="immagine" src="https://github.com/user-attachments/assets/c82c1422-eb17-4ca0-9ab5-cafe565fce35" />


The forum features a clean, terminal-style interface with:
- Topic listing with categories, authors, and statistics
- Article view with replies and interaction buttons
- User authentication and profile management

## Installation

### Requirements

- [Reticulum](https://reticulum.network/) network stack
- [NomadNet](https://github.com/markqvist/NomadNet) client
- Python 3.6+

### Setup

1. Clone this repository:
```bash
git clone https://github.com/fr33n0w/topics
cd topics
```

2. Copy the forum files to your NomadNet pages directory:
```bash
cp *.mu ~/.nomadnetwork/storage/pages/
cp adminpanel.py ~/.nomadnetwork/storage/pages/
```

3. Create the required JSON data files if missing:
```bash
cd ~/.nomadnetwork/storage/pages/
echo "[]" > forum_topics.json
echo "[]" > forum_replies.json
echo "[]" > forum_users.json
```

4. Make the admin panel executable:
```bash
chmod +x adminpanel.py
```

## File Structure

### Forum Pages (.mu files)

- **index.mu** - Main forum page with topic listing
- **article.mu** - Topic view with replies and interactions
- **newtopic.mu** - Create new topics
- **setuser.mu** - Set/update username
- **forum-post.mu** - Legacy topic creation (deprecated)

### Admin Tools

- **adminpanel.py** - Command-line admin interface for managing topics, replies, and users

### Data Files (JSON)

These files are created automatically and should **not** be committed to git:

- `forum_topics.json` - Topic data
- `forum_replies.json` - Reply data
- `forum_users.json` - User profiles
- `forum_stats.json` - Forum statistics

## Usage

### For Users

1. Navigate to `index.mu` in your NomadNet client
2. **Guest Mode** - Read topics without authentication
3. **Authenticated Mode** - Identify/fingerprint to NomadNet, then set a username
4. Create topics, post replies, and like content

### For Admins

Run the admin panel from your pages directory:

```bash
cd ~/.nomadnetwork/storage/pages/
./adminpanel.py
```

Admin panel features:
- List and delete topics
- Manage replies
- User management
- Reset counters
- Recalculate statistics
- Create backups

## Security Features

- Input sanitization (removes formatting codes and special characters)
- Reserved username protection (admin, root, moderator, etc.)
- Identity-based authentication via NomadNet
- No hardcoded credentials or backdoors

## Categories

The forum supports customizable categories with color coding:
- 🧬 Reticulum
- 🛰️ NomadNet
- 🌐 rBrowser
- 🗺️ rMap
- 🧱 rNode
- 🧰 Tools
- 📘 Guides/Manuals
- 💬 General Talks
- 📢 Announcements
- 🔧 Hardware
- 🌍 Networking
- 🧭 Meta
- ⚡ Performance
- 🔐 Security
- 💻 Software

## Development

The forum is built using NomadNet's micron page format with:
- Python backend for data handling
- JSON file storage
- Environment variable authentication
- Colorized terminal UI with custom formatting

## Contributing

Contributions are welcome! Feel free to:
- Report bugs
- Suggest features
- Submit pull requests
- Improve documentation


## License

[Choose your license - MIT, GPL, etc.]

## Credits

Created by F for the Reticulum/NomadNet community.

## Links

- [Reticulum Network](https://reticulum.network/)
- [NomadNet](https://github.com/markqvist/NomadNet)
- [My Full Projects Repo](https://github.com/fr33n0w/)

## Support

For issues or questions:
- Open an issue on GitHub
- Reach out via LXMF on the Reticulum network
 
- NOTE: DEVELOPING OF THIS NOMADNET FORUM HAS STOPPED DUE TO LACK OF TIME, USE IT, CORRECT AND EDIT AS YOU WANT!
