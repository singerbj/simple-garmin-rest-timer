import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.System;
import Toybox.Timer;
import Toybox.WatchUi;

const MIN_SECONDS = 5;
const MAX_SECONDS = 180;
const STEP_SECONDS = 5;
const DEFAULT_SECONDS = 30;
const STORAGE_KEY = "duration";
// Light green: shows green on colour screens but maps to white (not black) on monochrome ones.
const RUNNING_COLOR = 0x55FF55;
// Redraw rate while running, so the ring shrinks smoothly instead of once a second.
const FRAME_MS = 100;

class RestTimerView extends WatchUi.View {

    private var _duration as Number = DEFAULT_SECONDS;
    // Seconds left while running; the draft value while editing.
    private var _remaining as Number = DEFAULT_SECONDS;
    private var _running as Boolean = false;
    private var _editing as Boolean = false;
    private var _timer as Timer.Timer;
    // System.getTimer() value when the countdown started.
    private var _startMs as Number = 0;
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
        drawRing(dc, w, h);
        if (_running && _remaining == 0) {
            // Number fonts only have digits, so use the largest text font.
            dc.drawText(w / 2, h / 2, Graphics.FONT_LARGE, "TIME",
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        } else {
            dc.drawText(w / 2, h / 2, Graphics.FONT_NUMBER_THAI_HOT, _remaining.toString(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }

        if (!_running) {
            dc.setColor(Graphics.COLOR_LT_GRAY, Graphics.COLOR_TRANSPARENT);
            // One line higher than the bottom slot, to keep clear of the ring.
            var y = h * 0.84 - dc.getFontHeight(Graphics.FONT_XTINY);
            dc.drawText(w / 2, y, Graphics.FONT_XTINY,
                hintText(),
                Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER);
        }
    }

    // Outer ring: full while stopped, unfilling clockwise from 12 o'clock while running.
    private function drawRing(dc as Graphics.Dc, w as Number, h as Number) as Void {
        var size = w < h ? w : h;
        var pen = size / 30;
        if (pen < 4) {
            pen = 4;
        }
        var r = size / 2 - pen / 2;
        if (dc has :setAntiAlias) {
            dc.setAntiAlias(true);
        }
        dc.setPenWidth(pen);

        var fraction = _running ? remainingFraction() : 1.0;
        if (fraction >= 1.0) {
            dc.drawCircle(w / 2, h / 2, r);
        } else {
            var sweep = 360.0 * fraction;
            // A zero-length arc would draw as a full circle, so skip slivers.
            if (sweep >= 1.0) {
                dc.drawArc(w / 2, h / 2, r, Graphics.ARC_CLOCKWISE, 90, 90 - sweep);
            }
        }
        dc.setPenWidth(1);
    }

    private function remainingFraction() as Float {
        var total = _duration * 1000;
        var left = total - elapsedMs();
        if (left <= 0) {
            return 0.0;
        }
        return left.toFloat() / total;
    }

    private function elapsedMs() as Number {
        return System.getTimer() - _startMs;
    }

    private function hintText() as String {
        if (_touch) {
            return _editing ? "Swipe to change\nTap to save" : "Tap and hold to edit";
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
            _startMs = System.getTimer();
            _timer.start(method(:onTick), FRAME_MS, true);
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

    // Counts down from the start time; buzzes when it hits 0, then resets a second later.
    function onTick() as Void {
        var elapsed = elapsedMs();
        if (elapsed >= (_duration + 1) * 1000) {
            reset();
        } else {
            var next = _duration - elapsed / 1000;
            if (next < 0) {
                next = 0;
            }
            var hitZero = next == 0 && _remaining > 0;
            _remaining = next;
            if (hitZero && Attention has :vibrate) {
                // Three short pulses: 200 ms on, 150 ms off.
                Attention.vibrate([
                    new Attention.VibeProfile(100, 200),
                    new Attention.VibeProfile(0, 150),
                    new Attention.VibeProfile(100, 200),
                    new Attention.VibeProfile(0, 150),
                    new Attention.VibeProfile(100, 200)
                ]);
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
