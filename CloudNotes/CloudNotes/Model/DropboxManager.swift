import Foundation
import SwiftyDropbox
import CoreData

struct DropboxManager {
    static let basePath = "/test/path/in/Dropbox/account"
    static let sqliteFileNames = [
        "/CloudNotes.sqlite",
        "/CloudNotes.sqlite-shm",
        "/CloudNotes.sqlite-wal"
    ]
    static var index = 0
    
//    func createFoloder() {
//        guard let client1 = DropboxClientsManager.authorizedClient else {
//            print("No client")
//            return
//        }
//        let client2 = DropboxClient(accessToken: "N20J0VxwGrkAAAAAAAAAAS9-gog_7fDGQMGpspWccY5WdlNPwgx27b8lcK7qCxws")
//
//        client1.files.createFolderV2(path: Self.basePath).response { response, error in
//            if let response = response {
//                print(response)
//            } else if let error = error {
//                print(error)
//            }
//        }
//    }
    
    func upload() {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("No client")
            return
        }

        Self.sqliteFileNames.forEach {
            let coreDataPath = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent($0)
            let data = FileManager.default.contents(atPath: coreDataPath.path)!
            let request = client.files.upload(path: "\(Self.basePath)\($0)", input: data)
                .response { response, error in
                    if let response = response {
//                        print(response)
                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                }
        }
    }
    
    func download(completion: @escaping () -> Void) {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("No client")
            return
        }
        Self.sqliteFileNames.forEach {
            let coreDataPath = NSPersistentContainer.defaultDirectoryURL().appendingPathComponent($0)
            let destination: (URL, HTTPURLResponse) -> URL = { temporaryURL, response in
                return coreDataPath
            }
            client.files.download(path: "\(Self.basePath)\($0)", overwrite: true, destination: destination)
                .response(queue: .main) { response, error in
                    if let response = response {
//                        print(response)
                        completion()
                    } else if let error = error {
                        print(error)
                    }
                }
                .progress { progressData in
                    print(progressData)
                }
        }
//        completion()
    }
}
