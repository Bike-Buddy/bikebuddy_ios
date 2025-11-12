//
//  AdviceView.swift
//  BikeBuddy
//
//  Created by Aniket Garg on 11/12/25.
//

import Foundation
import SwiftUI 

struct AdviceView: View {
    var data: [String] = [
        "Keep your chain clean and lubricated – wipe it down regularly and reapply bike-specific chain lube (not WD-40).",
        "Clean your bike after wet or muddy rides – dirt and grit wear down parts faster.",
        "Check tire pressure before every ride – use the recommended PSI printed on the sidewall.",
        "Inspect tires for cuts, glass, or embedded debris – prevents punctures and blowouts.",
        "Wipe rims and brake pads – dirt buildup can reduce braking power and damage rims.",
        "Keep derailleurs properly adjusted – shifting should be smooth without clicking or skipping.",
        "Replace your chain regularly – every 2,000–3,000 miles for road bikes, or sooner for mountain bikes.",
        "Check cassette and chainrings for wear – shark-tooth–shaped teeth mean it’s time to replace them.",
        "Clean and lube derailleur pulleys – small but easy to overlook; they collect grime fast.",
        "Do a quick pre-ride safety check – brakes, wheels, and quick releases before every ride.",
        "Schedule a full tune-up at least once a year – even if everything feels fine, a pro can spot early issues.",
        "True your wheels – look for side-to-side wobbles and tighten or loosen spokes as needed.",
        "Check spoke tension – uneven tension can lead to broken spokes or wobbly rims.",
        "Inspect brake pads – replace if grooves are worn down or braking feels weak.",
        "Adjust brake cables and levers – ensure smooth pull and proper return.",
        "Check disc brakes for rotor rub or oil contamination – clean rotors with isopropyl alcohol."
    ]
    
    var body: some View {
        NavigationStack {
            Text(data.randomElement() ?? "Happy riding!")
                .padding()
        }
    }
}
