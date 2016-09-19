//
//  ModelParser.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/19/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation
import CoreData
import iAirportsDB

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
            let (entityDescription, context) = self.modelType.entityDescriptionContext()
            let model:IADBModel = self.modelType.init(entity: entityDescription, insertInto: nil)
            model.setCsvValues( line )
            context.insert(model)
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
