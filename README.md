[CSCE636 Project 2 - The User Guide.pdf](https://github.com/user-attachments/files/23351037/CSCE636.Project.2.-.The.User.Guide.pdf)


[CSCE636 Project 2 - Group 9 Technical Documentation.pdf](https://github.com/user-attachments/files/23351038/CSCE636.Project.2.-.Group.9.Technical.Documentation.pdf)

[CSCE636 Project 2 - Group 9 -Cucmber.pdf](https://github.com/user-attachments/files/23351093/CSCE636.Project.2.-.Group.9.-Cucmber.pdf)

The live Heroku deployment can be accessed here: https://p2-vinylverse-g9-b9b7a2eb942f.herokuapp.com/


 🎶 VinylVerse

 A Ruby on Rails Web App for Vinyl Collectors

---

 Overview

**VinylVerse** is a web application built for **vinyl collectors and music enthusiasts** who want a modern, organized way to catalog their physical music collections.  
The app allows users to **explore albums**, **manage their collections**, **create wishlists**, and **search through the Discogs API** for real album data.

---

 Who It’s For

This application is designed for:
- Vinyl collectors who want to **digitally showcase** their albums  
- New collectors looking to **track and grow** their music collections  
- Anyone who enjoys discovering and organizing music visually  

---

 The Problem

There isn’t a single unified platform for users to both **display their current vinyl collections** and **create wishlists** for albums they hope to own.  
Most collectors rely on spreadsheets or social media posts, which lack accurate data and structure.

---
 The Solution

VinylVerse connects to the **Discogs API** to fetch accurate album and artist information.  
Users can easily search, view, and save albums into their **collections** or **wishlists** through a beautiful, glowing interface.

---

 Key Features

 1. Explore Albums  
- Browse iconic albums (like *Thriller* or *Abbey Road*)  
- Preview covers, artist names, and details directly in the app  

 2. My Collection  
- View all owned albums in a grid of glowing album cards  
- See artist names, release years, and cover art  
- Remove albums anytime to keep the collection up to date  

 3. My Wishlist  
- Save albums you want to collect in the future  
- Remove them easily once they’ve been added to your collection  

 4. Search & Quick Add  
- Search through Discogs’ massive catalog of vinyl records  
- Add albums directly to **My Collection** or **Wishlist**  

---

 Design Principles Applied

- **Consistency:** Unified color palette, typography, and card layout across all pages  
- **Simplicity:** Clean and intuitive design focused on the albums  
- **Accessibility:** Passes accessibility checks and works even with JavaScript disabled  
- **User-Centered Design:** Every feature enhances the collector’s experience  
- **Aesthetic Appeal:** Glowing purple theme on a dark background inspired by vinyl culture  

---

 Security Features

- User authentication implemented through **bcrypt**  
- Passwords are **encrypted and hashed** before being stored  
- The app **verifies users** before allowing access to private data  
- **API keys** are securely stored in **Heroku environment variables** (never exposed on GitHub)

---

 Tech Stack

| Layer | Technology |
|--------|-------------|
| **Frontend** | HTML, CSS, ERB, JavaScript |
| **Backend** | Ruby on Rails |
| **Database** | SQLite (development) / PostgreSQL (production) |
| **Version Control** | Git & GitHub |
| **Deployment** | Heroku |


