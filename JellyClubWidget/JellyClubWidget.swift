//
//  JellyClubWidget.swift
//  JellyClubWidget
//
//  Created by Tyler Dakin on 5/11/22.
//

import Parse
import WidgetKit
import SwiftUI

var parseInited = false

struct Provider: TimelineProvider {
    
    
    
    func placeholder(in context: Context) -> SimpleEntry {
        Post.registerSubclass()
        User.registerSubclass()
        
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = parseAppID
            $0.clientKey = parseClientKey
            $0.server = parseServerURL
        }
        if !parseInited {
            Parse.initialize(with: parseConfig)
        }
        parseInited = true
        
        guard let user = User.current() else { return SimpleEntry(date: Date(), post: nil)}
        let fakePost = Post(song: SongResult(trackName: "Cool Song", trackId: -1, artistName: "Awesome Guy", collectionName: "Great Album", trackCensoredName: "C**l Song", collectionCensoredName: "G***t Album", previewUrl: "https://google.com/", artworkUrl100: "https://", trackViewUrl: "https://google.com/", releaseDate: "", primaryGenreName: "Rock"), createdBy: user, completion: nil)
        return SimpleEntry(date: Date(), post: fakePost)
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        Post.registerSubclass()
        User.registerSubclass()
        
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = parseAppID
            $0.clientKey = parseClientKey
            $0.server = parseServerURL
        }
        if !parseInited {
            Parse.initialize(with: parseConfig)
        }
        parseInited = true
        
        
        let query = Post.query()
        query?.limit = 1
        query?.addDescendingOrder("createdAt")
        query?.getFirstObjectInBackground(block: { object, error in
            if let object = object as? Post {
                let entry = SimpleEntry(date: Date(),post: object)
                completion(entry)
            }
            else if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("An unknown error occurred when fetching the post.")
            }
        })
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []
        
        Post.registerSubclass()
        User.registerSubclass()
        
        
        let parseConfig = ParseClientConfiguration {
            $0.applicationId = parseAppID
            $0.clientKey = parseClientKey
            $0.server = parseServerURL
        }
        if !parseInited {
            Parse.initialize(with: parseConfig)
        }
        parseInited = true

        let currentDate = Date()
        let query = Post.query()
        query?.limit = 1
        query?.addDescendingOrder("createdAt")
        query?.getFirstObjectInBackground(block: { object, error in
            if let object = object as? Post {
                let entryDate = Calendar.current.date(byAdding: .hour, value: 0, to: currentDate)!
                let entry = SimpleEntry(date: entryDate, post: object)
                entries.append(entry)
                let timeline = Timeline(entries: entries, policy: .atEnd)
                completion(timeline)
            }
            else if let error = error {
                print(error.localizedDescription)
            }
            else {
                print("An unknown error occurred when fetching the post.")
            }
        })

        
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let post: Post?
}

struct JellyClubWidgetEntryView : View {
    var entry: Provider.Entry
    
    // https://stackoverflow.com/a/63715553
    private static let deeplinkURL: URL = URL(string: "widget-deeplink://")!

    var body: some View {
        VStack {
            if let post = entry.post {
                Text("Latest Post:")
                    .font(.subheadline)
                Text(post.trackName)
                    .font(.headline)
                 
            }
            else {
                Text("No Post Found")
            }
        }
        .widgetURL(JellyClubWidgetEntryView.deeplinkURL)
    }
}

@main
struct JellyClubWidget: Widget {
    let kind: String = "JellyClubWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            JellyClubWidgetEntryView(entry: entry)
            
        }
        .configurationDisplayName("In Progress")
        .description("This widget is very experimental.")
    }
}

//struct JellyClubWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        JellyClubWidgetEntryView(entry: SimpleEntry(date: Date()))
//            .previewContext(WidgetPreviewContext(family: .systemSmall))
//    }
//}
