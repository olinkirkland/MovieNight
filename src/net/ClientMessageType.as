package net
{
    public class ClientMessageType
    {
        /*
        Client -> Server
         */

        public static const CONFIRM_CONNECTION:String = "confirmConnection"; // Client confirms their connection
        public static const SET_NAME:String = "setName"; // Sets a name
        public static const SET_AVATAR:String = "setAvatar"; // Sets an avatar
        public static const GET_ID:String = "getId"; // Asks for id
        public static const GET_PARTY:String = "getParty"; // Asks for the party list
        public static const SEND_CHAT:String = "chat"; // Sends a chat
    }
}