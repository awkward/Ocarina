//
//  OcarinaManagerDelegate.swift
//  Ocarina
//
//  Created by Rens Verhoeven on 26/02/2017.
//  Copyright © 2017 awkward. All rights reserved.
//

import Foundation
import Kanna

public protocol OcarinaManagerDelegate: class {
    
    func ocarinaManager(manager: OcarinaManager, doAdditionalParsingForInformation information: URLInformation, html: HTMLDocument?) -> URLInformation?
    
}

extension OcarinaManagerDelegate {
    
    func ocarinaManager(manager: OcarinaManager, doAdditionalParsingForInformation information: URLInformation, html: HTMLDocument?) -> URLInformation? {
        return information
    }
}
