package net
{
    import flash.events.*;

    public class MessageEvent extends Event
    {
        public static var DATA:String = "MessageEvent_Data";
        public var data:Object;

        public function MessageEvent(data:Object):void
        {
            super(MessageEvent.DATA);
            this.data = data;
        }
    }
}