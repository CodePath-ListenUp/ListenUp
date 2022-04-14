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
* User can view their favorite songs

**Optional Nice-to-have Stories**

* User can share streaming links from in the app
* User can switch between grid view and list view
* User can filter by genre (or other tags, potentially)
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
<img src="https://github.com/CodePath-ListenUp/ListenUp/blob/main/assets/wireframe-ListenUp.png" width=600>

### [BONUS] Digital Wireframes & Mockups
See Digital Wireframe above.

### [BONUS] Interactive Prototype
<img src="https://github.com/CodePath-ListenUp/ListenUp/blob/main/assets/interactive-wireframe-ListenUp.gif" width=320>

## Schema

#### User
| propertyName   | Type   | Description |
| - | - | - |
| submittedPosts | [Post] | Array of posts that the user has submitted |
| upvotedPosts   | [Post] | Array of posts that the user has upvoted |
| favoritedPosts | [Post] | Array of posts that the user has favorited; favoriting a post is more significant than upvoting a post (save vs upvote on reddit, for example) |
| downvotedPosts | [Post] | Array of posts that the user has downvoted |
| username       | String | username for this user (managed by Parse?) |
| password       | String | password for this user (managed by Parse?) |

#### Post
| propertyName | Type | Description |
|-|-|-|
| id | Int | The ID of the post|
| song | Song | The song will be stored in the SongResult object (Description below) |
| songLink | String URL | SongWhip Link given by API |
| upvotes | Int | Number of upvotes for the post |
| downvotes | Int | Number of downvotes for the post |
| calculatedScore | Int | Difference between upvotes and downvotes |
| createdAt | Date | Swift Date describing time of creation of post |
| createdBy | User | User that created the post

## Networking

* Log-in & Sign up
    - (Create/POST) Create a new profile
    - (Read/GET) Read user credentials and find a match
* Feed
    - (Read/GET) Query all posts with the highest calculated score as a sorter
       ```
        let query = PFQuery(className: "Post")
        query.includeKeys(["id","song","songLink","upvotes","downvotes","calculatedScore","createdAt","createdBy"])
        query.limit = numberOfPostsLoaded
        query.addDescendingOrder("calculatedScore")

        query.findObjectsInBackground { posts, error in
            if let error = error {
                print(error.localizedDescription)
                return
            }
            else {
                guard let posts = posts else {
                    print("An unknown error occurred.")
                    return
                }

                // Do something with posts...
            }
        }
       ```
    - (Create/POST) Create a new upvote
    - (Delete) Delete a previous upvote
    - (Create/POST) Create a new downvote
    - (Delete) Delete a previous downvote
* Create Post
    - (Read/GET) Search for a song using the iTunes Search API
    - (Create/POST) Create a new post
* Favorites
    - (Read/GET) Query all posts which have been favorited by the user

### Existing API Endpoints

We'll also be creating the following classes to manage our API responses from the iTunes Search API.

Base URL: "https://itunes.apple.com/"

GET: "/search"
- Options
    - term -> search term given by user
    - entity=song

#### SongResult
| propertyName | Type | Description |
|-|-|-|
| artistName | String | Name of the artist |
| trackName | String | Name of the track |
| collectionName | String | Name of the collection |
| trackCensoredName | String | Name of the track (non-explicit) |
| collectionCensoredName | String | Name of the collection (non-explicit) |
| previewUrl | String URL | Link to the 30-second track preview |
| artworkUrl[size] | String URL | Link to the track artwork |
| releaseDate | Date | Release date of the tack |
| primaryGenreName | String | The specific genre the track belongs to |
| trackName | String | Name of the track |

#### iTunesAPIResponse
| propertyName | Type | Description |
|-|-|-|
| resultsCount | Int | Number of results returned by API |
| results | [SongResult] |Array of SongResult objects |

### Progress Tracking

#### Issue #3: User can sign up and log in to the app

<img src="https://github.com/CodePath-ListenUp/ListenUp/blob/main/assets/login-and-signup.gif" width=320>
