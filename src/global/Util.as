package global
{

    import flash.desktop.Clipboard;
    import flash.desktop.ClipboardFormats;
    import flash.net.InterfaceAddress;
    import flash.net.NetworkInfo;
    import flash.net.NetworkInterface;

    import net.Session;

    import ui.Console;

    /**
     * ...
     * @author Olin Kirkland
     */
    public class Util
    {
        // Server Address
        public static const PORT:int = 21025;

        /**
         * Icons
         */

        [Embed(source="/assets/icons/chat.png")]
        public static const ICON_CHAT:Class;

        [Embed(source="/assets/icons/key.png")]
        public static const ICON_KEY:Class;

        [Embed(source="/assets/icons/config.png")]
        public static const ICON_CONFIG:Class;

        [Embed(source="/assets/icons/speed.png")]
        public static const ICON_SPEED:Class;

        [Embed(source="/assets/icons/input.png")]
        public static const ICON_INPUT:Class;

        [Embed(source="/assets/icons/alert.png")]
        public static const ICON_ALERT:Class;

        [Embed(source="/assets/icons/email.png")]
        public static const ICON_EMAIL:Class;

        [Embed(source="/assets/icons/userJoined.png")]
        public static const ICON_USERJOINED:Class;

        [Embed(source="/assets/icons/userLeft.png")]
        public static const ICON_USERLEFT:Class;

        [Embed(source="/assets/icons/stats.png")]
        public static const ICON_STATS:Class;

        // Policy

        [Embed(source="/assets/policy.xml", mimeType="application/octet-stream")]
        public static var POLICY:Class;

        // Image Storage

        public static var images:Object;

        public function Util():void
        {
        }

        public static function copyToClipboard(str:String):void
        {
            Clipboard.generalClipboard.clear();
            Clipboard.generalClipboard.setData(ClipboardFormats.TEXT_FORMAT, str, false);
            Console.log("Copied: " + str);
        }

        public static function generateRandomString(len:int, safe:Boolean = true):String
        {
            var dictionary:String = "abcdefghijklmnopqrstuvABCDEFGHIJKLMNOPQRSTUVXYZ0123456789";
            var safeDictionary:String = "abcdefghijklmnopqrstuvABCDEFGHIJKLMNPQRSTUVXYZ123456789";

            if (safe)
                dictionary = safeDictionary;

            var str:String = "";
            for (var i:int = 0; i < len; i++)
                str += dictionary.charAt(int(Math.random() * dictionary.length));
            return str;
        }

        public static function formatNetworkInfo():String
        {
            var str:String = "";
            var networkInterfaces:Vector.<NetworkInterface> = NetworkInfo.networkInfo.findInterfaces();
            for (var i:int = 0; i < networkInterfaces.length; i++)
            {
                var networkInterface:NetworkInterface = networkInterfaces[i];

                if (!networkInterface.active)
                    continue;

                str += networkInterface.displayName + " " + networkInterface.name;

                for each (var address:InterfaceAddress in networkInterface.addresses)
                    str += "\n  " + address.address;

                if (i < networkInterfaces.length)
                    str += "\n";
            }

            return str;
        }
    }
}