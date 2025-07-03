'use strict';

// Promisified helpers for Cordova exec
function execPromise(action, args = []) {
    return new Promise((resolve, reject) => {
        cordova.exec(resolve, function (err) { reject(toAkilesError(err)); }, 'AKILES', action, args);
    });
}

class AkilesError extends Error {
    constructor(code, message) {
        super(message);
        this.name = 'AkilesError';
        this.code = code;
    }
}

function toAkilesError(err) {
    if (err && err.code) {
        const e = new AkilesError(
            err.code,
            err.description || err.message || String(err)
        );

        if (err.reason) e.reason = err.reason;
        if (err.startsAt) e.startsAt = err.startsAt;
        if (err.endsAt) e.endsAt = err.endsAt;
        if (err.schedule) e.schedule = err.schedule;
        if (err.waitTime) e.waitTime = err.waitTime;
        if (err.timezone) e.timezone = err.timezone;
        if (err.siteGeo) e.siteGeo = err.siteGeo;
        if (err.distance !== undefined) e.distance = err.distance;

        return e;
    }
    if (typeof err === 'string') {
        return new AkilesError('INTERNAL', err);
    }
    return new AkilesError('INTERNAL', err && err.message ? err.message : String(err));
}

function generateOpId() {
    const timestamp = Date.now(); // Current timestamp in milliseconds.
    const randomPart = Math.floor(Math.random() * 1000000); // Random number up to 6 digits.
    return `${timestamp}-${randomPart}`; // Combine timestamp and random part.
}

function cancelFunc(opId) {
    return function () {
        cordova.exec(null, null, 'AKILES', 'cancel', [opId]);
    }
}

module.exports = {
    getSessionIDs: function () {
        return execPromise('get_session_ids');
    },
    getVersion: function () {
        return execPromise('get_version');
    },
    getClientInfo: function () {
        return execPromise('get_client_info');
    },
    addSession: function (token) {
        return execPromise('add_session', [token]);
    },
    removeSession: function (id) {
        return execPromise('remove_session', [id]);
    },
    removeAllSessions: function () {
        return execPromise('remove_all_sessions');
    },
    refreshSession: function (id) {
        return execPromise('refresh_session', [id]);
    },
    refreshAllSessions: function () {
        return execPromise('refresh_all_sessions');
    },
    getGadgets: function (sessionID) {
        return execPromise('get_gadgets', [sessionID]);
    },
    getHardwares: function (sessionID) {
        return execPromise('get_hardwares', [sessionID]);
    },
    action: function (sessionID, gadgetID, actionID, options, callback) {
        const opId = generateOpId();
        cordova.exec(
            function (result) {
                if (result && result.type) {
                    switch (result.type) {
                        case 'success':
                            callback.onSuccess && callback.onSuccess();
                            break;
                        case 'error':
                            callback.onError && callback.onError(toAkilesError(result.error));
                            break;
                        case 'internet_status':
                            callback.onInternetStatus && callback.onInternetStatus(result.status);
                            break;
                        case 'internet_success':
                            callback.onInternetSuccess && callback.onInternetSuccess();
                            break;
                        case 'internet_error':
                            callback.onInternetError && callback.onInternetError(toAkilesError(result.error));
                            break;
                        case 'bluetooth_status':
                            callback.onBluetoothStatus && callback.onBluetoothStatus(result.status);
                            break;
                        case 'bluetooth_status_progress':
                            callback.onBluetoothStatusProgress && callback.onBluetoothStatusProgress(result.percent);
                            break;
                        case 'bluetooth_success':
                            callback.onBluetoothSuccess && callback.onBluetoothSuccess();
                            break;
                        case 'bluetooth_error':
                            callback.onBluetoothError && callback.onBluetoothError(toAkilesError(result.error));
                            break;
                    }
                }
            },
            function (err) {
                callback.onError && callback.onError(toAkilesError(err));
            },
            'AKILES',
            'action',
            [opId, sessionID, gadgetID, actionID, options]
        );
        return cancelFunc(opId);
    },
    scan: function (callback) {
        const opId = generateOpId();
        cordova.exec(
            function (result) {
                if (result && result.type) {
                    switch (result.type) {
                        case 'discover':
                            callback.onDiscover && callback.onDiscover(result.hardware);
                            break;
                        case 'success':
                            callback.onSuccess && callback.onSuccess();
                            break;
                        case 'error':
                            callback.onError && callback.onError(toAkilesError(result.error));
                            break;
                    }
                }
            },
            function (err) {
                callback.onError && callback.onError(toAkilesError(err));
            },
            'AKILES',
            'scan',
            [opId]
        );
        return cancelFunc(opId);
    },
    sync: function (sessionID, hardwareID, callback) {
        const opId = generateOpId();
        cordova.exec(
            function (result) {
                if (result && result.type) {
                    switch (result.type) {
                        case 'status':
                            callback.onStatus && callback.onStatus(result.status);
                            break;
                        case 'status_progress':
                            callback.onStatusProgress && callback.onStatusProgress(result.percent);
                            break;
                        case 'success':
                            callback.onSuccess && callback.onSuccess();
                            break;
                        case 'error':
                            callback.onError && callback.onError(toAkilesError(result.error));
                            break;
                    }
                }
            },
            function (err) {
                callback.onError && callback.onError(toAkilesError(err));
            },
            'AKILES',
            'sync',
            [opId, sessionID, hardwareID]
        );
        return cancelFunc(opId);
    },
    scanCard: function (callback) {
        const opId = generateOpId();
        cordova.exec(
            function (card) {
                callback.onSuccess && callback.onSuccess({
                    ...card,
                    update: function () {
                        return execPromise('update_card', [card.uid]);
                    },
                    close: function () {
                        // No return value, fire and forget
                        execPromise('close_card', [card.uid]);
                    }
                });
            },
            function (err) {
                callback.onError && callback.onError(toAkilesError(err));
            },
            'AKILES',
            'scan_card',
            [opId]
        );
        return cancelFunc(opId);
    },
    isBluetoothSupported: function () {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'AKILES', 'is_bluetooth_supported', []);
        });
    },
    isCardEmulationSupported: function () {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'AKILES', 'is_card_emulation_supported', []);
        });
    },
    isSecureNFCSupported: function () {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'AKILES', 'is_secure_nfc_supported', []);
        });
    },
    /* IOS ONLY */
    startCardEmulation: function (language) {
        return new Promise((resolve, reject) => {
            cordova.exec(resolve, reject, 'AKILES', 'start_card_emulation', [language]);
        });
    },
    AkilesError,
};
