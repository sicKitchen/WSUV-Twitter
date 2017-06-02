# WSUV Twitter

CS 458

WSUV Twitter is a client iOS application that mimics a Twitter-like service. User information and messages are stored on a server and are accessible via a web-based API using HTTP GET/POST methods. This project uses the Alamofire framework o communicate with the server. The application allows the user to

• fetch and view the latest “tweets”

• authenticate (register, log-on, and log-off)

• post messages (authenticated users only)

• delete messages that the user posted (bonus feature)

The project covers a variety of topics discussed in this course:

• UI controllers and views

• data persistence including using the iOS Keychain for secure storage of user information

• keyboard input and user interaction

• HTTP GET/POST communication with a RESTful API via Alamofire.

NOTE: Details of program in implementation details

## Implementation Details

### Model Objects

The tweets are stored remotely on the server, but are cached in a local array. The application delegate is a convenient place to store the tweets since it persists for the lifetime of the app, is easily accessible by all view controllers, and already has the hooks in place for loading and storing the tweets in the app’s sandbox when the app launches and enters the background state. The tweets are sorted by ascending dates (i.e., newest tweets are at the front of the array).

`Structure of tweet Object`

| property  | description                          |
|-----------|--------------------------------------|
| tweet_id  | unique integer identifying tweet     |
| username  | string of user who posted tweet      |
| isdeleted | true iff this tweet has been deleted |
| tweet     | content of tweet (NSString)          |
| date      | time/date stamp of tweet (NSDate)    |

### User Interface

Here the navigation controllers merely provide a navigation bar which is a convenient place to put titles and buttons – no controllers are ever “pushed onto” a navigation stack since they are all presented modally. These controllers define the primary interfaces for viewing tweets and adding a tweet. We can use UIAlertControllers for the user management menu and login view.

The primary controller is a table view controller that displays each tweet with the latest tweet near the top as shown on the left of Figure 1. The user can request that the latest tweets be fetched from the server by performing a “pull to refresh” gesture.

Since the length of each tweets varies between 1 and 140 characters, we display the tweets in table view cells with varying heights.

### Network Communication

Communication with the server requires creating HTTP connections which can be slow. Normally any time consuming processing needs to be performed on a background thread since blocking the main event-loop thread is never an option. Fortunately there are several frameworks that handle HTTP background network communication. NSURLConnection provides a mechanism for creating an HTTP connection for which you provide a delegate that can asynchronously receive data – the background network communication is handled for you. Since iOS 7, the URL loading system has been overhauled. The new NSURLSession class provides a richer set of features for HTTP processing. Alamofire is a third party Swift networking library built on top of Apple’s API’s that is even easier to use. AFNetworking is the analogous library for Objective-C.

## Backend API

### Get Tweets

* HTTP/GET get-tweets.cgi?date=<timestamp>
* Example : get-tweets.cgi?date=2013-03-14%2014:15:01
* Description: Fetch all tweets with time stamps later than given date.
* Parameter date : time stamp of earliest tweet to fetch
* Returns (on success) JSON object
* Errors
    500 Internal Server Error : my bad
    503 Database Unavailable : unable to connect to internal database.

### Register New User

* HTTP/POST register.cgi
* Description: Register new user and logs user in.
* Parameters: username, password
* Returns (on success) JSON object with “session token”
     {"session_token" : "765ADF654A64D566D6F6E66A"}
* Errors
    500 Internal Server Error : my bad;
    400 Bad Request : both username and password not provided 409 Conflict : username already exists.

### Login / Logout

* HTTP/POST login.cgi
* Description: Login / logout users.
* Parameters: username, password, [action=login|logout]
* Returns on successful login JSON object with “session token”
     {"session_token" : "765ADF654A64D566D6F6E66A"}

    On successful logout returns JSON object with session token 0

     {"session_token" : "0"}
* Errors
    500 Internal Server Error : my bad;
    400 Bad Request : both username and password not provided; 401 Unauthorized : Unauthorized;
    404 Not Found : no such user.

### Add Tweet

