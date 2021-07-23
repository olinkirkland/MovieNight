package net
{

    import flash.events.*;
    import flash.net.*;

    import global.Avatar;
    import global.State;
    import global.Util;

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

            // Sessions start with selfClient as one of the sessions
            sessions = {};
            selfSession = new SelfSession();
            selfSession.selfClient = selfClient;
            sessions[UIDUtil.createUID()] = selfSession;
            state.party.addItem({id: selfSession.id, name: "Anon-" + selfSession.id.substr(0, 3).toUpperCase(), avatar: Avatar.avatars[0].name});

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
            state.party.addItem({id: session.id, name: "Anon-" + session.id.substr(0, 3).toUpperCase(), avatar: Avatar.avatars[0].name});

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

            var i:int;
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
                    s.send(new Message(ServerMessageType.UPDATE_PARTY, state.party.source));
                    break;
                case ClientMessageType.SEND_CHAT:
                    // Received a chat message from a user
                    sendAll(m.type, {text: m.data, id: s.id});
                    break;
                case ClientMessageType.SET_NAME:
                    // Change a client name
                    for (i = 0; i < state.party.length; i++)
                        if (state.party[i].id == s.id)
                            state.party[i].name = m.data;
                    sendAll(ServerMessageType.UPDATE_PARTY, state.party.source);
                    break;
                case ClientMessageType.SET_AVATAR:
                    // Change a client avatar
                    for (i = 0; i < state.party.length; i++)
                        if (state.party[i].id == s.id)
                            state.party[i].avatar = m.data;
                    sendAll(ServerMessageType.UPDATE_PARTY, state.party.source);
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