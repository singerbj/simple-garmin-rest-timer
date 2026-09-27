import Toybox.Lang;
import Toybox.WatchUi;

class RestTimerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as RestTimerView;

    function initialize(view as RestTimerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Top-right (START/ENTER) button.
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            _view.pressButton();
            return true;
        }
        return false;
    }

    function onHold(evt as WatchUi.ClickEvent) as Boolean {
        _view.beginEdit();
        return true;
    }

    // Taps only save while editing; always consumed so they never trigger onSelect.
    function onTap(evt as WatchUi.ClickEvent) as Boolean {
        if (_view.isEditing()) {
            _view.save();
        }
        return true;
    }

    // Back while editing discards the change instead of exiting the app.
    function onBack() as Boolean {
        if (_view.isEditing()) {
            _view.cancelEdit();
            return true;
        }
        return false;
    }

    function onSwipe(evt as WatchUi.SwipeEvent) as Boolean {
        var dir = evt.getDirection();
        if (dir == WatchUi.SWIPE_UP) {
            _view.adjust(1);
            return true;
        }
        if (dir == WatchUi.SWIPE_DOWN) {
            _view.adjust(-1);
            return true;
        }
        return false;
    }
}
