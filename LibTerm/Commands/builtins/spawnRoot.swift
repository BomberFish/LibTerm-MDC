// bomberfish
// spawnRoot.swift – LibTerm
// created on 2023-12-01

import Foundation

func spawnRootMain(_ argc: Int, argv: [String], io: LTIO) -> Int32 {
    if argc < 3 {
        fputs("Usage: spawnRoot <path> [args]\n", stderr)
        return 1
    }
    let arguments = Array(argv.dropFirst()[2...]) as [Any]
    TrollStoreUtils.spawnAsRoot(argv.dropFirst()[1] as String, arguments)
    return 0
}
