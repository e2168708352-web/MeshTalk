import CoreBluetooth
import Testing
@testable import bitchat

struct ChatBluetoothAlertPolicyTests {
    @Test
    func poweredOffShowsAlertMessage() {
        let update = ChatBluetoothAlertPolicy.update(for: .poweredOff, authorization: .allowedAlways)

        #expect(update.isPresented)
        #expect(update.message?.isEmpty == false)
    }

    @Test
    func unauthorizedShowsAlertMessage() {
        let update = ChatBluetoothAlertPolicy.update(for: .unauthorized, authorization: .denied)

        #expect(update.isPresented)
        #expect(update.message?.isEmpty == false)
    }

    @Test
    func unauthorizedDistinguishesItsThreeCauses() {
        let denied = ChatBluetoothAlertPolicy.update(for: .unauthorized, authorization: .denied)
        let restricted = ChatBluetoothAlertPolicy.update(for: .unauthorized, authorization: .restricted)
        let alreadyAllowed = ChatBluetoothAlertPolicy.update(for: .unauthorized, authorization: .allowedAlways)

        // All three are presented, but they must not share wording: pointing a
        // user whose toggle is already on at the privacy pane is the bug this
        // policy exists to avoid.
        #expect(denied.isPresented)
        #expect(restricted.isPresented)
        #expect(alreadyAllowed.isPresented)
        #expect(denied.message != restricted.message)
        #expect(denied.message != alreadyAllowed.message)
        #expect(restricted.message != alreadyAllowed.message)
    }

    @Test
    func poweredOnHidesAndClearsAlertMessage() {
        let update = ChatBluetoothAlertPolicy.update(for: .poweredOn, authorization: .allowedAlways)

        #expect(!update.isPresented)
        #expect(update.message == "")
    }

    @Test
    func transientStatesHideWithoutChangingAlertMessage() {
        let unknown = ChatBluetoothAlertPolicy.update(for: .unknown, authorization: .notDetermined)
        let resetting = ChatBluetoothAlertPolicy.update(for: .resetting, authorization: .notDetermined)

        #expect(!unknown.isPresented)
        #expect(unknown.message == nil)
        #expect(!resetting.isPresented)
        #expect(resetting.message == nil)
    }
}
