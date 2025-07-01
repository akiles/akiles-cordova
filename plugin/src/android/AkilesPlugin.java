package app.akiles.cordova;

import android.app.Activity;
import android.nfc.NfcAdapter;
import android.os.Build;
import android.util.Log;

import androidx.annotation.NonNull;

import org.apache.cordova.CallbackContext;
import org.apache.cordova.CordovaArgs;
import org.apache.cordova.CordovaPlugin;
import org.apache.cordova.PluginResult;
import org.apache.cordova.LOG;
import org.json.JSONArray;
import org.json.JSONException;
import org.json.JSONObject;

import app.akiles.sdk.Akiles;
import app.akiles.sdk.AkilesException;
import app.akiles.sdk.Cancel;
import app.akiles.sdk.Gadget;
import app.akiles.sdk.Hardware;
import app.akiles.sdk.Card;
import app.akiles.sdk.ActionOptions;
import app.akiles.sdk.Schedule;

import java.util.Arrays;
import java.util.concurrent.ConcurrentHashMap;

public class AkilesPlugin extends CordovaPlugin {
    private static final String TAG = "AkilesPlugin";

    private Akiles ak;
    private Card card;
    private final ConcurrentHashMap<String, Cancel> cancelTokens = new ConcurrentHashMap<>();

    @Override
    protected void pluginInitialize() {
        Activity activity = cordova.getActivity();
        ak = new Akiles(activity);
        ak.setPermissionRequester((permissions, requestCode) -> {
            LOG.i(TAG, "requestPermissions", requestCode);
            cordova.requestPermissions(AkilesPlugin.this, requestCode, permissions);
            return true;
        });
    }

    // Cordova says this is deprecated and to use onRequestPermissionResult instead,
    // but it seems it calls this method and not the new one.
    // This makes no sense.
    @Override
    public void onRequestPermissionResult(int requestCode, String[] permissions, @NonNull int[] grantResults) {
        onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public void onRequestPermissionsResult(int requestCode, String[] permissions, @NonNull int[] grantResults) {
        LOG.i(TAG, "onRequestPermissionsResult", requestCode);
        ak.onRequestPermissionsResult(requestCode, permissions, grantResults);
    }

    @Override
    public boolean execute(String action, CordovaArgs args, CallbackContext callbackContext) throws JSONException {
        String opId;
        switch (action) {
            case "get_session_ids":
                getSessionIDs(callbackContext);
                return true;
            case "add_session":
                String token = args.getString(0);
                addSession(callbackContext, token);
                return true;
            case "remove_session":
                String sessionID = args.getString(0);
                removeSession(callbackContext, sessionID);
                return true;
            case "remove_all_sessions":
                removeAllSessions(callbackContext);
                return true;
            case "refresh_session":
                sessionID = args.getString(0);
                refreshSession(callbackContext, sessionID);
                return true;
            case "refresh_all_sessions":
                refreshAllSessions(callbackContext);
                return true;
            case "get_gadgets":
                sessionID = args.getString(0);
                getGadgets(callbackContext, sessionID);
                return true;
            case "action":
                opId = args.getString(0);
                sessionID = args.getString(1);
                String gadgetID = args.getString(2);
                String actionID = args.getString(3);
                JSONObject optionsJson = args.optJSONObject(4);
                action(opId, callbackContext, sessionID, gadgetID, actionID, optionsJson);
                return true;
            case "scan":
                opId = args.getString(0);
                scan(opId, callbackContext);
                return true;
            case "sync":
                opId = args.getString(0);
                sessionID = args.getString(1);
                String hardwareID = args.getString(2);
                sync(opId, callbackContext, sessionID, hardwareID);
                return true;
            case "scan_card":
                opId = args.getString(0);
                scanCard(opId, callbackContext);
                return true;
            case "update_card":
                updateCard(callbackContext);
                return true;
            case "close_card":
                closeCard(callbackContext);
                return true;
            case "cancel":
                opId = args.getString(0);
                cancel(opId, callbackContext);
                return true;
            case "is_bluetooth_supported":
                callbackContext.success(ak.isBluetoothSupported() ? 1 : 0);
                return true;
            case "is_secure_nfc_supported":
                try {
                    if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.Q) {
                        NfcAdapter nfcAdapter = NfcAdapter.getDefaultAdapter(cordova.getActivity());
                        boolean isSupported = nfcAdapter != null && nfcAdapter.isSecureNfcSupported() && nfcAdapter.isSecureNfcEnabled();
                        callbackContext.success(isSupported ? 1 : 0);
                    } else {
                        callbackContext.success(0);
                    }
                } catch (Exception e) {
                    callbackContext.error("Error checking secure NFC availability: " + e.getMessage());
                }
                return true;
            case "is_card_emulation_supported":
                callbackContext.success(ak.isCardEmulationSupported() ? 1 : 0);
                return true;
            default:
                return false;
        }
    }

