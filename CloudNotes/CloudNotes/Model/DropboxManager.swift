import Foundation
import SwiftyDropbox

struct DropboxManager {
    func createFoloder() {
        guard let client1 = DropboxClientsManager.authorizedClient else {
            print("No client")
            return
        }
        let client2 = DropboxClient(accessToken: "N20J0VxwGrkAAAAAAAAAAS9-gog_7fDGQMGpspWccY5WdlNPwgx27b8lcK7qCxws")

        client1.files.createFolderV2(path: "/test/path/in/Dropbox/account").response { response, error in
            if let response = response {
                print(response)
            } else if let error = error {
                print(error)
            }
        }
    }
    
    func upload(data: Data) {
        guard let client = DropboxClientsManager.authorizedClient else {
            print("No client")
            return
        }
        let request = client.files.upload(path: "/test/path/in/Dropbox/account", input: data)
            .response { response, error in
                if let response = response {
                    print(response)
                } else if let error = error {
                    print(error)
                }
            }
            .progress { progressData in
                print(progressData)
            }

        // in case you want to cancel the request
//        if someConditionIsSatisfied {
//            request.cancel()
//        }
    }
    
    func download() {
        
    }
}
