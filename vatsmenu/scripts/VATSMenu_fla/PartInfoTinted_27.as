package VATSMenu_fla
{
   import flash.display.MovieClip;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol15")]
   public dynamic class PartInfoTinted_27 extends MovieClip
   {
      
      public var AnimationInstance:MovieClip;
      
      public function PartInfoTinted_27()
      {
         super();
         addFrameScript(0,this.frame1,29,this.frame30);
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame30() : *
      {
         gotoAndPlay("flashing");
      }
   }
}

