package net
{
    public class ServerMessageType
    {
        /*
        Server -> Client
         */

        public static const UPDATE_PARTY:String = "updateParty"; // Updates the party information
        public static const UPDATE_ID:String = "updateId"; // Updates the user id
        public static const CHAT:String = "chat"; // A chat message, forwarded to all sessions
    }
}
