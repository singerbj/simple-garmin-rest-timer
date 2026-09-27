import Toybox.Lang;
import Toybox.WatchUi;

class RestTimerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as RestTimerView;

    function initialize(view as RestTimerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Top-right (START/ENTER) button, and UP/DOWN on watches that have them.
    // UP/DOWN are handled here so the page behaviors below only come from swipes.
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        var key = evt.getKey();
        if (key == WatchUi.KEY_ENTER) {
            _view.pressButton();
            return true;
        }
        if (key == WatchUi.KEY_UP) {
            _view.adjust(1);
            return true;
        }
        if (key == WatchUi.KEY_DOWN) {
            _view.adjust(-1);
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

    // Button-only watches: hold UP (MENU) to edit.
    function onMenu() as Boolean {
        _view.beginEdit();
        return true;
    }

    // The system turns a swipe up into "next page", so swipe up increases the time.
    function onNextPage() as Boolean {
        _view.adjust(1);
        return true;
    }

    function onPreviousPage() as Boolean {
        _view.adjust(-1);
        return true;
    }
}
