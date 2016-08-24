//
//  CsvParser.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/19/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import Foundation

class CsvParser: Parser, CHCSVParserDelegate {
    var columns = [String]()
    var lineDictionary = [String: String]()
    var fileName = ""
    var recordNumber: UInt = 0
    let parser:CHCSVParser
    var lineHandler: (([String: String]) -> Void) = { (_:[String : String]) in return }

    
    init(fileName: String) {
        self.fileName = fileName
        guard let url = NSBundle.mainBundle().URLForResource(fileName, withExtension: "csv") else {
            fatalError( "File not found for parsing: \(fileName).csv")
        }
        self.parser = CHCSVParser(contentsOfCSVURL: url)
        self.parser.trimsWhitespace = true
        self.parser.sanitizesFields = true
    }
    
    func parseLines(lineHandler: ([String: String]) -> Void) {
        self.lineHandler = lineHandler
        self.parser.delegate = self
        print("Starting parse: \(fileName)")
        self.parser.parse()
        print("Finished parse: \(fileName), lines: \(UInt(self.recordNumber))")
    }
    
    @objc func parser(parser: CHCSVParser!, didBeginLine recordNumber: UInt) {
        self.recordNumber = recordNumber
        if recordNumber % 1000 == 0 {
            print("line \(Int(recordNumber))")
        }
        if recordNumber > 1 {
            lineDictionary = [String: String]()
        }
        else {
            self.columns = [String]()
        }
    }
    
    @objc func parser(parser: CHCSVParser!, didReadField field: String!, atIndex fieldIndex: Int) {
        if recordNumber == 1 {
            if columns.contains(field) {
                print( "WARNING: duplicate column: \(field)" )
            }
            columns.append(field)
        }
        else {
            let column = (fieldIndex >= 0 && fieldIndex < columns.count) ? columns[fieldIndex] : String(fieldIndex)
            lineDictionary[ column ] = field
        }
    }
    
    @objc func parser(parser: CHCSVParser!, didEndLine recordNumber: UInt) {
        if recordNumber > 1 {
            self.lineHandler(lineDictionary)
        }
    }
    
}