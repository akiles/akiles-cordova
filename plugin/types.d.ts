/**
 * Enum representing various error codes that can occur in the SDK.
 */

export enum ErrorCode {
    /**
     * Something went wrong internally. This should never happen, if you see it you can contact
     * Akiles for help.
     */
    INTERNAL = 'INTERNAL',

    /**
     * Invalid parameter. The `message` field contains extra information.
     */
    INVALID_PARAM = 'INVALID_PARAM',

    /**
     * The session token is invalid. Possible causes:
     * - The session token has an incorrect format.
     * - The organization administrator has uninstalled the application.
     * - The member has been deleted.
     * - The member token has been deleted.
     */
    INVALID_SESSION = 'INVALID_SESSION',

    /**
     * The current session does not have permission to do the requested action on the device.
     */
    PERMISSION_DENIED = 'PERMISSION_DENIED',

    /**
     * All communication methods (Internet, Bluetooth) have failed.
     *
     * Check the errors reported in `onInternetError` and `onBluetoothError` for information
     * on why each method failed.
     */
    ALL_COMM_METHODS_FAILED = 'ALL_COMM_METHODS_FAILED',

    /**
     * Phone has no internet access.
     */
    INTERNET_NOT_AVAILABLE = 'INTERNET_NOT_AVAILABLE',

    /**
     * Phone has internet access and could reach the Akiles server, but the Akiles server could
     * not reach the device because it's either offline or turned off.
     */
    INTERNET_DEVICE_OFFLINE = 'INTERNET_DEVICE_OFFLINE',

    /**
     * The organization administrator has enabled geolocation check for this device, and the
     * phone's location services indicate it's outside the maximum radius.
     *
     * This check only applies to actions via internet, since being able to do actions via Bluetooth
     * already guarantees you're near the device without need for geolocation checking.
     */
    INTERNET_LOCATION_OUT_OF_RADIUS = 'INTERNET_LOCATION_OUT_OF_RADIUS',

    /**
     * The organization administrator has configured this device so it doesn't accept actions via
     * the internet communication method. Other methods such as Bluetooth, PINs, cards, NFC might work.
     */
    INTERNET_NOT_PERMITTED = 'INTERNET_NOT_PERMITTED',

    /**
     * The device is not within Bluetooth range, or is turned off.
     */
    BLUETOOTH_DEVICE_NOT_FOUND = 'BLUETOOTH_DEVICE_NOT_FOUND',

    /**
     * The phone has bluetooth turned off, the user should enable it.
     */
    BLUETOOTH_DISABLED = 'BLUETOOTH_DISABLED',

    /**
     * The phone has no bluetooth support.
     */
    BLUETOOTH_NOT_AVAILABLE = 'BLUETOOTH_NOT_AVAILABLE',

    /**
     * The phone has bluetooth support, but the user hasn't granted permission for it to the app.
     */
    BLUETOOTH_PERMISSION_NOT_GRANTED = 'BLUETOOTH_PERMISSION_NOT_GRANTED',

    /**
     * The user hasn't granted Bluetooth permission to the app permanently.
     * You should show some UI directing the user to the "app info" section to grant it.
     */
    BLUETOOTH_PERMISSION_NOT_GRANTED_PERMANENTLY = 'BLUETOOTH_PERMISSION_NOT_GRANTED_PERMANENTLY',

    /**
     * Operation timed out.
     */
    TIMEOUT = 'TIMEOUT',

    /**
     * Operation has been canceled.
     */
    CANCELED = 'CANCELED',

    /**
     * This phone has no NFC support.
     */
    NFC_NOT_AVAILABLE = 'NFC_NOT_AVAILABLE',

    /**
     * NFC read error. The user either moved the card away too soon, or the card is not compatible.
     */
    NFC_READ_ERROR = 'NFC_READ_ERROR',

    /**
     * This NFC card is not compatible with Akiles devices.
     */
    NFC_CARD_NOT_COMPATIBLE = 'NFC_CARD_NOT_COMPATIBLE',

    /**
     * The phone has location turned off, the user should enable it.
     */
    LOCATION_DISABLED = 'LOCATION_DISABLED',

