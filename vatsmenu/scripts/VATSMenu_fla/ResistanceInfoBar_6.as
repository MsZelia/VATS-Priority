package VATSMenu_fla
{
   import flash.display.MovieClip;
   import flash.geom.ColorTransform;
   import flash.text.TextField;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol88")]
   public dynamic class ResistanceInfoBar_6 extends MovieClip
   {
       
      
      public var BackgroundInstance:MovieClip;
      
      public var BossIcon_mc:MovieClip;
      
      public var Container:MovieClip;
      
      public var Level:TextField;
      
      public var Skull:MovieClip;
      
      public function ResistanceInfoBar_6()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2);
      }
      
      internal function frame1() : *
      {
         stop();
         this.BossIcon_mc.transform.colorTransform = new ColorTransform(0.96,0.46,0.46,1,0,0,0,0);
      }
      
      internal function frame2() : *
      {
         stop();
         this.BossIcon_mc.transform.colorTransform = new ColorTransform(0.96,0.46,0.46,1,0,0,0,0);
      }
   }
}
