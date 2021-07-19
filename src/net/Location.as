package net
{
    import flash.utils.ByteArray;

    public class Location
    {
        public var city:String;
        public var region:String;
        public var country:String;

        public function Location(city:String, region:String, country:String)
        {
            this.city    = city;
            this.region  = region;
            this.country = country;
        }
    }
}
