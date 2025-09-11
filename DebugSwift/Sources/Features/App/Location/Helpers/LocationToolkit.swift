//
//  LocationToolkit.swift
//  DebugSwift
//
//  Created by Matheus Gois on 19/12/23.
//

import CoreLocation
import Foundation

class LocationToolkit: @unchecked Sendable {
    /// Allows setting a custom location by latitude and longitude, in addition to map selection.
    func setCustomLocation(latitude: Double, longitude: Double) {
        let location = CLLocation(latitude: latitude, longitude: longitude)
        self.simulatedLocation = location
    }
    static let shared = LocationToolkit()

    var simulatedLocation: CLLocation? {
        get {
            let latitude = UserDefaults.standard.double(forKey: Constants.simulatedLatitude)
            let longitude = UserDefaults.standard.double(forKey: Constants.simulatedLongitude)
            guard !latitude.isZero, !longitude.isZero else { return nil }

            return .init(latitude: latitude, longitude: longitude)
        }
        set {
            if let location = newValue {
                UserDefaults.standard.set(
                    location.coordinate.latitude,
                    forKey: Constants.simulatedLatitude
                )
                UserDefaults.standard.set(
                    location.coordinate.longitude,
                    forKey: Constants.simulatedLongitude
                )
            } else {
                UserDefaults.standard.removeObject(
                    forKey: Constants.simulatedLatitude
                )
                UserDefaults.standard.removeObject(
                    forKey: Constants.simulatedLongitude
                )
            }
            UserDefaults.standard.synchronize()

            CLLocationManagerTracker.shared.triggerUpdateForAllLocations()
        }
    }

    var indexSaved: Int {
        guard let simulatedLocation else { return -1 }
        if let index = presetLocations.firstIndex(
            where: {
                $0.latitude == simulatedLocation.coordinate.latitude &&
                    $0.longitude == simulatedLocation.coordinate.longitude
            }
        ) {
            return index + 1
        }

        return -1
    }

    let presetLocations: [PresetLocation] = {
        var presetLocations = [PresetLocation]()
        presetLocations.append(
            PresetLocation(
                title: "London, England",
                latitude: 51.509980,
                longitude: -0.133700
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Johannesburg, South Africa",
                latitude: -26.204103,
                longitude: 28.047305
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Moscow, Russia",
                latitude: 55.755786,
                longitude: 37.617633
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Mumbai, India",
                latitude: 19.017615,
                longitude: 72.856164
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Tokyo, Japan",
                latitude: 35.702069,
                longitude: 139.775327
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Sydney, Australia",
                latitude: -33.863400,
                longitude: 151.211000
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Hong Kong, China",
                latitude: 22.284681,
                longitude: 114.158177
            )
        )
        // Indian Tier 1 Cities
        presetLocations.append(
            PresetLocation(
                title: "Delhi, India",
                latitude: 28.613939,
                longitude: 77.209021
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Bangalore, India",
                latitude: 12.971599,
                longitude: 77.594566
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Chennai, India",
                latitude: 13.082680,
                longitude: 80.270718
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Hyderabad, India",
                latitude: 17.385044,
                longitude: 78.486671
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Kolkata, India",
                latitude: 22.572646,
                longitude: 88.363895
            )
        )
        // Indian Tier 2 Cities
        presetLocations.append(
            PresetLocation(
                title: "Pune, India",
                latitude: 18.520430,
                longitude: 73.856744
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Ahmedabad, India",
                latitude: 23.022505,
                longitude: 72.571362
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Jaipur, India",
                latitude: 26.912434,
                longitude: 75.787270
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Lucknow, India",
                latitude: 26.846694,
                longitude: 80.946166
            )
        )
        presetLocations.append(
            PresetLocation(
                title: "Coimbatore, India",
                latitude: 11.016844,
                longitude: 76.955832
            )
        )

        return presetLocations
    }()
}

final class PresetLocation {
    var title: String
    var latitude: Double
    var longitude: Double

    init(title: String, latitude: Double, longitude: Double) {
        self.title = title
        self.latitude = latitude
        self.longitude = longitude
    }
}

extension LocationToolkit {
    enum Constants {
        static let simulatedLatitude = "_simulatedLocationLatitude"
        static let simulatedLongitude = "_simulatedLocationLongitude"
    }
}
