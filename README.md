
<p align="center" style="margin-top: 20px;">
  <img src="https://github.com/nfgrilo/sherpany-challenge/raw/master/Source/Assets.xcassets/AppIcon.appiconset/Icon.png" width="128" height="128" alt="Posts"/><br/>
  <strong>Sherpany Code Challenge</strong><br/>by <a href="https://nunogrilo.com" target="_blank">Nuno Grilo</a>
</p>


# Posts

![iOS](https://img.shields.io/badge/iOS-11.0.%2B-green.svg?style=flat) ![iPad](https://img.shields.io/badge/device-iPad-blue.svg?style=flat) ![Swift](https://img.shields.io/badge/swift-4.1-orange.svg?style=flat)

## Table of Contents

- [Instructions](#instructions)
- [Discussion](#discussion)
  * [Architecture](#architecture)
  * [Persistence](#persistence)
  * [REST API](#rest-api)
  * [Photo Fetching](#photo-fetching)
  * [UI](#ui)
  * [Dependencies](#dependencies)
- [Requirements](#requirements)
- [Bonuses](#bonuses)

---

## Instructions

1. Navigate to [repo](https://github.com/nfgrilo/sherpany-challenge.git)
2. Clone locally using
   `git clone git@github.com:nfgrilo/sherpany-challenge.git`
3. Open `Sherpany Posts.xcodeproj` in Xcode
4. Build & Run
5. Enjoy!


## Discussion

### Architecture

The application was designed with the simple but effective **Coordinator Pattern**. 
The **Posts** app is making use of 4 coordinators: 

- `MainCoordinator`: the app coordinator
- `PostsCoordinator`: the post list coordinator for the master view
- `PostDetailsCoordinator`: the post details coordinator for the detail view
- `FullscreenPhotoCoordinator`: the coordinator for the full-size image viewer

#### Brief coordinators explanation
> A coordinator is an object that manages one or more view controllers. They take all the driving logic out of view controllers, moving it one layer up:

> `Coordinator` -> `UIViewController` -> `UIView`

> Similarly to views and view controllers, coordinators exist in tree structures. This allows to push down tasks into child coordinator (when parent coordinator grows), which helps to easily manage complexity giving space for growth. A child coordinator can create view controllers, wait for them to complete, and signal up when done. When a coordinator 'finishes', it cleans itself up, popping off whatever view controllers it has added, and then uses delegates to get messages back up to its parent.

### Persistence

#### Merging of fetched data with persisted data

Merging of fetched data with Core Data persisted data is handled the following way (search "`Requirement #5`" in Xcode):

1. Set appropriate **Core Data merging policy** by setting the `mergePolicy` of the managed object context to `NSMergeByPropertyObjectTrumpMergePolicy` (so that, data in memory takes precedence over persisted data).
2. **Remove any orphan** `Post` or `User` (although it is not possible to remove any of these from the app), which will cascade delete related entities when appropriate.
3. Persisted data is then **iterated and updated with fetched data** in `O(n)` time and `O(n)` space complexity.

#### Model objects

There are two groups of model objects in the app: 

  - Managed model objects (handled by Core Data) (`ManagedPost`, `ManagedUser`, `ManagedAlbum` and `ManagedPhoto`)
  - Simple model objects (`Post`, `User`, `Album` and `Photo`)

This simpler model object consists of Swift structs, providing a simple and safe way to achieve immutability and thread safety throughout the app. All model accesses are made through the `ModelController` class, which *only* return simple model objects.

### REST API

The API resources were defined using a protocol-oriented approach (see files `API*.swift`), and are accessible from the controller `APIController`:

- `APIResource`: describes each API resource by its method and URL
- `APIRequest`: provides request related functionality (network fetch)
- `APIResponse`: represents each model resource (as `Codable`)
- `APIError`: describes any error occurred during API access

### Photo Fetching

The actual photo (image) fetching is made separately by the `PhotoController` controller.

Each photo request translate into a `PhotoController.Task` being added to a queue, so that no multiple connections to the same image resource are ever made. Additionally, tasks have different priorities depending on the context (prefetching, fetching for visible cell, cancelling prefetching, full-sized image fetch), so dequeuing is always made with higher priority tasks. 

When queueing (and dequeuing) tasks, thread-safety is accomplished by using a concurrent queue with barrier (faster than a serial queue). Read accesses can be asynchronously, while writes are made synchronously with barrier, so that once a "write" is placed on the queue, it is only executed when there are no more "reads" in the queue. 

Network requests are made on a concurrent queue. However, because we could generate too many simultaneous requests to the same server, the number of network connections is limited to `10` (`PhotoController.httpMaximumConnectionsPerHost`).

**PS:** Please note that, for the purpose for the code challenge, the app is making use of the `URLSessionConfiguration.ephemeral` in-memory configuration. For a real-life application, this should be either `URLSessionConfiguration.default` or a custom one, so it could make use of disk caching, etc.

### UI

#### Master/Detail

This is handled by `MainCoordinator`. This coordinator will then create & delegate control to `PostsCoordinator` and `PostDetailsCoordinator` to handle their master and details view controllers, respectively. Each view controller is then loaded into an `UISplitViewController`.

#### Post List

The post list is handled by the `PostsCoordinator`. This will create the view controller, its data source and the search controller. The protocol `PostSelectedDelegate` is used to signal the observer (`PostDetailsCoordinator`) that the post selection has changed.

`PostsCoordinator` is a delegate of `ModelController` (via `ModelControllerDelegate`) and it's notified when new data becomes available (after fetching & merging data with persisted one).

#### Post Details & Related Albums

Post title, body and user albums are handled by `PostDetailsCoordinator`, which shows either `NoPostDetailsViewController` if no post is selected, or `PostDetailsViewController` otherwise.

A `UICollectionView` is used to show all the post details:

- post title and post body: implemented as a collection view header (first)
- album titles: implemented as collection view sections
- photos: implemented as collection view items

`PostDetailsCoordinator` implements `PostSelectedDelegate` to be notified of post selection changes. Whenever a post is selected, the coordinator will instruct its view controller to refresh its contents preserving its viewing context (selected post, scrolling position, albums collapsed state, and if a full-sized photo is being shown).

#### Full-Sized Photos

`FullscreenPhotoCoordinator` handles the view controller responsible for showing full-sized images. It is a *child coordinator* of `PostDetailsCoordinator`.


### Dependencies

This project has no 3rd party libraries dependencies.



## Requirements

Develop an **iPad application** that conforms with the requirements below.
Please note that you can **find code related with a specific requirement** by searching "`Requirement #XX`" on Xcode.

1. ✅ Set the navigation bar title to “Challenge Accepted!”
2. ✅ Use Swift
3. ✅ Fetch the data every time the app becomes active:
  - **Posts**: http://jsonplaceholder.typicode.com/posts
  - **Users**: http://jsonplaceholder.typicode.com/users
  - **Albums**: http://jsonplaceholder.typicode.com/albums
  - **Photos**: http://jsonplaceholder.typicode.com/photos
4. ✅ Persist the data in Core Data with relationships
5. ✅ Merge fetched data with persisted data, even though the returned data of the API currently never changes. See (6).
6. ✅ Our UI has a master/detail view. The master view should always be visible and has a fixed width. The detail view adapts to the space available depending on orientation.
7. ✅ Display a table of all the posts in the master view. For each post display the entire post title and the users email address below the title. The cell will have a variable height because of that
8. ✅ Implement swipe to delete on a post cell. Because of (4) the post will appear again after the next fetch of the data which is expected.
9. ✅ Selecting a post (master) displays the detail to this post. The detail view consists of the post title, post body and related albums.
10. ✅ The creator of this post has some favorite albums that we want to display along the post. An album consists of the album title and a collection of photos that belong to the album. 
11. ✅ The photos should be lazy-ly loaded when needed and cached. If the photo is in the cache it should take that, otherwise load from web and update the photo cell.
12. ✅ In general, provide UI feedback where you see fit.


## Bonuses

Please note that you can **find code related with a specific bonus** by searching "`Bonus #XX`" on Xcode.

1. ✅ It would be nice to be able to show/hide the photos of an album. All albums are collapsed in the default state.
2. ✅ Because the collection of photos can get quite long, we would like the headers to stick to the top. 
3. ✅ Include a search bar to search in the master view and provide live feedback to the user while searching.

**Extra Bonuses 👍**
  
4. ✅ UI State restoration when merge of fetched and persisted data ends (selected post, scrolling position, albums collapsed state, ...)
5. ✅ Tapping a photo (thumbnail) shows a new view with the full size photo
6. ✅ Dynamic Type support: UI adapts to text size changes in Settings app (General > Accessibility > Larger Text)
7. ⬜️ Unit Tests