    /**
     * The phone has no location support.
     */
    LOCATION_NOT_AVAILABLE = 'LOCATION_NOT_AVAILABLE',

    /**
     * The phone has location support, but the user hasn't granted permission for it to the app.
     */
    LOCATION_PERMISSION_NOT_GRANTED = 'LOCATION_PERMISSION_NOT_GRANTED',

    /**
     * The user hasn't granted location permission to the app permanently.
     * You should show some UI directing the user to the "app info" section to grant it.
     */
    LOCATION_PERMISSION_NOT_GRANTED_PERMANENTLY = 'LOCATION_PERMISSION_NOT_GRANTED_PERMANENTLY',

    /**
     * The phone failed to acquire a GNSS fix in reasonable time, probably because it has bad coverage (it's indoors, etc).
     */
    LOCATION_FAILED = 'LOCATION_FAILED',
}

/**
 * Represents an error in the Akiles SDK.
 */
export class AkilesError extends Error {
    /** The error code. */
    code: ErrorCode;

    /**
     * Reason for permission denied errors. Only present if `code` is `PERMISSION_DENIED`.
     */
    reason?: PermissionDeniedReason;

    /**
     * Member start date, RFC3339 timestamp. Only present if `reason` is `MEMBER_NOT_STARTED`.
     */
    startsAt?: string;

    /**
     * Member end date, RFC3339 timestamp. Only present if `reason` is `MEMBER_ENDED`.
     */
    endsAt?: string;

    /**
     * Member's schedule. Only present if `reason` is `OUT_OF_SCHEDULE`.
     */
    schedule?: Schedule;

    /**
     * Time needed to wait to be in schedule, in seconds. Only present if `reason` is `OUT_OF_SCHEDULE`.
     */
    waitTime?: number;

    /**
     * Timezone the schedule is interpreted in. TZDB name, example `Europe/Madrid`. Only present if `reason` is `OUT_OF_SCHEDULE`.
     */
    timezone?: string;

    /**
     * Geolocation restriction of the site. Only present if `code` is `INTERNET_LOCATION_OUT_OF_RADIUS`.
     */
    siteGeo?: SiteGeo;

    /**
     * Actual distance to the site, in meters. Only present if `code` is `INTERNET_LOCATION_OUT_OF_RADIUS`.
     */
    distance?: number;

    constructor(code: ErrorCode, message: string);
}

/**
 * Enum representing reasons for permission denial.
 */
export enum PermissionDeniedReason {
    /** Other reason. */
    OTHER = 'OTHER',

    /** Current time is before member's start date. */
    MEMBER_NOT_STARTED = 'MEMBER_NOT_STARTED',

    /** Current time is after member's end date. */
    MEMBER_ENDED = 'MEMBER_ENDED',

    /** Current time is not inside the configured schedule. */
    OUT_OF_SCHEDULE = 'OUT_OF_SCHEDULE',

    /** The Akiles organization this device belongs to is disabled. */
    ORGANIZATION_DISABLED = 'ORGANIZATION_DISABLED',
}

/**
 * Represents a schedule with allowed time ranges for each day of the week.
 */
export interface Schedule {
    /** Array of 7 elements, one for each day of the week (Monday=0). */
    weekdays: ScheduleWeekday[];
}

/**
 * Represents a weekday in a schedule.
 */
export interface ScheduleWeekday {
    /** Array of allowed time ranges for this day, in seconds since midnight. */
    ranges: ScheduleRange[];
}

/**
 * Represents a time range in a schedule.
 */
export interface ScheduleRange {
    /** Start of the range, in seconds since midnight (inclusive). */
    start: number;

    /** End of the range, in seconds since midnight (exclusive). */
    end: number;
}

/**
 * Represents a geographic location.
 */
export interface Location {
    /** Latitude, in degrees. */
    lat: number;

    /** Longitude, in degrees. */
    lng: number;
}

/**
 * Represents geolocation restriction of a site.
 */
export interface SiteGeo {
    /** Location. */
    location: Location;

    /** Max radius, in meters. */
    radius: number;
}

/**
 * Represents an action that can be performed on a gadget.
 */
