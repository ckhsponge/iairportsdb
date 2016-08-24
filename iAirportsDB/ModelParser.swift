//
//  ModelParser.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/19/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData

class ModelParser {
    var fileName: String
    var modelType: IADBModel.Type
    
    init(fileName: String, modelType: IADBModel.Type) {
        self.fileName = fileName
        self.modelType = modelType
    }
    
    func go() {
        let parser = CsvParser(fileName: fileName)
        parser.parseLines { (line:[String : String]) in
            let context = self.persistence().managedObjectContext
            let entity = NSEntityDescription.entityForName(self.modelType.description(), inManagedObjectContext: context)
            let model:IADBModel = self.modelType.init(entity: entity!, insertIntoManagedObjectContext: nil)
            model.setCsvValues( line )
            context.insertObject(model)
        }
        do {
            try self.persistence().managedObjectContext.save()
        } catch {
            fatalError("Failure to save context: \(error)")
        }
        print("Saved! \(self.modelType.description()) \(self.modelType.countAll())")
    }
    
    func persistence() -> IADBPersistence {
        return IADBModel.persistence
    }
}
