import XCTest
import SnapshotTesting
@testable import Tracker

final class TrackerTests: XCTestCase {
    override func setUp() {
        super.setUp()
        //SnapshotTesting.isRecording = false
    }

    func testTrackersViewControllerAppearance_LightAndDark() {
        let trackersVC = TrackerController()
        trackersVC.loadViewIfNeeded()

        trackersVC.view.frame = CGRect(x: 0, y: 0, width: 430, height: 932)

        trackersVC.view.backgroundColor = .white
        assertSnapshot(of: trackersVC.view, as: .image, named: "Light")

        trackersVC.view.backgroundColor = .red
        assertSnapshot(of: trackersVC.view, as: .image, named: "Light_Modified")
    }
}