export interface GadgetAction {
    /** The ID of the action. */
    id: string;

    /** The name of the action. */
    name: string;
}

/**
 * Represents a gadget in the Akiles system.
 */
export interface Gadget {
    /** The ID of the gadget. */
    id: string;

    /** The name of the gadget. */
    name: string;

    /** Array of actions that can be performed on the gadget. */
    actions: GadgetAction[];
}

/**
 * Represents a hardware device in the Akiles system.
 */
export interface Hardware {
    /** The ID of the hardware. */
    id: string;

    /** The name of the hardware. */
    name: string;

    /** The product ID of the hardware. */
    productId: string;

    /** The revision ID of the hardware. */
    revisionId: string;

    /** Array of session IDs associated with the hardware. */
    sessions: string[];
}

/**
 * Represents a card scanned with the Akiles system.
 */
export interface Card {
    /** The UID of the card. */
    uid: string;

    /** Whether the card is an Akiles card. */
    isAkilesCard: boolean;

    /**
     * Update the data on the card with the Akiles server.
     *
     * @returns A promise that resolves when the update is complete.
     */
    update(): Promise<void>;

    /** Close the connection to the card. */
    close(): void;
}

/**
 * Enum representing the status of an action performed via the internet communication method.
 */
export enum ActionInternetStatus {
    /** The action is being executed. */
    EXECUTING_ACTION = 'EXECUTING_ACTION',

    /** The phone is acquiring the location. */
    ACQUIRING_LOCATION = 'ACQUIRING_LOCATION',

    /** The phone is waiting for the location to be within the allowed radius. */
    WAITING_FOR_LOCATION_IN_RADIUS = 'WAITING_FOR_LOCATION_IN_RADIUS',
}

/**
 * Enum representing the status of an action performed via the Bluetooth communication method.
 */
export enum ActionBluetoothStatus {
    /** The phone is scanning for the device. */
    SCANNING = 'SCANNING',

    /** The phone is connecting to the device. */
    CONNECTING = 'CONNECTING',

    /** The phone is syncing with the device. */
    SYNCING_DEVICE = 'SYNCING_DEVICE',

    /** The phone is syncing with the server. */
    SYNCING_SERVER = 'SYNCING_SERVER',

    /** The action is being executed. */
    EXECUTING_ACTION = 'EXECUTING_ACTION',
}

/**
 * Enum representing the status of a synchronization operation.
 */
export enum SyncStatus {
    /** The phone is scanning for the device. */
    SCANNING = 'SCANNING',

    /** The phone is connecting to the device. */
    CONNECTING = 'CONNECTING',

    /** The phone is syncing with the device. */
    SYNCING_DEVICE = 'SYNCING_DEVICE',

    /** The phone is syncing with the server. */
    SYNCING_SERVER = 'SYNCING_SERVER',
}

/**
 * Callback used by the `action` method.
 */
export interface ActionCallback {
    /** Called when the action operation succeeds. */
    onSuccess(): void;

    /** Called when the operation fails. */
    onError(e: AkilesError): void;

    /** Called when there's a status update for the internet method. */
    onInternetStatus?(status: ActionInternetStatus): void;

    /** Called when the operation succeeds via the internet method. */
    onInternetSuccess?(): void;

    /** Called when the operation fails via the internet method. */
    onInternetError?(e: AkilesError): void;

    /** Called when there's a status update for the Bluetooth method. */
    onBluetoothStatus?(status: ActionBluetoothStatus): void;

    /** Called when there's progress for the Bluetooth method. */
    onBluetoothStatusProgress?(percent: number): void;

    /** Called when the operation succeeds via the Bluetooth method. */
    onBluetoothSuccess?(): void;

    /** Called when the operation fails via the Bluetooth method. */
    onBluetoothError?(e: AkilesError): void;
}

/**
 * Callback used by the `scan` method.
 */
export interface ScanCallback {
    /** Called when a hardware is discovered by scanning. */
    onDiscover(hw: Hardware): void;

    /** Called when the operation succeeds. */
    onSuccess(): void;

    /** Called when the operation fails. */
    onError(e: AkilesError): void;
}