    private void getSessionIDs(CallbackContext callbackContext) {
        try {
            String[] sessionIDs = ak.getSessionIDs();
            JSONArray result = new JSONArray(Arrays.asList(sessionIDs));
            callbackContext.success(result);
        } catch (AkilesException e) {
            LOG.e(TAG, "Error getting session IDs", e);
            callbackContext.error(akilesExceptionToJson(e));
        }
    }

    private void addSession(CallbackContext callbackContext, String token) {
        ak.addSession(token, new app.akiles.sdk.Callback<String>() {
            @Override
            public void onSuccess(String sessionID) {
                callbackContext.success(sessionID);
            }

            @Override
            public void onError(AkilesException e) {
                LOG.e(TAG, "Error adding session", e);
                callbackContext.error(akilesExceptionToJson(e));
            }
        });
    }

    private void removeSession(CallbackContext callbackContext, String sessionID) {
        try {
            ak.removeSession(sessionID);
            callbackContext.success();
        } catch (AkilesException e) {
            LOG.e(TAG, "Error removing session", e);
            callbackContext.error(akilesExceptionToJson(e));
        }
    }

    private void removeAllSessions(CallbackContext callbackContext) {
        try {
            ak.removeAllSessions();
            callbackContext.success();
        } catch (AkilesException e) {
            LOG.e(TAG, "Error removing all sessions", e);
            callbackContext.error(akilesExceptionToJson(e));
        }
    }

    private void refreshSession(CallbackContext callbackContext, String sessionID) {
        ak.refreshSession(sessionID, new app.akiles.sdk.Callback<Void>() {
            @Override
            public void onSuccess(Void unused) {
                callbackContext.success();
            }

            @Override
            public void onError(AkilesException e) {
                LOG.e(TAG, "Error refreshing session", e);
                callbackContext.error(akilesExceptionToJson(e));
            }
        });
    }

    private void refreshAllSessions(CallbackContext callbackContext) {
        ak.refreshAllSessions(new app.akiles.sdk.Callback<Void>() {
            @Override
            public void onSuccess(Void unused) {
                callbackContext.success();
            }

            @Override
            public void onError(AkilesException e) {
                LOG.e(TAG, "Error refreshing all sessions", e);
                callbackContext.error(akilesExceptionToJson(e));
            }
        });
    }

    private void getGadgets(CallbackContext callbackContext, String sessionID) {
        Gadget[] gadgets;
        try {
            gadgets = ak.getGadgets(sessionID);
        } catch (AkilesException e) {
            LOG.e(TAG, "Error getting gadgets", e);
            callbackContext.error(akilesExceptionToJson(e));
            return;
        }
        try {
            JSONArray result = new JSONArray();
            for (Gadget gadget : gadgets) {
                JSONObject obj = new JSONObject();
                obj.put("id", gadget.id);
                obj.put("name", gadget.name);
                JSONArray actions = new JSONArray();
                if (gadget.actions != null) {
                    for (app.akiles.sdk.GadgetAction action : gadget.actions) {
                        JSONObject actionObj = new JSONObject();
                        actionObj.put("id", action.id);
                        actionObj.put("name", action.name);
                        actions.put(actionObj);
                    }
                }
                obj.put("actions", actions);
                result.put(obj);
            }
            callbackContext.success(result);
        } catch (JSONException e) {
            LOG.e(TAG, "Error encoding gadgets", e);
            callbackContext.error("Error encoding gadgets: " + e.getMessage());
        }
    }

