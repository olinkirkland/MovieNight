package net
{

    import flash.events.*;
    import flash.net.*;
    import flash.utils.ByteArray;
    import flash.utils.setTimeout;

    import global.Util;

    import mx.utils.UIDUtil;

    import ui.Console;

    public class Session extends EventDispatcher
    {
        public static const DISCONNECT:String = "userDisconnect";
        public static const CONFIRM:String = "userConfirm";

        public var id:String;
        public var ip:String;

        public var confirmed:Boolean;
        public var socket:Socket;
        public var data:Object;
        public var policy:Boolean;

        public function Session(socket:Socket):void
        {
            policy = false;
            confirmed = false;

            // Generate a session id
            id = UIDUtil.createUID();

            this.socket = socket;
            if (!socket)
                return;

            ip = socket.remoteAddress;

            // Listen for the socket to close (a session disconnects)
            socket.addEventListener(Event.CLOSE, function (e:Event):void
            {
                if (policy)
                    dispatchEvent(new Event(Session.DISCONNECT));
            });

            // Listen for data from the socket
            socket.addEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
        }

        private function onSocketData(e:ProgressEvent):void
        {
            try
            {
                // Try to read an object from the socket
                data = socket.readObject();
                socket.flush();
                dispatchEvent(new MessageEvent(data));

                // Set policy to true
                policy = true;

                if (!confirmed)
                {
                    confirmed = true;
                    dispatchEvent(new Event(Session.CONFIRM));
                }
            } catch (error:Error)
            {
                // If there's no object in the socket, assume it's a request for a policy file
                // Respond with a policy file
                socket.writeUTFBytes((new Util.POLICY() as ByteArray).toString());
                socket.writeByte(0);
                socket.flush();
            }

            dispatchChange();
        }

        private function dispatchChange():void
        {
            setTimeout(function ():void
            {
                dispatchEvent(new Event(Event.CHANGE, true));
            }, 200);
        }

        public function send(m:Message):void
        {
            Console.log("[send] " + JSON.stringify(m));
            setTimeout(function ():void
            {
                try
                {
                    // Try to send an object to the socket
                    socket.writeObject(m);
                    socket.flush();
                } catch (error:Error)
                {
                    // There's no connection, or there was a problem with the connection
                    // Disconnect this socket and don't try to send any more messages to it
                    confirmed = false;

                    socket.removeEventListener(ProgressEvent.SOCKET_DATA, onSocketData);
                    dispatchEvent(new Event(Session.DISCONNECT));
                }
            }, 50);
        }

        public function toPartyMember():Object
        {
            return {id: id};
        }
    }
}