import UIKit

//  Toolbar icons in the application are courtesy of Joseph Wain / glyphish.com
//  See the license file in the GlyphishIcons directory for more information on these icons

@UIApplicationMain

class iPhoneAppDelegate : NSObject, UIApplicationDelegate, UITabBarControllerDelegate
{

    @IBOutlet var window: UIWindow? = nil
    @IBOutlet var tabBarController: UITabBarController? = nil

    func applicationDidFinishLaunching(application: UIApplication?) {
        if let myWindow = self.window {
            myWindow.rootViewController = self.tabBarController
            myWindow.makeKeyAndVisible()
        }
    }
}
