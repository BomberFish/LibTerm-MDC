//
//  unsandbox.swift
//  LibTerm
//
//  Created by Hariz Shirazi on 2023-04-15.
//  Copyright © 2023 Adrian Labbe. All rights reserved.
//

import Foundation
import MacDirtyCow

func unsandboxMain(_ argc: Int, argv: [String], io: LTIO) -> Int32 {
    fputs("Unsandboxing...", stdout)
    do {
        try MacDirtyCow.unsandbox()
        fputs("Should be unsandboxed!", stdout)
        return 0
    } catch {
        fputs("Error while unsandboxing: \(error.localizedDescription)", stderr)
        return 1
    }
}
