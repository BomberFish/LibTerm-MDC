//
//  unsandbox.swift
//  LibTerm
//
//  Created by Hariz Shirazi on 2023-04-15.
//

import Foundation

func unsandboxMain(_ argc: Int, argv: [String], io: LTIO) -> Int32 {
    var exitCode: Int32 = 0
    fputs("Unsandboxing...", stdout)
    grant_full_disk_access() {error in
        if error != nil {
            fputs("Unsandboxing Error: \(error!.localizedDescription)\nPlease close the app and retry. If the problem persists, reboot your device.", stderr)
            exitCode = 255
        } else {
            fputs("WE ARE UNSANDBOXED!", stdout)
        }
    }
    return exitCode
}