    private void getHardwares(CallbackContext callbackContext, String sessionID) {
        Hardware[] hardwares;
        try {
            hardwares = ak.getHardwares(sessionID);
        } catch (AkilesException e) {
            LOG.e(TAG, "Error getting hardwares", e);
            callbackContext.error(akilesExceptionToJson(e));
            return;
        }
        try {
            JSONArray result = new JSONArray();
            for (Hardware hw : hardwares) {
                JSONObject obj = new JSONObject();
                obj.put("id", hw.id);
                obj.put("name", hw.name);
                obj.put("productId", hw.productId);
                obj.put("revisionId", hw.revisionId);
                JSONArray sessions = new JSONArray();
                if (hw.sessions != null) {
                    for (String s : hw.sessions) {
                        sessions.put(s);
                    }
                }
                obj.put("sessions", sessions);
                result.put(obj);
            }
            callbackContext.success(result);
        } catch (JSONException e) {
            LOG.e(TAG, "Error encoding hardwares", e);
            callbackContext.error("Error encoding hardwares: " + e.getMessage());
        }
    }

    private void action(String opId, CallbackContext callbackContext, String sessionID, String gadgetID, String actionID, JSONObject optionsJson) {
        ActionOptions options = new ActionOptions();
          try {
            if (optionsJson != null) {
                if (optionsJson.has("requestBluetoothPermission")) {
                    options.requestBluetoothPermission = optionsJson.getBoolean("requestBluetoothPermission");
                }
                if (optionsJson.has("requestLocationPermission")) {
                    options.requestLocationPermission = optionsJson.getBoolean("requestLocationPermission");
                }
                if (optionsJson.has("useInternet")) {
                    options.useInternet = optionsJson.getBoolean("useInternet");
                }
                if (optionsJson.has("useBluetooth")) {
                    options.useBluetooth = optionsJson.getBoolean("useBluetooth");
                }
            }
        } catch (JSONException e) {
            LOG.e(TAG, "JSONException", e);
            callbackContext.error(e.getMessage());
            return;
        }

        // Track completion of global, internet, and bluetooth
        class ActionCompletion {
            boolean globalDone = false;
            boolean internetDone = false;
            boolean bluetoothDone = false;

            void tryFinish() {
                if (globalDone && internetDone && bluetoothDone) {
                    // All done, release callback
                    PluginResult pluginResult = new PluginResult(PluginResult.Status.NO_RESULT);
                    pluginResult.setKeepCallback(false);
                    callbackContext.sendPluginResult(pluginResult);
                }
            }
        }
        ActionCompletion completion = new ActionCompletion();
        Cancel cancel = ak.action(sessionID, gadgetID, actionID, options, new app.akiles.sdk.ActionCallback() {
            @Override
            public void onSuccess() {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "success");
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "JSONException", e);
                    callbackContext.error(e.getMessage());
                }
                completion.globalDone = true;
                completion.tryFinish();
            }

