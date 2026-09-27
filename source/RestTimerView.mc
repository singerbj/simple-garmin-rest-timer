import Toybox.Application;
import Toybox.Attention;
import Toybox.Graphics;
import Toybox.Lang;
import Toybox.Timer;
import Toybox.WatchUi;

const MIN_SECONDS = 1;
const MAX_SECONDS = 180;
const DEFAULT_SECONDS = 30;
const STORAGE_KEY = "duration";

class RestTimerView extends WatchUi.View {

    private var _duration as Number = DEFAULT_SECONDS;
    private var _remaining as Number = DEFAULT_SECONDS;
    private var _running as Boolean = false;
    private var _timer as Timer.Timer;

    function initialize() {
        View.initialize();
        var saved = Application.Storage.getValue(STORAGE_KEY);
        if (saved instanceof Number) {
            _duration = clamp(saved);
        }
        _remaining = _duration;
        _timer = new Timer.Timer();
    }

    function onUpdate(dc as Graphics.Dc) as Void {
        dc.setColor(Graphics.COLOR_BLACK, Graphics.COLOR_BLACK);
        dc.clear();
        dc.setColor(_running ? Graphics.COLOR_GREEN : Graphics.COLOR_WHITE, Graphics.COLOR_TRANSPARENT);
        dc.drawText(
            dc.getWidth() / 2,
            dc.getHeight() / 2,
            Graphics.FONT_NUMBER_THAI_HOT,
            _remaining.toString(),
            Graphics.TEXT_JUSTIFY_CENTER | Graphics.TEXT_JUSTIFY_VCENTER
        );
    }

    // Top-right button: start if idle, reset if running.
    function toggle() as Void {
        if (_running) {
            reset();
        } else {
            _running = true;
            _timer.start(method(:onTick), 1000, true);
        }
        WatchUi.requestUpdate();
    }

    // Swipe up/down: change the duration while idle, and persist it.
    function adjust(delta as Number) as Void {
        if (_running) {
            return;
        }
        var next = clamp(_duration + delta);
        if (next != _duration) {
            _duration = next;
            _remaining = next;
            Application.Storage.setValue(STORAGE_KEY, next);
            WatchUi.requestUpdate();
        }
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
