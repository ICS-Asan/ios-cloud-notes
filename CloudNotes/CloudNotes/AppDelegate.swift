import UIKit
import CoreData
import SwiftyDropbox

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        DropboxClientsManager.setupWithAppKey("04sxf8v47v0yzo2")
        return true
    }

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        let oauthCompletion: DropboxOAuthCompletion = {
          if let authResult = $0 {
              switch authResult {
              case .success:
                  print("Success! User is logged into DropboxClientsManager.")
              case .cancel:
                  print("Authorization flow was manually canceled by user!")
              case .error(_, let description):
                  print("Error: \(String(describing: description))")
              }
          }
        }
        let canHandleUrl = DropboxClientsManager.handleRedirectURL(url, completion: oauthCompletion)
        return canHandleUrl
    }
}