            @Override
            public void onError(AkilesException ex) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "error");
                    event.put("error", akilesExceptionToJson(ex));
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "JSONException", e);
                    callbackContext.error(e.getMessage());
                }
                completion.globalDone = true;
                completion.tryFinish();
            }

            @Override
            public void onInternetStatus(app.akiles.sdk.ActionInternetStatus status) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "internet_status");
                    event.put("status", status.toString());
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action internet_status event", e);
                }
            }

            @Override
            public void onInternetSuccess() {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "internet_success");
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action internet_success event", e);
                }
                completion.internetDone = true;
                completion.tryFinish();
            }

            @Override
            public void onInternetError(AkilesException ex) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "internet_error");
                    event.put("error", akilesExceptionToJson(ex));
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action internet_error event", e);
                }
                completion.internetDone = true;
                completion.tryFinish();
            }

            @Override
            public void onBluetoothStatus(app.akiles.sdk.ActionBluetoothStatus status) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "bluetooth_status");
                    event.put("status", status.toString());
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action bluetooth_status event", e);
                }
            }

            @Override
            public void onBluetoothStatusProgress(float percent) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "bluetooth_status_progress");
                    event.put("percent", percent);
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action bluetooth_status_progress event", e);
                }
            }

            @Override
            public void onBluetoothSuccess() {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "bluetooth_success");
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action bluetooth_success event", e);
                }
                completion.bluetoothDone = true;
                completion.tryFinish();
            }

            @Override
            public void onBluetoothError(AkilesException ex) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "bluetooth_error");
                    event.put("error", akilesExceptionToJson(ex));
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending action bluetooth_error event", e);
                }
                completion.bluetoothDone = true;
                completion.tryFinish();
            }
        });
        cancelTokens.put(opId, cancel);
    }

    private void scan(String opId, CallbackContext callbackContext) {
        Cancel cancel = ak.scan(new app.akiles.sdk.ScanCallback() {
            @Override
            public void onDiscover(Hardware hw) {
                JSONObject object = new JSONObject();
                try {
                    object.put("id", hw.id);
                    object.put("name", hw.name);
                    object.put("productId", hw.productId);
                    object.put("revisionId", hw.revisionId);
                    JSONArray sessions = new JSONArray();
                    if (hw.sessions != null) {
                        for (String s : hw.sessions) {
                            sessions.put(s);
                        }
                    }
                    object.put("sessions", sessions);
                    JSONObject event = new JSONObject();
                    event.put("type", "discover");
                    event.put("hardware", object);
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    Log.w(TAG, "scan failed to encode hardware (ignored)", e);
                }
            }

            @Override
            public void onSuccess() {
                cancelTokens.remove(opId);
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "success");
                    sendFinalEvent(callbackContext, event);
                } catch (JSONException e) {
                    Log.w(TAG, "scan success event error (ignored)", e);
                }
            }

            @Override
            public void onError(AkilesException ex) {
                cancelTokens.remove(opId);
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "error");
                    event.put("error", akilesExceptionToJson(ex));
                    sendFinalEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "JSONException", e);
                    callbackContext.error(e.getMessage());
                }
            }
        });
        cancelTokens.put(opId, cancel);
    }

    private void cancel(String opId, CallbackContext callbackContext) {
        Cancel cancel = cancelTokens.remove(opId);
        if (cancel != null) {
            cancel.cancel();
        }
        callbackContext.success();
    }

    private void sync(String opId, CallbackContext callbackContext, String sessionID, String hardwareID) {
        Cancel cancel = ak.sync(sessionID, hardwareID, new app.akiles.sdk.SyncCallback() {
            @Override
            public void onStatus(app.akiles.sdk.SyncStatus status) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "status");
                    event.put("status", status.toString());
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending sync status event", e);
                }
            }

            @Override
            public void onStatusProgress(float percent) {
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "status_progress");
                    event.put("percent", percent);
                    sendEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending sync status_progress event", e);
                }
            }

            @Override
            public void onSuccess() {
                cancelTokens.remove(opId);
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "success");
                    sendFinalEvent(callbackContext, event);
                } catch (JSONException e) {
                    LOG.e(TAG, "Error sending sync success event", e);
                }
            }

            @Override
            public void onError(AkilesException e) {
                cancelTokens.remove(opId);
                try {
                    JSONObject event = new JSONObject();
                    event.put("type", "error");
                    event.put("error", akilesExceptionToJson(e));
                    sendFinalEvent(callbackContext, event);
                } catch (JSONException ex) {
                    LOG.e(TAG, "JSONException", e);
                    callbackContext.error(ex.getMessage());
                }
            }
        });
        cancelTokens.put(opId, cancel);
    }

    private void scanCard(String opId, CallbackContext callbackContext) {
        Cancel cancel = ak.scanCard(new app.akiles.sdk.Callback<Card>() {
            @Override
            public void onSuccess(Card cardResult) {
                cancelTokens.remove(opId);
                card = cardResult;
                JSONObject object = new JSONObject();
                try {
                    object.put("isAkilesCard", card.isAkilesCard());
                    object.put("uid", hex(card.getUid()));
                    callbackContext.success(object);
                } catch (JSONException e) {
                    LOG.e(TAG, "JSONException", e);
                    callbackContext.error(e.getMessage());
                }
            }

            @Override
            public void onError(AkilesException e) {
                cancelTokens.remove(opId);
                LOG.e(TAG, "Error scanning card", e);
                callbackContext.error(akilesExceptionToJson(e));
            }
        });
        cancelTokens.put(opId, cancel);
    }

    private void updateCard(CallbackContext callbackContext) {
        if (card == null) {
            LOG.e(TAG, "Error updating card: no card");
            callbackContext.error("Error updating card: no card");
            return;
        }
        card.update(new app.akiles.sdk.Callback<Void>() {
            @Override
            public void onSuccess(Void unused) {
                callbackContext.success();
            }

            @Override
            public void onError(AkilesException e) {
                LOG.e(TAG, "Error updating card", e);
                callbackContext.error(akilesExceptionToJson(e));
            }
        });
    }

    private void closeCard(CallbackContext callbackContext) {
        if (card == null) {
            LOG.e(TAG, "Error closing card: no card");
            callbackContext.error("Error closing card: no card");
            return;
        }
        card.close();
        card = null;
        callbackContext.success();
    }

    private static String hex(byte[] payload) {
        if (payload == null)
            return "";
        StringBuilder stringBuilder = new StringBuilder(payload.length);
        for (byte byteChar : payload)
            stringBuilder.append(String.format("%02X", byteChar));
        return stringBuilder.toString();
    }

    private static JSONObject akilesExceptionToJson(AkilesException ex) {
        LOG.i(TAG, "exception", ex);
        JSONObject obj = new JSONObject();
        try {
            obj.put("code", ex.code.toString());
            obj.put("description", ex.getMessage());

            // Check for PermissionDenied subclass
            if (ex instanceof AkilesException.PermissionDenied) {
                AkilesException.PermissionDenied permissionDenied = (AkilesException.PermissionDenied) ex;
                obj.put("reason", permissionDenied.reason.toString());

                // Check for PermissionDeniedNotStarted subclass
                if (ex instanceof AkilesException.PermissionDeniedNotStarted) {
                    AkilesException.PermissionDeniedNotStarted notStarted = (AkilesException.PermissionDeniedNotStarted) ex;
                    obj.put("startsAt", notStarted.startsAt);
                }
                // Check for PermissionDeniedEnded subclass
                else if (ex instanceof AkilesException.PermissionDeniedEnded) {
                    AkilesException.PermissionDeniedEnded ended = (AkilesException.PermissionDeniedEnded) ex;
                    obj.put("endsAt", ended.endsAt);
                }
                // Check for PermissionDeniedOutOfSchedule subclass
                else if (ex instanceof AkilesException.PermissionDeniedOutOfSchedule) {
                    AkilesException.PermissionDeniedOutOfSchedule outOfSchedule = (AkilesException.PermissionDeniedOutOfSchedule) ex;
                    obj.put("waitTime", outOfSchedule.waitTime);
                    obj.put("timezone", outOfSchedule.timezone);

                    // Serialize the schedule object
                    if (outOfSchedule.schedule != null) {
                        JSONObject scheduleObj = new JSONObject();
                        JSONArray weekdaysArray = new JSONArray();
                        
                        if (outOfSchedule.schedule.weekdays != null) {
                            for (Schedule.Weekday weekday : outOfSchedule.schedule.weekdays) {
                                JSONObject weekdayObj = new JSONObject();
                                JSONArray rangesArray = new JSONArray();
                                
                                if (weekday.ranges != null) {
                                    for (Schedule.Range range : weekday.ranges) {
                                        JSONObject rangeObj = new JSONObject();
                                        rangeObj.put("start", range.start);
                                        rangeObj.put("end", range.end);
                                        rangesArray.put(rangeObj);
                                    }
                                }
                                weekdayObj.put("ranges", rangesArray);
                                weekdaysArray.put(weekdayObj);
                            }
                        }
                        scheduleObj.put("weekdays", weekdaysArray);
                        obj.put("schedule", scheduleObj);
                    }
                }
            }
        } catch (JSONException e) {
            LOG.e(TAG, "JSONException", e);
            // fallback: just description
            try {
                obj.put("description", ex.getMessage());
            } catch (JSONException ee) {
                LOG.e(TAG, "JSONException", ee);
            }
        }
        return obj;
    }

    private void sendEvent(CallbackContext callbackContext, JSONObject event) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, event);
        pluginResult.setKeepCallback(true);
        callbackContext.sendPluginResult(pluginResult);
    }

    private void sendFinalEvent(CallbackContext callbackContext, JSONObject event) {
        PluginResult pluginResult = new PluginResult(PluginResult.Status.OK, event);
        pluginResult.setKeepCallback(false);
        callbackContext.sendPluginResult(pluginResult);
    }
}
