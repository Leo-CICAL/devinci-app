//
//  DevinciWidget.swift
//  DevinciWidget
//
//  Created by Antoine Raulin on 24/07/2020.
//

import WidgetKit
import SwiftUI

struct EDTTimeline: TimelineProvider {
    public typealias Entry = EDTEntry
    
    public func snapshot(with context: Context, completion: @escaping (EDTEntry) -> ()) {
        let fakeEDT = EDT(matiere: "Matière", prof: "Professeur M/Mme", salle: "L103", horaires: "12h00 à 13h00")
        let entry = EDTEntry(date: Date(), edt: fakeEDT)
        completion(entry)
    }

    public func timeline(with context: Context, completion: @escaping (Timeline<EDTEntry>) -> ()) {
        let currentDate = Date()
        let refreshDate = Calendar.current.date(byAdding: .minute, value: 20, to: currentDate)!

        EDTLoader.fetch { result in
            let edt: EDT
            if case .success(let fetchedEDT) = result {
                edt = fetchedEDT
            } else {
                edt = EDT(matiere: "Erreur", prof: "", salle: "", horaires: "")
            }
            let entry = EDTEntry(date: currentDate, edt: edt)
            let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
            completion(timeline)
        }
    }
}

struct EDT {
    let matiere: String
    let prof: String
    let salle: String
    let horaires: String
}

struct EDTEntry: TimelineEntry {
    public let date: Date
    public let edt: EDT
}

struct EDTLoader {
    static func fetch(completion: @escaping (Result<EDT, Error>) -> Void) {
        let edt = getEDTData()
        completion(.success(edt))
    }
    static func getEDTData() -> EDT {
        return EDT(matiere: "Espaces Vectoriels", prof: "Baptiste Beaux-Collin", salle: "E110", horaires: "12h00 à 13h00")
    }
}

struct PlaceholderView : View {
    var body: some View {
        Text("Chargement...")
    }
}

struct EDTCheckerWidgetView : View {
    let entry: EDTEntry
    @Environment(\.colorScheme) var colorScheme
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(entry.edt.matiere)
                .font(.system(size:22))
                .fontWeight(.bold)
                .foregroundColor(Color(UIColor.label))
            Text(entry.edt.salle)
                .font(.system(size:26))
                .foregroundColor(colorScheme == .dark ? Color(red: 100/255, green: 1, blue: 218/255):Color(red: 0, green: 150/255, blue: 136/255))
                .fontWeight(.bold)
            Text("par \(entry.edt.prof) de \(entry.edt.horaires)")
                .font(.system(.caption))
                .foregroundColor(Color(UIColor.label))
            Text("MAJ : \(Self.format(date:entry.date))")
                .font(.system(size:7))
                .foregroundColor(Color(UIColor.placeholderText))
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
struct DevinciWidget: Widget {
    private let kind: String = "DevinciWidget"

    public var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: EDTTimeline(), placeholder: PlaceholderView()) { entry in
            EDTCheckerWidgetView(entry: entry)
        }
        .configurationDisplayName("EDT")
        .description("Votre emploi du temps.")
    }
}

struct DevinciWidget_Previews: PreviewProvider {
    static var previews: some View {
        /*@START_MENU_TOKEN@*/Text("Hello, World!")/*@END_MENU_TOKEN@*/
    }
}
