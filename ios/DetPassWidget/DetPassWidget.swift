import SwiftUI
import WidgetKit

struct DetPassWidgetEntry: TimelineEntry {
    let date: Date
}

struct DetPassWidgetProvider: TimelineProvider {
    func placeholder(in context: Context) -> DetPassWidgetEntry {
        DetPassWidgetEntry(date: Date())
    }

    func getSnapshot(in context: Context, completion: @escaping (DetPassWidgetEntry) -> Void) {
        completion(DetPassWidgetEntry(date: Date()))
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<DetPassWidgetEntry>) -> Void) {
        completion(Timeline(entries: [DetPassWidgetEntry(date: Date())], policy: .never))
    }
}

struct DetPassWidgetEntryView: View {
    let entry: DetPassWidgetEntry
    @Environment(\.widgetFamily) private var family

    var body: some View {
        GeometryReader { geometry in
            switch family {
            case .systemSmall:
                smallLayout(in: geometry.size)
            case .systemLarge:
                largeLayout(in: geometry.size)
            default:
                mediumLayout(in: geometry.size)
            }
        }
        .widgetURL(URL(string: "detpass://generate"))
        .containerBackground(for: .widget) {
            DetPassTheme.cardGradient
        }
    }

    private func mediumLayout(in size: CGSize) -> some View {
        let inset = max(10, min(14, size.width * 0.035))
        let gap = max(6, min(10, size.width * 0.025))
        let statusHeight: CGFloat = 16
        let buttonSide = min(96, max(74, size.height - (inset * 2) - gap - statusHeight))
        let fieldHeight = max(34, (buttonSide - gap) / 2)

        return VStack(spacing: gap) {
            HStack(spacing: gap) {
                VStack(spacing: gap) {
                    widgetField("Your secret", height: fieldHeight, fontSize: 16)
                    widgetField("example.com", height: fieldHeight, fontSize: 16)
                }

                generateLink(side: buttonSide, imageScale: 0.50, fontSize: 13)
            }

            statusText("TAP TO GENERATE", size: 11)
                .frame(height: statusHeight)
        }
        .padding(inset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .overlay(alignment: .topTrailing) {
            Image("Kitty")
                .resizable()
                .scaledToFit()
                .frame(width: 30, height: 30)
                .opacity(0.22)
                .padding(.top, 5)
                .padding(.trailing, 7)
        }
    }

    private func smallLayout(in size: CGSize) -> some View {
        let inset = max(10, min(14, size.width * 0.08))

        return VStack(spacing: 7) {
            Image("Kitty")
                .resizable()
                .scaledToFit()
                .frame(maxWidth: size.width * 0.46, maxHeight: size.height * 0.38)

            Text("Det-Pass")
                .font(.system(size: 17, weight: .semibold))
                .foregroundStyle(Color.black.opacity(0.82))
                .lineLimit(1)
                .minimumScaleFactor(0.75)

            statusText("TAP TO GENERATE", size: 10)
        }
        .padding(inset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func largeLayout(in size: CGSize) -> some View {
        let inset = max(14, min(18, size.width * 0.045))
        let gap: CGFloat = 10
        let buttonSide = min(112, max(92, size.width * 0.28))

        return VStack(spacing: 14) {
            HStack(alignment: .top, spacing: gap) {
                VStack(spacing: gap) {
                    widgetField("Your secret", height: 46, fontSize: 17)
                    widgetField("example.com", height: 46, fontSize: 17)
                }

                generateLink(side: buttonSide, imageScale: 0.54, fontSize: 14)
            }

            VStack(spacing: 8) {
                Image("Kitty")
                    .resizable()
                    .scaledToFit()
                    .frame(maxHeight: min(96, size.height * 0.28))

                statusText("TAP TO GENERATE", size: 12)
            }
            .frame(maxWidth: .infinity)
        }
        .padding(inset)
        .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .top)
    }

    private func widgetField(_ placeholder: String, height: CGFloat, fontSize: CGFloat) -> some View {
        Text(placeholder)
            .font(.system(size: fontSize))
            .foregroundStyle(.gray)
            .lineLimit(1)
            .minimumScaleFactor(0.75)
            .frame(maxWidth: .infinity, minHeight: height, maxHeight: height, alignment: .leading)
            .padding(.horizontal, 10)
            .background(Color.white)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: Color.black.opacity(0.18), radius: 1, x: 0, y: -1)
    }

    private func generateLink(side: CGFloat, imageScale: CGFloat, fontSize: CGFloat) -> some View {
        Link(destination: URL(string: "detpass://generate")!) {
            VStack(spacing: 1) {
                Image("Kitty")
                    .resizable()
                    .scaledToFit()
                    .frame(maxWidth: side * imageScale, maxHeight: side * imageScale)

                Text("Generate")
                    .font(.system(size: fontSize, weight: .semibold))
                    .foregroundStyle(.white)
                    .lineLimit(1)
                    .minimumScaleFactor(0.65)
            }
            .frame(width: side, height: side)
            .background(DetPassTheme.blue)
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(Color.black, lineWidth: 1)
            )
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: DetPassTheme.shadow, radius: 0, x: 3, y: 3)
        }
    }

    private func statusText(_ text: String, size: CGFloat) -> some View {
        Text(text)
            .font(.system(size: size))
            .foregroundStyle(DetPassTheme.textMuted)
            .lineLimit(1)
            .minimumScaleFactor(0.7)
            .frame(maxWidth: .infinity)
    }
}

struct DetPassWidget: Widget {
    let kind = "DetPassWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: DetPassWidgetProvider()) { entry in
            DetPassWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Det-Pass")
        .description("Open the deterministic password generator.")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
        .contentMarginsDisabled()
    }
}

@main
struct DetPassWidgetBundle: WidgetBundle {
    var body: some Widget {
        DetPassWidget()
    }
}
