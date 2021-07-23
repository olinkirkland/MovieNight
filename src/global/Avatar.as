package global
{
    public class Avatar
    {
        public static var avatars:Array = [{
            name: "Block",
            icon: Icons.AvatarBlock
        }, {
            name: "Broccoli",
            icon: Icons.AvatarBroccoli
        }, {
            name: "Cat",
            icon: Icons.AvatarCat
        }, {
            name: "Dog",
            icon: Icons.AvatarDog
        }, {
            name: "Easy",
            icon: Icons.AvatarEasy
        }, {
            name: "Egg",
            icon: Icons.AvatarEgg
        }, {
            name: "Popcorn",
            icon: Icons.AvatarPopcorn
        }, {
            name: "Press",
            icon: Icons.AvatarPress
        }, {
            name: "Sun",
            icon: Icons.AvatarSun
        }, {
            name: "Question",
            icon: Icons.AvatarQuestion
        }];

        public function Avatar()
        {
        }

        public static function getAvatarByName(name:String):Object
        {
            trace(name);
            for each (var avatar:Object in avatars)
                if (avatar.name == name)
                    return avatar;
            return null;
        }
    }
}
