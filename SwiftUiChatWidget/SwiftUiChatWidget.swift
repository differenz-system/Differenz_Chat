//
//  SwiftUiChatWidget.swift
//  SwiftUiChatWidget
//
//  Created by differenz147 on 05/08/21.
//

import WidgetKit
import SwiftUI
import Intents

struct Provider: IntentTimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date(), configuration: ConfigurationIntent())
    }

    func getSnapshot(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date(), configuration: configuration)
        completion(entry)
    }

    func getTimeline(for configuration: ConfigurationIntent, in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        var entries: [SimpleEntry] = []

        // Generate a timeline consisting of five entries an hour apart, starting from the current date.
        let currentDate = Date()
        for hourOffset in 0 ..< 5 {
            let entryDate = Calendar.current.date(byAdding: .hour, value: hourOffset, to: currentDate)!
            let entry = SimpleEntry(date: entryDate, configuration: configuration)
            entries.append(entry)
        }

        let timeline = Timeline(entries: entries, policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
    let configuration: ConfigurationIntent
    var gridLayout: [GridItem] = [ GridItem(.flexible())]
  
}

struct SwiftUiChatWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        
        
        switch family {
        case .systemSmall:
            GeometryReader(content: { geometry in
                VStack {
                    
                    HStack {
                        
                        VStack {
                            HStack {
                                
                                Image("1024")
                                    .resizable()
                                    .cornerRadius(5)
                                    .frame(width: geometry.size.width*0.44, height: geometry.size.width*0.4, alignment: .center)
                                
                                Spacer()
                                
                            }
                            
                            Divider()
                            HStack {
                                Text("click here to open application")
                                    .bold()
                                    .font(.system(size: 12))
                                Spacer()
                            }
                            
                            Spacer()
                        }
                        .padding()
                        
                    }
                    
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            })
        case .systemMedium:
            
            GeometryReader(content: { geometry in
                VStack {
                    
                    VStack {
                        
                        HStack {
                            Text("Chat")
                                .bold()
                                .font(.system(size: 14))
                            
                            Spacer()
                            
                        }//: title
                        
                        HStack {
                            LazyHGrid(rows: entry.gridLayout, alignment: .center, spacing: 10, pinnedViews: [], content: {
                               
                                ForEach(0...6,id: \.self) { item in
                                    
                                    VStack {
                                        
                                        Text("JK")
                                            .bold()
                                        
                                    }
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    
                                }
                                
                                
                            })
                            Spacer()
                        }
                        
                      Spacer()
                        
                    }
                    .padding([.leading,.trailing,.top], 10)
                    Divider().padding([.trailing, .leading], 10)
                    
                    VStack {
                        
                        HStack {
                            Text("Group")
                                .bold()
                                .font(.system(size: 14))
                            Spacer()
                        }// : title
                        
                        HStack {
                            LazyHGrid(rows: entry.gridLayout, alignment: .center, spacing: 10, pinnedViews: [], content: {
                               
                                ForEach(0...6,id: \.self) { item in
                                    
                                    VStack {
                                        
                                        Text("JK")
                                            .bold()
                                        
                                    }
                                    .frame(width: 40, height: 40, alignment: .center)
                                    .background(Color.blue)
                                    .clipShape(Circle())
                                    
                                }
                                
                                
                            })
                            Spacer()
                        }
                        Spacer()
                        
                    }//:  group
                    .padding([.leading,.trailing,.bottom], 10)
                    
                }
                .frame(width: geometry.size.width, height: geometry.size.height, alignment: .center)
            })
            
            
        case .systemLarge:
            Text("Large")
        default:
            Text("Some other WidgetFamily in the future.")
        }
        
        
    }
}

@main
struct SwiftUiChatWidget: Widget {
    let kind: String = "SwiftUiChatWidget"

    var body: some WidgetConfiguration {
        
        IntentConfiguration(kind: kind, intent: ConfigurationIntent.self, provider: Provider()) { entry in
            SwiftUiChatWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("SwiftUIChatApp")
        .description("quick open application.")
    }
}

struct SwiftUiChatWidget_Previews: PreviewProvider {
    static var previews: some View {
        SwiftUiChatWidgetEntryView(entry: SimpleEntry(date: Date(), configuration: ConfigurationIntent()))
            .previewContext(WidgetPreviewContext(family: .systemMedium))
    }
}
