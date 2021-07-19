package net.email
{
    public class EmailAssets
    {
        [Embed(source="/assets/email/verify.txt", mimeType="application/octet-stream")]
        public static var EMAIL_VERIFY:Class;

        [Embed(source="/assets/email/welcome.txt", mimeType="application/octet-stream")]
        public static var EMAIL_WELCOME:Class;

        [Embed(source="/assets/email/reset.txt", mimeType="application/octet-stream")]
        public static var EMAIL_RESET:Class;
    }
}
