# ListenUp - Music Sharing App

## Table of Contents
1. [Overview](#Overview)
1. [Product Spec](#Product-Spec)
1. [Wireframes](#Wireframes)
2. [Schema](#Schema)

## Overview
### Description
An app for sharing songs with others.

### App Evaluation
- **Category:** Music
- **Mobile:** Real-time and audio.
- **Story:** A platform for music-lovers to share their favorite songs with other music-lovers.
- **Market:** No theoretical limit. Practically it's how many rows we can create on a Parse backend without paying. Demographic is people that listen to music.
- **Habit:** Consumption and creation app used as frequently as a music-lover decides to listen to music and keep up with other music-lovers.
- **Scope:** A stripped down version of the app would be functional and still true to the idea. Although challenging, the product we intend to build is reasonable in terms of completing this app by the end of the program.

## Product Spec

### 1. User Stories (Required and Optional)

**Required Must-have Stories**

* User can sign up and log in to app
* User can view other posted songs
* User can listen to previews of songs
* User can open the song in other streaming services
* User can favorite songs
* User can post songs

**Optional Nice-to-have Stories**

* User can share streaming links from in the app
* User can switch between grid view and list view
* User can filter by genre (or other tags, potentially)
* User can view the songs they've liked
* User can comment on posted songs
* User can open the app from the share page in other apps to quickly create a post

### 2. Screen Archetypes

* **Log-in & Sign up**
   * User can sign up and log in to app
* **Feed**
    * User can view other posted songs
    * User can listen to previews of songs
    * User can favorite songs
    * User can post songs
* **Favorites**
    * User can view the songs they've liked
* **Safari View Controller**
    * User can open the song in other streaming services

### 3. Navigation

**Tab Navigation** (Tab to Screen)

* **Feed**
* **Favorites**
* **Settings**

**Flow Navigation** (Screen to Screen)

* **Log-in & Sign Up**
   * Tab Bar View
       * Shows Feed, Favorites, Settings
* **Feed**
    * Create Posts
    * Safari View Controller
* **Favorites**
    * Safari View Controller

## Wireframes
<img src="https://github.com/CodePath-ListenUp/ListenUp/blob/main/wireframe-ListenUp.png" width=600>

### [BONUS] Digital Wireframes & Mockups
See Digital Wireframe above.

### [BONUS] Interactive Prototype
<img src="https://github.com/CodePath-ListenUp/ListenUp/blob/main/interactive-wireframe-ListenUp.gif" width=320>

## Schema 
[This section will be completed in Unit 9]
### Models
[Add table of models]
### Networking
- [Add list of network requests by screen ]
- [Create basic snippets for each Parse network request]
- [OPTIONAL: List endpoints if using existing API such as Yelp]
