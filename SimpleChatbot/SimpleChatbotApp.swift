import SwiftUI

@main
struct SimpleChatbotApp: App {

    @StateObject var callContainerModel: CallContainerModel
    @StateObject var cameraVM: CameraViewModel
    
    init() {
        let cameraVM: CameraViewModel = .init()
        _cameraVM = .init(wrappedValue: cameraVM)
        _callContainerModel = .init(wrappedValue: .init(cameraVM: cameraVM))
    }

    var body: some Scene {
        WindowGroup {
            Group {
                if (!callContainerModel.isInCall) {
                    PreJoinView().environmentObject(callContainerModel)
                } else {
                    MeetingView().environmentObject(callContainerModel)
                }
            }
            .environmentObject(cameraVM)
        }
    }

}