* HTTP/POST add-tweet.cgi
* Description: Add a tweet (up to 140 characters in length – actually database stores up to 200 characters).
* Parameters: username, session_token, tweet.
* Returns (on success) an echo back of the tweet:
     {"tweet" : "content of tweet"}

    Note that since neither the tweet_id nor actual time date stamp used is returned, the client is respon- sible for fetching tweet tweets (via get-tweets.cgi) to get the data for any new tweets (tweets later than its latest stored time stamp).

* Errors
    500 Internal Server Error : my bad;
    400 Bad Request : all parameters not provided; 401 Unauthorized : Unauthorized;
    404 Not Found : no such user.

### Delete Tweet

* HTTP/POST del-tweet.cgi (note not HTTP/DELETE)
* Description: Delete a tweet.
* Parameters: username, session_token, tweet_id.
* Returns (on success) JSON object:
     { "tweet_id" : 5342, "isdeleted" : 1, "tweet" : "[delete]" }

    The tweet is not actually deleted from the DB, but the content is replaced with ”[delete]”, the isdeleted field is set to true, and the time_stamp is updated so that that any clients will be no- tified that it has been deleted upon refresh.
* Errors
    500 Internal Server Error : my bad;
    400 Bad Request : all parameters not provided; 401 Unauthorized : Unauthorized;
    403 Forbidded : not the user’s tweet.
    404 Not Found : no such user or no such tweet.

## How to build and run

Explain to build and run the target program(s).

As of now, app must be ran through iOS simulator provided through xcode.

1. Clone tenKey repo from : `git@gitlab.encs.vancouver.wsu.edu:ssmiler/WSUV-Twitter.git`

1. Open in Xcode by double clicking: `WSUV Twitter.xcodeproj`

1. Select preferred targeted iOS emulator by the drop down menu on the top of the screen by the run button.

1. Click the run button to launch app on iOS emulator. (Looks like a play button on top of screen)

## Archive

```txt
WSUV Twitter
    ├── AddTweetTableViewController.swift   : Controller for add tweet tableView
    ├── AppDelegate.swift
    ├── Assets.xcassets                     : Holds app icons
    │   ├── AppIcon.appiconset
    │   │   ├── Contents.json
    │   │   ├── Icon-App-20x20@1x.png
    │   │   ├── Icon-App-20x20@2x-1.png
    │   │   ├── Icon-App-20x20@2x.png
    │   │   ├── Icon-App-20x20@3x.png
    │   │   ├── Icon-App-29x29@1x.png
    │   │   ├── Icon-App-29x29@2x-1.png
    │   │   ├── Icon-App-29x29@2x.png
    │   │   ├── Icon-App-29x29@3x.png
    │   │   ├── Icon-App-40x40@1x.png
    │   │   ├── Icon-App-40x40@2x-1.png
    │   │   ├── Icon-App-40x40@2x.png
    │   │   ├── Icon-App-40x40@3x.png
    │   │   ├── Icon-App-60x60@2x.png
    │   │   ├── Icon-App-60x60@3x.png
    │   │   ├── Icon-App-76x76@1x.png
    │   │   ├── Icon-App-76x76@2x.png
    │   │   └── Icon-App-83.5x83.5@2x.png
    │   └── Contents.json
    ├── Base.lproj
    │   ├── LaunchScreen.storyboard         : Splash screen
    │   └── Main.storyboard                 : Main app
    ├── Info.plist
    ├── SAMKeychain.h                       : For using keyChain
    ├── SAMKeychain.m
    ├── SAMKeychainQuery.h
    ├── SAMKeychainQuery.m
    ├── TwitterTableViewController.swift    : Controller for main tweet table
    ├── ViewController.swift
    ├── WSUV\ Twitter-Bridging-Header.h
    ├── twitter-logo-final.png              : twitter logo
    └── twitter-title.png                   : title logo
```

## Assets

* Twitter logo: http://itouchappreviewers.com/wp-content/uploads/2014/09/twitter1.png

* Icons created with: https://makeappicon.com

* Twitter styled text created with: http://www.twitlogo.com

## Authors / Contact

**[Spencer Kitchen](mailto:spencer.kitchen@wsu.edu)**







