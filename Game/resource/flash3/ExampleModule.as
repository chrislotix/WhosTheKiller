package  {
    
    import flash.display.MovieClip;
    //we have to import mouse events so flash knows what we're talking about
    import flash.events.MouseEvent;
    
    public class ExampleModule extends MovieClip {
		
		//hold the gameAPI
   	 	var gameAPI:Object;
		var globals:Object;
		
		var originalXScale:Number;
		var originalYScale:Number;
                
        public function ExampleModule() {
            //we add a listener to this.button1 (I called my button 'button1')
            //this listener listens to the CLICK mouseEvent, and when it observes it, it cals onButtonClicked
            //this.button1.addEventListener(MouseEvent.CLICK, onButtonClicked);
			this.myButton.addEventListener(MouseEvent.CLICK, onButtonClicked);
        }
		
		//set initialise this instance's gameAPI
		public function setup(api:Object, globals:Object) {
			this.gameAPI = api;
			
			//added globals to this module too (don't forget the variable!), we need it now
			this.globals = globals;
			
			//this is our listener for the event, onGoldUpdate() is the handler
    		this.gameAPI.SubscribeToGameEvent("cgm_player_gold_changed", this.onGoldUpdate);
		}
		
		public function onGoldUpdate(args:Object) : void {
			//get the ID of the player this UI belongs to, here we use a scaleform function from globals
			var pID:int = globals.Players.GetLocalPlayer();
			
			//check of the player in the event is the owner of this UI. Note that args are the parameters of the event
			if (args.player_ID == pID) {
				//if we can not afford another ability point, we will remove the button
				if (args.gold_amount < 200) {
					this.removeChild(this.myButton);
				}
			}
		}
        
        /*this function is new, it is the handler for our listener
         *handlers for mouseEvents always need the event:MouseEvent parameter.
         *the ': void' at the end gives the type of this function, handlers are always voids. */
        private function onButtonClicked(event:MouseEvent) : void {
            trace("click!");
			
			//Send the 'BuyAbilityPoint' command to the server. We do not need the 1, but I left it in as a parameter you can pass with your command.
			//If you want to multiple ability points with one click for example, you can pass the number of points instead of this 1.
			this.gameAPI.SendServerCommand("BuyAbilityPoint 1");
        }
		
		//we define a public function, because we call it from outside our module object.
		//we get four parameters, the stage's dimensions and the scale ratios. Flash does not have floats, we use Number for that.
		//you might wonder what happened to the ': void'. Whenever that is not added, void is assumed
		public function screenResize(stageW:int, stageH:int, scaleRatio:Number){
			//we set the position of this movieclip to the center of the stage
			//remember, the black cross in the center is our center. You control the alignment with this code, you can align your module however you like.
			this.x = stageW/2;
			this.y = stageH/2;
			
			//Let's say we want our element to scale proportional to the screen height, scale like this:
			this.scaleX = this.originalXScale * scaleRatio;
			this.scaleY = this.originalYScale * scaleRatio;
		}
    }
    
}