import CoreBluetooth
import Foundation

struct ChatBluetoothAlertUpdate: Equatable {
    let isPresented: Bool
    let message: String?
}

enum ChatBluetoothAlertPolicy {
    /// Maps a radio state to the alert the UI should show.
    ///
    /// `authorization` is passed in rather than read from `CBManager` so the
    /// decision stays a pure function that tests can pin down. It matters
    /// because `.unauthorized` has three unrelated causes, and telling them
    /// apart is the difference between an actionable alert and one that sends
    /// the user to a toggle that is already on.
    static func update(
        for state: CBManagerState,
        authorization: CBManagerAuthorization
    ) -> ChatBluetoothAlertUpdate {
        switch state {
        case .poweredOff:
            ChatBluetoothAlertUpdate(
                isPresented: true,
                message: String(localized: "content.alert.bluetooth_required.off", comment: "Message shown when Bluetooth is turned off")
            )
        case .unauthorized:
            ChatBluetoothAlertUpdate(
                isPresented: true,
                message: unauthorizedMessage(for: authorization)
            )
        case .unsupported:
            ChatBluetoothAlertUpdate(
                isPresented: true,
                message: String(localized: "content.alert.bluetooth_required.unsupported", comment: "Message shown when the device lacks Bluetooth support")
            )
        case .poweredOn:
            ChatBluetoothAlertUpdate(isPresented: false, message: "")
        case .unknown, .resetting:
            ChatBluetoothAlertUpdate(isPresented: false, message: nil)
        @unknown default:
            ChatBluetoothAlertUpdate(isPresented: false, message: nil)
        }
    }

    private static func unauthorizedMessage(
        for authorization: CBManagerAuthorization
    ) -> String {
        switch authorization {
        case .restricted:
            // Screen Time or an MDM profile blocks Bluetooth device-wide, so no
            // in-app action can help and the privacy toggle will not stick.
            return String(
                localized: "content.alert.bluetooth_required.restricted",
                defaultValue: "Bluetooth is restricted by this device's Screen Time or device-management settings, so MeshTalk cannot request access. Ask whoever manages this device to allow Bluetooth.",
                comment: "Shown when device policy blocks Bluetooth for every app"
            )
        case .allowedAlways:
            // The system already granted access, yet the radio still refuses to
            // start. That is a stale grant bound to a previous install, so the
            // privacy toggle is not the fix and must not be suggested.
            return String(
                localized: "content.alert.bluetooth_required.stale_authorization",
                defaultValue: "Bluetooth access is already allowed for MeshTalk, but the Bluetooth service is not responding. Close and reopen the app; if that does not help, delete MeshTalk and install it again.",
                comment: "Shown when the system reports Bluetooth as allowed but the radio still refuses to start"
            )
        case .denied, .notDetermined:
            return String(localized: "content.alert.bluetooth_required.permission", comment: "Message shown when Bluetooth permission is missing")
        @unknown default:
            return String(localized: "content.alert.bluetooth_required.permission", comment: "Message shown when Bluetooth permission is missing")
        }
    }
}
