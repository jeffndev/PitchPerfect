//
//  RecordedAudio.swift
//  Pitch Perfect
//
//  Created by Jeff Newell on 3/25/15.
//  Copyright (c) 2015 Jeff Newell. All rights reserved.
//

import Foundation

class RecordedAudio: NSObject {
    init(audioUrl:NSURL!, audioTitle:String!){
        filePathUrl = audioUrl
        title = audioTitle
    }
    var filePathUrl:NSURL!
    var title:String!
    
}
