package global
{
    import mx.collections.ArrayCollection;

    import net.ServerMessageType;
    import net.Session;

    import signal.Signal;
    import signal.SignalEvent;

    import ui.Console;

    public class State
    {
        private static var _instance:State;

        private var signalManager:Signal;

        public var id:String;
        public var party:ArrayCollection;
        public var messages:ArrayCollection;

        public function State()
        {
            if (_instance)
                throw new Error("Singletons can only have one instance");
            _instance = this;

            // Signal
            signalManager = Signal.instance;
            signalManager.addEventListener(SignalEvent.SIGNAL, handleSignal);

            party = new ArrayCollection();
            messages = new ArrayCollection();
        }

        public function getMe():Object
        {
            var me:Object = null;
            for each (var user:Object in party)
                if (user.id == id)
                    me = user;
            return me;
        }

        public static function get instance():State
        {
            if (!_instance)
                new State();
            return _instance;
        }

        public function handleSignal(signalEvent:SignalEvent):void
        {
            // Handle global Signals
            var payload:Object = signalEvent.payload;

            switch (signalEvent.action)
            {
                case ServerMessageType.UPDATE_PARTY:
                    party.source = payload as Array;
                    var str:String = "==== Party ====";
                    for each (var partyMember:Object in State.instance.party)
                    {
                        str += "\n";
                        if (partyMember.id == id)
                            str += "me -> ";
                        if (partyMember.name)
                            str += "(" + partyMember.name + ")";
                        str += " " + partyMember.id;
                    }
                    Console.log(str);
                    break;
                case ServerMessageType.UPDATE_ID:
                    id = payload as String;
                    Console.log("id: " + id);
                    break;
                case ServerMessageType.CHAT:
                    messages.addItem(payload);
                    break;
                default:
                    break;
            }
        }
    }
}
