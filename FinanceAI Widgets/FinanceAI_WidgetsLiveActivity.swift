//
//  FinanceAI_WidgetsLiveActivity.swift
//  FinanceAI Widgets
//
//  Created by Vansh Kamra on 03/09/25.
//

import ActivityKit
import WidgetKit
import SwiftUI

struct FinanceAI_WidgetsAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        // Dynamic stateful properties about your activity go here!
        var emoji: String
    }

    // Fixed non-changing properties about your activity go here!
    var name: String
}

struct FinanceAI_WidgetsLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: FinanceAI_WidgetsAttributes.self) { context in
            // Lock screen/banner UI goes here
            VStack {
                Text("Hello \(context.state.emoji)")
            }
            .activityBackgroundTint(Color.cyan)
            .activitySystemActionForegroundColor(Color.black)

        } dynamicIsland: { context in
            DynamicIsland {
                // Expanded UI goes here.  Compose the expanded UI through
                // various regions, like leading/trailing/center/bottom
                DynamicIslandExpandedRegion(.leading) {
                    Text("Leading")
                }
                DynamicIslandExpandedRegion(.trailing) {
                    Text("Trailing")
                }
                DynamicIslandExpandedRegion(.bottom) {
                    Text("Bottom \(context.state.emoji)")
                    // more content
                }
            } compactLeading: {
                Text("L")
            } compactTrailing: {
                Text("T \(context.state.emoji)")
            } minimal: {
                Text(context.state.emoji)
            }
            .widgetURL(URL(string: "http://www.apple.com"))
            .keylineTint(Color.red)
        }
    }
}

extension FinanceAI_WidgetsAttributes {
    fileprivate static var preview: FinanceAI_WidgetsAttributes {
        FinanceAI_WidgetsAttributes(name: "World")
    }
}

extension FinanceAI_WidgetsAttributes.ContentState {
    fileprivate static var smiley: FinanceAI_WidgetsAttributes.ContentState {
        FinanceAI_WidgetsAttributes.ContentState(emoji: "😀")
     }
     
     fileprivate static var starEyes: FinanceAI_WidgetsAttributes.ContentState {
         FinanceAI_WidgetsAttributes.ContentState(emoji: "🤩")
     }
}

#Preview("Notification", as: .content, using: FinanceAI_WidgetsAttributes.preview) {
   FinanceAI_WidgetsLiveActivity()
} contentStates: {
    FinanceAI_WidgetsAttributes.ContentState.smiley
    FinanceAI_WidgetsAttributes.ContentState.starEyes
}
