# Flow Interview for James Turner Code Sample
This is a quick and dirty sample App I created for my code interview Wednesday night, because I don't have any non-proprietary code I can share... It's not pretty by any means, it's intended to show that I know how to deal with JSON data tasks, dispatch queues, using Combine for subscribing to
data updates, and various basic SwiftUI things like HStacks, Lists, etc as well as responsiveness to screen footprint.

## Potential Improvements (oh so many...)
- Real error handling and logging instead of prints
- Make the UI actually look nice
- Handle long place names more elegantly than just truncating them
- Store previous values in CoreData along with last update date so that the app doesn't start by fetching all the earthquakes every time it starts
- Sorting by column
- Tapping on a row for more information
- Filtering results by magnitude, location (distance from user), etc
- Displaying the earthquakes on a map
- Alerts using local pushes if there is an earthquake nearby
- Toggle time display between local and UTC
- Creating a mock data source and using it to write unit tests for some of the functions like the JSON decoding and data computations.
- There appears to be an edge case where earthquakes can be added that are earlier than the latest ones you saw, and by limiting the return value to ones later than the last request, you could miss them. Not sure how to fix this without refetching older ones to try and catch up.
