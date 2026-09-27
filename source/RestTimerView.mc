import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

const MIN_SECONDS = 1;
const MAX_SECONDS = 180;
const STEP_SECONDS = 5;
const DEFAULT_SECONDS = 30;
const STORAGE_KEY = "duration";
// Light green: shows green on colour screens but maps to white (not black) on monochrome ones.
const RUNNING_COLOR = 0x55FF55;

class RestTimerView extends WatchUi.View {

    private var _duration as Number = DEFAULT_SECONDS;
    // Seconds left while running; the draft value while editing.
    private var _remaining as Number = DEFAULT_SECONDS;
    private var _running as Boolean = false;
    private var _editing as Boolean = false;
    private var _timer as Timer.Timer;
    private var _touch as Boolean;

    function initialize() {
        View.initialize();
        _touch = System.getDeviceSettings().isTouchScreen;
        var saved = Application.Storage.getValue(STORAGE_KEY);
        if (saved instanceof Number) {
            _duration = clamp(saved);
        }
        _remaining = _duration;
        _timer = new Timer.Timer();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        var w = dc.getWidth();
        var h = dc.getHeight();
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();

        var color = Graphics.COLOR_WHITE;
        if (_running) {
            color = RUNNING_COLOR;
        } else if (_editing) {
            color = Graphics.COLOR_YELLOW;
        }
        dc.setColor(color, Graphics.COLOR_TRANSPARENT);
        dc.drawText(w / 2, h / 2, Graphics.FONT_NUMBER_THAI_HOT, _remaining.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);

        if (!_running) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            dc.drawText(w / 2, h * 0.84, Graphics.FONT_XTINY,
                hintText(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    private function hintText() as String {
        if (_touch) {
            return _editing ? "Tap to save" : "Tap and hold to edit";
        }
        return _editing ? "START to save" : "Hold UP to edit";
    }

    function isEditing() as Boolean {
        return _editing;
    }

    // Top-right button: save while editing, otherwise start / reset.
    function pressButton() as Void {
        if (_editing) {
            save();
            return;
        }
        if (_running) {
            reset();
        } else {
            _running = true;
            _timer.start(method(:onTick), 1000, true);
        }
        WatchUi.requestUpdate();
    }

    // Tap and hold (or hold UP / MENU on button-only watches): enter edit mode (only while stopped).
    function beginEdit() as Void {
        if (!_running && !_editing) {
            _editing = true;
            WatchUi.requestUpdate();
        }
    }

    // Swipe up/down (or UP/DOWN buttons) while editing: step the draft value by 5s.
    function adjust(direction as Number) as Void {
        if (!_editing) {
            return;
        }
        var next = direction > 0
            ? (_remaining / STEP_SECONDS + 1) * STEP_SECONDS
            : ((_remaining - 1) / STEP_SECONDS) * STEP_SECONDS;
        _remaining = clamp(next);
        WatchUi.requestUpdate();
    }

    function save() as Void {
        _duration = _remaining;
        _editing = false;
        Application.Storage.setValue(STORAGE_KEY, _duration);
        WatchUi.requestUpdate();
    }

    function cancelEdit() as Void {
        _remaining = _duration;
        _editing = false;
        WatchUi.requestUpdate();
    }

    // Counts down; buzzes when it hits 0, then resets on the next tick.
    function onTick() as Void {
        if (_remaining <= 0) {
            reset();
        } else {
            _remaining -= 1;
            if (_remaining == 0 && Attention has :vibrate) {
                Attention.vibrate([new Attention.VibeProfile(100, 1000)]);
            }
        }
        WatchUi.requestUpdate();
    }

    private function reset() as Void {
        _timer.stop();
        _running = false;
        _remaining = _duration;
    }

    private function clamp(value as Number) as Number {
        if (value < MIN_SECONDS) {
            return MIN_SECONDS;
        }
        if (value > MAX_SECONDS) {
            return MAX_SECONDS;
        }
        return value;
    }
}
