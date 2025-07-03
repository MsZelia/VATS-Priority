package
{
   import Shared.*;
   import Shared.AS3.*;
   import Shared.AS3.Data.*;
   import Shared.AS3.Events.*;
   import com.adobe.serialization.json.*;
   import fl.motion.*;
   import flash.display.*;
   import flash.events.*;
   import flash.filters.*;
   import flash.geom.*;
   import flash.net.*;
   import flash.system.*;
   import flash.text.*;
   import flash.ui.*;
   import flash.utils.*;
   import scaleform.gfx.*;
   import utils.*;
   
   public class VatsPriority extends MovieClip
   {
      
      public static const MOD_NAME:String = "VatsPriority";
      
      public static const MOD_VERSION:String = "1.0.0";
      
      public static const FULL_MOD_NAME:String = MOD_NAME + " " + MOD_VERSION;
      
      public static const CONFIG_FILE:String = "../VatsPriority.json";
      
      public static var DEBUG:Boolean = false;
       
      
      private var topLevel:*;
      
      private var debug_tf:TextField;
      
      private var lastConfig:String;
      
      private var config:Object;
      
      public function VatsPriority()
      {
         this.config = {};
         super();
         this.createDebugTf();
         this.loadConfig();
         addEventListener(Event.ADDED_TO_STAGE,this.addedToStageHandler);
      }
      
      public static function toString(param1:Object) : String
      {
         return new JSONEncoder(param1).getString();
      }
      
      public static function ShowHUDMessage(param1:String) : void
      {
         GlobalFunc.ShowHUDMessage("[" + FULL_MOD_NAME + "] " + param1);
      }
      
      private function createDebugTf() : void
      {
         this.debug_tf = new TextField();
         this.debug_tf.x = 20;
         this.debug_tf.y = 20;
         this.debug_tf.width = 700;
         this.debug_tf.height = 700;
         GlobalFunc.SetText(this.debug_tf,"",false);
         this.debug_tf.autoSize = TextFieldAutoSize.LEFT;
         this.debug_tf.wordWrap = true;
         this.debug_tf.multiline = true;
         var font:TextFormat = new TextFormat("$MAIN_Font",12,16777215);
         this.debug_tf.defaultTextFormat = font;
         this.debug_tf.setTextFormat(font);
         this.debug_tf.selectable = true;
         this.debug_tf.mouseWheelEnabled = true;
         this.debug_tf.mouseEnabled = true;
         this.debug_tf.visible = false;
         addChild(this.debug_tf);
      }
      
      public function displayMessage(param1:*, clear:Boolean = false) : void
      {
         if(clear)
         {
            this.debug_tf.text = "";
         }
         if(param1 is String)
         {
            var str:String = param1;
         }
         else
         {
            str = toString(param1);
         }
         this.debug_tf.text = this.debug_tf.text + "\n" + str;
         this.debug_tf.visible = true;
         this.debug_tf.scrollV = this.debug_tf.maxScrollV;
      }
      
      private function loadConfig() : void
      {
         var loaderComplete:Function;
         var url:URLRequest = null;
         var loader:URLLoader = null;
         try
         {
            loaderComplete = function(param1:Event):void
            {
               try
               {
                  config = new JSONDecoder(loader.data,true).getValue();
                  DEBUG = config.debug;
                  config.defaultPriority = config.defaultPriority != null ? config.defaultPriority.toUpperCase() : "HEAD";
                  if(config.priorities == null)
                  {
                     config.priorities = {};
                  }
                  for(prio in config.priorities)
                  {
                     if(config.priorities[prio] != null && config.priorities[prio] is String)
                     {
                        config.priorities[prio] = config.priorities[prio].toUpperCase();
                     }
                  }
                  displayMessage("Config file loaded!");
                  displayMessage(toString(config));
                  initTarget();
               }
               catch(e:Error)
               {
                  ShowHUDMessage("Error parsing config: " + e);
               }
            };
            url = new URLRequest(CONFIG_FILE);
            loader = new URLLoader();
            loader.load(url);
            loader.addEventListener(Event.COMPLETE,loaderComplete);
         }
         catch(e:Error)
         {
            ShowHUDMessage("Error loading config: " + e);
         }
      }
      
      public function addedToStageHandler(param1:Event) : *
      {
         this.topLevel = stage.getChildAt(0);
         if(Boolean(this.topLevel))
         {
            this.topLevel = this.topLevel.numChildren > 0 ? this.topLevel.getChildAt(0) : null;
            if(Boolean(this.topLevel))
            {
               stage.addEventListener("VatsPriority::RefreshActionDisplay",this.onRefreshActionDisplay);
               trace(MOD_NAME + " added to VATSMenu: " + getQualifiedClassName(this.topLevel));
               displayMessage(MOD_NAME + " added to VATSMenu: " + getQualifiedClassName(this.topLevel));
            }
            else
            {
               trace(MOD_NAME + " not added to VATSMenu");
               displayMessage(MOD_NAME + " not added to VATSMenu");
            }
         }
         else
         {
            trace(MOD_NAME + " not added to stage");
            displayMessage(MOD_NAME + " not added to stage");
         }
      }
      
      public function onRefreshActionDisplay(event:Event) : void
      {
         if(!config)
         {
            return;
         }
         setTimeout(this.initTarget,config.delayRefresh);
      }
      
      public function initTarget() : void
      {
         if(!this.topLevel || !this.topLevel.PartInfos || this.topLevel.PartInfos.length == 0)
         {
            return;
         }
         displayMessage("selectedPart: " + this.topLevel.SelectedPart);
         displayMessage("Parts: " + this.topLevel.PartInfos.length);
         var parts:Array = [];
         for(part in this.topLevel.PartInfos)
         {
            parts.push(this.topLevel.PartInfos[part].NameTextField.text.toUpperCase());
            displayMessage(parts[part] + (this.topLevel.SelectedPart == part ? " [S]" : ""));
         }
         var targetName:String = "".toUpperCase();
         var foundTarget:Boolean = false;
         var PRIO_LEGACY:Boolean = true;
         if(PRIO_LEGACY)
         {
            for(prio in config.priorities)
            {
               if(config.priorities[prio] != null)
               {
                  var prioLookup:String = prio.toUpperCase();
                  for(part in parts)
                  {
                     if(parts[part].indexOf(config.priorities[prio]) != -1)
                     {
                        displayMessage("Found target " + prioLookup + ", selecting part " + part + ": " + parts[part]);
                        this.topLevel.BGSCodeObj.SelectPart(part);
                        foundTarget = true;
                        break;
                     }
                  }
                  if(foundTarget)
                  {
                     break;
                  }
               }
            }
         }
         else
         {
            for(prio in config.priorities)
            {
               if(config.priorities[prio] != null)
               {
                  prioLookup = prio.toUpperCase();
                  if(targetName.indexOf(prioLookup) != -1)
                  {
                     for(part in parts)
                     {
                        if(parts[part].indexOf(config.priorities[prio]) != -1)
                        {
                           displayMessage("Found target " + prioLookup + ", selecting part " + part + ": " + parts[part]);
                           this.topLevel.BGSCodeObj.SelectPart(part);
                           foundTarget = true;
                           break;
                        }
                     }
                     if(foundTarget)
                     {
                        break;
                     }
                  }
               }
            }
         }
      }
      
      public function showHUDChildren() : void
      {
         if(!this.topLevel)
         {
            return;
         }
         var i:int = 0;
         while(i < this.topLevel.numChildren)
         {
            if(this.topLevel.getChildAt(i) is Loader)
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i).content));
            }
            else
            {
               displayMessage(i + ":" + getQualifiedClassName(this.topLevel.getChildAt(i)));
            }
            i++;
         }
      }
   }
}
