package net
{

    import flash.net.*;

    import ui.Console;

    public class SelfSession extends Session
    {
        public var selfClient:Client;

        public function SelfSession(socket:Socket = null):void
        {
            super(null);

            policy = true;
            confirmed = true;
        }

        override public function send(m:Message):void
        {
            Console.log("[send] " + JSON.stringify(m));
            selfClient.handleData(m);
        }
    }
}