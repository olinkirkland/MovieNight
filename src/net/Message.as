package net
{
    import flash.utils.ByteArray;

    public class Message
    {
        public var type:String;
        public var data:Object;

        public function Message(type:String = "", data:Object = null)
        {
            this.type = type;
            this.data = data;
        }

        public static function serialize(untypedMessage:Object):Message
        {
            var m:Message = new Message(untypedMessage.hasOwnProperty("type") ? untypedMessage.type : null,
                    untypedMessage.hasOwnProperty("data") ? untypedMessage.data : null);

            if (m.type)
                return m;

            trace("Received unexpected message format:\n" + JSON.stringify(untypedMessage));
            return null;
        }
    }
}
