//
//  ViewController.swift
//  iAirportsDB
//
//  Created by Christopher Hobbs on 8/17/16.
//  Copyright © 2016 Toonsy Net. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    let controller = IADBParseController()
    //        controller.downloadAndParse()
    //controller.parseAll()

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    @IBAction func downloadAndParse(sender: UIButton) {
        controller.downloadAll()
        controller.parseAll()
    }
    
    @IBAction func download(sender: UIButton) {
        controller.downloadAll()
    }
    
    @IBAction func parse(sender: UIButton) {
        controller.parseAll()
    }
    
    @IBAction func test(sender: UIButton) {
        controller.test()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

