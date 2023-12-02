// bomberfish
// overwriteMDC.swift – LibTerm
// created on 2023-12-01

import Foundation

func overwriteMain(_ argc: Int, argv: [String], io: LTIO) -> Int32 {
    func overwriteFileWithDataImpl(originPath: String, replacementData: Data, unlockDataAtEnd: Bool = true) throws {
    #if false
        let documentDirectory = FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask
        )[0].path
        
        let pathToRealTarget = originPath
        let originPath = documentDirectory + originPath
        let origData = try! Data(contentsOf: URL(fileURLWithPath: pathToRealTarget))
        try! origData.write(to: URL(fileURLWithPath: originPath))
    #endif
        
        // open and map original font
        let fd = open(originPath, O_RDONLY | O_CLOEXEC)
        if fd == -1 {
            print("Could not open target file")
            throw("Could not open target file")
        }
        defer { close(fd) }
        // check size of font
        let originalFileSize = lseek(fd, 0, SEEK_END)
        guard originalFileSize >= replacementData.count else {
            print("Original file: \(originalFileSize)")
            print("Replacement file: \(replacementData.count)")
            print("File too big")
            throw "File too big!\nOriginal file: \(originalFileSize)\nReplacement file: \(replacementData.count)"
        }
        lseek(fd, 0, SEEK_SET)
        
        // Map the font we want to overwrite so we can mlock it
        let fileMap = mmap(nil, replacementData.count, PROT_READ, MAP_SHARED, fd, 0)
        if fileMap == MAP_FAILED {
            print("Failed to map")
            throw "Failed to map"
        }
        // mlock so the file gets cached in memory
        guard mlock(fileMap, replacementData.count) == 0 else {
            print("Failed to mlock")
            throw "Failed to mlock"
        }
        
        // for every 16k chunk, rewrite
        print(Date())
        for chunkOff in stride(from: 0, to: replacementData.count, by: 0x4000) {
    //        print(String(format: "%lx", chunkOff))
            let dataChunk = replacementData[chunkOff..<min(replacementData.count, chunkOff + 0x4000)]
            var overwroteOne = false
            for _ in 0..<2 {
                let overwriteSucceeded = dataChunk.withUnsafeBytes { dataChunkBytes in
                    return unaligned_copy_switch_race(
                        fd, Int64(chunkOff), dataChunkBytes.baseAddress, dataChunkBytes.count, unlockDataAtEnd)
                }
                if overwriteSucceeded {
                    overwroteOne = true
                    break
                }
                print("try again?!")
            }
            guard overwroteOne else {
                print("Failed to overwrite")
                throw "Failed to overwrite"
            }
        }
        print(Date())
        
        if unlockDataAtEnd {
            guard munlock(fileMap, replacementData.count) == 0 else {
                print("Failed to munlock")
                return
            }
        }
    }

    
    do {
        if argc < 3 || argc > 4 {
            fputs("Usage: overwrite <path> <data>\n", stderr)
            return 1
        }
        fputs("Overwriting file...", stdin)
        let args = Array(argv.dropFirst())
        if !FileManager.default.fileExists(atPath: args[2]) || !FileManager.default.fileExists(atPath: args[3]) {
            throw "Invalid arguments. Both arguments should be valid paths."
        }
        try overwriteFileWithDataImpl(originPath: args[2], replacementData: .init(contentsOf: .init(fileURLWithPath: args[3])), unlockDataAtEnd: false)
        fputs("Sucessfully overwritten!", stdin)
        return 0
    } catch {
        fputs("Error: \(error.localizedDescription)", stderr)
        return 1
    }
}
