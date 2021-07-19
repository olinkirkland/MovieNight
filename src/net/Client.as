package net
{

    import flash.events.*;
    import flash.net.*;
    import flash.utils.setTimeout;

    import global.Util;

    import signal.Signal;
    import signal.SignalEvent;

    import ui.Console;

    /**
     * ...
     * @author Olin Kirkland
     */

    public class Client extends EventDispatcher
    {
        private var socket:Socket;
        private var signalManager:Signal;

        public var address:String;
        public var connected:Boolean;

        public var server:Server;

        // id refers to the id of the currently logged in user
        public static var id:String = "";

        public function Client():void
        {
            connected = false;

            // Signal
            signalManager = Signal.instance;
            signalManager.addEventListener(SignalEvent.SIGNAL, handleSignal);
        }

        public function handleSignal(signalEvent:SignalEvent):void
        {
            // Handle global Signals
            var payload:Object = signalEvent.payload;

            // Client action
            switch (signalEvent.action)
            {
                default:
                    break;
            }
        }

        public function create():void
        {
            // Create the socket
            socket = new Socket();

            // Ten second timeout
            socket.timeout = 10 * 1000;
            socket.addEventListener(Event.CONNECT, handleConnect);
            socket.addEventListener(Event.CLOSE, handleDisconnect);
            socket.addEventListener(ProgressEvent.SOCKET_DATA, socketDataHandler);
            socket.addEventListener(IOErrorEvent.IO_ERROR, handleError);
            socket.addEventListener(SecurityErrorEvent.SECURITY_ERROR, handleError);
        }

        public function connect(address:String = null):void
        {
            if (!socket)
                create();

            if (address)
                this.address = address;

            connected = false;
            socket.connect(this.address, Util.PORT);
        }

        public function connectToSelf(server:Server):void
        {
            this.server = server;
            handleConnect(null);
        }

        private function handleConnect(e:Event):void
        {
            connected = true;
            dispatchEvent(new Event(Event.CONNECT));

            send(new Message(ClientMessageType.CONFIRM_CONNECTION));
        }

        private function handleDisconnect(e:Event):void
        {
            connected = false;
            dispatchEvent(new Event(Event.CLOSE));

            // Try to reconnect
            //connect();

            Console.log("You were disconnected from " + address);
        }

        public function handleError(e:IOErrorEvent):void
        {
            // Couldn't connect to server, retrying
            //connect();

            Console.log(e.text);
        }

        private function socketDataHandler(e:ProgressEvent):void
        {
            try
            {
                var data:Object = socket.readObject();
                handleData(data);
            } catch (error:Error)
            {
                // Not an object
                // Ignore it
            }
        }

        public function handleData(data:Object):void
        {
            signalManager.dispatch(data.type, data.data);
            dispatchEvent(new MessageEvent(Message.serialize(data)));
        }


        public function send(m:Message):void
        {
            // If it's the server, let it immediately receive the message
            if (server)
            {
                server.handleDataReceived(new MessageEvent(m));
                return;
            }

            try
            {
                // Try to send an object to the socket
                trace("[send] " + JSON.stringify(m));
                socket.writeObject(m);
                socket.flush();
            } catch (error:Error)
            {
                // There's no connection, or there was a problem with the connection
                trace("An error was encountered when trying to send the message\n" + JSON.stringify(m));
            }
        }
    }
}