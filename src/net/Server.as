package net
{

    import flash.events.*;
    import flash.filesystem.*;
    import flash.net.*;

    import global.State;
    import global.Util;

    import mx.collections.ArrayCollection;
    import mx.utils.UIDUtil;

    import ui.Console;

    public class Server extends EventDispatcher
    {
        public var sessions:Object;
        public var server:ServerSocket;
        public var state:State;

        private var selfSession:SelfSession;

        public function Server(selfClient:Client):void
        {
            state = State.instance;
            state.party = new ArrayCollection();

            // Load data from file
            var file:File = File.applicationStorageDirectory.resolvePath("data.json");
            if (!file.exists)
            {
                // No data yet, create an empty file
                var fileStream:FileStream = new FileStream();
                fileStream.open(file, FileMode.WRITE);
                fileStream.writeUTFBytes(JSON.stringify({}));
                fileStream.close();
            }

            // Sessions start with selfClient as one of the sessions
            sessions = {};
            selfSession = new SelfSession();
            selfSession.selfClient = selfClient;
            sessions[UIDUtil.createUID()] = selfSession;
            state.party.addItem(selfSession.toPartyMember());

            // Start the server
            server = new ServerSocket();
            server.bind(Util.PORT);
            server.addEventListener(ServerSocketConnectEvent.CONNECT, handleConnect);
            server.listen();
            Console.log("Server started on port " + Util.PORT, "config");
        }

        private function handleConnect(e:ServerSocketConnectEvent):void
        {
            // When a Socket connects
            var session:Session = new Session(e.socket);

            // Session event listeners
            session.addEventListener(Session.DISCONNECT, handleDisconnect);
            session.addEventListener(Session.CONFIRM, handleConfirm);
            session.addEventListener(MessageEvent.DATA, handleDataReceived);
        }

        private function handleConfirm(e:Event):void
        {
            // When a Session that's connected is confirmed (not a "policy connect")
            var session:Session = (e.target as Session);
            sessions[session.id] = session;
            state.party.addItem(session.toPartyMember());

            session.removeEventListener(Session.CONFIRM, handleConfirm);

            Console.log("Session (" + session.id + ") connected\n  " + session.socket.remoteAddress, "userJoined", {ip: session.socket.remoteAddress});
        }

        private function handleDisconnect(e:Event):void
        {
            // When a Session disconnects
            var session:Session = (e.target as Session);
            delete sessions[session.id];

            // Remove party member by id
            for (var i:int = 0; i < state.party.length; i++)
                if (state.party[i].id == session.id)
                    state.party.removeItemAt(i);

            Console.log("Session (" + session.id + ") disconnected\n  " + session.socket.remoteAddress, "userLeft", {ip: session.socket.remoteAddress});
        }

        public function handleDataReceived(e:MessageEvent):void
        {
            // Handle all received data from sessions here
            var m:Message = Message.serialize(e.data);
            if (!m)
                return;

            var s:Session = Session(e.target);
            if (!s)
                s = selfSession;

            // Handle messages from all sessions
            Console.log("* [received] " + JSON.stringify(m));

            switch (m.type)
            {
                case ClientMessageType.GET_PARTY:
                    // Session asks for party
                    s.send(new Message(ServerMessageType.UPDATE_PARTY, state.party.source));
                    break;
                case ClientMessageType.GET_ID:
                    // Session asks for id
                    s.send(new Message(ServerMessageType.UPDATE_ID, s.id));
                    break;
                case ClientMessageType.CONFIRM_CONNECTION:
                    // Connection confirmed
                    s.send(new Message(ServerMessageType.UPDATE_ID, s.id));
                    break;
                case ClientMessageType.SEND_CHAT:
                    // Received a chat message from a user
                    sendAll(m.type, m.data);
                    break;
                default:
                    Console.log("Uncaught message type '" + m.type + "' received", Console.CONFIG);
                    break;
            }
        }

        public function sendAll(type:String, data:Object):void
        {
            // Send a message to all sessions
            for each (var s:Session in sessions)
                s.send(new Message(type, data));
        }
    }
}