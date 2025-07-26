package utils
{
   public class StringUtil
   {
      
      public function StringUtil()
      {
         super();
      }
      
      public static function replace(str:String, oldSubStr:String, newSubStr:String) : String
      {
         return str.split(oldSubStr).join(newSubStr);
      }
      
      public static function trim(str:String, char:String = " ") : String
      {
         return trimBack(trimFront(str,char),char);
      }
      
      public static function trimFront(str:String, char:String = " ") : String
      {
         char = stringToCharacter(char);
         while(str.length > 0 && str.charAt(0) == char)
         {
            str = str.substring(1);
         }
         return str;
      }
      
      public static function trimBack(str:String, char:String = " ") : String
      {
         char = stringToCharacter(char);
         while(str.length > 0 && str.charAt(str.length - 1) == char)
         {
            str = str.substring(0,str.length - 1);
         }
         return str;
      }
      
      public static function stringToCharacter(str:String) : String
      {
         if(str.length == 1)
         {
            return str;
         }
         return str.slice(0,1);
      }
   }
}