/**
 * Callback used by the `sync` method.
 */
export interface SyncCallback {
    /** Called when there's a status update for the Bluetooth method. */
    onStatus?(status: SyncStatus): void;

    /** Called when there's progress for the Bluetooth method. */
    onStatusProgress?(percent: number): void;

    /** Called when the operation succeeds. */
    onSuccess(): void;

    /** Called when the operation fails. */
    onError(e: AkilesError): void;
}

/**
 * Callback used by the `scanCard` method.
 */
export interface ScanCardCallback {
    /** Called when the card scan operation succeeds. */
    onSuccess(card: Card): void;

    /** Called when the card scan operation fails. */
    onError(e: AkilesError): void;
}

/**
 * Options used to configure the behavior of the `action` method.
 */
export interface ActionOptions {
    /**
     * Whether to request Bluetooth permission if needed.
     *
     * This controls the behavior when the app hasn't been granted Bluetooth permissions yet:
     * - If false, the Bluetooth communication method immediately errors with `BLUETOOTH_PERMISSION_NOT_GRANTED`.
     * - If true, the SDK will try to request the permission from the user and wait for a response. If granted,
     *   it carries on with the action. If not granted or it couldn't be requested, it errors with `BLUETOOTH_PERMISSION_NOT_GRANTED`.
     *   The permission can't be requested if the user has denied it twice, or if the `PermissionRequester` returns `false`.
     *
     * Default: `true`.
     */
    requestBluetoothPermission?: boolean;

    /**
     * Whether to request location permission if needed.
     *
     * This controls the behavior when the app hasn't been granted location permissions yet:
     * - If false, the internet communication method immediately errors with `LOCATION_PERMISSION_NOT_GRANTED`.
     * - If true, the SDK will try to request the permission from the user and wait for a response. If granted,
     *   it carries on with the action. If not granted or it couldn't be requested, it.errors with `LOCATION_PERMISSION_NOT_GRANTED`.
     *   The permission can't be requested if the user has denied it twice, or if the `PermissionRequester` returns `false`.
     *
     * Default: `true`.
     */
    requestLocationPermission?: boolean;

    /**
     * Whether to try using the internet communication method.
     *
     * If false, it immediately errors with `CANCELED`.
     *
     * Default: `true`.
     */
    useInternet?: boolean;

    /**
     * Whether to try using the Bluetooth communication method.
     *
     * If false, it immediately errors with `CANCELED`.
     *
     * Default: `true`.
     */
    useBluetooth?: boolean;
}

/**
 * Cordova global akiles object.
 */
export interface Akiles {
    /**
     * Get the IDs for all sessions in the session store.
     *
     * @returns A promise that resolves to an array with the IDs of all sessions.
     */
    getSessionIDs(): Promise<string[]>;

    /**
     * Get the version of the Akiles SDK.
     *
     * @returns A promise that resolves to the version string of the SDK.
     */
    getVersion(): Promise<string>;

    /**
     * Add a session to the session store.
     *
     * If the session store already contains the session, this is a noop.
     * This does a network call to the server to check the session token, and to cache the
     * session data into local storage.
     *
     * @param token - The session token.
     * @returns A promise that resolves to the session ID.
     */
    addSession(token: string): Promise<string>;

    /**
     * Remove a session from the session store.
     *
     * If there's no session in the store with the given ID, this is a noop.
     *
     * @param id - The session ID to remove.
     */
    removeSession(id: string): Promise<void>;

    /**
     * Removes all sessions from the session store.
     */
    removeAllSessions(): Promise<void>;

    /**
     * Refresh the cached session data.
     *
     * @param id - The session ID.
     */
    refreshSession(id: string): Promise<void>;

    /**
     * Refresh the cached session data for all sessions.
     */
    refreshAllSessions(): Promise<void>;

    /**
     * Get the gadgets for a session.
     *
     * @param sessionID - The session ID.
     * @returns A promise that resolves to an array with all the gadgets in the session.
     */
    getGadgets(sessionID: string): Promise<Gadget[]>;

