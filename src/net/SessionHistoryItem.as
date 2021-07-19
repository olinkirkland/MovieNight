package net
{
    public class SessionHistoryItem
    {
        public var id:String;

        public var type:String;
        public var time:Number;

        public var ip:String;

        public function SessionHistoryItem(id:String, type:String, time:Number, ip:String)
        {
            this.id   = id;
            this.type = type;
            this.time = time;
            this.ip   = ip;
        }
    }
}
