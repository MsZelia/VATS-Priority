package
{
   import flash.display.MovieClip;
   import flash.geom.Point;
   import flash.text.TextField;
   import flash.text.TextFieldAutoSize;
   import flash.text.TextFormat;
   import scaleform.gfx.TextFieldEx;
   
   [Embed(source="/_assets/assets.swf", symbol="symbol22")]
   public class PartInfo extends MovieClip
   {
      
      internal static const PART_INFO_BORDER_WIDTH:Number = 6;
      
      internal static const PART_INFO_BORDER_WIDTH_MIN:Number = 60;
      
      internal static const BRACKET_WIDTH_INSET:Number = 12;
      
      internal static const BRACKET_HEIGHT_INSET:Number = 20;
       
      
      public var GraphicInstance:MovieClip;
      
      public var TargetBracketsInstance:MovieClip;
      
      public var HealthBar:MovieClip;
      
      public var HealthBarIndicator:MovieClip;
      
      public var ChanceToHit:TextField;
      
      public var NameTextField:TextField;
      
      public var InfoBracketInstance:MovieClip;
      
      private var ActionCount:uint = 0;
      
      private var HealthPercent:Number = 0;
      
      private var bOffsetPosition:Boolean;
      
      private var bSelected:Boolean;
      
      public function PartInfo()
      {
         super();
         addFrameScript(0,this.frame1,1,this.frame2,2,this.frame3);
         this.TargetBracketsInstance = this.GraphicInstance.TargetBracketsInstance;
         this.HealthBar = this.GraphicInstance.TintedContainer.AnimationInstance.PartHealth;
         this.HealthBarIndicator = this.HealthBar.BarInstance;
         this.ChanceToHit = this.GraphicInstance.TintedContainer.AnimationInstance.HitChance;
         this.ChanceToHit.visible = false;
         this.NameTextField = this.GraphicInstance.TintedContainer.AnimationInstance.Name;
         this.InfoBracketInstance = this.GraphicInstance.TintedContainer.AnimationInstance.InfoBracketInstance;
         TextFieldEx.setNoTranslate(this.NameTextField,true);
         this.SetActionCount(0);
         this.bSelected = false;
      }
      
      public function SetOffsetPosition(param1:Boolean) : *
      {
         this.bOffsetPosition = param1;
      }
      
      public function SetSelected(param1:Boolean) : *
      {
         if(param1 != this.bSelected)
         {
            this.bSelected = param1;
            if(param1)
            {
               this.GraphicInstance.TintedContainer.gotoAndPlay("flashing");
            }
            else
            {
               this.GraphicInstance.TintedContainer.gotoAndPlay("default");
            }
            this.UpdateElementVisibility();
         }
      }
      
      public function SetActionCount(param1:uint) : *
      {
         var _loc2_:Point = null;
         this.ActionCount = param1;
         if(this.ActionCount == 0)
         {
            this.TargetBracketsInstance.visible = false;
         }
         else
         {
            this.TargetBracketsInstance.scaleX = 1;
            this.TargetBracketsInstance.scaleY = 1;
            this.TargetBracketsInstance.visible = true;
            this.TargetBracketsInstance.gotoAndStop(Math.min(this.ActionCount,4));
            this.TargetBracketsInstance.width = this.TargetBracketsInstance.width + this.GraphicInstance.TintedContainer.width - BRACKET_WIDTH_INSET;
            this.TargetBracketsInstance.height = this.TargetBracketsInstance.height + this.GraphicInstance.TintedContainer.height - BRACKET_HEIGHT_INSET;
            _loc2_ = new Point(this.GraphicInstance.TintedContainer.x,this.InfoBracketInstance.y);
            _loc2_ = this.InfoBracketInstance.parent.localToGlobal(_loc2_);
            _loc2_ = this.TargetBracketsInstance.parent.globalToLocal(_loc2_);
            this.TargetBracketsInstance.y = _loc2_.y;
         }
      }
      
      public function SetHealthPercent(param1:Number) : *
      {
         this.HealthPercent = param1;
         this.HealthBarIndicator.scaleX = Math.max(param1,0);
         this.UpdateElementVisibility();
      }
      
      public function SetName(param1:String) : *
      {
         var _loc2_:TextFormat = this.NameTextField.getTextFormat();
         this.NameTextField.text = param1.toUpperCase();
         this.NameTextField.setTextFormat(_loc2_);
         this.NameTextField.autoSize = TextFieldAutoSize.CENTER;
      }
      
      public function SetChanceToHit(param1:uint) : *
      {
         var _loc2_:TextFormat = this.ChanceToHit.getTextFormat();
         this.ChanceToHit.text = param1.toString() + "%";
         this.ChanceToHit.setTextFormat(_loc2_);
         this.ChanceToHit.visible = true;
      }
      
      public function UpdateElementVisibility() : *
      {
         this.HealthBar.visible = this.HealthPercent < 1 || this.ActionCount > 0 || this.bSelected;
         this.NameTextField.visible = this.bSelected;
         this.HealthBar.scaleX = 1;
         this.HealthBar.scaleY = 1;
         this.NameTextField.scaleX = 1;
         this.NameTextField.scaleY = 1;
         var _loc1_:Number = this.ChanceToHit.y + this.ChanceToHit.height;
         var _loc2_:Number = this.NameTextField.visible ? this.NameTextField.y : (this.HealthBar.visible ? this.HealthBar.y - 6 : this.ChanceToHit.y);
         _loc1_ -= _loc2_;
         var _loc3_:Number = Math.max(this.NameTextField.visible ? this.NameTextField.width : 0,this.HealthBar.visible ? this.HealthBar.width : 0,this.ChanceToHit.width);
         this.InfoBracketInstance.height = _loc1_;
         this.InfoBracketInstance.width = Math.max(_loc3_ + PART_INFO_BORDER_WIDTH,PART_INFO_BORDER_WIDTH_MIN);
         this.InfoBracketInstance.y = _loc2_ + _loc1_ / 2;
         var _loc4_:Number = this.HealthBar.visible ? 1 : 0;
         this.HealthBar.scaleX = _loc4_;
         this.HealthBar.scaleY = _loc4_;
         _loc4_ = this.NameTextField.visible ? 1 : 0;
         this.NameTextField.scaleX = _loc4_;
         this.NameTextField.scaleY = _loc4_;
      }
      
      internal function frame1() : *
      {
         stop();
      }
      
      internal function frame2() : *
      {
         stop();
      }
      
      internal function frame3() : *
      {
         stop();
      }
   }
}
