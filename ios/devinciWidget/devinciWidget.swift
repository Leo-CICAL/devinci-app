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
        DevinciData(date: Date(), name: "Espaces Vectoriels", location:"L206", time: "8h15 - 11h15" , name2: "Calcul Intégral", location2: "E160", time2:"12h30 - 15h30")
    }
    
    func getSnapshot(in context: Context, completion: @escaping (DevinciData) -> ()) {
        let entry = DevinciData(date: Date(), name: "Espaces Vectoriels", location:"L206", time: "8h15 - 11h15" , name2: "Calcul Intégral", location2: "E160", time2:"12h30 - 15h30")
        completion(entry)
    }
    
    func getTimeline(in context: Context, completion: @escaping (Timeline<Entry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 5, to: currentDate)!
        let defaults = UserDefaults(suiteName: "group.eu.araulin.devinciApp")
        let url = defaults?.string(forKey: "ical") ?? ""
        var title = ""
        var location = ""
        var hours = ""
        var title2 = ""
        var location2 = ""
        var hours2 = ""
        if(url != ""){
            guard let myURL = URL(string: url) else {
                print("Error: \(url) doesn't seem to be a valid URL")
                return
            }
            
            do {
                let ics = try String(contentsOf: myURL, encoding: .utf8)
                let swiftCal = Read.swiftCal(from: ics)
                let dateFormatter = ISO8601DateFormatter()
                let begin = Date().addingTimeInterval( -3600)
                let end = Calendar.current.date(bySettingHour: 23, minute: 59, second: 59, of: Date())!
                let de = dateFormatter.date(from:"1970-10-24T04:00:00+0000")!
                var n = 0;
                for event in swiftCal.events {
                    
                    if(event.startDate ?? de > begin && event.startDate ?? de < end){
                        
                        
                        if(n == 0){
                            title = event.title ?? "..."
                            if(title.contains("]")){
                                let s = title.split(separator: "]")
                                title = String(s[1])
                            }
                            if(title.contains("[")){
                                let s = title.split(separator: "[")
                                title = String(s[0])
                            }
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            formatter.timeZone = NSTimeZone(abbreviation: TimeZone.current.abbreviation() ?? "") as TimeZone?
                            let startString = formatter.string(from: event.startDate!)
                            let endString = formatter.string(from: event.endDate!)
                            hours = startString + " - "+endString
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
                        }else{
                            title2 = event.title ?? "..."
                            if(title2.contains("]")){
                                let s = title2.split(separator: "]")
                                title2 = String(s[1])
                            }
                            if(title2.contains("[")){
                                let s = title2.split(separator: "[")
                                title2 = String(s[0])
                            }
                            let formatter = DateFormatter()
                            formatter.dateFormat = "HH:mm"
                            formatter.timeZone = NSTimeZone(abbreviation: TimeZone.current.abbreviation() ?? "") as TimeZone?
                            let startString = formatter.string(from: event.startDate!)
                            let endString = formatter.string(from: event.endDate!)
                            hours2 = startString + " - "+endString
                            location2 = event.location ?? ""
                            if(location2.contains("-")){
                                location2 = String(location2.split(separator: "-")[0])
                            }
                            if(location2.contains("(")){
                                location2 = String(location2.split(separator: "(")[0])
                            }
                            if(location2.contains("[")){
                                location2 = String(location2.split(separator: "[")[0])
                            }
                            break;
                        }
                        n += 1
                    }
                }
            } catch let error {
                title = "error"
                print("Error: \(error)")
            }
        }else{
            title = "url"
        }
        
        let entry = DevinciData(date: Date(), name: title, location:location, time:hours, name2: title2, location2: location2, time2: hours2)
        
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }
}



struct DevinciData: TimelineEntry {
    let date: Date
    let name: String
    let location: String
    let time: String
    
    let name2: String
    let location2: String
    let time2: String
}

struct devinciWidgetEntryView : View {
    var entry: Provider.Entry
    
    @Environment(\.colorScheme) var colorScheme
    @Environment(\.widgetFamily) var family
    
