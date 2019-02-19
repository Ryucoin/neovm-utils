//
//  ViewController.swift
//  neovmUtilsExample
//
//  Created by Wyatt Mufson on 2/19/19.
//  Copyright © 2019 Ryu Blockchain Technologies. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    @IBOutlet weak var qrView: QRView!

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        qrView.backgroundColor = .red
        view.backgroundColor = .blue
    }

    @IBAction func generate(_ sender: Any) {
        let w = newWallet()
        qrView.generate(code: w.privateKeyString)
    }
    
}

