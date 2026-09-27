import Toybox.Lang;
import Toybox.WatchUi;

class RestTimerDelegate extends WatchUi.BehaviorDelegate {

    private var _view as RestTimerView;

    function initialize(view as RestTimerView) {
        BehaviorDelegate.initialize();
        _view = view;
    }

    // Handle the physical top-right (START/ENTER) button only, so screen taps do nothing.
    function onKey(evt as WatchUi.KeyEvent) as Boolean {
        if (evt.getKey() == WatchUi.KEY_ENTER) {
            _view.toggle();
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
