var Notifications = require('cloud/Notifications.js');

exports.main = function(request, response){
  var query = new Parse.Query("Photo");
  query.include("user");
  query.include("user_full");

  var objid = request.params.objectid;
  var userWhoLikedID = request.params.userWhoLikedID;
  var userWhoLikedUsername = request.params.userWhoLikedUsername;  

  query.get(objid, {
    success: function(photo) {
        //console.log(userWhoLikedUsername);   	
    	var likesArray = photo.get("likes");
        var state = photo.get("state");
        var user = photo.get("user");     

        
        var username = user.get("username");
        var email = user.get("email");

    	var likesCounter = 0

        var url;

        if(state == "full"){
            url = photo.get("image_full")._url;
            
        }else{
            url = photo.get("image_half")._url;
        }

        var didUserLikedPhoto = false;

    	if(likesArray){
    		likesCounter = likesArray.length;
    		
    		
    		for (var i = likesCounter - 1; i >= 0; i--) {
    			if(likesArray[i] == userWhoLikedID){
    				didUserLikedPhoto = true;
    				likesArray.splice(i, 1);
    				break;
    			}
    		};

    		if(!didUserLikedPhoto){
    			likesArray.push(userWhoLikedID);
    			likesCounter++;	
    		}else{
    			likesCounter--;	
    		}
    	}else{
    		likesArray = new Array();
    		likesArray.push(userWhoLikedID);
    		likesCounter++;	
    	}

    	console.log(likesArray);
    	photo.set("likes",likesArray);
    	photo.save({likingPhoto:"yes"});

        //if user liked a photo, this service is unlikning the photo so we should only send notifications if liking the photo
        if(!didUserLikedPhoto){
            var msg = userWhoLikedUsername+ " just liked your photo." ;            
            var htmlMsg = "<br><a href='http://www.2by2app.com/pdp/"+photo.id+"'>See photo.</a>";
            htmlMsg += "<br><br>";
            htmlMsg += "Thanks,";
            htmlMsg += "<br>Team 2by2";
            htmlMsg += "<br>PS: To stop receiving this email, turn this notification off in the app settings page.";
            var subject = msg;

            console.log(msg);

            //don't send a notification if I am liking my own photo
            if(userWhoLikedID != user.id){
                Notifications.sendNotifications(null,"like",user.id,msg,htmlMsg,subject,photo.id,"",userWhoLikedID,userWhoLikedUsername,msg);
            }

            if(state == "full"){
                var user_full = photo.get("user_full");                              

                if(userWhoLikedID != user_full.id && userWhoLikedID != user.id){
                    Notifications.sendNotifications(response,"like",user_full.id,msg,htmlMsg,subject,photo.id,"",userWhoLikedID,userWhoLikedUsername,msg);
                }

            }
        }
	},    
    error: function(error) {
      //console.error("Got an error " + error.code + " : " + error.message);
      response.error(error);
    }
  });
}