//
//  LocalhostSplitClient.swift
//  Split
//
//  Created by Javier L. Avrudsky on 14/02/2019.
//  Copyright © 2019 Split. All rights reserved.
//

import Foundation

///
/// Split Client protocol implementation for Locahost mode
/// This mode is intended to use for development purposes.
///
/// This implementation loads a local file called localhost.splits
/// which has the follwing line format: SPLIT TREATMENT
/// Also you can include comments to the file starting a line with the # character
///
/// - Example: A simple `localhost.splits` file
/// `# This line is a comment`\
/// `# Following line has split = FEATURE_ONE and treatment = ON`\
/// `FEATURE_ONE ON`\
/// `FEATURE_TWO OFF`\
/// `# Previous line has split = FEATURE_TWO, treatment = OFF`\
///
///
/// If a file called **localhost.splits** is included into the project bundle,
/// it will be used as initial file. It will be copied to the cache folder, then
/// it can be edited while app is running to simulate split changes.
/// When no `localhost.splits` is added to the app bundle, an empty file will be
/// created in cache folder.
/// Enable debug mode, the **localhost.splits** file location will be logged
/// to the console so that is possible to open it with a text editor when working
/// on the simulator.
/// When using the device to run the app, the file can be modified by
/// overwritting the app's bundle from the **Device and Simulators** tool.
///
///
/// For more information
///  - seealso:
/// [Split iOS SDK](https://docs.split.io/docs/ios-sdk-overview#section-localhost)
///

public final class LocalhostSplitClient: NSObject, SplitClient {

    private let treatmentFetcher: TreatmentFetcher
    private let eventsManager: SplitEventsManager?
    
    init(treatmentFetcher: TreatmentFetcher, eventsManager: SplitEventsManager? = nil) {
        self.treatmentFetcher = treatmentFetcher
        self.eventsManager = eventsManager
    }
    
    public func getTreatment(_ split: String, attributes: [String : Any]?) -> String {
        return treatmentFetcher.fetch(splitName: split) ?? SplitConstants.CONTROL
    }
    
    public func getTreatment(_ split: String) -> String {
        return getTreatment(_: split, attributes: nil)
    }
    
    public func getTreatments(splits: [String], attributes: [String : Any]?) -> [String : String] {
        let treatments = treatmentFetcher.fetchAll()
        var results = [String : String]()
        for split in splits {
            results[split] = treatments?[split] ?? SplitConstants.CONTROL
        }
        return results
    }
    
    public func getTreatmentWithConfig(_ split: String) -> SplitResult {
        return getTreatmentWithConfig(split, attributes: nil)
    }
    
    public func getTreatmentWithConfig(_ split: String, attributes: [String : Any]?) -> SplitResult {
        return SplitResult(treatment: getTreatment(split), configurations: nil)
    }
    
    public func getTreatmentsWithConfig(splits: [String], attributes: [String : Any]?) -> [String : SplitResult] {
        return getTreatments(splits: splits, attributes: attributes).mapValues( { SplitResult(treatment: $0, configurations: nil) } )
    }
    
    public func on(_ event: SplitEvent, _ task: SplitEventTask) {
    }
    
    public func on(event: SplitEvent, execute action: @escaping SplitAction) {
        if let eventsManager = self.eventsManager {
            let task = SplitEventActionTask(action: action)
            eventsManager.register(event: event, task: task)
        }
    }
    
    public func track(trafficType: String, eventType: String) -> Bool {
        return true
    }
    
    public func track(trafficType: String, eventType: String, value: Double) -> Bool {
        return true
    }
    
    public func track(eventType: String) -> Bool {
        return true
    }
    
    public func track(eventType: String, value: Double) -> Bool {
        return true
    }
    
    
}
