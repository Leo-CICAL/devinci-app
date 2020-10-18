//
//  devinciWidget.swift
//  devinciWidget
//
//  Created by Antoine Raulin on 17/10/2020.
//

import WidgetKit
import SwiftUI



struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> DevinciData {
        DevinciData(date: Date(), name: "...", location:"...", time: "...")
    }

    func getSnapshot(in context: Context, completion: @escaping (DevinciData) -> ()) {
        let entry = DevinciData(date: Date(), name: "Espaces Vectoriels", location:"L206", time: "8h15 - 11h15" )
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let defaults = UserDefaults(suiteName: "group.eu.araulin.devinciApp")
        let url = defaults?.string(forKey: "ical") ?? ""
        let url2 = URL(string: url)!
        var title = ""
        var location = ""
        var hours = ""
        guard let myURL = URL(string: url) else {
            print("Error: \(url) doesn't seem to be a valid URL")
            return
        }

        do {
            let ics = try String(contentsOf: myURL, encoding: .utf8)
            let swiftCal = Read.swiftCal(from: ics)
            let dateFormatter = ISO8601DateFormatter()
            let begin = Date()
            let end = Date().addingTimeInterval(86400)
            let de = dateFormatter.date(from:"1970-10-24T04:00:00+0000")!
        
            for event in swiftCal.events {
                            
                if(event.startDate ?? de > begin && event.startDate ?? de < end){
                    title = event.title ?? "..."
                    if(title.contains("]")){
                        let s = title.split(separator: "]")
                        title = String(s[1])
                    }
                    if(title.contains("[")){
                        let s = title.split(separator: "[")
                        title = String(s[0	])
                    }
                    var end = event.endDate!
                    let formatter = DateFormatter()
                    formatter.dateFormat = "HH:mm"
                    formatter.timeZone = NSTimeZone(abbreviation: TimeZone.current.abbreviation() ?? "") as TimeZone?
                    let startString = formatter.string(from: event.startDate!)
                    let endString = formatter.string(from: event.endDate!)
                    hours = startString + " - "+endString
                    print(event.startDate)
                    location = event.location ?? ""
                    if(location.contains("-")){
                        location = String(location.split(separator: "-")[0])
                    }
                    if(location.contains("(")){
                        location = String(location.split(separator: "(")[0])
                    }
                    if(location.contains("[")){
                        location = String(location.split(separator: "[")[0])
                    }

                    break
                }
                        }
        } catch let error {
            title = "error"
            print("Error: \(error)")
        }
        
        
        let entry = DevinciData(date: Date(), name: title, location:location, time:hours)

        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}

extension Date {
    static var yesterday: Date { return Date().dayBefore }
    static var tomorrow:  Date { return Date().dayAfter }
    var dayBefore: Date {
        return Calendar.current.date(byAdding: .day, value: -1, to: noon)!
    }
    var dayAfter: Date {
        return Calendar.current.date(byAdding: .day, value: 1, to: noon)!
    }
    var noon: Date {
        return Calendar.current.date(bySettingHour: 12, minute: 0, second: 0, of: self)!
    }
    var month: Int {
        return Calendar.current.component(.month,  from: self)
    }
    var isLastDayOfMonth: Bool {
        return dayAfter.month != month
    }
}

struct SimpleEntry: TimelineEntry {
    let date: Date
}

struct DevinciData: TimelineEntry {
    let date: Date
    let name: String
    let location: String
    let time: String
}

struct devinciWidgetEntryView : View {
    var entry: Provider.Entry

    @Environment(\.colorScheme) var colorScheme
        var body: some View {
            VStack(alignment: .leading, spacing: 4) {
                Text(entry.name)
                    .font(.system(size:17))
                    .fontWeight(.bold)
                    .foregroundColor(Color(UIColor.label))
                Text(entry.location)
                    .font(.system(size:26))
                    .foregroundColor(colorScheme == .dark ? Color(red: 100/255, green: 1, blue: 218/255):Color(red: 0, green: 150/255, blue: 136/255))
                    .fontWeight(.bold)
                Spacer()
                Text(entry.time)
                    .font(.system(size:14))
                    .bold()
                    .foregroundColor(Color(UIColor.label))
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
                .padding()
            .background(Color(colorScheme == .dark ? UIColor.systemGray6 : UIColor.white))
        }

        static func format(date: Date) -> String {
            let formatter = DateFormatter()
            formatter.dateFormat = "dd/MM/yyyy HH:mm"
            return formatter.string(from: date)
        }
}

@main
struct devinciWidget: Widget {
    let kind: String = "devinciWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            devinciWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("Devinci")
        .description("Gardez un oeil sur votre prochain cours.")
    }
}

struct devinciWidget_Previews: PreviewProvider {
    static var previews: some View {
        devinciWidgetEntryView(entry: DevinciData(date: Date(), name: "...", location:"...", time: "..." ))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