    /**
     * Get a list of hardware accessible by this session.
     *
     * @param sessionID - The session ID.
     * @returns A promise that resolves to an array with all the hardware in the session.
     */
    getHardwares(sessionID: string): Promise<Hardware[]>;

    /**
     * Scan a card using NFC.
     *
     * The result will be notified via events:
     * - `scan_card_success`: { card: { uid, isAkilesCard } }
     * - `scan_card_error`: { error: { code, description } }
     *
     * @param callback - The callback that will be called on success or error.
     * @returns A function that cancels the ongoing scanCard operation.
     */
    scanCard(callback: ScanCardCallback): () => void;

    /**
     * Do an action on a gadget.
     *
     * This method tries to perform the action with both internet and Bluetooth communication methods,
     * possibly in parallel.
     *
     * The callback provides global success/error status, plus detailed status information for each
     * method. In particular, the sequence of callbacks is guaranteed to be:
     *
     * - For global status: exactly one of `onSuccess` or `onError`.
     * - For internet status: zero or more `onInternetStatus`, then exactly one of `onInternetSuccess` or `onInternetError`.
     * - For Bluetooth status: zero or more `onBluetoothStatus` or `onBluetoothStatusProgress`, then exactly one of `onBluetoothSuccess` or `onBluetoothError`.
     *
     * For Bluetooth, the SDK does some high-priority syncing before the action and some low-priority syncing after, so after the global `onSuccess` or `onError` is called you may still receive Bluetooth status updates. In this case, we recommend you show the success/failure to the user immediately to not make them wait, but still show a Bluetooth icon with a spinning indicator to convey there's still Bluetooth activity.
     *
     * @param sessionID - ID for the session to use.
     * @param gadgetID - Gadget ID, in the format "gad_3vms1xqucnus4ppfnl9h".
     * @param actionID - Action ID.
     * @param options - Options customizing the action.
     * @param callback - The callback that will be called on success or error.
     * @returns A function that cancels the ongoing action operation.
     */
    action(
        sessionID: string,
        gadgetID: string,
        actionID: string,
        options: ActionOptions | undefined | null,
        callback: ActionCallback
    ): () => void;

    /**
     * Scan using Bluetooth for nearby Akiles devices.
     *
     * The sequence of callbacks is guaranteed to be zero or more `onDiscover`, then exactly one of `onSuccess` or `onError`.
     *
     * @param callback - The callback that will be called on success or error.
     * @returns A function that cancels the ongoing scan operation.
     */
    scan(callback: ScanCallback): () => void;

    /**
     * Synchronize state of hardware.
     *
     * The sequence of callbacks is guaranteed to be zero or more `onStatus` or `onStatusProgress`, then exactly one of `onSuccess` or `onError`.
     *
     * @param sessionID - ID for the session to use.
     * @param hardwareID - Hardware ID, in the format "hw_3vms1xqucnus4ppfnl9h".
     * @param callback - The callback that will be called on success or error.
     * @returns A function that cancels the ongoing sync operation.
     */
    sync(
        sessionID: string,
        hardwareID: string,
        callback: SyncCallback
    ): () => void;

    /**
     * Returns whether Bluetooth is supported on this phone.
     *
     * This checks for the presence of Bluetooth LE hardware and requires Android 10 (API 29) or newer.
     *
     * @returns true if Bluetooth is supported, false otherwise.
     */
    isBluetoothSupported(): Promise<boolean>;

    /**
     * Returns whether card emulation is supported on this phone.
     *
     * This checks for the presence of NFC Host Card Emulation hardware.
     *
     * @returns true if card emulation is supported, false otherwise.
     */
    isCardEmulationSupported(): Promise<boolean>;

    /**
     * Returns whether secure NFC is supported on this phone.
     *
     * @returns true if card secure NFC is supported, false otherwise.
     */
    isSecureNFCSupported(): Promise<boolean>;

    /**
     * **iOS ONLY** - Start a card emulation session.
     * 
     * Do not call this on Android. Card emulation on Android works system-wide out of the
     * box, the only requirements is your app is installed and the session has been added.
     * The user doesn't even have to open the app.
     */
    startCardEmulation(): Promise<void>;
}


declare global {
    interface Window {
        akiles: Akiles
    }
}
