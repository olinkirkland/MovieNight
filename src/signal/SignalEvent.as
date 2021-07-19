package signal
{
    import flash.events.Event;


    public class SignalEvent extends Event
    {
        public static var SIGNAL:String = "signal";

        public var action:String;
        public var payload:Object;

        public function SignalEvent(action:String, payload:Object)
        {
            this.action  = action;
            this.payload = payload;
            super(SIGNAL);
        }
    }
}
