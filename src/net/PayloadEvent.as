package net
{

    import flash.events.Event;

    public class PayloadEvent extends Event
    {
        public var payload:Object;

        public function PayloadEvent(type:String, payload:Object)
        {
            this.payload = payload;
            super(type);
        }
    }
}
