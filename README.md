# akiles-cordova

This plugin defines a global `akiles` object.
Although the object is in the global scope, it is not available until after the `deviceready` event.

```js
document.addEventListener("deviceready", onDeviceReady, false);
function onDeviceReady() {
    console.log(akiles);
}
```

## Installation

    cordova plugin add akiles-cordova

## Example

The `example/` directory contains an example app showcasing all the SDK functionality.

## License

MIT
