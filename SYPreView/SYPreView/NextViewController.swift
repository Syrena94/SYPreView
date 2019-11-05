//
//  NextViewController.swift
//  SYPreView
//
//  Created by Syrena on 2019/11/5.
//  Copyright © 2019 Syrena. All rights reserved.
//

import UIKit
import SwifterSwift

class NextViewController: UIViewController {
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        self.navigationController?.navigationBar.shadowImage = UIImage.init(color: UIColor.red, size: CGSize.init(width: 2, height: 2))
        self.navigationController?.navigationBar.setBackgroundImage(UIImage.init(color: UIColor.red, size: CGSize.init(width: 2, height: 2)), for: .default)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = UIColor.white
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
