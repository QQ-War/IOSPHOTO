import WidgetKit
import SwiftUI

struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> SimpleEntry {
        SimpleEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (SimpleEntry) -> ()) {
        let entry = SimpleEntry(date: Date())
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        // 小组件不需要频繁刷新，因为它是静态入口
        let timeline = Timeline(entries: [SimpleEntry(date: Date())], policy: .atEnd)
        completion(timeline)
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct GravityWidgetEntryView : View {
    var entry: Provider.Entry
    @Environment(\.widgetFamily) var family

    var body: some View {
        switch family {
        case .accessoryCircular:
            // 锁屏圆圈小组件
            ZStack {
                AccessoryWidgetBackground()
                Image(systemName: "bubbles.and.sparkles.fill")
                    .font(.system(size: 20))
            }
        case .accessoryRectangular:
            // 锁屏长方形小组件
            HStack {
                VStack(alignment: .leading) {
                    Text("重力相册")
                        .font(.headline)
                    Text("点击进入物理世界")
                        .font(.caption2)
                }
                Spacer()
                Image(systemName: "iphone.radiowaves.left.and.right")
            }
        case .accessoryInline:
            // 锁屏时间上方的一行文字
            Text("📽️ 进入物理相册")
        default:
            Text("unsupported")
        }
    }
}

@main
struct GravityWidget: Widget {
    let kind: String = "GravityWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            GravityWidgetEntryView(entry: entry)
                .containerBackground(.fill.tertiary, for: .widget)
        }
        .configurationDisplayName("重力相册")
        .description("快速进入带重力感应的物理世界。")
        .supportedFamilies([.accessoryCircular, .accessoryRectangular, .accessoryInline])
    }
}
