
//import UIKit
//import HealthKit
//
//class MasterViewController: UIViewController {
//  
//  private let authorizeHealthKitSection = 2
//  
//  private func authorizeHealthKit() {
//    
//    HealthKitSetupAssistant.authorizeHealthKit { authorized, error in
//      
//      guard authorized else {
//        
//        let baseMessage = "HealthKit Authorization Failed"
//        
//        if let error = error {
//          print("\(baseMessage). Reason: \(error.localizedDescription)")
//        } else {
//          print(baseMessage)
//        }
//        return
//      }
//      print("HealthKit Successfully Authorized.")
//    }
//    
//  }
//}
