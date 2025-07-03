package VATSMenu_fla
{
   import flash.display.MovieClip;
   
   public dynamic class MainTimeline extends MovieClip
   {
       
      
      public var MenuInstance:VATSMenu;
      
      public function MainTimeline()
      {
         super();
         addFrameScript(0,this.frame1);
      }
      
      public function SetPlatform(param1:uint, param2:Boolean, param3:uint, param4:uint) : *
      {
         this.MenuInstance.SetPlatform(param1,param2,param3,param4);
      }
      
      internal function frame1() : *
      {
      }
   }
}
