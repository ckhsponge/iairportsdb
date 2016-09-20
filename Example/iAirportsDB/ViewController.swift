//
//  ViewController.swift
//  iAirportsDB
//
//  Created by Chris Hobbs on 08/24/2016.
//  Copyright (c) 2016 Chris Hobbs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let controller = IADBParseController()
    //        controller.downloadAndParse()
    //controller.parseAll()
    
    @IBOutlet var pathLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        pathLabel.text = IADBParseController.dbPath
    }
    
    @IBAction func downloadAndParse(_ sender: UIButton) {
        controller.downloadAll()
        controller.parseAll()
    }
    
    @IBAction func download(_ sender: UIButton) {
        controller.downloadAll()
    }
    
    @IBAction func parse(_ sender: UIButton) {
        controller.parseAll()
    }
    
    @IBAction func test(_ sender: UIButton) {
        controller.test()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    
}

