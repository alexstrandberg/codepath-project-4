# Project 4 - Chirpy

Chirpy is a basic Twitter app to read and compose tweets the [Twitter API](https://apps.twitter.com/).

Submitted by: Alexander Strandberg

Time spent: 22 hours spent in total

## User Stories

The following **required** functionality is completed:

- [X] User can sign in using OAuth login flow
- [X] The current signed in user will be persisted across restarts
- [X] User can view last 20 tweets from their home timeline
- [X] In the home timeline, user can view tweet with the user profile picture, username, tweet text, and timestamp.
- [X] User can pull to refresh.
- [X] User should display the relative timestamp for each tweet "8m", "7h"
- [X] Retweeting and favoriting should increment the retweet and favorite count.
- [X] User can tap on a tweet to view it, with controls to retweet, favorite, and reply.
- [X] User can compose a new tweet by tapping on a compose button.
- [X] User can tap the profile image in any tweet to see another user's profile
    - [X] Contains the user header view: picture and tagline
    - [X] Contains a section with the users basic stats: # tweets, # following, # followers
- [X] User can navigate to view their own profile
    - [X] Contains the user header view: picture and tagline
    - [X] Contains a section with the users basic stats: # tweets, # following, # followers

The following **optional** features are implemented:

- [X] User can load more tweets once they reach the bottom of the feed using infinite loading similar to the actual Twitter client.
- [X] User should be able to unretweet and unfavorite and should decrement the retweet and favorite count.
- [X] When composing, you should have a countdown in the upper right for the tweet limit.
- [X] After creating a new tweet, a user should be able to view it in the timeline immediately without refetching the timeline from the network.
- [X] User can reply to any tweet, and replies should be prefixed with the username and the reply_id should be set when posting the tweet
- [X] Links in tweets are clickable
- [X] User can switch between timeline, mentions, or profile view through a tab bar
- [ ] Pulling down the profile page should blur and resize the header image.
- [ ] Profile view should include that user's timeline

The following **additional** features are implemented:

- [X] User can click @screenname in tweet to go to that profile
- [X] Profile view has user's banner

Please list two areas of the assignment you'd like to **discuss further with your peers** during the next class (examples include better ways to implement something, how to extend your app in certain ways, etc):

1. 
2.

## Video Walkthrough

Here's a walkthrough of implemented user stories:

![Video Walkthrough](Chirpy2.gif)

GIF created with [LiceCap](http://www.cockos.com/licecap/).

## Notes

Describe any challenges encountered while building the app.

## Credits

List an 3rd party libraries, icons, graphics, or other assets you used in your app.

- [AFNetworking](https://github.com/AFNetworking/AFNetworking) - networking task library
- [MBProgressHUD](https://cocoapods.org/pods/MBProgressHUD) - progress indicator library
- [BDBOAuth1Manager](https://github.com/bdbergeron/BDBOAuth1Manager) - OAuth library
- [TTTAttributedLabel](https://github.com/TTTAttributedLabel/TTTAttributedLabel) - Custom UILabel library
- [IconMonstr - Home 7](http://iconmonstr.com/home-7)
- [swift-timeago](https://github.com/zemirco/swift-timeago) - Code adapted from function that displays relative timestamp
- [IconMonstr - User 6](http://iconmonstr.com/user-6)
- [IconMonstr - Picture 1](http://iconmonstr.com/picture-1)
- [stringByAddingPercentEncodingForRFC3986](http://useyourloaf.com/blog/how-to-percent-encode-a-url-string/) - Code snippet for posting tweets using proper encoding
- [init(htmlEncodedString: String)](http://stackoverflow.com/a/34245313) - Code snippet for making tweets display properly when there are HTML entities (ex: &amp;)
- [IconMonstr - Twitter 3](http://iconmonstr.com/twitter-3)

## License

Copyright 2016 Alexander Strandberg 

Licensed under the Apache License, Version 2.0 (the "License");
you may not use this file except in compliance with the License.
You may obtain a copy of the License at

http://www.apache.org/licenses/LICENSE-2.0

Unless required by applicable law or agreed to in writing, software
distributed under the License is distributed on an "AS IS" BASIS,
WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
See the License for the specific language governing permissions and
limitations under the License.
