//
//  Mode.swift
//  HSTracker
//
//  Created by Benjamin Michotte on 27/02/16.
//  Copyright © 2016 Benjamin Michotte. All rights reserved.
//

import Foundation

// swiftlint:disable type_name

enum Mode: String {
    case invalid,
    startup,
    login,
    hub,
    gameplay,
    collectionmanager,
    packopening,
    tournament,
    friendly,
    fatal_error,
    draft,
    credits,
    reset,
    adventure,
    tavern_brawl
}
