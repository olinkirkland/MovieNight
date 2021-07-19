package net.email
{
    public class EmailFormatter
    {
        public function EmailFormatter()
        {
        }

        public static function replace(message:String, replacements:Object):String
        {
            for (var r:String in replacements)
                message.replace(r, replacements[r]);
            return message;
        }
    }
}
