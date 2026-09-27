import Toybox.Application;
import Toybox.Lang;
import Toybox.WatchUi;

class RestTimerApp extends Application.AppBase {

    function initialize() {
        AppBase.initialize();
    }

    function getInitialView() {
        var view = new RestTimerView();
        return [view, new RestTimerDelegate(view)];
    }
}