    var body: some View {
        switch family {
        case .systemSmall:
            VStack(alignment: .leading, spacing: 4) {
                if(entry.name == "url"){
                    HStack{
                        Spacer()
                        Image(systemName: "gear")
                        Spacer()
                    }.padding(.bottom, 8)
                    Text("Quitter puis ouvrir Devinci pour initialiser le widget")
                        .font(.system(size:12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.label))
                }
                else if(entry.name == ""){
                    HStack{
                        Spacer()
                        Image(systemName: "calendar")
                        Spacer()
                    }.padding(.bottom, 8)
                    Text("Pas de cours prévu")
                        .font(.system(size:12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.label))
                }
                else{
                    Text(entry.name)
                        .font(.system(size:17))
                        .fontWeight(.bold)
                        .foregroundColor(Color(UIColor.label))
                    Text(entry.location)
                        .font(.system(size:26))
                        .foregroundColor(entry.location.contains("ZOOM") ?  (colorScheme == .dark ? Color(red: 255/255, green: 112/255, blue: 67/255):Color(red: 255/255, green: 87/255, blue: 34/255)):(colorScheme == .dark ? Color(red: 100/255, green: 1, blue: 218/255):Color(red: 0, green: 150/255, blue: 136/255)))
                        .fontWeight(.bold)
                    Spacer()
                    Text(entry.time)
                        .font(.system(size:14))
                        .bold()
                        .foregroundColor(Color(UIColor.label))
                }
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue:30/255) : Color(red: 250/255, green: 250/255, blue:250/255))
        default:
            
            VStack(alignment: .leading, spacing: 4) {
                if(entry.name == "url"){
                    HStack{
                        Spacer()
                        Image(systemName: "gear")
                        Spacer()
                    }.padding(.bottom, 8)
                    Text("Quitter puis ouvrir Devinci pour initialiser le widget")
                        .font(.system(size:12))
                        .multilineTextAlignment(.center)
                        .foregroundColor(Color(UIColor.label))
                }
                else if(entry.name == ""){
                    HStack{
                        Spacer()
                        Image(systemName: "calendar")
                        Spacer()
                    }.padding(.bottom, 8)
                    HStack{
                        Spacer()
                        Text("Pas de cours prévu")
                            .font(.system(size:14))
                            .multilineTextAlignment(.center)
                            .foregroundColor(Color(UIColor.label))
                        Spacer()
                    }
                }
                else{
                    GeometryReader {container in
                        HStack(spacing: 0){
                            VStack(alignment: .leading, spacing: 4){
                                Text(entry.name)
                                    .font(.system(size:17))
                                    .fontWeight(.bold)
                                    .foregroundColor(Color(UIColor.label))
                                Text(entry.location)
                                    .font(.system(size:26))
                                    .foregroundColor(entry.location.contains("ZOOM") ?  (colorScheme == .dark ? Color(red: 255/255, green: 112/255, blue: 67/255):Color(red: 255/255, green: 87/255, blue: 34/255)):(colorScheme == .dark ? Color(red: 100/255, green: 1, blue: 218/255):Color(red: 0, green: 150/255, blue: 136/255)))
                                    .fontWeight(.bold)
                                Spacer()
                                Text(entry.time)
                                    .font(.system(size:14))
                                    .bold()
                                    .foregroundColor(Color(UIColor.label))
                            }.frame(width: container.size.width / 2)
                            
                            Divider()
                            VStack(alignment: .leading, spacing: 4){
                                if(entry.name2 == ""){
                                    HStack{
                                        Spacer()
                                        Text("Pas de cours")
                                            .font(.system(size:17))
                                            .foregroundColor(Color(UIColor.label))
                                        Spacer()
                                    }
                                }else{
                                    Text(entry.name2)
                                        .font(.system(size:17))
                                        .fontWeight(.bold)
                                        .foregroundColor(colorScheme == .dark ?Color(red: 151/255, green: 151/255, blue:151/255):Color(red: 170/255, green: 170/255, blue:170/255))
                                    Text(entry.location2)
                                        .font(.system(size:26))
                                        .foregroundColor(entry.location2.contains("ZOOM") ? (colorScheme == .dark ? Color(red: 207/255, green: 84/255, blue: 46/255):Color(red: 219/255, green: 122/255, blue: 91/255)):(colorScheme == .dark ? Color(red: 65/255, green: 193/255, blue: 163/255):Color(red: 97/255, green: 138/255, blue: 133/255)))
                                        .fontWeight(.bold)
                                    Spacer()
                                    Text(entry.time2)
                                        .font(.system(size:14))
                                        .bold()
                                        .foregroundColor(colorScheme == .dark ?Color(red: 151/255, green: 151/255, blue:151/255):Color(red: 170/255, green: 170/255, blue:170/255))
                                }
                            }.frame(width: container.size.width / 2)
                        }
                    }
                }
                
                
            }.frame(minWidth: 0, maxWidth: .infinity, minHeight: 0, maxHeight: .infinity, alignment: .leading)
            .padding()
            .background(colorScheme == .dark ? Color(red: 28/255, green: 28/255, blue:30/255) : Color(red: 250/255, green: 250/255, blue:250/255))
        }
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
        }.supportedFamilies([.systemSmall, .systemMedium])
        .configurationDisplayName("Devinci")
        .description("Gardez un oeil sur votre prochain cours.")
    }
}

struct devinciWidget_Previews: PreviewProvider {
    static var previews: some View {
        devinciWidgetEntryView(entry: DevinciData(date: Date(), name: "Espaces Vectoriels", location:"L206", time: "8h15 - 11h15" , name2: "Calcul Intégral", location2: "E160", time2:"12h30 - 15h30"))
            .previewContext(WidgetPreviewContext(family: .systemSmall))
    }
}
